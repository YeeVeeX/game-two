require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "game/world"
require "app/stats_panel"
require "json"

# J-3 stats panel v0 (s74): the pure model over a REAL World — the panel's
# law is READER IDENTITY: every number equals the output of the same
# Progression/creature reader the sim hits (damage_for = leveled_damage's
# pack branch, special_impact_distances_for = volley_distances, live
# hp/max_hp); the panel never computes growth math (non-negotiable 3).
# Sim numbers stay unfrozen — every expectation derives from the live
# readers, never a pinned constant (progression_test law). Pixels are
# judged by the Rule 2 gate (menu_tour reel, menu_stats_reads row).
class StatsPanelTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def world = @world ||= Game::World.new(DATA, seed: 0)

  def panel
    @panel ||= App::StatsPanel.new(display: DATA["display"],
                                   strings: Core::Strings.new(DATA, locale: "en"))
  end

  def model = panel.model(world)

  # Award exactly enough XP to land the next level — the amount comes
  # from the live curve, so a k/cap retune never breaks this file.
  def level_up!(prog) = prog.award(prog.delta_e(prog.level + 1) - prog.xp)

  def lobber = world.pack.members.find { |m| m.kit_name == :lobber }

  def test_nil_without_a_world
    assert_nil panel.model(nil), "stats screen describes nothing without a world"
  end

  def test_header_reads_level_xp_threshold_and_session_xp
    prog = world.progression
    m = model
    assert_equal "LEVEL #{prog.level} · XP #{prog.xp}/#{prog.delta_e(prog.level + 1)}",
                 m[:header][0], "level + XP INTO next with its threshold (net_model format)"
    assert_equal "SESSION XP 0", m[:header][1],
                 "kills_xp is SESSION-earned by construction (P12; not a save fact) — " \
                 "the label says so honestly"
  end

  def test_session_xp_reads_kills_xp_through_the_real_award_path
    prog = world.progression
    prog.award_kill(:husk)
    assert prog.kills_xp.positive?, "staging: the kill-XP award landed"
    assert_equal "SESSION XP #{prog.kills_xp}", model[:header][1]
  end

  def test_header_shows_max_at_cap_and_growth_shows_no_next
    prog = world.progression
    level_up!(prog) while prog.level < prog.level_cap
    m = model
    assert_equal "LEVEL #{prog.level_cap} · XP MAX", m[:header][0],
                 "a capped bar reads MAX, never a misleading fraction"
    m[:growth].each do |row|
      refute_includes row, "NEXT",
                      "no threshold can sit above the cap (construction refuses dead " \
                      "rows) — a capped pack sees no NEXT"
    end
  end

  def test_body_rows_are_reader_identical
    prog = world.progression
    2.times { level_up!(prog) }
    world.pack.sync_max_hp!(progression: prog) # the world's :level_up handler verbatim
    m = model
    assert_equal ["player 1", "player 2", "player 3"],
                 m[:bodies].map { |b| b[:text][/\Aplayer \d/] },
                 "bodies wear the ratified overlay.vessel placeholders"
    world.pack.members.each_with_index do |mem, i|
      row = m[:bodies][i][:text]
      assert_includes row, "HP #{mem.hp}/#{mem.max_hp}",
                      "HP is the LIVE creature pair (max already leveled via sync)"
      assert_includes row, "DMG #{prog.damage_for(mem.kit[:attack][:damage])}",
                      "damage = the sim's own reader over the kit attack base " \
                      "(leveled_damage's pack branch verbatim)"
      refute m[:bodies][i][:dead]
      refute_includes row, "DEAD"
    end
    growth_pct = DATA["balance/progression"][:growth][:dmg_growth_pct]
    if growth_pct.positive?
      base = world.pack.members.first.kit[:attack][:damage]
      assert_operator prog.damage_for(base), :>, base,
                      "integer growth is VISIBLE on the row after leveling"
    end
  end

  def test_dead_body_is_marked_and_dimmed
    striker = world.pack.members.first
    striker.take_hit(damage: striker.hp, attacker: world.pack.members.last)
    assert striker.dead?, "staging: the body died"
    m = model
    assert m[:bodies][0][:dead], "dead flag drives the DIM tone in #draw"
    assert_includes m[:bodies][0][:text], "DEAD"
    assert_includes m[:bodies][0][:text], "HP 0/#{striker.max_hp}",
                    "a dead row still shows the ceiling the vat would revive into"
  end

  def test_growth_row_reads_the_real_tier_and_next_threshold
    prog = world.progression
    base = lobber.kit.dig(:special, :impact_distances)
    row = model[:growth].find { |r| r.start_with?("player 3") }
    refute_nil row, "the kit carrying impact distances gets a growth row"
    active = prog.special_impact_distances_for(:lobber, base:)
    assert_includes row, "REACH #{active.join('-')}",
                    "the CURRENT tier honestly — volley_distances' reader verbatim"
    if (nxt = prog.next_spell_growth_level(:lobber))
      assert_includes row, "NEXT L#{nxt}",
                      "the mid/late bloomer shows where the curve moves next"
    end
  end

  def test_growth_row_moves_with_the_level
    prog = world.progression
    base = lobber.kit.dig(:special, :impact_distances)
    before = prog.special_impact_distances_for(:lobber, base:)
    while (nxt = prog.next_spell_growth_level(:lobber))
      level_up!(prog) while prog.level < nxt
    end
    after = prog.special_impact_distances_for(:lobber, base:)
    row = model[:growth].find { |r| r.start_with?("player 3") }
    assert_includes row, "REACH #{after.join('-')}"
    refute_equal before, after,
                 "v19 data ships lobber growth — climbing every threshold must move " \
                 "the tier (if this fails the data dropped its growth rows)"
  end

  def test_panel_never_holds_a_world_ref
    model
    refute_includes panel.instance_variables, :@world,
                    "world arrives as an argument every call (menu D7 law)"
    ctor = App::StatsPanel.instance_method(:initialize).parameters.map(&:last)
    refute_includes ctor, :world, "no world enters at the ctor either"
  end

  def test_stats_keys_ship_in_all_three_locales
    %w[en es pt-br].each do |locale|
      table = JSON.parse(
        File.read(File.expand_path("../../data/strings/#{locale}.json", __dir__))
      )
      %w[menu.stats stats.session_xp stats.damage stats.reach
         stats.next stats.dead].each do |key|
        assert table.key?(key), "#{locale} missing #{key}"
      end
    end
  end
end
