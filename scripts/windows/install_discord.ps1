# Install Discord using Winget
Write-Host "Installing Discord..."
winget install -e --id Discord.Discord --accept-source-agreements --accept-package-agreements --silent
Write-Host "Discord installation complete."
