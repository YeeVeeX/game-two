# Audio polish grill — duplicate triggers + music ducking (2026-08-20)

**Status:** implementation complete; suite + netplay gate PASS; fresh-eyes review
FAIL adjudicated in §6 (release aligned in data; depth collision recorded +
ear-check item); owner ear-check pending.
**Owner order:**

- Duplicate/sync symptom: "algunos bugs de sincronización o duplicación de triggering de los sonidos".
- Mix pressure: "añadir algunos elementos que tengan sidechain/ducking … se juntan muchos sonidos a la vez … tiende a acumularse o volverse abrumante".
- The previous ear-check verdict was "suena muy bien"; this increment must preserve that approved overall balance.

## 1. Staging gate

- Pulled `origin/main`; live head is `6481440`. The only delta from the spark's
  `d3d853a` baseline is the owner-approved session-24 spark itself (docs-only).
- Working tree at staging: expected untracked `drafts/_refs/` only.
- Host save: md5 `98fe75edb6d72deab18cd48eaa88bdaf`, mtime
  `2026-08-20 15:51:53 -0600` — exact match; no launch occurred.
- Human launcher logs: 38 under `/tmp` + the same 38 through the Windows temp
  path = 76 paths, unchanged. Seat mail: inbox 0, `done/` 15. Newest soak:
  `tmp/soak/20260820-020422`, unchanged.
- Junior's new S0-J evidence was read before routing: `drafts/_junior-s0j-frame-probe-20260820.md`.
  Its preregistered 16.9 ms prediction matched the measured 16.8 ms median;
  the long-frame tail is now the live T2 fact for later T3.

## 2. T-A evidence before design

### 2.1 Static event shape

- A regular hit calls `emit_attack_hit` from `World#apply_action_hit`
  (`src/game/world.rb:997-1006`). Delayed volley and projectile impacts call the
  same seam (`src/game/world.rb:1057,1078`).
- `World#emit_attack_hit` emits one `:attack_hit` for each victim connection
  (`src/game/world.rb:1525-1532`). This is correct sim truth and remains untouched.
- A projectile launch emits one `:projectile_fired` per launched projectile
  (`src/game/world.rb:1012-1020`); it is not per impact target.
- Before this fix, every event in a variant family advanced its rotor and called
  the real sink immediately (`6481440:src/app/audio_bridge.rb:220-221`).

### 2.2 Headless reproduction against the real library

The reproduction used a real `Game::World`, real `Core::EventBus`, the district
three-target whirlwind setup from `test/game/whirlwind_test.rb`, and the real
sibling DLL/render graph through `App::AudioBridge.boot(device: 0)`. A Ruby
`TracePoint` only observed calls into the real `GTA::AudioSystem#handle_event`;
it did not replace any object or behavior. Raw output is retained at
`tmp/audio_dup_repro_pre_fix.log` (ignored artifact), md5
`9794ca7e29482e372554373537f6dcee`:

```text
BOOT AUDIO on: device=0 sha=15f03e0219d6 lib=C:/Users/gabri/workspace/game-two-audio
RAW_HITS count=3 ticks={395 => 3}
RAW tick=395 victim=rusher2 active_voices_after_callback=2
RAW tick=395 victim=rusher0 active_voices_after_callback=3
RAW tick=395 victim=rusher1 active_voices_after_callback=4
REQUESTS tick=395 count=9 names=[:damage_dealt, :attack_hit, "attack_hit__c", :damage_dealt, :attack_hit, "attack_hit__b", :damage_dealt, :attack_hit, "attack_hit__d"]
SYNTHETIC_HITS count=3 ticks={395 => 3} names=["attack_hit__c", "attack_hit__b", "attack_hit__d"]
VICTIM_HP [["rusher0", 20], ["rusher1", 20], ["rusher2", 20]]
```

Measured result: one legitimate three-target spin emits three raw hit facts and
starts three hit voices in the same tick. The existing special cue occupies the
first voice, so the observer sees active voices rise `2 → 3 → 4` as the three
hit callbacks run.

### 2.3 The owner's “sync” half

The one-tick-flam hypothesis is **contradicted**. All three raw events and all
three synthetic cue requests carry tick 395. The library maps that tick to one
PCM frame and starts each cue directly in `handle_event → start_cue`
(`game-two-audio/src/gta/audio_system.rb:77-87,236-257`). There is no bridge
queue or next-tick rotor cadence. The audible defect is same-frame layering
(three near-identical transients/voices), not a second take delayed by one tick.

### 2.4 Decision

Coalesce **presentation variants only** to one cue per event family per world
tick:

1. The first event for a variant family in tick N advances that family's rotor
   and reaches the sink.
2. Later events in the same family and tick do not advance the rotor and do not
   start another voice.
3. A new tick can fire the family again. Different families in the same tick
   remain independent.
4. Raw bus events still emit and process once per connection. World, damage,
   telemetry, save, digest, and netplay code do not change.

The policy applies uniformly to the families declared in
`data/audio/variants.json` (`attack_hit`, `dodged`, `pack_wiped`,
`projectile_fired`). This is intentionally a presentation density rule, not a
claim that simultaneous sim facts are duplicates.

**Rotor invariant:** coalesced events do not consume takes. Therefore the take
sequence is exactly the existing deterministic sequence sampled once per
(event family, tick), and two lockstep seats derive the same choices from the
same stream.

**Rejected:** changing `World#emit_attack_hit`, because it would erase sim and
telemetry truth to solve a sink symptom. Also rejected: time-window debounce;
a window longer than one tick would make combat cadence an implicit audio
balance constant and suppress legitimate later attacks.

## 3. T-B duck semantics and decision

### 3.1 Existing law

- Every cue may carry one data block with `bus`, `duck_db`, `attack_frames`,
  `hold_frames`, and `release_frames`.
- `AudioData` requires negative depth, positive times, a declared target bus,
  and `hold_frames >= tick_frames` (`game-two-audio/src/gta/audio_data.rb:79-100`).
- The engine has one pending fade slot per group. Same-depth overlap does not
  schedule another attack; it extends one hold, then issues one release
  (`game-two-audio/src/gta/audio_system.rb:265-287`).
- Current gate-proven dramatic precedent is music −12 dB with 2,400-frame
  attack, 24,000-frame hold, and 9,600-frame release on stingers/wipe
  (`data/audio/cues.json`).
- The pool already bounds SFX at 48 simultaneous voices inside a 64-voice total
  (`data/audio/cues.json:22-25`). That prevents unbounded growth; it does not
  prevent an ordinary sub-cap pile-up from sounding dense.

### 3.2 One-lever increment

Add this duck to all four takes of hit, dodge, and throw, plus the single
special cue:

```json
"duck": {
  "bus": "music",
  "duck_db": -4.0,
  "attack_frames": 800,
  "hold_frames": 2400,
  "release_frames": 9600
}
```

At 48 kHz this is a 16.7 ms attack, 50 ms hold, and 200 ms release. It is much
shallower than the −12 dB dramatic precedent. Repeated percussion extends one
music-space episode instead of stacking fades, which is exactly the library's
proven overlap behavior. The release length deliberately matches the dramatic
ducks — see §6 for the collision analysis that forced that value (the first
draft used 4800 and the fresh-eyes review caught the consequence).

Do **not** move the global SFX bus in this increment. The owner approved the
current overall sound and the percussive cues already moved −4.08 dB in session
23. A global −1…−2 dB change would be a second simultaneous lever and would
also move death/stingers that were not named in this complaint. First isolate
whether short music ducking plus same-tick hit coalescing resolves the pile-up.

No compressor, detector, envelope follower, or library change is needed. This
is cue-triggered bus ducking within the existing schema. True signal-driven
sidechain compression remains a library increment only if the owner's next
ear-check says this event-driven version is insufficient.

## 4. Touchstone and verification contract

Architecture touchstone: `game-research/game-audio-architecture-2d-deterministic.md`
(last verified 2026-08-17) requires audio to remain a pure sink and same-tick
commands to derive only from `(event stream, tick)`; it also places ducking at
the bus-command layer. The local bridge/library contracts above are the primary
authority.

Blocking checks before ship:

1. Red-first integration test: real World whirlwind proves 3 raw hit events in
   one tick but only 1 added hit voice for that family/tick.
2. Rotor tests: repeats in one tick consume one take; the next tick gets the
   next deterministic non-repeating take.
3. Real `AudioData` load/bridge boot accepts every duck row.
4. Full suite, then the netplay session gate because bridge code moved. No
   visual wall is owed: no pixels, replay inputs, renderer, or sim values move.
5. Fresh-context code/evidence/doc review is blocking. Accuracy and
   presentation are scored separately.
6. Owner ear-check remains pending for both the duplicate fix and ducking.

## 5. Implementation and deterministic receipts

### T-A

The red-first targeted run failed on both intended seams before production code
moved:

```text
AudioBridgeTest#test_rotor_coalesces_one_family_per_tick_without_consuming_a_take:
NoMethodError: undefined method 'next_for_tick'
AudioBridgeTest#test_real_whirl_keeps_three_hit_events_but_starts_one_hit_voice:
Expected: [2, 2, 2]
  Actual: [2, 3, 4]
14 runs, 358 assertions, 1 failures, 1 errors, 0 skips
```

`VariantRotor#next_for_tick` now rejects only a repeated tick without advancing
its sequence (`src/app/audio_bridge.rb:169-173`), and each per-family bridge
subscription uses that result (`src/app/audio_bridge.rb:225-236`). The real
World regression keeps all three same-tick hit callbacks while observing a
flat `[2, 2, 2]` voice count: one still-playing special voice plus one hit
voice (`test/app/audio_bridge_test.rb:260-282`). The targeted post-fix run:

```text
14 runs, 362 assertions, 0 failures, 0 errors, 0 skips
```

### T-B

Exactly 13 rows now carry the short music duck: four hit takes, four dodge
takes, four throw takes, and one special. `AudioDuckDataTest` pins both the
shared envelope and unchanged −10 dB SFX bus (`test/app/audio_duck_data_test.rb:8-35`).
A direct parse counted `percussive=13 exact_ducks=13 bad=[] sfx_db=-10.0`.
The targeted data test passed `2 runs, 15 assertions`; the real-library bridge
test then passed with zero skips, proving `AudioData.load` accepted the live
tables and DLL/render graph.

### Gates

- Full project suite: **935 runs, 17,734 assertions, 0 failures, 0 errors, 0 skips**
  (pre-review baseline; hooks re-run the suite at each commit after the §6
  adjudication edits).
- Required netplay gate (bridge moved): `netplay_session`, two replays,
  **12/12 captures byte-identical**, structured vision verdict **PASS**,
  gate rc 0. Raw run log: `tmp/audio_polish_netplay_gate.log`; tracked critic
  receipt appended by the gate to `drafts/_gate-verdicts.log` at
  `20260820-164004`. The post-review edits (§6) touch data values, tests, and
  comments only — the lockstep-relevant bridge code is byte-identical to what
  the gate ran, so the gate receipt stands.
- Visual wall debt: none. No renderer, replay input, sim value, or player text
  changed; the netplay gate is the requested cross-seat determinism check.
- Fresh-context review: executed, verdict FAIL, adjudicated in §6; receipt
  `drafts/_audio-polish-review-20260820.md`.
- Owner ear-check: pending for both same-tick coalescing and the duck envelope;
  automated gates prove structure/timing, not taste. §6 adds the specific
  stinger-overlap listen item.

## 6. Fresh-eyes adjudication — the cross-depth duck collision

The reviewer's blocking finding, verified against the primary
(`game-two-audio/src/gta/audio_system.rb:276-286`, read this session): the
music bus now carries TWO duck depths (−12 dB stingers/wipe, −4 dB
percussive), and `apply_duck` is last-writer-wins on depth change plus an
UNCONDITIONAL `ds.release_frames = rule.release` overwrite — even on the
pure-hold-extension path.

Concrete failure the first draft shipped: stinger fires (−12 dB, ~0.55 s
window, 9600-frame release); any percussive cue lands inside that window
(near-certain in the combat a stinger announces) → music re-attacks UP from
−12 to −4 dB within 16.7 ms, and the draft's 4800-frame release would ALSO
have halved the stinger's return.

Adjudication (dev of record):

1. **Release half — FIXED in data.** All 13 percussive rows now carry
   `release_frames: 9600`, identical to the dramatic ducks (every music-bus
   duck row: 19/19). The unconditional overwrite becomes value-identical — a
   hit can no longer shorten a stinger/wipe release. Pinned by
   `test_every_music_duck_shares_one_release_length`. Cost: a lone percussive
   episode returns over 200 ms instead of 100 ms — accepted.
2. **Depth half — NOT expressible in data.** "Deeper duck wins while its
   window lives" is engine semantics. Making percussive −12 dB would slam
   music on every hit (rejected); removing percussive ducks abandons the
   owner's ask (rejected). The residual behavior ships: during a stinger/wipe
   window, the first percussive cue lifts music to −4 dB for the remainder of
   that window. Deterministic, identical on both seats, zero desync exposure
   (audio is a sink).
3. **Owner ear-check item (es-CR, for the queue):** en una pelea densa,
   cuando suena el aviso del BOSS o de un sello, ¿se siente que la música
   vuelve a subir demasiado pronto? Si la respuesta es sí → the fix is the
   recorded library increment below, not a data tweak.
4. **Library increment RECORDED (build only on owner word):** depth-aware duck
   arbitration in `game-two-audio` (`apply_duck` tracks the deepest live
   window per bus; a shallower request inside it extends nothing but never
   re-attacks upward). Queued beside stereo-ambient stems + region-acoustics.

Reviewer findings 2/3/5 closed same session: the duck data test is staged with
the commit; the payload-first trade carries a comment at the subscriber
(`src/app/audio_bridge.rb`); `test_variant_rotation_fires_real_cues_through_the_bus`
tightened to `assert_equal 1` — a second coalescing witness. Finding 4 stays a
named design trade for the owners' ears.
