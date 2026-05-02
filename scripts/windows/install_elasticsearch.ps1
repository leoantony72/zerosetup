# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install Elasticsearch..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install Elasticsearch using Winget
Write-Host "Installing Elasticsearch..." -ForegroundColor Cyan
winget install -e --id Elastic.Elasticsearch --accept-source-agreements --accept-package-agreements --silent

# Dynamically discover installation path
$basePaths = @("C:\Program Files\Elastic", "C:\elasticsearch")
$esInstallPath = $null

foreach ($basePath in $basePaths) {
    if (Test-Path $basePath) {
        $esDir = Get-ChildItem $basePath -Directory -Filter "elasticsearch*" | Sort-Object Name -Descending | Select-Object -First 1
        if ($esDir) {
            $esInstallPath = $esDir.FullName
            break
        }
    }
}

if ($esInstallPath) {
    $esBinPath = Join-Path $esInstallPath "bin"
    Write-Host "Detected Elasticsearch at $esInstallPath" -ForegroundColor Green
    
    Write-Host "Configuring Elasticsearch environment variables..."
    [System.Environment]::SetEnvironmentVariable("ES_HOME", $esInstallPath, "User")

    # Update PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$esBinPath*") {
        $pathParts = $currentPath.Split(';') | Where-Object { $_ -and $_ -ne $esBinPath }
        $pathParts += $esBinPath
        [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
    }

    # Service should be started manually by the user
    Write-Host "Elasticsearch setup complete." -ForegroundColor Green

    Write-Host "Elasticsearch setup complete." -ForegroundColor Green
    Write-Host "Default port: 9200 | Default host: localhost"
    Write-Host "Please restart your terminal to apply PATH changes."
} else {
    Write-Error "Could not find Elasticsearch installation."
    exit 1
}
