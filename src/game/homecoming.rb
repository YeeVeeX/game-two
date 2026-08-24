require "game/flow_field"

module Game
  # J7-A extraction (the world.rb line-cap law, extract-on-touch): the
  # go-home POLICY — where a leashing human is actually headed (v13
  # guard-scope shift), the cached flow field that walks it there, the
  # emit-once leash decision, and the J7-B cold catch-up (where a frozen
  # zone's displaced humans stand after an absence). Plain object,
  # Crossing pattern: World stays the only mutator — the :human_leashed
  # payload is RETURNED by leash_emission, World emits it; catch-up
  # placements are RETURNED as a map, World rebinds.
  class Homecoming
    # map / corpse_loads are LIVE readers (the PriceSheet callable
    # pattern) — the current zone and the newest corpse load move
    # mid-session. threat: config hash (balance/threat), read-only.
    def initialize(map:, corpse_loads:, threat:)
      @map = map
      @corpse_loads = corpse_loads
      @threat = threat
      @home_fields = {}
    end

    # Home fields are keyed by TILE and never invalidated inside a zone —
    # homes don't move. Cleared with the flow cache on zone change (World
    # calls clear!). Keyed by the EFFECTIVE home (v13 guard-scope), so
    # shifted and true anchors coexist deterministically.
    def flow_home(creature)
      field_for(leash_home_tile(creature))
    end

    # J7-B (D4): the cold catch-up — where each displaced living human
    # stands after `elapsed` frozen ticks: linger first (leash_linger_frames,
    # spent once per absence), then walk toward home at the kit's own step
    # cadence (integer division — partial steps don't move you) along the
    # static flow-home field, walls-only blocked, clamped at home. The walk
    # aims at the PLAIN home tile — corpse-guard shifts mid-absence are not
    # reconstructed (fake precision; the live leash re-reads them). Roster
    # order; a tile taken by an earlier placement holds one step short
    # (repeating while contested — deterministic, ZERO rng). The taken set
    # covers catch-up placements ONLY: a placement may legally share a
    # tile with an at-home human or a pack body (soft collision — the
    # same overlap today's snap-home tolerates at contested home tiles).
    # Returns {human => tile}; every displaced living human gets an entry.
    def catchup_placements(humans, elapsed:)
      walk_ticks = [elapsed - @threat[:leash_linger_frames], 0].max
      taken = []
      humans.each_with_object({}) do |h, placed|
        next if h.dead? || h.tile == h.home_tile
        path = home_path(h, walk_ticks / h.kit[:step_frames])
        idx = path.length - 1
        idx -= 1 while idx.positive? && taken.include?(path[idx])
        taken << path[idx]
        placed[h] = path[idx]
      end
    end

    def clear!
      @home_fields = {}
    end

    # v13 guard-scope (fairness only, spec §4): a leashing wanderer whose
    # home sits inside the corpse guard of the NEWEST live corpse load
    # re-homes to the nearest walkable tile outside the radius along the
    # away ray — live humans cannot camp the corpse run. Engaged humans
    # never read this (leash runs no-focus only); same anchor source as
    # the respawn guard (corpse_loads, not visual corpses).
    def leash_home_tile(creature)
      home = creature.home_tile
      load = @corpse_loads.call.last
      return home unless load
      guard = @threat[:density][:corpse_guard_tiles]
      return home if tile_distance(load[:tile], home) > guard
      shifted_home(home, load[:tile], guard)
    end

    # One :human_leashed per episode: the flag arms on emit, disarms when the
    # human regains a focus (reset_leash! call sites) — track via leash_frames
    # equality: the payload is RETURNED exactly when the counter crosses the
    # linger threshold, nil otherwise (World emits — policy decides, World
    # mutates). steered (v13): this episode's destination was guard-shifted.
    def leash_emission(creature)
      return nil unless creature.leash_frames == @threat[:leash_linger_frames]
      { actor: creature, tile: creature.tile, hp: creature.hp,
        steered: leash_home_tile(creature) != creature.home_tile }
    end

    private

    def map = @map.call

    # Home fields cache, keyed by anchor TILE (flow_home's shifted and
    # true anchors coexist; the catch-up shares the true-home entries).
    def field_for(anchor)
      @home_fields[anchor] ||= FlowField.new(map).tap { |f| f.recompute!(anchor) }
    end

    # The walked prefix of a catch-up path: frozen tile + up to `tiles`
    # field steps toward home (index 0 = stay put). downhill_from returns
    # nil at home (nothing improves), so the clamp is structural.
    def home_path(creature, tiles)
      field = field_for(creature.home_tile)
      path = [creature.tile]
      tiles.times do
        dir = field.downhill_from(*path.last, blocked: [])
        break unless dir
        path << [path.last[0] + dir[0], path.last[1] + dir[1]]
      end
      path
    end

    # Walk the away ray (load->home direction, knock_away_from idiom) until
    # outside the guard AND walkable; a ray into walls/map edge falls back
    # to the ring scan; last resort is the true home — fairness is
    # best-effort, a stuck human would be worse than a camping one.
    def shifted_home(home, from, guard)
      dx = (home[0] - from[0]).clamp(-1, 1)
      dy = (home[1] - from[1]).clamp(-1, 1)
      dx = 1 if dx.zero? && dy.zero?
      (1..guard * 2).each do |k|
        cand = [home[0] + dx * k, home[1] + dy * k]
        next unless map.passable?(cand[0], cand[1])
        return cand if tile_distance(from, cand) > guard
      end
      ring_home(home, from, guard) || home
    end

    # Nearest-to-home walkable tile on the ring just outside the guard;
    # fixed sort key = deterministic.
    def ring_home(home, from, guard)
      r = guard + 1
      candidates = []
      (-r..r).each do |ox|
        (-r..r).each do |oy|
          next unless [ox.abs, oy.abs].max == r
          cand = [from[0] + ox, from[1] + oy]
          candidates << cand if map.passable?(cand[0], cand[1])
        end
      end
      candidates.min_by { |c| [tile_distance(home, c), c[0], c[1]] }
    end

    # Chebyshev (World#tile_distance; own copy per the Crossing group_wait
    # precedent — policy objects never call back into World).
    def tile_distance((ax, ay), (bx, by))
      [(bx - ax).abs, (by - ay).abs].max
    end
  end
end
