# Install Postman using Winget (Windows Package Manager)
Write-Host "Installing Postman..."
winget install -e --id Postman.Postman --accept-source-agreements --accept-package-agreements --silent
Write-Host "Postman installation complete."
