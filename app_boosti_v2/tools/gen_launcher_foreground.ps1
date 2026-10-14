Add-Type -AssemblyName System.Drawing

# Extrae el logo del `app_icon.png` nuevo (fondo azul solido) dejando el
# glifo sobre fondo transparente, y lo reescala al safe zone de los
# adaptive icons de Android.
#
# Por que hace falta: `pubspec.yaml` declara
#   adaptive_icon_background: "#10B981"
#   adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
# En Android 8+ el launcher dibuja background + foreground recortados a
# una mascara. El foreground era del 24/09 (logo viejo) y con el fondo
# verde tampoco coordinaba con el azul del logo nuevo.
#
# Adaptive icons: lienzo 108x108, zona segura 66x66 (~61%). Por eso el
# logo se escala al 62% y se centra.

$ErrorActionPreference = 'Stop'
# El script vive en `tools/`, así que el proyecto es el padre.
$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root 'assets\icon\app_icon.png'
$dst  = Join-Path $root 'assets\icon\app_icon_foreground.png'
$tmp  = Join-Path $root 'assets\icon\_logo_isolado.png'

# Fondo del PNG nuevo: RGB(47,129,211)
$bgR = 47; $bgG = 129; $bgB = 211
$TOL = 70          # tolerancia euclidiana para considerar "fondo"
$SAFE = 0.62       # fraccion del lienzo que ocupa el logo

$srcImg = [System.Drawing.Bitmap]::FromFile($src)
$w = $srcImg.Width; $h = $srcImg.Height

# ── 1. Aislar el glifo ──
$iso = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$minX = $w; $minY = $h; $maxX = -1; $maxY = -1

for ($y = 0; $y -lt $h; $y++) {
  for ($x = 0; $x -lt $w; $x++) {
    $c = $srcImg.GetPixel($x, $y)
    $d = [Math]::Sqrt([Math]::Pow($c.R - $bgR, 2) + [Math]::Pow($c.G - $bgG, 2) + [Math]::Pow($c.B - $bgB, 2))
    if ($d -le $TOL) {
      $iso.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $c.R, $c.G, $c.B))
    } else {
      $iso.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $c.R, $c.G, $c.B))
      if ($x -lt $minX) { $minX = $x }
      if ($y -lt $minY) { $minY = $y }
      if ($x -gt $maxX) { $maxX = $x }
      if ($y -gt $maxY) { $maxY = $y }
    }
  }
}

if ($maxX -lt 0) { throw "No se encontro ningun pixel distinto del fondo. Revisar el PNG." }

$bw = $maxX - $minX + 1
$bh = $maxY - $minY + 1
Write-Host "glifo detectado: ${bw} x ${bh} px  (offset $minX,$minY)"

# ── 2. Recortar al bounding box ──
$crop = New-Object System.Drawing.Bitmap($bw, $bh, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($crop)
$g.DrawImage($iso, (New-Object System.Drawing.Rectangle(0, 0, $bw, $bh)),
             (New-Object System.Drawing.Rectangle($minX, $minY, $bw, $bh)),
             [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

# ── 3. Escalar al safe zone y centrar en un lienzo transparente ──
$target = [int]([Math]::Min($w, $h) * $SAFE)
$scale = $target / [Math]::Max($bw, $bh)
$dw = [int]($bw * $scale); $dh = [int]($bh * $scale)
if ($dw -lt 1) { $dw = 1 }; if ($dh -lt 1) { $dh = 1 }

$fg = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g2 = [System.Drawing.Graphics]::FromImage($fg)
$g2.Clear([System.Drawing.Color]::Transparent)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g2.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g2.DrawImage($crop, [int](($w - $dw) / 2), [int](($h - $dh) / 2), $dw, $dh)
$g2.Dispose()

$fg.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)

Write-Host "foreground generado: ${dw} x ${dh} px sobre lienzo ${w} x ${h} ($([Math]::Round($scale*100))% del original)"
Write-Host "zona segura: el logo ocupa $([Math]::Round($dw/$w*100))% del ancho  (limite ~66%)"

$fg.Dispose(); $crop.Dispose(); $iso.Dispose(); $srcImg.Dispose()
if (Test-Path $tmp) { Remove-Item $tmp -Force }
