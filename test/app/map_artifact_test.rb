require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "game/world"
require "app/map_artifact"

# v18 god-view v0 (spec decision 13; test lane 6, the headless half).
# The offline map artifact renders every zone's grid from the SAME
# palette/identity data the renderer reads — these lanes pin the color
# SOURCE (zone palette + Renderer::SEAL_SLAB, never a second table), the
# labeled-grid layout, the header format, the SEALED/OPEN stamps, and the
# digest-provenance filename. The GL half (compose + pixel probes) runs
# inside `rake map PROBES=1` — a real window, the harness law; CI's rake
# stays headless (recorded micro-decision).
class MapArtifactTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  FACTS = {
    "banked" => 42, "provisions" => 2, "home_zone" => "camp",
    "breached" => [["district", [42, 13]]],
    "members" => [
      { "kit" => "striker", "hp" => 80, "inscribed" => true },
      { "kit" => "blocker", "hp" => 160, "inscribed" => false },
      { "kit" => "lobber", "hp" => 60, "inscribed" => false }
    ],
    "counters" => { "boss_1_defeats" => 3, "sessions" => 5 },
    "progression" => { "level" => 1, "xp" => 0 }
  }.freeze

  def artifact
    App::MapArtifact.new(DATA, strings: Core::Strings.new(DATA, locale: "en"))
  end

  def fresh_world = Game::World.new(DATA, seed: 0)
  def saved_world = Game::World.new(DATA, seed: 0, save: Marshal.load(Marshal.dump(FACTS)))

  # --- the palette-source law (no second color source) ----------------------

  def test_cell_colors_resolve_from_the_zone_palette_only
    w = fresh_world
    nest = w.zone_maps.fetch("nest")
    pal = DATA["zones/nest"][:palette]
    assert_equal pal[:floor], artifact.cell_rgb(w, "nest", nest, 5, 5)
    assert_equal pal[:wall], artifact.cell_rgb(w, "nest", nest, 0, 0)
    bank = DATA["zones/nest"][:stations].find { |s| s[:type] == "bank" }[:at]
    station_key = pal[:station] || pal[:wall]
    assert_equal station_key, artifact.cell_rgb(w, "nest", nest, *bank)
  end

  # T3: typed tiles resolve through the SAME TileVariants derivation the
  # renderer uses — the god-view shows the fixture's materials (variants
  # included), while nest's footstep-only remap keeps drawing floor (the
  # visible-overlay law holds on this surface too — the palette-source law
  # gains no second color source).
  def test_typed_cells_resolve_through_tile_variants
    w = fresh_world
    fixture = w.zone_maps.fetch("grass_fixture")
    pal = DATA["zones/grass_fixture"][:palette]
    a = artifact
    grass_rgbs = (1..8).flat_map { |tx| (1..11).map { |ty| a.cell_rgb(w, "grass_fixture", fixture, tx, ty) } }
    assert_equal [pal[:grass], pal[:grass_b], pal[:grass_c]].sort, grass_rgbs.uniq.sort,
                 "the grass field must show all three authored variants in god-view"
    assert_equal pal[:dirt], a.cell_rgb(w, "grass_fixture", fixture, 10, 6)
    assert_equal pal[:floor], a.cell_rgb(w, "grass_fixture", fixture, 16, 6), "plaza stone stays floor"
    assert_equal pal[:wood], a.cell_rgb(w, "grass_fixture", fixture, 21, 6)
    nest_pal = DATA["zones/nest"][:palette]
    assert_equal nest_pal[:floor], a.cell_rgb(w, "nest", w.zone_maps.fetch("nest"), 5, 5),
                 "nest's dirt remap stays invisible here too"
  end

  def test_seal_cells_read_breach_state_from_the_save
    sealed = fresh_world
    open   = saved_world
    map = sealed.zone_maps.fetch("district")
    seal_tile = map.transitions.find { |t| t[:sealed] && t[:at] == [42, 13] }
    refute_nil seal_tile, "staging: district's [42,13] way is seal-gated"
    slab = App::Renderer::SEAL_SLAB
    assert_equal [slab.red, slab.green, slab.blue],
                 artifact.cell_rgb(sealed, "district", map, 42, 13),
                 "sealed way draws the renderer's slab — same constant, no copy"
    assert_equal DATA["zones/district"][:palette][:transition],
                 artifact.cell_rgb(open, "district", open.zone_maps.fetch("district"), 42, 13),
                 "a breached way draws gold — walkable law"
  end

  # --- T4: drained-well swap + boss fact-gate, over fixture zone data
  # (real World/TileMap/registry; the store is a data fixture) -----------

  class FixtureStore
    def initialize(base, extra)
      @base = base
      @extra = extra
    end

    def [](key) = @extra.key?(key) ? @extra[key] : @base[key]
    def keys = (@base.keys + @extra.keys).uniq.sort
  end

  WELL_ZONE = {
    name: "upper", display_name: "UPPER", tile_size: 32,
    palette: { floor: [10, 10, 10], grid: [12, 12, 12], wall: [90, 90, 90],
               transition: [235, 190, 90], water: [30, 60, 90],
               water_drained: [50, 44, 30] },
    tiles: [
      "########",
      "#......#",
      "#.~~~..#",
      "#.~~~..#",
      "#.~~~..#",
      "#......#",
      "########"
    ],
    pack_spawn: [[1, 1], [2, 1], [3, 1]],
    enemy_spawns: {},
    stations: [
      { type: "seal", at: [1, 3], price: "breach_cost", opens: [3, 3], line: "TOLL PAID" }
    ],
    transitions: [
      { at: [3, 3], to: "upper", spawn: [1, 1], sealed: true, type: "hole" },
      { at: [5, 5], to: "upper", spawn: [1, 1], requires_defeats: 4 }
    ],
    water_drained_by: [3, 3]
  }.freeze

  def well_world(save: nil)
    store = FixtureStore.new(DATA, "zones/upper" => Marshal.load(Marshal.dump(WELL_ZONE)))
    Game::World.new(store, seed: 0, save:)
  end

  def test_water_cells_swap_to_drained_on_the_breach_fact
    w = well_world
    map = w.zone_maps.fetch("upper")
    assert_equal WELL_ZONE[:palette][:water], artifact.cell_rgb(w, "upper", map, 2, 2),
                 "undrained well shows water"
    w.restore_breach!("upper", [3, 3])
    assert_equal WELL_ZONE[:palette][:water_drained], artifact.cell_rgb(w, "upper", map, 2, 2),
                 "the persisted drain swaps the water ring to its dry look"
    assert_equal WELL_ZONE[:palette][:transition], artifact.cell_rgb(w, "upper", map, 3, 3),
                 "the drained hole is a walkable way — gold"
  end

  def test_boss_gate_cell_locks_until_the_counter_meets
    w = well_world # fresh: boss_1_defeats 0 < 4
    map = w.zone_maps.fetch("upper")
    slab = App::Renderer::SEAL_SLAB
    assert_equal [slab.red, slab.green, slab.blue], artifact.cell_rgb(w, "upper", map, 5, 5),
                 "an unmet fact-gate draws the same shut-way slab"
    stamp = artifact.seal_stamps(w).find { |s| s[:zone] == "upper" && s[:at] == [5, 5] }
    assert_equal "SEALED", stamp[:text], "fact-gates join the stamp grammar"
  end

  def test_boss_gate_cell_opens_on_the_persisted_fact
    members = DATA["balance/combat"][:pack][:members].map do |kit|
      { "kit" => kit, "hp" => 1, "inscribed" => false }
    end
    facts = { "banked" => 0, "provisions" => 0, "home_zone" => "nest", "breached" => [],
              "members" => members, "counters" => { "boss_1_defeats" => 4, "sessions" => 1 },
              "progression" => { "level" => 1, "xp" => 0 } }
    w = well_world(save: facts)
    map = w.zone_maps.fetch("upper")
    assert_equal WELL_ZONE[:palette][:transition], artifact.cell_rgb(w, "upper", map, 5, 5)
    stamp = artifact.seal_stamps(w).find { |s| s[:zone] == "upper" && s[:at] == [5, 5] }
    assert_equal "OPEN", stamp[:text]
  end

  # --- the labeled grid ------------------------------------------------------

  def test_layout_panels_every_zone_once_sorted_by_label
    l = artifact.layout(fresh_world)
    assert_equal ["BASEMENT 1", "BASEMENT 2", "DUNGEON 1", "HUB 1", "ZONE 1", "ZONE 2",
                  "ZONE 3", "ZONE 4", "ZONE 5", "ZONE 6", "ZONE 7"],
                 l[:panels].map { |p| p[:label] }
    assert_equal l[:panels].map { |p| p[:origin] }.uniq.length, l[:panels].length
    assert l[:width].positive? && l[:height].positive?
  end

  def test_home_marker_follows_the_loaded_home_zone
    fresh = artifact.layout(fresh_world)
    assert_equal ["nest"], fresh[:panels].select { |p| p[:home] }.map { |p| p[:name] },
                 "fresh world homes at the nest"
    saved = artifact.layout(saved_world)
    assert_equal ["camp"], saved[:panels].select { |p| p[:home] }.map { |p| p[:name] },
                 "the save's home_zone carries the marker"
  end

  # --- header + stamps + filename -------------------------------------------

  def test_header_reads_the_persisted_counters
    assert_equal "BANKED 42 · MARKS 1 · PROVISIONS 2 · BOSS 1 DEFEATS 3",
                 artifact.header_text(saved_world)
  end

  def test_seal_stamps_name_both_states
    stamps = artifact.seal_stamps(saved_world)
    open = stamps.find { |s| s[:zone] == "district" && s[:at] == [42, 13] }
    assert_equal "OPEN", open[:text]
    refute_empty stamps.select { |s| s[:text] == "SEALED" },
                 "every unbreached seal stamps SEALED"
  end

  def test_filename_carries_digest_provenance
    w = saved_world
    name = artifact.filename(w)
    assert_match(/\Aworld_[0-9a-f]{8}_\d+\.png\z/, name)
    assert name.start_with?("world_#{Game::SaveState.digest(w.save_facts)[0, 8]}_"),
           "digest8 comes from the WORLD's own facts — provenance, not decoration"
  end
end
