# Install R using Winget
Write-Host "Installing R..."
winget install -e --id RProject.R --accept-source-agreements --accept-package-agreements --silent

# R path usually looks like C:\Program Files\R\R-x.x.x\bin\x64
$rInstallBase = "C:\Program Files\R"
$rBin = Get-ChildItem -Path "$rInstallBase\R-*\bin\x64" | Select-Object -First 1 -ExpandProperty FullName

if ($rBin) {
    Write-Host "Updating PATH to include R bin..."
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$rBin*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$rBin", "User")
    }
}

Write-Host "R installation and environment setup complete."
