require_relative "../test_helper"
require "core/event_bus"
require "game/telemetry"

# v14 telemetry — the TWELFTH ask's arbiters. span_thirds re-buckets the
# same kill frames over the first->last-kill SPAN (the legacy session-
# denominator thirds stay untouched beside it — comparability both
# directions; the eleventh's all-k3 read was session-shape sensitivity).
# first_special{kit} arbitrates discovery (overlay -> earlier first casts);
# `never` sentinel because World starts at frame 0 (Codex fold — a 0
# sentinel would collide with a legal frame-0 cast).
class V14TelemetryTest < Minitest::Test
  ALL_EVENTS = %i[
    corpse_loaded corpse_looted carried_lost pack_wiped banked fight_resolved
    human_retargeted human_leashed actor_died drop_spawned
    inscribed banked_spent mark_consumed body_dissolved body_regrown
    tribute_paid vessel_kept human_respawned
    seal_breached home_rehomed zone_entered
    special_started attack_hit
  ].freeze

  Actor = Struct.new(:kit_name, :faction)
  Human = Struct.new(:faction, :tile)

  def bus = @bus ||= Core::EventBus.new.register(*ALL_EVENTS)

  # Minimal world stub: telemetry reads frame + the drop-gradient guards.
  def world_at(frame)
    w = Object.new
    class << w
      attr_accessor :frame
      def density_pockets = []
      def gate_distance(_tile) = Float::INFINITY
      def map = Struct.new(:drop_gradient).new(nil)
      def zone_name = "district"
      def possessed = nil
      def pack = nil
    end
    w.frame = frame
    w
  end

  def kill_at(t, world, frame)
    world.frame = frame
    bus.emit(:actor_died, actor: Human.new(:human, [0, 0]), killer: nil, faction: :human)
    bus.process
    t
  end

  # --- span_thirds ---------------------------------------------------------

  def test_span_thirds_zero_kills
    t = Game::Telemetry.new(bus, world: world_at(0))
    assert_match(/span_thirds\{k1=0 k2=0 k3=0 span=0\}/, t.drift_summary)
  end

  def test_span_thirds_single_kill
    w = world_at(0)
    t = Game::Telemetry.new(bus, world: w)
    kill_at(t, w, 500)
    assert_match(/span_thirds\{k1=1 k2=0 k3=0 span=1\}/, t.drift_summary)
  end

  def test_span_thirds_ignores_pre_combat_head
    # Kills late in a long session: legacy thirds bucket everything k3
    # (the eleventh's exact shape); span_thirds spreads them evenly.
    w = world_at(0)
    t = Game::Telemetry.new(bus, world: w)
    [9000, 9100, 9200].each { |f| kill_at(t, w, f) }
    w.frame = 10_000
    line = t.drift_summary
    assert_match(/thirds\{k1=0 k2=0 k3=3\}/, line, "legacy field unchanged beside the companion")
    assert_match(/span_thirds\{k1=1 k2=1 k3=1 span=201\}/, line)
  end

  def test_span_thirds_ignores_idle_tail
    w = world_at(0)
    t = Game::Telemetry.new(bus, world: w)
    [100, 200, 300].each { |f| kill_at(t, w, f) }
    w.frame = 10_000
    line = t.drift_summary
    assert_match(/thirds\{k1=3 k2=0 k3=0\}/, line)
    assert_match(/span_thirds\{k1=1 k2=1 k3=1 span=201\}/, line)
  end

  def test_span_thirds_reads_clustering_inside_the_span
    w = world_at(0)
    t = Game::Telemetry.new(bus, world: w)
    [100, 101, 102, 103, 104, 700].each { |f| kill_at(t, w, f) }
    assert_match(/span_thirds\{k1=5 k2=0 k3=1 span=601\}/, t.drift_summary)
  end

  # --- first_special -------------------------------------------------------

  def test_first_special_records_first_frame_per_kit_only
    w = world_at(50)
    t = Game::Telemetry.new(bus, world: w)
    bus.emit(:special_started, attacker: Actor.new(:striker, :pack))
    bus.process
    w.frame = 90
    bus.emit(:special_started, attacker: Actor.new(:striker, :pack))
    bus.emit(:special_started, attacker: Actor.new(:lobber, :pack))
    bus.process
    assert_match(/first_special\{striker=50 blocker=never lobber=90\}/, t.v14_summary)
  end

  def test_first_special_ignores_non_pack_casters
    t = Game::Telemetry.new(bus, world: world_at(10))
    bus.emit(:special_started, attacker: Actor.new(:striker, :human))
    bus.process
    assert_match(/first_special\{striker=never blocker=never lobber=never\}/, t.v14_summary)
  end

  # --- telegraphs_shown ----------------------------------------------------

  def test_telegraphs_shown_counts_registered_event
    bus.register(:respawn_telegraphed)
    t = Game::Telemetry.new(bus, world: world_at(0))
    3.times { bus.emit(:respawn_telegraphed, tile: [1, 1], kit_name: :rusher, at_frame: 300) }
    bus.process
    assert_match(/telegraphs_shown=3/, t.v14_summary)
  end

  def test_v14_line_always_prints_all_zero
    # The zero-line law: an unexercised session must still print the line
    # (subscriber-alive proof), on a bus that never registered the
    # telegraph event (pre-TDD-3 world shape).
    t = Game::Telemetry.new(bus, world: world_at(0))
    assert_match(/\ATELEMETRY v14 telegraphs_shown=0 first_special\{striker=never blocker=never lobber=never\}\z/,
                 t.v14_summary)
    assert_includes t.summary, "TELEMETRY v14"
  end
end
