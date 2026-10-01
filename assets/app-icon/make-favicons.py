#!/usr/bin/env python3
"""Makes the site's favicons from the app icon master (AppIcon-OffsetTrio.svg).

    python3 assets/app-icon/make-favicons.py

Writes into src/static/, which Eleventy publishes at the site root:

  favicon.svg           the icon cropped to its body, without the macOS margin or the shadows
                        (at tab size the blur only muddies the shapes)
  favicon.ico           16, 32 and 48px, for browsers that ask for /favicon.ico
  apple-touch-icon.png  180px, square and opaque; iOS rounds the corners itself

Needs rsvg-convert and ImageMagick (brew install librsvg imagemagick).
"""
import re
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1] / 'src' / 'static'
BODY = '100 100 824 824'  # the 824px body inside the 1024px canvas

master = (HERE / 'AppIcon-OffsetTrio.svg').read_text()


def flatten(svg):
    """Crop to the body and drop the shadows, the rim highlight, and the defs only they used."""
    svg = svg.replace('viewBox="0 0 1024 1024" width="1024" height="1024"', f'viewBox="{BODY}"')
    svg = re.sub(r'<desc>.*?</desc>\n?', '', svg, flags=re.S)
    svg = re.sub(r'<filter id="(cardShadow|bodyShadow)".*?</filter>', '', svg, flags=re.S)
    svg = re.sub(r'<linearGradient id="rim".*?</linearGradient>', '', svg, flags=re.S)
    svg = re.sub(r' filter="url\(#(cardShadow|bodyShadow)\)"', '', svg)
    svg = re.sub(r'<path d="[^"]*" fill="none" stroke="url\(#rim\)"[^>]*/>\n?', '', svg)
    assert 'filter' not in svg and 'rim' not in svg, 'the master changed shape; update flatten()'
    return svg


def square(svg):
    """Fill the whole square with the ground instead of the squircle, for iOS."""
    x, y, w, h = BODY.split()
    svg, n = re.subn(r'<path d="[^"]*" fill="url\(#ground\)"/>',
                     f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="url(#ground)"/>', svg)
    assert n == 1, 'the master changed shape; update square()'
    return svg


def render(svg, size, dest):
    subprocess.run(['rsvg-convert', '-w', str(size), '-h', str(size), '-o', str(dest), '-'],
                   input=svg.encode(), check=True)


flat = flatten(master)
(OUT / 'favicon.svg').write_text(flat)

with tempfile.TemporaryDirectory() as tmp:
    pngs = []
    for size in (16, 32, 48):
        pngs.append(Path(tmp) / f'{size}.png')
        render(flat, size, pngs[-1])
    subprocess.run(['magick', *map(str, pngs), str(OUT / 'favicon.ico')], check=True)

render(square(flat), 180, OUT / 'apple-touch-icon.png')
print('wrote favicon.svg, favicon.ico, apple-touch-icon.png to', OUT)
