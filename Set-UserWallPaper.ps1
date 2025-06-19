# Version info
$time = (Get-Date).ToString("hh:mm tt")
$version = "v25.6.19.3 - $time"
# CONFIGURATION
$OutputImage = "$env:USERPROFILE\Pictures\user_background.png"
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
$domainname = (Get-CimInstance Win32_ComputerSystem).Domain
$hostname = "$env:COMPUTERNAME" + "." + $domainname
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


# Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $OutputImage

# # Tell Windows to refresh the wallpaper
# RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Set background to fit
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 6

# Set background colour to #0A2232
Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "10 34 50"

Path to your wallpaper image
$wallpaperPath = $OutputImage

# Add type to use SystemParametersInfo function
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Constants
$SPI_SETDESKWALLPAPER = 20
$SPIF_UPDATEINIFILE = 1
$SPIF_SENDWININICHANGE = 2

# Set the wallpaper
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaperPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDWININICHANGE)

RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters


# # Set wallpaper image path
# Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $OutputImage

# # Set wallpaper style to Fit
# Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 6
# Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 0

# # Prevent background color conflict
# Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "10 34 50"

# # Disable slideshow or dynamic backgrounds
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name "SlideshowEnabled" -Value 0 -Type DWord

# # Apply changes immediately
# RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters