require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# v17 digest lane (spec decision 6) against the REAL sim — no mocks.
# Three layers of proof:
#   1. coverage pins — the decision-6 field lists live HERE; removing or
#      renaming a covered field fails the suite (W1 mitigation);
#   2. mutation sensitivity — real world mutations AND schema-level leaf
#      flips must each flip the canonical form;
#   3. window mechanics — determinism across two identical worlds, input
#      folding, all-registered-events subscription, retention for the
#      decision-8 artifact.
class StateDigestTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  WORLD_FIELDS = %w[frame zone state respawn_timer home_zone breached
                    zone_left_at
                    last_damaged swap_was_down rearm_needed corpse_serial
                    rng_draws respawn_rng_draws boss_1_defeats sessions
                    level xp hitstop].freeze
  PACK_FIELDS = %w[banked provisions mark possessed.1].freeze
  CREATURE_FIELDS = %w[kind tile_x tile_y px py tween_left tween_total
                       reserved_x reserved_y facing_x facing_y hp alive
                       stagger exhaust special_exhaust iframes
                       dodge_cooldown hurt_frames action action_state
                       action_frames action_triggered hit_victims
                       dash_landing dash_crossed dash_duration carried
                       marked seized_by seized_frames chant_left
                       chant_target chant_hp seize_cooldown engaged focus
                       taunted_by taunt_frames taunt_cause leash_frames
                       beachhead_waived pack_provoked
                       retarget_cause retarget_frames
                       home_x home_y].freeze
  PROJECTILE_FIELDS = %w[owner tile_x tile_y dir_x dir_y damage knockback
                         range_left countdown done].freeze
  SCALARS = [Integer, Float, String, Symbol, NilClass, TrueClass, FalseClass].freeze

  def world(seed: 7) = Game::World.new(DATA, seed:)
  def idle = Core::ScriptedInput.new(frames: {})
  def canonical(w) = Net::StateDigest.canonical(w.digest_snapshot)

  def drive(w, input, n)
    n.times do
      input.update(w.frame)
      w.tick(input)
    end
  end

  def drive_until(w, cap, what)
    cap.times do
      return if yield
      w.tick(idle)
    end
    flunk "staging: #{what} not reached within #{cap} ticks"
  end

  def possess_kit(w, kit_name)
    w.pack.members.length.times do
      return w.possessed if w.possessed.kit_name == kit_name
      w.pack.swap_next!
    end
    flunk "could not possess #{kit_name}"
  end

  # The passable tile farthest from every living human (row-major
  # tie-break): staging happens out of aggro range so AI can't interrupt
  # the lobber's windups mid-stage.
  def clear_corner(w)
    ts = w.map.tile_size
    alive = w.humans.reject(&:dead?)
    best = nil
    best_d = -1
    (0...(w.map.pixel_height / ts)).each do |y|
      (0...(w.map.pixel_width / ts)).each do |x|
        next unless w.map.passable?(x, y)
        d = alive.map { |h| [(h.tile[0] - x).abs, (h.tile[1] - y).abs].max }.min
        if d > best_d
          best_d = d
          best = [x, y]
        end
      end
    end
    best
  end

  # A world with every snapshot group populated: humans (district), a drop
  # + a respawn record (killed husk), a corpse load (killed carrier), a
  # volley impact in its delay window, and a projectile in flight.
  def staged_world
    w = world
    w.start_in("district")
    lobber = possess_kit(w, :lobber)
    corner = clear_corner(w)
    lobber.walker.teleport(*corner)
    others = w.pack.members - [lobber]
    others.each_with_index { |m, i| m.walker.teleport(corner[0], corner[1] + 1 + i) }
    victim = w.humans.reject(&:dead?).first
    victim.take_hit(damage: victim.hp, attacker: lobber) until victim.dead?
    carrier = others.first
    carrier.pick_up(9)
    carrier.take_hit(damage: carrier.hp, attacker: victim) until carrier.dead?
    w.tick(idle) # flush deaths: drop + respawn record + corpse load
    lobber.face([1, 0])
    lobber.start_special(blocked: []) or flunk "staging: volley cast refused"
    drive_until(w, 200, "volley impact") { w.impacts.any? }
    drive_until(w, 200, "lobber idle after volley") { lobber.attack_state == :idle }
    lobber.start_attack or flunk "staging: projectile attack refused"
    drive_until(w, 200, "projectile in flight") { w.projectiles.any? }
    assert w.impacts.any?, "staging: impact resolved before the projectile launched"
    w
  end

  # --- 1. coverage pins (the decision-6 lists live in the suite) --------

  def test_decision_6_coverage_lists_are_pinned
    snap = staged_world.digest_snapshot
    groups = snap.to_h
    assert_equal WORLD_FIELDS, groups.fetch("world").map(&:first)
    assert_equal PACK_FIELDS, groups.fetch("pack").map(&:first)
    assert_equal CREATURE_FIELDS, groups.fetch("pack.0").map(&:first)
    human_key = snap.map(&:first).find { |g| g.start_with?("human.") }
    assert_equal CREATURE_FIELDS, groups.fetch(human_key).map(&:first)
    assert_equal PROJECTILE_FIELDS, groups.fetch("projectile.0").map(&:first)
    %w[impact.0 drop. load. respawn.].each do |prefix|
      assert snap.map(&:first).any? { |g| g.start_with?(prefix) },
             "staging lost the #{prefix} group — the sweep no longer covers it"
    end
  end

  def test_every_leaf_is_a_plain_scalar
    staged_world.digest_snapshot.each do |group, fields|
      assert_kind_of String, group
      fields.each do |name, value|
        assert_kind_of String, name
        assert SCALARS.any? { |k| value.is_a?(k) },
               "#{group}.#{name} leaked a #{value.class} into the snapshot — " \
               "objects #inspect with memory addresses and desync the digest against itself"
      end
    end
  end

  # --- 2. mutation sensitivity ------------------------------------------

  # The spec's sweep: every covered leaf NAME, flipped through the schema,
  # must flip the canonical form (catches serializer aliasing/drops). One
  # representative group per kind — duplicate humans/drops share a shape,
  # so sweeping instances would be O(n²) noise, not extra schema coverage.
  def test_mutation_sensitivity_sweep_every_covered_leaf_flips_the_canonical_form
    snap = staged_world.digest_snapshot
    base = Net::StateDigest.canonical(snap)
    reps = {}
    snap.each_with_index do |(group, _), gi|
      seg = group.split(".")
      kind = seg.length == 1 ? seg[0] : "#{seg[0]}.N"
      reps[kind] ||= gi
    end
    assert_equal %w[world pack pack.N human.N projectile.N impact.N drop.N load.N respawn.N
                    totem.N].sort,
                 reps.keys.sort, "staging no longer covers every group kind"
    count = 0
    reps.each_value do |gi|
      group, fields = snap[gi]
      fields.each_index do |fi|
        original = fields[fi][1]
        fields[fi][1] = flip(original)
        refute_equal base, Net::StateDigest.canonical(snap),
                     "flipping #{group}.#{fields[fi][0]} did not change the canonical form"
        fields[fi][1] = original
        count += 1
      end
    end
    assert_equal base, Net::StateDigest.canonical(snap), "sweep failed to restore the snapshot"
    assert_operator count, :>=, 100, "sweep shrank suspiciously (#{count} leaves)"
  end

  # Live-state battery: digest_snapshot must read LIVE sim state, not a
  # cached copy. Each mutation is tick-free so the delta is attributable.
  def test_real_world_mutations_flip_the_digest
    w = staged_world
    h = w.humans.reject(&:dead?).first
    steps = {
      "rng draw count" => -> { w.rng.rand(2) },
      "respawn rng draw count" => -> { w.respawn_rng.rand(2) },
      "banked" => -> { w.pack.bank!(7) },
      "carried" => -> { w.possessed.pick_up(3) },
      "possessed tile" => -> { w.possessed.walker.teleport(w.possessed.tile[0], w.possessed.tile[1] - 1) },
      "stagger" => -> { w.possessed.stagger!(9) },
      "hitstop" => -> { w.feel.on_kill },
      "pack mark" => -> { w.pack.mark!(h) },
      "possession map" => -> { w.pack.swap_next! },
      "inscription" => -> { w.possessed.inscribe_mark! },
      "progression" => -> { w.progression.load_progress!(level: 2, xp: 5) },
      "human hp" => -> { h.take_hit(damage: 1, attacker: w.possessed) },
      "taunt" => -> { h.taunt!(w.possessed, 60) },
      "focus" => -> { h.focus = (h.focus.equal?(w.pack.members[0]) ? w.pack.members[1] : w.pack.members[0]) },
      "retarget cue" => -> { h.retarget_cue!(:hate, 30) },
      "chant" => -> { h.start_chant!(w.possessed, 40) },
      "seizure" => -> { w.possessed.seize!(h, 50) },
      "drop clock" => -> { w.drops.first[:frames_left] -= 1 },
      "corpse load term" => -> { w.corpse_loads.first[:term_left] -= 1 },
      "frame (one tick)" => -> { w.tick(idle) }
    }
    before = canonical(w)
    steps.each do |label, mutation|
      mutation.call
      after = canonical(w)
      refute_equal before, after, "#{label} mutation did not flip the digest"
      before = after
    end
  end

  # --- 3. window mechanics ----------------------------------------------

  def test_two_identical_worlds_produce_identical_window_md5s
    runs = Array.new(2) do
      w = world(seed: 3)
      digest = Net::StateDigest.new(world: w, every: 30)
      input = Core::ScriptedInput.new(frames: (0..89).to_h { |f| [f.to_s, ["right"]] })
      windows = []
      90.times do
        input.update(w.frame)
        w.tick(input)
        windows << digest.after_tick
      end
      windows.compact
    end
    assert_equal [30, 60, 90], runs[0].map(&:tick)
    assert_equal runs[0].map(&:md5), runs[1].map(&:md5)
  end

  def test_diverged_inputs_produce_diverged_window_md5s
    md5s = %w[right left].map do |action|
      w = world(seed: 3)
      digest = Net::StateDigest.new(world: w, every: 30)
      input = Core::ScriptedInput.new(frames: (0..29).to_h { |f| [f.to_s, [action]] })
      window = nil
      30.times do
        input.update(w.frame)
        w.tick(input)
        window ||= digest.after_tick
      end
      window.md5
    end
    refute_equal md5s[0], md5s[1]
  end

  def test_folded_input_masks_enter_the_digest
    md5s = [[1], [2], nil].map do |masks|
      w = world(seed: 3)
      digest = Net::StateDigest.new(world: w, every: 10)
      digest.fold_input(5, masks) if masks
      drive(w, idle, 10)
      digest.after_tick.md5
    end
    assert_equal 3, md5s.uniq.length, "mask [1] vs [2] vs none must all digest differently"
  end

  def test_digest_folds_events_outside_the_curated_harness_list
    w = world
    w.start_in("district")
    digest = Net::StateDigest.new(world: w, every: 5)
    h = w.humans.reject(&:dead?).first
    h.take_hit(damage: 1, attacker: w.possessed)
    w.possessed.start_attack
    window = nil
    5.times do
      w.tick(idle)
      window ||= digest.after_tick
    end
    assert window.lines.any? { |l| l.start_with?("EVENT damage_dealt ") },
           "damage_dealt (registered, uncurated) missing from the digest stream"
    assert window.lines.any? { |l| l.start_with?("EVENT attack_started ") },
           "attack_started (registered, uncurated) missing from the digest stream"
  end

  def test_windows_retain_their_own_lines_and_snapshot_then_reset
    w = world(seed: 3)
    digest = Net::StateDigest.new(world: w, every: 10)
    digest.fold_input(0, [9])
    windows = []
    20.times do
      w.tick(idle)
      windows << digest.after_tick
    end
    first, second = windows.compact
    assert first.lines.any? { |l| l.include?("masks=[9]") }
    refute second.lines.any? { |l| l.include?("masks=[9]") },
           "window 2 leaked window 1's lines — the rolling buffer did not reset"
    assert first.snapshot.any?
    assert_equal 10, first.tick
    assert_equal 20, second.tick
  end

  private

  def flip(value)
    case value
    when Integer then value + 1
    when Float then value + 1.0
    when String then "#{value}~"
    when Symbol then :"#{value}_flipped"
    when true then false
    when false then true
    when nil then 0
    else flunk "unflippable leaf class #{value.class}"
    end
  end
end
