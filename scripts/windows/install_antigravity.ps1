# Install Antigravity (Template)
# Replace $InstallerUrl with the actual download URL for Antigravity

$InstallerUrl = "https://example.com/downloads/antigravity-setup.exe"
$InstallerPath = "$env:TEMP\antigravity-setup.exe"

Write-Host "Downloading Antigravity installer..."
Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath

Write-Host "Running Antigravity installer silently..."
# Often standard Windows installers accept /S, /silent, or /quiet arguments. Adjust as necessary.
Start-Process -FilePath $InstallerPath -ArgumentList "/S" -Wait -NoNewWindow

Write-Host "Cleaning up..."
Remove-Item -Path $InstallerPath -Force

Write-Host "Antigravity installation complete."
