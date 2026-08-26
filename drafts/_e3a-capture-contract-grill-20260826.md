# E3a capture-contract — grill record (s81, 2026-08-26)

Head item per s80 queue. Foundation rider row (RATIFIED-G + RATIFIED-J,
ledger row 22): session-end recording bundle + offline state-track
re-execution; FENCE ratified verbatim: "recording at session end only,
never during play, zero per-tick cost on either seat." Assets seat
waiting since their v12 design mail (2026-08-20); their v27 close
flagged the SIXTH empty-inbox close. Budget declared at start: docs
lane only — council 0, gate critic calls 0, no code, no captures; stop
early on fence violation or owner redirect.

Primary sources read this session (grounding):

- foundation rider row: `drafts/_v19-foundation-20260822.md` §Riders
  (build shape + fence + owner verbatim).
- assets v12 design: `game-two-assets/docs/replay-capture-design.md`
  (their §4 contract proposal, §9 open questions 1–7, council appendix).
- assets draft schema: `game-two-assets/docs/state-track-schema.md`
  (draft-1; their reference consumer reads it today; "the game seat
  pins the schema — disagreements resolve in the game seat's favor").
- assets v27 mail (`done/from-game-two-assets-v27-repin-note.md`): lane
  armed, branches on spec arrival.
- s40 receipt (checkpoint): "their open-Q1 field list pinned by us at
  tool-spec time" — that receipt comes due HERE.
- s55 twin law (`drafts/_s55-close-20260823.md` + `src/net/fingerprint.rb:20-24`
  + `src/core/data_store.rb:19-22`): the next machine-written file lands
  in BOTH lists or repeats the gap.
- engine at `f88a24a`: `src/net/lockstep.rb` (queues retain consumed
  slots; TICK_MS), `src/net/session.rb` (:510 fold_input shape, :513
  @digest_log, conclude/finish), `src/net/state_digest.rb`
  (DIGEST_VERSION 3, canonical form), `src/net/protocol.rb` (ACTIONS
  12 bits, mask), `src/net/fingerprint.rb` (tree_md5 globs
  `src/**/*.rb + data/** + Gemfile.lock`, EOL-normalized),
  `src/main.rb` (seed lines, save canonical path),
  `harness/replay_runner.rb` + `harness/scenes/world_scene.rb` +
  `harness/support.rb` (apply_start staging surface),
  `data/netplay.json` (digest_every 60), `data/balance/combat.json`
  (SEVEN kits, per-kit step/attack timings), `src/app/renderer.rb`
  draw_creature reads at HEAD (badges beyond the assets pin),
  `.gitignore`.

## Decisions (the grill)

**D1 — v1 scope = P1 + P2 + headless re-executor + Mode T emitter.**
Their design's producer menu grilled against the ratified fence:

- **P1 scripted bundles: IN** (the primitive exists; missing only
  digest emission + packaging). All fifteen lettered questions are
  P1-answerable per their own design.
- **P2 netplay dump-at-close: IN** — this IS the ratified build shape
  ("from the already-retained lockstep queues"). Retention pre-exists
  (`lockstep.rb:117-119` consumed slots stay; `session.rb:513` digest
  log) — zero added per-tick work, one close-time write.
- **P3 solo live recorder: REFUSED for E3a.** The fence's plain
  reading kills it: a per-tick append during live play is recording
  DURING play, whatever it costs. Their design itself ranked P3
  "ecological-validity gravy only". Consequence named honestly: solo
  live sessions produce no bundles in v1; controlled stimulus = P1,
  coop forensics = P2. Reopening P3 = a NEW owner decision against the
  fence wording, not a ticket.

**D2 — bundles land in `bundles/<bundle_id>/`, top-level, GITIGNORED —
never under `data/`.** The s55 twin law names E3a explicitly; the
grill's answer is structural: `Fingerprint.tree_md5` globs `data/**`,
so ANY machine-written file there is a permanent-refusal factory (a
gitignored file can never be equalized by git pull — the s55 finding).
`bundles/` sits outside the fingerprint glob AND outside the
DataStore, so the twin law is satisfied by construction — nothing to
add to either list, and the comment cross-reference stays true. Same
class as `captures/` and `saves/`. Suite fixtures (one small committed
bundle for round-trip tests) live under `test/fixtures/` — test data,
outside both surfaces.

**D3 — re-execution identity = the FINGERPRINT, not the commit SHA.**
Strengthens their §4 field 1. A commit SHA lies twice: uncommitted
drift runs under a clean-sounding SHA, and autocrlf checkouts of the
SAME commit differ byte-wise (the v17 W6 live trap — fingerprint is
EOL-normalized for exactly this). Manifest carries
`fingerprint_md5` REQUIRED (the handshake identity, engine-computable
offline) + `game_commit` best-effort provenance (null when
unavailable; never load-bearing). The re-executor REFUSES on
fingerprint mismatch, names both values (handshake-refusal register).

**D4 — the digest chain rides whole, not just the end window.** The
Session already retains `[[tick, md5], …]` (`@digest_log`); their
contract's field 5 called the full chain "optional". Windowed
verification localizes a divergence to one 60-tick window for free —
the desync-forensics half of the ratified purpose. P1 builds the same
chain by attaching a `StateDigest` at cadence `digest_every` from
`data/netplay.json` (ONE cadence source; a bundle records its value).

**D5 — input log = per-tick seat-ordered mask arrays, exactly what
`fold_input` sees** (`session.rb:510` folds `[masks[1], masks[2]]`).
Seats=1 folds `[m1]` — same law, shorter row. Ticks 0..D-1 pre-fill
masks ARE consumed masks (by-definition empties) and are recorded.
One JSON file (array-of-arrays indexed by tick): ~36k-tick ritual
session ≈ sub-MB. Protocol coverage verified: ACTIONS = 12 bits, all
game verbs; coop plays entirely through masks, so masks are faithful
for anything a World can be driven by.

**D6 — preconditions = constructor-time facts, verbatim.** P2: seats,
seed (handshake), save canonical bytes + md5 EXACTLY as SESSION
carried them (the SaveState vocabulary — decode refusals stay NAMED).
P1: seats=1, seed, scenario + the script's `start` object VERBATIM
(`apply_start` staging — banked/progression/dead/zone/inscribed — is
declarative, constructor-time, and replays through the same audited
paths saves use; it is PART of the recorded contract, not a refusal
class). Mid-run sim pokes (the netplay scenes' frame-keyed staging)
are NOT reproducible from masks — bundle emission is scoped to
`harness/scripts/` world scenes in v1; harness/net scenes refuse
NAMED.

**D7 — manifest is write-once; verification receipts are separate
files.** Production writes `manifest.json` (identity + member sha256s
+ producer identity/invocation) exactly once. The re-executor writes
`verification.json` beside it. Their intake gate wants "a local
re-verification by the game seat recorded as the producer's
attestation" — the receipt IS that attestation, and the production
manifest never mutates (no self-certifying edits).

**D8 — P2 hook: session end, env-gated `GAME_BUNDLE_DUMP=1`, default
OFF, HOST-side only, all end reasons.** Host retains both seats'
masks + the save canonical — the weak seat writes nothing, ever
(S0-J2, their council Q2 adoption). Dumps fire on quit AND
desync/conn_lost/protocol — a desync bundle is the black box the
foundation names. A failed dump write warns one line and never
disturbs the quit path or exit status (audio optional-by-law
precedent). Procedural law, same class as VIDEO_EVERY: the wall and
the soak never set the flag (a soak episode must not grow bundle
side-effects; chain_check's file-count laws stay untouched).

**D9 — the re-executor is HEADLESS (no Gosu).** World + StateDigest
are pure sim; the suite's netplay perf lane ticks two sims + wire in
one process windowless. The foundation sketch said "on the existing
replay runner" — recorded deviation, defended: the replay runner
exists for PIXELS (Mode F, needs a live GL context); Mode T needs
none. Mode F stays on the existing runner path unchanged. Fence
unaffected either way (offline both ways).

**D10 — verification = double re-execution.** Two fresh re-executions:
chains equal each other AND the recorded chain (their §2.3 audit item
1, made the tool's own gate). Receipt records runs, verdict,
fingerprint, date. Byte-unstable-text-frame law (2026-08-25 memory)
is about PIXELS — digest chains are sim-only and carry no such
caveat.

**D11 — schema pinned as version "1"** (their open Q1; full shape in
the spec §5). Draft-1 adopted with four corrections, each defended:

1. `tick_ms` = **16.67** (`Lockstep::TICK_MS` verbatim — the engine's
   pinned constant; draft-1's 16.666666 is a value the engine never
   states).
2. `constants` is **per-kit** — combat.json carries SEVEN kits with
   their own `step_frames`/attack timings; draft-1's flat block
   assumed one kit and would lie for any mixed-roster window.
   Selection rule pinned in the spec: `step_frames` + the kit's
   ATTACK sub-object timings. Draft-1's `windup_px`/`active_px`
   DROPPED from v1 (review-gate finding, re-verified live: absent
   from combat.json, present only as renderer `lunge_offset` literals
   — a headless emitter loads no renderer, and the consumer's mapping
   + render-reference pin already carry the lunge model).
3. Per-creature adds **`possessed`** (bool): the renderer's
   possessed/controlled branch is a creature-draw read at HEAD
   (renderer.rb draw_creature), and "which body the human drove" is
   adjudication context their windows want anyway.
4. Our emitter always writes **`class: "RUNTIME"`** — by their own
   definition (tracks from re-executing a verified bundle);
   SYNTHETIC stays their repo's word for hand-built tracks.

**Named exclusions** (sufficiency criterion scoped, not papered):
renderer badge/tint reads at HEAD that are NOT pose inputs — `marked?`,
`taunted_target`, `seized_by`, `retarget_cue`, `pressure_role`,
`telegraphing?`, `hurt?` — stay OUT of v1: every one is either
derivable from carried fields (hurt/iframes from hp + iframes), or a
badge overlay the banked frame questions never reference. Additive
schema bump if ever needed; game-seat-owned. Their `state_frames`
addition ADOPTED (their parser finding is correct: attack_state alone
cannot index a positional timeline mid-window; the counter is already
digest-read engine-side). Windowed tracks legal from any start tick
for the same reason.

**D12 — their open questions 2–7, answered in the spec:** Q2
framebuffer cross-machine identity NOT promised (tracks + digests
anchor; Mode F byte-identity is a within-machine wall law). Q3 = D1.
Q4 display standard: ours (165 Hz primary), declared per verdict. Q5
LFS budget theirs; we bound sizes (windowed tracks default — emitter
takes an explicit tick range; full-session tracks legal but large).
Q6 = runner flag on the existing WorldScene path + separate headless
tool, no dedicated scene. Q7 live-rate re-runs stay parked (hub,
later).

**D13 — consumption mechanics (seat-lease-shaped).** Bundles are
gitignored, so digest-grounding for delivery = manifest sha256s +
verification receipt, not git blobs. Delivery = a MAIL naming bundle
path + manifest sha256; their seat reads our worktree read-only and
copies into their `evidence/replay/<id>/` under their intake gate.
Nothing here ever writes into their tree; game-two never depends on
their repo (one-way law, both directions of the fence restated in the
spec).

**D14 — tickets = 3** (each one session, each with a runnable verify;
spec §7): T1 P1 emitter + headless re-executor + receipt (the atomic
round-trip — an emitter without its verifier is unverifiable by
construction, so they ship together); T2 Mode T emitter + schema
tests + reference track mailed; T3 P2 dump-at-close + netplay-scene
proof. Implementation owner-paced (sequence-unblocked: all four lanes
have first ships).

## Fence audit (the STOP condition, checked last)

Zero per-tick cost: P1/re-executor/Mode T are offline tools; P2 adds
no retention (pre-existing), no per-tick branch (env read once at
session end), one close-time write, host-side. Session-end only: no
producer records during play. No sim surface: no World/creature/
renderer code changes anywhere in the tickets — harness + net-session
close seam + new offline tools only. Nothing violates the ratified
fence; no re-scope needed.

## Review gate (skill stage 4 — fresh-eyes, Rule 6)

Headless scrubbed-env pi review (author-independent), brief =
`tmp/s81_e3a_review_brief.txt`, two-way alignment rubric (fence /
build shape / s55 twin law / all seven consumer questions / intake
needs ↔ every spec decision traced or flagged-deviation). Verdict:
**PASS, 0 blockers, 1 major, 3 minors** — all four applied before
mail:

- MAJOR (re-verified live before acting): §5 claimed
  `windup_px`/`active_px` denormalize from combat.json — FALSE (they
  are renderer `lunge_offset` literals, `src/app/renderer.rb:879-886`;
  combat.json kits carry `step_frames` + per-action sub-objects
  only). Fix: px pair dropped from v1 schema constants; selection
  rule (ATTACK sub-object) named; T2's verify now assertable for all
  schema fields; one-way law preserved (no game tool reads an
  assets-repo manifest).
- Minors: manifest gains `machine` (producing machine class); the
  constants selection rule named (above); ticket budget rephrased to
  "zero visual-delta critic spend" so T3's mandated netplay-gate
  vision halves are never confused with skippable spend.

Verdict JSON (from the reviewer's final message, verbatim verdict
line): `{"verdict": "PASS", "blockers": []}` + the four findings
above; raw output `tmp/s81_e3a_review_out.txt` (tmp/, ephemeral —
findings preserved here).
