# Install Visual Studio Code using Winget
Write-Host "Installing Visual Studio Code..."
winget install -e --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --silent
Write-Host "Visual Studio Code installation complete."
