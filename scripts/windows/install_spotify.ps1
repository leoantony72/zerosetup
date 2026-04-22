# Install Spotify using Winget
Write-Host "Installing Spotify..."
winget install -e --id Spotify.Spotify --accept-source-agreements --accept-package-agreements --silent
Write-Host "Spotify installation complete."
