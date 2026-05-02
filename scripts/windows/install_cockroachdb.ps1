# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install CockroachDB..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Install CockroachDB on Windows
Write-Host "Installing CockroachDB..." -ForegroundColor Cyan

$crdbVersion = "v24.3.4"
$downloadUrl = "https://binaries.cockroachdb.com/cockroach-$crdbVersion.windows-6.2-amd64.zip"
$downloadPath = "$env:TEMP\cockroach.zip"
$installPath = "C:\cockroachdb"
$binPath = Join-Path $installPath "bin"

if (-not (Test-Path $binPath)) {
    Write-Host "Downloading CockroachDB $crdbVersion..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -UseBasicParsing

    Write-Host "Extracting CockroachDB..."
    if (!(Test-Path $installPath)) { New-Item -ItemType Directory -Path $installPath -Force | Out-Null }
    if (!(Test-Path $binPath))     { New-Item -ItemType Directory -Path $binPath     -Force | Out-Null }

    Expand-Archive -Path $downloadPath -DestinationPath "$env:TEMP\cockroach_extract" -Force
    $extractedDir = Get-ChildItem "$env:TEMP\cockroach_extract" -Directory | Select-Object -First 1
    Copy-Item "$($extractedDir.FullName)\cockroach.exe" -Destination "$binPath\cockroach.exe" -Force

    Remove-Item $downloadPath -Force
    Remove-Item "$env:TEMP\cockroach_extract" -Recurse -Force
}

if (Test-Path "$binPath\cockroach.exe") {
    Write-Host "Detected CockroachDB at $installPath" -ForegroundColor Green
    
    Write-Host "Configuring CockroachDB environment variables..."
    [System.Environment]::SetEnvironmentVariable("COCKROACHDB_HOME", $installPath, "User")
    [System.Environment]::SetEnvironmentVariable("COCKROACHDB_HOST", "localhost", "User")
    [System.Environment]::SetEnvironmentVariable("COCKROACHDB_PORT", "26257", "User")

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$binPath*") {
        $pathParts = $currentPath.Split(';') | Where-Object { $_ }
        $pathParts += $binPath
        [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
    }

    Write-Host "CockroachDB setup complete." -ForegroundColor Green
    Write-Host "Default SQL port: 26257 | Admin UI port: 8080"
    Write-Host "Please restart your terminal to apply PATH changes."
} else {
    Write-Error "Could not find CockroachDB installation."
    exit 1
}
