#!/bin/bash
# Assemble the 4:3 loop from take8.mov: trim, crossfade the seam, crop (left edge halfway into
# the daily list), fade the cropped edge to white, and add click rings.
set -euo pipefail
S=1.84; L=11.97; X=0.4
E=$(echo "$S+$L+$X" | bc); LX=$(echo "$L+$X" | bc)
W=2352; H=1764; FADE=224; LEAD=24   # 12pt solid white, then a soft S-curve over 100pt (2px per pt)
ring() { echo "[$1:v]format=rgba,tpad=start_duration=$2:color=0x00000000[r$1]"; }
FC="[0:v]scale=in_range=tv:in_color_matrix=bt709,format=gbrp,trim=start=${S}:end=${E},setpts=PTS-STARTPTS,fps=60,crop=${W}:${H}:72:70[src];\
[src][5:v]overlay=0:0:eof_action=pass:format=gbrp,split=3[c1][c2][c3];\
[c1]trim=0:${X},setpts=PTS-STARTPTS[head];\
[c2]trim=${X}:${L},setpts=PTS-STARTPTS[body];\
[c3]trim=${L}:${LX},setpts=PTS-STARTPTS[tail];\
[tail][head]xfade=transition=fade:duration=${X}:offset=0[seam];\
[seam][body]concat=n=2:v=1[base];\
$(ring 1 2.548);$(ring 2 6.159);$(ring 3 9.401);$(ring 4 9.565);\
[base][r1]overlay=336-100:514-100:eof_action=pass:format=gbrp[o1];\
[o1][r2]overlay=646-100:986-100:eof_action=pass:format=gbrp[o2];\
[o2][r3]overlay=1936-100:986-100:eof_action=pass:format=gbrp[o3];\
[o3][r4]overlay=1936-100:986-100:eof_action=pass:format=gbrp[o4];\
color=c=white:s=${FADE}x${H}:r=60,format=rgba,geq=r=255:g=255:b=255:a='255*(1-(clip((X-${LEAD})/(W-${LEAD})\,0\,1)*clip((X-${LEAD})/(W-${LEAD})\,0\,1)*clip((X-${LEAD})/(W-${LEAD})\,0\,1)*(clip((X-${LEAD})/(W-${LEAD})\,0\,1)*(6*clip((X-${LEAD})/(W-${LEAD})\,0\,1)-15)+10)))'[fade];\
[o4][fade]overlay=0:0:shortest=1:format=gbrp[o5];\
[o5]colorlevels=rimax=0.985:gimax=0.985:bimax=0.985,scale=1600:1200:flags=lanczos:out_color_matrix=bt709:out_range=tv,format=yuv420p[out]"
RING=(-framerate 60 -i ring/%03d.png)
ffmpeg -hide_banner -v error -y -i take8.mov "${RING[@]}" "${RING[@]}" "${RING[@]}" "${RING[@]}" -framerate 60 -i cursor2/%04d.png \
  -filter_complex "$FC" -map "[out]" -an -c:v libx264 -preset slow -crf 18 -profile:v high -color_primaries bt709 -color_trc bt709 -colorspace bt709 -color_range tv -movflags +faststart screenhint-demo-final.mp4
