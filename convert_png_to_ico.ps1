# PowerShell script to convert PNG to Windows compatible ICO format
Add-Type -AssemblyName System.Drawing

# Path to the input PNG file
$pngPath = "assets\images\2.png"

# Path to the output ICO file
$icoPath = "windows\runner\resources\app_icon.ico"

# Check if the PNG file exists
if (-not (Test-Path $pngPath)) {
    Write-Host "Error: PNG file not found at $pngPath"
    exit 1
}

try {
    # Load the PNG image
    $image = [System.Drawing.Image]::FromFile($pngPath)
    
    # Create a bitmap from the image
    $bitmap = New-Object System.Drawing.Bitmap($image)
    
    # Save as ICO using a different approach
    # First save as BMP, then convert to ICO using .NET methods
    $bmpPath = "temp.bmp"
    $bitmap.Save($bmpPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    
    # Load the BMP and create an ICO
    $bmpImage = [System.Drawing.Bitmap]::FromFile($bmpPath)
    
    # Create a new icon from the bitmap
    $iconHandle = $bmpImage.GetHicon()
    $icon = [System.Drawing.Icon]::FromHandle($iconHandle)
    
    # Save the ICO to file
    $iconStream = New-Object System.IO.FileStream($icoPath, [System.IO.FileMode]::Create)
    $icon.Save($iconStream)
    $iconStream.Close()
    
    # Clean up
    $image.Dispose()
    $bitmap.Dispose()
    $bmpImage.Dispose()
    $icon.Dispose()
    
    # Remove temporary BMP file
    if (Test-Path $bmpPath) {
        Remove-Item $bmpPath -Force
    }
    
    Write-Host "Successfully converted $pngPath to $icoPath"
    Write-Host "File size: $((Get-Item $icoPath).Length) bytes"
}
catch {
    Write-Host "Error converting image: $($_.Exception.Message)"
    exit 1
}