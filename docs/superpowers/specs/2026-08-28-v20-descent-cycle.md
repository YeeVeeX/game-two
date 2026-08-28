# v20 spec — the descent cycle, first wave (2026-08-28)

STATUS: CLOSED at grill (owner-ratified live, s114). Law of the cycle:
`drafts/_v20-foundation-20260828.md` (RATIFIED-G complete; RATIFIED-J
async pending). This spec details the ratified lanes into tickets;
on disagreement the foundation wins. Tickets are the durable artifact
(grill-and-ticket law); each runs in its OWN fresh session, claims via
CHECKPOINT `CLAIMED:` line at start (s56 law), any seat may execute
any ticket (FULL SEAT SYMMETRY, owner order 2026-08-28).

## Decisions carried (pointers, not repeats)

Foundation L1-L14 + 4 council amendments. Non-goals: foundation L14.
Verification strategy: suite via hooks (every commit) + blocking
Rule 2 gate per visual change + canary versioned-rebank for intended
map changes + soak crossing for new zones + telemetry oracles for sim
pieces. No mocks in integration tests. All tunables in
`data/**/*.json` — zero balance constants in code.

## Standing constraints (bite every ticket)

- `src/game/world.rb` 1769/1800: the FIRST ticket materially touching
  it budgets the owed extraction (plain object) INSIDE its scope.
- Pilot-four zones (incl. district/district_two/low_quay) are importer
  emissions: author `authoring/pilot.ldtk` (+ sidecar) →
  `tools/import_ldtk.rb` → deliberate copy. NEVER hand-edit JSON
  (provenance test enforces).
- Save-chain law (foundation L9): live save never a migration guinea
  pig. No first-wave ticket touches save schema; the destination/HOME
  ticket (second wave, gated) carries its own migration row.
- EventBus events registered at first use; placeholder register
  everywhere (ZONE N / generic verbs; es-CR/pt-br localized functional
  labels only).
- Wall scripts live in `harness/scripts/` — a changed zone re-gates
  every script traversing it; `harness/run_wall.sh` runs DETACHED.

## FIRST WAVE — tickets

### T1 — Floor 1: ZONE 2 retheme to v2b (lane A; the first felt change)

- **Goal:** district becomes descent floor -1 per Junior's v2b ("dois
  espaços + 4 pontes", 52×88 portrait): two themed halves (west
  dry/dark camps · east mossy/alive clearing), impassable wall-ringed
  central chasm, exactly 4 bridges (key bridges guarded), diagonal
  flow SW entry → NE exit, 27 minions arena-grouped, 3-wide corridor
  standard (v1 mining), `floor: -1` metadata + palette per the
  darkening-with-depth rule. Existing transitions keep their
  ENDPOINTS (mouth = camp→district edge re-typed stairs_down/hole;
  district→district_two edge re-typed as the floor -1 → -2 hole
  family). INERT/gate semantics unchanged this ticket.
- **Source geometry:** Junior's sandbox zone-JSON (his machine,
  `Desktop/game-two-conceitos/`) = geometry PROOF; transcription goes
  through LDtk (either seat authors; his seat qualifies under
  symmetry — coordinate via CLAIMED line).
- **Files:** `authoring/pilot.ldtk` + district sidecar →
  `data/zones/district.json` (emission) · wall scripts touching
  district (`world_loop`, `low_quay_run` path check) · gate checks.
- **Verify:** `bundle exec rake` (provenance + fixpoint green) →
  `rake gate SCRIPT=harness/scripts/world_loop.json` + affected
  scripts → canary versioned-rebank (INTENDED change protocol,
  test/harness/sim_identity_canary_test.rb header) → `rake soak N=1`
  crossing floor -1 → capture reviewed (Rule 2 vision verdict PASS).
- **Done:** gates green + soak clean + capture verdict banked in a
  drafts/ ticket record + push.
- **Size guard:** ONE session. If the re-gate sweep threatens the
  window, land zone+suite first, run the wall re-pin DETACHED, bank
  verdicts in a follow-up commit same day.

### T2 — Progression band step 1: cap 12 + k re-price + standing script (lane B)

- **Goal:** `data/balance/progression.json` cap 10→12; k re-priced
  against the dwell target (working target: L10→11 and L11→12 each
  ~15-30 min at the measured 8-20k band — final k lands from the
  script's table, recorded in the ticket); promote the pacing math to
  `tools/pacing_table.rb` (reads progression.json + kill_xp, emits
  the hours-per-level table; run on every curve/cap touch — output
  pasted in every touching ticket's record). At-cap xp-pin arithmetic
  re-verified for cap 12 (projector invariant).
- **Files:** `data/balance/progression.json` · `tools/pacing_table.rb`
  (new) · progression tests (cap/pin rows).
- **Verify:** `bundle exec rake` + `ruby tools/pacing_table.rb`
  output recorded + a live-save COPY decode check (cap raise must not
  refuse the existing save: level=10 xp=644 loads under cap 12 —
  test on a copy, never the live file).
- **Done:** suite green + table banked + copy-decode proof + push.

### T3 — Potions identity + discoverability (lane B; candidate 1 v1 + R-A2 escalation)

- **Goal:** the provisions system becomes legible AS potions:
  (a) surface identity — locale strings (en/es/pt-br) rename
  provision surfaces to the potion register (functional dictionary
  words, placeholder law; human-facing-output checklist applies);
  (b) R-A2 escalation — bank BUY hint strip (the recorded owner-word
  full-wall re-pin, now executing); (c) afield USE legibility pass on
  the U/R verb cue. Telemetry wording may extend (post-verdict
  lift): sustain reasons{} pattern stays.
- **Files:** `data/strings/*.json` · strip/hint surfaces (renderer
  strings only — layout untouched) · `harness/gate_checks.json` rows.
- **Verify:** `bundle exec rake` → `rake gate` on bank-hub script +
  strip-visible scripts → **full-wall re-pin DETACHED**
  (`harness/run_wall.sh v20-t3`, ~35 scripts ~3h, poll by rc lines)
  → language critique (accuracy/presentation axes, blocking).
- **Done:** wall sweep rc=0 all scripts + critique PASS + push.
- **Order law:** T3 lands BEFORE T4 (foundation L4 amendment).

### T4 — Totem pilot on floor 1 (lane C; first SIM delta; world.rb extraction rides here)

- **Goal:** new station type `totem`: fixed-cadence AoE heal pulse at
  floor -1's contested center. ALL numbers data-driven
  (`data/balance/sustain.json` new block: cadence_ticks, radius,
  heal_amount — zero constants in code). EventBus event registered at
  first use (e.g. `:totem_pulse`). Telemetry: `totem heals=N` beside
  the sustain line (oracle wording extension, lifted). Pre-registered
  priced-flip condition DOCUMENTED in the ticket record (foundation
  L4). **L10 executes here:** station/sustain behavior extracted into
  a plain object (`src/game/` new file) — world.rb net lines DOWN,
  cap test stays green.
- **Files:** `src/game/` (new sustain/station object) · `world.rb`
  (seam only) · `data/balance/sustain.json` · `data/zones/district`
  totem placement (via importer — pilot.ldtk entity) · EventBus
  registry · integration test (real files: totem pulse heals a real
  damaged body on cadence).
- **Verify:** `bundle exec rake` (line caps + integration green) →
  `rake gate` floor-1 script (pulse visible: Rule 2 verdict) →
  `rake soak N=1` (bots cross totem ground; chain check clean) →
  NINETEENTH delta clock STARTS here (recorded in ticket).
- **Done:** all green + telemetry line observed in a scripted replay
  log + push.

### T5 — Second wall class (lane D rider; engine, small)

- **Goal:** `data/tiles.json` second `passability: wall` type +
  per-zone palette key + importer IntGrid mapping + renderer wall
  pass reads the render-ref (not the hardcoded `:wall` key) for the
  new glyph. Unblocks v3-fidelity deep floors (red inner wall +
  near-black bounds coexisting).
- **Files:** `data/tiles.json` · `tools/import_ldtk.rb` mapping ·
  `src/app/renderer.rb` (small touch) · tile/renderer tests.
- **Verify:** `bundle exec rake` → `rake gate` on a staged fixture
  zone exercising BOTH wall classes (strong-member affirmative read —
  the 2026-08-26 residual-tolerance lesson) → import→emit→import
  fixpoint green.
- **Done:** gate PASS with the two-wall capture verdict + push.

### T6 — B4 mercy-floor revisit (lane E; debt 1; data-only)

- **Goal:** the session-open revive/coin chore answered by the
  ratified data-only knob move: mercy floor context gate / spend pct
  re-read (B4 lane, verdict R-SO). ONE knob; values from
  `data/balance/death.json` family; no code.
- **Files:** `data/balance/` (one knob) + its test row.
- **Verify:** `bundle exec rake` + a scripted session-open replay
  showing the changed open state (telemetry/capture) + ticket record
  names the knob and the before/after.
- **Done:** suite + replay evidence + push. (Feel verdict = the
  NINETEENTH's job, delta-triggered.)

## SECOND WAVE (cut at T4/T5 close — outline only, not tickets yet)

Floors -2/-3 rethemes (v3 grammar deepest; cap 13/15 ride these with
new kinds + kill_xp rows) · C3 stance-verb + flee/engage co-tune
re-session (debt 2; J-6 input family) · destination/HOME single-row
decision (graph drawing + save migration law + cardinal sketch
reconciliation) · GM read-only rung (stretch) · city start (if
capacity). Each cuts against this spec's constraints at its own time.

## Review law (skill stage 4)

Every ticket's diff gets a fresh-eyes review in a context that did
not write it (headless scrubbed pi or the OTHER seat — symmetric
review is already live practice). Receipt lands beside the ticket
record in drafts/. A failed review blocks the next ticket in the
same lane.
