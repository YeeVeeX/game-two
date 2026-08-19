#!/usr/bin/env bash
# v18 session-8 soak orchestrator (brief D4-D7): spawn a host bot + a
# joiner bot as REAL processes (real windows, real loopback TCP, real
# wall clock — the gates prove determinism; the soak proves endurance),
# N episodes on a SCRATCH save, then judge the run from LOGS + exit
# codes via soak/chain_check.rb. NEVER bin/play (that launcher logs to
# %TEMP% and belongs to humans — D4): every artifact lands under
# tmp/soak/<run>/.
#
# Usage (env-driven; `rake soak` passes these through):
#   N=3 TICKS=36000 SEED=12345 bash soak/run_soak.sh
#   PORT_BASE=43217   first episode binds PORT_BASE+1, then +2, ...
#   HOST_ONLY=1       spawn only the host seat (cross-machine: the peer
#                     runs JOIN_ONLY=1 HOST_ADDR=<this machine>)
#   JOIN_ONLY=1 HOST_ADDR=100.x.y.z   joiner-only against a remote host
#   JOIN_WAIT_S=10    join_only: seconds to wait before each join (give
#                     the remote host time to bind/rebind between episodes)
#   ALLOW_LINK_FAULTS=1   Tailscale posture (D7): exit 2 = recorded
#                     finding, not a hard fail. Loopback default: hard.
#   TIMEOUT_S=...     per-episode kill fuse (default TICKS/60 + 180)
#   ZONES=a,b,c       lane-1 coverage (2026-08-19): episode i starts both
#                     seats in zones[(i-1) % len] via --start-zone;
#                     chain_check asserts the START_ZONE line per seat
#                     and combat outside hubs.
#   SEED_SAVE=1       pre-seed the scratch save (soak/seed_save.rb:
#                     home=nest banked=60 provisions=3) so sustain buys
#                     execute for real; chain_check expects ep1 to LOAD
#                     the seeded digest.
#   SOAK_AUDIO=1      bots boot the audio bridge in noDevice mode (real
#                     mixer graph, no hardware) — audio_bridge.rb reads
#                     this env directly; watch AUDIO teardown lines.
#
# Quarantine (mechanical, verified EVERY run): the real save
# (saves/world.json) md5 must not move, and no new game_two_session_*.log
# may appear in the temp dir — either drift is a named BREACH, exit 1.
set -u
cd "$(dirname "$0")/.." || exit 1
export PATH="/c/Ruby34-x64/bin:$PATH"

N=${N:-3}
TICKS=${TICKS:-36000}
SEED=${SEED:-$((RANDOM * 32768 + RANDOM))}
PORT_BASE=${PORT_BASE:-43217}
HOST_ADDR=${HOST_ADDR:-127.0.0.1}
TIMEOUT_S=${TIMEOUT_S:-$((TICKS / 60 + 180))}
HOST_ONLY=${HOST_ONLY:-}
JOIN_ONLY=${JOIN_ONLY:-}
ALLOW_LINK_FAULTS=${ALLOW_LINK_FAULTS:-}

MODE=both
[ -n "$HOST_ONLY" ] && MODE=host_only
[ -n "$JOIN_ONLY" ] && MODE=join_only

ZONES=${ZONES:-}
SEED_SAVE=${SEED_SAVE:-}

RUN="tmp/soak/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN"
SAVE="$RUN/world.json"

SEED_DIGEST=""
if [ -n "$SEED_SAVE" ] && [ "$MODE" != "join_only" ]; then
  SEED_LINE=$(ruby -Isrc soak/seed_save.rb "$SAVE" nest 60 3) || {
    echo "SOAK ABORT: seed_save failed"; echo "$SEED_LINE"; exit 1; }
  echo "$SEED_LINE"
  SEED_DIGEST=$(printf '%s' "$SEED_LINE" | sed -n 's/.*digest=\([0-9a-f]\{32\}\).*/\1/p')
  [ -z "$SEED_DIGEST" ] && { echo "SOAK ABORT: no digest in seed line"; exit 1; }
fi

ZONES_JSON=null
if [ -n "$ZONES" ]; then
  ZONES_JSON=$(printf '%s' "$ZONES" | ruby -e 'require "json"; puts STDIN.read.split(",").map(&:strip).reject(&:empty?).to_json')
fi

save_md5() { [ -f saves/world.json ] && md5sum saves/world.json | cut -d' ' -f1 || echo absent; }
logsize() { [ -f "$1" ] && wc -c < "$1" || echo 0; }
temp_logs() { ls /tmp/game_two_session_*.log 2>/dev/null | wc -l; }
REAL_MD5=$(save_md5)
TEMP_COUNT=$(temp_logs)

cat > "$RUN/run.json" <<EOF
{"ticks": $TICKS, "episodes": $N, "mode": "$MODE",
 "allow_link_faults": $([ -n "$ALLOW_LINK_FAULTS" ] && echo true || echo false),
 "seed_base": $SEED, "port_base": $PORT_BASE, "host_addr": "$HOST_ADDR",
 "zones": $ZONES_JSON,
 "seed_digest": $([ -n "$SEED_DIGEST" ] && printf '"%s"' "$SEED_DIGEST" || echo null)}
EOF
echo "SOAK RUN $RUN mode=$MODE n=$N ticks=$TICKS seed_base=$SEED timeout=${TIMEOUT_S}s${ZONES:+ zones=$ZONES}${SEED_DIGEST:+ seeded=$SEED_DIGEST}"

for i in $(seq 1 "$N"); do
  EP="$RUN/ep$i"
  mkdir -p "$EP"
  PORT=$((PORT_BASE + i))
  HSEED=$((SEED + 2 * i))
  JSEED=$((SEED + 2 * i + 1))
  ZONE_ARGS=()
  if [ -n "$ZONES" ]; then
    ZONE=$(printf '%s' "$ZONES" | ruby -e 'zs = STDIN.read.split(",").map(&:strip).reject(&:empty?); puts zs[(ARGV[0].to_i - 1) % zs.length]' "$i")
    ZONE_ARGS=(--start-zone "$ZONE")
  fi
  HPID=""
  JPID=""
  # Host quits at TICKS+120 (margin: seats run ~D apart, BOTH must clear
  # TICKS); the joiner's own quit is a backstop only.
  if [ "$MODE" != "join_only" ]; then
    ruby -Isrc src/main.rb --host "$PORT" --bot "$HSEED" --bot-ticks $((TICKS + 120)) \
      --save "$SAVE" "${ZONE_ARGS[@]}" > "$EP/host.log" 2>&1 &
    HPID=$!
    sleep 2
  fi
  if [ "$MODE" != "host_only" ]; then
    [ "$MODE" = "join_only" ] && sleep "${JOIN_WAIT_S:-10}"
    ruby -Isrc src/main.rb --join "$HOST_ADDR:$PORT" --bot "$JSEED" \
      --bot-ticks $((TICKS + 3720)) "${ZONE_ARGS[@]}" > "$EP/joiner.log" 2>&1 &
    JPID=$!
  fi
  echo "EP$i port=$PORT host_seed=$HSEED joiner_seed=$JSEED${ZONE_ARGS[1]:+ zone=${ZONE_ARGS[1]}} pids=${HPID:--}/${JPID:--}"

  TIMEOUT_FLAG=0
  s=0
  while [ "$s" -lt "$TIMEOUT_S" ]; do
    alive=0
    [ -n "$HPID" ] && kill -0 "$HPID" 2>/dev/null && alive=1
    [ -n "$JPID" ] && kill -0 "$JPID" 2>/dev/null && alive=1
    [ "$alive" -eq 0 ] && break
    [ $((s % 60)) -eq 0 ] && [ "$s" -gt 0 ] && \
      echo "EP$i heartbeat ${s}s host=$(logsize "$EP/host.log")B joiner=$(logsize "$EP/joiner.log")B"
    sleep 1
    s=$((s + 1))
  done
  for PID in $HPID $JPID; do
    if kill -0 "$PID" 2>/dev/null; then
      echo "EP$i TIMEOUT after ${TIMEOUT_S}s — killing $PID"
      kill "$PID" 2>/dev/null
      TIMEOUT_FLAG=1
    fi
  done
  HRC=""
  JRC=""
  [ -n "$HPID" ] && { wait "$HPID"; HRC=$?; }
  [ -n "$JPID" ] && { wait "$JPID"; JRC=$?; }
  {
    [ -n "$HRC" ] && echo "host=$HRC"
    [ -n "$JRC" ] && echo "joiner=$JRC"
    echo "timeout=$TIMEOUT_FLAG"
  } > "$EP/exit"
  echo "EP$i done host_rc=${HRC:--} joiner_rc=${JRC:--} timeout=$TIMEOUT_FLAG"
done

BREACH=0
POST_MD5=$(save_md5)
if [ "$REAL_MD5" != "$POST_MD5" ]; then
  echo "QUARANTINE BREACH: saves/world.json changed ($REAL_MD5 -> $POST_MD5)"
  BREACH=1
fi
POST_TEMP=$(temp_logs)
if [ "$POST_TEMP" -ne "$TEMP_COUNT" ]; then
  echo "QUARANTINE BREACH: game_two_session_*.log count in /tmp moved ($TEMP_COUNT -> $POST_TEMP)"
  BREACH=1
fi

ruby soak/chain_check.rb "$RUN"
CHECK_RC=$?
[ "$BREACH" -ne 0 ] && exit 1
exit $CHECK_RC
