#!/bin/bash
# v18 canary sweep runner: EVERY script in harness/scripts/ through
# `rake canary` against the banked baselines (default tmp/canary_baseline/
# — machine-local, banked at increment 0; re-bank from a sim-identical
# line if tmp/ was cleaned). Byte-identity proof after every sim-touching
# increment (spec decision 7 / W3). One capture window at a time.
#
# Usage:
#   harness/run_canary.sh [baseline_root]
#
# Exit codes are captured via PIPESTATUS — never bare $? after a pipe
# (the run_wall.sh lesson).
set -u -o pipefail
export PATH="/c/Ruby34-x64/bin:$PATH"
cd "$(dirname "$0")/.." || exit 1

ROOT="${1:-tmp/canary_baseline}"
fails=""
count=0

for script in harness/scripts/*.json; do
  s="$(basename "$script" .json)"
  count=$((count + 1))
  echo "=== CANARY $s ($count) $(date +%H:%M:%S) ==="
  bundle exec rake canary SCRIPT="$script" BASELINE="$ROOT/$s" 2>&1 | tail -2
  rc=${PIPESTATUS[0]}
  if [ "$rc" -ne 0 ]; then
    fails="$fails $s"
  fi
done

echo "CANARY SWEEP DONE $(date +%H:%M:%S) — $count scripts vs $ROOT, fails:${fails:- none}"
if [ -n "$fails" ]; then
  echo "CANARY SWEEP FAIL:$fails"
  exit 1
fi
echo "CANARY SWEEP PASS"
