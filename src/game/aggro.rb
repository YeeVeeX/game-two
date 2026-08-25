require "game/creature"

module Game
  # B1-T1 extraction (the world.rb line-cap law, extract-on-touch:
  # Crossing/PriceSheet/Homecoming/TierSheet precedent): the per-tick
  # threat brain — hostile focus ACQUISITION (including the B1 safe-zone
  # refusal), the engaged/pressuring partition, surround/pressure ring
  # claims, density pockets, beachhead shielding. Plain object; the
  # per-tick claim state that lived on World ivars lives here and resets
  # at the same tick_world call site (reset!). World keeps one-line view
  # delegates so the AiController duck-type, the renderer, telemetry,
  # and every test read the exact surface they always did.
  class Aggro
    # humans / map / arrivals are LIVE readers (the PriceSheet callable
    # pattern) — the active zone moves mid-session. threat/economy:
    # config hashes, read-only. ai: the shared AiController (stateless
    # rules). bus: :human_retargeted emission (FieldEconomy precedent —
    # the emit is the decision's own act; World stays the sim mutator).
    def initialize(humans:, map:, arrivals:, threat:, economy:, bus:, ai:)
      @humans = humans
      @map = map
      @arrivals = arrivals
      @threat = threat
      @economy = economy
      @bus = bus
      @ai = ai
      reset!
    end

    # Claims are rebuilt every tick (tick_world calls this where the old
    # @slot_claims/@pressure_claims resets sat) — never digest state.
    def reset!
      @slot_claims = {}
      @pressure_claims = {}
    end

    # The one write site for hostile focus. B1 safe-zone law (v19
    # foundation row 6, RATIFIED-G + RATIFIED-J 2026-08-22): while the
    # ACTIVE zone declares safe, acquisition is refused wholesale —
    # select_target never runs and any live focus drops to nil. The nil
    # write emits nothing (the retarget emit fires on a live target
    # only), so a hostile placed in a safe zone never pursues and never
    # damages, yet still leash-walks home if displaced (dispersed, not
    # invulnerable — no frozen-AI artifact).
    def assign_focus!(view)
      if @map.call.safe
        @humans.call.each { |h| h.focus = nil unless h.dead? }
        return
      end
      @humans.call.each do |h|
        next if h.dead?
        target, cause = @ai.select_target(h, view)
        if target && !target.equal?(h.focus)
          @bus.emit(:human_retargeted, actor: h, from: h.focus, to: target, cause:)
          # Cue-keyed causes only (spec section 5): taunt/anchor turns carry
          # their own tells (underline, pulse) and have no cue color — but
          # every turn invalidates a live cue, or a stale cause would explain
          # a turn it did not drive (impl review, Codex finding 2).
          if %i[hate lowhp proximity].include?(cause)
            h.retarget_cue!(cause, @economy[:retarget_cue_frames])
          else
            h.clear_retarget_cue!
          end
        end
        h.focus = target
      end
    end

    # Surround doctrine (owner directive 2026-08-09): attackers converging on
    # one target each claim a DIFFERENT adjacent tile and approach it, so a
    # group fans out into a pincer instead of a single-file queue. Claims are
    # rebuilt every tick in AI iteration order (roster order — deterministic).
    def surround_slot(attacker, target)
      claims = (@slot_claims[target] ||= {})
      already = claims.find { |_, who| who.equal?(attacker) }
      return already[0] if already
      tx, ty = target.tile
      slot = Creature::RING.map { |(dx, dy)| [tx + dx, ty + dy] }
                           .find { |t| @map.call.passable?(*t) && !claims.key?(t) }
      claims[slot] = attacker if slot
      slot
    end

    # A2 position pressure: per focus-target, the nearest engaged_cap_per_target
    # humans fight; the rest PRESSURE (follow, block, never swing). Sorting is
    # (distance, roster index) -- deterministic. Taunt-bound humans partition
    # like everyone else: taunt locks attention, not the right to swing.
    def partition_pressure!
      cap = @threat[:engaged_cap_per_target]
      @pressure_roles = {}
      @humans.call.reject(&:dead?).group_by(&:focus).each do |target, group|
        next unless target
        group.each_with_index
             .sort_by { |h, i| [tile_distance(h.tile, target.tile), i] }
             .each_with_index { |(h, _), rank| @pressure_roles[h] = rank < cap ? :engaged : :pressuring }
      end
    end

    def pressure_role(creature) = (@pressure_roles || {}).fetch(creature, :engaged)

    # Ring slots mirror surround_slot one ring further out: the Chebyshev ring at
    # pressure_ring_tiles, claimed per target per tick, fixed perimeter order.
    def pressure_slot(attacker, target)
      claims = (@pressure_claims[target] ||= {})
      already = claims.find { |_, who| who.equal?(attacker) }
      return already[0] if already
      r = @threat[:pressure_ring_tiles]
      tx, ty = target.tile
      ring = (-r..r).flat_map { |d| [[tx + d, ty - r], [tx + d, ty + r], [tx - r, ty + d], [tx + r, ty + d]] }
                    .uniq
      slot = ring.find { |t| @map.call.passable?(*t) && !claims.key?(t) }
      claims[slot] = attacker if slot
      slot
    end

    # v11 density: pockets = connected groups of living humans in the
    # current zone within join_radius_tiles of each other (chain distance,
    # Chebyshev). Public on purpose — the respawn anchor path, telemetry,
    # and tests must all read the SAME computation. Roster order in, so
    # grouping is deterministic.
    def density_pockets
      radius = @threat[:density][:join_radius_tiles]
      alive = @humans.call.reject(&:dead?)
      seen = {}
      pockets = []
      alive.each do |h|
        next if seen[h]
        group = [h]
        seen[h] = true
        queue = [h]
        until queue.empty?
          current = queue.shift
          alive.each do |other|
            next if seen[other] || tile_distance(current.tile, other.tile) > radius
            seen[other] = true
            group << other
            queue << other
          end
        end
        pockets << group
      end
      pockets
    end

    # Beachhead (A2): arrival is not an ambush. Blocks ACQUISITION only —
    # taunt/anchor bind first in the chain, and a human the pack has attacked
    # is waived for life (you don't get the doormat's protection while
    # swinging from it).
    def beachhead_shields?(human, target)
      return false if human.beachhead_waived?
      radius = @threat[:beachhead_tiles]
      @arrivals.call.any? { |a| tile_distance(target.tile, a) <= radius }
    end

    private

    # Chebyshev (World#tile_distance; own copy per the Crossing/Homecoming
    # precedent — policy objects never call back into World).
    def tile_distance((ax, ay), (bx, by))
      [(bx - ax).abs, (by - ay).abs].max
    end
  end
end
