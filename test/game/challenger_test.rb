require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# v15 increments 3-4: Varekka — chant (120f, interruptible, pinned) ->
# forced-approach seizure (450f; swap always escapes; damage interrupts;
# his death ends everything). Real World on the real zone chain, no
# mocks. Where a test needs a quiet room the quay crew dies by the real
# kill verb; human respawns land at ~420f (120 telegraph + 300 delay),
# so short tests stay clean and long tests assert STATE, not positions.
class ChallengerTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  HITSTOP_SLACK = DATA["balance/combat"][:feel][:hitstop_frames_kill] + 4
  SEIZE = DATA["balance/combat"][:kits][:challenger][:seize]

  def world = @world ||= Game::World.new(DATA)

  def scripted(frames) = Core::ScriptedInput.new(frames:)

  def drive(world, input, n)
    n.times do
      input.update(world.frame)
      world.tick(input)
    end
  end

  def seal1
    @seal1 ||= DATA["zones/district"][:stations].find { |s| s[:type] == "seal" }
  end

  def seal2
    @seal2 ||= DATA["zones/district_two"][:stations].find { |s| s[:type] == "seal" }
  end

  def enter_slow_door!
    world.possessed.walker.teleport(29, 8)
    drive(world, scripted({}), 2)
    src = world.possessed
    src.walker.teleport(*seal1[:at])
    (world.pack.living - [src]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.pack.bank!(ECO[:breach_cost])
    assert world.interact(src)
    src.walker.teleport(*seal1[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    world.possessed.walker.teleport(19, 5)
    drive(world, scripted({}), 2)
    src = world.possessed
    src.walker.teleport(*seal2[:at])
    (world.pack.living - [src]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.pack.bank!(ECO[:breach_cost_2])
    assert world.interact(src)
    src.walker.teleport(*seal2[:opens])
    drive(world, scripted({}), HITSTOP_SLACK)
    assert_equal "slow_door", world.zone_name
  end

  def descend!
    enter_slow_door!
    world.possessed.walker.teleport(7, 1)
    drive(world, scripted({}), 2)
    assert_equal "low_quay", world.zone_name
  end

  def varekka = world.humans.find { |h| h.kit_name == :challenger }

  # Real kill verb; corpses/drops are deterministic noise the tests ignore.
  # The kills land as possessed kills -> feel.on_kill HITSTOP freezes the
  # sim — burn the window here so test drives count real ticks.
  def clear_crew!
    world.humans.reject { |h| h.kit_name == :challenger }.each do |h|
      h.take_hit(damage: 9_999, attacker: world.possessed)
    end
    drive(world, scripted({}), HITSTOP_SLACK * 2)
  end

  def collect(event)
    (@collected ||= {})[event] ||= [].tap do |log|
      world.bus.subscribe(event) { |e| log << e }
    end
  end

  # Quiet-room staging: crew dead, allies parked far west, possessed at
  # arm's length from Varekka's post [43,15]. Deliberately does NOT tick
  # after the teleport — the chant triggers on the test's OWN first drive,
  # after its event subscriptions are in place.
  def face_varekka!(dist: 3)
    descend!
    clear_crew!
    (world.pack.living - [world.possessed]).each_with_index { |m, i| m.walker.teleport(2, 2 + i) }
    world.possessed.walker.teleport(43 - dist, 15)
  end

  def seize_possessed!
    face_varekka!(dist: 3)
    seized = collect(:vessel_seized)
    drive(world, scripted({}), SEIZE[:chant_frames] + 3)
    assert_equal 1, seized.length, "the chant completed into a seizure"
    assert_equal varekka, world.possessed.seized_by
  end

  # --- chant ---------------------------------------------------------------

  def test_chant_starts_in_range_and_he_stands_still
    face_varekka!(dist: 5)
    started = collect(:challenger_chant_started)
    drive(world, scripted({}), 3)
    assert_equal 1, started.length
    assert varekka.chanting?
    post = varekka.tile
    drive(world, scripted({}), 30)
    assert_equal post, varekka.tile, "pronunciation is stillness"
  end

  # The renderer's tell derives elapsed from chant_left (pilot-found crash:
  # the reader was missing while the ivar existed — NoMethodError the first
  # time a chant entered the camera).
  def test_chant_left_is_readable_and_counts_down
    face_varekka!(dist: 5)
    drive(world, scripted({}), 3)
    assert varekka.chanting?
    before = varekka.chant_left
    assert_operator before, :>, 0
    drive(world, scripted({}), 10)
    assert_operator varekka.chant_left, :<, before
  end

  def test_chant_does_not_start_out_of_range
    face_varekka!(dist: SEIZE[:range_tiles] + 3)
    started = collect(:challenger_chant_started)
    drive(world, scripted({}), 10)
    assert_empty started
  end

  def test_engagement_stamps_once
    face_varekka!(dist: 5)
    engaged = collect(:challenger_engaged)
    drive(world, scripted({}), 30)
    assert_equal 1, engaged.length
    drive(world, scripted({}), 60)
    assert_equal 1, engaged.length, "BOSS 1 SPAWNED fires once per session"
  end

  def test_damage_interrupts_the_chant_and_buys_the_cooldown
    face_varekka!(dist: 1)
    interrupted = collect(:chant_interrupted)
    seized = collect(:vessel_seized)
    drive(world, scripted({}), 3)
    assert varekka.chanting?
    # Real verb: the possessed (goret, arc3) swings into his tile.
    src = world.possessed
    src.face([1, 0])
    input = scripted((world.frame..world.frame + 40).to_h { |f| [f, [:attack]] })
    drive(world, input, 40)
    assert_equal 1, interrupted.length, "any damage cancels the sentence"
    refute varekka.chanting?
    assert varekka.seize_cooldown.positive?, "interrupting buys the room ten seconds"
    drive(world, scripted({}), SEIZE[:chant_frames])
    assert_empty seized, "no seizure lands off an interrupted chant"
  end

  def test_chant_pins_the_body_at_start_not_the_echo
    face_varekka!(dist: 3)
    drive(world, scripted({}), 3)
    pinned = world.possessed
    assert varekka.chanting?
    # Swap the echo out mid-chant: the sentence still names the BODY.
    input = scripted({ world.frame => [:swap] })
    drive(world, input, 2)
    refute world.possessed.equal?(pinned), "the echo moved"
    # Park the abandoned body OUT of his aggro — as a free ally it would
    # otherwise attack him and interrupt the chant (staging, not design;
    # completion needs no range: the seizure survives distance).
    pinned.walker.teleport(30, 15)
    drive(world, scripted({}), SEIZE[:chant_frames])
    assert_equal varekka, pinned.seized_by, "the pinned FLESH answers, not the echo"
    assert_nil world.possessed.seized_by
  end

  # --- seizure -------------------------------------------------------------

  def test_seizure_walks_the_possessed_to_him_and_suppresses_movement
    seize_possessed!
    body = world.possessed
    # Hold LEFT (away from him) the whole time: the feet are his. He also
    # closes in himself (engage AI) — the design claim is ADJACENCY: the
    # named flesh ends at the voice, held input notwithstanding.
    input = scripted((world.frame..world.frame + 120).to_h { |f| [f, [:left]] })
    drive(world, input, 120)
    dist = [(body.tile[0] - varekka.tile[0]).abs, (body.tile[1] - varekka.tile[1]).abs].max
    assert dist <= 1, "the body stands AT him against held input (got dist #{dist})"
    assert_equal varekka, body.seized_by, "still held (450f duration)"
  end

  def test_seizure_suppresses_dodge_but_not_attack
    seize_possessed!
    dodged = collect(:dodged)
    attacks = collect(:attack_started)
    input = scripted({ world.frame => [:dodge], world.frame + 10 => [:attack] })
    drive(world, input, 20)
    assert_empty dodged, "dodge is a movement verb — his"
    refute_empty attacks, "the hands are yours"
  end

  def test_swap_escapes_even_staggered
    seize_possessed!
    body = world.possessed
    body.stagger!(30)
    input = scripted({ world.frame => [:swap] })
    drive(world, input, 2)
    refute world.possessed.equal?(body),
           "Tab ALWAYS works while seized — stagger cannot trap the echo (fairness ladder)"
    assert_equal varekka, body.seized_by, "the abandoned flesh still answers the name"
  end

  def test_stagger_still_blocks_swap_when_not_seized
    descend!
    clear_crew!
    body = world.possessed
    body.stagger!(30)
    input = scripted({ world.frame => [:swap] })
    drive(world, input, 2)
    assert world.possessed.equal?(body), "law 2 unchanged outside seizure"
  end

  def test_seizure_expires_and_survives_distance
    face_varekka!(dist: 3)
    # The parked allies would trail the seized possessed toward Varekka
    # and kill him (:slain beats :expired) — this test wants the clock,
    # so the pack walks alone (human-side kills: no possessed hitstop).
    (world.pack.living - [world.possessed]).each do |m|
      m.take_hit(damage: 9_999, attacker: varekka)
    end
    seized = collect(:vessel_seized)
    ended = collect(:seizure_ended)
    drive(world, scripted({}), SEIZE[:chant_frames] + 3)
    assert_equal 1, seized.length
    # He calls from ACROSS the map: seizure survives distance by design —
    # and far away his melee can't kill the walking body, so expiry runs.
    varekka.walker.teleport(2, 17)
    drive(world, scripted({}), SEIZE[:duration_frames] + 5)
    assert_equal 1, ended.length
    assert_equal :expired, ended.first[:why]
    assert_nil world.possessed.seized_by
    # The drive's slack ticks keep decrementing after the end fires —
    # assert the cooldown STARTED at seizure end (pacing fold), not that
    # time stopped.
    assert_operator varekka.seize_cooldown, :>,
                    SEIZE[:cooldown_frames] - 30,
                    "the cooldown starts at seizure END (pacing fold)"
  end

  def test_his_death_ends_the_seizure
    seize_possessed!
    ended = collect(:seizure_ended)
    varekka.take_hit(damage: 9_999, attacker: world.possessed)
    drive(world, scripted({}), 2)
    assert_equal 1, ended.length
    assert_equal :slain, ended.first[:why]
  end

  def test_seized_body_death_ends_exactly_once_even_through_the_wipe
    seize_possessed!
    ended = collect(:seizure_ended)
    body = world.possessed
    # Kill the seized possessed AND the parked allies in one frame: the
    # death path ends the seizure (why=:died) and the wipe sweep that
    # follows in the same flush finds no state (exactly-once law).
    world.pack.living.each { |m| m.take_hit(damage: 9_999, attacker: varekka) }
    drive(world, scripted({}), 2)
    assert_equal 1, ended.length, "exactly one seizure_ended through death+wipe"
    assert_equal :died, ended.first[:why]
    refute body.seize_active?
  end

  def test_zone_exit_clears_the_seizure
    face_varekka!(dist: 3)
    drive(world, scripted({}), SEIZE[:chant_frames] + 3)
    pinned = world.possessed
    assert_equal varekka, pinned.seized_by
    ended = collect(:seizure_ended)
    # Swap the echo out and walk the free body up the stair: the whole
    # pack teleports through the gate — no dangling cross-zone seizure.
    input = scripted({ world.frame => [:swap] })
    drive(world, input, 2)
    world.possessed.walker.teleport(1, 4)
    drive(world, scripted({}), 3)
    assert_equal "slow_door", world.zone_name
    assert_equal 1, ended.length
    assert_equal :zone_left, ended.first[:why]
    refute pinned.seize_active?
  end

  def test_he_never_respawns
    descend!
    clear_crew!
    varekka.take_hit(damage: 9_999, attacker: world.possessed)
    drive(world, scripted({}), 2)
    assert_nil varekka, "one man, one death"
    drive(world, scripted({}), 500)
    assert_nil varekka, "no respawn record was ever scheduled"
  end
end
