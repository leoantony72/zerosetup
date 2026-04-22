# Install Go (Golang) using Winget
Write-Host "Installing Go (Golang)..."
winget install -e --id GoLang.Go --accept-source-agreements --accept-package-agreements --silent

# Configure Environment Variables
$goPath = "$HOME\go"
if (!(Test-Path $goPath)) {
    New-Item -ItemType Directory -Path $goPath -Force
}

Write-Host "Setting GOPATH..."
[System.Environment]::SetEnvironmentVariable("GOPATH", $goPath, "User")

# Update PATH to include Go bin and GOPATH bin
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$goInstallBin = "C:\Program Files\Go\bin"
$goUserBin = "$goPath\bin"

$newPathParts = @()
foreach ($part in $currentPath.Split(';')) {
    if ($part -and $part -ne $goInstallBin -and $part -ne $goUserBin) {
        $newPathParts += $part
    }
}
$newPathParts += $goInstallBin
$newPathParts += $goUserBin

$finalPath = $newPathParts -join ';'
[System.Environment]::SetEnvironmentVariable("Path", $finalPath, "User")

Write-Host "Go installation and environment setup complete."
Write-Host "Please restart your terminal to apply changes."
