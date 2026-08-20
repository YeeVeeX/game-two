# Audio polish fresh-eyes review receipt (2026-08-20)

Reviewer: scrubbed headless pi (no session, PI_* env removed), read-only over
the working-tree diff + evidence doc + untracked test + both repos' audio
sources. Prompt digest: md5 fe7ac78f3ac87168c7c01ef51f560e24; inputs
diff.patch md5 dbf326a0a3b26989028b18b14b8e1532, evidence.md md5
fea348a5b18b070a3db92944abf93458, new_test_file.rb md5
a867c62ecd916de815f3f0e63429a95a.

VERDICT: FAIL (finding 1 blocking). Dev-seat adjudication, same session:
finding 1 release-half FIXED in data (release 4800->9600 aligned, 19/19
music-bus ducks identical, pinned by test); depth-half recorded as library
increment + owner ear-check item (grill doc section 6). Findings 2/3/5 closed
(test staged, payload comment, ==1 tighten). Finding 4 stays a named trade.

--- verbatim reviewer output ---

# Audio polish fresh-eyes review — VERDICT: FAIL

Read with my own eyes: `src/app/audio_bridge.rb` (whole), `test/app/audio_bridge_test.rb`, `data/audio/{cues,variants,engine}.json`, `game-two-audio/src/gta/audio_system.rb`, `game-two-audio/src/gta/audio_data.rb`, the diff, evidence doc, and the untracked test. No repo writes, no suite run.

## Rubric

| Item | Verdict | Evidence |
|---|---|---|
| Pure-sink law | PASS | `next_for_tick` reads only `world.frame` (sim→audio); nothing flows back (`src/app/audio_bridge.rb:230-236`); pre-existing digest test untouched (`test/app/audio_bridge_test.rb`, `test_attached_bridge_is_sim_invisible`) |
| Rotor determinism / no desync | PASS | State advances only on fired takes (`src/app/audio_bridge.rb:169-173`); `@last_tick` nil-init (`:151`) makes tick 0 safe; both seats derive identical decisions from the identical lockstep (event, tick) stream; bus dispatch is FIFO + subscription-order (`src/core/event_bus.rb:48-57`) |
| `@last_tick` init + `prime()` interaction | PASS | `prime` touches `@last` only, never `@last_tick` (`:177-180`); per-event rotors are never primed — only `@rot_rotor` is, and it uses `next!` |
| Library law hold ≥ tick_frames | PASS | 2400 ≥ 800; validated at every real boot by `AudioData.validate_cues!` (`game-two-audio/src/gta/audio_data.rb:91-101`); release issues from `update()` at hold expiry, never in the past (`audio_system.rb:111-119`) |
| Two-depth duck interaction | **FAIL (disclosure)** | `apply_duck` (`audio_system.rb:276-287`): different depth ⇒ last-writer-wins re-attack (`:281-286`) and unconditional release overwrite (`:280`). See Finding 1 — deterministic, but audibly degrades the −12 dB dramatic ducks, and the evidence doc never analyzes it |
| Whirl regression test proves the claim | PASS | `test/app/audio_bridge_test.rb:257-283`. Oracle `[2,2,2]` is right: voice 1 = the still-live `msfx_special_600ms` (noDevice never renders, so `gta_sound_at_end` never fires and voices persist); voice 2 = the single coalesced hit take. Bridge subscribes before the test callback, so each callback reads post-bridge counts (subscription order, `event_bus.rb:38-57`); pre-fix red run `[2,3,4]` empirically confirms ordering. `hit_ticks` asserts 3 events / 1 tick — the precondition that makes the claim meaningful. Broken staging ⇒ `[1,1,1]`, broken coalescing ⇒ `[2,3,4]` — both caught |
| Smoke script | PASS | `SMOKE_SCRIPT` fires via direct `handle_event`, below the rotors — no coalescing interaction; contains no percussive events |
| Null bridge | PASS | Every seam no-op; untouched |
| `rot_rotor` uses `next!` | PASS | Fine: `rotate_music` is period-gated to at most one call per tick under the once-per-tick update contract, and `music_rotation` is currently DORMANT (absent from `variants.json`) — nothing to coalesce |
| `pack_wiped` keeps −12 dB | PASS | Coherent: wipe is classed with stingers ("wipe ducks music -12 dB like the stingers", `cues.json` _comment); the 13-row set deliberately excludes it, and the new test's predicate excludes `pack_wiped__` |
| New data test pins vs overfits | PASS | Count pin 13 forces a conscious decision on any future take add; exact-envelope equality is the point (single shared lever); the −10 dB SFX-bus assert pins the "one lever only" decision. Runs everywhere (needs no library). Right invariant, not overfit |
| data-driven law | PASS | All new tunables in `data/audio/cues.json`; no constants entered code |
| Language axes | N/A | No player-facing text in the diff — comments, JSON, test strings, and the gate-appended log are all dev-facing. Accuracy of the dev-facing evidence doc is scored under Finding 1; presentation of the doc is otherwise good |

## Findings

1. **BLOCKING — cross-depth duck interaction is real, live, and undisclosed.** This change creates the first cross-depth pair on the music bus. `apply_duck` keeps `duck_end` as a max but re-attacks whenever depth differs (`audio_system.rb:279-286`) and overwrites `release_frames` unconditionally (`:280`). Concrete sequence: `challenger_engaged` fires (−12 dB, window 2400+24000 = 26400 frames ≈ 0.55 s, release 9600); any of the 13 new percussive cues lands inside that window — near-certain in the combat that stingers announce — and music re-attacks **up** from −12 to −4 dB in 800 frames, sits at −4 for the remainder of the stinger's window (max() keeps the far end), then releases over the hit's 4800 frames instead of 9600. Dense combat structurally clamps the dramatic carve to −4 dB; same for `seal_breached` and (rarely, post-death) `pack_wiped`. The evidence doc (§3.1–3.2) cites only same-depth "pure hold extension… exactly the library's proven overlap behavior" — true within the new −4 dB family, silent on the one interaction the change makes live. The increment's own contract ("must preserve that approved overall balance") is exactly what this can violate, and the owner ear-check won't reliably hit the overlap unless told to listen for it. Remedy is cheap, not code: name the hazard honestly in the evidence doc + put "stinger during combat" on the ear-check list, or align the data (accepting/matching depths) — dev-of-record's call, but it must be adjudicated, not omitted.
2. **LOW — `test/app/audio_duck_data_test.rb` is untracked** (`git status`: `??`). Local `rake` runs it (Rakefile glob `test/**/*_test.rb`), so hooks pass whether or not it's staged — forget `git add` and the T-B pin silently never ships. Stage it explicitly with the commit.
3. **LOW — first-event-in-batch payload wins under coalescing.** The coalesced subscriber forwards the first event's payload only (`audio_bridge.rb:233-235`). Moot today (v1 cues non-spatial, payload deliberately unread) but becomes a real choice when spatial variants land; a one-line comment at the subscriber would inoculate future readers.
4. **INFO — same-tick multi-source merge is a design trade, correctly named.** Two coop seats landing hits on one tick, or a multi-projectile volley, now produce one family sound. Evidence §2.4 owns this as presentation density; deterministic and identical on both seats. Owner ear-check adjudicates taste.
5. **INFO — pre-existing `test_variant_rotation_fires_real_cues_through_the_bus` quietly changed meaning:** its 3 same-frame emits now start 1 voice, not 3; the `>= 1` assertion still holds so it stays green. Tightening to `== 1` would make it a second coalescing witness — optional.
6. **INFO — red-first discipline verified in evidence:** pre-fix failure output shows both seams red (`NoMethodError: next_for_tick`, `[2,3,4]` vs `[2,2,2]`) before production code moved; the `drafts/_gate-verdicts.log` hunk matches the claimed netplay gate receipt (20260820-164004).

## Explicit statements required by the brief

**Two-depth duck:** the ordering hazard is **fully deterministic** — single control thread, FIFO event queue, fixed subscription order, so both lockstep seats and every replay emit byte-identical fade command streams; there is **no desync risk** (audio is a sink regardless). It **can sound wrong**: a −4 dB percussive cue inside a live −12 dB stinger/wipe window lifts music +8 dB mid-hold within 16.7 ms and shortens the release from 9600 to 4800 frames — the dramatic duck is effectively disabled during exactly the combat moments that trigger it.

**Rotor determinism:** `next_for_tick` cannot desync seats. Coalescing is a pure function of (family, tick) presence in the lockstep event stream; the rotor sequence advances only on fired takes, so both seats sample the same deterministic sequence; `@last_tick = nil` init fires correctly on tick 0; `prime()` is orthogonal (touches `@last` only, and is never called on per-event rotors). The unit test proves non-consumption against a twin rotor; the whirl test proves it end-to-end through a real World and the real DLL.

FAIL — Finding 1: the live −4 dB/−12 dB cross-depth duck interaction is an undisclosed audible regression risk on an owner-approved surface; ship after the evidence doc names it and it lands on the owner ear-check list (no code change required unless the owner rejects the behavior). Also stage the untracked test (Finding 2).
