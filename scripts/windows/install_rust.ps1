# Install Rust using Winget
Write-Host "Installing Rust (rustup)..."
winget install -e --id Rustlang.Rustup --accept-source-agreements --accept-package-agreements --silent

# Ensure .cargo/bin is in PATH
$cargoBin = "$HOME\.cargo\bin"
if (!(Test-Path $cargoBin)) {
    # If not found yet, maybe installer hasn't finished directory setup. 
    # Force a refresh or wait? Winget usually handles this.
}

Write-Host "Updating PATH to include Cargo bin..."
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$cargoBin*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$cargoBin", "User")
}

Write-Host "Rust installation and environment setup complete."
