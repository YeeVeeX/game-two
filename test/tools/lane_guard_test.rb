require_relative "../test_helper"
require_relative "../../tools/lane_guard"

# The multi-agent FENCE (drafts/_multiagent-lanes-design-20260906.md §2):
# a lane may touch only its `owns`, never its `never`; collisions between
# lanes are impossible by construction, not by trust. Every shipped brief
# must parse and must not own a shared file.
class LaneGuardTest < Minitest::Test
  BRIEF = <<~MD
    ---
    lane: s4-equipment
    branch: lane/s4-equipment
    owns:
      - src/game/equipment.rb
      - test/game/equipment_test.rb
      - src/app/equip_*.rb
      - data/balance/equipment/
    never:
      - src/game/world.rb
      - data/display.json
    objective: x
    ---
    body
  MD

  SHARED = %w[src/game/world.rb src/game/creature.rb src/net/protocol.rb data/display.json
              data/bindings.json data/balance/economy.json harness/gate_checks.json
              test/net/state_digest_test.rb test/game/save_state_test.rb].freeze

  def cfg = @cfg ||= LaneGuard.parse_brief(BRIEF)

  def test_parses_front_matter_lists_and_scalars
    assert_equal "s4-equipment", cfg["lane"]
    assert_equal "lane/s4-equipment", cfg["branch"]
    assert_equal 4, cfg["owns"].length
    assert_equal %w[src/game/world.rb data/display.json], cfg["never"]
  end

  def test_owned_files_pass_outside_and_forbidden_refuse
    r = LaneGuard.check(cfg, %w[src/game/equipment.rb test/game/equipment_test.rb])
    assert r[:ok], r.inspect
    r = LaneGuard.check(cfg, %w[src/game/equipment.rb src/game/stat_resolver.rb])
    refute r[:ok]
    assert_equal %w[src/game/stat_resolver.rb], r[:outside]
    r = LaneGuard.check(cfg, %w[src/game/world.rb])
    assert_equal %w[src/game/world.rb], r[:forbidden]
    assert_empty r[:outside], "never wins over owns/outside"
  end

  def test_globs_segment_star_and_subtree
    assert LaneGuard.match?("src/app/equip_*.rb", "src/app/equip_screen.rb")
    refute LaneGuard.match?("src/app/equip_*.rb", "src/app/equip/screen.rb"), "* stays within one segment"
    assert LaneGuard.match?("data/balance/equipment/", "data/balance/equipment/tier1.json")
    assert LaneGuard.match?("tmp/wall/**", "tmp/wall/a/b.log")
    refute LaneGuard.match?("data/balance/equipment/", "data/balance/equipment.json")
  end

  def test_bad_briefs_are_refused
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("no front matter") }
    assert_raises(LaneGuard::BadBrief) { LaneGuard.parse_brief("---\nlane: x\nowns:\n---\n") }
  end

  def test_every_shipped_brief_parses_and_owns_no_shared_file
    briefs = Dir[File.expand_path("../../drafts/lanes/*.md", __dir__)].reject { |f| File.basename(f) =~ /\A(README|BOARD|_template)\.md\z/ }
    refute_empty briefs, "no lane briefs shipped under drafts/lanes/"
    briefs.each do |f|
      c = LaneGuard.parse_brief(File.read(f, encoding: "utf-8"))
      assert_equal File.basename(f, ".md"), c["lane"], "#{f}: lane name must equal the file name"
      SHARED.each do |sf|
        refute c["owns"].any? { |o| LaneGuard.match?(o, sf) }, "#{c['lane']} owns the SHARED file #{sf} — shared files move only by PATCH REQUEST"
      end
    end
  end
end
