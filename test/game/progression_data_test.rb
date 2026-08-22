require_relative "../test_helper"
require "core/data_store"

class ProgressionDataTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def test_every_zone_spawned_enemy_kit_has_kill_xp
    spawned_kits = DATA.keys.grep(/\Azones\//).flat_map do |key|
      DATA[key].fetch(:enemy_spawns, {}).keys
    end.uniq.sort
    priced_kits = DATA["balance/progression"][:kill_xp].keys

    missing = spawned_kits - priced_kits
    assert_empty missing,
                 "zone enemy_spawns missing kill_xp rows in progression.json: #{missing.inspect}"
  end
end
