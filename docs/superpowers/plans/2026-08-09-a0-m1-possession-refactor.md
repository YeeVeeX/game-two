# A0/M1 — Possession Core Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship M1 — the actor/controller refactor + possession core in the EXISTING world: a pack
of 3 creatures (shared melee kit), Tab swap, forced-swap-on-death with stagger, wipe → nest
respawn, exhaust replacing free-swing, per-attacker cadence replacing blanket invuln — fought
against the existing husks in the existing two zones. Playable feel-check build for the owner.

**Architecture:** One `Creature` class (kit-driven actor: walker + hp + attack machine + exhaust)
replaces both `Player` and `Enemy`. Controllers (`PossessedController` reading input with an
edge-trigger mask; `AiController` running the generalized husk brain) drive creatures through
public verbs. `Pack` owns the 3 members + the possession pointer. `World` resolves ALL combat
from the attacker's kit via factions (`:pack` vs `:human`), scopes hitstop to the possessed body,
and anchors BFS flow fields on any creature (cached per anchor, recomputed on anchor tile change).

**Tech Stack:** Ruby 3.4.10 (no YJIT — RubyInstaller build), Gosu 1.4.6, minitest, rake.
Vision gate: python + boto3 on Bedrock (`us.anthropic.claude-fable-5`, profile `voice-dev`).

**Scope boundary:** This plan = Phase 0 (make the gate real, per review orders 2/3/6/4-text) + M1
(review order 1). **M2 is a separate plan**, written after the owner's M1 feel-check: three kits +
Lobber projectile, Rushers, nest + district zones, 3-bar HUD + exhaust pip, edge pips, carried
critique fixes (facing notch, hurt-flash, telegraph color, wall brightness, corpses, lunge),
`district_hunt.json`, perf smoke (p95 update < 16.6 ms — review order 4's measurement half).

## Global Constraints

- Spec: `docs/superpowers/specs/2026-08-09-a0-possession-core-design.md`; binding review law:
  `drafts/_design-review-reconciliation.md` (promoted to `docs/design-corpus/` in Task 2).
- Every shell needs `export PATH="/c/Ruby34-x64/bin:$PATH"` (Git Bash; Ruby not on PATH).
- Run everything from repo root `C:/Users/gabri/workspace/game-two`; anchor Bash calls with
  `cd /c/Users/gabri/workspace/game-two &&` (cwd drifts between calls).
- `src/app/window.rb` ≤ ~300 lines (orchestrator cap). All balance numbers in `data/**/*.json`.
- EventBus events are registered or they raise; register new symbols when first used.
- No mocks in integration tests — real DataStore, real zone JSON, real sim.
- Timebase decision (review order 5): `Window#update` stays **tick-locked** (one sim tick per
  update; replays deterministic by tick count). Live slowdown is surfaced by an on-screen
  update-overrun counter (Task 12), never compensated by an accumulator.
- Determinism: sim never reads `Gosu.milliseconds`/`Time`/global `rand`. The sim's PRNG is
  `Random.new(seed)` plumbed in Task 11 (unused by M1 logic — the plumbing is the law).
- Names in code are internal spec-speak (de-slop rule). Player-visible strings that await the
  bible are marked `# fiction-pending`.
- Commit after every task (message given per task). Never `git push` (no remote by design).

---

## Phase 0 — make the gate real

### Task 1: Reproducibility — commit Gemfile.lock, pin gosu exact

**Files:**
- Modify: `Gemfile` (gosu line)
- Modify: `.gitignore` (remove `Gemfile.lock` line)
- Create: `Gemfile.lock` (generated)
- Modify: `CLAUDE.md` (Environment section — fresh-machine caveat)

**Interfaces:** none (build hygiene).

- [ ] **Step 1: Pin gosu exact in Gemfile**

Change the gosu line in `Gemfile`:

```ruby
gem "gosu", "= 1.4.6"
```

- [ ] **Step 2: Remove `Gemfile.lock` from `.gitignore`**

Delete the line `Gemfile.lock` from `.gitignore` (currently the last line).

- [ ] **Step 3: Generate the lockfile**

Run: `cd /c/Users/gabri/workspace/game-two && export PATH="/c/Ruby34-x64/bin:$PATH" && bundle lock`
Expected: `Gemfile.lock` created; `gosu (1.4.6)` in it. (`bundle lock` resolves without
reinstalling; gosu 1.4.6 is already installed.)

- [ ] **Step 4: Record the fresh-machine caveat**

In `CLAUDE.md` Environment section, append one bullet:

```markdown
- Gemfile.lock is committed; gosu pinned `= 1.4.6`. ⚠️ rubygems ships no prebuilt
  x64-mingw-ucrt binary for gosu 1.4.6 — it compiled from source here via the RubyInstaller
  devkit; a fresh machine needs MSYS2/devkit installed before `bundle install`.
```

- [ ] **Step 5: Verify tests still green**

Run: `export PATH="/c/Ruby34-x64/bin:$PATH" && rake`
Expected: `31 runs, 82 assertions, 0 failures, 0 errors`

- [ ] **Step 6: Commit**

```bash
git add Gemfile Gemfile.lock .gitignore CLAUDE.md
git commit -m "build: commit Gemfile.lock, pin gosu = 1.4.6 (review order 3)"
```

### Task 2: Promote the design corpus into docs/ + correct the YJIT claim

**Files:**
- Create: `docs/design-corpus/` (moved from `drafts/_*`): `design-review-reconciliation.md`,
  `kethral-feature-map.md`, `marrow-fact-sheet.md`, `tibia-research.md`,
  `vision-critique-20260809.md`
- Modify: `docs/CHECKPOINT.md` (paths + YJIT correction)

**Interfaces:** none (docs). Bulky dumps (`drafts/_tibia-videos/`, `_mining_raw.txt`, goal
scratch files) STAY gitignored by design.

- [ ] **Step 1: Move the load-bearing files (drop the underscore prefix — `drafts/_*` is the gitignore pattern)**

```bash
mkdir -p docs/design-corpus
git mv 2>/dev/null; :  # files are untracked — plain mv
mv drafts/_design-review-reconciliation.md docs/design-corpus/design-review-reconciliation.md
mv drafts/_kethral-feature-map.md          docs/design-corpus/kethral-feature-map.md
mv drafts/_marrow-fact-sheet.md            docs/design-corpus/marrow-fact-sheet.md
mv drafts/_tibia-research.md               docs/design-corpus/tibia-research.md
mv drafts/_vision-critique-20260809-090905.md docs/design-corpus/vision-critique-20260809.md
```

- [ ] **Step 2: Fix stale references and the YJIT claim in `docs/CHECKPOINT.md`**

In the top (2026-08-09 evening) section, update every `drafts/_...` path that moved to its
`docs/design-corpus/...` equivalent. Then fix the locked-decision text (review order 4): change
the line `1. **Ruby + Gosu**, CRuby 3.4 + YJIT. DragonRuby and Ruby2D rejected.` to:

```markdown
1. **Ruby + Gosu**, CRuby 3.4. DragonRuby and Ruby2D rejected. [Corrected 2026-08-09: the
   installed RubyInstaller 3.4.10 has NO YJIT (needs rustc at build time) — PRISM interpreter
   only. Perf is asserted by measurement, not by this decision text: M2 gate carries a perf
   smoke (p95 update < 16.6 ms) per the third review.]
```

Also update the same-file references in the spec
(`docs/superpowers/specs/2026-08-09-a0-possession-core-design.md` cites
`drafts/_design-review-reconciliation.md` twice) to the new `docs/design-corpus/` path.

- [ ] **Step 3: Commit**

```bash
git add docs/design-corpus docs/CHECKPOINT.md docs/superpowers/specs/2026-08-09-a0-possession-core-design.md
git commit -m "docs: promote design corpus into git; correct YJIT locked-decision text (orders 4/6)"
```

### Task 3: `rake gate` — replay twice, hash-compare, nonzero on mismatch

**Files:**
- Modify: `harness/replay_runner.rb:56` (out_dir override via ARGV[1])
- Modify: `Rakefile` (new `gate` task)

**Interfaces:**
- Consumes: existing `harness/replay_runner.rb` CLI (`ruby -Isrc harness/replay_runner.rb <script>`).
- Produces: `rake gate SCRIPT=harness/scripts/<name>.json` — exits nonzero on determinism
  mismatch or (Task 4) critic FAIL. `replay_runner.rb <script> [out_dir]` — optional override.

- [ ] **Step 1: Add the out_dir override to the runner**

In `harness/replay_runner.rb`, change the `@out_dir` line in `initialize` to accept an override,
and thread it through:

```ruby
    def initialize(script_path, out_dir_override = nil)
```

```ruby
      @out_dir = out_dir_override || raw.fetch(:out_dir)
```

and the entry point at the bottom:

```ruby
if __FILE__ == $PROGRAM_NAME
  script = ARGV[0] or abort "Usage: ruby -Isrc harness/replay_runner.rb <script.json> [out_dir]"
  Harness::ReplayWindow.new(script, ARGV[1]).show
  puts "REPLAY_DONE"
end
```

- [ ] **Step 2: Add the `gate` task to the Rakefile**

Append to `Rakefile`:

```ruby
desc "Rule 2 gate (BLOCKING): replay twice, byte-compare captures, vision verdict. SCRIPT=..."
task :gate do
  require "digest"
  require "json"
  require "fileutils"
  script = ENV.fetch("SCRIPT") { abort "Usage: rake gate SCRIPT=harness/scripts/<name>.json" }
  base = JSON.parse(File.read(script)).fetch("out_dir")
  a_dir = "#{base}_gate_a"
  b_dir = "#{base}_gate_b"
  [a_dir, b_dir].each { |d| FileUtils.rm_rf(d) }

  sh "ruby -Isrc harness/replay_runner.rb #{script} #{a_dir}"
  sh "ruby -Isrc harness/replay_runner.rb #{script} #{b_dir}"

  a_pngs = Dir[File.join(a_dir, "*.png")].sort
  b_pngs = Dir[File.join(b_dir, "*.png")].sort
  abort "GATE FAIL: no captures produced" if a_pngs.empty?
  abort "GATE FAIL: capture counts differ (#{a_pngs.size} vs #{b_pngs.size})" if a_pngs.size != b_pngs.size
  a_pngs.zip(b_pngs).each do |a, b|
    ha = Digest::MD5.file(a).hexdigest
    hb = Digest::MD5.file(b).hexdigest
    abort "GATE FAIL: nondeterministic capture #{File.basename(a)} (#{ha} != #{hb})" unless ha == hb
  end
  puts "GATE determinism: #{a_pngs.size} captures byte-identical across two runs"

  if ENV["SKIP_CRITIC"] == "1"
    puts "GATE vision: SKIPPED (SKIP_CRITIC=1 — determinism only, NOT a shippable pass)"
  else
    sh "python harness/vision_critic.py --verdict #{a_dir} --checks harness/gate_checks.json"
  end
  puts "GATE PASS"
end
```

- [ ] **Step 3: Verify the positive path (determinism half only — Task 4 builds the critic mode)**

Run: `export PATH="/c/Ruby34-x64/bin:$PATH" && SKIP_CRITIC=1 rake gate SCRIPT=harness/scripts/world_loop.json`
Expected: two replay runs, `GATE determinism: 10 captures byte-identical...`, `GATE PASS`.

- [ ] **Step 4: Verify the negative path (one-off, not committed)**

Corrupt one byte of one gate_a PNG, rerun ONLY the compare by re-invoking the task with the
doctored dir preserved — simplest: after Step 3, run
`printf 'X' | dd of=captures/world_loop_gate_a/frame_0001.png bs=1 seek=100 conv=notrunc`
then re-run the two-line compare in `ruby -e` form, or temporarily comment the two `sh` replay
lines and re-run the task. Expected: `GATE FAIL: nondeterministic capture ...`, exit nonzero
(`echo $?` → 1). Restore by deleting both `_gate_*` dirs.

- [ ] **Step 5: Commit**

```bash
git add harness/replay_runner.rb Rakefile
git commit -m "harness: rake gate — double replay + md5 compare, blocking (review order 2)"
```

### Task 4: vision critic `--verdict` mode — structured pass/fail, nonzero exit

**Files:**
- Create: `harness/gate_checks.json`
- Modify: `harness/vision_critic.py` (add verdict mode; keep existing critique modes intact)

**Interfaces:**
- Consumes: capture dir of `frame_*.png`; Bedrock via profile `voice-dev`.
- Produces: `python harness/vision_critic.py --verdict <dir> --checks harness/gate_checks.json`
  → exit 0 PASS / 1 FAIL / 2 infrastructure error. Report appended to
  `drafts/_gate-verdicts.log` (run artifact, gitignored).
- Known critic defect (standing caveat, review order 2): it once misread cubic easing as linear —
  any CODE-level claim in a critique is re-verified against source before acting; the gate
  checklist therefore contains only WHAT-IS-VISIBLE checks, never code inferences.

- [ ] **Step 1: Write the M1 gate checklist (only invariants that hold at HEAD — critique FIXES join in M2)**

Create `harness/gate_checks.json`:

```json
{
  "checks": [
    { "id": "actors_distinct", "check": "Pack creatures (ember orange family) and husks (pale bone) are immediately distinguishable from each other and from the floor in every frame where both appear." },
    { "id": "possessed_readable", "check": "In frames with multiple pack creatures, exactly one reads as 'the one I control' (brighter + outlined). If no frame shows more than one pack creature, mark pass=false with why='not exercised by this script'." },
    { "id": "telegraph_reads", "check": "Enemy attack telegraph (yellow swell) reads as incoming danger, distinct from gate/transition gold tiles." },
    { "id": "attack_visible", "check": "The player-side attack shows visibly on its tiles (white arc) in at least one frame." },
    { "id": "hud_legible", "check": "The HP bar is legible and plausibly reflects the fight shown." },
    { "id": "zones_distinct", "check": "Town frames (warm brown) and dungeon frames (cold blue) read as different places." },
    { "id": "no_render_garbage", "check": "No frame shows tearing, missing map, entities outside walls, or obviously corrupted output." }
  ]
}
```

- [ ] **Step 2: Add the verdict mode to `harness/vision_critic.py`**

Add after `REEL_PROMPT` (keeping every existing function unchanged):

```python
VERDICT_PROMPT_TEMPLATE = """These frames are capture output from a deterministic replay.
Evaluate ONLY the checklist below against what is actually visible. You are a gate,
not an advisor: a check passes only if the frames clearly demonstrate it.

Checklist:
{checks}

Respond with JSON only, no prose outside it:
{{
  "checks": [{{"id": "...", "pass": true, "why": "one sentence"}}],
  "verdict": "PASS" or "FAIL"
}}
"verdict" MUST be "FAIL" if any check has "pass": false."""


def extract_json(text: str) -> dict:
    m = re.search(r"\{.*\}", text, re.DOTALL)
    if not m:
        raise ValueError(f"no JSON object in model output: {text[:200]!r}")
    return json.loads(m.group(0))


def run_verdict(captures_dir: Path, checks_path: Path) -> int:
    checks = json.loads(checks_path.read_text(encoding="utf-8"))["checks"]
    listing = "\n".join(f"- [{c['id']}] {c['check']}" for c in checks)
    prompt = VERDICT_PROMPT_TEMPLATE.format(checks=listing)
    client = _client()
    frames = load_frames(captures_dir)
    print(f"gate verdict on {len(frames)} frames from {captures_dir} ...")
    for attempt in (1, 2):
        text = converse(client, image_blocks(frames) + [{"text": prompt}])
        try:
            result = extract_json(text)
            break
        except (ValueError, json.JSONDecodeError) as exc:
            if attempt == 2:
                print(f"GATE INFRA ERROR: unparseable verdict: {exc}", file=sys.stderr)
                return 2
    log = Path("drafts") / "_gate-verdicts.log"
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    with log.open("a", encoding="utf-8") as fh:
        fh.write(f"\n=== {stamp} {captures_dir} ===\n{json.dumps(result, indent=2)}\n")
    for c in result.get("checks", []):
        mark = "PASS" if c.get("pass") else "FAIL"
        print(f"  [{mark}] {c.get('id')}: {c.get('why', '')}")
    if result.get("verdict") == "PASS" and all(c.get("pass") for c in result.get("checks", [])):
        print("GATE vision: PASS")
        return 0
    print("GATE vision: FAIL (see above; full verdict in drafts/_gate-verdicts.log)", file=sys.stderr)
    return 1
```

And extend `main()`'s argument handling (replace the current `args`-parsing block at the top of
`main`, keeping the rest of `main` unchanged):

```python
    args = sys.argv[1:]
    if not args:
        sys.exit("usage: python harness/vision_critic.py <captures_dir> [--reel <dir>] | --verdict <dir> --checks <checks.json>")
    if args[0] == "--verdict":
        captures_dir = Path(args[1])
        checks_path = Path(args[args.index("--checks") + 1]) if "--checks" in args else Path("harness/gate_checks.json")
        sys.exit(run_verdict(captures_dir, checks_path))
```

- [ ] **Step 3: Live verify against existing captures (real Bedrock, no mocks)**

Run: `python harness/vision_critic.py --verdict captures/world_loop_gate_a --checks harness/gate_checks.json; echo "exit=$?"`
Expected: per-check PASS/FAIL lines and a final verdict. Note: `possessed_readable` SHOULD fail
against pre-refactor captures (single player, no pack) — that proves the gate can say no.
Temporarily verify exit code is nonzero on FAIL. (Do not weaken the check; the pack exists by
Task 10 when the gate must pass for real.)

- [ ] **Step 4: Full pipeline check**

Run: `export PATH="/c/Ruby34-x64/bin:$PATH" && rake gate SCRIPT=harness/scripts/world_loop.json; echo "exit=$?"`
Expected: determinism PASS, then vision verdict runs end-to-end (FAIL on `possessed_readable`
is expected pre-refactor; exit nonzero proves blocking).

- [ ] **Step 5: Commit**

```bash
git add harness/gate_checks.json harness/vision_critic.py
git commit -m "harness: vision critic --verdict mode, structured + blocking (review order 2)"
```

---

## M1 — actor/controller refactor + possession core

### Task 5: Kit data — restructure `data/balance/combat.json`

**Files:**
- Modify: `data/balance/combat.json` (full replacement below)
- Modify: `test/game/world_test.rb:10` (STEP constant path — minimal touch so the suite still
  loads; full test rewrite comes with Tasks 8–9)

**Interfaces:**
- Produces: `DATA["balance/combat"]` shape consumed by everything after this task:
  `[:kits][<kit_sym>]` → creature kit; `[:pack][:members]` → array of kit-name strings;
  `[:pack][:swap_stagger_frames]`; `[:respawn_frames]` (wipe veil); `[:feel]` unchanged.
  Kit shape: `{max_hp, step_frames, aggro_tiles, attack: {damage, windup_frames, active_frames,
  recovery_frames, exhaust_frames, arc ("arc3"|"ring"), knockback_tiles,
  knockback_frames_per_tile}, dodge: {tiles, frames_per_tile, iframes, cooldown_frames}?,
  knockback_tiles_received, knockback_frames_per_tile, respawn_frames?}`.
- Numbers preserved from HEAD except: exhaust is NEW (prowler 45f hypothesis; husk 81f =
  its old 30+6+45 cadence, so husk feel is unchanged); `invuln_frames_after_hit` is REMOVED
  (review law 5 — its former line count in combat.json:19).

- [ ] **Step 1: Replace `data/balance/combat.json`**

```json
{
  "pack": {
    "members": ["prowler", "prowler", "prowler"],
    "swap_stagger_frames": 20
  },
  "respawn_frames": 90,
  "kits": {
    "prowler": {
      "max_hp": 100,
      "step_frames": 15,
      "aggro_tiles": 8,
      "attack": {
        "damage": 25,
        "windup_frames": 6,
        "active_frames": 4,
        "recovery_frames": 10,
        "exhaust_frames": 45,
        "arc": "arc3",
        "knockback_tiles": 1,
        "knockback_frames_per_tile": 5
      },
      "dodge": {
        "tiles": 2,
        "frames_per_tile": 7,
        "iframes": 18,
        "cooldown_frames": 50
      },
      "knockback_tiles_received": 1,
      "knockback_frames_per_tile": 5
    },
    "husk": {
      "max_hp": 60,
      "step_frames": 17,
      "aggro_tiles": 12,
      "respawn_frames": 300,
      "attack": {
        "damage": 15,
        "windup_frames": 30,
        "active_frames": 6,
        "recovery_frames": 0,
        "exhaust_frames": 81,
        "arc": "ring",
        "knockback_tiles": 1,
        "knockback_frames_per_tile": 5
      },
      "knockback_tiles_received": 1,
      "knockback_frames_per_tile": 5
    }
  },
  "feel": {
    "hitstop_frames_hit": 3,
    "hitstop_frames_kill": 8,
    "shake_hit": 3.0,
    "shake_player_hit": 6.0,
    "shake_kill": 8.0,
    "shake_decay": 0.85
  }
}
```

- [ ] **Step 2: Point the test constant at the new shape**

In `test/game/world_test.rb` change line 10 to:

```ruby
  STEP = DATA["balance/combat"][:kits][:prowler][:step_frames]
```

(The suite will still fail on `[:player]` reads inside `world.rb` — expected; Tasks 6–8 fix the
code, Task 9 rewrites the tests. This task only locks the data contract.)

- [ ] **Step 3: Commit**

```bash
git add data/balance/combat.json test/game/world_test.rb
git commit -m "data: kit-shaped combat config — exhaust in, blanket invuln out (laws 1/5)"
```

### Task 6: `Creature` — the unified kit-driven actor

**Files:**
- Create: `src/game/creature.rb`
- Create: `test/game/creature_test.rb`
- (Player.rb / enemy.rb stay in tree until Task 8 deletes them.)

**Interfaces:**
- Consumes: `Game::GridWalker` (`step/dash/tick/moving?/tile_x/tile_y/px/py/teleport`),
  `Core::EventBus`, kit hash from Task 5, `Core::TileMap`.
- Produces (everything later builds on THESE exact signatures):
  `Creature.new(bus:, kit:, kit_name:, map:, tile:, faction:, name:)`;
  readers `hp max_hp kit kit_name faction name walker facing attack_state stagger dodge_cooldown`;
  queries `tile x y dead? hurt? moving? attacking_active? attack_can_hit? exhaust_ready?
  iframes?`; verbs `tick_body`, `face(dir)`, `step(dx, dy, blocked:)`,
  `start_attack -> bool`, `attack_landed!`, `attack_tiles`, `dodge(dir, blocked:) -> bool`,
  `take_hit(damage:, attacker:, blocked:) -> bool`, `stagger!(frames)`,
  `rebind(map:, tile:)`, `revive!(map:, tile:)`. `SIZE = 28`.

- [ ] **Step 1: Write the failing tests**

Create `test/game/creature_test.rb`:

```ruby
require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "game/creature"

class CreatureTest < Minitest::Test
  # player_spawn is the pre-Task-8 schema; Task 8 Step 1 migrates this
  # fixture to pack_spawn: [[1, 1], [2, 1], [3, 1]] with the TileMap change.
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["##########", "#........#", "#........#", "#........#", "##########"],
    player_spawn: [1, 1]
  )

  KIT = {
    max_hp: 100, step_frames: 15, aggro_tiles: 8,
    attack: { damage: 25, windup_frames: 6, active_frames: 4, recovery_frames: 10,
              exhaust_frames: 45, arc: "arc3", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    dodge: { tiles: 2, frames_per_tile: 7, iframes: 18, cooldown_frames: 50 },
    knockback_tiles_received: 1, knockback_frames_per_tile: 5
  }.freeze

  RING_KIT = {
    max_hp: 60, step_frames: 17, aggro_tiles: 12,
    attack: { damage: 15, windup_frames: 30, active_frames: 6, recovery_frames: 0,
              exhaust_frames: 81, arc: "ring", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    knockback_tiles_received: 1, knockback_frames_per_tile: 5
  }.freeze

  EVENTS = %i[attack_started attack_hit damage_dealt actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def creature(kit: KIT, tile: [3, 2], faction: :pack)
    Game::Creature.new(bus:, kit:, kit_name: :prowler, map: MAP, tile:, faction:, name: "c1")
  end

  def test_exhaust_gates_attack_cadence
    c = creature
    assert c.start_attack, "first swing starts"
    refute c.start_attack, "second swing refused while exhausted"
    44.times { c.tick_body }
    refute c.exhaust_ready?, "still exhausted at 44f"
    c.tick_body
    assert c.exhaust_ready?, "exhaust clears at 45f"
    assert c.start_attack, "swing available again at exhaust pace"
  end

  def test_no_blanket_invuln_two_attackers_both_land
    c = creature
    a1 = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    a2 = creature(kit: RING_KIT, tile: [4, 2], faction: :human)
    assert c.take_hit(damage: 15, attacker: a1)
    assert c.take_hit(damage: 15, attacker: a2), "no post-hit immunity: second attacker also lands"
    assert_equal 70, c.hp
  end

  def test_dodge_iframes_still_block
    c = creature
    attacker = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    assert c.dodge([1, 0])
    assert c.iframes?
    refute c.take_hit(damage: 15, attacker:), "dodge i-frames block (active defense stays)"
    assert_equal 100, c.hp
  end

  def test_arc3_and_ring_attack_tiles
    c = creature(tile: [3, 2])
    c.face([1, 0])
    assert_equal [[4, 2], [4, 3], [4, 1]], c.attack_tiles, "cardinal facing: front + diagonals"
    r = creature(kit: RING_KIT, tile: [3, 2])
    assert_equal 8, r.attack_tiles.length, "ring hits all Chebyshev neighbors"
    assert_includes r.attack_tiles, [2, 1]
    refute_includes r.attack_tiles, [3, 2], "ring excludes own tile"
  end

  def test_stagger_blocks_verbs_until_expired
    c = creature
    c.stagger!(20)
    refute c.start_attack, "staggered: no attack"
    refute c.step(1, 0, blocked: []), "staggered: no step"
    refute c.dodge([1, 0]), "staggered: no dodge"
    20.times { c.tick_body }
    assert c.step(1, 0, blocked: []), "stagger expired: verbs return"
  end

  def test_death_emits_actor_died_with_killer
    c = creature
    killer = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    died = nil
    bus.subscribe(:actor_died) { |e| died = e }
    4.times { c.take_hit(damage: 25, attacker: killer) }
    bus.process
    assert c.dead?
    assert_equal c, died[:actor]
    assert_equal killer, died[:killer]
  end

  def test_kill_does_not_double_fire
    c = creature
    killer = creature(kit: RING_KIT, tile: [2, 2], faction: :human)
    4.times { c.take_hit(damage: 25, attacker: killer) }
    refute c.take_hit(damage: 25, attacker: killer), "dead creatures take no hits"
  end
end
```

- [ ] **Step 2: Run to verify failure**

Run: `export PATH="/c/Ruby34-x64/bin:$PATH" && ruby -Isrc -Itest test/game/creature_test.rb`
Expected: FAIL — `cannot load such file -- game/creature`

- [ ] **Step 3: Implement `src/game/creature.rb`**

```ruby
require "game/grid_walker"

module Game
  # The unified actor: ANY creature on the grid — pack member or human —
  # is a Creature with a kit (all numbers from data), a faction, and a body.
  # Controllers (possessed or AI) drive it through public verbs; the World
  # resolves combat by reading the ATTACKER's kit (never a player path).
  class Creature
    SIZE = 28

    RING = [[0, -1], [1, 0], [0, 1], [-1, 0], [1, -1], [1, 1], [-1, 1], [-1, -1]].freeze

    attr_reader :hp, :max_hp, :kit, :kit_name, :faction, :name, :walker,
                :facing, :attack_state, :stagger, :dodge_cooldown

    def initialize(bus:, kit:, kit_name:, map:, tile:, faction:, name:)
      @bus = bus
      @kit = kit
      @kit_name = kit_name
      @faction = faction
      @name = name
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
      @max_hp = kit[:max_hp]
      @hp = @max_hp
      @facing = [1, 0]
      @attack_state = :idle
      @state_frames = 0
      @exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      @attack_landed = false
    end

    def tile = [@walker.tile_x, @walker.tile_y]
    def x = @walker.px
    def y = @walker.py
    def dead? = @hp <= 0
    def moving? = @walker.moving?
    def hurt? = @hurt_frames.positive?
    def iframes? = @iframes.positive?
    def exhaust_ready? = @exhaust <= 0
    def staggered? = @stagger.positive?
    def attacking_active? = @attack_state == :active
    def telegraphing? = @attack_state == :windup

    # One swing hits at most once (per-swing hit registry — law 3's "at most
    # once per victim" is trivially satisfied by single-victim swings).
    def attack_landed! = @attack_landed = true
    def attack_can_hit? = attacking_active? && !@attack_landed

    # Timers + tween advance every frame regardless of controller.
    def tick_body
      @walker.tick
      return if dead?
      @exhaust -= 1 if @exhaust.positive?
      @iframes -= 1 if @iframes.positive?
      @stagger -= 1 if @stagger.positive?
      @dodge_cooldown -= 1 if @dodge_cooldown.positive?
      @hurt_frames -= 1 if @hurt_frames.positive?
      advance_attack_state
    end

    def face(dir)
      @facing = dir unless dir == [0, 0]
    end

    def step(dx, dy, blocked:)
      return false if dead? || staggered? || %i[windup active].include?(@attack_state)
      @walker.step(dx, dy, frames: @kit[:step_frames], blocked:)
    end

    # Exhaust is the ONLY cadence gate (law 1): a swing may not begin until
    # the clock runs out. Creature-owned, swap-inert by construction (law 4).
    def start_attack
      return false if dead? || staggered? || @attack_state != :idle || !exhaust_ready?
      @attack_state = :windup
      @state_frames = @kit[:attack][:windup_frames]
      @exhaust = @kit[:attack][:exhaust_frames]
      @attack_landed = false
      @bus.emit(:attack_started, attacker: self)
      true
    end

    def attack_tiles
      tx, ty = tile
      case @kit[:attack][:arc]
      when "ring"
        RING.map { |(dx, dy)| [tx + dx, ty + dy] }
      else # "arc3": front + flanks (diagonal facing -> cardinal components)
        fx, fy = @facing
        front = [tx + fx, ty + fy]
        flanks =
          if fx != 0 && fy != 0
            [[tx + fx, ty], [tx, ty + fy]]
          else
            [[front[0] + fy, front[1] + fx], [front[0] - fy, front[1] - fx]]
          end
        [front, *flanks]
      end
    end

    def dodge(dir, blocked: [])
      cfg = @kit[:dodge]
      return false if dead? || staggered? || cfg.nil?
      return false unless @dodge_cooldown.zero? && @attack_state == :idle
      d = dir == [0, 0] ? @facing : dir
      moved = @walker.dash(d[0], d[1], max_tiles: cfg[:tiles],
                           frames_per_tile: cfg[:frames_per_tile], blocked:)
      return false unless moved
      @iframes = [@iframes, cfg[:iframes]].max
      @dodge_cooldown = cfg[:cooldown_frames]
      @bus.emit(:dodged, actor: self)
      true
    end

    # No blanket post-hit invuln (law 5): only dodge i-frames block. Damage
    # pacing comes from each attacker's own exhaust cadence.
    def take_hit(damage:, attacker:, blocked: [])
      return false if iframes? || dead?
      @hp = [@hp - damage, 0].max
      @hurt_frames = 8
      @attack_state = :idle
      knock_away_from(attacker.tile, blocked)
      if dead?
        @bus.emit(:actor_died, actor: self, killer: attacker, faction: @faction)
      else
        @bus.emit(:damage_dealt, target: self, hp: @hp, attacker:)
      end
      true
    end

    def stagger!(frames)
      @stagger = [@stagger, frames].max
    end

    def rebind(map:, tile:)
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
    end

    def revive!(map:, tile:)
      @hp = @max_hp
      @attack_state = :idle
      @exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      rebind(map:, tile:)
    end

    private

    def knock_away_from(from_tile, blocked)
      dx = (@walker.tile_x - from_tile[0]).clamp(-1, 1)
      dy = (@walker.tile_y - from_tile[1]).clamp(-1, 1)
      dx = 1 if dx.zero? && dy.zero?
      @walker.dash(dx, dy, max_tiles: @kit[:knockback_tiles_received],
                   frames_per_tile: @kit[:knockback_frames_per_tile], blocked:)
    end

    def advance_attack_state
      return if @attack_state == :idle
      @state_frames -= 1
      return if @state_frames.positive?
      case @attack_state
      when :windup
        @attack_state = :active
        @state_frames = @kit[:attack][:active_frames]
      when :active
        @attack_state = :recovery
        @state_frames = @kit[:attack][:recovery_frames]
        @attack_state = :idle if @state_frames.zero?
      when :recovery
        @attack_state = :idle
      end
    end
  end
end
```

- [ ] **Step 4: Run the creature tests**

Run: `ruby -Isrc -Itest test/game/creature_test.rb`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add src/game/creature.rb test/game/creature_test.rb
git commit -m "feat: Creature — unified kit-driven actor (exhaust, no blanket invuln, stagger)"
```

### Task 7: Controllers + Pack

**Files:**
- Create: `src/game/controllers.rb`
- Create: `src/game/pack.rb`
- Create: `test/game/pack_test.rb`

**Interfaces:**
- Consumes: `Creature` verbs from Task 6; `Core::ScriptedInput`-shaped input (`down?(action)`).
- Produces:
  `PossessedController.new` — `rearm!(input)` (mask currently-down actions; call on every
  possession change), `tick(creature, input, view)`. Reads actions `:left :right :up :down
  :attack :dodge` (`:swap` is handled by World, not here).
  `AiController.new` — `tick(creature, view)`. Chases nearest hostile via `view.flow_to(target)`,
  attacks when target in kit range, follows the possessed when idle (allies only).
  `view` duck-type (World provides it in Task 8): `hostiles_for(creature)` → living creatures
  of the other faction; `flow_to(creature)` → FlowField anchored on that creature;
  `blocked_for(creature)` → tiles it may not enter; `possessed` → creature.
  `Pack.new(members:, stagger_frames:)` — `members`, `possessed`, `living`, `wipe?`,
  `swap_next! -> Creature|nil` (voluntary, no stagger), `forced_swap! -> Creature|nil`
  (nearest living to the dead body, applies stagger).

- [ ] **Step 1: Write the failing tests**

Create `test/game/pack_test.rb`:

```ruby
require_relative "../test_helper"
require "core/event_bus"
require "core/tile_map"
require "core/input"
require "game/creature"
require "game/pack"
require "game/controllers"

class PackTest < Minitest::Test
  MAP = Core::TileMap.new(
    tile_size: 32, display_name: "test", palette: {},
    tiles: ["############", "#..........#", "#..........#", "#..........#", "############"],
    player_spawn: [1, 1]
  )
  KIT = {
    max_hp: 100, step_frames: 15, aggro_tiles: 8,
    attack: { damage: 25, windup_frames: 6, active_frames: 4, recovery_frames: 10,
              exhaust_frames: 45, arc: "arc3", knockback_tiles: 1, knockback_frames_per_tile: 5 },
    dodge: { tiles: 2, frames_per_tile: 7, iframes: 18, cooldown_frames: 50 },
    knockback_tiles_received: 1, knockback_frames_per_tile: 5
  }.freeze
  EVENTS = %i[attack_started attack_hit damage_dealt actor_died dodged].freeze

  def bus = @bus ||= Core::EventBus.new.register(*EVENTS)

  def member(tile, name)
    Game::Creature.new(bus:, kit: KIT, kit_name: :prowler, map: MAP, tile:, faction: :pack, name:)
  end

  def pack
    @pack ||= Game::Pack.new(
      members: [member([1, 1], "a"), member([5, 1], "b"), member([9, 1], "c")],
      stagger_frames: 20
    )
  end

  def test_swap_cycles_living_members
    assert_equal "a", pack.possessed.name
    pack.swap_next!
    assert_equal "b", pack.possessed.name
    pack.swap_next!
    assert_equal "c", pack.possessed.name
    pack.swap_next!
    assert_equal "a", pack.possessed.name, "cycles back around"
  end

  def test_swap_skips_dead_members
    killer = member([2, 2], "k")
    4.times { pack.members[1].take_hit(damage: 25, attacker: killer) }
    pack.swap_next!
    assert_equal "c", pack.possessed.name, "dead b is skipped"
  end

  def test_voluntary_swap_has_no_stagger
    pack.swap_next!
    refute pack.possessed.staggered?
  end

  def test_forced_swap_picks_nearest_living_and_staggers
    killer = member([2, 2], "k")
    4.times { pack.possessed.take_hit(damage: 25, attacker: killer) } # kills a at [1,1]
    survivor = pack.forced_swap!
    assert_equal "b", survivor.name, "b at [5,1] is nearer to a than c at [9,1]"
    assert survivor.staggered?, "forced swap costs a stagger (law 2)"
  end

  def test_wipe_detection
    killer = member([2, 2], "k")
    refute pack.wipe?
    pack.members.each { |m| 4.times { m.take_hit(damage: 25, attacker: killer) } }
    assert pack.wipe?
    assert_nil pack.forced_swap!, "no survivor to swap to"
  end

  def test_possessed_controller_edge_trigger_masks_held_keys
    input = Core::ScriptedInput.new(frames: { 0 => %i[attack right], 1 => %i[attack right], 2 => [] , 3 => %i[attack] })
    ctl = Game::PossessedController.new
    c = pack.possessed
    input.update(0)
    ctl.rearm!(input)              # swap happened while attack+right held
    ctl.tick(c, input, nil)
    assert_equal :idle, c.attack_state, "held attack masked after swap"
    assert_equal [1, 1], c.tile, "held right masked after swap"
    input.update(1)
    ctl.tick(c, input, nil)
    assert_equal :idle, c.attack_state, "still masked while still held"
    input.update(2)
    ctl.tick(c, input, nil)        # released this frame -> unmask
    input.update(3)
    ctl.tick(c, input, nil)        # re-pressed -> fires
    assert_equal :windup, c.attack_state, "re-press after release fires (edge-trigger, law 2)"
  end
end
```

- [ ] **Step 2: Run to verify failure**

Run: `ruby -Isrc -Itest test/game/pack_test.rb`
Expected: FAIL — `cannot load such file -- game/pack`.

- [ ] **Step 3: Implement `src/game/pack.rb`**

```ruby
module Game
  # The three creatures + the possession pointer. Possession is a pointer
  # move, never a state copy — exhaust/buffers stay creature-owned (law 4).
  class Pack
    attr_reader :members, :possessed

    def initialize(members:, stagger_frames:)
      @members = members
      @possessed = members.first
      @stagger_frames = stagger_frames
    end

    def living = @members.reject(&:dead?)
    def wipe? = living.empty?

    # Voluntary Tab swap: next living member in roster order, no stagger.
    def swap_next!
      order = @members.rotate(@members.index(@possessed) + 1)
      target = order.find { |m| !m.dead? && !m.equal?(@possessed) }
      return nil unless target
      @possessed = target
    end

    # Death swap: control snaps to the NEAREST living member (Chebyshev from
    # the dead body) and pays the stagger — losing a body costs a beat (law 2).
    def forced_swap!
      dead_at = @possessed.tile
      target = living.min_by do |m|
        [[(m.tile[0] - dead_at[0]).abs, (m.tile[1] - dead_at[1]).abs].max, @members.index(m)]
      end
      return nil unless target
      target.stagger!(@stagger_frames)
      @possessed = target
    end
  end
end
```

- [ ] **Step 4: Implement `src/game/controllers.rb`**

```ruby
module Game
  # Drives the possessed creature from live/scripted input. Post-swap inputs
  # are edge-triggered (law 2): every action held at rearm! time is masked
  # until it is released once — a buffered attack can't ghost-fire from the
  # new body, and a held dodge can't burn the new body's cooldown.
  class PossessedController
    ACTIONS = %i[left right up down attack dodge].freeze

    def initialize
      @masked = []
    end

    def rearm!(input)
      @masked = ACTIONS.select { |a| input.down?(a) }
    end

    def tick(creature, input, _view)
      @masked.reject! { |a| !input.down?(a) }
      return if creature.dead?

      dir = held_direction(input)
      creature.face(dir)
      if down?(input, :dodge)
        creature.dodge(dir, blocked: @blocked || [])
      elsif dir != [0, 0]
        creature.step(dir[0], dir[1], blocked: @blocked || [])
      end
      creature.start_attack if down?(input, :attack)
    end

    # World supplies body-blocking per frame (it knows all occupied tiles).
    # NB: plain def — Ruby forbids endless method definitions for setters.
    def blocked=(tiles)
      @blocked = tiles
    end

    private

    def down?(input, action) = input.down?(action) && !@masked.include?(action)

    def held_direction(input)
      dx = (down?(input, :right) ? 1 : 0) - (down?(input, :left) ? 1 : 0)
      dy = (down?(input, :down) ? 1 : 0) - (down?(input, :up) ? 1 : 0)
      [dx, dy]
    end
  end

  # Husk-grade brain (deliberately dumb — gambits are A1): aggro on the
  # nearest hostile, chase downhill on a flow field anchored on the target,
  # swing when the target is in kit range. Allies additionally follow the
  # possessed when nothing is in aggro range, so they never get left behind.
  class AiController
    FOLLOW_DISTANCE = 2

    def tick(creature, view)
      return if creature.dead?

      target = nearest(creature, view.hostiles_for(creature))
      if target && chebyshev(creature.tile, target.tile) <= creature.kit[:aggro_tiles]
        engage(creature, target, view)
      elsif creature.faction == :pack && !view.possessed.equal?(creature)
        follow(creature, view.possessed, view)
      end
    end

    private

    def engage(creature, target, view)
      dist = chebyshev(creature.tile, target.tile)
      if in_attack_range?(creature, dist)
        face_toward(creature, target)
        creature.start_attack
      elsif !creature.moving?
        chase_step(creature, target, view)
      end
    end

    def in_attack_range?(creature, dist)
      dist <= 1 # M1: both kits are melee (arc3 reaches Chebyshev-adjacent via facing)
    end

    def follow(creature, possessed, view)
      return if creature.moving?
      return if chebyshev(creature.tile, possessed.tile) <= FOLLOW_DISTANCE
      chase_step(creature, possessed, view)
    end

    def chase_step(creature, target, view)
      return if creature.moving?
      blocked = view.blocked_for(creature)
      dir = view.flow_to(target).downhill_from(*creature.tile, blocked:)
      return unless dir
      creature.face(dir)
      creature.step(dir[0], dir[1], blocked:)
    end

    def face_toward(creature, target)
      dx = (target.tile[0] - creature.tile[0]).clamp(-1, 1)
      dy = (target.tile[1] - creature.tile[1]).clamp(-1, 1)
      creature.face([dx, dy])
    end

    def nearest(creature, hostiles)
      hostiles.min_by.with_index { |h, i| [chebyshev(creature.tile, h.tile), i] }
    end

    def chebyshev((ax, ay), (bx, by)) = [(bx - ax).abs, (by - ay).abs].max
  end
end
```

- [ ] **Step 5: Run the pack tests**

Run: `ruby -Isrc -Itest test/game/pack_test.rb`
Expected: all PASS. (AiController is exercised through the World integration tests in Task 9 —
it needs a real view.)

- [ ] **Step 6: Commit**

```bash
git add src/game/pack.rb src/game/controllers.rb test/game/pack_test.rb
git commit -m "feat: Pack + controllers — swap/forced-swap/stagger, edge-trigger input mask"
```

### Task 8: World refactor — factions, kit-read combat, scoped hitstop, pack lifecycle

**Files:**
- Modify: `src/core/tile_map.rb` (schema: `pack_spawn` array replaces `player_spawn`)
- Modify: `data/zones/town.json`, `data/zones/threketh.json` (`pack_spawn`)
- Rewrite: `src/game/world.rb` (full replacement below)
- Delete: `src/game/player.rb`, `src/game/enemy.rb`
- Modify: `harness/scenes/world_scene.rb` (event list + seed param, code below)
- Test: compile-level only here — the behavioral suite is Task 9 (`test/game/world_test.rb`)

**Interfaces:**
- Consumes: Tasks 5–7 (`[:kits]` data shape, `Creature`, `Pack`, controllers).
- Produces (renderer/harness/tests build on these):
  `World.new(data, seed: 0)`; readers `bus pack feel states frame camera zone_name rng`;
  `possessed` → `pack.possessed`; `humans` → living+dead hostile roster of current zone;
  `actors` → pack.members + humans (living only); `tick(input)`; `map`, `banner?` unchanged.
  View API for AiController: `hostiles_for(creature)`, `flow_to(creature)`,
  `blocked_for(creature)`.
  EVENTS: `%i[attack_started attack_hit damage_dealt actor_died dodged telegraph
  zone_entered possession_changed pack_wiped pack_respawned]`.
  States: `:world ↔ :nest_respawn`. `HOME_ZONE = "town"` (M1 nest stand-in).
- TileMap: `pack_spawn` → array of ≥3 distinct passable tiles; `player_spawn` key removed
  from schema and both zone files. `enemy_spawns`/`transitions` unchanged.

- [ ] **Step 1: TileMap schema — `pack_spawn`**

In `src/core/tile_map.rb`: rename the reader and load `pack_spawn`; validate every tile and
distinctness. Replace `@player_spawn = cfg.fetch(:player_spawn)` with
`@pack_spawn = cfg.fetch(:pack_spawn)` and the attr; replace the
`check_passable!("player_spawn", @player_spawn)` line with:

```ruby
      raise BadMap, "pack_spawn needs >= 3 tiles" if @pack_spawn.length < 3
      raise BadMap, "pack_spawn tiles must be distinct" if @pack_spawn.uniq.length != @pack_spawn.length
      @pack_spawn.each { |s| check_passable!("pack_spawn", s) }
```

Also update the two test fixtures written in Tasks 6–7 (`creature_test.rb`, `pack_test.rb`)
from `player_spawn: [1, 1]` to `pack_spawn: [[1, 1], [2, 1], [3, 1]]`, and
`test/core/data_store_test.rb` if it references zone shape (check with
`grep -rn "player_spawn" test/ src/ harness/ data/` — every hit gets migrated in this task).

- [ ] **Step 2: Zone files**

`data/zones/town.json`: replace `"player_spawn": [8, 8]` with
`"pack_spawn": [[8, 8], [7, 8], [9, 8]]` (row 8 is open floor).
`data/zones/threketh.json`: replace its `"player_spawn"` with
`"pack_spawn": [[2, 12], [2, 11], [2, 13]]` — the gate-arrival column; TileMap's validator
raises `BadMap` at load if any tile is a wall, which `rake` surfaces immediately (fix by
picking adjacent open tiles from the ASCII if so).

- [ ] **Step 3: Rewrite `src/game/world.rb`**

```ruby
require "core/event_bus"
require "core/state_stack"
require "core/tile_map"
require "game/creature"
require "game/pack"
require "game/controllers"
require "game/feel"
require "game/camera"
require "game/flow_field"

module Game
  # The sim: a pack of creatures (one possessed, the rest AI) hunting through
  # zones against hostile humans (M1 stand-in kit: husk). Combat resolves
  # from the ATTACKER's kit via factions — there is no player path. Pure and
  # deterministic; never touches Gosu. Seed plumbs the sim PRNG (unused by
  # M1 logic; the plumbing is determinism law 3).
  class World
    EVENTS = %i[
      attack_started attack_hit damage_dealt actor_died dodged telegraph
      zone_entered possession_changed pack_wiped pack_respawned
    ].freeze

    TRANSITIONS = { world: %i[nest_respawn], nest_respawn: %i[world] }.freeze

    HOME_ZONE = "town".freeze # fiction-pending: the nest

    attr_reader :bus, :pack, :feel, :states, :frame, :camera, :zone_name, :rng

    def initialize(data, seed: 0)
      @data = data
      @display = data["display"]
      @balance = data["balance/combat"]
      @rng = Random.new(seed)
      @bus = Core::EventBus.new.register(*EVENTS)
      @states = Core::StateStack.new(initial: :world, transitions: TRANSITIONS)
      @feel = Feel.new(@balance[:feel])
      @frame = 0
      @respawn_timer = 0
      @banner_timer = 0
      @zones = {}
      @humans = Hash.new { |h, k| h[k] = [] }
      @human_respawns = Hash.new { |h, k| h[k] = [] }
      @controller = PossessedController.new
      @ai = AiController.new
      @swap_was_down = false
      load_zones
      spawn_pack
      wire_events
      enter_zone(HOME_ZONE, map.pack_spawn)
    end

    def map = @zones.fetch(@zone_name)
    def humans = @humans[@zone_name]
    def possessed = @pack.possessed
    def banner? = @banner_timer.positive?
    def actors = (@pack.members + humans).reject(&:dead?)

    def tick(input)
      if @feel.hitstop?
        @feel.tick
        @bus.process
        @frame += 1
        return
      end

      @banner_timer -= 1 if @banner_timer.positive?

      case @states.current
      when :world
        tick_world(input)
      when :nest_respawn
        @respawn_timer -= 1
        if @respawn_timer <= 0
          @states.transition_to(:world)
          respawn_pack
        end
      end

      c = possessed
      @camera.tick(c.x + Creature::SIZE / 2.0, c.y + Creature::SIZE / 2.0)
      @feel.tick
      @bus.process
      @frame += 1
    end

    # --- view API (AiController duck-type) ------------------------------

    def hostiles_for(creature)
      creature.faction == :pack ? humans.reject(&:dead?) : @pack.living
    end

    def blocked_for(creature)
      actors.reject { |a| a.equal?(creature) }.map(&:tile)
    end

    # Flow fields anchor on ANY creature, cached per anchor, recomputed only
    # when the anchor's tile changes. Cache clears on zone change.
    def flow_to(anchor)
      @flow_cache ||= {}
      entry = (@flow_cache[anchor] ||= { field: FlowField.new(map), tile: nil })
      if entry[:tile] != anchor.tile
        entry[:field].recompute!(anchor.tile)
        entry[:tile] = anchor.tile
      end
      entry[:field]
    end

    private

    def tick_world(input)
      handle_swap(input)
      # Forced swap happens at bus-process time (no input in scope there), so
      # the edge-trigger re-arm is deferred to the next tick — law 2 applies
      # to BOTH swap kinds: no held key may leak into the new body.
      if @rearm_needed
        @controller.rearm!(input)
        @rearm_needed = false
      end
      @pack.members.each(&:tick_body)
      humans.each(&:tick_body)

      @controller.blocked = blocked_for(possessed)
      @controller.tick(possessed, input, self)
      @pack.living.each { |m| @ai.tick(m, self) unless m.equal?(possessed) }
      humans.each { |h| emit_telegraph_edge(h); @ai.tick(h, self) }

      check_transition
      resolve_attacks
      respawn_due_humans
      prune_flow_cache
    end

    # Tab swap: rising edge only, world-level (the controller mask handles
    # every OTHER action; swap itself must not autorepeat while held).
    def handle_swap(input)
      down = input.down?(:swap)
      if down && !@swap_was_down && @pack.living.length > 1
        from = possessed
        @pack.swap_next!
        @controller.rearm!(input)
        @bus.emit(:possession_changed, from:, to: possessed, forced: false)
      end
      @swap_was_down = down
    end

    # Any active unlanded swing hits the FIRST living hostile on its tiles
    # (attack_tiles order is deterministic: front-first for arcs, fixed ring
    # order otherwise). Damage comes from the attacker's kit — the law.
    def resolve_attacks
      actors.each do |attacker|
        next unless attacker.attack_can_hit?
        foes = hostiles_for(attacker)
        victim = attacker.attack_tiles.filter_map { |t| foes.find { |f| !f.dead? && f.tile == t } }.first
        next unless victim
        attacker.attack_landed!
        victim.take_hit(damage: attacker.kit[:attack][:damage], attacker:,
                        blocked: blocked_for(victim))
        @bus.emit(:attack_hit, attacker:, victim:)
      end
    end

    # AiController drives the state machine; the telegraph event fires on the
    # windup rising edge so feel/renderer/harness can aim at it.
    def emit_telegraph_edge(human)
      @telegraphing ||= {}
      now = human.telegraphing?
      @bus.emit(:telegraph, actor: human) if now && !@telegraphing[human]
      @telegraphing[human] = now
    end

    def check_transition
      c = possessed
      return if c.walker.moving? || c.dead?
      t = map.transition_at(*c.tile)
      return unless t
      enter_zone(t[:to], arrival_tiles(t[:to], t[:spawn]))
    end

    # The whole pack moves through a gate: possessed lands on the gate spawn,
    # allies on the nearest passable neighbors (deterministic STEPS order).
    def arrival_tiles(zone, spawn)
      zmap = @zones.fetch(zone)
      tiles = [spawn]
      FlowField::STEPS.each do |(dx, dy)|
        break if tiles.length >= @pack.living.length
        cand = [spawn[0] + dx, spawn[1] + dy]
        tiles << cand if zmap.passable?(*cand) && !tiles.include?(cand)
      end
      tiles
    end

    def enter_zone(name, tiles)
      raise ArgumentError, "unknown zone #{name}" unless @zones.key?(name)
      @zone_name = name
      @flow_cache = {}
      placed = 0
      # Possessed gets the first tile; living allies the rest, in roster order.
      ([possessed] + (@pack.living - [possessed])).each do |m|
        m.rebind(map:, tile: tiles[placed] || tiles.first)
        placed += 1
      end
      @camera = Camera.new(
        view_w: @display[:view_width], view_h: @display[:view_height],
        world_w: map.pixel_width, world_h: map.pixel_height,
        lerp: @display[:camera_lerp]
      )
      @camera.snap!(possessed.x + Creature::SIZE / 2.0, possessed.y + Creature::SIZE / 2.0)
      @banner_timer = @display[:zone_banner_frames]
      @bus.emit(:zone_entered, zone: name)
    end

    def load_zones
      names = @data.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
      names.each { |n| @zones[n] = Core::TileMap.new(@data["zones/#{n}"]) }
      seed_humans
    end

    def seed_humans
      @zones.each do |zone, zmap|
        zmap.enemy_spawns.each do |kit_name, spawns|
          spawns.each { |tile| add_human(zone, kit_name, tile) }
        end
      end
    end

    def add_human(zone, kit_name, tile)
      kit = @balance[:kits].fetch(kit_name.to_sym)
      @humans[zone] << Creature.new(bus: @bus, kit:, kit_name: kit_name.to_sym,
                                    map: @zones[zone], tile:, faction: :human,
                                    name: "#{kit_name}#{@humans[zone].length}")
    end

    def spawn_pack
      cfg = @balance[:pack]
      town = @zones.fetch(HOME_ZONE)
      @zone_name = HOME_ZONE
      members = cfg[:members].each_with_index.map do |kit_name, i|
        Creature.new(bus: @bus, kit: @balance[:kits].fetch(kit_name.to_sym),
                     kit_name: kit_name.to_sym, map: town, tile: town.pack_spawn[i],
                     faction: :pack, name: "pack#{i}")
      end
      @pack = Pack.new(members:, stagger_frames: cfg[:swap_stagger_frames])
    end

    def respawn_pack
      @zone_name = HOME_ZONE
      @pack.members.each_with_index { |m, i| m.revive!(map:, tile: map.pack_spawn[i]) }
      enter_zone(HOME_ZONE, map.pack_spawn)
      @bus.emit(:pack_respawned)
    end

    def respawn_due_humans
      due, rest = @human_respawns[@zone_name].partition { |r| r[:at_frame] <= @frame }
      @human_respawns[@zone_name] = rest
      due.each { |r| add_human(@zone_name, r[:kit_name], r[:tile]) }
    end

    def prune_flow_cache
      @flow_cache&.select! { |anchor, _| !anchor.dead? }
      @telegraphing&.select! { |actor, _| !actor.dead? }
    end

    # Feel is scoped to the possessed body (law 5): its fights hitstop and
    # shake; ally/AI-vs-AI hits emit events only — the world never freezes
    # for a fight the player isn't in.
    def wire_events
      @bus.subscribe(:attack_hit) do |e|
        if e[:victim].equal?(possessed)
          @feel.on_player_hit
        elsif e[:attacker].equal?(possessed)
          @feel.on_hit
        end
      end

      @bus.subscribe(:actor_died) do |e|
        if e[:faction] == :human
          @feel.on_kill if e[:killer].equal?(possessed)
          schedule_human_respawn(e[:actor])
        elsif e[:actor].equal?(possessed)
          handle_possessed_death
        end
      end
    end

    def handle_possessed_death
      from = possessed
      survivor = @pack.forced_swap!
      if survivor
        @rearm_needed = true
        @feel.on_kill # losing a body lands like a kill against you
        @bus.emit(:possession_changed, from:, to: survivor, forced: true)
      else
        @bus.emit(:pack_wiped)
        @respawn_timer = @balance[:respawn_frames]
        @states.transition_to(:nest_respawn)
      end
    end

    def schedule_human_respawn(human)
      delay = human.kit[:respawn_frames]
      return unless delay
      spawns = map.enemy_spawns[human.kit_name] || [human.tile]
      home = spawns.min_by { |(sx, sy)| (sx - human.tile[0]).abs + (sy - human.tile[1]).abs }
      @human_respawns[@zone_name] << { kit_name: human.kit_name, tile: home, at_frame: @frame + delay }
      humans.delete(human)
    end
  end
end
```

- [ ] **Step 4: Delete the retired classes and update the harness scene**

```bash
git rm src/game/player.rb src/game/enemy.rb
```

Rewrite `harness/scenes/world_scene.rb` (events + seed):

```ruby
require "core/data_store"
require "game/world"
require "app/renderer"

# Replay adapter: the REAL world sim + REAL renderer under scripted input.
# No mocks — what the harness captures is what the player sees.
module Harness
  module Scenes
    class WorldScene
      attr_reader :world

      # Logs key sim events with frame numbers so capture scripts can be
      # aimed at exact moments (telegraph, swap, wipe, zone change).
      def initialize(width:, height:, seed: 0)
        data = Core::DataStore.new(File.expand_path("../../data", __dir__))
        @world = Game::World.new(data, seed:)
        @renderer = App::Renderer.new
        %i[telegraph attack_hit actor_died dodged possession_changed
           pack_wiped pack_respawned zone_entered].each do |ev|
          @world.bus.subscribe(ev) { |e| puts "EVENT #{ev} frame=#{@world.frame} #{describe(e)}" }
        end
      end

      def tick(input) = @world.tick(input)
      def draw = @renderer.draw(@world)

      private

      # Payloads carry live Creature objects — log stable identifiers.
      def describe(e)
        e.payload.map { |k, v| "#{k}=#{v.respond_to?(:name) ? v.name : v.inspect}" }.join(" ")
      end
    end
  end
end
```

- [ ] **Step 5: Compile check (unit suites green; world_test red is EXPECTED until Task 9)**

Run: `ruby -Isrc -Itest test/game/creature_test.rb && ruby -Isrc -Itest test/game/pack_test.rb && ruby -Isrc -e 'require "core/data_store"; require "game/world"; w = Game::World.new(Core::DataStore.new("data")); 600.times { w.tick(Core::ScriptedInput.new(frames: {})) rescue (require "core/input"; retry) }; puts "SMOKE OK frame=#{w.frame} zone=#{w.zone_name}"'`
— if the inline smoke is awkward, write it as a plain script instead:
`ruby -Isrc -r core/data_store -r core/input -r game/world -e 'w = Game::World.new(Core::DataStore.new("data")); i = Core::ScriptedInput.new(frames: {}); 600.times { i.update(w.frame); w.tick(i) }; puts "SMOKE OK frame=#{w.frame} zone=#{w.zone_name}"'`
Expected: `SMOKE OK frame=600 zone=town`.

- [ ] **Step 6: Commit**

```bash
git add -A src/game src/core/tile_map.rb data/zones harness/scenes/world_scene.rb test
git commit -m "refactor: World on factions + Pack — kit-read combat, scoped hitstop, forced swap (laws 1-5)"
```

### Task 9: Rewrite the world integration suite around possession

**Files:**
- Rewrite: `test/game/world_test.rb` (full replacement below)

**Interfaces:**
- Consumes: World API from Task 8. No mocks — real DataStore, real zones, real sim.

- [ ] **Step 1: Replace `test/game/world_test.rb`**

```ruby
require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# Integration tests against the REAL data files and the REAL sim — no mocks.
# All assertions are on TILES, not pixels (grid movement doctrine).
class WorldTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  STEP = DATA["balance/combat"][:kits][:prowler][:step_frames]
  EXHAUST = DATA["balance/combat"][:kits][:prowler][:attack][:exhaust_frames]
  STAGGER = DATA["balance/combat"][:pack][:swap_stagger_frames]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def hold(action, from, to)
    (from..to).to_h { |f| [f.to_s, [action.to_s]] }
  end

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def enter_dungeon(world)
    drive(world, scripted(hold(:right, 0, STEP * 30 - 1)), STEP * 30)
    assert_equal "threketh", world.zone_name
  end

  def nearest_human(world)
    px, py = world.possessed.tile
    world.humans.reject(&:dead?).min_by { |h| [(h.tile[0] - px).abs, (h.tile[1] - py).abs].max }
  end

  def kill(creature, by:)
    creature.take_hit(damage: creature.hp, attacker: by) until creature.dead?
  end

  # --- pack + possession -------------------------------------------------

  def test_pack_of_three_spawns_in_town
    assert_equal 3, world.pack.members.length
    assert_equal world.map.pack_spawn.take(3).sort, world.pack.members.map(&:tile).sort
    assert_equal world.pack.members.first, world.possessed
    assert_empty world.humans
  end

  def test_tab_swaps_to_next_living_and_camera_follows
    a = world.possessed
    drive(world, scripted({ "0" => ["swap"] }), 1)
    refute_equal a, world.possessed, "Tab moves possession"
    refute world.possessed.staggered?, "voluntary swap has no stagger"
  end

  def test_held_swap_does_not_autorepeat
    swaps = 0
    world.bus.subscribe(:possession_changed) { swaps += 1 }
    drive(world, scripted(hold(:swap, 0, 29)), 30)
    assert_equal 1, swaps, "30 held frames = exactly one swap (rising edge)"
  end

  def test_forced_swap_on_possessed_death_with_stagger
    changes = []
    world.bus.subscribe(:possession_changed) { |e| changes << e }
    victim = world.possessed
    hunter = world.pack.members[1] # any creature works as attacker identity
    kill(victim, by: hunter)
    drive(world, scripted({}), 1) # flush bus
    assert_equal 1, changes.length
    assert changes.first[:forced]
    refute_equal victim, world.possessed
    assert world.possessed.staggered?, "forced swap pays the stagger (law 2)"
    assert_equal :world, world.states.current, "forced swap is NOT a state change"
  end

  def test_wipe_respawns_whole_pack_in_town
    wiped = false
    world.bus.subscribe(:pack_wiped) { wiped = true }
    enter_dungeon(world)
    hunter = world.humans.first
    world.pack.members.each { |m| kill(m, by: hunter) }
    drive(world, scripted({}), 1)
    assert wiped
    assert_equal :nest_respawn, world.states.current
    drive(world, scripted({}), DATA["balance/combat"][:respawn_frames] + 5)
    assert_equal :world, world.states.current
    assert_equal "town", world.zone_name, "wipe sends the pack home"
    assert world.pack.members.all? { |m| m.hp == m.max_hp }, "everyone revives full"
  end

  # --- combat laws ---------------------------------------------------------

  def test_held_attack_swings_at_exhaust_pace
    starts = 0
    world.bus.subscribe(:attack_started) { starts += 1 }
    drive(world, scripted(hold(:attack, 0, EXHAUST * 3 - 1)), EXHAUST * 3)
    assert_equal 3, starts, "held attack = one swing per exhaust window, not per frame"
  end

  def test_swap_is_exhaust_inert
    a = world.possessed
    drive(world, scripted({ "0" => ["attack"] }), 1)
    refute a.exhaust_ready?, "a just paid its exhaust"
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 1)
    b = world.possessed
    assert b.exhaust_ready?, "b's own clock governs — swap transfers nothing (law 4)"
    refute a.exhaust_ready?, "a's clock keeps counting unpossessed"
  end

  def test_ally_ai_fights_humans
    enter_dungeon(world)
    ally_kills = 0
    world.bus.subscribe(:actor_died) do |e|
      ally_kills += 1 if e[:faction] == :human && e[:killer].faction == :pack && !e[:killer].equal?(world.possessed)
    end
    # Possessed stands at the gate; allies must engage approaching husks alone.
    drive(world, scripted({}), 9000)
    assert_operator ally_kills, :>=, 1, "unpossessed allies fight on their own (husk-grade AI)"
  end

  def test_hitstop_only_for_possessed_fights
    enter_dungeon(world)
    # Swap away so the fighting happens between allies and husks only.
    drive(world, scripted({ world.frame.to_s => ["swap"] }), 1)
    hits_seen = 0
    stops_during_ally_hits = 0
    world.bus.subscribe(:attack_hit) do |e|
      unless [e[:attacker], e[:victim]].any? { |c| c.equal?(world.possessed) }
        hits_seen += 1
        stops_during_ally_hits += 1 if world.feel.hitstop?
      end
    end
    drive(world, scripted({}), 6000)
    assert_operator hits_seen, :>=, 1, "allies traded hits during the window"
    assert_equal 0, stops_during_ally_hits, "ally fights never freeze the world (law 5)"
  end

  # --- carried grid invariants (rewritten from v2 suite) -------------------

  def test_held_key_walks_tile_by_tile
    input = scripted(hold(:right, 0, STEP * 3 - 1))
    x0, y0 = world.possessed.tile
    drive(world, input, STEP * 3)
    assert_equal [x0 + 3, y0], world.possessed.tile
  end

  def test_zone_transition_moves_whole_pack
    enter_dungeon(world)
    tiles = world.pack.living.map(&:tile)
    assert_equal tiles.uniq.length, tiles.length, "no shared tiles on arrival"
    tiles.each { |t| assert world.map.passable?(*t) }
    back = scripted(hold(:left, world.frame, world.frame + STEP * 10 - 1))
    drive(world, back, STEP * 11)
    assert_equal "town", world.zone_name
  end

  def test_husks_hunt_the_nearest_pack_member_not_the_possessed
    enter_dungeon(world)
    # After arrival the possessed walks north; allies hold at the gate. The
    # husks must engage whoever is nearest — assert SOME ally takes a hit
    # while the possessed keeps distance.
    ally_hit = false
    world.bus.subscribe(:attack_hit) do |e|
      ally_hit = true if e[:victim].faction == :pack && !e[:victim].equal?(world.possessed)
    end
    drive(world, scripted(hold(:up, world.frame, world.frame + STEP * 6 - 1)), STEP * 6)
    drive(world, scripted({}), 6000)
    assert ally_hit, "humans target nearest pack creature, not the camera"
  end

  def test_determinism_same_script_same_state_with_swaps
    script = hold(:right, 0, STEP * 20).merge(
      (STEP * 21).to_s => %w[swap],
      (STEP * 25).to_s => %w[attack],
      (STEP * 30).to_s => %w[swap]
    )
    states = [Game::World.new(DATA), Game::World.new(DATA)].map do |w|
      input = scripted(script)
      drive(w, input, 4000)
      [w.zone_name, w.frame,
       w.pack.members.map { |m| [m.tile, m.hp, m.x, m.y] },
       w.humans.map { |h| [h.tile, h.hp] }]
    end
    assert_equal states[0], states[1]
  end

  def test_body_blocking_no_two_creatures_share_a_tile
    enter_dungeon(world)
    drive(world, scripted({}), 4000)
    tiles = world.actors.map(&:tile)
    assert_equal tiles.uniq.length, tiles.length,
                 "no two living creatures may occupy one tile: #{tiles}"
  end

  def test_human_respawns_after_kill
    enter_dungeon(world)
    count = world.humans.length
    target = nearest_human(world)
    kill(target, by: world.possessed)
    drive(world, scripted({}), 1)
    assert_equal count - 1, world.humans.length
    drive(world, scripted({}), DATA["balance/combat"][:kits][:husk][:respawn_frames] + 10)
    assert_equal count, world.humans.length
  end
end
```

- [ ] **Step 2: Run the full suite; iterate to green**

Run: `export PATH="/c/Ruby34-x64/bin:$PATH" && rake`
Expected: all green. Iteration guidance for likely failures:
- `test_ally_ai_fights_humans` / `test_husks_hunt...`: timing-sensitive — raise the drive
  window (husk cadence is 81f; approaches take hundreds of frames), never weaken the assertion.
- `test_hitstop_only_for_possessed_fights`: if possessed gets engaged, extend the initial
  possessed retreat (walk back toward the gate) before idling.
- Fixture failures in `creature_test.rb`/`pack_test.rb` from the TileMap schema change: the
  fixtures were migrated in Task 8 Step 1 — re-check if missed.

- [ ] **Step 3: Commit**

```bash
git add test/game/world_test.rb
git commit -m "test: possession-core integration suite — swap/wipe/exhaust/scoped-hitstop laws"
```

### Task 10: Renderer + Window — pack rendering, Tab binding, overrun counter

**Files:**
- Rewrite: `src/app/renderer.rb` (full replacement below)
- Modify: `src/app/window.rb` (swap binding, seed, overrun counter)

**Interfaces:**
- Consumes: World API (`pack`, `possessed`, `humans`, `actors`, `states`, `feel`, `camera`,
  `map`, `banner?`, `frame`), Creature readers (`x y tile hp max_hp faction hurt?
  telegraphing? attack_state attack_tiles iframes? dead?`).
- Produces: `Renderer#draw(world)` (same entry point). Window adds `:swap` → `Gosu::KB_TAB`.

- [ ] **Step 1: Rewrite `src/app/renderer.rb`**

```ruby
module App
  # Draws the world sim with Gosu primitives. Flat-rect minimalism: the
  # possessed body is the brightest thing on screen with a white possession
  # ring; allies are dimmer kin; humans (husk kit, M1) pale bone. Palettes
  # come from data/zones/*.json.
  class Renderer
    POSSESSED      = Gosu::Color.new(255, 235, 120, 40)
    POSSESSED_RING = Gosu::Color.new(255, 255, 255, 255)
    ALLY           = Gosu::Color.new(255, 165, 90, 40)
    HURT_FLASH     = Gosu::Color.new(255, 255, 235, 235)
    HUMAN          = Gosu::Color.new(255, 205, 198, 180)
    TELEGRAPH      = Gosu::Color.new(255, 250, 210, 60)
    HUMAN_HURT     = Gosu::Color.new(255, 255, 80, 80)
    SLASH          = Gosu::Color.new(200, 255, 255, 255)
    WINDUP         = Gosu::Color.new(90, 255, 255, 255)
    HP_BACK        = Gosu::Color.new(255, 50, 20, 30)
    HP_FILL        = Gosu::Color.new(255, 220, 60, 70)
    WIPE_VEIL      = Gosu::Color.new(170, 8, 4, 10)
    BANNER         = Gosu::Color.new(255, 225, 215, 190)
    STAGGER_VEIL   = Gosu::Color.new(90, 20, 8, 8)

    SIZE = Game::Creature::SIZE

    def draw(world)
      cam = world.camera
      Gosu.translate(world.feel.shake_x - cam.x, world.feel.shake_y - cam.y) do
        draw_map(world.map)
        world.humans.each { |h| draw_creature(h, world) }
        world.pack.living.each { |m| draw_creature(m, world) }
      end
      draw_hud(world)
      draw_banner(world) if world.banner?
      draw_wipe_overlay(world) if world.states.current == :nest_respawn
      draw_stagger_veil(world) if world.possessed.staggered?
    end

    private

    def color(rgb, alpha = 255) = Gosu::Color.new(alpha, rgb[0], rgb[1], rgb[2])

    def draw_map(map)
      ts = map.tile_size
      floor = color(map.palette[:floor])
      grid = color(map.palette[:grid])
      wall = color(map.palette[:wall])
      transition = color(map.palette[:transition])

      Gosu.draw_rect(0, 0, map.pixel_width, map.pixel_height, floor)
      map.rows.times do |ty|
        map.cols.times do |tx|
          Gosu.draw_rect(tx * ts, ty * ts, ts, ts, wall) if map.wall?(tx, ty)
        end
      end
      (0..map.cols).each { |tx| Gosu.draw_rect(tx * ts, 0, 1, map.pixel_height, grid) }
      (0..map.rows).each { |ty| Gosu.draw_rect(0, ty * ts, map.pixel_width, 1, grid) }
      map.transitions.each do |t|
        tx, ty = t[:at]
        Gosu.draw_rect(tx * ts + 3, ty * ts + 3, ts - 6, ts - 6, transition)
      end
    end

    def draw_creature(c, world)
      return if c.dead?
      base = body_color(c, world)
      if c.equal?(world.possessed)
        Gosu.draw_rect(c.x - 3, c.y - 3, SIZE + 6, SIZE + 6, POSSESSED_RING)
      end
      if c.faction == :human && c.telegraphing?
        swell = 6
        Gosu.draw_rect(c.x - swell / 2, c.y - swell / 2, SIZE + swell, SIZE + swell, TELEGRAPH)
      else
        Gosu.draw_rect(c.x, c.y, SIZE, SIZE, base)
      end
      draw_attack(c, world.map.tile_size) if c.faction == :pack
    end

    def body_color(c, world)
      if c.hurt? && c.faction == :human then HUMAN_HURT
      elsif c.faction == :human then HUMAN
      elsif c.iframes? && (world.frame / 3).even? then HURT_FLASH
      elsif c.equal?(world.possessed) then POSSESSED
      else ALLY
      end
    end

    def draw_attack(c, ts)
      return unless %i[windup active].include?(c.attack_state)
      col = c.attack_state == :windup ? WINDUP : SLASH
      c.attack_tiles.each do |(tx, ty)|
        Gosu.draw_rect(tx * ts + 4, ty * ts + 4, ts - 8, ts - 8, col)
      end
    end

    def draw_hud(world)
      w = 260
      c = world.possessed
      Gosu.draw_rect(32, 16, w, 14, HP_BACK)
      frac = c.hp.fdiv(c.max_hp)
      Gosu.draw_rect(32, 16, (w * frac).round, 14, HP_FILL) if frac.positive?
    end

    def draw_banner(world)
      text = world.map.display_name
      font = banner_font
      x = (view_width(world) - font.text_width(text)) / 2
      font.draw_text(text, x, 48, 10, 1, 1, BANNER)
    end

    def draw_wipe_overlay(world)
      Gosu.draw_rect(0, 0, view_width(world), view_height(world), WIPE_VEIL)
      font = wipe_font
      text = "THE HUNT ENDS" # fiction-pending: wipe line comes from the bible
      x = (view_width(world) - font.text_width(text)) / 2
      font.draw_text(text, x, view_height(world) / 2 - 40, 10, 1, 1, Gosu::Color.new(255, 200, 40, 40))
    end

    # Forced swap lands with a one-beat red edge so losing a body FEELS lost.
    def draw_stagger_veil(world)
      Gosu.draw_rect(0, 0, view_width(world), view_height(world), STAGGER_VEIL)
    end

    def view_width(world) = world.camera.view_w
    def view_height(world) = world.camera.view_h

    def banner_font = @banner_font ||= Gosu::Font.new(28, bold: true)
    def wipe_font = @wipe_font ||= Gosu::Font.new(64, bold: true)
  end
end
```

- [ ] **Step 2: Update `src/app/window.rb`**

```ruby
require "gosu"
require "core/data_store"
require "core/input"
require "game/world"
require "app/renderer"

module App
  # Orchestrator (scope contract: <= ~300 lines). Owns the Gosu window, wires
  # data -> world -> renderer, and maps the keyboard to abstract actions.
  # ALL game logic lives in Game::World and below.
  #
  # Timebase: update() = exactly ONE sim tick (tick-locked; replays are
  # deterministic by tick count). Under load the game slows rather than
  # skipping — the overrun counter below makes that visible so a sluggish
  # playtest is diagnosed as perf, not misread as balance.
  class Window < Gosu::Window
    BINDINGS = {
      left:   [Gosu::KB_LEFT, Gosu::KB_A],
      right:  [Gosu::KB_RIGHT, Gosu::KB_D],
      up:     [Gosu::KB_UP, Gosu::KB_W],
      down:   [Gosu::KB_DOWN, Gosu::KB_S],
      attack: [Gosu::KB_J, Gosu::KB_SPACE],
      dodge:  [Gosu::KB_K, Gosu::KB_LEFT_SHIFT],
      swap:   [Gosu::KB_TAB]
    }.freeze

    FRAME_BUDGET_MS = 17

    def initialize
      data = Core::DataStore.new(File.expand_path("../../data", __dir__))
      display = data["display"]
      super display[:view_width], display[:view_height]
      self.caption = "game-two"
      @world = Game::World.new(data)
      @input = Core::KeyboardInput.new(bindings: BINDINGS)
      @renderer = Renderer.new
      @overruns = 0
      @overrun_font = Gosu::Font.new(14)
    end

    def update
      t0 = Gosu.milliseconds
      @world.tick(@input)
      @overruns += 1 if Gosu.milliseconds - t0 > FRAME_BUDGET_MS
    end

    def draw
      @renderer.draw(@world)
      if @overruns.positive?
        @overrun_font.draw_text("overruns: #{@overruns}", width - 110, 8, 20, 1, 1,
                                Gosu::Color.new(200, 255, 120, 120))
      end
    end

    def button_down(id)
      id == Gosu::KB_ESCAPE ? close : super
    end
  end
end
```

- [ ] **Step 3: Verify — suite + live launch smoke**

Run: `rake` → all green. Then launch `bin/play` for ~20 seconds: confirm the pack of three
renders, Tab swaps the ring, allies follow, Esc quits cleanly. (This is a crash-smoke, not the
verification — Rule 2 runs in Task 11.)

- [ ] **Step 4: Commit**

```bash
git add src/app/renderer.rb src/app/window.rb
git commit -m "feat: pack rendering + possession ring, Tab swap binding, overrun counter (order 5)"
```

### Task 11: Harness — seed lane, swap lane, M1 capture script, run the full gate

**Files:**
- Modify: `harness/replay_runner.rb` (seed passthrough)
- Modify: `harness/scripts/world_loop.json` (re-aim for the pack world)
- Create: `harness/scripts/possession_core.json`
- Modify: `CLAUDE.md` (commands section: `rake gate`, timebase note)

**Interfaces:**
- Consumes: `WorldScene.new(width:, height:, seed:)` from Task 8.
- Produces: script schema gains optional `"seed": <int>` (default 0); `"swap"` works in
  `hold`/`frames` lanes (already generic — actions are arbitrary strings). Determinism law 3's
  harness half is DONE with this task.

- [ ] **Step 1: Seed passthrough in `harness/replay_runner.rb`**

In `ReplayWindow#initialize`, change the scene construction line to:

```ruby
      @scene = SCENES.fetch(raw.fetch(:scenario)).new(width: w, height: h, seed: raw.fetch(:seed, 0))
```

and update `harness/scenes/moving_square.rb`'s constructor to accept and ignore `seed:`
(add `seed: 0` to its keyword args — check its current signature before editing).

- [ ] **Step 2: Scout the M1 loop, then pin `possession_core.json`**

Author a scout script exercising: walk east into Threketh → possessed fights a husk (swing via
exhaust pace) → Tab swap mid-fight → idle until the possessed body dies (forced swap fires) →
keep idling until wipe → respawn in town. Run
`ruby -Isrc harness/replay_runner.rb harness/scripts/possession_core.json` and read the
`EVENT ...` lines to find the actual frames of `possession_changed(forced)`, `pack_wiped`,
`pack_respawned`; then set `"captures"` to hit: spawn, mid-walk, arrival banner, a telegraph,
a swing arc, the voluntary swap (ring on a new body), the forced swap (stagger veil), the wipe
overlay, and post-respawn town. Structure (frame numbers pinned by the scout run):

```json
{
  "scenario": "world",
  "width": 960,
  "height": 540,
  "seed": 20260809,
  "hold": {
    "right": [[0, 599]],
    "attack": [[620, 800]],
    "up": [[620, 800]]
  },
  "frames": {
    "850": ["swap"]
  },
  "captures": [1, 300, 614, 640, 700, 851, 1400, 2200, 2600],
  "run_until": 2800,
  "out_dir": "captures/possession_core"
}
```

(The values above are the starting scout; the committed version carries the pinned frames from
the actual event log. Update `world_loop.json`'s captures the same way if its old frame numbers
no longer land on interesting moments — its job now is the everyday regression loop.)

- [ ] **Step 3: Add M1 gate checks for possession**

Append to `harness/gate_checks.json` `checks` array:

```json
    { "id": "possession_ring_moves", "check": "Across the swap frames, the white possession ring appears on a DIFFERENT pack creature before vs after — possession visibly moved." },
    { "id": "wipe_reads", "check": "The wipe frame reads as a run-ending event (dark veil + large text), distinct from ordinary combat frames." }
```

- [ ] **Step 4: Run the full blocking gate on both scripts**

Run:
`rake gate SCRIPT=harness/scripts/possession_core.json` and
`rake gate SCRIPT=harness/scripts/world_loop.json`
Expected: determinism PASS (byte-identical) + vision verdict PASS on all checks, exit 0.
This is Rule 2/6 — a FAIL blocks Task 12; fix and re-run, never ship red. Also Read 2–3 of the
captured PNGs directly (vision-verify with own eyes per Rule 2 discipline).

- [ ] **Step 5: Document commands**

In `CLAUDE.md` Commands section, add:

```markdown
- `rake gate SCRIPT=harness/scripts/<name>.json` — the BLOCKING Rule 2 gate: double replay +
  md5 compare + structured vision verdict (exit nonzero on any failure). `SKIP_CRITIC=1` runs
  the determinism half only (iteration aid, not a shippable pass).
```

and in Controls: `Tab = swap possession`. Note the timebase line from Task 10's comment in the
Environment section (one sentence: tick-locked update, overrun counter top-right).

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md harness/scripts/possession_core.json harness/scripts/world_loop.json harness/gate_checks.json harness/replay_runner.rb harness/scenes/moving_square.rb
git commit -m "harness: seed + swap lanes, possession_core script, gate green (Rule 2)"
```

### Task 12: M1 ship — checkpoint, adversarial review, hand to owner

**Files:**
- Modify: `docs/CHECKPOINT.md` (new dated top section)

- [ ] **Step 1: Full verification pass**

Run: `rake` (expect ~45+ runs green) and both `rake gate` scripts (expect GATE PASS). Record
the real numbers — measured, never recalled.

- [ ] **Step 2: Adversarial code review of the whole M1 diff**

Dispatch a `code-reviewer` agent over `git diff <pre-M1-sha>..HEAD` focused on: determinism
holes (any wall-clock/hash-order/global-rand in sim), swap-cycling exploit actually dead
(exhaust truly creature-owned), event-payload object leaks (dead creatures retained via
`@flow_cache`/`@telegraphing` — verify pruning), orchestrator cap. Fix CONFIRMED findings
before shipping; log PLAUSIBLE ones to the checkpoint.

- [ ] **Step 3: Checkpoint + commit**

New top section in `docs/CHECKPOINT.md`: M1 shipped (measured test/gate numbers), what the
owner should feel-check (swap under pressure: Tab mid-fight, forced swap sting, wipe → town,
held-attack rhythm vs the old barrier), known M2 queue, in-flight = nothing.

```bash
git add docs/CHECKPOINT.md
git commit -m "checkpoint: M1 possession core shipped — owner feel-check queued"
```

- [ ] **Step 4: Report to owner**

One message: what shipped, how to run (`bin\play.cmd`, Tab = swap), the four things to
feel-check, and that M2's plan gets written from their reaction.

---

## Post-M1 (next plan, for the record — NOT tasks here)

Three kits + Lobber projectile · Rushers + per-creature flow fields under load · nest +
district zones · 3-bar HUD + exhaust pip · edge pips · carried critique fixes · perf smoke
p95 < 16.6 ms (order 4) · `district_hunt.json` full gate · fiction binding pass when the
bible lands.
