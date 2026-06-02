# Umbraco Sitemap Generator
# Generates a well-formed sitemap.xml from a base URL and a list of relative URLs.
#
# Usage:
#   & ".github/skills/umb-sitemap/generate-sitemap.ps1" -BaseUrl "http://localhost:14737" -Urls "/", "/blog/", "/blog/my-post/"
#
# The sitemap is written to src/MyProject/wwwroot/sitemap.xml

param(
    [Parameter(Mandatory)]
    [string]$BaseUrl,

    [Parameter(Mandatory, ValueFromRemainingArguments)]
    [string[]]$Urls,

    [string]$ProjectRoot = (Join-Path $PSScriptRoot ".." ".." ".." "src" "MyProject")
)

$ProjectRoot = Resolve-Path $ProjectRoot
$outputPath = Join-Path $ProjectRoot "wwwroot" "sitemap.xml"

Write-Host "=== Generating sitemap.xml ===" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl"
Write-Host "URLs: $($Urls.Count)"

$xml = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
"@

foreach ($url in $Urls) {
    $fullUrl = $BaseUrl.TrimEnd('/') + $url
    # Root and top-level pages get higher priority
    $segments = ($url.Trim('/') -split '/').Count
    if ($url -eq '/') {
        $priority = "1.0"
        $freq = "daily"
    } elseif ($segments -le 1) {
        $priority = "0.9"
        $freq = "daily"
    } else {
        $priority = "0.8"
        $freq = "weekly"
    }

    $xml += @"

  <url>
    <loc>$fullUrl</loc>
    <changefreq>$freq</changefreq>
    <priority>$priority</priority>
  </url>
"@
}

$xml += @"

</urlset>
"@

# Ensure wwwroot directory exists
$wwwroot = Join-Path $ProjectRoot "wwwroot"
if (-not (Test-Path $wwwroot)) {
    New-Item -ItemType Directory -Path $wwwroot -Force | Out-Null
}

$xml | Out-File -FilePath $outputPath -Encoding UTF8 -NoNewline
Write-Host "[OK] Sitemap written to: $outputPath" -ForegroundColor Green
Write-Host "[OK] Contains $($Urls.Count) URLs" -ForegroundColor Green
Write-Host "=== Done ===" -ForegroundColor Cyan
