require "game/grid_walker"

module Game
  # The unified actor: ANY creature on the grid — pack member or human —
  # is a Creature with a kit (all numbers from data), a faction, and a body.
  # Controllers (possessed or AI) drive it through public verbs; the World
  # resolves combat by reading the ATTACKER's kit (never a player path).
  class Creature
    SIZE = 28

    RING = [[0, -1], [1, 0], [0, 1], [-1, 0], [1, -1], [1, 1], [-1, 1], [-1, -1]].freeze

    attr_reader :hp, :max_hp, :kit_name, :faction, :name, :walker,
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
      @action_cfg = nil # E0: the begun skill's cfg, live windup -> recovery
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
      @pack_provoked = false
      # v15 seizure (victim side) + chant (challenger side). Inert for
      # every kind that never uses them — the taunt-state precedent.
      @seized_by = nil
      @seized_frames = 0
      @chant_left = 0
      @chant_target = nil
      @chant_hp = 0
      @seize_cooldown = 0
      @engaged_announced = false
      @tier_dmg_pct = 0
      # MUNDO VIVO FASE 4.3 blink (serpent family): a short teleport to the
      # target's flank. Inert for every kind without kit[:blink].
      @blink_cooldown = 0
      @blink_flash = 0
      # MUNDO VIVO FASE 5 boss block: phases by hp%, each with its own skill
      # list; the active skill overrides kit[:attack] through the merged
      # `kit` view below. Inert (kit == @kit) for every kind without :boss.
      @boss_skill_index = 0
      @boss_kit_cache = {}
      # MUNDO VIVO FASE 4.5 poison (spore family): a DOT — ticks_left ticks
      # of dmg_per every interval frames. Inert for every kind never poisoned.
      @poison_ticks = 0
      @burn_ticks = 0
      @burn_dmg = 0
      @burn_interval = 1
      @burn_countdown = 0
      @burn_by = nil
      @poison_dmg = 0
      @poison_interval = 0
      @poison_countdown = 0
      @poison_by = nil
    end

    # The kit every reader sees. For a boss with phases, :attack is the
    # CURRENT phase's current skill (deterministic: phase = f(hp), skill =
    # index cycled on every attack start). Cached per (phase, index) — no
    # per-frame allocation for the hot paths.
    def kit
      phases = @kit.dig(:boss, :phases)
      return @kit if phases.nil? || phases.empty? || @boss_skill_index.nil?
      ph = boss_phase
      skills = phases[ph][:skills]
      idx = @boss_skill_index % skills.length
      @boss_kit_cache[[ph, idx]] ||= @kit.merge(attack: skills[idx])
    end

    # Phase index (0-based) = the LAST phase whose hp_pct threshold the boss
    # is at or below; phases are authored descending (100, 60, 30).
    def boss_phase
      phases = @kit.dig(:boss, :phases)
      return 0 if phases.nil? || phases.empty?
      pct = @max_hp.zero? ? 0 : (@hp * 100) / @max_hp
      i = 0
      phases.each_with_index { |p, k| i = k if pct <= p[:hp_pct] }
      i
    end

    def boss? = !@kit[:boss].nil?
    def boss_phase_count = @kit.dig(:boss, :phases)&.length || 0
    def boss_skill_index = @boss_skill_index

    def advance_boss_skill!
      @boss_skill_index += 1 if boss? && boss_phase_count.positive?
    end

    def tile = [@walker.tile_x, @walker.tile_y]
    def x = @walker.px
    def y = @walker.py
    def dead? = @hp <= 0
    def moving? = @walker.moving?
    def hurt? = @hurt_frames.positive?
    def hurt_frames = @hurt_frames
    def iframes? = @iframes.positive?
    def exhaust_ready? = @exhaust <= 0
    def special_ready? = @special_exhaust <= 0
    def staggered? = @stagger.positive?
    def action_active? = @attack_state == :active && !@current_action.nil?
    def telegraphing? = @attack_state == :windup
    # E0 (T0 BLOCKER a1): the cfg of the action IN FLIGHT, snapshotted at
    # begin_action. A phased boss advances its rotation the moment a cast
    # begins, so re-reading the merged `kit` here would resolve skill N+1
    # for a cast that telegraphed skill N (ember_boss [dash, beam]: a beam
    # start followed by a dash read crashed on a nil @dash_plan). nil when
    # idle. Not digested: it is a pure function of leaves digested at the
    # begin tick (kind, hp -> phase, boss_skill_index) — two seats can only
    # disagree here if they already disagree there.
    def action_config = @current_action && @action_cfg
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
        ["pack_provoked", @pack_provoked],
        ["retarget_cause", @retarget_cue_cause], ["retarget_frames", @retarget_cue_frames],
        ["home_x", @home_tile[0]], ["home_y", @home_tile[1]],
        ["blink_cooldown", @blink_cooldown],
        ["boss_skill_index", @boss_skill_index],
        ["poison_ticks", @poison_ticks], ["poison_dmg", @poison_dmg],
        ["poison_countdown", @poison_countdown], ["poison_by", @poison_by&.name],
        ["burn_ticks", @burn_ticks], ["burn_dmg", @burn_dmg],
        ["burn_countdown", @burn_countdown], ["burn_by", @burn_by&.name]
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
      @blink_cooldown -= 1 if @blink_cooldown.positive?
      @blink_flash -= 1 if @blink_flash.positive?
      tick_poison
      tick_burn
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
    def start_attack(blocked: [])
      return false if dead? || staggered? || @attack_state != :idle || !exhaust_ready?
      cfg = kit[:attack]
      active_frames = nil
      if cfg[:arc] == "dash"
        # FASE 4.4 charge: an ATTACK that is a dash (the striker's special
        # grammar, hostile side). Planned at start so the windup can draw
        # the run line; commit + i-frames happen at activate_action.
        @dash_plan = @walker.plan_dash(
          @facing[0], @facing[1],
          max_tiles: cfg[:max_tiles], frames_per_tile: cfg[:frames_per_tile],
          blocked:, through: true
        )
        return false unless @dash_plan
        active_frames = @dash_plan.duration
      end
      @exhaust = cfg[:exhaust_frames]
      begin_action(:attack, active_frames:)
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
      # dash-strike (s66): the DAMAGE line is the full scan (struck) — the
      # movement may land short of a body; the blade still reaches it.
      return @dash_plan.struck if cfg[:arc] == "dash" && @dash_plan
      tx, ty = tile
      case cfg[:arc]
      when "ring"
        RING.map { |(dx, dy)| [tx + dx, ty + dy] }
      when "front1" # striker: one precise tile, no flanks
        [[tx + @facing[0], ty + @facing[1]]]
      when "projectile", "volley", "spread" # World owns the shot(s) / delayed target tiles
        []
      when "beam" # FASE 4.4: a straight line along the facing, stops at the first wall
        fx, fy = @facing
        out = []
        (1..cfg.fetch(:beam_length, 6)).each do |i|
          x = tx + fx * i
          y = ty + fy * i
          break unless @walker.map.passable?(x, y)
          out << [x, y]
        end
        out
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
      # C2 provocation (v19 Lane 3, s80): every damage arc funnels here, so
      # this is the ONE choke point for both directions of the defensive-
      # default law — a human the pack strikes is engaged ("what the
      # possessed engages"), a human that strikes any pack body has
      # attacked the pack. Body-scoped like the beachhead waiver: an echo
      # respawns as a NEW Creature, unprovoked by construction.
      provoke! if @faction == :human && attacker.faction == :pack
      attacker.provoke! if @faction == :pack && attacker.faction == :human
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

    # FASE 4.3 blink: instant relocation to `tile` (already validated by the
    # caller as passable + unoccupied), facing the target, then a cooldown
    # from kit[:blink][:cooldown_frames]. A presentation flash counter (never
    # digested) lets the renderer draw the departure/arrival tell.
    # FASE 4.5 poison: applied by a landed hit whose cfg carries :poison
    # {ticks, dmg_per, interval_frames}. Re-application REFRESHES (max of
    # ticks, latest dmg) — never stacks. Damage bypasses i-frames and
    # knockback (it is not a hit), but DEATH walks the same door as every
    # hit: actor_died with the poisoner as killer (drops/xp/corpse laws hold).
    def poison!(ticks:, dmg_per:, interval_frames:, by:)
      @poison_ticks = [@poison_ticks, ticks].max
      @poison_dmg = dmg_per
      @poison_interval = interval_frames
      @poison_countdown = interval_frames if @poison_countdown.zero?
      @poison_by = by
    end

    # FASE 4.6 aura: non-hit damage from a field (bypasses i-frames and
    # knockback like poison; death walks the actor_died door with the
    # field's owner as killer). Shared by every future field effect.
    # Field damage (aura tick, lava) - instant, bypasses i-frames like poison.
    def burn!(amount, by:)
      return false if dead? || amount <= 0
      @hp = [@hp - amount, 0].max
      if dead?
        interrupt_action!
        @bus.emit(:actor_died, actor: self, killer: by, faction: @faction)
      else
        @bus.emit(:damage_dealt, target: self, hp: @hp, attacker: by)
      end
      true
    end

    # S3: BURN as a status - a DOT that keeps ticking after you leave the
    # fire (mirrors poison!: refresh extends, never stacks damage). Numbers
    # come from balance/status.json burn. Cured by an item with use.cure
    # ["burn"] (ember_salve) - see cure!.
    def ignite!(ticks:, dmg_per:, interval_frames:, by:)
      @burn_ticks = [@burn_ticks, ticks].max
      @burn_dmg = dmg_per
      @burn_interval = interval_frames
      @burn_countdown = interval_frames if @burn_countdown.zero?
      @burn_by = by
    end

    def burning? = @burn_ticks.positive?
    def burn_ticks = @burn_ticks

    def tick_burn
      return unless burning? && !dead?
      @burn_countdown -= 1
      return if @burn_countdown.positive?
      @burn_countdown = @burn_interval
      @burn_ticks -= 1
      @hp = [@hp - @burn_dmg, 0].max
      if dead?
        @burn_ticks = 0
        interrupt_action!
        @bus.emit(:actor_died, actor: self, killer: @burn_by, faction: @faction)
      else
        @bus.emit(:damage_dealt, target: self, hp: @hp, attacker: @burn_by)
      end
    end

    # S3: clear a named status (antidote -> poison, ember_salve -> burn).
    # Returns true when something was cured.
    def cure!(status)
      case status.to_sym
      when :poison
        return false unless poisoned?
        @poison_ticks = 0
        @poison_countdown = 0
      when :burn
        return false unless burning?
        @burn_ticks = 0
        @burn_countdown = 0
      else
        return false
      end
      true
    end

    # Statuses this body carries right now (for the HUD / cure lookup).
    def statuses
      out = []
      out << :poison if poisoned?
      out << :burn if burning?
      out
    end

    def poisoned? = @poison_ticks.positive?
    def poison_ticks = @poison_ticks

    def tick_poison
      return unless poisoned? && !dead?
      @poison_countdown -= 1
      return if @poison_countdown.positive?
      @poison_countdown = @poison_interval
      @poison_ticks -= 1
      @hp = [@hp - @poison_dmg, 0].max
      if dead?
        @poison_ticks = 0
        interrupt_action!
        @bus.emit(:actor_died, actor: self, killer: @poison_by, faction: @faction)
      else
        @bus.emit(:damage_dealt, target: self, hp: @hp, attacker: @poison_by)
      end
    end

    def blink_ready? = !@kit[:blink].nil? && @blink_cooldown.zero? && @attack_state == :idle && !staggered? && !dead?
    def blink_flash? = @blink_flash.positive?
    def blink_cooldown = @blink_cooldown

    def blink!(tile, face_toward:)
      @walker.teleport(tile[0], tile[1])
      dx = (face_toward[0] - tile[0]).clamp(-1, 1)
      dy = (face_toward[1] - tile[1]).clamp(-1, 1)
      face([dx, dy]) unless dx.zero? && dy.zero?
      @blink_cooldown = @kit[:blink][:cooldown_frames]
      @blink_flash = @kit[:blink].fetch(:flash_frames, 8)
      true
    end

    def tick_leash = @leash_frames += 1
    def reset_leash! = @leash_frames = 0
    # J7-B catch-up resume: the absence already spent the linger — pre-set
    # the counter so the walk resumes next tick without re-lingering and
    # without re-crossing leash_emission's == threshold (emit-once law).
    def resume_leash!(frames) = @leash_frames = frames
    def beachhead_waived? = @beachhead_waived
    def waive_beachhead! = @beachhead_waived = true
    # C2 (s80): provocation gates FREE-ALLY acquisition only — human-side
    # AI never reads it. Set at take_hit/taunt! (creature-side) and at the
    # chant/seize aggression sites (World); cleared when the human
    # disengages (leash past linger) or the pack re-enters the zone.
    def pack_provoked? = @pack_provoked
    def provoke! = @pack_provoked = true
    def clear_provocation! = @pack_provoked = false

    # Taunt lock (A0.6): victim-owned, swap-inert — bound to the taunter's
    # BODY, never the possession pointer. A fresh taunt overwrites.
    # cause (v13): rides the lock for telemetry (:challenged for the
    # blocker's challenge); the mechanism itself is unchanged.
    def taunt!(taunter, frames, cause: :taunt)
      @taunted_by = taunter
      @taunt_frames = frames
      @taunt_cause = cause
      # C2: a possessed challenge is an engage order — the pack picked this
      # fight, so the whole pack may answer it (not just the anchor-bound
      # taunter).
      provoke! if @faction == :human && taunter.faction == :pack
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

    # v18 save-apply seam (SaveState.apply! only, construction time):
    # hp lands directly — alive is DERIVED (hp > 0, never stored), so a
    # zero here IS death; no event fires (a loaded death already
    # happened in a previous session). Clamping to the kit's current
    # max is the caller's job (it owns the data).
    def load_hp!(hp)
      @hp = hp
    end

    # P4 level growth: living flesh gains only the ceiling delta (never a
    # free full heal); dead flesh keeps hp 0 and revives into the new max.
    # A negative retune delta clamps living flesh to 1 instead of killing it.
    def grow_max_hp!(delta)
      @max_hp += delta
      return if dead?
      @hp = (@hp + delta).clamp(1, @max_hp)
    end

    # s68 zone-tier seam (TierSheet#apply! via World#add_human only,
    # spawn time — the coop-seam precedent below): Integer pct on the kit
    # base, base + base·pct/100 with Integer division — no Float ever
    # enters the balance path. HP applies BEFORE the coop scalar
    # (composition pin: kit base -> zone tier -> coop scalar); the damage
    # pct rides the BODY for World#leveled_damage, static per life like
    # home_tile (config-derived — the max_hp digest precedent).
    def tier_max_hp!(pct)
      @max_hp += (@max_hp * pct) / 100
      @hp = @max_hp
    end

    def tier_damage!(pct) = @tier_dmg_pct = pct

    def tier_dmg_pct = @tier_dmg_pct

    # v18 coop-spawn seam (decision 11, World#add_human only, spawn
    # time): rescales the ceiling and fills to it — an explicit .round
    # Integer, never mid-life, never at seats=1 (the caller guards on
    # the coop block's existence).
    def scale_max_hp!(scale)
      @max_hp = (@max_hp * scale).round
      @hp = @max_hp
    end

    def interrupt_action!
      @attack_state = :idle
      @state_frames = 0
      @current_action = nil
      @action_cfg = nil
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

    # Provision heal (v18 decision 9, Pack#use_provision! only): partial
    # flesh heal clamped at the ceiling — dead flesh untouched (the vat
    # keeps regrowth; heal_full! keeps the station). Same flesh-only law
    # as heal_full!: clocks, exhaust, iframes, carried all untouched.
    def heal!(amount)
      return if dead?
      @hp = [@hp + amount, @max_hp].min
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
      cfg = kit.fetch(kind)
      @current_action = kind
      @action_cfg = cfg # E0: every later reader (World resolve, renderer, activate) sees THIS skill
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
      # Payload shape stays {attacker:} on purpose: EventSerial.describe
      # serializes EVERY key, special_started is a wall EVENT line (the
      # sim-identity banks) and every registered event feeds the netplay
      # digest. Handlers run at the frame's bus flush (after the advance
      # below) and read the begun skill through attacker.action_config.
      @bus.emit(event, attacker: self)
      advance_boss_skill! if kind == :attack   # FASE 5: next skill in the phase's rotation (the snapshot above keeps THIS cast on skill N)
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
