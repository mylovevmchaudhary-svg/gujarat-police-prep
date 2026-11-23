Add-Type -AssemblyName System.Drawing

function Generate-AuthenticPoliceBadge([int]$size, [string]$outPath) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $cx = $size / 2.0
    $cy = $size / 2.0

    # 1. Background: Deep Royal Police Navy Blue #0D253F
    $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 13, 37, 63))
    $g.FillRectangle($bgBrush, $rect)

    # 2. Outer Concentric Shield / Circle with Golden Gradients
    $outerR = $size * 0.46
    $goldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 193, 7), [Math]::Max(2, $size * 0.035))
    $g.DrawEllipse($goldPen, $cx - $outerR, $cy - $outerR, $outerR * 2, $outerR * 2)

    $innerR = $size * 0.42
    $goldInnerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 212, 175, 55), [Math]::Max(1.5, $size * 0.015))
    $g.DrawEllipse($goldInnerPen, $cx - $innerR, $cy - $innerR, $innerR * 2, $innerR * 2)

    # 3. Draw Golden Laurel Wreath (Leaves framing the sides)
    $leafBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 255, 215, 0))
    $leafCount = 7
    for ($i = 0; $i -lt $leafCount; $i++) {
        $angleLeft = 110 + ($i * 12)
        $radL = $angleLeft * [Math]::PI / 180.0
        $lx = $cx + ($size * 0.38) * [Math]::Cos($radL)
        $ly = $cy + ($size * 0.38) * [Math]::Sin($radL)
        $leafSize = [Math]::Max(3, $size * 0.04)
        $g.FillEllipse($leafBrush, $lx - ($leafSize/2), $ly - ($leafSize/2), $leafSize * 1.5, $leafSize)

        $angleRight = 70 - ($i * 12)
        $radR = $angleRight * [Math]::PI / 180.0
        $rx = $cx + ($size * 0.38) * [Math]::Cos($radR)
        $ry = $cy + ($size * 0.38) * [Math]::Sin($radR)
        $g.FillEllipse($leafBrush, $rx - ($leafSize/2), $ry - ($leafSize/2), $leafSize * 1.5, $leafSize)
    }

    # 4. Central Police Starburst (8-Pointed Faceted Star)
    $starR_outer = $size * 0.28
    $starR_inner = $size * 0.14
    $pts = New-Object "System.Drawing.PointF[]" 16
    for ($i = 0; $i -lt 16; $i++) {
        $r = if ($i % 2 -eq 0) { $starR_outer } else { $starR_inner }
        $angle = ($i * 22.5 - 90) * [Math]::PI / 180.0
        $pts[$i] = New-Object System.Drawing.PointF(($cx + $r * [Math]::Cos($angle)), ($cy + $r * [Math]::Sin($angle)))
    }
    $starBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 215, 0))
    $g.FillPolygon($starBrush, $pts)

    # 5. Inner Core Disc
    $coreR = $size * 0.18
    $coreBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 13, 37, 63))
    $g.FillEllipse($coreBrush, $cx - $coreR, $cy - $coreR, $coreR * 2, $coreR * 2)
    $coreBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 193, 7), [Math]::Max(1.5, $size * 0.02))
    $g.DrawEllipse($coreBorderPen, $cx - $coreR, $cy - $coreR, $coreR * 2, $coreR * 2)

    # 6. Central Text & Typography
    $goldTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 193, 7))
    $whiteTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center

    # Top Arch: "GUJARAT POLICE"
    $topFontSize = [Math]::Max(6, $size * 0.075)
    $topFont = New-Object System.Drawing.Font("Arial", $topFontSize, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("GUJARAT POLICE", $topFont, $goldTextBrush, $cx, ($size * 0.17), $fmt)

    # Center: "PSI" (Prominent)
    $centerFontSize = [Math]::Max(10, $size * 0.15)
    $centerFont = New-Object System.Drawing.Font("Arial", $centerFontSize, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("PSI", $centerFont, $whiteTextBrush, $cx, ($cy * 0.98), $fmt)

    # Sub-center: "MOCK TEST"
    $subFontSize = [Math]::Max(5, $size * 0.055)
    $subFont = New-Object System.Drawing.Font("Arial", $subFontSize, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("MOCK TEST", $subFont, $goldTextBrush, $cx, ($cy * 1.18), $fmt)

    # 7. Bottom Ribbon Banner: "સેવા સુરક્ષા શાંતિ"
    $bannerW = $size * 0.72
    $bannerH = $size * 0.13
    $bannerY = $size * 0.76
    $bannerRect = New-Object System.Drawing.RectangleF(($cx - ($bannerW/2)), $bannerY, $bannerW, $bannerH)
    $bannerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 212, 175, 55))
    $g.FillRectangle($bannerBrush, $bannerRect)
    $bannerBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), [Math]::Max(1, $size * 0.01))
    $g.DrawRectangle($bannerBorderPen, ($cx - ($bannerW/2)), $bannerY, $bannerW, $bannerH)

    # Motto Text inside Ribbon
    $mottoFontSize = [Math]::Max(5.5, $size * 0.065)
    $mottoFont = New-Object System.Drawing.Font("Arial", $mottoFontSize, [System.Drawing.FontStyle]::Bold)
    $navyTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 13, 37, 63))
    $g.DrawString("SEVA SURAKSHA", $mottoFont, $navyTextBrush, $cx, ($bannerY + ($bannerH * 0.5)), $fmt)

    # Save
    $dir = [System.IO.Path]::GetDirectoryName($outPath)
    if (-not (Test-Path $dir)) { [System.IO.Directory]::CreateDirectory($dir) | Out-Null }
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$destDir = "C:\Users\Bluraj India\.gemini\antigravity\scratch\gujarat_police_prep\android_branding"
Generate-AuthenticPoliceBadge 48 "$destDir\mipmap-mdpi\ic_launcher.png"
Generate-AuthenticPoliceBadge 72 "$destDir\mipmap-hdpi\ic_launcher.png"
Generate-AuthenticPoliceBadge 96 "$destDir\mipmap-xhdpi\ic_launcher.png"
Generate-AuthenticPoliceBadge 144 "$destDir\mipmap-xxhdpi\ic_launcher.png"
Generate-AuthenticPoliceBadge 192 "$destDir\mipmap-xxxhdpi\ic_launcher.png"
Generate-AuthenticPoliceBadge 512 "$destDir\playstore_icon.png"

# Round icons
Generate-AuthenticPoliceBadge 48 "$destDir\mipmap-mdpi\ic_launcher_round.png"
Generate-AuthenticPoliceBadge 72 "$destDir\mipmap-hdpi\ic_launcher_round.png"
Generate-AuthenticPoliceBadge 96 "$destDir\mipmap-xhdpi\ic_launcher_round.png"
Generate-AuthenticPoliceBadge 144 "$destDir\mipmap-xxhdpi\ic_launcher_round.png"
Generate-AuthenticPoliceBadge 192 "$destDir\mipmap-xxxhdpi\ic_launcher_round.png"

Write-Output "Successfully generated authentic Gujarat Police badges in $destDir"
