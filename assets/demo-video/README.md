# Hero demo video

Sources for `src/static/video/screenhint-demo.{mp4,webm}` and its poster: a scripted take of
ScreenHint capturing the wind map from the Weather app, dragging the hint beside the window, and
double-clicking it away. It loops seamlessly.

The raw recording isn't checked in (it's ~130 MB), so re-making the video means recording a new
take. The coordinates below are specific to the setup it was recorded on: a 2560×1440pt
external display above the laptop, a pure-white wallpaper, and the Weather window at
(33, -1138), 1048×768pt. Measure the window again before re-recording.

## Pieces

- `drive.swift` — moves the mouse and presses keys for one take (⌘⇧2 hotkey, selection, drag,
  double-click) and logs each event and cursor position to `events.jsonl`.
  `swift drive.swift setup`, start recording, then `swift drive.swift take`.
- `ring.swift` — renders the brand-yellow click ring as a 24-frame PNG sequence in `ring/`.
- `build.sh` — trims, crossfades the loop seam, crops to the whole window plus the hint's landing
  spot (1520×882pt, ~1.72:1, 57pt of white on every side), adds the click rings, and encodes. The sync offset between the log and the video comes from when the
  hint starts fading after the double-click.

## Recording

```sh
ffmpeg -f avfoundation -capture_cursor 1 -framerate 60 -i "Capture screen 1:none" -t 18 \
  -vf "crop=3200:1900:644:420" -c:v h264_videotoolbox -b:v 60M take9.mov
```

The pointer was enlarged in Accessibility settings for legibility. macOS hides the pointer after
keyboard input until the mouse moves, so `drive.swift setup` wiggles it first; otherwise the
recording starts without a pointer.

ScreenHint's capture overlay only shows up in recordings since its window's `sharingType`
became `.readOnly`.

## Encoding notes

The recording is video-range (TV) BT.709, and its white wallpaper decodes to 252. `build.sh`
reads it as TV range, works in RGB, lifts whites to 255, and tags the output BT.709, so the
video's background matches the page's white exactly in the browser.

On the page, `.hero-video` (in `custom.css`) scales it to fit the one-screen hero on wider
screens, and on phones shows a 4:3 window anchored right, so the left of the Weather app runs
off the page.
