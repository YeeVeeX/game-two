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
  ZONES = %w[zone_7 basement_1 basement_2 dungeon_1].freeze

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
end
