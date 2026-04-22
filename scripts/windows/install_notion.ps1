# Install Notion using Winget
Write-Host "Installing Notion..."
winget install -e --id Notion.Notion --accept-source-agreements --accept-package-agreements --silent
Write-Host "Notion installation complete."
