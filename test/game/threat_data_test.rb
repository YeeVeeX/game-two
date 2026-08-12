require_relative "../test_helper"
require "core/data_store"

class ThreatDataTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def setup
    @threat = DATA["balance/threat"]
  end

  def test_threat_keys_exist_and_are_sane
    assert @threat[:proximity_switch_margin_tiles] >= 1
    assert @threat[:lowhp_switch_pct].between?(0.05, 0.9)
    assert @threat[:engaged_cap_per_target] >= 1
    assert @threat[:pressure_ring_tiles] >= 2, "ring must sit outside melee adjacency"
    assert @threat[:leash_linger_frames] >= 1
    assert @threat[:respawn_block_tiles] > 10, "suppression must exceed rusher aggro_tiles (10)"
    assert @threat[:beachhead_tiles] < 10, "beachhead must sit inside aggro_tiles or it never binds"
  end
end
