require "game/flow_field"

module Game
  # Drives the possessed creature from live/scripted input. Post-swap COMBAT
  # inputs are edge-triggered (law 2): attack/dodge held at rearm! time are
  # masked until released once — a buffered attack can't ghost-fire from the
  # new body, and a held dodge can't burn the new body's cooldown. Held
  # MOVEMENT deliberately survives the swap: walking into the new body is
  # what the hand expects; masking it made every Tab a micro-stall (M2.1
  # fix 3).
  class PossessedController
    ACTIONS = %i[left right up down attack dodge].freeze
    EDGE_TRIGGERED = %i[attack dodge].freeze

    def initialize
      @masked = []
    end

    def rearm!(input)
      @masked = EDGE_TRIGGERED.select { |a| input.down?(a) }
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
      if in_attack_range?(creature, target, view)
        face_toward(creature, target)
        creature.start_attack
      elsif !creature.moving?
        chase_step(creature, target, view)
      end
    end

    # Melee kits: Chebyshev adjacency. Projectile kits: 8-way aligned with a
    # wall-clear line inside range (fires down rows/columns/diagonals only —
    # grid-faithful, and the shot itself flies that same lane).
    def in_attack_range?(creature, target, view)
      atk = creature.kit[:attack]
      dist = chebyshev(creature.tile, target.tile)
      return dist <= 1 unless atk[:arc] == "projectile"

      dx = target.tile[0] - creature.tile[0]
      dy = target.tile[1] - creature.tile[1]
      aligned = dx.zero? || dy.zero? || dx.abs == dy.abs
      aligned && dist <= atk[:range_tiles] && dist >= 2 &&
        view.line_clear?(creature.tile, target.tile)
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

    # Approach the claimed SURROUND SLOT, not the target's own tile — a group
    # fans into a pincer instead of queuing single-file. Greedy diagonal-first
    # step toward the slot; the target's flow field is the fallback when the
    # greedy step is refused (walls, bodies).
    def chase_step(creature, target, view)
      return if creature.moving?
      blocked = view.blocked_for(creature)
      slot = view.respond_to?(:surround_slot) ? view.surround_slot(creature, target) : nil
      if slot && slot != creature.tile
        dx = (slot[0] - creature.tile[0]).clamp(-1, 1)
        dy = (slot[1] - creature.tile[1]).clamp(-1, 1)
        if creature.step(dx, dy, blocked:)
          creature.face([dx, dy])
          return
        end
      end
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
