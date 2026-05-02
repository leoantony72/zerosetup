# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install MongoDB..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install MongoDB using Winget
Write-Host "Installing MongoDB..." -ForegroundColor Cyan
winget install -e --id MongoDB.Server --accept-source-agreements --accept-package-agreements --silent

# Dynamically discover installation path
$basePath = "C:\Program Files\MongoDB\Server"
if (Test-Path $basePath) {
    # Get the latest version folder (e.g., 8.0, 7.0, etc.)
    $mongoVersionDir = Get-ChildItem $basePath -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($mongoVersionDir) {
        $mongodbInstallPath = $mongoVersionDir.FullName
        $mongodbBinPath = Join-Path $mongodbInstallPath "bin"
        $mongodbDataPath = "C:\data\db"
        $mongodbLogPath = "C:\data\log"

        Write-Host "Detected MongoDB at $mongodbInstallPath" -ForegroundColor Green
        
        Write-Host "Creating MongoDB data and log directories..."
        foreach ($dir in @($mongodbDataPath, $mongodbLogPath)) {
            if (!(Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
        }

        Write-Host "Configuring MongoDB environment variables..."
        [System.Environment]::SetEnvironmentVariable("MONGODB_HOME", $mongodbInstallPath, "User")
        [System.Environment]::SetEnvironmentVariable("MONGODB_DATA", $mongodbDataPath, "User")
        [System.Environment]::SetEnvironmentVariable("MONGODB_LOG", $mongodbLogPath, "User")

        # Update PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$mongodbBinPath*") {
            $pathParts = $currentPath.Split(';') | Where-Object { $_ -and $_ -ne $mongodbBinPath }
            $pathParts += $mongodbBinPath
            [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
        }

        # Service should be started manually by the user
        Write-Host "MongoDB setup complete." -ForegroundColor Green

        Write-Host "MongoDB setup complete." -ForegroundColor Green
        Write-Host "Default port: 27017 | Connection string: mongodb://localhost:27017"
        Write-Host "Please restart your terminal to apply PATH changes."
    } else {
        Write-Error "Could not find MongoDB Server version directory in $basePath"
        exit 1
    }
} else {
    Write-Error "MongoDB installation base path not found at $basePath"
    exit 1
}

