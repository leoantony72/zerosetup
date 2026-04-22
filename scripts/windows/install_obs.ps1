# Install OBS Studio using Winget
Write-Host "Installing OBS Studio..."
winget install -e --id OBSProject.OBSStudio --accept-source-agreements --accept-package-agreements --silent
Write-Host "OBS Studio installation complete."
