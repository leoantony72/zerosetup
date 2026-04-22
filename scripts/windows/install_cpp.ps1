# Install MSYS2 for C/C++ development
Write-Host "Installing MSYS2 (MinGW)..."
winget install -e --id msys2.msys2 --accept-source-agreements --accept-package-agreements --silent

# Configure PATH for MinGW-w64
$msysBin = "C:\msys64\mingw64\bin"
if (!(Test-Path $msysBin)) {
    # If not fully initialized, we can't do much automatically yet, 
    # but we set the expected path for next reboot.
}

Write-Host "Updating PATH to include MinGW bin..."
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$msysBin*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$msysBin", "User")
}

Write-Host "C/C++ environment (MSYS2) installation complete."
Write-Host "Note: You may need to run 'pacman -S mingw-w64-x86_64-toolchain' inside MSYS2 terminal."
