<#
.SYNOPSIS
    Starts a headed Playwright MCP server over HTTP for the Umbraco demo.

.DESCRIPTION
    Clients connect to this server over HTTP. Because the server is started with
    --shared-browser-context, every client connected to the SAME server drives
    the SAME browser window - so the audience always sees the live interactions
    instead of a hidden, behind-the-scenes browser.

    Run this BEFORE starting the Copilot CLI session and before running the
    conductor workflow. The server is launched detached so it outlives both,
    which also keeps the demo browser open at the end of the run.

    The script is idempotent: if a healthy server is already listening on the
    port it does nothing. The browser profile is per-port, so you can run two
    independent servers on different ports to get two separate, simultaneous
    browser windows. For the dual demo (agent + Conductor at once), start one
    server per consumer:

        # Window 1: the traditional demo agent (.mcp.json -> port 8931)
        powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1
        # Window 2: the Conductor workflow (umbraco-demo.yaml -> port 8932)
        powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1 -Port 8932

.PARAMETER Port
    TCP port for the Playwright MCP HTTP endpoint. Default: 8931.
    Use 8932 for the Conductor workflow's separate browser window.

.PARAMETER Version
    Pinned @playwright/mcp version. Default: 0.0.75.
#>
[CmdletBinding()]
param(
    [int]$Port = 8931,
    [string]$Version = "0.0.75"
)

$ErrorActionPreference = "Stop"

# Use a space-free profile path. The repo path contains spaces, and passing a
# spaced --user-data-dir through npx.cmd -> node mangles arguments on Windows
# (Playwright then errors with "too many arguments"). LOCALAPPDATA is the
# conventional, reliably space-free home for a browser profile.
# The profile dir is per-port so multiple servers (e.g. one for the agent and
# one for the Conductor workflow) can run side by side with independent browser
# windows instead of clashing on a single shared profile.
$profileDir = Join-Path $env:LOCALAPPDATA "umbraco-demo-playwright-mcp-$Port"
$mcpUrl = "http://localhost:$Port/mcp"

# --- Idempotency: skip if a server is already listening on the port ----------
$listening = $false
try {
    $conn = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -WarningAction SilentlyContinue
    $listening = $conn.TcpTestSucceeded
} catch {
    $listening = $false
}

if ($listening) {
    Write-Host "Playwright MCP server already listening on port $Port - reusing it." -ForegroundColor Green
    Write-Host "  Endpoint: $mcpUrl"
    return
}

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$mcpArgs = @(
    "-y", "@playwright/mcp@$Version",
    "--port", "$Port",
    "--host", "127.0.0.1",
    "--allowed-hosts", "localhost,127.0.0.1,localhost:$Port,127.0.0.1:$Port",
    "--shared-browser-context",
    "--user-data-dir", "$profileDir"
)

# Resolve a launchable npx. On Windows the PATH entry is often npx.ps1, which
# Start-Process cannot execute directly; prefer the sibling npx.cmd.
$npxLauncher = "npx.cmd"
$npxCmdInfo = Get-Command npx.cmd -ErrorAction SilentlyContinue
if ($npxCmdInfo) {
    $npxLauncher = $npxCmdInfo.Source
}

Write-Host "Starting shared headed Playwright MCP server..." -ForegroundColor Cyan
Write-Host "  Version : @playwright/mcp@$Version"
Write-Host "  Endpoint: $mcpUrl"
Write-Host "  Profile : $profileDir"

# Launch detached so it survives the CLI session and the workflow run.
Start-Process -FilePath $npxLauncher -ArgumentList $mcpArgs -WindowStyle Minimized | Out-Null

# Wait for the endpoint to come up (npx may need to fetch the package first).
$deadline = (Get-Date).AddSeconds(60)
do {
    Start-Sleep -Seconds 1
    try {
        $conn = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -WarningAction SilentlyContinue
        $listening = $conn.TcpTestSucceeded
    } catch {
        $listening = $false
    }
} while (-not $listening -and (Get-Date) -lt $deadline)

if ($listening) {
    Write-Host "Playwright MCP server is up on $mcpUrl" -ForegroundColor Green
} else {
    Write-Warning "Timed out waiting for the Playwright MCP server on port $Port. Check that 'npx' and Node.js are installed."
    exit 1
}
