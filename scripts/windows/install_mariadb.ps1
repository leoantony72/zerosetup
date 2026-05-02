# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install MariaDB..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install MariaDB using Winget
Write-Host "Installing MariaDB..." -ForegroundColor Cyan
winget install -e --id MariaDB.Server --accept-source-agreements --accept-package-agreements --silent

# Dynamically discover installation path
$basePath = "C:\Program Files\MariaDB"
if (-not (Test-Path $basePath)) {
    $basePath = Get-ChildItem "C:\Program Files" -Directory -Filter "MariaDB*" | Sort-Object Name -Descending | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if ($basePath -and (Test-Path $basePath)) {
    Write-Host "Detected MariaDB at $basePath" -ForegroundColor Green
    
    $mariadbBinPath = Join-Path $basePath "bin"
    
    Write-Host "Configuring MariaDB environment variables..."
    [System.Environment]::SetEnvironmentVariable("MARIADB_HOME", $basePath, "User")
    [System.Environment]::SetEnvironmentVariable("MARIADB_HOST", "localhost", "User")
    [System.Environment]::SetEnvironmentVariable("MARIADB_PORT", "3306", "User")

    # Update PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$mariadbBinPath*") {
        $pathParts = $currentPath.Split(';') | Where-Object { $_ -and $_ -ne $mariadbBinPath }
        $pathParts += $mariadbBinPath
        [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
    }

    # Service should be started manually by the user
    Write-Host "MariaDB setup complete." -ForegroundColor Green

    Write-Host "MariaDB setup complete." -ForegroundColor Green
    Write-Host "Default port: 3306 | Default user: root"
    Write-Host "Please restart your terminal to apply PATH changes."
} else {
    Write-Error "Could not find MariaDB installation path."
    exit 1
}

