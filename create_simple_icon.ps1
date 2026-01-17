# Create a simple compatible icon for Windows
# This script creates a basic icon that works with the Windows resource compiler

# Define paths
$iconPath = "windows\runner\resources\app_icon.ico"

# Create directory if it doesn't exist
$iconDir = Split-Path -Parent $iconPath
if (-not (Test-Path $iconDir)) {
    New-Item -ItemType Directory -Path $iconDir -Force | Out-Null
}

# Create a simple 32x32 icon using .NET
Add-Type -AssemblyName System.Drawing

# Create a bitmap
$bitmap = New-Object System.Drawing.Bitmap(32, 32)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

try {
    # Clear with white background
    $graphics.Clear([System.Drawing.Color]::White)
    
    # Draw a simple icon (red circle with white center)
    $graphics.FillEllipse([System.Drawing.Brushes]::Red, 4, 4, 24, 24)
    $graphics.FillEllipse([System.Drawing.Brushes]::White, 10, 10, 12, 12)
    
    # Save as ICO
    $stream = New-Object System.IO.FileStream($iconPath, [System.IO.FileMode]::Create)
    try {
        $icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
        $icon.Save($stream)
        $icon.Dispose()
        Write-Host "Created simple icon at: $iconPath"
    }
    finally {
        $stream.Dispose()
    }
}
finally {
    $graphics.Dispose()
    $bitmap.Dispose()
}

# Verify the icon was created
if (Test-Path $iconPath) {
    $iconSize = (Get-Item $iconPath).Length
    Write-Host "Icon file size: $iconSize bytes"
    Write-Host "Icon creation completed successfully!"
} else {
    Write-Host "Failed to create icon file!"
    exit 1
}