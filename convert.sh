#!/usr/bin/env bash
set -euo pipefail

# Recursively convert all .pdf files under INPUT_DIR to .png.
# By default, the PNG is written next to the PDF with the same basename.
#
# Usage:
#   bash pdfs_to_pngs.sh /path/to/root
#
# Optional environment variables:
#   DENSITY=300        # rasterization DPI
#   QUALITY=100        # PNG compression/quality hint for ImageMagick
#   OVERWRITE=0        # set to 1 to overwrite existing PNGs

INPUT_DIR="${1:-.}"
DENSITY="${DENSITY:-300}"
QUALITY="${QUALITY:-100}"
OVERWRITE="${OVERWRITE:-0}"

if ! command -v magick >/dev/null 2>&1; then
  echo "Error: ImageMagick ('magick') is not installed or not in PATH."
  echo "Install it and try again."
  exit 1
fi

find "$INPUT_DIR" -type f \( -iname '*.pdf' \) -print0 |
while IFS= read -r -d '' pdf; do
  png="${pdf%.*}.png"

  if [[ -f "$png" && "$OVERWRITE" != "1" ]]; then
    echo "Skipping existing: $png"
    continue
  fi

  echo "Converting: $pdf -> $png"

  # [0] means first page only. Remove it if you want all pages.
  magick -density "$DENSITY" "${pdf}[0]" \
    -background white -alpha remove -alpha off \
    -quality "$QUALITY" \
    "$png"
done