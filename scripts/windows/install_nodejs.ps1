# Install Node.js using Winget
Write-Host "Installing Node.js (LTS)..."
winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent

# Configure npm global path
$npmGlobalPath = "$AppData\npm"
if (!(Test-Path $npmGlobalPath)) {
    New-Item -ItemType Directory -Path $npmGlobalPath -Force
}

Write-Host "Updating PATH to include npm global bin..."
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$npmGlobalPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$npmGlobalPath", "User")
}

Write-Host "Node.js installation and environment setup complete."
