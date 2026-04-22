# Install Google Chrome using Winget
Write-Host "Installing Google Chrome..."
winget install -e --id Google.Chrome --accept-source-agreements --accept-package-agreements --silent
Write-Host "Google Chrome installation complete."
