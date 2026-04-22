# Install Python using Winget
Write-Host "Installing Python..."
winget install -e --id Python.Python.3 --accept-source-agreements --accept-package-agreements --silent

# Python installer typically handles PATH, but let's ensure Scripts directory is included for pip packages
$pythonPath = & python -c "import sys; import os; print(os.path.dirname(sys.executable))"
$scriptsPath = "$pythonPath\Scripts"

if (Test-Path $scriptsPath) {
    Write-Host "Updating PATH to include Python Scripts..."
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$scriptsPath*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$scriptsPath", "User")
    }
}

Write-Host "Python installation and environment setup complete."
