require_relative "../test_helper"
require_relative "../../tools/lane_guard"

# The multi-agent FENCE, hardened (review 2026-09-06): trusted-ref briefs,
# policy paths integrator-only, both sides of a rename fenced, SIM TOKEN for
# src/game/**, fail-closed parsing. Every shipped brief must parse, own no
# shared/policy path, and not overlap another brief.
class LaneGuardTest < Minitest::Test
  BRIEF = <<~MD
    ---
    lane: s4-equipment
    branch: lane/s4-equipment
    owns:
      - src/game/equipment.rb            # comment after a value
      - test/game/equipment_test.rb
      - "src/app/equip_*.rb"
      - data/balance/equipment/
    never:
      - src/game/world.rb
      - data/display.json
    objective: x
    ---
    body
  MD

  SHARED = %w[src/game/world.rb src/game/creature.rb src/net/protocol.rb src/game/save_state.rb
              data/display.json data/strings/en.json data/bindings.json data/balance/economy.json
              harness/gate_checks.json test/net/state_digest_test.rb test/game/save_state_test.rb
              data/art/manifest.json data/art/atlas/striker.png drafts/lanes/BOARD.md
              drafts/lanes/s5-attributes.md].freeze

  def cfg = @cfg ||= LaneGuard.parse_brief(BRIEF)

  def test_parses_real_yaml_front_matter_with_comments_quotes_bom_and_crlf
    assert_equal "s4-equipment", cfg["lane"]
    assert_equal "lane/s4-equipment", cfg["branch"]
    assert_equal %w[src/game/equipment.rb test/game/equipment_test.rb src/app/equip_*.rb data/balance/equipment/], cfg["owns"]
    c2 = LaneGuard.parse_brief("\xEF\xBB\xBF---\r\nlane: x\r\nowns: [a.rb]\r\n---\r\nbody")
    assert_equal ["a.rb"], c2["owns"]
  end

  def test_owned_pass_outside_forbidden_and_policy_refuse
    r = LaneGuard.check(cfg, %w[src/game/equipment.rb test/game/equipment_test.rb], token_holder: "s4-equipment")
    assert r[:ok], r.inspect
    r = LaneGuard.check(cfg, %w[src/game/stat_resolver.rb])
    assert_equal %w[src/game/stat_resolver.rb], r[:outside]
    r = LaneGuard.check(cfg, %w[src/game/world.rb])
    assert_equal %w[src/game/world.rb], r[:forbidden]
    r = LaneGuard.check(cfg, %w[drafts/lanes/s4-equipment.md drafts/lanes/BOARD.md])
    assert_equal %w[drafts/lanes/s4-equipment.md drafts/lanes/BOARD.md], r[:policy], "a lane never edits policy"
  end

  def test_sim_paths_need_the_token
    r = LaneGuard.check(cfg, %w[src/game/equipment.rb], token_holder: "Gabriel")
    refute r[:ok]
    assert_equal %w[src/game/equipment.rb], r[:sim]
    assert LaneGuard.check(cfg, %w[src/game/equipment.rb], token_holder: "s4-equipment")[:ok]
    assert LaneGuard.check(cfg, %w[test/game/equipment_test.rb], token_holder: nil)[:ok], "tests are not src/game"
    assert_equal "s4-equipment", LaneGuard.token_holder("# BOARD\n\nSIM TOKEN: s4-equipment (since 03:00) - next: s5\n")
    assert_nil LaneGuard.token_holder("no token line")
  end

  def test_a_brief_that_owns_policy_is_refused_at_parse
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nowns: [drafts/lanes/x.md]\n---\n") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nowns: [drafts/]\n---\n") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("no front matter") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nowns: []\n---\n") }
  end

  def test_renames_and_copies_fence_both_sides
    z = "R100\0src/game/world.rb\0src/game/equipment.rb\0M\0test/game/equipment_test.rb\0D\0data/display.json\0"
    paths = LaneGuard.changed_paths(z)
    assert_equal %w[src/game/world.rb src/game/equipment.rb test/game/equipment_test.rb data/display.json], paths
    r = LaneGuard.check(cfg, paths, token_holder: "s4-equipment")
    assert_equal %w[src/game/world.rb data/display.json], r[:forbidden], "the rename SOURCE and the deletion are fenced"
  end

  def test_globs_segment_star_and_subtree
    assert LaneGuard.match?("src/app/equip_*.rb", "src/app/equip_screen.rb")
    refute LaneGuard.match?("src/app/equip_*.rb", "src/app/equip/screen.rb"), "* stays within one segment"
    assert LaneGuard.match?("data/balance/equipment/", "data/balance/equipment/tier1.json")
    assert LaneGuard.match?("tmp/wall/**", "tmp/wall/a/b.log")
    refute LaneGuard.match?("data/balance/equipment/", "data/balance/equipment.json")
    assert LaneGuard.match?("src/game/**", "src/game/loot.rb")
  end

  def test_every_shipped_brief_parses_owns_no_shared_or_policy_path_and_lanes_do_not_overlap
    dir = File.expand_path("../../drafts/lanes", __dir__)
    briefs = Dir[File.join(dir, "*.md")].reject { |f| File.basename(f) =~ /\A(README|BOARD|_template)\.md\z/ }
    refute_empty briefs
    cfgs = briefs.map do |f|
      c = LaneGuard.parse_brief(File.read(f, encoding: "utf-8"))
      assert_equal File.basename(f, ".md"), c["lane"], "#{f}: lane name must equal the file name"
      assert_equal "lane/#{c['lane']}", c["branch"], "#{f}: branch = lane/<lane>"
      SHARED.each do |sf|
        refute c["owns"].any? { |o| LaneGuard.match?(o, sf) }, "#{c['lane']} owns SHARED/POLICY #{sf}"
      end
      c
    end
    # pairwise: a concrete path owned by one lane must not be owned by another
    probes = cfgs.flat_map { |c| c["owns"].map { |o| o.sub("**", "x/y").sub("*", "probe").sub(%r{/\z}, "/probe") } }.uniq
    probes.each do |path|
      owners = cfgs.select { |c| c["owns"].any? { |o| LaneGuard.match?(o, path) } }.map { |c| c["lane"] }
      assert_operator owners.length, :<=, 1, "#{path} is owned by #{owners.inspect} - two lanes on one path"
    end
  end
end
