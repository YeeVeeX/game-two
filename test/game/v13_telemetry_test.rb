require_relative "../test_helper"
require "core/event_bus"
require "game/telemetry"

# v13 telemetry — the ELEVENTH ask's oracle lines. whirl.hits histogram is
# the hard number for "did density become YOUR weapon": a fat 3+ tail means
# ammunition, a 1-spike means a worse dash. Drift thirds replace guess three
# on the Q6 lane (instrument-first law).
class V13TelemetryTest < Minitest::Test
  ALL_EVENTS = %i[
    corpse_loaded corpse_looted carried_lost pack_wiped banked fight_resolved
    human_retargeted human_leashed actor_died drop_spawned
    inscribed banked_spent mark_consumed body_dissolved body_regrown
    tribute_paid vessel_kept human_respawned
    seal_breached home_rehomed zone_entered
    special_started attack_hit
  ].freeze

  # faction slot added at v14 (nil here = not pack — the first_special
  # subscriber reads it; nil skips safely, v13 assertions unchanged).
  Actor = Struct.new(:kit_name, :faction)
  Victim = Struct.new(:dead) { def dead? = dead }

  def bus = @bus ||= Core::EventBus.new.register(*ALL_EVENTS)

  def striker = @striker ||= Actor.new(:striker)
  def blocker = @blocker ||= Actor.new(:blocker)
  def lobber = @lobber ||= Actor.new(:lobber)

  def test_whirl_histogram_buckets_hits_per_cast
    t = Game::Telemetry.new(bus)
    bus.emit(:special_started, attacker: striker)
    3.times { bus.emit(:attack_hit, attacker: striker, victim: Victim.new(false), kind: :special, landed: true) }
    bus.emit(:special_started, attacker: striker)
    bus.emit(:attack_hit, attacker: striker, victim: Victim.new(true), kind: :special, landed: true)
    bus.process
    line = t.v13_summary
    assert_match(/casts=2/, line)
    assert_match(/hits\{1=1 2=0 3=1 4=0 5plus=0\}/, line)
    assert_match(/kills=1/, line, "dead victim on a special hit = whirl kill")
  end

  def test_whirl_ignores_basic_attacks_and_other_kits
    t = Game::Telemetry.new(bus)
    bus.emit(:special_started, attacker: striker)
    bus.emit(:attack_hit, attacker: striker, victim: Victim.new(false), kind: :attack, landed: true)
    bus.emit(:attack_hit, attacker: blocker, victim: Victim.new(false), kind: :special, landed: true)
    bus.emit(:attack_hit, attacker: striker, victim: Victim.new(false), kind: :special, landed: false)
    bus.process
    line = t.v13_summary
    assert_match(/casts=1/, line)
    assert_match(/hits\{1=0 2=0 3=0 4=0 5plus=0\}/, line, "whiffs/basics/blocker hits stay out")
  end

  def test_five_plus_bucket_catches_full_rings
    t = Game::Telemetry.new(bus)
    bus.emit(:special_started, attacker: striker)
    6.times { bus.emit(:attack_hit, attacker: striker, victim: Victim.new(false), kind: :special, landed: true) }
    bus.process
    assert_match(/hits\{1=0 2=0 3=0 4=0 5plus=1\}/, t.v13_summary)
  end

  def test_challenge_casts_count_blocker_specials_only
    t = Game::Telemetry.new(bus)
    bus.emit(:special_started, attacker: blocker)
    bus.emit(:special_started, attacker: blocker)
    bus.emit(:special_started, attacker: lobber) # volley — not a v13 special
    bus.emit(:human_retargeted, actor: nil, from: nil, to: nil, cause: :challenged)
    bus.process
    line = t.v13_summary
    assert_match(/challenge\{casts=2 retargets=1\}/, line)
  end

  def test_drift_thirds_bucket_kills_and_pocket_sizes_by_summary_frame
    world = Object.new
    class << world
      attr_accessor :frame, :pockets
      def density_pockets = pockets
      def gate_distance(_tile) = Float::INFINITY
      def map = Struct.new(:drop_gradient).new(nil)
      def zone_name = "district"
      def possessed = nil
      def pack = nil
    end
    world.frame = 50
    world.pockets = [[1, 2], [3]] # sizes 2 + 1 -> mean 1.5

    t = Game::Telemetry.new(bus, world:)
    human = Struct.new(:faction, :tile).new(:human, [0, 0])
    2.times { bus.emit(:actor_died, actor: human, killer: nil, faction: :human) }
    bus.emit(:human_respawned, anchor: :pocket) # pocket sample at frame 50
    bus.process
    world.frame = 290
    bus.emit(:actor_died, actor: human, killer: nil, faction: :human)
    bus.process
    world.frame = 300 # summary time: thirds = 0-99 / 100-199 / 200-299

    assert_match(/thirds\{k1=2 k2=0 k3=1\}/, t.drift_summary)
    assert_match(/pockets\{p1=1\.5 p2=0\.0 p3=0\.0\}/, t.drift_summary)
  end
end
