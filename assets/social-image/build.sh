#!/bin/bash
# Renders card.html to the site's link-preview image with headless Chrome, at 2x for sharp text.
# Build the site first (npm run deploy): the card uses public/css/page.css.
set -euo pipefail
cd "$(dirname "$0")"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
OUT=../../src/static/img/social-preview.png
"$CHROME" --headless=new --hide-scrollbars --window-size=1200,630 --force-device-scale-factor=2 \
  --virtual-time-budget=5000 --screenshot="$PWD/$OUT" "file://$PWD/card.html"
echo "wrote $OUT"
