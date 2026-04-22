# Install 1Password using Winget
Write-Host "Installing 1Password..."
winget install -e --id AgileBits.1Password --accept-source-agreements --accept-package-agreements --silent
Write-Host "1Password installation complete."
