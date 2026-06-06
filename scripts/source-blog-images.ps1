<#
.SYNOPSIS
    Sources one topical hero image per blog post from Unsplash and prints a
    compact JSON mapping. Image DISCOVERY only - it never touches Umbraco.

.DESCRIPTION
    The umb-image-sourcing skill uses this script so the LLM does NOT have to call
    an Unsplash MCP tool once per post (which floods the context with large JSON
    blobs). Instead the agent runs this once with a small [{slug, query}] list and
    reads back a single compact JSON array.

    For each post the script:
      - queries the Unsplash API (search/photos) using an access key,
      - takes the most relevant landscape result,
      - builds a sized JPG CDN URL (Umbraco downloads it server-side later),
      - records the photographer name + profile URL for attribution,
      - pings Unsplash's required download endpoint (ToS attribution).

    If the Unsplash call fails, returns nothing, the key is missing, or the rate
    limit is hit, the post falls back to a stable Lorem Picsum image so the live
    demo never stalls.

    The script does NOT upload anything to Umbraco. Uploading the returned URLs
    into the media library is done by the skill via the umbraco-mcp tools.

.PARAMETER InputFile
    Path to a JSON file containing an array of objects: [{ "slug": "...", "query": "..." }].

.PARAMETER Posts
    Inline JSON array (same shape as InputFile). Use this OR InputFile.

.PARAMETER AccessKey
    Unsplash access key. Defaults to $env:UNSPLASH_ACCESS_KEY, then the demo key.

.PARAMETER OutFile
    Optional path to also write the compact JSON output to.

.OUTPUTS
    A minified JSON array to stdout, one object per post:
    [{ "slug", "query", "url", "source", "photographer", "profile", "photoId" }]
    where source is "unsplash" or "picsum".

.EXAMPLE
    pwsh scripts/source-blog-images.ps1 -InputFile posts.json

.EXAMPLE
    pwsh scripts/source-blog-images.ps1 -Posts '[{"slug":"hello-ai","query":"artificial intelligence"}]'
#>
[CmdletBinding()]
param(
    [string]$InputFile,
    [string]$Posts,
    [string]$AccessKey,
    [string]$OutFile
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# --- Resolve the access key (param > env > demo default) ----------------------
if (-not $AccessKey) { $AccessKey = $env:UNSPLASH_ACCESS_KEY }
if (-not $AccessKey) { $AccessKey = "RnkKYvk5jR6HcPqZqCsMaZPJLFerwyXPHTCX2L37lZY" }

# --- Load the post list -------------------------------------------------------
if ($InputFile) {
    if (-not (Test-Path $InputFile)) { throw "InputFile not found: $InputFile" }
    $raw = Get-Content -Raw -Path $InputFile
} elseif ($Posts) {
    $raw = $Posts
} else {
    throw "Provide either -InputFile <path> or -Posts <json string>."
}

$postList = $raw | ConvertFrom-Json
if ($null -eq $postList) { throw "No posts parsed from input." }
if ($postList -isnot [System.Array]) { $postList = @($postList) }

function Invoke-WithRetry {
    param([scriptblock]$Action, [int]$Retries = 2)
    for ($i = 0; $i -le $Retries; $i++) {
        try { return & $Action }
        catch {
            if ($i -eq $Retries) { throw }
            Start-Sleep -Milliseconds (300 * ($i + 1))
        }
    }
}

function Get-PicsumUrl {
    param([string]$Slug)
    return "https://picsum.photos/seed/$Slug/1200/800"
}

$headers = @{ Authorization = "Client-ID $AccessKey"; "Accept-Version" = "v1" }
$results = New-Object System.Collections.Generic.List[object]

foreach ($p in $postList) {
    $slug = "$($p.slug)".Trim()
    $query = "$($p.query)".Trim()
    if (-not $slug) { Write-Warning "Skipping post with no slug."; continue }
    if (-not $query) { $query = $slug -replace "-", " " }

    $entry = [ordered]@{
        slug         = $slug
        query        = $query
        url          = $null
        source       = "picsum"
        photographer = $null
        profile      = $null
        photoId      = $null
    }

    $ok = $false
    try {
        $q = [uri]::EscapeDataString($query)
        $uri = "https://api.unsplash.com/search/photos?query=$q&orientation=landscape&per_page=3&order_by=relevant"
        $resp = Invoke-WithRetry { Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -TimeoutSec 20 }

        if ($resp.results -and $resp.results.Count -gt 0) {
            $photo = $resp.results[0]
            $rawUrl = $photo.urls.raw
            $url = if ($rawUrl) { "$rawUrl&w=1600&q=80&fm=jpg" } else { $photo.urls.regular }

            $entry.url = $url
            $entry.source = "unsplash"
            $entry.photographer = $photo.user.name
            $entry.profile = $photo.user.links.html
            $entry.photoId = $photo.id

            # Unsplash ToS: ping the download endpoint when a photo is selected.
            try {
                $dl = $photo.links.download_location
                if ($dl) { Invoke-WithRetry { Invoke-RestMethod -Uri $dl -Headers $headers -Method Get -TimeoutSec 20 } | Out-Null }
            } catch {
                Write-Warning "Attribution ping failed for '$slug': $($_.Exception.Message)"
            }
            $ok = $true
        } else {
            Write-Warning "No Unsplash results for '$query' ($slug); using Picsum fallback."
        }
    } catch {
        Write-Warning "Unsplash search failed for '$query' ($slug): $($_.Exception.Message). Using Picsum fallback."
    }

    if (-not $ok) {
        $entry.url = Get-PicsumUrl -Slug $slug
        $entry.source = "picsum"
    }

    $results.Add([pscustomobject]$entry)
}

# Force a JSON array even for a single result (ConvertTo-Json unwraps singletons).
$outJson = "[" + (($results | ForEach-Object { $_ | ConvertTo-Json -Depth 5 -Compress }) -join ",") + "]"

if ($OutFile) { Set-Content -Path $OutFile -Value $outJson -Encoding UTF8 }
Write-Output $outJson
