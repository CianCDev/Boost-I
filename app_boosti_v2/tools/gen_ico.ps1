Add-Type -AssemblyName System.Drawing

# Genera `assets/icon/app_icon.ico` multi-resolucion desde `app_icon.png`.
#
# Por que hace falta: `pubspec.yaml` declara
#   inno_bundle.installer_icon: "assets/icon/app_icon.ico"
# y el archivo fue borrado al cambiar el logo -> `dart run inno_bundle`
# revienta con "installer_icon not found".
#
# Formato ICO: ICONDIR (6 bytes) + N ICONDIRENTRY (16 bytes c/u) + las
# imagenes. Desde Windows Vista el payload puede ser PNG directamente, asi
# que no hace falta recomprimir a BMP.
#
# El PNG viene con fondo azul solido, asi que aca NO se transparenta el
# fondo: el .ico es un icono cuadrado clasico de Windows y se ve bien
# con el azul completo.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root 'assets\icon\app_icon.png'
$dst  = Join-Path $root 'assets\icon\app_icon.ico'

$sizes = @(16, 32, 48, 64, 128, 256)

$source = [System.Drawing.Image]::FromFile($src)

# ── Renderizar cada tamano a PNG en memoria ──
$images = @()
foreach ($s in $sizes) {
  $bmp = New-Object System.Drawing.Bitmap($s, $s, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g   = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.Clear([System.Drawing.Color]::FromArgb(47, 129, 211))
  $g.DrawImage($source, (New-Object System.Drawing.Rectangle(0, 0, $s, $s)))
  $g.Dispose()

  $ms = New-Object System.IO.MemoryStream
  $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
  $images += ,$ms.ToArray()
  $bmp.Dispose()
}

# ── Escribir el contenedor ICO ──
$fs = [System.IO.File]::Create($dst)
$bw = New-Object System.IO.BinaryWriter($fs)

# ICONDIR
$bw.Write([UInt16]0)          # idReserved
$bw.Write([UInt16]1)          # idType = 1 (icono)
$bw.Write([UInt16]$sizes.Count)

# Offset del primer payload: header + una entry por imagen
$offset = 6 + (16 * $sizes.Count)

for ($i = 0; $i -lt $sizes.Count; $i++) {
  $s = $sizes[$i]
  # 256 se codifica como 0 en el campo de 1 byte
  $dim = if ($s -ge 256) { 0 } else { $s }
  $bw.Write([Byte]$dim)        # bWidth
  $bw.Write([Byte]$dim)        # bHeight
  $bw.Write([Byte]0)           # bColorCount = 0 (>256 colores)
  $bw.Write([Byte]0)           # bReserved
  $bw.Write([UInt16]1)         # wPlanes
  $bw.Write([UInt16]32)        # wBitCount
  $bw.Write([UInt32]$images[$i].Length)  # dwBytesInRes
  $bw.Write([UInt32]$offset)             # dwImageOffset
  $offset += $images[$i].Length
}

foreach ($img in $images) { $bw.Write($img) }

$bw.Dispose(); $fs.Dispose(); $source.Dispose()

Write-Host "ICO generado: $dst  ($($sizes -join ', ') px)"
Write-Host "  tamano: $([Math]::Round((Get-Item $dst).Length / 1KB, 1)) KB"
