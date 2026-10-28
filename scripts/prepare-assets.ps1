$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    New-Item -ItemType Directory -Force docs/assets/images,docs/assets/brand | Out-Null
    function Resize-Asset($Source, $Target, $Width, $Format) {
        $original = [Drawing.Image]::FromFile((Join-Path $PWD $Source))
        $height = [int][Math]::Round($original.Height * $Width / $original.Width)
        $copy = New-Object Drawing.Bitmap $Width, $height
        $graphics = [Drawing.Graphics]::FromImage($copy)
        $graphics.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.DrawImage($original, 0, 0, $Width, $height)
        if ($Format -eq 'jpeg') {
            $encoder = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
            $parameters = New-Object Drawing.Imaging.EncoderParameters 1
            $parameters.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality), ([long]90)
            $copy.Save((Join-Path $PWD $Target), $encoder, $parameters)
            $parameters.Dispose()
        } else { $copy.Save((Join-Path $PWD $Target), [Drawing.Imaging.ImageFormat]::Png) }
        $graphics.Dispose(); $copy.Dispose(); $original.Dispose()
    }
    Resize-Asset 'assets/kauai-plantation-home-original.png' 'docs/assets/images/kauai-home-1536.jpg' 1536 'jpeg'
    Resize-Asset 'assets/kauai-plantation-home-original.png' 'docs/assets/images/kauai-home-960.jpg' 960 'jpeg'
    Resize-Asset 'images/Logo/Yandow Walker.png' 'docs/assets/brand/yandow-walker-color.png' 408 'png'
    Resize-Asset 'images/Logo/yandow walker logo5 - Copy.png' 'docs/assets/brand/yandow-walker-cream.png' 408 'png'
    Resize-Asset 'images/Logo/Yandow Walker.png' 'docs/assets/brand/favicon.png' 96 'png'
} finally { Pop-Location }
