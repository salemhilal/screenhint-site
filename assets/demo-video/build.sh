#!/bin/bash
# Assemble the wide loop from take9.mov: the whole Weather window plus the hint's landing spot,
# 57pt of white on every side (1520x882pt, ~1.72:1). Trims, crossfades the loop seam, adds click
# rings, lifts the wallpaper to pure white, and encodes BT.709. The real pointer is in the take.
set -euo pipefail
S=1.83; L=11.96; X=0.4
E=$(echo "$S+$L+$X" | bc); LX=$(echo "$L+$X" | bc)
W=3040; H=1764                      # frame in recording pixels (2 px per pt)
OUT_W=1920; OUT_H=1114
ring() { echo "[$1:v]format=rgba,tpad=start_duration=$2:color=0x00000000[r$1]"; }
FC="[0:v]scale=in_range=tv:in_color_matrix=bt709,format=gbrp,trim=start=${S}:end=${E},setpts=PTS-STARTPTS,fps=60,crop=${W}:${H}:72:70,split=3[c1][c2][c3];\
[c1]trim=0:${X},setpts=PTS-STARTPTS[head];\
[c2]trim=${X}:${L},setpts=PTS-STARTPTS[body];\
[c3]trim=${L}:${LX},setpts=PTS-STARTPTS[tail];\
[tail][head]xfade=transition=fade:duration=${X}:offset=0[seam];\
[seam][body]concat=n=2:v=1[base];\
$(ring 1 2.535);$(ring 2 6.135);$(ring 3 9.393);$(ring 4 9.560);\
[base][r1]overlay=1016-100:514-100:eof_action=pass:format=gbrp[o1];\
[o1][r2]overlay=1326-100:986-100:eof_action=pass:format=gbrp[o2];\
[o2][r3]overlay=2616-100:986-100:eof_action=pass:format=gbrp[o3];\
[o3][r4]overlay=2616-100:986-100:eof_action=pass:format=gbrp[o4];\
[o4]colorlevels=rimax=0.985:gimax=0.985:bimax=0.985,scale=${OUT_W}:${OUT_H}:flags=lanczos:out_color_matrix=bt709:out_range=tv,format=yuv420p[out]"
RING=(-framerate 60 -i ring/%03d.png)
ffmpeg -hide_banner -v error -y -i take9.mov "${RING[@]}" "${RING[@]}" "${RING[@]}" "${RING[@]}" \
  -filter_complex "$FC" -map "[out]" -an -c:v libx264 -preset slow -crf 18 -profile:v high -color_primaries bt709 -color_trc bt709 -colorspace bt709 -color_range tv -movflags +faststart screenhint-demo-wide.mp4
