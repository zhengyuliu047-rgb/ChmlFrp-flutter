# Create a Flutter-style icon with correct ICO format for Windows
# This script uses .NET to create a proper ICO file

# Define paths
$iconDir = "windows\runner\resources"
$flutterIconIco = "$iconDir\app_icon.ico"

# Create directory if it doesn't exist
if (-not (Test-Path $iconDir)) {
    New-Item -ItemType Directory -Path $iconDir -Force | Out-Null
}

# Create a proper Flutter icon using .NET with multiple sizes
Add-Type -AssemblyName System.Drawing

# Create icon with multiple sizes (16x16, 32x32, 48x48, 64x64, 128x128, 256x256)
$sizes = @(16, 32, 48, 64, 128, 256)
$bitmaps = @()

foreach ($size in $sizes) {
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Clear with transparent background
    $graphics.Clear([System.Drawing.Color]::Transparent)
    
    # Set high quality rendering
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Flutter colors
    $blue = [System.Drawing.Color]::FromArgb(59, 130, 246)
    $cyan = [System.Drawing.Color]::FromArgb(6, 182, 212)
    $green = [System.Drawing.Color]::FromArgb(16, 185, 129)
    $yellow = [System.Drawing.Color]::FromArgb(245, 158, 11)
    $white = [System.Drawing.Color]::White
    
    # Calculate proportions based on size
    $margin = $size * 0.125
    $wingSize = $size * 0.5
    $centerSize = $size * 0.25
    $centerX = ($size - $centerSize) / 2
    $centerY = ($size - $centerSize) / 2
    
    # Draw main circle (gradient)
    $gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point($size, $size)),
        $blue,
        $cyan
    )
    $graphics.FillEllipse($gradientBrush, $margin, $margin, $size - ($margin * 2), $size - ($margin * 2))
    $gradientBrush.Dispose()
    
    # Draw left wing (green)
    $greenBrush = New-Object System.Drawing.SolidBrush($green)
    $graphics.FillEllipse($greenBrush, $margin * 0.5, $size * 0.25, $wingSize, $wingSize)
    $greenBrush.Dispose()
    
    # Draw right wing (yellow)
    $yellowBrush = New-Object System.Drawing.SolidBrush($yellow)
    $graphics.FillEllipse($yellowBrush, $size * 0.4375, $size * 0.25, $wingSize, $wingSize)
    $yellowBrush.Dispose()
    
    # Draw center circle (white)
    $whiteBrush = New-Object System.Drawing.SolidBrush($white)
    $graphics.FillEllipse($whiteBrush, $centerX, $centerY, $centerSize, $centerSize)
    $whiteBrush.Dispose()
    
    # Add to bitmaps collection
    $bitmaps += $bitmap
    $graphics.Dispose()
}

# Create ICO file with multiple sizes
# Note: .NET's built-in ICO saving doesn't support multiple sizes properly
# So we'll use a different approach - create a simple 256x256 icon that works
$finalBitmap = New-Object System.Drawing.Bitmap(256, 256)
$finalGraphics = [System.Drawing.Graphics]::FromImage($finalBitmap)

# Recreate the icon at 256x256
$finalGraphics.Clear([System.Drawing.Color]::Transparent)
$finalGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

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
$finalGraphics.FillEllipse($gradientBrush, 32, 32, 192, 192)
$gradientBrush.Dispose()

# Draw left wing (green)
$greenBrush = New-Object System.Drawing.SolidBrush($green)
$finalGraphics.FillEllipse($greenBrush, 16, 64, 128, 128)
$greenBrush.Dispose()

# Draw right wing (yellow)
$yellowBrush = New-Object System.Drawing.SolidBrush($yellow)
$finalGraphics.FillEllipse($yellowBrush, 112, 64, 128, 128)
$yellowBrush.Dispose()

# Draw center circle (white)
$whiteBrush = New-Object System.Drawing.SolidBrush($white)
$finalGraphics.FillEllipse($whiteBrush, 96, 96, 64, 64)
$whiteBrush.Dispose()

# Save as ICO using a different method that produces compatible format
# We'll use a simple approach that works with the resource compiler
$finalBitmap.Save($flutterIconIco, [System.Drawing.Imaging.ImageFormat]::Icon)
Write-Host "Created compatible Flutter icon: $flutterIconIco"

# Clean up
$finalGraphics.Dispose()
$finalBitmap.Dispose()
foreach ($bitmap in $bitmaps) {
    $bitmap.Dispose()
}

Write-Host "Flutter icon setup completed successfully!"