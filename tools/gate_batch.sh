#!/bin/bash
# Gate a LIST of wall scripts in the CURRENT worktree (run it from the worktree
# root), one after another (one GL window per machine): Rule 2 = replay x2
# byte-identical + vision critic. Per script: log to tmp/wall/gate_<tag>_<s>.log,
# judge the manifest over the gate log (harness/manifest_check.rb, the wall's
# judge), record the pin on a clean pass (harness/pins.rb, like run_wall.sh),
# print one summary line.
#
# --ref <captures_root>: after each gate, compare EVERY capture in
# captures/<s>_gate_a byte-for-byte (cmp) with <captures_root>/<s>_gate_a. That
# is the proof a refactor claimed byte-inert really is (IDENTICAL), or the count
# of frames a presentation change touched (DIFFERS n/total). Gate the claim at
# the sha that carries ONLY the refactor (detached worktree) against the wall's
# captures of the sha before it.
#
#   tools/gate_batch.sh <tag> [--ref <captures_root>] <script> [script ...]
#   tools/gate_batch.sh build4fix boss1_writ boss2_phases brasa3_run
#   (cd ../game-two-sig1 && bash ../game-two/tools/gate_batch.sh sig1 --ref ../game-two-wall6/captures ledger_loop town_gates)
#
# Refuses (exit 2) while a wall/sweep is running (any ruby alive) - one window.
# Exit 0 always otherwise: it is a batch runner, the pins + logs are the record.
# 2026-09-06, Junior's seat (wall #4 close: 14 fix gates + the signage extraction proof).
set -u
export PATH="/c/Ruby34-x64/bin:$PATH" CRITIC_TRANSPORT="${CRITIC_TRANSPORT:-gateway}"
[ -f Rakefile ] && [ -d harness/scripts ] || { echo "run from a worktree root (Rakefile + harness/scripts/)"; exit 2; }
tag="${1:-}"; shift || true
ref=""
if [ "${1:-}" = "--ref" ]; then ref="${2:-}"; shift 2; fi
if [ -z "$tag" ] || [ $# -eq 0 ]; then
  echo "usage: tools/gate_batch.sh <tag> [--ref <captures_root>] <scripts...>"; exit 2
fi
if [ "$(tasklist //FI "IMAGENAME eq ruby.exe" 2>/dev/null | grep -c ruby.exe)" -ne 0 ]; then
  echo "ruby is alive on this machine (a wall or a gate owns the window) - refuse"; exit 2
fi
mkdir -p tmp/wall
summary=()
t0=$(date +%s)
for s in "$@"; do
  [ -f "harness/scripts/$s.json" ] || { echo "=== $s: no such script - skipped ==="; summary+=("$(printf '%-18s SKIPPED (no script)' "$s")"); continue; }
  log="tmp/wall/gate_${tag}_${s}.log"
  echo "=== GATE $s $(date +%H:%M:%S) ==="
  bundle exec rake gate SCRIPT="harness/scripts/$s.json" > "$log" 2>&1
  rc=$?
  grep -E "^GATE (vision|determinism)|\[FAIL\]|INFRA" "$log" | cut -c1-200
  ruby harness/manifest_check.rb "harness/scripts/$s.json" "$log" > /dev/null 2>&1; mrc=$?
  cmpres="-"
  if [ -n "$ref" ] && [ -d "$ref/${s}_gate_a" ]; then
    diff_n=0; tot=0
    for f in captures/${s}_gate_a/*.png; do
      [ -f "$f" ] || continue
      b="$(basename "$f")"; tot=$((tot+1))
      if [ ! -f "$ref/${s}_gate_a/$b" ] || ! cmp -s "$f" "$ref/${s}_gate_a/$b"; then diff_n=$((diff_n+1)); fi
    done
    if [ "$diff_n" -eq 0 ]; then cmpres="IDENTICAL($tot)"; else cmpres="DIFFERS($diff_n/$tot)"; fi
  fi
  if [ "$rc" -eq 0 ] && [ "$mrc" -eq 0 ]; then
    ruby harness/pins.rb record --script "$s" --tag "$tag" --gate-rc 0 --manifest-rc 0 2>&1 | cut -c1-110
  fi
  line="$(printf '%-18s gate_rc=%s manifest_rc=%s captures_vs_ref=%s' "$s" "$rc" "$mrc" "$cmpres")"
  echo "=== $line ==="
  summary+=("$line")
done
echo
echo "GATE BATCH $tag DONE $(date +%H:%M:%S) ($(( ($(date +%s) - t0) / 60 )) min)"
printf '  %s\n' "${summary[@]}"
