# ── Elevation Check ───────────────────────────────────────────────────────────
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges to install Apache Cassandra..." -ForegroundColor Yellow
    $process = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"") -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

# Cassandra requires Java 11+
Write-Host "Installing Apache Cassandra..." -ForegroundColor Cyan

# Check for Java
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Host "Java is required for Cassandra. Installing OpenJDK 11..." -ForegroundColor Yellow
    winget install -e --id EclipseAdoptium.Temurin.11.JDK --accept-source-agreements --accept-package-agreements --silent
}

# Download and Install
$cassandraVersion = "4.1.7"
$downloadUrl = "https://archive.apache.org/dist/cassandra/$cassandraVersion/apache-cassandra-$cassandraVersion-bin.tar.gz"
$downloadPath = "$env:TEMP\cassandra.tar.gz"
$installPath = "C:\cassandra"

if (-not (Test-Path $installPath)) {
    Write-Host "Downloading Apache Cassandra $cassandraVersion..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -UseBasicParsing
    
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    
    Write-Host "Extracting Cassandra..."
    tar -xzf $downloadPath -C $installPath --strip-components=1
    Remove-Item $downloadPath -Force
}

# Dynamically find the real home if it was installed differently (e.g. via choco)
$cassandraHome = if (Test-Path "C:\cassandra") { "C:\cassandra" } else { "C:\ProgramData\chocolatey\lib\cassandra\tools" }
$cassandraBin  = Join-Path $cassandraHome "bin"

if (Test-Path $cassandraBin) {
    Write-Host "Detected Cassandra at $cassandraHome" -ForegroundColor Green
    
    # Set environment variables
    [System.Environment]::SetEnvironmentVariable("CASSANDRA_HOME", $cassandraHome, "User")
    [System.Environment]::SetEnvironmentVariable("CASSANDRA_HOST", "127.0.0.1", "User")
    [System.Environment]::SetEnvironmentVariable("CASSANDRA_PORT", "9042", "User")

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$cassandraBin*") {
        $pathParts = $currentPath.Split(';') | Where-Object { $_ }
        $pathParts += $cassandraBin
        [System.Environment]::SetEnvironmentVariable("Path", ($pathParts -join ';'), "User")
    }

    Write-Host "Apache Cassandra setup complete." -ForegroundColor Green
    Write-Host "Default port: 9042 | Default host: 127.0.0.1"
    Write-Host "Please restart your terminal to apply PATH changes."
} else {
    Write-Error "Could not find Cassandra installation."
    exit 1
}
