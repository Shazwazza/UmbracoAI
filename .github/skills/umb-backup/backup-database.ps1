# Umbraco Database Backup Script
# Creates a timestamped backup of the Umbraco LocalDB database.
# Usage: & ".github/skills/umb-backup/backup-database.ps1"

param(
    [string]$ProjectRoot = (Join-Path $PSScriptRoot ".." ".." ".." "src" "MyProject")
)

$ProjectRoot = Resolve-Path $ProjectRoot
$ErrorActionPreference = "Stop"

Write-Host "=== Umbraco Database Backup ===" -ForegroundColor Cyan

# 1. Generate timestamp and create backup directory
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $ProjectRoot "umbraco" "Data" "backups" $timestamp
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Write-Host "[OK] Backup directory: $backupDir" -ForegroundColor Green

# 2. Query LocalDB for the Umbraco database name
$dbNameRaw = sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE name NOT IN ('master','tempdb','model','msdb')" -h -1 -W 2>&1
$dbName = ($dbNameRaw | Where-Object { $_ -and $_.Trim() -ne "" } | Select-Object -First 1).Trim()

if (-not $dbName) {
    Write-Host "[ERROR] Could not find Umbraco database in LocalDB" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Database: $dbName" -ForegroundColor Green

# 3. Run the backup
$bakFile = Join-Path $backupDir "Umbraco.bak"
Write-Host "Backing up to: $bakFile ..." -ForegroundColor Yellow
sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "BACKUP DATABASE [$dbName] TO DISK = N'$bakFile' WITH FORMAT, INIT, NAME = N'Umbraco Backup'" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Backup command failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}

# 4. Verify
if (Test-Path $bakFile) {
    $size = (Get-Item $bakFile).Length
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "[OK] Backup complete: $bakFile ($sizeMB MB)" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Backup file not found at $bakFile" -ForegroundColor Red
    exit 1
}

Write-Host "=== Backup finished ===" -ForegroundColor Cyan
