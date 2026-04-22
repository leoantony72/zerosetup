# Install Slack using Winget
Write-Host "Installing Slack..."
winget install -e --id SlackTechnologies.Slack --accept-source-agreements --accept-package-agreements --silent
Write-Host "Slack installation complete."
