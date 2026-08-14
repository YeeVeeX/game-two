require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "core/tile_map"
require "game/world"

# v12 breach chain, increment 1: the sealed threshold in District One, the
# banked toll, the forward camp behind it — through the REAL World + data,
# no mocks. Tiles, events, and state only (grid doctrine).
class SealBreachTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  # The breach fires the strongest feel kick; hitstop pauses the sim clock.
  HITSTOP_SLACK = DATA["balance/combat"][:feel][:hitstop_frames_kill] + 4

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def seal_station
    @seal_station ||= DATA["zones/district"][:stations].find { |s| s[:type] == "seal" }
  end

  def enter_district!
    # Teleport-stage the pack into the district via the real transition:
    # walk the possessed onto the nest gate tile and tick once.
    world.possessed.walker.teleport(29, 8)
    drive(world, scripted({}), 2)
    assert_equal "district", world.zone_name
  end

  def at_seal!
    enter_district!
    src = world.possessed
    src.walker.teleport(*seal_station[:at])
    # Park allies far from the seal so nothing contests the interaction.
    (world.pack.living - [src]).each_with_index do |m, i|
      m.walker.teleport(2, 2 + i)
    end
    src
  end

  # --- gradient_anchor (the load-bearing correctness fix) ---------------

  def test_district_band_map_pinned_despite_new_zone_arrivals
    # Adding camp.json re-orders district's arrivals (sorted zone keys put
    # camp before nest); without an explicit anchor the gate field would
    # flip to the east gate and invert every band. These pins are today's
    # truth measured from the nest-side arrival [1,13].
    enter_district!
    assert_equal 0, world.send(:gradient_band, [2, 13]), "near the nest gate = band 0"
    assert_equal 1, world.send(:gradient_band, [20, 13]), "mid-district = band 1"
    assert_equal 2, world.send(:gradient_band, [42, 13]), "deep east = band 2"
  end

  def test_tile_map_validates_gradient_anchor_passable
    cfg = {
      tile_size: 32, display_name: "t", palette: {},
      tiles: ["#####", "#...#", "#####"],
      pack_spawn: [[1, 1], [2, 1], [3, 1]],
      gradient_anchor: [0, 0]
    }
    assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(cfg) }
  end

  def test_camp_is_a_hub_zone_and_district_is_not
    assert Core::TileMap.new(DATA["zones/camp"]).hub
    refute Core::TileMap.new(DATA["zones/district"]).hub
  end

  # --- the seal fixture --------------------------------------------------

  def test_seal_price_reads_breach_cost_while_sealed
    at_seal!
    assert_equal ECO[:breach_cost], world.station_price(seal_station)
  end

  def test_seal_refuses_under_toll_without_mutation
    src = at_seal!
    world.pack.bank!(ECO[:breach_cost] - 1)
    refute world.interact(src)
    assert_equal ECO[:breach_cost] - 1, world.pack.banked
    refute world.breached?("district", seal_station[:opens])
    assert_equal :refused, world.station_cue[:kind]
    assert_equal seal_station[:at], world.station_cue[:at]
  end

  def test_seal_pays_opens_and_emits
    src = at_seal!
    world.pack.bank!(ECO[:breach_cost] + 7)
    spent = []
    breached = []
    world.bus.subscribe(:banked_spent) { |e| spent << e }
    world.bus.subscribe(:seal_breached) { |e| breached << e }
    assert world.interact(src)
    world.bus.process
    assert_equal 7, world.pack.banked
    assert world.breached?("district", seal_station[:opens])
    assert_equal 1, spent.length
    assert_equal :breach, spent.first[:sink]
    assert_equal 1, breached.length
    assert_equal "district", breached.first[:zone]
    assert_equal seal_station[:opens], breached.first[:tile]
    assert_equal ECO[:breach_cost], breached.first[:cost]
    refute_nil world.breach_line, "the breach line arms for the banner slot"
    assert_equal seal_station[:line], world.breach_line[:text]
  end

  def test_seal_second_press_is_inert
    src = at_seal!
    world.pack.bank!(ECO[:breach_cost] * 2)
    assert world.interact(src)
    refute world.interact(src), "a spent seal is inert"
    assert_equal ECO[:breach_cost], world.pack.banked, "no double spend"
    assert_nil world.station_price(seal_station), "price line stops rendering"
  end

  def test_breach_line_expires_on_its_display_clock
    src = at_seal!
    world.pack.bank!(ECO[:breach_cost])
    world.interact(src)
    frames = DATA["display"][:breach_banner_frames]
    # The breach kick hitstops the sim (strongest feel kick, 8 frames) and
    # hitstop pauses cosmetic clocks — the banner law. Slack covers it.
    drive(world, scripted({}), frames + HITSTOP_SLACK)
    assert_nil world.breach_line
  end

  # --- the sealed transition ---------------------------------------------

  def test_sealed_transition_refuses_before_breach
    at_seal!
    world.possessed.walker.teleport(*seal_station[:opens])
    drive(world, scripted({}), 3)
    assert_equal "district", world.zone_name, "a sealed door is not a gate"
  end

  def test_sealed_transition_carries_pack_after_breach
    src = at_seal!
    world.pack.bank!(ECO[:breach_cost])
    assert world.interact(src)
    src.walker.teleport(*seal_station[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "camp", world.zone_name
    assert_equal "The Second Vigil", world.map.display_name
    assert world.banner?, "arriving somewhere new announces itself"
  end

  def test_camp_declares_the_full_station_kit
    types = Core::TileMap.new(DATA["zones/camp"]).stations.map { |s| s[:type] }.sort
    assert_equal %w[altar bank vat], types
  end

  # --- breach state lifetime ----------------------------------------------

  def test_breach_survives_a_wipe
    src = at_seal!
    world.pack.bank!(ECO[:breach_cost])
    world.interact(src)
    world.pack.members.each { |m| m.take_hit(damage: m.hp, attacker: m) until m.dead? }
    drive(world, scripted({}), DATA["balance/combat"][:respawn_frames] + HITSTOP_SLACK + 5)
    assert_equal "nest", world.zone_name, "wipe still sends the pack home"
    assert world.breached?("district", seal_station[:opens]),
           "wipes never close the door — that is the arc"
  end

  def test_fresh_world_is_sealed_again
    refute Game::World.new(DATA).breached?("district", seal_station[:opens]),
           "the arc is session-scoped by fork: restart re-seals"
  end
end
