#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <input-image> <output-dir> [basename]" >&2
  exit 2
fi

input="$1"
out_dir="$2"
base="${3:-xhs-image}"

mkdir -p "$out_dir"

main="$out_dir/${base}-1080x1440.jpg"
upload="$out_dir/${base}-720x960.jpg"

if command -v ffmpeg >/dev/null 2>&1; then
  # Center-crop to 3:4, lightly brighten/saturate, and sharpen without destroying real flower texture.
  ffmpeg -y -i "$input" \
    -vf "crop='min(iw,ih*3/4)':'min(ih,iw*4/3)',scale=1080:1440,eq=brightness=0.025:contrast=1.06:saturation=1.08:gamma=1.02,unsharp=5:5:0.45:5:5:0.0" \
    -frames:v 1 -q:v 2 "$main" >/dev/null 2>&1
  ffmpeg -y -i "$main" -vf "scale=720:960" -frames:v 1 -q:v 3 "$upload" >/dev/null 2>&1
elif command -v sips >/dev/null 2>&1; then
  # macOS fallback: pad to 3:4 instead of filtering.
  sips -s format jpeg -s formatOptions 92 --resampleHeight 1440 --padToHeightWidth 1440 1080 --padColor FFFFFF "$input" --out "$main" >/dev/null
  sips -s format jpeg -s formatOptions 90 --resampleHeight 960 --padToHeightWidth 960 720 --padColor FFFFFF "$input" --out "$upload" >/dev/null
else
  echo "Need ffmpeg or sips for image optimization." >&2
  exit 1
fi

printf '%s\n%s\n' "$main" "$upload"
