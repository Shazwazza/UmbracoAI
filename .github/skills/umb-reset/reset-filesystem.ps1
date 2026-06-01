# Umbraco Reset — Filesystem Cleanup
# Removes all generated CSS, custom partial views, and template views.
# Safe to run at any time — preserves Umbraco's built-in blockgrid/blocklist/singleblock partials.

param(
    [string]$ProjectRoot = (Join-Path $PSScriptRoot ".." ".." ".." "src" "MyProject")
)

$ProjectRoot = Resolve-Path $ProjectRoot

Write-Host "=== Umbraco Filesystem Reset ===" -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot"

# 1. Delete all CSS files in wwwroot/css
$cssDir = Join-Path $ProjectRoot "wwwroot" "css"
if (Test-Path $cssDir) {
    $cssFiles = Get-ChildItem $cssDir -File -Recurse
    if ($cssFiles) {
        $cssFiles | Remove-Item -Force
        Write-Host "[OK] Deleted $($cssFiles.Count) CSS file(s)" -ForegroundColor Green
    } else {
        Write-Host "[--] No CSS files to delete" -ForegroundColor DarkGray
    }
} else {
    Write-Host "[--] No css directory found" -ForegroundColor DarkGray
}

# 2. Delete custom partial views (keep blockgrid, blocklist, singleblock)
$partialsDir = Join-Path $ProjectRoot "Views" "Partials"
$keepFolders = @("blockgrid", "blocklist", "singleblock")

if (Test-Path $partialsDir) {
    # Delete loose files (custom partials like _Navigation.cshtml, _Footer.cshtml)
    $partialFiles = Get-ChildItem $partialsDir -File -ErrorAction SilentlyContinue
    if ($partialFiles) {
        $partialFiles | Remove-Item -Force
        Write-Host "[OK] Deleted $($partialFiles.Count) partial view file(s)" -ForegroundColor Green
    } else {
        Write-Host "[--] No partial view files to delete" -ForegroundColor DarkGray
    }

    # Delete custom folders (anything not in the keep list)
    $customFolders = Get-ChildItem $partialsDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $keepFolders }
    if ($customFolders) {
        $customFolders | Remove-Item -Recurse -Force
        Write-Host "[OK] Deleted $($customFolders.Count) custom partial folder(s)" -ForegroundColor Green
    } else {
        Write-Host "[--] No custom partial folders to delete" -ForegroundColor DarkGray
    }
} else {
    Write-Host "[--] No Partials directory found" -ForegroundColor DarkGray
}

# 3. Delete generated template views (e.g., home.cshtml, blogList.cshtml, blogPost.cshtml)
#    Keep _ViewImports.cshtml and _ViewStart.cshtml
$viewsDir = Join-Path $ProjectRoot "Views"
$keepFiles = @("_ViewImports.cshtml", "_ViewStart.cshtml")
$keepDirs = @("Partials", "Shared")

if (Test-Path $viewsDir) {
    $viewFiles = Get-ChildItem $viewsDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $keepFiles }
    if ($viewFiles) {
        $viewFiles | Remove-Item -Force
        Write-Host "[OK] Deleted $($viewFiles.Count) template view file(s)" -ForegroundColor Green
    } else {
        Write-Host "[--] No template view files to delete" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=== Filesystem cleanup complete ===" -ForegroundColor Cyan
