require "game/flow_field"

module Game
  # Drives the possessed creature from live/scripted input. Post-swap COMBAT
  # inputs are edge-triggered (law 2): combat/command keys held at rearm!
  # time are masked until released once — buffered verbs cannot ghost-fire
  # from the new body or burn its clocks. Held
  # MOVEMENT deliberately survives the swap: walking into the new body is
  # what the hand expects; masking it made every Tab a micro-stall (M2.1
  # fix 3).
  class PossessedController
    ACTIONS = %i[left right up down attack dodge special mark interact].freeze
    EDGE_TRIGGERED = %i[attack dodge special mark interact].freeze

    def initialize
      @masked = []
      @edge_was_down = {}
    end

    def rearm!(input)
      @masked = EDGE_TRIGGERED.select { |a| input.down?(a) }
    end

    def tick(creature, input, view)
      @masked.reject! { |a| !input.down?(a) }
      dodge_pressed = pressed?(input, :dodge)
      special_pressed = pressed?(input, :special)
      mark_pressed = pressed?(input, :mark)
      interact_pressed = pressed?(input, :interact)
      return if creature.dead?

      dir = held_direction(input)
      creature.face(dir)
      if dodge_pressed
        creature.dodge(dir, blocked: @blocked || [])
      elsif dir != [0, 0]
        creature.step(dir[0], dir[1], blocked: @blocked || [])
      end
      # Interact resolves before attack/special: a same-frame pickup or bank
      # must not lose the tie to a held attack starting a swing.
      view.interact(creature) if interact_pressed && view&.respond_to?(:interact)
      creature.start_special(blocked: @blocked || []) if special_pressed
      creature.start_attack if down?(input, :attack)
      view.set_mark(creature) if mark_pressed && view&.respond_to?(:set_mark)
    end

    # World supplies body-blocking per frame (it knows all occupied tiles).
    # NB: plain def — Ruby forbids endless method definitions for setters.
    def blocked=(tiles)
      @blocked = tiles
    end

    private

    def down?(input, action) = input.down?(action) && !@masked.include?(action)

    def pressed?(input, action)
      now = down?(input, action)
      pressed = now && !@edge_was_down.fetch(action, false)
      @edge_was_down[action] = now
      pressed
    end

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

    # A2 human chain: taunt -> anchor -> kit-hate -> lowest-HP -> sticky focus
    # (proximity-margin steal) -> nearest acquisition. Stateless rules, readable
    # switches (learnability law): every cause is telemetry.
    def select_target(creature, view)
      bound = creature.taunted_target
      return [bound, creature.taunt_cause || :taunt] if bound
      anchor = anchor_victim_for(creature, view)
      return [anchor, :anchor] if anchor
      threat = view.threat_config
      candidates = view.hostiles_for(creature)
                       .reject { |h| view.beachhead_shields?(creature, h) }
                       .select { |h| chebyshev(creature.tile, h.tile) <= creature.kit[:aggro_tiles] }
      return [nil, nil] if candidates.empty?
      if (hated = creature.kit[:hate])
        hit = candidates.find { |h| h.kit_name == hated.to_sym }
        return [hit, :hate] if hit
      end
      low = candidates.select { |h| h.hp < h.max_hp * threat[:lowhp_switch_pct] }
      unless low.empty?
        return [nearest(creature, low), :lowhp]
      end
      focus = creature.focus
      if focus && !focus.dead? && candidates.include?(focus)
        steal = nearest(creature, candidates)
        if !steal.equal?(focus) &&
           chebyshev(creature.tile, focus.tile) - chebyshev(creature.tile, steal.tile) >=
           threat[:proximity_switch_margin_tiles]
          return [steal, :proximity]
        end
        return [focus, :sticky]
      end
      [nearest(creature, candidates), :acquired]
    end

    def tick(creature, view)
      return if creature.dead?
      return tick_human(creature, view) if creature.faction == :human
      bound = creature.taunted_target || anchor_victim_for(creature, view)
      marked = marked_target_for(creature, view)
      target = bound || marked || nearest(creature, view.hostiles_for(creature))
      if target && (bound || marked || chebyshev(creature.tile, target.tile) <= creature.kit[:aggro_tiles])
        engage(creature, target, view)
      elsif creature.faction == :pack && !view.possessed.equal?(creature)
        follow(creature, view.possessed, view)
      end
    end

    private

    def tick_human(creature, view)
      target = creature.focus
      if target && !target.dead?
        creature.reset_leash!
        case view.pressure_role(creature)
        when :pressuring then pressure_step(creature, target, view)
        else engage(creature, target, view)
        end
      else
        creature.tick_leash
        leash_home(creature, view)
      end
    end

    # Leash-with-no-heal (A2): nothing in aggro for the linger -> walk home,
    # KEEPING hp. A returning human re-engages the moment focus reappears
    # (dispersed, not invulnerable).
    def leash_home(creature, view)
      return if creature.leash_frames < view.threat_config[:leash_linger_frames]
      return if creature.tile == creature.home_tile
      view.human_leashed!(creature) if view.respond_to?(:human_leashed!)
      return if creature.moving?
      blocked = view.blocked_for(creature)
      dir = view.flow_home(creature).downhill_from(*creature.tile, blocked:)
      return unless dir
      creature.face(dir)
      creature.step(dir[0], dir[1], blocked:)
    end

    # The anchor holds: a husk that taunted the room must not walk off after
    # a mark press or trail the possessed — it targets its nearest living
    # victim until every lock expires or breaks (spec design decision 5).
    def anchor_victim_for(creature, view)
      victims = view.hostiles_for(creature)
                    .select { |h| !h.dead? && h.taunted_target&.equal?(creature) }
      nearest(creature, victims)
    end

    def marked_target_for(creature, view)
      return nil unless creature.faction == :pack
      return nil if view.possessed.equal?(creature)
      view.respond_to?(:marked_target) ? view.marked_target : nil
    end

    def engage(creature, target, view)
      if in_attack_range?(creature, target, view)
        face_toward(creature, target)
        creature.start_attack
      elsif !creature.moving?
        if projectile?(creature) && chebyshev(creature.tile, target.tile) < 2
          retreat_step(creature, target, view) # husk-grade: open range, then fire (M2.1 fix 5)
        else
          chase_step(creature, target, view)
        end
      end
    end

    def projectile?(creature) = creature.kit[:attack][:arc] == "projectile"

    # A projectile kit hugging its target is inert (needs dist >= 2). Step to
    # the first free neighbor that INCREASES distance; cornered (no such
    # neighbor reachable), side-step along the wall at EQUAL distance instead
    # of freezing in place — fixed STEPS order = deterministic. Full kiting
    # stays A1 gambit territory.
    def retreat_step(creature, target, view)
      blocked = view.blocked_for(creature)
      dist = chebyshev(creature.tile, target.tile)
      [dist + 1, dist].each do |want|
        Game::FlowField::STEPS.each do |(dx, dy)|
          to = [creature.tile[0] + dx, creature.tile[1] + dy]
          next unless chebyshev(to, target.tile) >= want
          return true if creature.step(dx, dy, blocked:)
        end
      end
      false
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

    # Pressuring: close space, claim a ring tile, body-block -- never swing.
    # The ring is porous by design (dodge and specials cross it): escapable
    # is what makes wipes fair (spec cadence law).
    def pressure_step(creature, target, view)
      return if creature.moving?
      slot = view.pressure_slot(creature, target)
      return unless slot && slot != creature.tile
      blocked = view.blocked_for(creature)
      dx = (slot[0] - creature.tile[0]).clamp(-1, 1)
      dy = (slot[1] - creature.tile[1]).clamp(-1, 1)
      if creature.step(dx, dy, blocked:)
        creature.face([dx, dy])
      else
        dir = view.flow_to(target).downhill_from(*creature.tile, blocked:)
        if dir
          creature.face(dir)
          creature.step(dir[0], dir[1], blocked:)
        end
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
