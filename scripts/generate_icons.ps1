Add-Type -AssemblyName System.Drawing

function Generate-PoliceIcon([int]$size, [string]$outPath) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # Background color: Deep Navy Blue #0D253F
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 13, 37, 63))
    $g.FillRectangle($bgBrush, 0, 0, $size, $size)

    # Outer Gold Circle / Ring
    $goldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 193, 7), [Math]::Max(2, $size * 0.04))
    $padding = $size * 0.06
    $g.DrawEllipse($goldPen, $padding, $padding, $size - 2 * $padding, $size - 2 * $padding)

    # Inner Gold Circle
    $innerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 255, 215, 0), [Math]::Max(1, $size * 0.015))
    $innerPadding = $size * 0.10
    $g.DrawEllipse($innerPen, $innerPadding, $innerPadding, $size - 2 * $innerPadding, $size - 2 * $innerPadding)

    # Star Insignia / Shield Center
    $goldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 193, 7))
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

    # Draw Text "POLICE" on top
    $policeFontSize = [Math]::Max(8, $size * 0.11)
    $policeFont = New-Object System.Drawing.Font("Arial", $policeFontSize, [System.Drawing.FontStyle]::Bold)
    $policeFormat = New-Object System.Drawing.StringFormat
    $policeFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $policeFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString("POLICE", $policeFont, $goldBrush, ($size / 2), ($size * 0.28), $policeFormat)

    # Draw Big Text "PSI" in center
    $psiFontSize = [Math]::Max(12, $size * 0.24)
    $psiFont = New-Object System.Drawing.Font("Arial", $psiFontSize, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("PSI", $psiFont, $whiteBrush, ($size / 2), ($size * 0.52), $policeFormat)

    # Draw Text "MOCK TEST" below
    $subFontSize = [Math]::Max(6, $size * 0.08)
    $subFont = New-Object System.Drawing.Font("Arial", $subFontSize, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("MOCK TEST", $subFont, $goldBrush, ($size / 2), ($size * 0.74), $policeFormat)

    # Save
    $dir = [System.IO.Path]::GetDirectoryName($outPath)
    if (-not (Test-Path $dir)) { [System.IO.Directory]::CreateDirectory($dir) | Out-Null }
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$destDir = "C:\Users\Bluraj India\.gemini\antigravity\scratch\gujarat_police_prep\android_branding"
Generate-PoliceIcon 48 "$destDir\mipmap-mdpi\ic_launcher.png"
Generate-PoliceIcon 72 "$destDir\mipmap-hdpi\ic_launcher.png"
Generate-PoliceIcon 96 "$destDir\mipmap-xhdpi\ic_launcher.png"
Generate-PoliceIcon 144 "$destDir\mipmap-xxhdpi\ic_launcher.png"
Generate-PoliceIcon 192 "$destDir\mipmap-xxxhdpi\ic_launcher.png"
Generate-PoliceIcon 512 "$destDir\playstore_icon.png"

# Also round icons for modern Android
Generate-PoliceIcon 48 "$destDir\mipmap-mdpi\ic_launcher_round.png"
Generate-PoliceIcon 72 "$destDir\mipmap-hdpi\ic_launcher_round.png"
Generate-PoliceIcon 96 "$destDir\mipmap-xhdpi\ic_launcher_round.png"
Generate-PoliceIcon 144 "$destDir\mipmap-xxhdpi\ic_launcher_round.png"
Generate-PoliceIcon 192 "$destDir\mipmap-xxxhdpi\ic_launcher_round.png"

Write-Output "Successfully generated branded icons in $destDir"
