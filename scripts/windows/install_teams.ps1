# Install Microsoft Teams using Winget
Write-Host "Installing Microsoft Teams..."
winget install -e --id Microsoft.Teams --accept-source-agreements --accept-package-agreements --silent
Write-Host "Microsoft Teams installation complete."
