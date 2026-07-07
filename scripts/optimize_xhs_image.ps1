param(
  [Parameter(Mandatory = $true)]
  [string]$InputImage,

  [Parameter(Mandatory = $true)]
  [string]$OutputDir,

  [string]$BaseName = "xhs-image"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$Main = Join-Path $OutputDir "$BaseName-1080x1440.jpg"
$Upload = Join-Path $OutputDir "$BaseName-720x960.jpg"

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
  throw "ffmpeg is required on Windows. Install it with: winget install Gyan.FFmpeg"
}

# Center-crop to 3:4, lightly brighten/saturate, and sharpen without destroying real flower texture.
& $ffmpeg.Source -y -i $InputImage `
  -vf "crop='min(iw,ih*3/4)':'min(ih,iw*4/3)',scale=1080:1440,eq=brightness=0.025:contrast=1.06:saturation=1.08:gamma=1.02,unsharp=5:5:0.45:5:5:0.0" `
  -frames:v 1 -q:v 2 $Main | Out-Null

& $ffmpeg.Source -y -i $Main `
  -vf "scale=720:960" `
  -frames:v 1 -q:v 3 $Upload | Out-Null

Write-Output $Main
Write-Output $Upload
