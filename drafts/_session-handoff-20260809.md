# Session handoff — 2026-08-09 (written pre-compact, in the "Game On(e)" session)

Full rationale behind the goal text / checkpoint. Read this before scaffolding.

## Ownership grant (owner, verbatim intent, 2026-08-09)

*"create this as if you own it, no limitations, no constraints, you are the dev and I am the
tester, find your preferred method and way to it."* — So: **Claude is the dev of record.**
Design decisions (mechanics, visuals, systems, architecture, process) are mine to make and
defend; the owner playtests builds and gives feedback. Don't ask permission for design calls —
make them, log the reasoning, ship testable builds. Sensei-not-secretary still applies in
reverse: surface risks, but decide. The owner's role each loop: run the build, react, report.

## What this project is

Ruby rebuild of Kethral ("game-two", working title — owner hasn't named it). Owner's direction,
verbatim intent: *"the midi system in kethral and sounds were just an experiment, we will not
miss them, create your best version of the gameplay and core of the game, visuals, mechanics,
systems that you can improve/enhance."* So: creative license on gameplay/visuals/systems,
audio demoted to placeholder, and the mandate is **the better version**, informed by 2–3 prior
Kethral iterations (Aerolith Chronicles → `prototype/` → `kethral/`).

Old repo (read-only reference): `C:\Users\gabri\Documents.stale-20260413\coding_projects_main\Game On(e)`

## Toolkit decision: Gosu (settled this session — don't relitigate)

- **Gosu** — chosen. Closest pygame analog (update/draw loop, image blitting, input polling,
  Sample/Song audio). Free, MIT, full CRuby so gems work, `gem install gosu` has prebuilt
  Windows binaries for RubyInstaller. Ruby 3.4 + YJIT is performance-adequate at this scale.
- DragonRuby GTK — rejected: mRuby subset (no gems), paid license. Its built-in deterministic
  replay was attractive, but we build our own Rule 2 harness anyway.
- Ruby2D — rejected: too thin, would be outgrown immediately.
- Frame capture candidate API: `Gosu.render(w, h) { ...draw... }` returns a `Gosu::Image`
  which has `#save(path)`. **Verify against current Gosu docs (context7) before building the
  Rule 2 harness on it** — do not trust this note as ground truth.

## Kethral post-mortem — what "better this time" means (evidence-based)

Measured/observed this session from the old repo:

1. **The scope doc was ignored — the #1 failure.** `SCOPE_PROTECTION.md` declared OUT of
   scope: procedural dungeon generation, branching dialogue trees, status effects, complex
   crafting. `WORKSPACE_STATUS.md` (2026-04-02) lists ALL of them as implemented, plus
   weather, time system, codex, bestiary charms, local co-op, NPC schedules... 17 phases in
   and the status line still reads "vertical slice APPROACHING". Breadth won over depth
   every time. **Fix: scope lists live in project CLAUDE.md where the harness enforces them;
   new ideas go to PARKING_LOT.md, never to code; nothing new starts until the current loop
   is fun-verified.**
2. **God object.** `kethral/game.py` = 2,663 lines despite an event bus existing. **Fix:
   orchestrator cap ~300 lines; systems talk via the bus or they don't ship.**
3. **Verification arrived late.** 1,364 passing tests (doc-claimed) verified logic, never
   feel or visuals; the frame-capture pipeline was retrofitted around Phase 15. **Fix:
   Rule 2 harness (scripted input replay + frame capture + vision critique, blocking) is
   Phase 0, proven on a moving square before any game code exists.**
4. **Audio experiment consumed a large share of effort** (MIDI engine, procedural SFX
   synthesis, 20 sounds, adaptive layering). Owner explicitly dropped it. **Fix: Gosu
   Sample/Song placeholders only. Do not rebuild a MIDI engine. Ruby's MIDI ecosystem is
   weak anyway — this decision removes Ruby's only real disadvantage for this project.**

What WORKED in Kethral (port the pattern, not the code):
- Event bus + state machine + data-driven JSON configs (40+) + manager pattern
- Test-first culture (minitest replaces pytest; rake as runner)
- Design corpus worth mining: `.kiro/specs/marrow/requirements.md` (29 reqs, 390+ criteria),
  `.kiro/specs/marrow/design.md` (3,284 lines), `.kiro/steering/*.md`, kethral phase
  architecture docs. Distill the proven-fun subset into a 1-page slice spec BEFORE combat.

## Measured numbers (commands run 2026-08-09)

- Old repo: 211 `.py` files under `kethral/` (Glob count, capped listing).
- New repo: `git init -b main` done, 0 commits at harvest time.
- "1,364 tests passing" is WORKSPACE_STATUS.md's claim (dated 2026-04-02), not re-measured.

## Session-mechanics caveat

The Claude Code session that wrote this had cwd pinned to the OLD repo (`cd` doesn't persist
across Bash calls in this harness). Launch the next session IN `~/workspace/game-two`
(claude-on or plain cd first) so relative paths and /goal apply to the right repo.
