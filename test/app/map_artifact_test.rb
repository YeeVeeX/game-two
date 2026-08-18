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
    "counters" => { "boss_1_defeats" => 3, "sessions" => 5 }
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

  # --- the labeled grid ------------------------------------------------------

  def test_layout_panels_every_zone_once_sorted_by_label
    l = artifact.layout(fresh_world)
    assert_equal ["HUB 1", "ZONE 1", "ZONE 2", "ZONE 3", "ZONE 4", "ZONE 5"],
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
