require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "net/state_digest"

# MUNDO VIVO FASE 4.4 — the ember family's two line primitives:
#   charge (ember_a): an ATTACK that is a dash — telegraphed run along the
#     facing, i-framed, strikes every hostile on the crossed line, knocks
#     back (the striker's dash grammar, hostile side, through start_attack);
#   beam (ember_d): a long windup, then a straight line of tiles to the
#     first wall is struck for the active window (no projectile object).
# Boot+combat proof on a real World; the AI reaches both through the same
# engage → in_attack_range? path (aligned, 2..reach, clear line).
class ChargeBeamTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KITS = DATA["balance/combat"][:kits]

  def world = @world ||= Game::World.new(DATA)
  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def stage!(kind, w = world, dist:)
    w.start_in("grass_fixture")
    body = w.possessed
    (w.pack.living - [body]).each_with_index { |m, i| m.walker.teleport(2, 1 + i) }
    body.walker.teleport(7, 6)
    w.send(:add_human, "grass_fixture", kind, [7 + dist, 6])
  end

  # ---- charge ----
  def test_charge_kit_shape_and_xp_rows
    a = KITS[:ember_a][:attack]
    assert_equal "dash", a[:arc]
    assert a[:charge], "renderer read flag (ground telegraph)"
    assert_operator a[:max_tiles], :>=, 4
    assert_operator a[:knockback_tiles], :>=, 1, "a charge SHOVES"
    xp = DATA["balance/progression"][:kill_xp]
    assert xp[:ember_a] < xp[:ember_d] && xp[:ember_d] < xp[:challenger], "L6 inside the family, below BOSS 1"
  end

  def test_a_far_aligned_charger_runs_the_line_and_the_hit_lands_with_knockback
    charger = stage!(:ember_a, dist: 4)
    body = world.possessed
    hp0 = body.hp
    tile0 = body.tile
    started = []
    world.bus.subscribe(:attack_started) { |e| started << e }
    drive(world, scripted({}), 3)
    assert started.any? { |e| e[:attacker].equal?(charger) }, "aligned at dist 4 (2..max_tiles): the charge STARTS instead of a walk"
    assert charger.telegraphing?
    refute_empty charger.action_tiles, "the run line exists during the windup (ground telegraph reads it)"
    drive(world, scripted({}), KITS[:ember_a][:attack][:windup_frames] + KITS[:ember_a][:attack][:max_tiles] * KITS[:ember_a][:attack][:frames_per_tile] + 4)
    assert_operator body.hp, :<, hp0, "the charge struck the body on its line"
    refute_equal tile0, body.tile, "…and knocked it back (knockback_tiles 2)"
    refute_equal [11, 6], charger.tile, "the charger MOVED (it is a dash, not a stationary swing)"
  end

  def test_charge_never_starts_adjacent_or_misaligned
    charger = stage!(:ember_a, dist: 1)
    started = []
    world.bus.subscribe(:attack_started) { |e| started << e }
    drive(world, scripted({}), 6)
    assert started.none? { |e| e[:attacker].equal?(charger) }, "adjacent = no charge (needs dist >= 2)"
    charger.walker.teleport(12, 9) # misaligned (dx 5, dy 3)
    drive(world, scripted({}), 6)
    assert started.none? { |e| e[:attacker].equal?(charger) }, "misaligned = walks, never charges"
  end

  # ---- beam ----
  def test_beam_kit_shape
    a = KITS[:ember_d][:attack]
    assert_equal "beam", a[:arc]
    assert_operator a[:windup_frames], :>=, 40, "beam is the LONG telegraph (a dodge lane exists)"
    assert_operator a[:beam_length], :>=, 6
  end

  def test_beam_tiles_run_along_the_facing_and_stop_at_walls
    caster = stage!(:ember_d, dist: 5)
    drive(world, scripted({}), 3)
    assert caster.telegraphing?, "aligned at dist 5 (2..beam_length): the beam winds up"
    tiles = caster.action_tiles
    assert_equal KITS[:ember_d][:attack][:beam_length], tiles.length, "full length on an open row"
    assert_equal [-1, 0], caster.facing
    assert_equal [caster.tile[0] - 1, caster.tile[1]], tiles.first
    assert tiles.all? { |(x, y)| world.map.passable?(x, y) }
    # a wall-facing caster: the line stops at the wall
    caster.walker.teleport(3, 6)
    caster.face([-1, 0])
    assert_operator caster.action_tiles.length, :<, KITS[:ember_d][:attack][:beam_length], "walls cut the beam"
  end

  def test_the_beam_strikes_a_body_on_its_line_once
    stage!(:ember_d, dist: 5)
    body = world.possessed
    hp0 = body.hp
    hits = []
    world.bus.subscribe(:attack_hit) { |e| hits << e }
    drive(world, scripted({}), KITS[:ember_d][:attack][:windup_frames] + KITS[:ember_d][:attack][:active_frames] + 2)
    assert_operator body.hp, :<, hp0, "the beam damaged the body standing on the line"
    assert_equal 1, hits.count { |e| e[:victim].equal?(body) }, "one hit per victim per beam (hit_victims law)"
  end

  def test_charge_and_beam_are_deterministic
    stage!(:ember_a, dist: 4)
    world.send(:add_human, "grass_fixture", :ember_d, [7, 12])
    drive(world, scripted({}), 70)
    a = Net::StateDigest.canonical(world.digest_snapshot)
    w2 = Game::World.new(DATA)
    stage!(:ember_a, w2, dist: 4)
    w2.send(:add_human, "grass_fixture", :ember_d, [7, 12])
    drive(w2, scripted({}), 70)
    assert_equal a, Net::StateDigest.canonical(w2.digest_snapshot)
  end
end
