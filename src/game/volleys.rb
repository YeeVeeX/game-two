module Game
  # T4 carve (world.rb line-cap law, extract-on-touch): the volley
  # subsystem as a plain object — delayed-impact records, launch
  # geometry, the delay tick + hit resolution, and the digest fold.
  # Explicit call order, no bus, no IO (Crossing/FieldEconomy pattern):
  # World resolves damage and distances BEFORE launch (Volleys receives
  # values, never kit configs or progression), and hit resolution
  # reaches back through injected callables — hostiles(owner) → foes,
  # blocked(victim) → blocking tiles, hit_sink(attacker, victim,
  # landed) → World's attack_hit emit.
  #
  # Record shape (owner/tiles/frames_left/damage, LIVE owner reference)
  # is FROZEN API: renderer.rb reads owner.kit[:special][:delay_frames]
  # off the record, net/state_digest pins the impact.<i> group rows,
  # and a volley must survive its caster's death (world_test law).
  class Volleys
    attr_reader :records

    def initialize(hostiles:, blocked:, hit_sink:)
      @hostiles = hostiles
      @blocked = blocked
      @hit_sink = hit_sink
      @records = []
    end

    # Launch-time resolution law: the record stores RESOLVED damage and
    # tiles — a later level or zone change never rewrites a falling volley.
    def launch(owner:, map:, origin:, dir:, distances:, delay_frames:, damage:)
      @records << { owner:, tiles: tiles_for(map, origin, dir, distances),
                    frames_left: delay_frames, damage: }
    end

    # Pure geometry: march the facing one tile at a time, stop at the
    # first impassable tile (a wall honestly shortens the chain), keep
    # the tiles whose distance the kit names. Tile order is fixed and
    # order-insensitive to the distances array (max + include?).
    def tiles_for(map, origin, dir, distances)
      tiles = []
      tx, ty = origin
      1.upto(distances.max) do |distance|
        tx += dir[0]
        ty += dir[1]
        break unless map.passable?(tx, ty)
        tiles << [tx, ty] if distances.include?(distance)
      end
      tiles
    end

    # Creation order and tile order are fixed (determinism). Called only
    # from tick_world — the hitstop pause law rides that call site.
    def tick!
      @records.each do |impact|
        impact[:frames_left] -= 1
        next if impact[:frames_left].positive?
        foes = @hostiles.call(impact[:owner])
        impact[:tiles].each do |tile|
          victim = foes.find { |foe| !foe.dead? && foe.tile == tile }
          next unless victim
          landed = victim.take_hit(damage: impact[:damage], attacker: impact[:owner],
                                   knockback_tiles: 0, blocked: @blocked.call(victim))
          @hit_sink.call(impact[:owner], victim, landed)
        end
      end
      @records.reject! { |impact| impact[:frames_left] <= 0 }
    end

    # Zone entry / wipe re-entry (Transients precedent): live volleys
    # die with the zone.
    def clear!
      @records.clear
    end

    # The netplay digest fold (FieldEconomy digest_groups precedent):
    # same impact.<i> group names, same rows, same order as the World
    # fold it replaces — byte-identical by construction.
    def digest_groups
      @records.each_with_index.map do |imp, i|
        ["impact.#{i}", [
          ["owner", imp[:owner].name],
          ["tiles", imp[:tiles].map { |t| t.join(",") }.join("|")],
          ["frames_left", imp[:frames_left]], ["damage", imp[:damage]]
        ]]
      end
    end
  end
end
