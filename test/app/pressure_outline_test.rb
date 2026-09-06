require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "app/signage"

# Lane `signage` commit 2: the pressuring hostile's hollow outline is drawn
# IFF the sim says `:pressuring` (World#pressure_role — untouched) AND the
# body is close enough to BE on the ring (Chebyshev <= display
# `pressure_outline_max_tiles` = the sim's `pressure_ring_tiles` + 1) AND,
# unless `pressure_outline_needs_line` is false, no wall cuts the sight to the
# local possessed body (Signage.sight_open?, presentation geometry). Real
# World, real district walls, headless — the pattern of threat_pressure_test
# (5 engaged rushers at d=1 fill the cap; the 6th is `:pressuring`).
class PressureOutlineTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  THREAT = DATA["balance/threat"]
  DISPLAY = DATA["display"]
  MAX = DISPLAY[:pressure_outline_max_tiles]

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, n, input: scripted({}))
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def make_human(world, kit_name, tile)
    kit = DATA["balance/combat"][:kits].fetch(kit_name)
    Game::Creature.new(bus: world.bus, kit: kit, kit_name: kit_name, map: world.map, tile: tile,
                       faction: :human, name: "test_#{kit_name}_#{tile}")
  end

  # District arena, the blocker possessed and parked at `target_tile`, the
  # other pack bodies far away, the engaged cap filled at d=1, ONE extra
  # rusher at `pressurer_tile`; one tick partitions the roles.
  def stage(target_tile, pressurer_tile, adjacent:)
    w = Game::World.new(DATA, seed: 7)
    step = DATA["balance/combat"][:kits][:striker][:step_frames]
    drive(w, step * 30, input: scripted((0..step * 30 - 1).to_h { |f| [f.to_s, ["right"]] }))
    assert_equal "district", w.zone_name
    w.humans.clear
    target = w.pack.members.find { |m| m.kit_name == :blocker }
    w.pack.members.length.times { break if w.possessed.equal?(target); w.pack.swap_next! }
    target.walker.teleport(*target_tile)
    w.pack.members.reject { |m| m.equal?(target) }.each_with_index { |m, i| m.walker.teleport(40, 1 + i) }
    cap = THREAT[:engaged_cap_per_target]
    adjacent.first(cap).each { |t| w.humans << make_human(w, :rusher, t) }
    pressurer = make_human(w, :rusher, pressurer_tile)
    w.humans << pressurer
    drive(w, 1)
    assert_equal target_tile, w.possessed.tile
    [w, pressurer]
  end

  def outline?(w, c, needs_line: true) =
    App::Signage.pressure_outline?(w, c, w.possessed, max_tiles: MAX, needs_line: needs_line)

  def test_max_tiles_is_the_sim_ring_radius_plus_one
    assert_equal THREAT[:pressure_ring_tiles] + 1, MAX,
                 "pressure_outline_max_tiles must be the sim's pressure_ring_tiles (threat.json) + 1"
    assert_equal true, DISPLAY[:pressure_outline_needs_line]
  end

  # (i) pressuring, on the ring, open sight -> outline
  def test_pressuring_within_max_tiles_with_open_sight_outlines
    w, pr = stage([5, 8], [8, 8], adjacent: [[6, 7], [6, 8], [6, 9], [5, 9], [4, 9]])
    assert_equal :pressuring, w.pressure_role(pr)
    assert_operator App::Signage.chebyshev(pr.tile, w.possessed.tile), :<=, MAX
    assert App::Signage.sight_open?(w.map, pr.tile, w.possessed.tile)
    assert outline?(w, pr)
  end

  # (ii) pressuring but FAR (the brasa2 pocket distances 6-9) -> no outline
  def test_pressuring_beyond_max_tiles_does_not_outline
    w, pr = stage([5, 8], [12, 8], adjacent: [[6, 7], [6, 8], [6, 9], [5, 9], [4, 9]])
    assert_equal :pressuring, w.pressure_role(pr)
    assert_operator App::Signage.chebyshev(pr.tile, w.possessed.tile), :>, MAX
    refute outline?(w, pr)
    refute outline?(w, pr, needs_line: false), "distance alone removes it, no sight needed"
  end

  # (iii) pressuring, near, but a real wall between -> no outline
  def test_pressuring_near_but_behind_a_wall_does_not_outline
    w, pr = stage([23, 11], [20, 14], adjacent: [[23, 10], [24, 11], [23, 12], [24, 10], [24, 12]])
    assert_equal :pressuring, w.pressure_role(pr)
    assert_operator App::Signage.chebyshev(pr.tile, w.possessed.tile), :<=, MAX
    assert w.map.wall?(22, 12), "the arena's wall block cuts the diagonal (real district tile)"
    refute App::Signage.sight_open?(w.map, pr.tile, w.possessed.tile)
    refute outline?(w, pr)
  end

  # (iv) engaged (fighting) -> never the outline
  def test_engaged_never_outlines
    w, _pr = stage([5, 8], [8, 8], adjacent: [[6, 7], [6, 8], [6, 9], [5, 9], [4, 9]])
    engaged = w.humans.select { |h| w.pressure_role(h) == :engaged }
    assert_equal THREAT[:engaged_cap_per_target], engaged.length
    engaged.each { |h| refute outline?(w, h), "#{h.tile} engaged must not outline" }
    engaged.each { |h| refute outline?(w, h, needs_line: false) }
  end

  # (v) the data toggle: needs_line false -> (iii) outlines (the owner can
  # drop the sight clause without code)
  def test_needs_line_false_ignores_the_wall
    w, pr = stage([23, 11], [20, 14], adjacent: [[23, 10], [24, 11], [23, 12], [24, 10], [24, 12]])
    assert_equal :pressuring, w.pressure_role(pr)
    refute outline?(w, pr, needs_line: true)
    assert outline?(w, pr, needs_line: false)
  end

  # (vi) AGREEMENT: on the 8 aligned offsets (the only pairs the sim ray
  # defines) sight_open? == World#line_clear? for every passable pair at
  # distance 1..3 on the real district map — the two definitions never
  # disagree where both exist.
  def test_sight_open_agrees_with_the_sim_ray_on_every_aligned_pair
    w = Game::World.new(DATA, seed: 7)
    step = DATA["balance/combat"][:kits][:striker][:step_frames]
    drive(w, step * 30, input: scripted((0..step * 30 - 1).to_h { |f| [f.to_s, ["right"]] }))
    assert_equal "district", w.zone_name
    m = w.map
    dirs = [[1, 0], [0, 1], [1, 1], [1, -1], [-1, 0], [0, -1], [-1, 1], [-1, -1]]
    pairs = 0
    disagreements = []
    (0...m.rows).each do |y|
      (0...m.cols).each do |x|
        next unless m.passable?(x, y)
        dirs.each do |ux, uy|
          (1..MAX).each do |d|
            to = [x + ux * d, y + uy * d]
            next unless m.passable?(*to)
            pairs += 1
            a = App::Signage.sight_open?(m, [x, y], to)
            b = w.line_clear?([x, y], to)
            disagreements << [[x, y], to, a, b] if a != b
          end
        end
      end
    end
    assert_operator pairs, :>, 1000, "sample regressed"
    assert_empty disagreements, "sight_open? and World#line_clear? disagree on aligned pairs"
  end

  # Knight offsets ARE on the Chebyshev-2 ring; the sim ray is false for them
  # by construction (8-way), the presentation geometry is not.
  def test_sight_open_covers_the_off_axis_ring_slots_the_sim_ray_cannot
    w = Game::World.new(DATA, seed: 7)
    m = w.map # nest: open floor around the spawn
    me = w.possessed.tile
    checked = 0
    [[2, 1], [1, 2], [-2, 1], [-1, -2]].each do |dx, dy|
      t = [me[0] + dx, me[1] + dy]
      next unless m.passable?(*t)
      checked += 1
      assert App::Signage.sight_open?(m, t, me), "open floor #{t} -> #{me} must be open sight"
      refute w.line_clear?(t, me), "(documenting why sight_open? exists: the sim ray is 8-way)"
    end
    assert_operator checked, :>, 0, "the nest spawn must have at least one passable knight offset (else vacuous)"
  end

  def test_pure_guards
    w = Game::World.new(DATA, seed: 7)
    c = w.possessed
    assert_equal true, App::Signage.sight_open?(w.map, c.tile, c.tile), "from == to is open"
    refute App::Signage.pressure_outline?(w, c, c, max_tiles: MAX, needs_line: true), "a pack body never outlines"
    h = make_human(w, :rusher, [c.tile[0] + 1, c.tile[1]])
    refute App::Signage.pressure_outline?(w, h, nil, max_tiles: MAX, needs_line: true), "no possessed => false"
  end
end
