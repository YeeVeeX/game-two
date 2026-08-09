require "core/event_bus"
require "core/state_stack"
require "core/tile_map"
require "game/creature"
require "game/pack"
require "game/projectile"
require "game/controllers"
require "game/feel"
require "game/camera"
require "game/flow_field"

module Game
  # The sim: a pack of creatures (one possessed, the rest AI) hunting through
  # zones against hostile humans (M1 stand-in kit: husk). Combat resolves
  # from the ATTACKER's kit via factions — there is no player path. Pure and
  # deterministic; never touches Gosu. Seed plumbs the sim PRNG (unused by
  # M1 logic; the plumbing is determinism law 3).
  class World
    EVENTS = %i[
      attack_started attack_hit damage_dealt actor_died dodged telegraph
      zone_entered possession_changed pack_wiped pack_respawned projectile_fired
    ].freeze

    TRANSITIONS = { world: %i[nest_respawn], nest_respawn: %i[world] }.freeze

    HOME_ZONE = "nest".freeze # fiction-pending name (world bible integration = owner call)

    attr_reader :bus, :pack, :feel, :states, :frame, :camera, :zone_name, :rng

    def initialize(data, seed: 0)
      @data = data
      @display = data["display"]
      @balance = data["balance/combat"]
      @rng = Random.new(seed)
      @bus = Core::EventBus.new.register(*EVENTS)
      @states = Core::StateStack.new(initial: :world, transitions: TRANSITIONS)
      @feel = Feel.new(@balance[:feel])
      @frame = 0
      @respawn_timer = 0
      @banner_timer = 0
      @zones = {}
      @humans = Hash.new { |h, k| h[k] = [] }
      @human_respawns = Hash.new { |h, k| h[k] = [] }
      @projectiles = []
      @corpses = Hash.new { |h, k| h[k] = [] }
      @controller = PossessedController.new
      @ai = AiController.new
      @swap_was_down = false
      @rearm_needed = false
      load_zones
      spawn_pack
      wire_events
      enter_zone(HOME_ZONE, map.pack_spawn)
    end

    def map = @zones.fetch(@zone_name)
    def humans = @humans[@zone_name]
    def possessed = @pack.possessed
    def banner? = @banner_timer.positive?
    def actors = (@pack.members + humans).reject(&:dead?)
    def projectiles = @projectiles
    def corpses = @corpses[@zone_name]

    def tick(input)
      if @feel.hitstop?
        @feel.tick
        @bus.process
        @frame += 1
        return
      end

      @banner_timer -= 1 if @banner_timer.positive?

      case @states.current
      when :world
        tick_world(input)
      when :nest_respawn
        @respawn_timer -= 1
        if @respawn_timer <= 0
          @states.transition_to(:world)
          respawn_pack
        end
      end

      c = possessed
      @camera.tick(c.x + Creature::SIZE / 2.0, c.y + Creature::SIZE / 2.0)
      @feel.tick
      @bus.process
      @frame += 1
    end

    # --- view API (AiController duck-type) ------------------------------

    def hostiles_for(creature)
      creature.faction == :pack ? humans.reject(&:dead?) : @pack.living
    end

    def blocked_for(creature)
      actors.reject { |a| a.equal?(creature) }.map(&:tile)
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
                           .find { |t| map.passable?(*t) && !claims.key?(t) }
      claims[slot] = attacker if slot
      slot
    end

    # Straight walls-only ray check for ranged AI (occupancy is deliberately
    # ignored — a shot over a friendly is legal, no friendly fire).
    def line_clear?(from, to)
      dx = (to[0] - from[0]).clamp(-1, 1)
      dy = (to[1] - from[1]).clamp(-1, 1)
      cx, cy = from
      loop do
        cx += dx
        cy += dy
        return true if [cx, cy] == to
        return false unless map.passable?(cx, cy)
      end
    end

    # Flow fields anchor on ANY creature, cached per anchor, recomputed only
    # when the anchor's tile changes. Cache clears on zone change.
    def flow_to(anchor)
      @flow_cache ||= {}
      entry = (@flow_cache[anchor] ||= { field: FlowField.new(map), tile: nil })
      if entry[:tile] != anchor.tile
        entry[:field].recompute!(anchor.tile)
        entry[:tile] = anchor.tile
      end
      entry[:field]
    end

    private

    def tick_world(input)
      @slot_claims = {}
      handle_swap(input)
      # Forced swap happens at bus-process time (no input in scope there), so
      # the edge-trigger re-arm is deferred to the next tick — law 2 applies
      # to BOTH swap kinds: no held key may leak into the new body.
      if @rearm_needed
        @controller.rearm!(input)
        @rearm_needed = false
      end
      @pack.members.each(&:tick_body)
      humans.each(&:tick_body)

      @controller.blocked = blocked_for(possessed)
      @controller.tick(possessed, input, self)
      @pack.living.each { |m| @ai.tick(m, self) unless m.equal?(possessed) }
      humans.each { |h| emit_telegraph_edge(h); @ai.tick(h, self) }

      check_transition
      resolve_attacks
      tick_projectiles
      respawn_due_humans
      prune_caches
    end

    # Tab swap: rising edge only, world-level (the controller mask handles
    # every OTHER action; swap itself must not autorepeat while held).
    # Refused while the possessed is staggered — otherwise an instant Tab
    # after a forced swap hands you an unstaggered third body and the
    # death penalty never lands (law 2).
    def handle_swap(input)
      down = input.down?(:swap)
      if down && !@swap_was_down && @pack.living.length > 1 && !possessed.staggered?
        from = possessed
        @pack.swap_next!
        @controller.rearm!(input)
        @bus.emit(:possession_changed, from:, to: possessed, forced: false)
      end
      @swap_was_down = down
    end

    # Any active unlanded swing hits the FIRST living hostile on its tiles
    # (attack_tiles order is deterministic: front-first for arcs, fixed ring
    # order otherwise). Damage comes from the attacker's kit — the law.
    #
    # Dev-of-record call: a husk killed earlier in this same frame still
    # lands its active swing (uninterruptible windup + iteration order =
    # a deterministic simultaneous trade). Killing blows don't erase a blow
    # already in flight — that's the pressure husks are for.
    def resolve_attacks
      actors.each do |attacker|
        next unless attacker.attack_can_hit?
        if attacker.kit[:attack][:arc] == "projectile"
          launch_projectile(attacker)
          next
        end
        foes = hostiles_for(attacker)
        victim = attacker.attack_tiles.filter_map { |t| foes.find { |f| !f.dead? && f.tile == t } }.first
        next unless victim
        attacker.attack_landed!
        victim.take_hit(damage: attacker.kit[:attack][:damage], attacker:,
                        knockback_tiles: attacker.kit[:attack][:knockback_tiles],
                        blocked: blocked_for(victim))
        @bus.emit(:attack_hit, attacker:, victim:)
      end
    end

    # A projectile swing "lands" the moment it fires — the shot itself is a
    # new sim object that carries the hit forward. Diagonal facings fly
    # diagonally (grid-faithful: one tile per window on both axes).
    def launch_projectile(attacker)
      attacker.attack_landed!
      cfg = attacker.kit[:attack]
      @projectiles << Projectile.new(
        owner: attacker, map:, tile: attacker.tile, dir: attacker.facing,
        damage: cfg[:damage], range_tiles: cfg[:range_tiles],
        frames_per_tile: cfg[:projectile_frames_per_tile]
      )
      @bus.emit(:projectile_fired, attacker:)
    end

    # Creation order = resolution order (deterministic). The projectile only
    # reports the victim; damage resolves here from the OWNER's kit, exactly
    # like melee — one law for all combat.
    def tick_projectiles
      @projectiles.each do |p|
        victim = p.tick(hostiles: hostiles_for(p.owner))
        next unless victim
        victim.take_hit(damage: p.damage, attacker: p.owner,
                        knockback_tiles: p.owner.kit[:attack][:knockback_tiles],
                        blocked: blocked_for(victim))
        @bus.emit(:attack_hit, attacker: p.owner, victim:)
      end
      @projectiles.reject!(&:done?)
    end

    # AiController drives the state machine; the telegraph event fires on the
    # windup rising edge so feel/renderer/harness can aim at it.
    def emit_telegraph_edge(human)
      @telegraphing ||= {}
      now = human.telegraphing?
      @bus.emit(:telegraph, actor: human) if now && !@telegraphing[human]
      @telegraphing[human] = now
    end

    def check_transition
      c = possessed
      return if c.walker.moving? || c.dead?
      t = map.transition_at(*c.tile)
      return unless t
      enter_zone(t[:to], arrival_tiles(t[:to], t[:spawn]))
    end

    # The whole pack moves through a gate: possessed lands on the gate spawn,
    # allies on the nearest passable neighbors (deterministic STEPS order).
    def arrival_tiles(zone, spawn)
      zmap = @zones.fetch(zone)
      tiles = [spawn]
      FlowField::STEPS.each do |(dx, dy)|
        break if tiles.length >= @pack.living.length
        cand = [spawn[0] + dx, spawn[1] + dy]
        tiles << cand if zmap.passable?(*cand) && !tiles.include?(cand)
      end
      tiles
    end

    def enter_zone(name, tiles)
      raise ArgumentError, "unknown zone #{name}" unless @zones.key?(name)
      @zone_name = name
      @flow_cache = {}
      @projectiles = []
      placed = 0
      # Possessed gets the first tile; living allies the rest, in roster order.
      ([possessed] + (@pack.living - [possessed])).each do |m|
        m.rebind(map:, tile: tiles[placed] || tiles.first)
        placed += 1
      end
      @camera = Camera.new(
        view_w: @display[:view_width], view_h: @display[:view_height],
        world_w: map.pixel_width, world_h: map.pixel_height,
        lerp: @display[:camera_lerp]
      )
      @camera.snap!(possessed.x + Creature::SIZE / 2.0, possessed.y + Creature::SIZE / 2.0)
      @banner_timer = @display[:zone_banner_frames]
      @bus.emit(:zone_entered, zone: name)
    end

    def load_zones
      names = @data.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
      names.each { |n| @zones[n] = Core::TileMap.new(@data["zones/#{n}"]) }
      seed_humans
    end

    def seed_humans
      @zones.each do |zone, zmap|
        zmap.enemy_spawns.each do |kit_name, spawns|
          spawns.each { |tile| add_human(zone, kit_name, tile) }
        end
      end
    end

    # Names use a monotonic per-zone counter, never the roster length —
    # respawns after a delete would otherwise collide with a live name and
    # corrupt the harness event log (capture scripts aim by name).
    def add_human(zone, kit_name, tile)
      kit = @balance[:kits].fetch(kit_name.to_sym)
      @human_serial ||= Hash.new(0)
      serial = @human_serial[zone]
      @human_serial[zone] += 1
      @humans[zone] << Creature.new(bus: @bus, kit:, kit_name: kit_name.to_sym,
                                    map: @zones[zone], tile:, faction: :human,
                                    name: "#{kit_name}#{serial}")
    end

    def spawn_pack
      cfg = @balance[:pack]
      home = @zones.fetch(HOME_ZONE)
      @zone_name = HOME_ZONE
      members = cfg[:members].each_with_index.map do |kit_name, i|
        Creature.new(bus: @bus, kit: @balance[:kits].fetch(kit_name.to_sym),
                     kit_name: kit_name.to_sym, map: home, tile: home.pack_spawn[i],
                     faction: :pack, name: kit_name)
      end
      @pack = Pack.new(members:, stagger_frames: cfg[:swap_stagger_frames])
    end

    def respawn_pack
      @zone_name = HOME_ZONE
      @pack.members.each_with_index { |m, i| m.revive!(map:, tile: map.pack_spawn[i]) }
      enter_zone(HOME_ZONE, map.pack_spawn)
      @bus.emit(:pack_respawned)
    end

    def respawn_due_humans
      due, rest = @human_respawns[@zone_name].partition { |r| r[:at_frame] <= @frame }
      @human_respawns[@zone_name] = rest
      due.each { |r| add_human(@zone_name, r[:kit_name], r[:tile]) }
    end

    def prune_caches
      @flow_cache&.select! { |anchor, _| !anchor.dead? }
      @telegraphing&.select! { |actor, _| !actor.dead? }
      corpses.reject! { |c| @frame - c[:at_frame] > CORPSE_FADE_FRAMES }
    end

    # A body stays where it fell and fades (vision critique: kills that
    # vanish erase the fight's history). Records, not creatures — the sim
    # never reads them; only renderer/tests do. Cap guards the roster.
    CORPSE_FADE_FRAMES = 600
    CORPSE_CAP = 40

    def leave_corpse(actor)
      list = corpses
      list << { tile: actor.tile, x: actor.x, y: actor.y,
                faction: actor.faction, at_frame: @frame }
      list.shift if list.length > CORPSE_CAP
    end

    # Feel is scoped to the possessed body (law 5): its fights hitstop and
    # shake; ally/AI-vs-AI hits emit events only — the world never freezes
    # for a fight the player isn't in.
    def wire_events
      @bus.subscribe(:attack_hit) do |e|
        if e[:victim].equal?(possessed)
          @feel.on_player_hit
        elsif e[:attacker].equal?(possessed)
          @feel.on_hit
        end
      end

      @bus.subscribe(:actor_died) do |e|
        leave_corpse(e[:actor])
        if e[:faction] == :human
          @feel.on_kill if e[:killer].equal?(possessed)
          schedule_human_respawn(e[:actor])
        elsif e[:actor].equal?(possessed)
          handle_possessed_death
        end
      end
    end

    def handle_possessed_death
      from = possessed
      survivor = @pack.forced_swap!
      if survivor
        @rearm_needed = true
        @feel.on_kill # losing a body lands like a kill against you
        @bus.emit(:possession_changed, from:, to: survivor, forced: true)
      else
        @bus.emit(:pack_wiped)
        @respawn_timer = @balance[:respawn_frames]
        @states.transition_to(:nest_respawn)
      end
    end

    def schedule_human_respawn(human)
      delay = human.kit[:respawn_frames]
      return unless delay
      spawns = map.enemy_spawns[human.kit_name] || [human.tile]
      home = spawns.min_by { |(sx, sy)| (sx - human.tile[0]).abs + (sy - human.tile[1]).abs }
      @human_respawns[@zone_name] << { kit_name: human.kit_name, tile: home, at_frame: @frame + delay }
      humans.delete(human)
    end
  end
end
