# Create a simple Flutter-style icon using PowerShell
# This script will create a basic Flutter icon and convert it to ICO

# Define icon paths
$flutterIconPng = "flutter_icon.png"
$flutterIconIco = "flutter_icon.ico"
$windowsIconPath = "windows\runner\resources\app_icon.ico"

# Create a Flutter-style icon using .NET drawing
Add-Type -AssemblyName System.Drawing

# Create bitmap
$bitmap = New-Object System.Drawing.Bitmap(256, 256)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Clear with transparent background
$graphics.Clear([System.Drawing.Color]::Transparent)

# Set smoothing mode
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Flutter colors
$blue = [System.Drawing.Color]::FromArgb(59, 130, 246)
$cyan = [System.Drawing.Color]::FromArgb(6, 182, 212)
$green = [System.Drawing.Color]::FromArgb(16, 185, 129)
$yellow = [System.Drawing.Color]::FromArgb(245, 158, 11)
$white = [System.Drawing.Color]::White

# Draw main circle (gradient)
$gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point(256, 256)),
    $blue,
    $cyan
)
$graphics.FillEllipse($gradientBrush, 32, 32, 192, 192)
$gradientBrush.Dispose()

# Draw left wing (green)
$greenBrush = New-Object System.Drawing.SolidBrush($green)
$graphics.FillEllipse($greenBrush, 16, 64, 128, 128)
$greenBrush.Dispose()

# Draw right wing (yellow)
$yellowBrush = New-Object System.Drawing.SolidBrush($yellow)
$graphics.FillEllipse($yellowBrush, 112, 64, 128, 128)
$yellowBrush.Dispose()

# Draw center circle (white)
$whiteBrush = New-Object System.Drawing.SolidBrush($white)
$graphics.FillEllipse($whiteBrush, 96, 96, 64, 64)
$whiteBrush.Dispose()

# Save as PNG
$bitmap.Save($flutterIconPng, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Created Flutter icon: $flutterIconPng"

# Convert to ICO
$bitmap.Save($flutterIconIco, [System.Drawing.Imaging.ImageFormat]::Icon)
Write-Host "Converted to ICO: $flutterIconIco"

# Copy to Windows resources
Copy-Item -Path $flutterIconIco -Destination $windowsIconPath -Force
Write-Host "Copied icon to Windows resources: $windowsIconPath"

# Clean up
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Flutter icon setup completed successfully!"