# SPARK: v18 session 5 — the SEVENTEENTH: harvest + decision (the cycle gate)

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST — the v18 scope contract is ground truth, the
spec is FINAL, and two standing owner orders bind every word you
write: the lore ban (placeholders + functional dictionary words only)
and the **register law (2026-08-18, commit `29edda3`)**: es/pt
human-facing text uses everyday gamer words — no notarial/judicial/
debt vocabulary, ever (foreclosure-quarantine family; project MEMORY.md
carries the banned-word list). English spec cross-reference names
("Half A arbiter", F2 "save custody") stay as written.

**What this session is:** the v18 build phase closed at increment 8
(`90c75e6`); the owner and Junior then played the SEVENTEENTH's two
real sessions on different days per
`drafts/_v18-seventeenth-runsheet-20260818.md`. This session HARVESTS
the evidence, checks Half A mechanically, records Half B verbatim,
decides, and routes per the spec's CLOSED table. **It changes NO code,
NO data, NO harness files — it reads, evaluates, records, routes.**
Routed work ships in its own later sparks. The question wording in the
run sheet (including "Veredicto libre./Veredicto livre.") was owner-
approved 2026-08-18 — the ritual ran exactly that sheet.

**Two modes — decide at Job 0 and say which you are in:**
- **FULL** — both sessions played, logs available, both players'
  answers gathered → run every job below.
- **PARTIAL** — anything missing (session 2 not played, a log absent,
  answers not yet gathered) → bank what exists verbatim into the
  skeleton draft, name what is missing in the checkpoint + owner
  queue, and STOP. The cycle is owner-paced; do not invent work.

## Read before acting (in order)

1. `AGENTS.md` — whole file (Ruby PATH per shell:
   `export PATH="/c/Ruby34-x64/bin:$PATH"`).
2. `docs/CHECKPOINT.md` top TWO entries — the register cleanup (what
   was kept and why) and the session-4 close (the two RECORDED
   docs-found defects: launcher persist-line filter gap; joiner
   null-save fresh line — they stay recorded unless a routing row
   opens them).
3. `drafts/_v18-seventeenth-runsheet-20260818.md` — the sheet the
   owner ran: harvest checklist, Half A checks, the verbatim
   questions.
4. The spec
   `docs/superpowers/specs/2026-08-17-v18-persistent-world-design.md`,
   the WHOLE "Fun-verify protocol (SEVENTEENTH — pre-registered)"
   section — Half A arbiter, Half B questions, and the ROUTING TABLE.
   All CLOSED: you evaluate against them, you never reshape them.
5. `drafts/_v17-fun-verify-skeleton-20260816.md` — the skeleton
   TEMPLATE precedent (structure, verbatim-evidence style, verdict
   framing). Your artifact is its v18 successor.
6. `drafts/_junior-specials-chain-retry-20260818.md` — Junior's
   discoverability side-signal. LAW: it enters the evaluation only
   AFTER both players' answers are recorded (pre-registered routing
   context, never a pre-weight).
7. `git pull --ff-only` FIRST and before every push — Junior's seat
   lands commits mid-session (live precedents), and his answer or
   telemetry may arrive AS a commit.

## Job 0 — verify state + the evidence gate

- History holds `90c75e6` (increment 8) + `29edda3` (register
  cleanup); tree clean; branch synced; `bundle exec rake` green
  (was 761 runs / 13889 assertions).
- The evidence: session logs are `%TEMP%\game_two_session_*.log` (cmd)
  / `/tmp/game_two_session_*.log` (Git Bash), one per launch,
  host-side on this machine; Junior-side lines (his two `TELEMETRY
  netplay` lines and his `loaded ... source=handshake` lines) arrive
  via owner/Junior paste, a drafts/ file, or his own commit — pull.
  Solo-play logs between the sessions belong to the chain too.
- Judge sessions ONLY by TELEMETRY lines (project memory: idle seats
  sit at ticks=0 and a dead session can hold its end screen —
  process-alive ≠ session-alive; check `ticks=` on every line).
- Anything missing → PARTIAL mode (bank + name + stop). A ritual
  shortfall (a session under 36000 ticks, a non-quit `reason=`, a lost
  log) is NOT a routing-table failure: that session RE-RUNS,
  owner-paced — never waive a check, never fudge a pass.

## Job 1 — harvest (before reading any answer)

Create `drafts/_v18-fun-verify-skeleton-<yyyymmdd>.md` (naming
precedent: the v17 skeleton). Into it, VERBATIM with provenance (log
filename or paste source, machine, date): every `TELEMETRY netplay`
line (2 sessions × 2 seats), every `TELEMETRY persist` line
(loaded/saved/fresh — host sessions AND solo between), every
`TELEMETRY sustain` line, `TELEMETRY session seed=` lines, and any
refusal/desync text if one appeared. Do not summarize a line you can
quote.

## Job 2 — Half A (PERSISTED), the mechanical checks

Each check PASS/FAIL with the exact lines quoted beside it (spec
wording is the gate; the run sheet restates it):
1. Digest chain: session 2's `persist loaded digest` == the latest
   prior `persist saved digest` in the host's logs (solo saves
   included).
2. Joiner's `loaded ... source=handshake` digest == the host's digest,
   BOTH sessions.
3. `desyncs=0` + `reason=quit` on all four netplay lines; ticks ≥
   36000 each session.
4. Carried fact: session 2's persist line shows the accreted state
   matching session 1's close — name at least one strictly-positive
   carried fact (banked/seals/marks/sessions).
A full chronological chain walk (every loaded == previous saved) is
welcome DIAGNOSTIC context; the four pinned checks alone decide.

## Job 3 — Half B (FELT), recorded not judged

Record both players' answers UNEDITED (es for the owner, pt-br for
Junior — their words, their language, full sentences as given). No
paraphrase, no scoring, no register cleanup of THEIR words. Only after
both sets are recorded may the side-signal (read-item 6) and the
`TELEMETRY sustain` numbers enter the reading.

## Job 4 — decide + route (the table is CLOSED)

- The oracle: Half A all-pass AND Half B reads as "the world felt
  continued / the frictions eased" per the players' own words →
  **CUMPLIDO** on that half's terms; anything else = the specific
  rows that fired.
- Walk EVERY row of the spec's routing table against the evidence.
  For each: quote the row, state TRIGGERED or NOT, cite the exact
  evidence line(s). A triggered row = a RECORDED work item in the
  skeleton (+ PARKING_LOT only if the row says so) with a recommended
  next-spark shape — never in-session code/data changes, not even the
  coop.json retune row (it prescribes a data-only re-session: that IS
  its own spark).
- Contradictory evidence (e.g., clean chain + "no continuó") is
  exactly what the table pre-registered — follow the row, do not
  editorialize.

## Job 5 — artifacts + close

- Skeleton committed in drafts/ (explicit paths; hooks run the suite).
- `docs/CHECKPOINT.md` new top entry: the decision, the fired rows,
  the resume point (CUMPLIDO → cycle CLOSED, v19 opens only via a
  fresh owner-paced brainstorm — PARKING_LOT riders name the lead
  candidate; NOT CUMPLIDO → the routed items in recommended order,
  each awaiting its own spark).
- `AGENTS.md`: ONE dated status line inside the v18 block (after the
  Oracle paragraph): `SEVENTEENTH (2026-08-XX): <decision> — evidence:
  drafts/_v18-fun-verify-skeleton-<date>.md.` Nothing else in the
  owner's prose moves; the v19 opening rewrites the block later, not
  now.
- If Junior's seat ratified or amended the JUNIOR.md pt-br section
  meanwhile: his lane — pull, keep his wording, note it in the
  checkpoint. If not: the flag stays, not blocking.
- Owner queue at close (es-CR ustedeo, everyday words, ~3 lines): the
  result in plain language, what opens next (or what is still owed),
  and any single decision that is his to make.

## Laws that bite

- **No code, no data, no harness, no strings changes** — a defect or
  tuning need found here is RECORDED and routed, never fixed inline
  (docs-only discipline, same as increment 8).
- Questions, arbiter, routing table: CLOSED. Evidence is quoted, never
  reshaped. Players' answers are theirs — verbatim, unedited.
- Register law on everything YOU write (es/pt everyday gamer words;
  the skeleton's analysis prose is English — internal doc).
- Placeholder law + lore ban (standing owner order 2026-08-16).
- Explicit-path commits; pull before every push; hooks run
  `bundle exec rake` — fix, never `--no-verify`.
- Budget: analysis session, zero fan-outs. One optional council call
  (≤2K tokens out) ONLY if a routing row's trigger is genuinely
  ambiguous on the evidence — name the ambiguity first.

## Stop conditions

- FULL mode: skeleton + checkpoint + AGENTS.md status line + owner
  queue, committed + pushed → STOP. Nothing new starts; routed items
  and the v19 brainstorm each get their own spark AFTER the owner
  reads the skeleton.
- PARTIAL mode: partial skeleton + checkpoint naming the gaps + owner
  queue asking for exactly the missing pieces → STOP.
- Seat conflict, red suite at Job 0, or a push race: reconcile or hand
  off via drafts/ + `swarmforge handoff validate` — never route
  around.
