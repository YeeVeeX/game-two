require_relative "../test_helper"
require_relative "../../tools/lane_guard"

# The multi-agent FENCE, v3 (two fresh-eyes reviews, 2026-09-06): trusted-ref
# briefs, canonical paths, policy = glob intersection with drafts/lanes/ (minus
# receipts/), both sides of a rename, SIM LANE machine row, strict schema,
# fail-closed. Every shipped brief must parse, own no shared/policy path, and
# not overlap another brief.
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
      - drafts/lanes/receipts/s4-equipment.md
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
              drafts/lanes/README.md drafts/lanes/s5-attributes.md].freeze

  def cfg = @cfg ||= LaneGuard.parse_brief(BRIEF)

  def test_parses_real_yaml_front_matter_with_comments_quotes_bom_and_crlf
    assert_equal "s4-equipment", cfg["lane"]
    assert_equal "lane/s4-equipment", cfg["branch"]
    assert_equal 5, cfg["owns"].length
    c2 = LaneGuard.parse_brief("\xEF\xBB\xBF---\r\nlane: x\r\nbranch: lane/x\r\nowns: [a.rb]\r\n---\r\nbody")
    assert_equal ["a.rb"], c2["owns"]
  end

  def test_strict_schema_refuses_scalars_bad_branch_bad_lane_and_policy_owns
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nbranch: lane/x\nowns: src/x.rb\n---\n") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nbranch: main\nowns: [a.rb]\n---\n") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: X Y\nbranch: lane/X Y\nowns: [a.rb]\n---\n") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nbranch: lane/x\nowns: []\n---\n") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nbranch: lane/x\nowns: [\"\"]\n---\n") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("no front matter") }
    %w[drafts/lanes/x.md drafts/l*/x.md ./drafts/lanes/x.md drafts//lanes/x.md drafts/ drafts/** ** drafts/lanes/ drafts/lanes/receipts/../x.md].each do |bad|
      assert LaneGuard.policy?(bad), "#{bad.inspect} must be a policy pattern"
      assert_raises(LaneGuard::BadBrief, bad) { LaneGuard.parse_brief("---\nlane: x\nbranch: lane/x\nowns: [#{bad.inspect}]\n---\n") }
    end
    %w[drafts/lanes/receipts/x.md drafts/lanes/receipts/ drafts/_review-*.md tmp/review_*.md src/game/x.rb].each do |ok|
      refute LaneGuard.policy?(ok), "#{ok.inspect} is not policy"
    end
  end

  def test_canonical_paths_and_malformed_segments
    assert_equal "drafts/lanes/x.md", LaneGuard.canon("./drafts//lanes\\x.md")
    assert_nil LaneGuard.canon("drafts/lanes/receipts/../x.md")
    assert_nil LaneGuard.canon("./")
    r = LaneGuard.check(cfg, ["drafts/lanes/receipts/../s4-equipment.md", "src/game/equipment.rb"], sim_lane: "s4-equipment")
    assert_equal ["drafts/lanes/receipts/../s4-equipment.md"], r[:malformed]
    refute r[:ok]
  end

  def test_owned_pass_outside_forbidden_and_policy_refuse
    r = LaneGuard.check(cfg, %w[src/game/equipment.rb test/game/equipment_test.rb drafts/lanes/receipts/s4-equipment.md], sim_lane: "s4-equipment")
    assert r[:ok], r.inspect
    r = LaneGuard.check(cfg, %w[src/game/stat_resolver.rb])
    assert_equal %w[src/game/stat_resolver.rb], r[:outside]
    r = LaneGuard.check(cfg, %w[src/game/world.rb])
    assert_equal %w[src/game/world.rb], r[:forbidden]
    r = LaneGuard.check(cfg, ["drafts/lanes/s4-equipment.md", "drafts/lanes/BOARD.md", "./drafts//lanes/README.md"])
    assert_equal %w[drafts/lanes/s4-equipment.md drafts/lanes/BOARD.md drafts/lanes/README.md], r[:policy], "a lane never edits policy, in any spelling"
  end

  def test_sim_paths_need_the_sim_lane_row
    r = LaneGuard.check(cfg, %w[src/game/equipment.rb], sim_lane: nil)
    assert_equal %w[src/game/equipment.rb], r[:sim]
    assert LaneGuard.check(cfg, %w[src/game/equipment.rb], sim_lane: "s4-equipment")[:ok]
    assert LaneGuard.check(cfg, %w[test/game/equipment_test.rb], sim_lane: nil)[:ok], "tests are not src/game"
    board = "# BOARD\n\nSIM TOKEN: Gabriel (T1 schema 3) - human attribution\nSIM LANE: NONE\n"
    assert_nil LaneGuard.sim_lane(board), "a human name is attribution, never a lane grant"
    assert_equal "s4-equipment", LaneGuard.sim_lane("SIM TOKEN: Junior\nSIM LANE: s4-equipment\n")
    assert_nil LaneGuard.sim_lane("no rows")
  end

  def test_renames_copies_types_and_spaces_fence_both_sides
    z = "R100\0src/game/world.rb\0src/game/equipment.rb\0C075\0data/display.json\0data/balance/equipment/a b.json\0" \
        "M\0test/game/equipment_test.rb\0D\0data/strings/en.json\0T\0src/app/equip_x.rb\0U\0src/app/equip y.rb\0"
    paths = LaneGuard.changed_paths(z)
    assert_equal ["src/game/world.rb", "src/game/equipment.rb", "data/display.json", "data/balance/equipment/a b.json",
                  "test/game/equipment_test.rb", "data/strings/en.json", "src/app/equip_x.rb", "src/app/equip y.rb"], paths
    r = LaneGuard.check(cfg, paths, sim_lane: "s4-equipment")
    assert_equal %w[src/game/world.rb data/display.json], r[:forbidden], "rename/copy SOURCES are fenced"
    assert_equal ["data/strings/en.json", "src/app/equip y.rb"], r[:outside], "equip_*.rb has a literal underscore"
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
      SHARED.each do |sf|
        refute c["owns"].any? { |o| LaneGuard.match?(o, sf) }, "#{c['lane']} owns SHARED/POLICY #{sf}"
      end
      c
    end
    board = File.read(File.join(dir, "BOARD.md"), encoding: "utf-8")
    assert_match(/^SIM LANE: \S+$/m, board, "BOARD carries the machine row SIM LANE: <lane|NONE>")
    # pairwise: one concrete probe per pattern + every tracked file must have <= 1 owner
    probes = cfgs.flat_map { |c| c["owns"].map { |o| o.sub("**", "x/y").sub("*", "probe").sub(%r{/\z}, "/probe") } }
    tracked = `git -C #{File.expand_path("../..", __dir__).inspect} ls-files`.split("\n")
    (probes + tracked).uniq.each do |path|
      owners = cfgs.select { |c| c["owns"].any? { |o| LaneGuard.match?(o, path) } }.map { |c| c["lane"] }
      assert_operator owners.length, :<=, 1, "#{path} is owned by #{owners.inspect} - two lanes on one path"
    end
  end
end
