# Install Zoom using Winget
Write-Host "Installing Zoom..."
winget install -e --id Zoom.Zoom --accept-source-agreements --accept-package-agreements --silent
Write-Host "Zoom installation complete."
