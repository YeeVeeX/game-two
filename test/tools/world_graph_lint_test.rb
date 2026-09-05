require_relative "../test_helper"
require "json"
require "open3"
require "tmpdir"
require "fileutils"
require "core/tile_map"
require "core/tile_registry"
require_relative "../../tools/lint_world_graph"

# WB-T6 (S2): the world-graph lint's blocking contract. The live world
# (data/zones, real files, the game's own loader path) may carry ONLY the
# allowlisted floor-delta rows; a NEW hard finding or a STALE allowlist
# row is red. Checks (1)/(2) restate boot law (Game::Crossing
# .validated_arrivals) and must agree with it: zero rows on the live
# world. A synthetic bad graph proves every check fires.
class WorldGraphLintTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  ZONES = File.join(ROOT, "data/zones")
  TILES = File.join(ROOT, "data/tiles.json")
  ALLOWLIST = File.join(ROOT, "authoring/world_graph_allowlist.json")
  LINT = File.join(ROOT, "tools/lint_world_graph.rb")

  def self.live
    @live ||= Tools::WorldGraphLint.new(Tools::WorldGraphLint.load_zones([ZONES], TILES))
  end

  def allowlist = Tools::WorldGraphLint.load_allowlist(ALLOWLIST)

  # --- the blocking test ---------------------------------------------------

  def test_live_world_carries_no_new_hard_finding_and_no_stale_allowlist_row
    lint = self.class.live
    new_hard = lint.new_hard_findings(allowlist)
    assert_empty new_hard.map(&:to_s),
                 "NEW world-graph violation(s) — fix the zone through its lawful edit path, or " \
                 "classify the row in authoring/world_graph_allowlist.json with a reason"
    stale = lint.stale_allowlist(allowlist)
    assert_empty stale.map { |r| Tools::WorldGraphLint.row_key(r) },
                 "allowlist row(s) match no finding — the row was fixed; remove it from the list"
  end

  def test_checks_one_and_two_agree_with_the_boot_law_on_the_live_world
    rows = self.class.live.hard_findings.select { |f| %i[target spawn].include?(f.check) }
    assert_empty rows.map(&:to_s), "Crossing.validated_arrivals would refuse this world at boot"
  end

  def test_every_transition_type_has_a_floor_delta_law
    assert_equal Core::TileMap::TRANSITION_TYPES.sort,
                 (Tools::WorldGraphLint::EXPECTED_DELTA.keys - [nil]).sort,
                 "a new transition type needs its floor-delta row"
  end

  def test_allowlist_rows_are_classified_with_reasons
    rows = allowlist
    refute_empty rows
    rows.each do |r|
      assert_includes Tools::WorldGraphLint::ALLOWLIST_STATUSES, r["status"]
      assert_operator r["reason"].length, :>=, 20, "row #{r['zone']} #{r['at']}: a reason both peers can read"
    end
  end

  # --- synthetic proofs (real TileMap objects, real registry) -------------

  def zone(name, floor:, transitions:, tiles: %w[##### #...# #...# #...# #####])
    cfg = { name:, display_name: name.upcase, tile_size: 32, palette: { floor: "#333333", wall: "#777777" },
            tiles:, pack_spawn: [[1, 1], [2, 1], [3, 1]], enemy_spawns: {}, stations: [],
            transitions: }
    cfg[:floor] = floor
    Core::TileMap.new(cfg)
  end

  def test_synthetic_bad_graph_fires_every_check
    zones = {
      "top" => zone("top", floor: 0, transitions: [
        { at: [1, 2], to: "mid", spawn: [1, 2], type: "stairs_down" }, # ok
        { at: [2, 2], to: "mid", spawn: [1, 3], type: "hole" },        # ok, one-way (info)
        { at: [3, 2], to: "nowhere", spawn: [1, 1] },                  # (1) target
        { at: [1, 3], to: "mid", spawn: [0, 0] },                      # (2) spawn on a wall + (3) gate 0 -> -1
        { at: [2, 3], to: "mid", spawn: [9, 9], type: "stairs_down" }  # (2) spawn out of bounds
      ]),
      "mid" => zone("mid", floor: -1, transitions: [
        { at: [3, 3], to: "deep", spawn: [1, 2], type: "stairs_down" } # ok (-1 -> -2)
      ]),
      "deep" => zone("deep", floor: -2, transitions: [
        { at: [3, 3], to: "mid", spawn: [1, 2], type: "stairs_up" },   # ok (+1), reciprocal
        { at: [3, 1], to: "mid", spawn: [2, 2], type: "rope_spot" }    # ok (+1)
      ])
    }
    lint = Tools::WorldGraphLint.new(zones)
    by = lint.findings.group_by(&:check)
    assert_equal ["top [3, 2] -> nowhere"], by[:target].map { |f| "#{f.zone} #{f.at} -> #{f.to}" }
    assert_match(/unknown zone "nowhere"/, by[:target].first.message)
    assert_equal [[1, 3], [2, 3]], by[:spawn].map(&:at).sort
    assert_match(/lands on "#" \(impassable\) in mid/, by[:spawn].find { |f| f.at == [1, 3] }.message)
    assert_match(/outside mid's 5x5 bounds/, by[:spawn].find { |f| f.at == [2, 3] }.message)
    assert_equal [[1, 3]], by[:floor].map(&:at)
    assert_match(/gate: floor 0 -> -1 \(delta -1, plain gate expects \+0\)/, by[:floor].first.message)
    assert_equal [:info], by[:return].map(&:severity).uniq
    assert_equal [[1, 2], [1, 3], [2, 2], [2, 3]], by[:return].map(&:at).sort,
                 "every top -> mid edge lacks a mid -> top; the dangling nowhere edge is not double-counted; mid <-> deep is reciprocal"
    assert_match(/hole: one-way by law D4/, by[:return].find { |f| f.at == [2, 2] }.message)
    refute_match(/one-way/, by[:return].find { |f| f.at == [1, 2] }.message, "stairs are not one-way by law")
    assert_equal 4, lint.hard_findings.length
    assert_equal 4, lint.new_hard_findings([]).length
    allow = [{ "check" => "floor", "zone" => "top", "at" => [1, 3], "to" => "mid", "status" => "legacy", "reason" => "test row" }]
    assert_equal 3, lint.new_hard_findings(allow).length
    stale = [{ "check" => "floor", "zone" => "top", "at" => [4, 4], "to" => "mid", "status" => "intended", "reason" => "gone" }]
    assert_equal stale, lint.stale_allowlist(stale)
  end

  def test_floor_delta_law_per_type
    { "stairs_down" => -1, "hole" => -1, "stairs_up" => 1, "rope_spot" => 1, nil => 0 }.each do |type, delta|
      good = { "a" => zone("a", floor: 0, transitions: [{ at: [1, 2], to: "b", spawn: [1, 2], type: }.compact]),
               "b" => zone("b", floor: delta, transitions: [{ at: [1, 2], to: "a", spawn: [1, 2] }]) }
      assert_empty Tools::WorldGraphLint.new(good).findings.select { |f| f.check == :floor && f.zone == "a" },
                   "#{type.inspect} with delta #{delta} is lawful"
      bad = { "a" => zone("a", floor: 0, transitions: [{ at: [1, 2], to: "b", spawn: [1, 2], type: }.compact]),
              "b" => zone("b", floor: delta + 1, transitions: []) }
      assert_equal 1, Tools::WorldGraphLint.new(bad).findings.count { |f| f.check == :floor && f.zone == "a" },
                   "#{type.inspect} with delta #{delta + 1} is a finding"
    end
  end

  def test_loader_refuses_a_zone_the_game_would_refuse
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "broken.json"),
                 JSON.generate({ name: "broken", display_name: "X", tile_size: 32, palette: {},
                                 tiles: %w[### #.# ###], pack_spawn: [[1, 1]], transitions: [] }))
      e = assert_raises(Tools::WorldGraphLint::Refusal) { Tools::WorldGraphLint.load_zones([dir], TILES) }
      assert_match(/zone broken .* refused by the loader — pack_spawn needs >= 3 tiles/, e.message)
    end
  end

  def test_overlay_dir_replaces_same_named_zones
    Dir.mktmpdir do |dir|
      overlay = File.join(dir, "overlay")
      FileUtils.mkdir_p(overlay)
      nest = JSON.parse(File.read(File.join(ZONES, "nest.json")))
      nest["floor"] = -1
      File.write(File.join(overlay, "nest.json"), JSON.generate(nest))
      zones = Tools::WorldGraphLint.load_zones([ZONES, overlay], TILES)
      assert_equal -1, zones.fetch("nest").floor
      assert_equal self.class.live.instance_variable_get(:@zones).length, zones.length, "overlay replaces, never adds"
    end
  end

  # --- the CLI (what the AfterSave driver runs) ----------------------------

  def test_cli_live_world_exits_zero_and_summarizes
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, LINT, "--zones", ZONES, "--tiles", TILES,
                                            "--allowlist", ALLOWLIST)
    assert status.success?, stderr + stdout
    assert_match(/\AWORLD GRAPH LINT: 20 zones, \d+ transitions .* 0 NEW, 0 stale/, stdout)
  end

  def test_cli_exits_one_on_a_new_violation_and_names_it
    Dir.mktmpdir do |dir|
      overlay = File.join(dir, "overlay")
      FileUtils.mkdir_p(overlay)
      camp = JSON.parse(File.read(File.join(ZONES, "camp.json")))
      camp["transitions"] << { "at" => camp["transitions"].first["at"].dup.tap { |a| a[0] += 1 },
                               "to" => "district", "spawn" => [11, 87], "type" => "stairs_up" }
      File.write(File.join(overlay, "camp.json"), JSON.generate(camp))
      stdout, _, status = Open3.capture3(RbConfig.ruby, LINT, "--zones", ZONES, "--overlay", overlay,
                                         "--tiles", TILES, "--allowlist", ALLOWLIST)
      assert_equal 1, status.exitstatus
      assert_match(/NEW HARD floor camp .* -> district: stairs_up: floor 0 -> -1 \(delta -1, stairs_up expects \+1\)/, stdout)
    end
  end

  def test_cli_refuses_unloadable_input_named
    _, stderr, status = Open3.capture3(RbConfig.ruby, LINT, "--zones", File.join(ROOT, "no_such_dir"))
    assert_equal 2, status.exitstatus
    assert_match(/LINT REFUSED: zones dir .*no_such_dir.* does not exist/, stderr)
  end
end
