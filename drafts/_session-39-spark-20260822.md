# SPARK sesión 39 — THE v19 BRAINSTORM (owner-approved 2026-08-22). You facilitate; the owners decide; the foundation gets written.

You are the dev of record in game-two (cwd `~/workspace/game-two`) and
TODAY the facilitator of the v19 brainstorm — approved by Gabriel in the
hub chat 2026-08-22 ("Approved the brainstorm"). Read `AGENTS.md` FIRST
(rule 8; redesigned `e9048b4` — the live file beats this spark). Ruby
per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"` (you likely need no
Ruby today — NO CODE in the brainstorm). Working language English;
Gabriel's surfaces es-CR (everyday gamer words); Junior's pt-br. His
verdicts may land in Spanish — record them VERBATIM, never translated.

## Mandate

Produce v19's foundation: lanes ratified one candidate at a time, forks
closed (dev recommendation + owner veto, v13 precedent), staging and
gates named, the v19 fun-verify ritual drafted. Junior is likely absent:
under the 2026-08-22 order (AGENTS operating model) the brainstorm runs
with the peer present; every decision carries a ratification mark —
**RATIFIED-G** (Gabriel, live) / **PENDING-J** (Junior, async in the hub
chat or his next session). The AGENTS cycle-section rewrite lands ONLY
after BOTH ratify — NOT this session unless Junior appears.

## Read FULLY before the first candidate (in this order)

1. `drafts/_v19-intake-docket-20260820.md` — the agenda page (LAW: it
   adds no opinions; every row verified live 2026-08-20).
2. `drafts/_v19-brainstorm-prep-20260821.md` — which shelf note serves
   which row (pointers only; FLAGGED shelf numbers are shape, NEVER spec
   numbers without re-verification).
3. `drafts/_junior-v19-ideas-20260819.md` — the banked ideas verbatim
   (both owners' ideas; Junior's voice is IN the room through this).
4. `drafts/_v18-foundation-20260817.md` — the structural template for
   what you output.
5. `drafts/_v18-fun-verify-verdict-20260820.md` — carried caveats the
   v19 ritual design must fix: same-day spacing + symmetric audio
   novelty; triggered rows 3/6/9 are docket inputs today.

## Job 0 — minimal (~3 min; the brainstorm is THE session)

`git pull --ff-only` (read any Junior commits BEFORE rebasing). Note
deltas (save mtime/md5 vs `98fe75ed…` 08-20 15:51 · new
`game_two_session_*.log` beyond 40×2/08-21 01:39 · assets RECEIPT mail)
in one checkpoint line for s40 — do NOT harvest today. Exceptions that
DO preempt: a live owner order in chat, or a delta showing a crossing
landed BROKEN (defect = classify + ask which takes priority).

## Protocol (per candidate — the quality loop)

1. PRESENT: one screen max — what it is, which docket row, what the
   player would feel. Cite the source doc, not memory.
2. GROUND: pull the prep-mapped vault note (`hub kb query --domain
   game-research "<topic>"`); name the touchstone mechanism in one
   line. For the NAMED SHELF GAP (companion/ally AI — finding A + row
   6): say "the shelf has nothing" honestly; offer the banking-only
   research spoke as the gap-filler; never improvise fake research.
3. RISKS: name the 2-3 biggest (interactions with other rows count —
   e.g. J-4 leveling × death-penalty × row 9 economy is one system).
4. RECOMMEND: ONE position (commit-as-lane / stage-later / park /
   refuse) with reasons. Defend it; fold on owner veto without
   relitigating.
5. VERDICT: the owner's line VERBATIM → **append to the foundation
   draft ON DISK immediately** (crash-safe; one write per verdict).
   Mark RATIFIED-G + PENDING-J.
6. Next candidate. Timebox ~10 min each; the headline debate (J-4) may
   run long by owner choice — ask before letting it eat a second slot.

## The agenda (pre-clustered from the docket — walk in this order, owner may reorder)

- **A. PROGRESSION (the recorded headline):** J-4 leveling/XP/skills/
  level-gated world (+ lobber addendum `38a3ddb`) — with its two
  interlocks: death-penalty co-tuning and combat math (prep rows carry
  three loaded notes). This cluster likely DEFINES v19; let it.
- **B. WORLD GEOGRAPHY & ECONOMY:** J-2 safe vs battle zones · finding
  B no-bank-in-deep-zones (two recorded interpretations — design, not
  bug) · TOWN 1 content v0 (empty-town crossing bank) · verdict row 9
  session-2 under-resourced · row 3 respawn/coop.json retune. These
  five interlock — consider ratifying them as ONE lane with staging.
- **C. LIVING WORLD & AI:** J-7 walk-home-not-teleport (frozen-zone law
  is the current deviation) · finding A ally-acquisition gating
  (mechanism CONFIRMED read-only `9a7dd98`; R-A3 frozen until today) ·
  row 6 AI suicides. SHELF GAP applies to the ally half.
- **D. PRESENTATION & LEGIBILITY:** J-3 CryoFall-style menu (+ asset
  style signal) · J-5 projection/style preview · J-6 non-pausing menu ·
  the two NAMED FORKS owed a class today: projectile-visual sync
  (presentation-only vs sim cadence, `c835c67`) and lobber pass-through
  (legibility vs sim hit-test). Naming the fork ≠ building it.
- **E. RIDERS (fast, only if time/owner interest):** debug/mod menu
  (awaits Gabriel's validation — his call, never nag) · ping remap
  (parked audio data) · assets v12 capture-contract + turn-handling
  sequencing (process; the owners own sequencing) · motif-strip
  authoring (data-class leftover) · audio library increments
  (depth-aware duck; stereo stems + region-acoustics — owner word
  dispatches them, they build in game-two-audio).
- **F. THE v19 RITUAL:** draft the fun-verify design INTO the
  foundation — what the owners must FEEL for v19 to be CUMPLIDO, halves
  and spacing (fix the same-day-spacing caveat), novelty asymmetry (fix
  the symmetric-audio caveat), pre-registered routing rows. Wording
  freezes at ratification; do NOT rehearse the questions with the
  owners in chat (measurement hygiene re-arms when the ritual stages).

SKIP (settled — one line each in the foundation appendix): J-1 (CLOSED,
"FUNCIONA") · lag rows (adjudicated/closed) · basement ambience
(ANSWERED, T4 rider 8) · gamesmith R7 rows (evidence on named triggers
only) · BOSS-1 dread (stays OPEN-FOR-EXPOSURE, zero code — cite the
first organic exposure bank if the owners ask).

## Output contract (all in drafts/, committed before close)

1. `drafts/_v19-foundation-20260822.md` — template: v18 foundation.
   Sections: vision line (the owners') · lanes with staging + gates
   owed + world.rb-extraction flags (cap is 1800/1800) · forks closed
   (verdict verbatim per fork) · parked/refused with one-line reasons ·
   ritual draft (F) · settled appendix · ratification ledger
   (RATIFIED-G / PENDING-J per decision). PARTIAL is honest if the
   owners stop early — mark it.
2. `drafts/_v19-ratificacao-junior-20260822.md` — pt-br, one screen,
   plain gamer words (docs/JUNIOR.md register): the decisions awaiting
   his async ratification, one line each + foundation pointer. Never
   quote Gabriel in Portuguese he didn't write — paraphrase, unquoted.
3. Checkpoint entry (s39 = brainstorm) + docket rows annotated with
   verdict pointers (docket LAW: pointers only, no new opinions).
4. s40 spark (harvest+execution posture returns; menu = the ratified
   lanes; AGENTS cycle rewrite waits for Junior's marks unless he
   ratified live) — commit, then clipboard via the verified
   CF_UNICODETEXT recipe (python ctypes, restype/argtypes pinned,
   read-back vs SOURCE).

## Hard laws today

- **NO CODE, no data/ edits, no gates run, nothing ships.** Writes =
  drafts/ + docs/CHECKPOINT.md only.
- Verbatim means verbatim; verdicts in the language the owner typed.
- Parking-lot items stay parked unless an owner EXPLICITLY promotes one
  (one recorded line). Sim-class discussion is the brainstorm's JOB —
  but everything lands as staged lanes, none as immediate work.
- **R-A2 stays silent**: rows 9/B/row-3 economy DESIGN debates are fair
  game (the owners banked them); the silent sustain measure and its
  numbers are NEVER revealed or hinted. Row 4's recorded order:
  discoverability first, price debate parked behind it.
- FLAGGED shelf numbers never become spec numbers in the foundation
  without re-verification — cite mechanism shape only.
- Junior's lane files are his — cite, never edit. If he appears live
  mid-session, he ratifies live (marks flip to RATIFIED-J) and his
  ideas get equal floor time — the protocol doesn't change.

## Budget + stop conditions

One attended session ~1.5-2.5 h. KB queries: free, unlimited. Council 0
by default — ONE exception, budget-declared first: an owner-requested
outside taste-read on a genuinely deadlocked fork (≤2 calls). Sub-agent:
ONLY the companion-AI research spoke (banking-only, bounded, one pass)
and ONLY if the owners open that debate AND want the shelf filled before
deciding — otherwise mark the lane's research debt in the foundation.
Context guard 85% → compact-checkpoint skill (the on-disk foundation
draft makes this safe at any point).
**Stop when:** agenda walked (or owner calls it) → outputs 1-4 committed
+ pushed → spark clipboarded. **Stop early, honestly, if:** the owners
redirect · a defect-class delta preempts (their call) · any verdict
would require re-litigating a recorded owner order (refuse, cite the
line).
