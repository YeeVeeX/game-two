# E3a capture contract — spec (2026-08-26, grill s81)

Owner-ratified v19 rider (foundation `drafts/_v19-foundation-20260822.md`
§Riders + ledger row 22, RATIFIED-G + RATIFIED-J 2026-08-22). FENCE,
ratified verbatim and binding on every ticket: **recording at session
end only, never during play, zero per-tick cost on either seat.**
Grill record (decisions D1–D14, forks + refusals):
`drafts/_e3a-capture-contract-grill-20260826.md`. Consumer-side
design input: `game-two-assets/docs/replay-capture-design.md` (their
§4 proposal, §9 open questions) + `docs/state-track-schema.md`
(draft-1). This spec is the game seat's pin — where it differs from
draft-1, this spec wins (their own resolution rule). Tickets at the
end are the durable execution artifact; one ticket = one fresh
session, owner-paced.

## 1. Purpose and scope

A **replay bundle** is the atom of runtime evidence: everything a
deterministic offline re-execution needs and nothing more. It serves
two ratified purposes: (a) the assets seat's runtime
temporal-question adjudication (their fifteen lettered items + x0),
consumed as state tracks recomposed repo-side; (b) OUR
desync-forensics black box (a desync end dumps the full input +
digest history that produced it).

**In scope (v1):** P1 scripted bundles (harness), P2 netplay
host-side dump-at-close, a headless bundle re-executor with a
double-run verification gate, and the Mode T state-track emitter
(schema version "1", §5).

**Out of scope / refused:** P3 solo live recorder (fence: per-tick
appends during live play are recording during play — grill D1;
reopening it is an owner decision, not a ticket) · sprite integration
(separate, unproposed owner decision — their design says the same) ·
any World/creature/renderer code change · any schedule promise to the
assets seat · re-adjudication of their banked verdicts · Mode F
changes (the existing capture path already serves it).

## 2. Bundle contract

One directory per bundle: `bundles/<bundle_id>/` — top-level,
**gitignored**, never under `data/` (a machine-written file inside
the fingerprint glob manufactures permanent handshake refusals — s55
finding; `bundles/` sits outside both the fingerprint and the
DataStore, satisfying the s55 twin law by construction — grill D2).
`bundle_id` = `<UTC yyyymmddThhmmssZ>_<mode>_<seed>`, mode ∈
`p1|p2` — mechanical, no lore.

Members:

| file | content |
|---|---|
| `manifest.json` | identity + member sha256s; WRITE-ONCE at production (grill D7) |
| `input_log.json` | per-tick seat-ordered consumed-mask arrays — byte-for-byte what `fold_input` saw (`src/net/session.rb:510` shape: `[m1, m2]`; seats=1 → `[m1]`). Ticks 0..D-1 pre-fill zeros are recorded (they ARE consumed masks) |
| `digest_chain.json` | the FULL `[[tick, md5], …]` chain at the recorded cadence (the Session's `@digest_log`; P1 builds the same via an attached `StateDigest`) — full chain, not just the end window: windowed verification localizes a divergence to one window (grill D4) — plus a `terminal` `[tick, md5]` snapshot-only digest at end-of-run (T1 amend, s83: windows close only at cadence boundaries, so trailing ticks would otherwise be covered by member sha256s alone; residual named in `harness/bundle_writer.rb`) |
| `preconditions.json` | constructor-time facts (§3) |
| `save.json` | P2 non-fresh only: the canonical save-facts bytes EXACTLY as SESSION carried them (`Game::SaveState` vocabulary; strict decode refuses NAMED on re-execution) |

`manifest.json` fields: `bundle_id`, `mode`, `produced_at` (UTC),
`producer` (tool identity + invocation line), `fingerprint_md5`
(**REQUIRED** — `Net::Fingerprint.tree_md5`, the EOL-normalized
handshake identity; re-execution refuses on mismatch, naming both
values), `game_commit` (best-effort `git rev-parse HEAD`, null when
unavailable, never load-bearing — a commit SHA lies about uncommitted
drift and autocrlf checkouts, the v17 W6 trap; grill D3),
`digest_version` (`Net::StateDigest::DIGEST_VERSION`), `digest_every`
(from `data/netplay.json` — the ONE cadence source), `seed`, `seats`,
`ticks_executed`, `end_reason` (P2: quit/desync/conn_lost/protocol),
`machine` (producing machine class — the consumer's intake manifest
records it; stated at the source instead of derived), `members`
(relpath → sha256).

Verification receipts (`verification.json`, §4) are separate files
written by the re-executor — the production manifest never mutates.

## 3. Preconditions

- **P2 (netplay):** `seats: 2`, seed = the handshake seed, save =
  fresh | the canonical bytes + md5 the SESSION message carried.
- **P1 (scripted):** `seats: 1`, seed = the script's, `scenario`,
  and the script's `start` object VERBATIM (`Harness.apply_start`
  staging — banked/progression/dead/zone/inscribed — is declarative,
  constructor-time, and flows through the same audited paths saves
  use; it is part of the recorded contract — grill D6).
- **Refusal class:** bundle emission from `harness/net/` scenes
  refuses NAMED in v1 — their frame-keyed mid-run sim pokes are not
  reproducible from masks + preconditions. P1 scope = single-world
  scenes driven purely by scripted input + `start`.

## 4. Producers, re-executor, verification

**P1 (ships in E3a-T1).** A script key `"bundle": true` on the
existing runner path (no dedicated scene — their open Q6): the runner
attaches a `StateDigest` to the world (cadence from
`data/netplay.json`), folds `[mask]` per executed tick
(`Protocol.mask` covers all 12 game actions — coop plays entirely
through masks), collects the chain, and writes the bundle at run end.
Offline tooling — zero live-play surface by construction.

**P2 (ships in E3a-T3).** At session end — ANY end reason — the HOST
serializes the already-retained lockstep queues + `@digest_log` +
handshake facts into a bundle. Env-gated **`GAME_BUNDLE_DUMP=1`**,
default OFF (`GAME_FRAME_PROBE` precedent: off = no branch in play;
the env is read once at the close seam). Host-side ONLY — the host
retains both seats' masks and the save canonical; the weak seat never
writes (S0-J2). A failed dump warns ONE line and never disturbs the
quit path or exit status (audio optional-by-law precedent).
Procedural law, same class as VIDEO_EVERY: the wall and the soak
never set the flag.

**Re-executor (ships in E3a-T1).** A HEADLESS harness tool (no Gosu —
World + StateDigest are pure sim; the suite's netplay perf lane
proves windowless ticking; recorded deviation from the foundation
sketch's "on the existing replay runner", defended in grill D9 — the
runner exists for pixels, Mode T needs none): load bundle → refuse on
fingerprint mismatch (NAMED, both values) → strict-decode save if
present (refusals NAMED) → construct `World(data, seed:, seats:,
save:)` → apply P1 `start` staging if present → per tick, feed
`SampledInput` masks from the log, folding digests at the recorded
cadence → compare the produced chain to the recorded chain.

**Verification gate:** TWO fresh re-executions; both chains must
equal each other AND the recorded chain (same-machine identity —
their §2.3 audit item 1, made the tool's own gate; grill D10).
Receipt `verification.json`: runs, verdict, first-divergent window if
red, fingerprint at verification, date. This receipt IS the
"producer's attestation" their intake gate names.

## 5. State track — schema version "1" (the open-Q1 pin)

Emitted ONLY by the re-executor (offline, from a verified bundle),
into the bundle dir: `tracks/<name>.json` + sidecar sha256. Draft-1
(`game-two-assets/docs/state-track-schema.md`) is adopted with four
corrections (grill D11); where this section differs from draft-1,
this section wins.

Top level:

```json
{
  "schema_version": "1",
  "class": "RUNTIME",
  "tick_ms": 16.67,
  "zone": "<world zone id>",
  "view": { "origin_px": [0, 0], "width": 96, "height": 64 },
  "constants": { "<kit>": { "step_frames": 13, "windup_frames": 5,
                             "active_frames": 4, "recovery_frames": 8 } },
  "creatures": [ { "name": "player_1", "faction": "pack", "kit": "striker" } ],
  "ticks": [ "…per-tick records, consecutive frames…" ],
  "provenance": { "class": "RUNTIME", "producer": "<tool identity>",
                   "bundle_id": "<id>", "statement": "<one line>" }
}
```

Corrections vs draft-1, each defended:

1. `schema_version` = `"1"`; `class` = `"RUNTIME"` always (their own
   definition: a track from re-executing a verified bundle; SYNTHETIC
   stays their repo's word for hand-built tracks).
2. `tick_ms` = **16.67** — `Net::Lockstep::TICK_MS` verbatim (the
   engine states no 16.666666 anywhere).
3. `constants` is **per-kit** (map kit → constants): combat.json
   carries SEVEN kits with their own timings; a flat block lies for
   any mixed-roster window. Selection rule, named: `step_frames` =
   `kits.<kit>.step_frames`; the three `*_frames` = the kit's
   **`attack` sub-object** (`kits.<kit>.attack.{windup,active,
   recovery}_frames` — attack-only is sufficient: the consumer's
   mapping refuses `unmapped-action-class` for specials by its own
   law). Denormalized from `data/balance/combat.json` at the bundle's
   fingerprint; the bundle stays authoritative and intake
   cross-checks. **Draft-1's `windup_px`/`active_px` are DROPPED from
   v1 constants** (review-gate finding, verified): they are not in
   combat.json — they are draw-side literals in the renderer's
   `lunge_offset` (`src/app/renderer.rb:879-886`), the headless
   emitter loads no renderer, and the consumer's declared mapping +
   their `render-reference.json` pin already carry the lunge model
   under their established re-pin discipline (one-way law preserved:
   no game tool ever reads an assets-repo manifest).
4. `provenance` gains `bundle_id` — a track never self-certifies; it
   names its bundle (their §5 law, made a field).

Per-tick record (draft-1 shape + one field):

```json
{
  "frame": 17,
  "creatures": {
    "player_1": {
      "tile_x": 1, "tile_y": 1, "px": 4.0, "py": 32.0,
      "facing": [1, 0], "tween_left": 11, "tween_total": 13,
      "attack_state": "idle", "current_action": null, "state_frames": 0,
      "hp": 80, "iframes": 0, "possessed": true
    }
  },
  "masks": { "1": 0 }
}
```

- **Adopted from draft-1 unchanged:** `frame`, `tile_x/tile_y`,
  `px/py`, `facing`, `tween_left/tween_total`, `attack_state`,
  `current_action`, `state_frames` (their parser finding is CORRECT —
  the banked timeline is positional and `attack_state` alone cannot
  index it mid-window; the counter is already digest-read
  engine-side), `hp`, `iframes`, `masks` (seat → int).
- **Added: `possessed`** (bool) — the possessed/controlled branch is
  a creature-draw read at HEAD, and "which body the human drove" is
  adjudication context their windows want.
- **Named exclusions (v1):** renderer badge/tint reads that are not
  pose inputs — `marked?`, `taunted_target`, `seized_by`,
  `retarget_cue`, `pressure_role`, `telegraphing?`, `hurt?` — every
  one is either derivable from carried fields or a badge overlay no
  banked frame question references. Extension = additive schema bump,
  game-seat-owned.
- **Windowed tracks are legal** (consecutive `frame` values from any
  start tick; `state_frames` makes mid-phase windows self-describing
  — their finding, adopted). The emitter takes an explicit tick range;
  windowed is the default posture (full-session tracks are legal but
  large — their storage call, open Q5).

## 6. Consumption mechanics + the fence restated

- Bundles/tracks are gitignored; digest-grounding for delivery =
  **manifest sha256s + the verification receipt**, not git blobs.
  Delivery = a MAIL naming the bundle path + manifest sha256; the
  assets seat reads this worktree read-only and copies into their
  `evidence/replay/<id>/` under their intake gate. Nothing game-side
  ever writes into their tree (seat-lease law); game-two never
  depends on their repo (one-way, both directions).
- Answers riding to their seat (their §9): **Q1** = §5. **Q2**:
  cross-machine framebuffer byte-identity is NOT promised — state
  tracks + digest chains anchor identity; Mode F byte-identity is a
  within-machine wall law. **Q3** = P1 + P2, P3 refused (fence).
  **Q4**: the adjudication display standard is ours (165 Hz primary),
  declared per verdict. **Q5**: theirs; size envelope above. **Q6**:
  runner flag + separate headless tool, no dedicated scene. **Q7**:
  stays parked (hub, later).
- The FENCE audit lives in the grill record (final section): no
  producer records during play; P2 adds no retention and no per-tick
  branch; all analysis is offline; no sim/renderer code moves in any
  ticket.

## 7. Tickets (each = one fresh session, runnable verify, owner-paced)

**E3a-T1 — P1 bundle emitter + headless re-executor + verification
receipt.** The atomic round-trip (an emitter without its verifier is
unverifiable — they ship together). Files: `harness/replay_runner.rb`
(the `bundle` script key), new `harness/bundle_writer.rb` +
`harness/bundle_replay.rb` (names indicative), `.gitignore`
(`bundles/`), `test/harness/bundle_roundtrip_test.rb` + a small
fixture under `test/fixtures/`. Verify: emit from
`harness/scripts/world_loop.json` with `bundle: true`; run the
re-executor twice; receipt PASS; a tampered mask byte flips it RED
(both directions exercised); `rake` green. Done when: receipt PASS +
tamper RED + suite green. No visual surface — critic calls 0.

**E3a-T2 — Mode T state-track emitter (schema "1").** Inside the
re-executor behind a flag + tick range. Files: the T1 tools +
`test/harness/state_track_test.rb` (leaf types, consecutive frames,
per-kit constants match combat.json at the fingerprint, RUNTIME
class + bundle_id provenance, windowed start mid-phase). Verify:
emit a windowed track from the T1 fixture bundle; schema tests green
(constants assertable for ALL schema fields — the px pair is out of
schema); `rake` green. Done when: a reference track + schema section MAIL to
the assets seat (their consumer adapts to the pin — their stated
posture). Critic calls 0.

**E3a-T3 — P2 netplay dump-at-close.** Files: the Session close seam
(`src/net/session.rb` — finish!/close path), `src/main.rb` or the
window close hook ONLY if the seam demands it (window.rb cap 300
watched), `test/net/` + a `harness/net/` scene proof. Verify: a
netplay scene run with `GAME_BUNDLE_DUMP=1` dumps a bundle whose
re-execution verifies via the T1 tool; with the env unset,
byte-identical session behavior (no dump, no new output line); a
simulated write failure warns one line and exit status is unchanged;
netplay gates ×3 re-run green (session/desync/conn_lost — the seam
touches Session). Done when: all four proofs recorded + suite green.
Critic calls 0 (no visual surface; the netplay gates' vision halves
are the standing mandated re-run, not visual-delta spend).

Budget across all tickets: council 0 · **zero visual-delta critic
spend** (T3's mandated netplay-gate re-runs keep their vision halves
— never SKIP_CRITIC for a shippable pass) · any visual delta
discovered mid-ticket = STOP, re-scope, declare (none is expected —
no renderer file is in any ticket's scope).
