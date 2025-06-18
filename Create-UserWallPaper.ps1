# Version info
$version = "v25.6.18.1"
# CONFIGURATION
$OutputImage = "$env:USERPROFILE\Pictures\user_background.png"
$bgColor = [System.Drawing.Color]::FromArgb(0x0A, 0x22, 0x32)
$ImageWidth = 2560
$ImageHeight = 1440
$FontName = "Arial"
$FontSizeHostname = 68
$FontSizeUsername = 35
$PngLogoPath = "C:\lab-background\Logo.png"
$MaxLogoHeight = 150
# CONFIGURATION

# Load required .NET drawing classes
Add-Type -AssemblyName System.Drawing

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
$hostname = "$env:COMPUTERNAME"
# Domain Username
$domain = $env:USERDOMAIN
$username = $env:USERNAME
$domainUser = if ($domain) { "$domain\$username" } else { $username }

#$username = "Username: $env:USERNAME"

# Fix for ambiguous font constructor
$fontStyleBold = [System.Drawing.FontStyle]::Bold
$fontStyleRegular = [System.Drawing.FontStyle]::Regular
$fontHost = New-Object System.Drawing.Font($FontName, $FontSizeHostname, $fontStyleBold)
$fontUser = New-Object System.Drawing.Font($FontName, $FontSizeUsername, $fontStyleRegular)
$brush = [System.Drawing.Brushes]::White

# Draw hostname centered on screen
$centerX = $ImageWidth / 2
$hostSize = $graphics.MeasureString($hostname, $fontHost)
$hostY = ($ImageHeight / 2) - 40
$graphics.DrawString($hostname, $fontHost, $brush, $centerX - $hostSize.Width / 2, $hostY)

# Draw username below hostname
$userSize = $graphics.MeasureString($domainUser, $fontUser)
$userY = $hostY + $hostSize.Height + 10
$graphics.DrawString($domainUser, $fontUser, $brush, $centerX - $userSize.Width / 2, $userY)

# Version info
$fontSizeVersion = 24
$fontVersion = New-Object System.Drawing.Font($FontName, $fontSizeVersion, $fontStyleRegular)
$versionSize = $graphics.MeasureString($version, $fontVersion)
$versionY = $hostY + $hostSize.Height + 5
$graphics.DrawString($version, $fontVersion, $brush, $centerX - $versionSize.Width / 2, $versionY)


# Save to file
$bitmap.Save($OutputImage, [System.Drawing.Imaging.ImageFormat]::Png)

# Clean up
$graphics.Dispose()
$bitmap.Dispose()
$logo.Dispose()
$logoOriginal.Dispose()

Write-Output "✅ Background image created: $OutputImage"


Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $OutputImage

# Tell Windows to refresh the wallpaper
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters



