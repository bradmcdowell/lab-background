# Version info
$ScriptVersion = "v25.7.03.1"
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
$bgColor = [System.Drawing.Color]::FromArgb(2, 107, 149)

# Create blank bitmap and graphics object
$bitmap = New-Object System.Drawing.Bitmap $ImageWidth, $ImageHeight
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
#$graphics.Clear([System.Drawing.Color]::$BackgroundColor)
$bgColor = [System.Drawing.Color]::FromArgb(2, 107, 149)
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

# This part of the scipt is to detect Windows 11 computers and apply the background
# Get OS version
$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "Detected OS: $($osInfo.Caption) ($($osInfo.Version), Build $($osInfo.BuildNumber))"

# Reg Path
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

# Check if OS build is greater than 22000
$isWindows11 = [int]$osInfo.BuildNumber -ge 22000

if ($isWindows11) {
    Write-Host "✔ This is Windows 11."
    # Create the registry key if it doesn't exist
    If (-not (Test-Path $regPath)) {
		
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set the required values
    Set-ItemProperty -Path $regPath -Name "LockScreenImagePath"   -Value $lockScreenImagePath -Type String
    Set-ItemProperty -Path $regPath -Name "LockScreenImageUrl"    -Value $lockScreenImagePath -Type String
    Set-ItemProperty -Path $regPath -Name "LockScreenImageStatus" -Value 1                    -Type DWord

    Write-Host "✔ Lock screen image set to $lockScreenImagePath on Windows 11."
} else {
    Write-Host "❌ This is not Windows 11 ending the script."
}
