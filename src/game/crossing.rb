require "game/flow_field"

module Game
  # T4 extraction (the world.rb line-cap law, extract-on-touch): the
  # zone-crossing POLICY — which ways are open, when the gate group
  # consents, where the pack lands. Plain object, explicit call order,
  # no bus mediation. World stays the only mutator: nothing here touches
  # sim state (the waiting cue is RETURNED, written by the caller).
  class Crossing
    # zones: {name => TileMap}. breached / defeats / living are LIVE
    # readers (the PriceSheet callable pattern) — breach state and the
    # boss counter move mid-session.
    def initialize(zones:, breached:, defeats:, living:)
      @zones = zones
      @breached = breached
      @defeats = defeats
      @living = living
    end

    # v12 seal law + T4 boss fact-gate (spec §THE GATE): a way is shut
    # while its toll is unpaid OR its required boss_1_defeats count is
    # unmet — a breach-variant reading a persisted fact instead of a
    # price. Both READ persisted state; neither spends here.
    def open?(zone_name, t)
      return false if t[:sealed] && !@breached.call(zone_name, t[:at])
      return false if t[:requires_defeats] && @defeats.call < t[:requires_defeats]
      true
    end

    # v17 decision 11 (co-location consent), ONE law for gates and ropes:
    # the crossing fires only with every living controlled body in the
    # gate group — the trigger ON the tile, every other seat's living
    # body within Chebyshev 1. Dead/waiting seats don't block.
    # nil = consent holds; else the WAITING AT GATE cue tile.
    def group_wait(bodies, trigger, t)
      others = bodies.reject { |b| b.equal?(trigger) || b.dead? }
      ok = others.all? do |b|
        [(b.tile[0] - t[:at][0]).abs, (b.tile[1] - t[:at][1]).abs].max <= 1
      end
      ok ? nil : t[:at]
    end

    # The whole pack moves through a gate: possessed lands on the gate
    # spawn, allies on the nearest passable neighbors (deterministic
    # STEPS order).
    def arrival_tiles(zone, spawn)
      zmap = @zones.fetch(zone)
      tiles = [spawn]
      FlowField::STEPS.each do |(dx, dy)|
        break if tiles.length >= @living.call
        cand = [spawn[0] + dx, spawn[1] + dy]
        tiles << cand if zmap.passable?(*cand) && !tiles.include?(cand)
      end
      tiles
    end
  end
end
