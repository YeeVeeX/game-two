require_relative "../test_helper"
require "json"
require "core/tile_registry"
require_relative "../../tools/import_ldtk"

# T4 provenance pin (D1/D2/D12): the four committed pilot zones are the
# EXACT bytes the production importer emits from the committed authoring
# project — the world provably came through the only door. If either side
# drifts (a hand edit to data/zones, an authoring change without re-import,
# an emitter change), this pin names it.
class PilotAuthoringTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PROJECT = File.join(ROOT, "authoring/pilot.ldtk")
  ZONES = %w[zone_7 basement_1 basement_2 dungeon_1 dungeon_2 dungeon_3 dungeon_4 ember_1 ember_2 ember_3 district district_two low_quay].freeze

  def test_committed_pilot_zones_are_the_importer_emission
    doc = JSON.parse(File.read(PROJECT))
    registry = Core::TileRegistry.new(JSON.parse(File.read(File.join(ROOT, "data/tiles.json"))))
    sidecars = ZONES.to_h do |z|
      [z, JSON.parse(File.read(File.join(ROOT, "authoring/#{z}.sidecar.json")))]
    end
    known = Dir[File.join(ROOT, "data/zones/*.json")].map { |p| File.basename(p, ".json") }
    emitted = Tools::LdtkImporter.new(registry:, sidecars:, known_zones: known).import(doc)
    assert_equal ZONES.sort, emitted.keys.sort
    ZONES.each do |zone|
      committed = File.read(File.join(ROOT, "data/zones/#{zone}.json"))
      # autocrlf checkouts materialize CRLF in the working tree; the
      # emitter's canonical bytes are LF — compare normalized so the pin
      # judges CONTENT drift, not the clone's eol setting (Junior's seat).
      assert_equal emitted.fetch(zone), committed.gsub("\r\n", "\n"),
                   "data/zones/#{zone}.json drifted from the authoring emission (re-import or revert)"
    end
  end

  def test_authoring_project_carries_the_pinned_version
    doc = JSON.parse(File.read(PROJECT))
    assert_equal "1.5.3", doc["jsonVersion"], "the pilot project rides the D1 pin"
    assert_equal "Free", doc["identifierStyle"]
  end

  # WB-T6 GUI-safety pin (hit live 2026-09-05): LDtk 1.5.3 ZEROES every
  # IntGrid cell whose value the layer def does not declare -- the first GUI
  # save of the MUNDO VIVO floors destroyed 924 cells (values 9/10/12 written
  # by builders that skipped the T6b declaration law). The importer reads the
  # registry, never the defs, so the suite was green while the editor was a
  # trap. Every value a level uses must be declared, and every declaration
  # must be a registry type.
  def test_every_used_intgrid_value_is_declared_in_the_terrain_def
    doc = JSON.parse(File.read(PROJECT))
    terrain_def = doc["defs"]["layers"].find { |l| l["identifier"] == "Terrain" }
    declared = terrain_def["intGridValues"].to_h { |v| [v["value"], v["identifier"]] }
    registry = JSON.parse(File.read(File.join(ROOT, "data/tiles.json")))["types"]
    registry_values = registry.to_h { |id, t| [t["int_grid"], id] }
    used = doc["levels"].flat_map do |l|
      l["layerInstances"].select { |li| li["__identifier"] == "Terrain" }.flat_map { |li| li["intGridCsv"] }
    end.uniq - [0]
    assert_empty used - declared.keys,
                 "IntGrid value(s) used by a level but undeclared in the Terrain def -- LDtk zeroes them on save"
    assert_equal registry_values, declared, "Terrain def declarations must mirror data/tiles.json (value => type id)"
  end
end
