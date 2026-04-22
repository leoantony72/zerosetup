# Install VLC Media Player using Winget
Write-Host "Installing VLC..."
winget install -e --id VideoLAN.VLC --accept-source-agreements --accept-package-agreements --silent
Write-Host "VLC installation complete."
