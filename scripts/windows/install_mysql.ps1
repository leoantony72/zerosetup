# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install MySQL..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install MySQL using Winget
Write-Host "Installing MySQL..." -ForegroundColor Cyan
winget install -e --id Oracle.MySQL --accept-source-agreements --accept-package-agreements --silent

# Dynamically discover installation path
$basePath = "C:\Program Files\MySQL"
if (Test-Path $basePath) {
    # Search for the MySQL Server directory
    $mysqlServerDir = Get-ChildItem $basePath -Directory -Filter "MySQL Server*" | Sort-Object Name -Descending | Select-Object -First 1
    if ($mysqlServerDir) {
        $mysqlInstallPath = $mysqlServerDir.FullName
        $mysqlBinPath = Join-Path $mysqlInstallPath "bin"
        
        Write-Host "Detected MySQL at $mysqlInstallPath" -ForegroundColor Green
        
        Write-Host "Configuring MySQL environment variables..."
        [System.Environment]::SetEnvironmentVariable("MYSQL_HOME", $mysqlInstallPath, "User")

        # Update PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$mysqlBinPath*") {
            $pathParts = $currentPath.Split(';') | Where-Object { $_ -and $_ -ne $mysqlBinPath }
            $pathParts += $mysqlBinPath
            [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
        }

        Write-Host "MySQL setup complete." -ForegroundColor Green
        Write-Host "Default port: 3306 | Default user: root"
        Write-Host "Please restart your terminal to apply PATH changes."
    } else {
        Write-Error "Could not find MySQL Server directory in $basePath"
        exit 1
    }
} else {
    Write-Error "MySQL installation base path not found at $basePath"
    exit 1
}

