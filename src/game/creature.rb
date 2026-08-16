require "game/grid_walker"

module Game
  # The unified actor: ANY creature on the grid — pack member or human —
  # is a Creature with a kit (all numbers from data), a faction, and a body.
  # Controllers (possessed or AI) drive it through public verbs; the World
  # resolves combat by reading the ATTACKER's kit (never a player path).
  class Creature
    SIZE = 28

    RING = [[0, -1], [1, 0], [0, 1], [-1, 0], [1, -1], [1, 1], [-1, 1], [-1, -1]].freeze

    attr_reader :hp, :max_hp, :kit, :kit_name, :faction, :name, :walker,
                :facing, :attack_state, :stagger, :dodge_cooldown, :current_action,
                :carried, :taunt_frames, :home_tile, :leash_frames
    attr_accessor :focus

    def initialize(bus:, kit:, kit_name:, map:, tile:, faction:, name:)
      @bus = bus
      @kit = kit
      @kit_name = kit_name
      @faction = faction
      @name = name
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
      @max_hp = kit[:max_hp]
      @hp = @max_hp
      @facing = [1, 0]
      @attack_state = :idle
      @state_frames = 0
      @current_action = nil
      @action_frames = {}
      @hit_victims = []
      @action_triggered = false
      @dash_plan = nil
      @exhaust = 0
      @special_exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      @carried = 0
      @taunted_by = nil
      @taunt_frames = 0
      @home_tile = tile.dup.freeze # threat home: where this body belongs (A2 leash)
      @focus = nil
      @leash_frames = 0
      @beachhead_waived = false
      # v15 seizure (victim side) + chant (challenger side). Inert for
      # every kind that never uses them — the taunt-state precedent.
      @seized_by = nil
      @seized_frames = 0
      @chant_left = 0
      @chant_target = nil
      @chant_hp = 0
      @seize_cooldown = 0
      @engaged_announced = false
    end

    def tile = [@walker.tile_x, @walker.tile_y]
    def x = @walker.px
    def y = @walker.py
    def dead? = @hp <= 0
    def moving? = @walker.moving?
    def hurt? = @hurt_frames.positive?
    def iframes? = @iframes.positive?
    def exhaust_ready? = @exhaust <= 0
    def special_ready? = @special_exhaust <= 0
    def staggered? = @stagger.positive?
    def action_active? = @attack_state == :active && !@current_action.nil?
    def telegraphing? = @attack_state == :windup
    def action_config = @current_action && @kit[@current_action]
    def special_committed? = @current_action == :special && %i[windup active].include?(@attack_state)

    def reserved_tile
      @dash_plan&.landing if @attack_state == :windup
    end

    def action_can_hit?(victim) = action_active? && !@hit_victims.include?(victim)

    # --- v17 digest lane (spec decision 6): this body as flat named
    # scalars. Creature references serialize as stable names (kit name for
    # pack bodies, spawn-order name for humans). Every name here is pinned
    # by the coverage test and swept by the mutation-sensitivity test;
    # adding sim state to Creature without adding it here is W1 — the
    # watched desync-blindness risk. home_tile is static per life but
    # feeds leashing, so it rides along.
    def digest_fields
      [
        ["kind", @kit_name],
        ["tile_x", @walker.tile_x], ["tile_y", @walker.tile_y],
        ["px", @walker.px], ["py", @walker.py],
        ["tween_left", @walker.tween_left], ["tween_total", @walker.tween_total],
        ["reserved_x", reserved_tile&.[](0)], ["reserved_y", reserved_tile&.[](1)],
        ["facing_x", @facing[0]], ["facing_y", @facing[1]],
        ["hp", @hp], ["alive", !dead?],
        ["stagger", @stagger], ["exhaust", @exhaust],
        ["special_exhaust", @special_exhaust], ["iframes", @iframes],
        ["dodge_cooldown", @dodge_cooldown], ["hurt_frames", @hurt_frames],
        ["action", @current_action], ["action_state", @attack_state],
        ["action_frames", @state_frames], ["action_triggered", @action_triggered],
        ["hit_victims", @hit_victims.map(&:name).join(",")],
        ["dash_landing", @dash_plan&.landing&.join(",")],
        ["dash_crossed", @dash_plan && @dash_plan.crossed.map { |t| t.join(",") }.join("|")],
        ["dash_duration", @dash_plan&.duration],
        ["carried", @carried], ["marked", marked?],
        ["seized_by", @seized_by&.name], ["seized_frames", @seized_frames],
        ["chant_left", @chant_left], ["chant_target", @chant_target&.name],
        ["chant_hp", @chant_hp], ["seize_cooldown", @seize_cooldown],
        ["engaged", @engaged_announced],
        ["focus", @focus&.name],
        ["taunted_by", @taunted_by&.name], ["taunt_frames", @taunt_frames],
        ["taunt_cause", @taunt_cause],
        ["leash_frames", @leash_frames], ["beachhead_waived", @beachhead_waived],
        ["retarget_cause", @retarget_cue_cause], ["retarget_frames", @retarget_cue_frames],
        ["home_x", @home_tile[0]], ["home_y", @home_tile[1]]
      ]
    end
    def action_hit!(victim)
      @hit_victims << victim unless @hit_victims.include?(victim)
    end
    def action_can_trigger? = action_active? && !@action_triggered
    def action_triggered! = @action_triggered = true

    # Timers + tween advance every frame regardless of controller.
    def tick_body
      @walker.tick
      return if dead?
      @exhaust -= 1 if @exhaust.positive?
      @special_exhaust -= 1 if @special_exhaust.positive?
      @iframes -= 1 if @iframes.positive?
      @stagger -= 1 if @stagger.positive?
      @dodge_cooldown -= 1 if @dodge_cooldown.positive?
      @hurt_frames -= 1 if @hurt_frames.positive?
      @retarget_cue_frames -= 1 if @retarget_cue_frames&.positive?
      if @taunt_frames.positive?
        @taunt_frames -= 1
        clear_taunt! if @taunt_frames.zero? || @taunted_by&.dead?
      end
      advance_attack_state
    end

    def face(dir)
      @facing = dir unless dir == [0, 0]
    end

    def step(dx, dy, blocked:)
      return false if dead? || staggered? || %i[windup active].include?(@attack_state)
      @walker.step(dx, dy, frames: @kit[:step_frames], blocked:)
    end

    # Exhaust is the ONLY cadence gate (law 1): a swing may not begin until
    # the clock runs out. Creature-owned, swap-inert by construction (law 4).
    def start_attack
      return false if dead? || staggered? || @attack_state != :idle || !exhaust_ready?
      @exhaust = @kit[:attack][:exhaust_frames]
      begin_action(:attack)
    end

    def start_special(blocked: [])
      cfg = @kit[:special]
      return false unless cfg
      return false if dead? || staggered? || @attack_state != :idle || !special_ready?
      active_frames = nil
      if cfg[:arc] == "dash"
        @dash_plan = @walker.plan_dash(
          @facing[0], @facing[1],
          max_tiles: cfg[:max_tiles], frames_per_tile: cfg[:frames_per_tile],
          blocked:, through: true
        )
        return false unless @dash_plan
        active_frames = @dash_plan.duration
      end
      @special_exhaust = cfg[:exhaust_frames]
      begin_action(:special, active_frames:)
    end

    def action_tiles
      cfg = action_config
      return [] unless cfg
      return @dash_plan.crossed if cfg[:arc] == "dash" && @dash_plan
      tx, ty = tile
      case cfg[:arc]
      when "ring"
        RING.map { |(dx, dy)| [tx + dx, ty + dy] }
      when "front1" # striker: one precise tile, no flanks
        [[tx + @facing[0], ty + @facing[1]]]
      when "projectile", "volley" # World owns the shot / delayed target tiles
        []
      else # "arc3": front + flanks (diagonal facing -> cardinal components)
        fx, fy = @facing
        front = [tx + fx, ty + fy]
        flanks =
          if fx != 0 && fy != 0
            [[tx + fx, ty], [tx, ty + fy]]
          else
            [[front[0] + fy, front[1] + fx], [front[0] - fy, front[1] - fx]]
          end
        [front, *flanks]
      end
    end

    # Dodge passes THROUGH bodies (through: true) — the surround ring can be
    # escaped but never landed on; walls still stop it. Knockback keeps the
    # stop-short dash (being shoved through a body would be wrong).
    def dodge(dir, blocked: [])
      cfg = @kit[:dodge]
      return false if dead? || staggered? || cfg.nil?
      return false unless @dodge_cooldown.zero? && @attack_state == :idle
      d = dir == [0, 0] ? @facing : dir
      moved = @walker.dash(d[0], d[1], max_tiles: cfg[:tiles],
                           frames_per_tile: cfg[:frames_per_tile], blocked:, through: true)
      return false unless moved
      @iframes = [@iframes, cfg[:iframes]].max
      @dodge_cooldown = cfg[:cooldown_frames]
      @bus.emit(:dodged, actor: self)
      true
    end

    # No blanket post-hit invuln (law 5): only dodge i-frames block. Damage
    # pacing comes from each attacker's own exhaust cadence. Interrupt-on-hit
    # is a kit property (old game: the player was interrupted, husks were
    # NOT — an uninterruptible windup is what lets pressure through).
    # Knockback is the ATTACKER's stat (kit identity: a blocker displaces,
    # a striker doesn't) — the victim only supplies the tween speed.
    def take_hit(damage:, attacker:, knockback_tiles: 0, blocked: [])
      return false if iframes? || dead?
      waive_beachhead! if @faction == :human && attacker.faction == :pack
      @hp = [@hp - damage, 0].max
      @hurt_frames = 8
      interrupt_action! if @kit[:interrupt_on_hit] || (dead? && @current_action == :special)
      knock_away_from(attacker.tile, knockback_tiles, blocked)
      if dead?
        @bus.emit(:actor_died, actor: self, killer: attacker, faction: @faction)
      else
        @bus.emit(:damage_dealt, target: self, hp: @hp, attacker:)
      end
      true
    end

    def stagger!(frames)
      @stagger = [@stagger, frames].max
    end

    def tick_leash = @leash_frames += 1
    def reset_leash! = @leash_frames = 0
    def beachhead_waived? = @beachhead_waived
    def waive_beachhead! = @beachhead_waived = true

    # Taunt lock (A0.6): victim-owned, swap-inert — bound to the taunter's
    # BODY, never the possession pointer. A fresh taunt overwrites.
    # cause (v13): rides the lock for telemetry (:challenged for the
    # blocker's challenge); the mechanism itself is unchanged.
    def taunt!(taunter, frames, cause: :taunt)
      @taunted_by = taunter
      @taunt_frames = frames
      @taunt_cause = cause
      waive_beachhead!
    end

    def taunt_cause = @taunt_cause

    # PURE reader — never mutates (the renderer calls it from draw, and a
    # mutating reader would let wall-clock draw timing change sim state).
    # Clearing is sim-owned: tick_body for ticking victims, and the World's
    # respawn sweep for victims frozen in abandoned zones (impl review 1+2:
    # a lazy clear here is unreachable between wipe and revival, so revival
    # would resurrect locks the blocker never re-cast).
    def taunted_target
      return nil unless @taunted_by && @taunt_frames.positive?
      @taunted_by.dead? ? nil : @taunted_by
    end

    # Q6 rider: why-they-turned cue. Sim-owned timer (renderer READS it,
    # never mutates — taunted_target law); stamped by assign_human_focus,
    # decays in this body's own tick.
    def retarget_cue!(cause, frames)
      @retarget_cue_cause = cause
      @retarget_cue_frames = frames
    end

    def retarget_cue
      return nil unless @retarget_cue_frames&.positive?
      { cause: @retarget_cue_cause, frames_left: @retarget_cue_frames }
    end

    def clear_retarget_cue!
      @retarget_cue_cause = nil
      @retarget_cue_frames = 0
    end

    def release_taunt! = clear_taunt!

    # --- v15 seizure: the Challenger's verb, victim side -----------------
    # Body-owned and swap-inert like taunt — the seizure names the BODY,
    # never the echo (fiction-exact AND the swap-escape mechanism).
    def seize!(seizer, frames)
      @seized_by = seizer
      @seized_frames = frames
    end

    # PURE reader (taunted_target law): nil once the seizure is spent or
    # the seizer is dead. Raw state stays visible via seizure_seizer /
    # seize_active? for the World's exactly-once end sweep.
    def seized_by
      return nil unless @seized_by && @seized_frames.positive?
      @seized_by.dead? ? nil : @seized_by
    end

    def seize_active? = !@seized_by.nil? && @seized_frames.positive?
    def seizure_seizer = @seized_by
    def seized_frames = @seized_frames

    def tick_seizure
      @seized_frames -= 1 if @seized_frames.positive?
    end

    def release_seize!
      @seized_by = nil
      @seized_frames = 0
    end

    # --- v15 chant: the Challenger's verb, caster side -------------------
    # The creature holds state; World#tick_challengers owns the clock,
    # the interrupt (hp below chant-start), and every event.
    def start_chant!(target, frames)
      @chant_target = target
      @chant_left = frames
      @chant_hp = @hp
    end

    def chanting? = @chant_left.positive?
    def chant_left = @chant_left
    def chant_target = @chant_target
    def chant_hp = @chant_hp

    def tick_chant
      @chant_left -= 1 if @chant_left.positive?
    end

    def abort_chant!
      @chant_left = 0
      @chant_target = nil
    end

    def seize_cooldown = @seize_cooldown
    def seize_cooldown!(frames) = @seize_cooldown = frames

    def tick_seize_cooldown
      @seize_cooldown -= 1 if @seize_cooldown.positive?
    end

    def engaged_announced? = @engaged_announced
    def announce_engaged! = @engaged_announced = true

    # Carried value is creature-owned and swap-inert (law 4): it rides the
    # body, not the possession pointer. Drained by banking and by death.
    def pick_up(amount) = @carried += amount

    def drain_carried!
      amount = @carried
      @carried = 0
      amount
    end

    # D1b god-mark: body-owned and swap-inert (law 4) — it rides the BODY
    # like carried and taunt, never the possession pointer. Burned ONLY by
    # the judgment (World#respawn_pack); revive!/vat-regrowth preserve it.
    def marked? = !!@god_mark

    def inscribe_mark!
      @god_mark = true
    end

    def burn_mark!
      @god_mark = false
    end

    def interrupt_action!
      @attack_state = :idle
      @state_frames = 0
      @current_action = nil
      @action_frames = {}
      @hit_victims = []
      @action_triggered = false
      @dash_plan = nil
    end

    def rebind(map:, tile:)
      @walker = GridWalker.new(map:, tile_x: tile[0], tile_y: tile[1], size: SIZE)
    end

    # Tribute heal (D1b): flesh only — clocks, exhaust, iframes, carried all
    # untouched (revive! is the full reset; this is not it).
    def heal_full!
      @hp = @max_hp
    end

    def revive!(map:, tile:)
      @hp = @max_hp
      interrupt_action!
      @exhaust = 0
      @special_exhaust = 0
      @iframes = 0
      @stagger = 0
      @dodge_cooldown = 0
      @hurt_frames = 0
      @carried = 0
      clear_taunt!
      # Belt+braces (clear_taunt! reasoning): a revived body is fresh
      # flesh. Reachable seizures end at death (why=:died) BEFORE any
      # revive, so this never swallows an event.
      release_seize!
      rebind(map:, tile:)
    end

    private

    def clear_taunt!
      @taunted_by = nil
      @taunt_frames = 0
      @taunt_cause = nil
    end

    def begin_action(kind, active_frames: nil)
      cfg = @kit.fetch(kind)
      @current_action = kind
      @action_frames = {
        windup: cfg[:windup_frames],
        active: active_frames || cfg[:active_frames],
        recovery: cfg[:recovery_frames]
      }
      @dash_plan = nil unless cfg[:arc] == "dash"
      @hit_victims = []
      @action_triggered = false
      @attack_state = :windup
      @state_frames = @action_frames[:windup]
      event = kind == :attack ? :attack_started : :special_started
      @bus.emit(event, attacker: self)
      true
    end

    def knock_away_from(from_tile, tiles, blocked)
      return if tiles.zero?
      dx = (@walker.tile_x - from_tile[0]).clamp(-1, 1)
      dy = (@walker.tile_y - from_tile[1]).clamp(-1, 1)
      dx = 1 if dx.zero? && dy.zero?
      @walker.dash(dx, dy, max_tiles: tiles,
                   frames_per_tile: @kit[:knockback_frames_per_tile], blocked:)
    end

    def advance_attack_state
      return if @attack_state == :idle
      @state_frames -= 1
      return if @state_frames.positive?
      case @attack_state
      when :windup
        @attack_state = :active
        @state_frames = @action_frames[:active]
        activate_action
      when :active
        # v13 clump-payoff: the refund anchors HERE — the one moment
        # @hit_victims is complete and not yet cleared (interrupt paths
        # never reach this line, so an interrupted spin refunds nothing).
        apply_special_refund! if @current_action == :special
        @attack_state = :recovery
        @state_frames = @action_frames[:recovery]
        interrupt_action! if @state_frames.zero?
      when :recovery
        interrupt_action!
      end
    end

    # Exhaust refund per extra victim (data-driven; nil config = no-op).
    # Density literally powers cadence — the v13 oracle's formula.
    def apply_special_refund!
      refund = action_config[:refund_frames_per_extra_hit]
      return unless refund
      extra = @hit_victims.length - 1
      return unless extra.positive?
      @special_exhaust = [@special_exhaust - refund * extra, 0].max
    end

    def activate_action
      return unless action_config[:arc] == "dash"
      @walker.commit_dash(@dash_plan)
      @iframes = [@iframes, @dash_plan.duration].max
    end
  end
end
