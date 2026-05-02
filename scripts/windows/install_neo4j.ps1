# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install Neo4j..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install Neo4j on Windows
Write-Host "Installing Neo4j..." -ForegroundColor Cyan

# Attempt Neo4j Desktop via winget (most common for Windows)
winget install -e --id Neo4j.Neo4jDesktop --accept-source-agreements --accept-package-agreements --silent

# Dynamically discover installation path
$basePaths = @("C:\neo4j", "C:\Program Files\Neo4j")
$neo4jHome = $null

foreach ($basePath in $basePaths) {
    if (Test-Path $basePath) {
        $neo4jHome = $basePath
        break
    }
}

# Check for Neo4j Desktop specifically if server not found in direct paths
if (-not $neo4jHome) {
    $desktopPath = "$env:LOCALAPPDATA\Programs\Neo4j Desktop"
    if (Test-Path $desktopPath) {
        $neo4jHome = $desktopPath
    }
}

if ($neo4jHome) {
    Write-Host "Detected Neo4j at $neo4jHome" -ForegroundColor Green
    $neo4jBin = Join-Path $neo4jHome "bin"
    
    # Set environment variables
    [System.Environment]::SetEnvironmentVariable("NEO4J_HOME", $neo4jHome, "User")
    [System.Environment]::SetEnvironmentVariable("NEO4J_HOST", "localhost", "User")

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$neo4jBin*") {
        $pathParts = $currentPath.Split(';') | Where-Object { $_ }
        $pathParts += $neo4jBin
        [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
    }

    Write-Host "Neo4j setup complete." -ForegroundColor Green
    Write-Host "Please restart your terminal to apply PATH changes."
} else {
    Write-Host "Neo4j Desktop installed. Please open it to manage your database instances." -ForegroundColor Yellow
}
