# Install .NET SDK using Winget
Write-Host "Installing .NET SDK 8..."
winget install -e --id Microsoft.DotNet.SDK.8 --accept-source-agreements --accept-package-agreements --silent

# .NET SDK usually sets PATH automatically, but let's ensure global tools are included
$dotnetToolsPath = "$HOME\.dotnet\tools"
if (!(Test-Path $dotnetToolsPath)) {
    New-Item -ItemType Directory -Path $dotnetToolsPath -Force
}

Write-Host "Updating PATH to include .NET global tools..."
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$dotnetToolsPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$dotnetToolsPath", "User")
}

Write-Host ".NET SDK installation and environment setup complete."
