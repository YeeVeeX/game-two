# SPARK: v18 interlude session — ritual-readiness + owner-visible polish (Junior away)

You are the dev of record in game-two (cwd `~/workspace/game-two`).
Read `AGENTS.md` FIRST — the v18 scope contract is ground truth. Ruby
per shell: `export PATH="/c/Ruby34-x64/bin:$PATH"`.

**What this session is:** the SEVENTEENTH is PARTIAL/STANDBY (ritual
needs Junior; he is unavailable — owner said so 2026-08-18). The owner
has explicitly opened a bounded interlude: progress and polish on what
does NOT need Junior and does NOT touch what the oracle measures. This
session hardens the baseline, lands the one folded rubric item under a
green-or-revert law, and hands the owner two things he can use TODAY:
his world map and a solo sheet (solo play legitimately advances the
shared world — spec F4).

**What this session is NOT:** not the harvest (that spark re-runs when
evidence exists), not a retune, not a new lane, not defect cleanup.
The two session-4 recorded defects (launcher persist-line echo gap;
joiner null-save fresh line) were RULED non-blocking with
post-adjudication timing — the session log is the pre-registered
evidence path and the run sheet already points there. They STAY
recorded. Do not re-litigate them.

## Read first, in order

1. `AGENTS.md` — whole file (scope contract, orchestration block).
2. `docs/CHECKPOINT.md` — top THREE entries (session 6 intake+adoption,
   session 5 PARTIAL+forensics, session 4 build close + the two
   recorded defects with their rulings).
3. `drafts/_v18-fun-verify-skeleton-20260818.md` — STANDBY skeleton:
   the chain anchor (`d63fd8ea…`), the residue-trap law, the gaps.
4. `drafts/_itexo-intake-triage-20260818.md` — the triage: the ONE item
   with a landing slot this session (2.9 occlusion rubric candidate)
   and the FOLD-NOW semantics that bind everything else.
5. `git pull --ff-only` FIRST and before every push.

## Job 0 — evidence gate + health baseline (blocking; ~30 min)

- Evidence re-check first: newest `game_two_session_*.log` in BOTH temp
  dirs, any Junior-side commit/paste. If ritual evidence EXISTS →
  STOP this spark; the harvest spark (`7224819` pattern) is the
  vehicle — tell the owner, do not adjudicate here. New SOLO logs (no
  Junior) → continue, bank them in Job 4.
- Then the full baseline on the promoted mainline, all four surfaces:
  `bundle exec rake` (expect ~761 runs green) · `harness/run_wall.sh
  interlude-20260818` (18 scripts, full critic) · the three netplay
  gates (`rake gate SCRIPT=harness/net/<x>.json
  CHECKS=harness/net/gate_checks.json`) · `rake perf` (p95 < 16.6 ms).
- ANY red = the session BECOMES regression forensics: bisect, report,
  fix only with TDD + its own commit; Jobs 1–3 wait for a green
  baseline or the next session. Never proceed on red.

## Job 1 — occlusion rubric line, green-or-revert (~45 min)

The triage folded ONE Rule-2 rubric candidate with the landing slot
"next wall-touching spark" — this is that spark.

- Add ONE checklist line to `harness/gate_checks.json` (default wall
  checklist), phrased per the triage: burst/AoE effects must leave
  actor silhouettes and ground state readable (corpus-observed failure:
  Itexo addendum 2.9, era-tagged 2019).
- Re-run the FULL wall with the critic (`harness/run_wall.sh
  interlude-rubric-20260818`).
- **Green → lands** (wall stronger, zero behavior change; commit alone,
  message cites triage + addendum section).
- **Any script fails the new line → REVERT the line, keep the log**,
  record the failing frames as a post-ritual design question in the
  triage draft's FOLD notes. NEVER retune visuals to pass — visual feel
  belongs to the oracle window and the routing table.

## Job 2 — god-view artifact for the owner (~20 min)

- Gate first: `rake map PROBES=1` + its own critique
  (`harness/map_checks.json`) — this surface's Rule 2 (probes + vision,
  no replay half; decision 13). Must exit 0.
- Then the real artifact: `rake map` against the live `saves/world.json`
  → `world_<digest8>_<ts>.png`. Verify the digest8 in the filename
  matches the save's current digest through the play-path decoder.
- Deliver the PNG path in the owner queue: his persistent world,
  digest-stamped, as it stands before ritual session 1. Touch NOTHING
  in `saves/` (never hand-edit; no `--fresh`; the world is the owner's).

## Job 3 — solo sheet for the owner (docs-only; ~15 min)

`drafts/_v18-solo-sheet-20260818.md`, es-CR ustedeo, everyday gamer
words (register law — no notarial/judicial vocabulary), ≤10 lines:

- `git pull` antes de jugar · `bin\play.cmd es` · juegue normal ·
  salga SIEMPRE con Esc (así se guarda el mundo) · el archivo
  `%TEMP%\game_two_session_*.log` de cada partida se guarda, no se
  borra · nunca editar `saves/world.json` a mano · nunca `--fresh`
  (eso reinicia su mundo).
- Why it matters, one line: solo play advances the SAME shared world
  (F4) and its logs join the digest chain the ritual will walk.
- The sheet gets a pointer line in the owner queue; do NOT touch the
  run sheet or JUNIOR.md (ritual surfaces are frozen; Junior's lane).

## Job 4 — bank new chain evidence, if any (docs-only)

Any new solo/dev persist lines found in Job 0: append VERBATIM to the
skeleton's chain-anchor section with provenance (log filename, mtime,
machine), same style session 5 used. The residue-trap law applies
(suite/gate artifacts are not sessions; judge by session LOGS only).
No adjudication — slots stay PENDING.

## Job 5 — close

- `docs/CHECKPOINT.md` new top entry: baseline results (counts, wall
  tag, perf p95), rubric line landed-or-reverted (with evidence), map
  artifact path + digest, solo sheet path, evidence-gate result.
- Commits: explicit paths, one concern each (rubric line separate from
  docs). Hooks run the suite; fix, never `--no-verify`. Pull before
  every push.
- Owner queue (es-CR ustedeo, ~4 lines): estado del baseline, dónde
  está el mapa de su mundo, la hoja de juego solo, y que el ritual
  sigue igual — dos sesiones con Junior cuando él pueda; la única
  decisión suya es cuándo jugar.

## Laws that bite

- **The oracle surface is FROZEN:** no changes to telemetry wording,
  launcher echo behavior, respawn/pacing/sustain numbers,
  `data/balance/coop.json`, the run sheet, the skeleton's adjudication
  sections, or JUNIOR.md. The sustain-discoverability side-signal is
  HELD — zero work, zero speculation, it enters only after Half B.
- Spec CLOSED: arbiter, questions, routing table — this session never
  reshapes them; a defect or tuning need found here is RECORDED and
  routed, never fixed inline (except under Job 0's red-baseline rule).
- No new lanes, no parked promotions, no `data/**` edits. The ONLY
  gate-adjacent change permitted is Job 1's single checklist line under
  green-or-revert.
- Placeholder/lore ban + register law on every human-facing word you
  write (the solo sheet is human-facing: everyday es, gamer words).
- Rule 2: Job 1's evidence is the full wall run; Job 2's is the map
  gate. No eyeballing, no SKIP_CRITIC on anything that ships.
- Budget: single session, zero sub-agent fan-outs, no council call
  (nothing here is ambiguous enough); ~2h soft cap. Seat conflict or
  push race → coordinate via drafts/ + seat mail, never route around.

## Stop conditions

- Jobs 0–5 done (or Job 1 reverted-with-evidence) → checkpoint + owner
  queue committed + pushed → STOP. Nothing new starts; the ritual and
  all routed work stay owner-paced.
- Ritual evidence discovered at Job 0 → STOP after reporting (the
  harvest spark is the vehicle).
- Red baseline → forensics only, report at close what turned red, what
  was fixed (TDD), what remains.
