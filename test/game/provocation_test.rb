require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"

# C2 — ally defensive-default engage rule (v19 foundation Lane 3 row 13,
# RATIFIED-G + RATIFIED-J 2026-08-22; decision doc
# drafts/_c2-defensive-default-20260826.md) against the REAL World, no
# mocks. Free pack bodies acquire PROVOKED humans only — what attacked
# the pack or what the possessed engaged — while taunt/anchor binds and
# the mark bypass, and the follow branch answers everything else.
# Provocation is body-scoped (the beachhead-waiver precedent): stamped
# at take_hit (every damage arc funnels there), taunt!, chant-start and
# seize!; cleared at leash-past-linger and zone re-entry; an echo
# respawns as a NEW body, unprovoked by construction. The rule is
# seat-INDEPENDENT (faction AI law); only the flee threshold stays
# coop-gated (v18 decision 12, untouched).
class ProvocationTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  KITS = DATA["balance/combat"][:kits]
  THREAT = DATA["balance/threat"]

  def world(seats: 1, seed: 7) = Game::World.new(DATA, seed:, seats:)
  def idle = @idle ||= Core::ScriptedInput.new(frames: {})

  def inputs_for(w) = w.seats.length == 2 ? { 1 => idle, 2 => idle } : idle

  def drive(w, n)
    n.times { w.tick(inputs_for(w)) }
  end

  def drive_until(w, cap, what)
    cap.times do
      return if yield
      w.tick(inputs_for(w))
    end
    flunk "staging: #{what} not reached within #{cap} ticks"
  end

  def free_ally(w)
    w.pack.members.find { |m| !w.controlled?(m) && m.kit_name == :lobber } ||
      w.pack.members.find { |m| !w.controlled?(m) }
  end

  def chebyshev(a, b) = [(a[0] - b[0]).abs, (a[1] - b[1]).abs].max

  # The coop_feel flee-stage shape at FULL hp: lobber free ally aligned at
  # dist 2 with a clear line — under the old offensive default this opens
  # a swing THIS tick; controlled bodies parked far west.
  def stage(seats: 1)
    w = world(seats:)
    w.start_in("district")
    ally = free_ally(w)
    hostile = w.humans.reject(&:dead?).min_by { |h| h.name }
    ally.walker.teleport(hostile.tile[0] + 2, hostile.tile[1])
    w.controlled_bodies.each_with_index { |b, i| b.walker.teleport(1, 12 + i) }
    [w, ally, hostile]
  end

  # --- the core refusal (the R3 complaint's mechanism) ---------------------

  def test_unprovoked_hostile_in_range_starts_no_swing_ally_follows_home
    w, ally, hostile = stage
    anchor = w.controlled_bodies.first
    before = chebyshev(ally.tile, anchor.tile)
    drive(w, KITS[:lobber][:step_frames] + 2)
    assert_equal :idle, ally.attack_state,
                 "defensive default: an unprovoked human in range draws NO swing"
    refute hostile.pack_provoked?
    assert_operator chebyshev(ally.tile, anchor.tile), :<, before,
                    "nothing to engage -> the follow branch walks the ally back"
  end

  def test_seats2_parity_the_rule_is_seat_independent
    w, ally, = stage(seats: 2)
    drive(w, 2)
    assert_equal :idle, ally.attack_state,
                 "the engage rule is faction AI law — no seat gate"
  end

  # --- provocation: what attacks the pack ----------------------------------

  def test_human_striking_a_pack_body_provokes_and_the_ally_answers
    w, ally, hostile = stage
    ally.take_hit(damage: 1, attacker: hostile)
    assert hostile.pack_provoked?, "a connected human hit stamps the attacker"
    drive_until(w, 4, "ally answer") { ally.attack_state != :idle }
    refute_equal :idle, ally.attack_state
  end

  def test_pack_wide_defense_a_hit_on_the_possessed_frees_every_ally
    w, ally, hostile = stage
    w.possessed.take_hit(damage: 1, attacker: hostile)
    assert hostile.pack_provoked?
    drive_until(w, 4, "ally answer") { ally.attack_state != :idle }
  end

  # --- provocation: what the possessed engages ------------------------------

  def test_pack_striking_a_human_provokes_it_for_the_whole_pack
    w, ally, hostile = stage
    hostile.take_hit(damage: 1, attacker: w.possessed)
    assert hostile.pack_provoked?, "the pack picked this fight"
    drive_until(w, 4, "ally answer") { ally.attack_state != :idle }
  end

  def test_taunt_pulse_provokes_its_victims
    w, _ally, hostile = stage
    blocker = w.pack.members.find { |m| m.kit_name == :blocker }
    hostile.taunt!(blocker, 10)
    assert hostile.pack_provoked?, "a possessed challenge is an engage order"
  end

  # --- selectivity: provoked beats nearer-unprovoked -------------------------

  def test_ally_picks_the_provoked_human_over_a_nearer_unprovoked_one
    w = world
    w.start_in("district")
    ally = free_ally(w)
    humans = w.humans.reject(&:dead?).sort_by(&:name)
    near, far = humans[0], humans[1]
    refute_nil far, "district must stage at least two humans"
    ally.walker.teleport(10, 10)
    near.walker.teleport(12, 10) # dist 2, unprovoked
    far.walker.teleport(6, 10)   # dist 4, provoked
    far.provoke!
    w.controlled_bodies.each_with_index { |b, i| b.walker.teleport(1, 12 + i) }
    before = chebyshev(ally.tile, far.tile)
    drive(w, KITS[:lobber][:step_frames] + 2)
    assert ally.attack_state != :idle || chebyshev(ally.tile, far.tile) < before,
           "the ally answers the provoked human (fires or closes), never the near bystander"
    refute near.pack_provoked?
  end

  # --- the challenger: chant-start is the aggression -------------------------

  def test_chant_start_provokes_the_challenger
    w = world
    w.start_in("low_quay")
    boss = w.humans.find { |h| h.kit_name == :challenger }
    refute_nil boss
    refute boss.pack_provoked?, "spawns unprovoked"
    boss.walker.teleport(w.possessed.tile[0] + 2, w.possessed.tile[1])
    started = false
    w.bus.subscribe(:challenger_chant_started) { started = true }
    drive_until(w, 600, "chant start") { started }
    assert boss.pack_provoked?,
           "free allies may help interrupt — the counterplay is not possessed-only"
  end

  # --- forgiveness: leash and zone re-entry ----------------------------------

  def test_leash_past_linger_clears_provocation
    w = world
    w.start_in("district")
    h = w.humans.reject(&:dead?).min_by { |x| x.name }
    h.provoke!
    # Pack parked across the arena: nothing in the human's aggro, no focus —
    # pre-set the linger so leash_home runs on the very next tick.
    w.pack.members.each_with_index { |b, i| b.walker.teleport(1, 12 + i) }
    h.walker.teleport(16, 12)
    h.resume_leash!(THREAT[:leash_linger_frames])
    drive(w, 2)
    refute h.pack_provoked?,
           "a human that disengaged and walks home is forgiven"
  end

  def test_zone_reentry_clears_provocation
    w = world
    w.start_in("district")
    h = w.humans.reject(&:dead?).min_by { |x| x.name }
    h.provoke!
    # v2b: start-in-district lands at the SW mouth; stage beside the west
    # nest door so the round trip is a short straight walk.
    w.possessed.walker.teleport(2, 13)
    (w.pack.members - [w.possessed]).each_with_index { |b, i| b.walker.teleport(2, 12 + 2 * i) }
    walk_until(w, "left", "back in nest") { w.zone_name == "nest" }
    walk_until(w, "right", "district re-entry") { w.zone_name == "district" }
    refute h.pack_provoked?, "re-entry is a fresh slate (the focus=nil law)"
  end

  def walk_until(w, dir, what)
    input = Core::ScriptedInput.new(frames: (0..12_000).to_h { |f| [f.to_s, [dir]] })
    5000.times do
      return if yield
      input.update(w.frame)
      w.tick(input)
    end
    flunk "staging: #{what} not reached within 5000 ticks"
  end

  def test_respawned_echo_returns_unprovoked
    w = world
    w.start_in("district")
    victim = w.humans.reject(&:dead?).find { |h| h.kit_name == :rusher }
    victim.provoke!
    names_before = w.humans.map(&:name)
    victim.take_hit(damage: victim.hp, attacker: w.possessed) until victim.dead?
    # Park the pack away from spawn anchors so placement never defers.
    w.pack.members.each_with_index { |b, i| b.walker.teleport(40, 1 + i) }
    echo = nil
    drive_until(w, KITS[:rusher][:respawn_frames] + 900, "echo respawn") do
      echo = w.humans.find { |h| !names_before.include?(h.name) }
      !echo.nil?
    end
    refute echo.pack_provoked?, "a NEW body carries no grudge (add_human builds fresh)"
  end

  # --- digest membership (W1: sim state must be desync-visible) --------------

  def test_provocation_is_digest_visible
    w, _ally, hostile = stage
    fields = hostile.digest_fields.to_h
    assert_equal false, fields["pack_provoked"]
    hostile.provoke!
    assert_equal true, hostile.digest_fields.to_h["pack_provoked"]
  end
end
