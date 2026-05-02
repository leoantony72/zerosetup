# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install ClickHouse..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install ClickHouse on Windows
Write-Host "Installing ClickHouse..." -ForegroundColor Cyan

$chVersion = "25.1.3.26"
# ClickHouse now provides a single binary for Windows
$downloadUrl = "https://github.com/ClickHouse/ClickHouse/releases/download/v$chVersion-stable/clickhouse-windows.exe"
$installPath = "C:\clickhouse"
$binPath = Join-Path $installPath "bin"
$exePath = Join-Path $binPath "clickhouse.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "Downloading ClickHouse binary $chVersion..."
    if (!(Test-Path $binPath)) { New-Item -ItemType Directory -Path $binPath -Force | Out-Null }
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -UseBasicParsing
    } catch {
        Write-Host "Primary download failed. Trying alternative..." -ForegroundColor Yellow
        # Fallback to a slightly older known version if latest is 404
        $fallbackUrl = "https://github.com/ClickHouse/ClickHouse/releases/download/v24.8.2.257-stable/clickhouse-windows.exe"
        Invoke-WebRequest -Uri $fallbackUrl -OutFile $exePath -UseBasicParsing
    }
}

if (Test-Path $exePath) {
    Write-Host "Detected ClickHouse at $installPath" -ForegroundColor Green
    
    # Create data and log directories
    foreach ($dir in @("data", "logs", "config")) {
        $p = Join-Path $installPath $dir
        if (!(Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
    }

    # Set environment variables
    [System.Environment]::SetEnvironmentVariable("CLICKHOUSE_HOME", $installPath, "User")
    [System.Environment]::SetEnvironmentVariable("CLICKHOUSE_HOST", "localhost", "User")

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$binPath*") {
        $pathParts = $currentPath.Split(';') | Where-Object { $_ }
        $pathParts += $binPath
        [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
    }

    Write-Host "ClickHouse setup complete." -ForegroundColor Green
    Write-Host "Start server: clickhouse server --config-file=C:\clickhouse\config\config.xml"
    Write-Host "Please restart your terminal to apply PATH changes."
} else {
    Write-Error "Could not find ClickHouse installation."
    exit 1
}
