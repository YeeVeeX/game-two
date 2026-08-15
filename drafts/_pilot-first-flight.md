# Pilot mode — first flight transcript (2026-08-10)

Task-6 live verification of the pilot-mode plan. Session `first-flight`, seed 0,
real Gosu window on the real sim+renderer, driven entirely by inbox appends.
**Every acceptance item passed.**

## The acceptance bar (the design's central claim)

Pilot capture PNGs are **byte-identical (MD5)** to the PNGs produced by
`rake capture` replaying the session's own export:

```
b60c33ba467b57e9512f90f8743926b5  captures/pilot/first-flight/frame_0381_pickup.png
b60c33ba467b57e9512f90f8743926b5  captures/pilot/first-flight_replay/frame_0381.png
e4d2cc81e0759c49001144b674174d91  captures/pilot/first-flight/frame_0723_banked.png
e4d2cc81e0759c49001144b674174d91  captures/pilot/first-flight_replay/frame_0723.png
```

The replay also reproduced the exact live event: `EVENT banked frame=723
actor=striker amount=1 banked=1` appears in both the pilot log and the
rake-capture output.

## Flight log (commands appended → responses observed)

| # | Command | Response |
|---|---|---|
| 1 | `state` | STATE frame=0 nest, pack 3/3, banked=0 |
| 2 | `speed 30` | ACK |
| 3 | `goto 29 8` | `GOTO_FAILED reason=zone_changed tile=[1,13]` — gate crossed INTO district, abort correct (frame 219) |
| 4 | `goto 9 12` | GOTO_OK frame=350; allies engaged rusher2 en route (hp 50→5), striker took 12 (80→68) |
| 5 | `hold left,attack 6` | rusher2 died frame=355, `drop_spawned tile=[8,12] amount=1` |
| 6 | `goto 8 12` + `press interact` | `drop_picked_up carried=1` frame=381 |
| 7 | `capture pickup` | CAPTURED frame_0381_pickup.png (replay frame 381 = world.frame−1) |
| 8 | `goto 0 13` | `GOTO_FAILED reason=zone_changed tile=[28,8]` — re-entered nest frame 498 |
| 9 | `goto 12 8` + `press interact` | `banked amount=1 banked=1` frame=723 |
| 10 | `capture banked` | CAPTURED frame_0723_banked.png; frame shows magenta ledger "1" over the station |
| 11 | *(window minimized via user32 ShowWindow)* `wait 600` | `ACK wait 600 frame=1324` — exactly 724+600, frames advance minimized ✅ |
| 12 | `export smoke` | `EXPORTED tmp/pilot/first-flight/smoke.json run_until=1324`, captures [381, 723] |
| 13 | `quit` | ACK, clean process exit 0 |

## Defect found and fixed during the flight

**`$stdout.reopen(log)` takes an EXCLUSIVE file handle on mingw Ruby** — the
log was unreadable (`Device or resource busy`) while the window lived, which
defeats the whole read-the-log-while-flying loop. Verified with a minimal
two-variant probe: `IO#reopen` locks; plain `$stdout = File.open(..., "a")`
shares. Fixed in pilot.rb (assign globals, don't reopen). This is why the
first launch attempt looked dead: the log held only READY and couldn't be
read until the process exited.

## Also proven in passing

- Idle = frozen sim: state at frame 0 stayed frame 0 until the first command.
- ERR path: none triggered live (parser ERR cases covered by tests).
- The D0 loop end-to-end via pilot: kill → drop → pickup → gate → bank,
  `banked=1` in STATE — the exact loop the owner will fun-verify.
- goto abort on zone change fires on BOTH crossings (nest→district,
  district→nest) and reports the landing tile in the new zone.
