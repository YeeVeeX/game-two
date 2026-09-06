#!/usr/bin/env bash
# AREA TOUR (owner ask 2026-09-05: "show me each area 1 by 1, you play it,
# I just look, sped up 2.5x, 5 minute limit"). One deterministic wall
# script per area -> 2.5x clip -> title card -> one stitched MP4.
#
# Speed is exact by construction: VIDEO_EVERY=5 dumps 12 game-frames per
# second; ffmpeg plays them at 30 fps = 2.5x. No setpts, no resampling.
#
# Usage: harness/make_tour.sh [out.mp4]
#   runs ~12 min of tick-locked replay -> run DETACHED, never under a
#   bash-call timeout. NEVER beside a live human seat or a soak (GL
#   contention + single-writer). Needs a real GPU GL context: Gosu.render
#   dies NAMED on GDI-generic GL (Missing GL_EXT_framebuffer_object).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
export PATH="/c/Ruby34-x64/bin:$PATH"
unset MSYS_NO_PATHCONV

STAMP=$(date +%Y%m%d-%H%M%S)
OUT=${1:-captures/clips/tour_${STAMP}.mp4}
WORK="tmp/tour/${STAMP}"
EVERY=5
FPS=30   # 60/EVERY = 12 source fps, played at 30 = 2.5x
CARD_S=1.6
mkdir -p "$(dirname "$OUT")" "$WORK"

if tasklist //FI "IMAGENAME eq ruby.exe" 2>/dev/null | grep -q ruby.exe; then
  echo "TOUR REFUSED: a ruby.exe is already running (live seat or soak) - never capture beside it"
  exit 2
fi

# script | title | subtitle | max seconds of clip (0 = whole)
# Card claims are PROBE-CHECKED (s135, T0 d18): a subtitle may only promise
# what its reel actually puts on camera. Verified with tmp probes over each
# reel's own frames - tower4_run and brasa3_run never showed their promised
# boss (0 frames), tower3_run never blinks and tower2_run never petrifies.
# The three boss reels below are the ones that DO show a boss (on camera for
# most of the reel, and at 7-8 of their captured frames).
AREAS=(
  "world_loop|ZONE 1 - HOME + HUB 1|the everyday loop: bank, potions, first fights|0"
  "town_gates|ZONE 7 - town hub|torches (living ambience) - holes down to the tower and the fire dungeon|0"
  "floor1_run|ZONE 2 - descent floor -1|two spaces + 4 bridges - sprite pack, tile relief|0"
  "floor2_run|ZONE 3 - descent floor -2|submerged pilot: underwater ambience|0"
  "floor3_run|ZONE 5 - descent floor -3|moss: poison spores (green DOT) - BOSS 1 walks out of the vault|0"
  "basement_pocket|BASEMENT 1|the shallow pocket under ZONE 7|0"
  "toll_pocket|BASEMENT 2|the toll seal|0"
  "multi_floor_descent|DUNGEON 1 - tower top|serpent floor (your old ZONE 5 map) - stairs down at level 8|0"
  "tower2_run|DUNGEON 2 - tower floor 2|forced loop 2.2x - spread volleys|0"
  "tower3_run|DUNGEON 3 - tower floor 3|spiral loop 2.8x - petrify (stone telegraph)|0"
  "tower4_run|DUNGEON 4 - the bottom|the toll gate at the far end of the forced loop|0"
  "brasa1_run|DUNGEON 5 - fire dungeon, veins|lava + rubble - charge (ground telegraph)|0"
  "brasa2_run|DUNGEON 6 - fire dungeon, maze|guardian with the beam - stairs at level 17|30"
  "brasa3_run|DUNGEON 7 - fire dungeon, hall|aura rings and fire glow on the way to the dais|0"
  "zone8_crossing|ZONE 8 - the frontier|rope down from DUNGEON 1 (the way needs level 8)|0"
  "boss1_writ|BOSS 1 - the writ|his chant, the writ frame, and the seizure landing on you|0"
  "boss2_phases|BOSS 2 - phases|driven past 60% and 30%: the bar drains, the pips move|0"
  "boss4_phases|BOSS 4 - phases|the fire boss past 50%: dash and beam in rotation|0"
)

LIST="$WORK/concat.txt"
: > "$LIST"
i=0
for row in "${AREAS[@]}"; do
  IFS='|' read -r script title sub maxs <<< "$row"
  i=$((i + 1)); n=$(printf '%02d' "$i")
  seg="$WORK/${n}_$script"; mkdir -p "$seg"
  echo "TOUR [$n] $script - $title"
  python harness/tour_card.py "$seg/card.png" "$title" "$sub" || exit 1
  ffmpeg -y -loop 1 -framerate "$FPS" -t "$CARD_S" -i "$seg/card.png" \
    -c:v libx264 -pix_fmt yuv420p -r "$FPS" -loglevel error "$seg/card.mp4" || exit 1
  VIDEO_EVERY=$EVERY ruby -Isrc harness/replay_runner.rb "harness/scripts/$script.json" "$seg/run" \
    > "$seg/replay.log" 2>&1
  rc=$?
  frames=$(ls "$seg/run/video" 2>/dev/null | wc -l)
  if [ $rc -ne 0 ] || [ "$frames" -lt 10 ]; then
    echo "TOUR FAILED at $script (rc=$rc frames=$frames) - see $seg/replay.log"
    tail -5 "$seg/replay.log"
    exit 1
  fi
  trim=()
  [ "$maxs" != "0" ] && trim=(-t "$maxs")
  ffmpeg -y -framerate "$FPS" -i "$seg/run/video/v_%06d.png" "${trim[@]}" \
    -c:v libx264 -pix_fmt yuv420p -crf 20 -loglevel error "$seg/clip.mp4" || exit 1
  # Windows ffmpeg cannot open POSIX /c/... paths in a concat list: emit C:/... (pwd -W).
  echo "file '$(pwd -W)/$seg/card.mp4'" >> "$LIST"
  echo "file '$(pwd -W)/$seg/clip.mp4'" >> "$LIST"
  echo "TOUR [$n] done: frames=$frames -> $(awk "BEGIN{printf \"%.1f\", $frames/$FPS}")s at 2.5x"
done

ffmpeg -y -f concat -safe 0 -i "$LIST" -c copy -loglevel error "$OUT" || exit 1
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")
echo "TOUR DONE $OUT duration=${DUR}s areas=$i (2.5x, every=$EVERY @ ${FPS}fps)"
