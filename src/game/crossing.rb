require "game/flow_field"

module Game
  # T4 extraction (the world.rb line-cap law, extract-on-touch): the
  # zone-crossing POLICY — which edges are even legal (s31 load-time
  # law), which ways are open, when the gate group consents, where the
  # pack lands. Plain object, explicit call order, no bus mediation.
  # World stays the only mutator: nothing here touches sim state (the
  # waiting cue is RETURNED, written by the caller).
  class Crossing
    # s31 (T5 hardening, s30 review nit 6): every zone edge validates at
    # WORLD LOAD — the one point all consumers converge (play, netplay,
    # map, harness, soak, pilot). TileMap checks :at in isolation; the
    # destination zone and its spawn tile only exist as a PAIR once all
    # zones are built. Illegal data refuses NAMED at boot (the message
    # carries the full source/at/to/spawn tuple, grep-able) instead of a
    # crossing-time KeyError (unknown :to) or a silent in-wall placement
    # (arrival_tiles trusts spawn unconditionally). ArgumentError matches
    # World's house style for unknown-zone refusals; the malformed-spawn
    # guard exists because passable?(*nil) would raise an UNNAMED arity
    # error before the passability check could run. Returns the arrivals
    # table {to => [spawn, ...]} — the validated edges ARE the arrival
    # geometry, one pass builds both.
    def self.validated_arrivals(zones)
      arrivals = Hash.new { |h, k| h[k] = [] }
      zones.each do |zname, zmap|
        zmap.transitions.each do |t|
          edge = "zone edge #{zname} #{t[:at].inspect} -> #{t[:to]}"
          unless zones.key?(t[:to])
            raise ArgumentError, "#{edge}: unknown destination zone #{t[:to].inspect}"
          end
          spawn = t[:spawn]
          unless spawn.is_a?(Array) && spawn.length == 2 && spawn.all? { |v| v.is_a?(Integer) }
            raise ArgumentError, "#{edge}: spawn must be an [x, y] tile (got #{spawn.inspect})"
          end
          unless zones.fetch(t[:to]).passable?(*spawn)
            raise ArgumentError, "#{edge}: spawn #{spawn.inspect} impassable in #{t[:to]}"
          end
          arrivals[t[:to]] << spawn
        end
      end
      arrivals
    end
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
