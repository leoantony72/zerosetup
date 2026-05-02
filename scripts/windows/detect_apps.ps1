# Detect installed applications by checking PATH, Registry, Services, and open ports
param (
    [string]$appsJson # JSON string representing the apps to check
)

# ── Helper: Test if a TCP port is listening locally ───────────────────────────
function Test-LocalPort {
    param([int]$Port)
    try {
        $conn = [System.Net.Sockets.TcpClient]::new()
        $result = $conn.BeginConnect('127.0.0.1', $Port, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne(300, $false)
        if ($success -and $conn.Connected) { $conn.Close(); return $true }
        $conn.Close(); return $false
    } catch { return $false }
}

# ── Helper: Test if a Windows service exists ──────────────────────────────────
function Test-ServiceExists {
    param([string]$Name)
    return ($null -ne (Get-Service -Name $Name -ErrorAction SilentlyContinue))
}

# ── Database IDs and their verification logic ─────────────────────────────────
$databaseIds = @('postgresql','mysql','redis','mongodb','cassandra','cockroachdb','elasticsearch','mariadb','neo4j','clickhouse')

# Ports to check per database ID
$dbPorts = @{
    'postgresql'    = 5432
    'mysql'         = 3306
    'redis'         = 6379
    'mongodb'       = 27017
    'cassandra'     = 9042
    'cockroachdb'   = 26257
    'elasticsearch' = 9200
    'mariadb'       = 3306
    'neo4j'         = 7474
    'clickhouse'    = 8123
}

# Windows service names per database ID (multiple candidates)
$dbServices = @{
    'postgresql'    = @('postgresql','postgresql-x64-17','postgresql-x64-16','postgresql-x64-15')
    'mysql'         = @('MySQL','MySQL80','MySQL57')
    'redis'         = @('Memurai','Redis')
    'mongodb'       = @('MongoDB','mongod')
    'cassandra'     = @('cassandra')
    'cockroachdb'   = @('CockroachDB')
    'elasticsearch' = @('elasticsearch')
    'mariadb'       = @('MariaDB','mariadb')
    'neo4j'         = @('neo4j','Neo4j')
    'clickhouse'    = @('clickhouse','ClickHouseServer')
}

# Known install paths per database ID
$dbPaths = @{
    'postgresql'    = @('C:\Program Files\PostgreSQL')
    'mysql'         = @('C:\Program Files\MySQL')
    'redis'         = @('C:\Program Files\Memurai','C:\redis','C:\Program Files\Redis')
    'mongodb'       = @('C:\Program Files\MongoDB\Server')
    'cassandra'     = @('C:\cassandra','C:\ProgramData\chocolatey\lib\cassandra')
    'cockroachdb'   = @('C:\cockroachdb\bin\cockroach.exe')
    'elasticsearch' = @('C:\elasticsearch')
    'mariadb'       = @('C:\Program Files\MariaDB 11.4','C:\Program Files\MariaDB')
    'neo4j'         = @('C:\neo4j','C:\Program Files\Neo4j')
    'clickhouse'    = @('C:\clickhouse\bin\clickhouse-server.exe')
}

if ([string]::IsNullOrWhiteSpace($appsJson)) {
    Write-Output "[]"
    exit
}

try {
    $apps = $appsJson | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse JSON: $_"
    Write-Output "[]"
    exit
}

$results = New-Object System.Collections.Generic.List[PSCustomObject]

foreach ($app in $apps) {
    if ($null -eq $app.id) { continue }
    
    $isInstalled = $false
    $version = "Not detected"
    $executable = $app.executable_cmd
    $programName = $app.program_name

    # 1. Check PATH (Only if executable is defined and non-empty)
    if (-not [string]::IsNullOrWhiteSpace($executable)) {
        # Check for commands of type Application to avoid aliases like 'http' -> 'Invoke-WebRequest'
        $cmd = Get-Command $executable -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cmd) {
            $isInstalled = $true
            if ($cmd.Definition -match "\.exe$") {
                try {
                    $verInfo = (Get-Item $cmd.Definition).VersionInfo.ProductVersion
                    if ($verInfo) { $version = $verInfo }
                } catch {}
            }
        }
    }

    # 2. Check Registry (if not found in PATH)
    if (-not $isInstalled -and -not [string]::IsNullOrWhiteSpace($programName)) {
        $regPaths = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($path in $regPaths) {
            $keys = Get-ItemProperty $path -ErrorAction SilentlyContinue
            if ($null -eq $keys) { continue }
            
            # Use stricter matching to avoid partial common word matches
            $matched = $keys | Where-Object { 
                ([string]$_.DisplayName -and [string]$_.DisplayName.Trim() -eq $programName) -or 
                ([string]$_.DisplayName -and [string]$_.DisplayName -like "*$programName*") -or
                ([string]$_.PSChildName -and [string]$_.PSChildName -eq $app.id)
            } | Select-Object -First 1

            if ($matched) {
                $isInstalled = $true
                if ($matched.DisplayVersion) { $version = [string]$matched.DisplayVersion }
                break
            }
        }
    }

    # 3. Last resort: Specific known paths for some stubborn apps
    if (-not $isInstalled) {
        $specificPaths = @()
        switch ($app.id) {
            "spotify" { 
                $specificPaths += "$env:APPDATA\Spotify\Spotify.exe"
                $specificPaths += "$env:LocalAppData\Microsoft\WindowsApps\Spotify.exe"
            }
            "vscode" { 
                $specificPaths += "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"
            }
            "discord" {
                $specificPaths += "$env:LocalAppData\Discord\Update.exe"
            }
            "postman" {
                $specificPaths += "$env:LocalAppData\Postman\Postman.exe"
            }
        }

        foreach ($p in $specificPaths) {
            if (Test-Path $p) {
                $isInstalled = $true
                break
            }
        }
    }

    # 4. Database-specific verification (service + port + path)
    if ($databaseIds -contains $app.id) {
        $dbInstalled = $false
        $isRunning = $false
        $matchedServiceName = $null
        $matchedBinPath = $null

        # a) Check if a known Windows service exists
        if ($dbServices.ContainsKey($app.id)) {
            foreach ($svcName in $dbServices[$app.id]) {
                if (Test-ServiceExists $svcName) {
                    # Verify the service executable actually exists to avoid false positives from stale service entries
                    $svc = Get-CimInstance Win32_Service -Filter "Name='$svcName'" -ErrorAction SilentlyContinue
                    if ($svc) {
                        $pName = if ($svc.PathName.StartsWith('"')) { $svc.PathName.Split('"')[1] } else { $svc.PathName }
                        if (Test-Path $pName -ErrorAction SilentlyContinue) {
                            $dbInstalled = $true
                            $matchedServiceName = $svcName
                            $matchedBinPath = $pName
                            $svcObj = Get-Service -Name $svcName -ErrorAction SilentlyContinue
                            if ($svcObj -and $svcObj.Status -eq 'Running') {
                                $version = 'Service running'
                                $isRunning = $true
                            } else {
                                $version = 'Service installed'
                            }
                            break
                        }
                    }
                }
            }
        }

        # b) Check if the port is open (authoritative for "Running")
        if ($dbPorts.ContainsKey($app.id)) {
            if (Test-LocalPort $dbPorts[$app.id]) {
                $dbInstalled = $true
                $isRunning = $true
                $version = "Listening on port $($dbPorts[$app.id])"
            }
        }

        # c) Check known installation directories/files (Dynamic check)
        if (-not $dbInstalled) {
            if ($dbPaths.ContainsKey($app.id)) {
                foreach ($p in $dbPaths[$app.id]) {
                    if (Test-Path $p) {
                        # If it's a direct file path (ends in .exe), it's authoritative
                        if ($p.EndsWith(".exe", [System.StringComparison]::OrdinalIgnoreCase)) {
                            $dbInstalled = $true
                            $version = 'Installed'
                            break
                        }
                        
                        # If it's a directory, check if it contains any relevant binary
                        if (Test-Path $p -PathType Container) {
                            $binFound = Get-ChildItem -Path $p -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                            if ($binFound) {
                                $dbInstalled = $true
                                $matchedBinPath = $binFound.FullName
                                $version = 'Installed'
                                break
                            }
                        }
                    }
                }
            }
        }

        # Override the earlier PATH/registry result with the authoritative db check
        $isInstalled = $dbInstalled
        if (-not $dbInstalled) { $version = 'Not detected' }
    }


    $results.Add([PSCustomObject]@{
        id = $app.id
        installed = [bool]$isInstalled
        isRunning = [bool]$isRunning
        version = [string]$version
        serviceName = [string]$matchedServiceName
        binPath = [string]$matchedBinPath
    })
}

$results | ConvertTo-Json
