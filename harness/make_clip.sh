#!/usr/bin/env bash
# Quality-flywheel lane 2 (2026-08-19): deterministic clip from a wall
# script. Runs the replay with VIDEO_EVERY frame dumping, then ffmpeg
# assembles an MP4. Same script + seed => same frames => comparable
# clips across builds (the before/after property the assets era needs).
#
# Usage: harness/make_clip.sh harness/scripts/<name>.json [every_n] [out.mp4]
#   every_n  dump every nth sim frame (default 2 -> 30 fps video)
#
# NEVER run beside a live human seat or a soak (GL contention + the
# single-writer discipline). The wall itself never uses video mode.
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1
export PATH="/c/Ruby34-x64/bin:$PATH"

SCRIPT=${1:?usage: make_clip.sh <script.json> [every_n] [out.mp4]}
EVERY=${2:-2}
NAME=$(basename "$SCRIPT" .json)
STAMP=$(date +%Y%m%d-%H%M%S)
OUT=${3:-captures/clips/${NAME}_${STAMP}.mp4}
WORK="tmp/clip_${NAME}_${STAMP}"

mkdir -p "$(dirname "$OUT")" "$WORK"

echo "CLIP replaying $SCRIPT (every=$EVERY frame) -> $WORK"
printf '{"every": %s}\n' "$EVERY" > "$WORK/clip_meta.json"
VIDEO_EVERY=$EVERY ruby -Isrc harness/replay_runner.rb "$SCRIPT" "$WORK" \
  | tail -3

FPS=$(( 60 / EVERY ))
ffmpeg -y -framerate "$FPS" -i "$WORK/video/v_%06d.png" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 -loglevel error "$OUT"

FRAMES=$(ls "$WORK/video" | wc -l)
SIZE=$(wc -c < "$OUT")
echo "CLIP DONE $OUT (frames=$FRAMES fps=$FPS bytes=$SIZE)"
echo "clip: $OUT" >> "$WORK/manifest.txt"
