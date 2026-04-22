# Detect installed applications by checking PATH and common Registry keys
param (
    [string]$appsJson # JSON string representing the apps to check
)

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

    $results.Add([PSCustomObject]@{
        id = $app.id
        installed = [bool]$isInstalled
        version = [string]$version
    })
}

$results | ConvertTo-Json
