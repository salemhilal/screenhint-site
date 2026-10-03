# Brand assets

Design sources for the ScreenHint app icon and menu-bar glyph. This folder sits
outside `src/static/`, so Eleventy does **not** publish it — nothing here is
served by the site. It exists so the vector sources live next to the marketing
site rather than only inside the Xcode project.

## app-icon — "Offset Trio"

Three overlapping cards at different proportions, axis-aligned, each casting its
own shadow. Drawn on the macOS container: an 824px body centred in a 1024px
canvas, continuous-curvature squircle (n = 5 superellipse, r = 412).

The card group is translated `(50, 14)` for optical centring — its bounding box
alone would sit high and left of true centre, because the mass collects toward
the upper-left.

| Colour | Role |
| --- | --- |
| `#25252E` → `#0B0B10` | ground |
| `#8E8E9C` → `#6A6A78` | back card |
| `#FFFFFF` → `#E4E4EB` | middle card |
| `#FFD976` → `#F3A70D` | accent card |

Mustard resolves to `#FDC331` at its midpoint, matching the site.

- `AppIcon-OffsetTrio.svg` — master, 1024px, editable vectors with gradients
- `png/` — flat ladder, 16 through 1024
- `ScreenHint.iconset/` — Apple's naming, ready for `iconutil`

Sizes at or below 32px are rendered without the inner shadows; at that scale the
blur only muddies the shapes.

### Building a .icns

```sh
iconutil -c icns ScreenHint.iconset
```

### Regenerating

The PNGs are rendered from geometry rather than rasterised from the SVG, so the
two can drift if only one is edited. Treat the SVG as the source of truth and
re-render the ladder from it after any change.

### Favicons

`make-favicons.py` derives the site's favicons from the master and writes them to `src/static/`
(`favicon.svg`, `favicon.ico`, `apple-touch-icon.png`). They are the icon cropped to its body,
without the macOS margin or the shadows. Re-run it after changing the master.

## menu-bar — hint-glyph.svg

A 22×22 template image for the status item, used as `Image("Icon")` in
`ScreenHintApp.swift`. Three solid rounded rectangles echoing the app icon's
three cards, at the same relative directions — wide upper-left, tall right,
wide lower.

It is **not** a scaled-down Offset Trio. In the icon the cards overlap; at 22px
those overlaps are about 1px, and a template image is tinted flat, so overlapping
cards merge into one blob. The arrangement here keeps the directions but opens
the spacing to ~1.2px gaps so the three shapes stay separate once tinted.

Template images are tinted by the system — keep everything black, with the alpha
channel doing the work. No strokes: at this size solid shapes survive tinting and
low-DPI rendering better than outlines.

## wordmark

The site builds its wordmark from HTML and CSS in `src/_includes/navbar.njk` —
two spans, Space Grotesk 600 at 30px, `letter-spacing: -1px`, `gap: 4px`, with
"hint" on a `#FDC331` chip (`padding: 2px 6px`, `border-radius: 2px`). There is
no SVG in the site build, and `src/static/img/logo.svg` is the **old** outlined
mark, no longer used.

The SVGs here are that CSS logo converted to outlines, for contexts that can't
run CSS — currently the app's About window. Glyph advances and kerned positions
were measured against the live page, so the outlines sit exactly where the
browser puts them; the baseline is at y=30.5 (half-leading of -1.5 plus a 30px
ascent inside the 36px line box). The 5%-opacity `shadow-sm` on the chip is
omitted; it is imperceptible at any size this renders at.

- `wordmark-light.svg` — black "screen" and black "hint" on a mustard chip, for light backgrounds
- `wordmark-dark.svg` — white "screen" and black "hint" on a white chip, for dark backgrounds

On dark backgrounds the mark is black and white only: a mustard chip next to white
type on black reads as someone else's logo. The site footer does the same in CSS.

**If the CSS logo changes, these do not follow.** Regenerate them rather than
editing the path data by hand.

### In the app

`ScreenHint/Assets.xcassets/Logo.imageset/` carries both, keyed to light and dark
appearance. It is no longer a template image — a two-colour mark can't be tinted
flat without losing the mustard — so `template-rendering-intent` is gone and
`preserves-vector-representation` is set, since `AboutView` scales it to fit.

## social-image

The image shown when a link to the site is shared (`og:image`), `src/static/img/social-preview.png`.

- `card.html` — the image as a 1200×630 page, drawn with the site's own stylesheet and a copy of
  the hero scene's markup, in its resting state
- `build.sh` — renders it at 2x with headless Chrome; build the site first (`npm run deploy`)

If the hero scene's markup changes in `src/_includes/section.header.njk`, copy it across again.
Link previews are cached by the sites that show them, so give the file a new name (and update
`image` in `src/_data/site.json`) if a change needs to show up straight away.
