# Version info
$ScriptVersion = "v25.6.20.2"
$time = (Get-Date).ToString("hh:mm tt")

# CONFIGURATION
$InfoPath = "C:\lab-background\info.txt"
$OutputImage = "C:\Windows\Web\Screen\lock_background.png"
$ImageWidth = 2560
$ImageHeight = 1440
$FontName = "Arial"
$FontSizeHostname = 68
$FontSizeUsername = 35
$PngLogoPath = "C:\lab-background\Logo.png"
$MaxLogoHeight = 150
# CONFIGURATION

# Check if the info file exists
if (Test-Path $InfoPath) {
    # Read the string from the file
    $version = Get-Content $InfoPath -Raw
} else {
    # Use hardcoded text
    $version = "$ScriptVersion - $time"
}

# Load required .NET drawing classes
Add-Type -AssemblyName System.Drawing
$bgColor = [System.Drawing.Color]::FromArgb(0x0A, 0x22, 0x32)

# Create blank bitmap and graphics object
$bitmap = New-Object System.Drawing.Bitmap $ImageWidth, $ImageHeight
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
#$graphics.Clear([System.Drawing.Color]::$BackgroundColor)
$bgColor = [System.Drawing.Color]::FromArgb(0x0A, 0x22, 0x32)
$graphics.Clear($bgColor)


# Load and resize the logo
if (-Not (Test-Path $PngLogoPath)) {
    Write-Error "Logo PNG not found at $PngLogoPath"
    exit
}
$logoOriginal = [System.Drawing.Image]::FromFile($PngLogoPath)

# Resize while preserving aspect ratio
$scaleFactor = $MaxLogoHeight / $logoOriginal.Height
$newWidth = [int]($logoOriginal.Width * $scaleFactor)
$newHeight = [int]($logoOriginal.Height * $scaleFactor)
$logo = New-Object System.Drawing.Bitmap $logoOriginal, $newWidth, $newHeight

# # Center logo at the top
# $logoX = [int](($ImageWidth - $newWidth) / 2)

# Top-right corner, with 20px margin
$logoX = $ImageWidth - $newWidth - 120

$logoY = 120
$graphics.DrawImage($logo, $logoX, $logoY, $newWidth, $newHeight)

# System information
$hostname = $env:COMPUTERNAME

# Fix for ambiguous font constructor
$fontStyleBold = [System.Drawing.FontStyle]::Bold
$fontStyleRegular = [System.Drawing.FontStyle]::Regular
$fontHost = New-Object System.Drawing.Font($FontName, $FontSizeHostname, $fontStyleBold)
$fontUser = New-Object System.Drawing.Font($FontName, $FontSizeUsername, $fontStyleRegular)
$brush = [System.Drawing.Brushes]::White

# Draw hostname centered on screen
# $centerX = $ImageWidth / 2
# $hostSize = $graphics.MeasureString($hostname, $fontHost)
# $hostY = ($ImageHeight / 2) - 40
# $graphics.DrawString($hostname, $fontHost, $brush, $centerX - $hostSize.Width / 2, $hostY)

# Draw hostanme on top left
# Draw hostname in top-left corner with margin
$marginX = 200
$marginY = 200
$graphics.DrawString($hostname, $fontHost, $brush, $marginX, $marginY)

# Version info in bottom-right corner
$fontSizeVersion = 24
$fontVersion = New-Object System.Drawing.Font($FontName, $fontSizeVersion, $fontStyleRegular)
$versionSize = $graphics.MeasureString($version, $fontVersion)
# Padding from bottom and right edge
$padding = 220
$versionX = $ImageWidth - $versionSize.Width - $padding
$versionY = $ImageHeight - $versionSize.Height - $padding

$graphics.DrawString($version, $fontVersion, $brush, $versionX, $versionY)


# Save to file
$bitmap.Save($OutputImage, [System.Drawing.Imaging.ImageFormat]::Png)

# Clean up
$graphics.Dispose()
$bitmap.Dispose()
$logo.Dispose()
$logoOriginal.Dispose()

Write-Output "✅ Background image created: $OutputImage"

$lockScreenImagePath = $OutputImage
# Registry path for lock screen image
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "LockScreenImage" -Value $lockScreenImagePath

