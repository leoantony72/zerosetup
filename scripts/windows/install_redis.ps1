# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install Redis (Memurai)..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install Redis using Winget (Memurai - Redis-compatible for Windows)
Write-Host "Installing Memurai (Redis for Windows)..." -ForegroundColor Cyan

# Attempt Memurai Developer via winget
winget install -e --id Memurai.MemuraiDeveloper --accept-source-agreements --accept-package-agreements --silent

# Dynamically discover installation path
$basePath = "C:\Program Files\Memurai"
if (-not (Test-Path $basePath)) {
    # Fallback to general Memurai path if it exists but not in the specific folder
    $basePath = Get-ChildItem "C:\Program Files" -Directory -Filter "Memurai*" | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if ($basePath -and (Test-Path $basePath)) {
    Write-Host "Detected Memurai at $basePath" -ForegroundColor Green
    
    $redisBinPath = $basePath
    
    # Configure environment
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$redisBinPath*") {
        $pathParts = $currentPath.Split(';') | Where-Object { $_ }
        $pathParts += $redisBinPath
        [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
    }

    [System.Environment]::SetEnvironmentVariable("REDIS_HOST", "127.0.0.1", "User")
    [System.Environment]::SetEnvironmentVariable("REDIS_PORT", "6379", "User")

    # Service should be started manually by the user
    Write-Host "Redis (Memurai) setup complete." -ForegroundColor Green
    Write-Host "Default host: 127.0.0.1 | Default port: 6379"
    Write-Host "Please restart your terminal to apply changes."
} else {
    Write-Host "Automatic installation might have failed or installed in a non-standard path." -ForegroundColor Yellow
    Write-Host "Please check if 'memurai-cli' is available in your terminal."
}
