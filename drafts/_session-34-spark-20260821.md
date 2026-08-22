# SPARK sesión 34 — harvest-first support + seal GATING grill (review nit 1, once-RECORDED: does a seal owe a gated way?); shared-save first crossing still loaded; v19 waits at the brainstorm

You are the dev of record in game-two (cwd `~/workspace/game-two`). Read
`AGENTS.md` FIRST (rule 8) — the live file beats this spark on any drift.
Ruby per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`. Working language
English; owner surfaces es-CR ustedeo (everyday gamer words — never the
foreclosure register); Junior surfaces pt-br. Quality over cost: council 0
(no design fork is open); paid calls 0 by default — TWO named exceptions
only: J1's defect branch (real-data fix owes its wall gates) and any
override lane that ships a gated change. Evidence-first: claims are not
evidence — file:line, log line, or UNVERIFIED tag. Bot lines are never
fun/oracle evidence.

## Program state (2026-08-21 session-33 close — verify live)

- v18 CLOSED · **v19 NOT open** (brainstorm at the owners' word; agenda:
  `drafts/_v19-intake-docket-20260820.md`; prep
  `drafts/_v19-brainstorm-prep-20260821.md`, one named SHELF GAP:
  companion/ally AI).
- **s33 shipped the seal `opens` law** (`4f74e33`, reviewed
  PASS-WITH-NITS, pushed): `TileMap#validate_seal_opens!` refuses NAMED
  (BadMap) at zone load when a seal's `opens` is ill-shaped (shape via
  `tile_pair?` — the s32 predicate extracted, ONE copy shared with
  `check_passable!`), out of bounds, or names NO transition (the seal
  that burned tolls, opened nothing, and poisoned the save —
  `restore_breach!` persisting `[zone, nil]` which SaveState refuses at
  next load). Shape → bounds → semantics, distinct messages. Suite
  1011→1018, zero data/fixture trips (3/3 real seals pre-scanned LEGAL
  twice). Importer: zero changes owed — `validate_emitted!` round-trips
  through `TileMap.new`, the door composes the law. Ticket:
  `drafts/_s33-seal-opens-20260821.md`.
- **Review nit 1 RECORDED (once), not built:** the guard does not
  require the named transition to be GATED — a seal pointing at an
  always-open way still loads and burns tolls as a visible no-op
  (`Crossing#open?` already true pre-breach). All 3 shipped seals point
  at `sealed: true` ways. Carries a REAL design question (grill before
  code): is a seal onto a `requires_defeats` fact-gated (unsealed)
  transition legal authoring? That's J1.
- **THE FIRST HUMAN GATE CROSSING LANDED at s32** (Junior, HIS solo live
  save, `8478cde`; verbatim "me senti em uma nova fase e com meu
  objetivo concluido"). **The SHARED save on THIS machine is UNMOVED**
  (md5 `98fe75ed…`) — Gabriel's/coop's own crossing is still ahead; its
  verbatims are still fun-lane gold when they land.
- **world.rb sits at EXACTLY 1800/1800 — ZERO headroom.** ANY net
  growth fails `line_caps_test`; the next material world.rb touch owes
  its own extraction (Crossing precedent, s31). J1 below is Core/data
  only.
- **Owner-pending (never nag):** ear-checks + audio-v12 batch · T3
  footstep/bed renders (frozen cue-spec mail, audio-seat inbox) · coop
  S1 invite (BOTH seats re-declared READY; Junior's seat has the gate
  crossed) · the v19 brainstorm.
- **R-A2 measure (silent, NEVER prime):** still `bought=0`/absent on
  every banked live-world HUMAN log. Harvest `TELEMETRY sustain` from
  every NEW human launcher log; never mention economy/provisions to the
  owners.

## Job 0 — standing gate (~10 min; anything moved = classify in writing FIRST)

Baselines at staging: origin/main tip = the s34 spark commit — `git log
--oneline -3` reads: that commit · s33 docs commit · `4f74e33` s33 feat.
Save `saves/world.json` md5 `98fe75edb6d72deab18cd48eaa88bdaf` mtime
08-20 15:51 (banked=7 provisions=0 seals=2 sessions=13 boss_1_defeats=1
home=camp) · launcher logs **40×2** (`$TEMP` + `/tmp`, pattern
`game_two_session_*.log`; newest 08-21 01:39 — already counted) · seat
mail at `~/.pi/agent/mail/`: `game-two/` inbox EMPTY done/=22,
`game-two-audio/` holds the unanswered T3 cue-spec (FROZEN — never
reply-ask) · tmp/soak newest `20260820-232208` · untracked
`drafts/_refs/` only · `tmp/pilot_walk/world.json` = local scratch
world (sessions=1 banked=20 home=zone_7; never delete, never play it) ·
coop S1 evidence dir `drafts/_lag-t2-evidence/` = README only. Known
ignored leftovers (NOT deltas): `captures/map/world_41a9683d_*.png` ·
`tmp/s30_review_out.txt` · `tmp/s31_diff.txt` ·
`tmp/s31_review_prompt.txt` · `tmp/s31_review_out.txt` ·
`tmp/s32_review_prompt.txt` · `tmp/s32_review_out.txt` ·
`tmp/s33_review_prompt.txt` · `tmp/s33_review_out.txt`.
EXPECTED deltas (classify, then proceed): **live save moved + sessions
up** = the owners walked THE SHARED SAVE (J2 harvest — the first
crossing on THIS world; verify digest chain log↔save; arrival [2,14] /
return [43,19] per the s30 pin; their verbatims = fun-lane gold, bank
QUOTES) · new human launcher logs (harvest silently) · **Junior
commits/bank** (coop S1 report, new findings, or ear-check relays —
read BEFORE rebasing; re-verify cited hashes after any rebase;
patch-id proves a reviewed diff survived, s32 precedent) · audio
receipt / assets re-pin mail (archive, never reply-ask) · coop S1
artifacts (override lane below). `git pull --ff-only` FIRST.
Single-instance guard before any launch (separate call, judged by
printed output). `--fresh` NEVER.

**Ordering law for this session:** deltas landed (owner play or Junior
bank) → J2/J3 harvest+adjudicate FIRST (docs-only, fast), THEN J1. If
a harvested log shows a crossing landed WRONG (bad tile, wrong zone,
crash at a gate), J1 pivots to that defect's reproduction lane
(classify + owner chat) before any grill. No deltas → J1 → docs close,
stop.

## GATE 0 OVERRIDE — any live owner order preempts this whole queue

- **Ear-check verdicts** = LAW: bank verbatim, route per the checkpoint
  questions; stinger-overlap failure → depth-aware-duck grilled in
  game-two-audio, never a data tweak here.
- **T3/T4 renders landing** → sha-pinned fixture conversion (v1.1
  pattern) + data-only rows + suite + noDevice re-walk + one es-CR
  ear-check line. Water family needs a NEW cue-spec mail — the sent one
  is FROZEN.
- **A live coop session = lag segment S1**: support + harvest verbatim
  per `drafts/_lag-t2-evidence/README.md`; BOTH seats at the s34 tip
  first (mixed builds refuse NAMED; exit 2 = auto-rehost/rejoin).
- **The v19 brainstorm opening in chat** = it takes over as THE session:
  facilitate from the intake docket + the prep doc (pointers only; the
  dev proposes LIVE with touchstones, `hub kb query --domain
  game-research`), ONE candidate at a time, owners decide, one recorded
  line each; output `drafts/_v19-foundation-<date>.md` + AGENTS rewrite
  only after BOTH ratify. NO CODE in the brainstorm.

## J1 — seal GATING grill: decide with evidence whether a seal owes a GATED way (ship ONLY on a tighten verdict)

**Provenance:** s33 fresh-eyes review nit 1, RECORDED in
`drafts/_s33-seal-opens-20260821.md` §Review receipt + §Scope refusals
(once-recorded; s31 precedent allows once-recorded promotion when the
extension is natural — but THIS one carries an open design question, so
the grill comes first and NO-SHIP is a legitimate outcome).

**The question, grounded:** `validate_seal_opens!` requires a seal's
`opens` to name a transition — but not a GATED one. A seal pointing at
an always-open way loads clean and burns tolls as a visible no-op
(`Crossing#open?` true pre-breach; the breach fact would be recorded
and meaningless). All 3 shipped seals point at `sealed: true` ways
(reviewer-verified). The T5 ratified edge uses `requires_defeats`
WITHOUT `sealed` — so the grill must answer: (a) must a seal's way
carry `sealed: true` exactly? (b) is a seal onto a fact-gated
(`requires_defeats`) unsealed way meaningful or a data bug? (c) is a
seal onto `stairs_unlocked_by` machinery reachable at all? Read
`src/game/crossing.rb` (`open?`, breach-fact keying), `interact_seal`
(world.rb ~1321), `restore_breach!`, and the three shipped seals before
answering. Cite file:line for every claim.

**Outcomes (both legitimate):**
- **TIGHTEN:** the grill concludes a transition-less-GATE seal is
  always-a-bug → extend `validate_seal_opens!` (Core only, same
  discipline end-to-end: fixture/data pre-scan with a throwaway script
  BEFORE code · message-asserted tests per mode + legal control · one
  one-concern commit · fresh-eyes scrubbed review ("touch NOTHING,
  including seat mail"; audit the mail dir after) · push · no Rule-2
  gate owed if zero visual surface moves — state it in the commit
  body). If REAL data trips → DEFECT BRANCH (classify + owner chat
  BEFORE fixing; wall gates owed if live-zone bytes move).
- **NO-SHIP:** the grill concludes ungated-way seals are legitimate
  authoring space (or the question is v19-class design) → RECORD the
  decision + reasoning in the ticket, ship nothing, done. Never build
  "just in case".

**OUT of scope (RECORD if tempted, never build):** runtime
`interact_seal` changes · breach/save semantics · importer changes ·
world.rb · any sim-class behavior. Ticket either way:
`drafts/_s34-seal-gating-<date>.md` — provenance, the grill (evidence
per claim), verdict, what shipped or why nothing did, suite counts if
code moved, review receipt if code moved, scope refusals.

## J2 — IF the owners walked the SHARED save: harvest (ZERO code by default)

Every NEW human launcher log → ONE note
`drafts/_s34-live-harvest-<date>.md`: log md5 + `TELEMETRY persist`
(digest chain + sessions; chain-anchor against the save) · **the
crossing check** (their earned `boss_1_defeats: 1` opens low_quay
[44,19] → zone_7 [2,14]; return [1,14] → [43,19] free — a mismatch is a
live defect, classify + owner chat) · `TELEMETRY varekka`
(dread-exposure row — Junior's baseline is banked to compare against) ·
`TELEMETRY sustain` (R-A2, silent) · `AUDIO ambience` keys (amb_town on
zone_7 is the live signature) · `AUDIO drift` · any `frame_probe`
(over100-spike watch: the s32 caveat row). Their chat verbatims about
the gate moment = fun-lane evidence, QUOTES not summaries. Watch items
(route, never patch): wayfinding to the corner · ambush-feel at return
[43,19] · wipe near the gate · toll/economy wishes (bank silently) ·
TOWN 1 emptiness reactions (feeds the docket's TOWN 1 v0 row).

## J3 — IF Junior banked again: harvest (his lane, never edit)

Likely classes: coop S1 report (route per the override lane +
`drafts/_lag-t2-evidence/README.md`) · new solo findings (docket rows,
one-line pointers) · ear-check relays from Gabriel's session (bank
verbatim, route per checkpoint questions) · over100-spike data (the s32
caveat row — if he banks a probe with period max spikes, attach to that
row; NO fix-stacking without a mechanical A/B first, s29 law).

## J4 — docs close

Checkpoint entry (s34) · docket rows where verdicts landed (pointers) ·
AGENTS one-liner ONLY if a verdict landed · commit docs + push. Honest
no-delta lines for whatever stayed pending. Author the s35 spark at
close (house pattern), commit it, clipboard it for the owner via the
verified CF_UNICODETEXT recipe (python ctypes, restype/argtypes pinned,
read-back vs SOURCE string).

## Laws that bite (short list)

- Deterministic gates decide; failed gate/critique BLOCKS ship — never
  downgraded. Presentation never mutates sim; audio pure sink; replays
  deterministic by tick count.
- Read-before-edit · one-concern commits, explicit paths (never `git
  add -A`) · hooks run the suite (~60 s/commit; pre-push re-runs) ·
  long jobs DETACHED (nohup + poll; NEVER under a bash-call timeout) ·
  JSON edits surgical · multi-line scripts in temp files, never inline
  heredocs.
- **world.rb = 1800/1800.** Any net growth fails line_caps_test —
  extract-on-touch into a plain object (Crossing precedent, s31) or
  don't touch it.
- Two instances fork a save — guard EVERY launch in a separate call
  judged by printed output; re-guard after Start-Process (~40 s ruby
  lag). Freeze ALL code/data edits while any sweep/replay runs.
- Junior's lane (`drafts/_junior-*`, docs/JUNIOR.md) is his — harvest,
  never edit. Owner overrides are law — one line, never re-litigated.
  No lore; placeholders only; es-CR everyday words in owner lines.
- Cross-repo: read siblings freely, write ONLY via seat mail at
  `~/.pi/agent/mail/<repo>/` (+ RECEIPT lines); never write into a held
  seat. Sub-agent prompts forbid seat-mail handling; audit the mail dir
  after every sub-agent run.
- Verbatim means verbatim; partial evidence = bank + name the gap.
  A rebase over a peer's push rewrites local hashes — re-verify after
  (patch-id, s32 precedent).
- **Sim-class anything** (tile behaviors, spawn logic, AI, balance,
  economy) → RECORDED for v19, refuse in writing.

## Budget + stop conditions

One attended session ~2-3 h. Council 0. Paid calls 0 — the ONLY
exceptions are J1's defect branch and an override lane shipping a gated
change. Sub-agents: the fresh-eyes reviewer for J1's commit (ONLY if
the tighten verdict ships code), nothing else. Context guard 85% →
compact-checkpoint skill.
**Stop when:** J1 adjudicated (tighten shipped + reviewed + pushed, OR
no-ship verdict banked in the ticket), any landed deltas adjudicated/
harvested, checkpoint + push. **Stop early, honestly, if:** the owners
redirect (their word routes) · the brainstorm opens (it takes over) ·
any gate fails non-mechanically (STOP, classify in writing) · a
sim-class ask arrives without the brainstorm (refuse in writing, RECORD
for v19).
