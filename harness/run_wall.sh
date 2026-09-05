#!/bin/bash
# Rule 2 wall runner: EVERY script in harness/scripts/ through the blocking
# gate + machine manifest check, one window at a time, teed logs.
#
# Verdicts are read from the teed logs AND from exit codes captured via
# PIPESTATUS — never bare $? after a pipe (a masked PIPESTATUS bug in the old
# tmp/ runner silently ate critic failures for ~2 cycles; that runner was
# untracked scratch, which is why this one lives in harness/ with tests.
# See drafts/_adversarial-review-20260815.md).
#
# Usage:
#   harness/run_wall.sh [tag]          # tag defaults to a timestamp
#   SKIP_CRITIC=1 harness/run_wall.sh  # determinism halves only (NOT shippable)
set -u -o pipefail
export PATH="/c/Ruby34-x64/bin:$PATH"
cd "$(dirname "$0")/.." || exit 1

TAG="${1:-$(date +%Y%m%d_%H%M%S)}"
mkdir -p tmp/wall
fails=""
count=0

for script in harness/scripts/*.json; do
  s="$(basename "$script" .json)"
  count=$((count + 1))
  log="tmp/wall/${s}_${TAG}.log"
  echo "=== WALL $s $(date +%H:%M:%S) ==="
  bundle exec rake gate SCRIPT="$script" 2>&1 | tee "$log"
  gate_rc=${PIPESTATUS[0]}
  bundle exec rake manifest SCRIPT="$script" LOG="$log" 2>&1 | tee -a "$log"
  man_rc=${PIPESTATUS[0]}
  echo "=== $s gate_rc=$gate_rc manifest_rc=$man_rc ===" | tee -a "$log"
  # Pin ledger (v22 prep): one row per script per sweep, written immediately so a
  # sweep killed midway keeps the pins it earned. `rake pins` reads it back.
  ruby harness/pins.rb record --script "$s" --tag "$TAG" --gate-rc "$gate_rc" --manifest-rc "$man_rc" 2>&1 | tee -a "$log"
  if [ "$gate_rc" -ne 0 ] || [ "$man_rc" -ne 0 ]; then
    fails="$fails $s"
  fi
done

echo "WALL SWEEP DONE $(date +%H:%M:%S) — $count scripts, fails:${fails:- none}"
if [ -n "$fails" ]; then
  echo "WALL FAIL:$fails"
  exit 1
fi
