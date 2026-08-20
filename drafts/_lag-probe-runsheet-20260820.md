# Lag P0 — T2 probe runsheet (staged 2026-08-20; owner-paced, never nag)

Zero-code probe matrix from `drafts/_lag-spec-20260820.md` §probe matrix.
Prereq: BOTH machines on the same commit (`git pull` both seats first —
handshake law), T1 shipped (this session's two commits). ~20 min total.
Every segment ends with Esc so each produces its OWN close lines.

**What is already known (do not re-measure):** the joiner seat paced both
ritual sessions at ~53.5 Hz while the host ran ~60.5 and waited (banked
counter arithmetic + audio-drift oracles, see forensics Correction);
Gabriel's machine runs 60.7-61.2 tps solo, rock-steady. **What T2
answers:** is Junior's machine ~53.5 Hz ALONE (S0-J — the decisive
probe)? what eats its frame (frame_probe line)? do the 0.8-3.3 s spikes
correlate with path events (samplers) or focus (S2)?

## Guards (mechanical, before any segment)

- Single-instance: `tasklist /FI "IMAGENAME eq ruby.exe"` shows NONE
  before each launch (separate call, judged by printed output).
- `saves/world.json` md5 recorded on Gabriel's machine BEFORE S3 and
  compared AFTER (the joiner never writes; any move = named breach):
  `md5sum saves/world.json`
- No `--fresh`, ever.

## Samplers (start before each coop segment, both seats; Ctrl-C after)

```bash
# tailscale path sampler — one line every 10 s while playing:
while true; do echo "$(date +%H:%M:%S) $(tailscale status | grep -E 'gabriel|junior|100\.')"; sleep 10; done | tee -a tmp/lag/ts_sample_$(date +%H%M%S).log
# TCP retransmit delta — run ONCE before and ONCE after each segment:
netstat -s | grep -iA2 "retransmit" > tmp/lag/netstat_before_<seg>.log   # then _after_<seg>.log
```

## S0-J — Junior SOLO, flag ON (~4 min) — THE decisive segment

Junior (pt-br, no seu terminal Git Bash):
```bash
cd ~/Desktop/projeto-game-two/game-two && git pull
GAME_FRAME_PROBE=1 bin/play pt-br        # jogue normal uns 4 min, lute um pouco, Esc
```
Depois cole no chat: a linha `TELEMETRY frame_probe ...` + as linhas
`AUDIO drift ...` (as últimas 5 bastam) do log em `/tmp/game_two_session_*.log`.

## S0-J2 — Junior machine facts (one PowerShell line)

```powershell
Get-CimInstance Win32_VideoController | Select-Object Name, CurrentRefreshRate, CurrentHorizontalResolution; powercfg /getactivescheme
```

## S1 — coop baseline, flag ON both seats (~4 min)

Gabriel: `GAME_FRAME_PROBE=1 bin/play es --host` · Junior:
`GAME_FRAME_PROBE=1 bin/play pt-br --join <ip-tailscale>`. Samplers on,
both seats. Play normally, Esc. Both paste: `NETPLAY handshake ...`,
`TELEMETRY netplay ...`, `TELEMETRY frame_probe ...`.

## S2 — coop, focus experiment (~4 min)

Same launch as S1. Mid-session, the seat that is ALIVE minimizes its
window for 60 s (note the wall-clock minute!), restores, plays on, Esc.
Read: does the other seat's stall pattern spike in that minute (compare
stall_ms_max/stall_worst_run) — the "worse when 1 alive" correlate under
control. NOTE: do not drag windows around otherwise (a title-bar drag
freezes the loop — it would fake a spike).

## S3 — role swap: Junior hosts, Gabriel joins (~4 min)

- Gabriel BEFORE: `md5sum saves/world.json` → record.
- Junior: `GAME_FRAME_PROBE=1 bin/play pt-br --host` (his seat starts a
  scratch world save on HIS machine — that save is never merged back;
  custody handoff stays parked).
- Gabriel: `GAME_FRAME_PROBE=1 bin/play es --join <ip-de-junior>`.
- Gabriel AFTER: `md5sum saves/world.json` → must be UNCHANGED.
- Settles: direction (does the stall asymmetry FLIP with the roles? then
  it is the machine, not the hosting duties) + host-duties cost on his
  frame_probe line.

## Harvest checklist (into a dated evidence dir, md5-banked)

Per segment per seat: launcher log (or pasted lines), sampler logs,
netstat before/after. Then T3 (own session) answers in writing: which
seat limited the lockstep, and what ate its frame.

## Mensaje corto para el chat (es-CR, cuando el owner quiera)

> Probes de lag listos — 4 tandas de ~4 min con Junior cuando puedan.
> La clave es la S0-J: Junior jugando SOLO 4 minutos con
> `GAME_FRAME_PROBE=1`. Con eso sabemos si su máquina sola va a ~53 fps
> o si es cosa de la conexión. Comandos exactos en
> `drafts/_lag-probe-runsheet-20260820.md`.
