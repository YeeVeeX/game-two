require "game/flow_field"

module Game
  # Drives the possessed creature from live/scripted input. Post-swap inputs
  # are edge-triggered (law 2): every action held at rearm! time is masked
  # until it is released once — a buffered attack can't ghost-fire from the
  # new body, and a held dodge can't burn the new body's cooldown.
  class PossessedController
    ACTIONS = %i[left right up down attack dodge].freeze

    def initialize
      @masked = []
    end

    def rearm!(input)
      @masked = ACTIONS.select { |a| input.down?(a) }
    end

    def tick(creature, input, _view)
      @masked.reject! { |a| !input.down?(a) }
      return if creature.dead?

      dir = held_direction(input)
      creature.face(dir)
      if down?(input, :dodge)
        creature.dodge(dir, blocked: @blocked || [])
      elsif dir != [0, 0]
        creature.step(dir[0], dir[1], blocked: @blocked || [])
      end
      creature.start_attack if down?(input, :attack)
    end

    # World supplies body-blocking per frame (it knows all occupied tiles).
    # NB: plain def — Ruby forbids endless method definitions for setters.
    def blocked=(tiles)
      @blocked = tiles
    end

    private

    def down?(input, action) = input.down?(action) && !@masked.include?(action)

    def held_direction(input)
      dx = (down?(input, :right) ? 1 : 0) - (down?(input, :left) ? 1 : 0)
      dy = (down?(input, :down) ? 1 : 0) - (down?(input, :up) ? 1 : 0)
      [dx, dy]
    end
  end

  # Husk-grade brain (deliberately dumb — gambits are A1): aggro on the
  # nearest hostile, chase downhill on a flow field anchored on the target,
  # swing when the target is in kit range. Allies additionally follow the
  # possessed when nothing is in aggro range, so they never get left behind.
  class AiController
    FOLLOW_DISTANCE = 2

    def tick(creature, view)
      return if creature.dead?

      target = nearest(creature, view.hostiles_for(creature))
      if target && chebyshev(creature.tile, target.tile) <= creature.kit[:aggro_tiles]
        engage(creature, target, view)
      elsif creature.faction == :pack && !view.possessed.equal?(creature)
        follow(creature, view.possessed, view)
      end
    end

    private

    def engage(creature, target, view)
      dist = chebyshev(creature.tile, target.tile)
      if in_attack_range?(creature, dist)
        face_toward(creature, target)
        creature.start_attack
      elsif !creature.moving?
        chase_step(creature, target, view)
      end
    end

    def in_attack_range?(creature, dist)
      dist <= 1 # M1: both kits are melee (arc3 reaches Chebyshev-adjacent via facing)
    end

    def follow(creature, possessed, view)
      return if creature.moving?
      if creature.tile == front_tile(possessed)
        yield_aside(creature, view) # never body-block your own possessed
      elsif chebyshev(creature.tile, possessed.tile) > FOLLOW_DISTANCE
        chase_step(creature, possessed, view)
      end
    end

    def front_tile(possessed)
      [possessed.tile[0] + possessed.facing[0], possessed.tile[1] + possessed.facing[1]]
    end

    # Step to the first available neighbor (fixed STEPS order = deterministic).
    # Follow logic pulls the ally back into formation afterward.
    def yield_aside(creature, view)
      blocked = view.blocked_for(creature)
      Game::FlowField::STEPS.each do |(dx, dy)|
        break if creature.step(dx, dy, blocked:)
      end
    end

    def chase_step(creature, target, view)
      return if creature.moving?
      blocked = view.blocked_for(creature)
      dir = view.flow_to(target).downhill_from(*creature.tile, blocked:)
      return unless dir
      creature.face(dir)
      creature.step(dir[0], dir[1], blocked:)
    end

    def face_toward(creature, target)
      dx = (target.tile[0] - creature.tile[0]).clamp(-1, 1)
      dy = (target.tile[1] - creature.tile[1]).clamp(-1, 1)
      creature.face([dx, dy])
    end

    def nearest(creature, hostiles)
      hostiles.min_by.with_index { |h, i| [chebyshev(creature.tile, h.tile), i] }
    end

    def chebyshev((ax, ay), (bx, by)) = [(bx - ax).abs, (by - ay).abs].max
  end
end
