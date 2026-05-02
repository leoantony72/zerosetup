# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install PostgreSQL..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install PostgreSQL using Winget
Write-Host "Installing PostgreSQL..." -ForegroundColor Cyan
winget install -e --id PostgreSQL.PostgreSQL.17 --accept-source-agreements --accept-package-agreements --silent

# Dynamically discover installation path
$basePath = "C:\Program Files\PostgreSQL"
if (Test-Path $basePath) {
    $pgVersionDir = Get-ChildItem $basePath -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($pgVersionDir) {
        $pgInstallPath = $pgVersionDir.FullName
        $pgBinPath = Join-Path $pgInstallPath "bin"
        $pgDataPath = Join-Path $pgInstallPath "data"
        $pgVersion = $pgVersionDir.Name
        
        Write-Host "Detected PostgreSQL $pgVersion at $pgInstallPath" -ForegroundColor Green
        
        Write-Host "Configuring PostgreSQL environment variables..."
        [System.Environment]::SetEnvironmentVariable("PGDATA", $pgDataPath, "User")
        [System.Environment]::SetEnvironmentVariable("PGVERSION", $pgVersion, "User")

        # Update PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$pgBinPath*") {
            $pathParts = $currentPath.Split(';') | Where-Object { $_ -and $_ -ne $pgBinPath }
            $pathParts += $pgBinPath
            [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
        }

        Write-Host "PostgreSQL setup complete." -ForegroundColor Green
        Write-Host "Default port: 5432 | Default user: postgres"
        Write-Host "Please restart your terminal to apply PATH changes."
    } else {
        Write-Error "Could not find PostgreSQL version directory in $basePath"
        exit 1
    }
} else {
    Write-Error "PostgreSQL installation base path not found at $basePath"
    exit 1
}

