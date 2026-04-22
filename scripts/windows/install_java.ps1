# Install OpenJDK 21 using Winget
Write-Host "Installing Microsoft OpenJDK 21..."
winget install -e --id Microsoft.OpenJDK.21 --accept-source-agreements --accept-package-agreements --silent

# Find Java Home
$jdkPath = "C:\Program Files\Microsoft\jdk-21" # Default path for Microsoft OpenJDK 21
if (!(Test-Path $jdkPath)) {
    # Fallback search if version differs slightly
    $jdkPath = Get-ChildItem "C:\Program Files\Microsoft\jdk-*" | Select-Object -First 1 -ExpandProperty FullName
}

if ($jdkPath) {
    Write-Host "Setting JAVA_HOME to $jdkPath"
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, "User")
    
    Write-Host "Updating PATH to include Java bin..."
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $javaBin = "$jdkPath\bin"
    if ($currentPath -notlike "*$javaBin*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$javaBin", "User")
    }
}

Write-Host "Java installation and environment setup complete."
