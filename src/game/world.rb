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
      attack_started special_started attack_hit damage_dealt actor_died dodged telegraph
      zone_entered possession_changed pack_wiped pack_respawned projectile_fired pack_mark_set
      drop_spawned drop_picked_up drop_decayed banked carried_lost taunted
      corpse_loaded corpse_looted
    ].freeze

    TRANSITIONS = { world: %i[nest_respawn], nest_respawn: %i[world] }.freeze

    HOME_ZONE = "nest".freeze # fiction-pending name (world bible integration = owner call)

    attr_reader :bus, :pack, :feel, :states, :frame, :camera, :zone_name, :rng

    def initialize(data, seed: 0)
      @data = data
      @display = data["display"]
      @balance = data["balance/combat"]
      @death = data["balance/death"]
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
      @impacts = []
      @last_damaged_target = nil
      @corpses = Hash.new { |h, k| h[k] = [] }
      @drops = Hash.new { |h, k| h[k] = [] }
      @corpse_loads = Hash.new { |h, k| h[k] = [] }
      @expiry_flashes = Hash.new { |h, k| h[k] = [] }
      @corpse_serial = 0
      @taunt_pulses = []
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
    def impacts = @impacts
    def corpses = @corpses[@zone_name]
    def drops = @drops[@zone_name]
    def corpse_loads(zone = @zone_name) = @corpse_loads[zone]
    def expiry_flashes(zone = @zone_name) = @expiry_flashes[zone]
    def marked_target = @pack.mark
    def taunt_pulses = @taunt_pulses

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
      actors.reject { |actor| actor.equal?(creature) }
            .flat_map { |actor| [actor.tile, actor.reserved_tile] }
            .compact
            .uniq
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

    def set_mark(source)
      return false unless source.equal?(possessed)
      range = @balance[:pack][:mark_range_tiles]
      foes = hostiles_for(source)
      preferred = @last_damaged_target
      target =
        if preferred && foes.include?(preferred) &&
           tile_distance(source.tile, preferred.tile) <= range
          preferred
        else
          foes.each_with_index
              .select { |foe, _| tile_distance(source.tile, foe.tile) <= range }
              .min_by { |foe, index| [tile_distance(source.tile, foe.tile), index] }
              &.first
        end
      return false unless target
      @pack.mark!(target)
      @bus.emit(:pack_mark_set, target:)
      true
    end

    # One shared interaction path (D0): pickup first, bank second — decided
    # so a drop ON the station tile takes two presses, deterministically.
    # Possessed-only — which body holds the value is a player decision.
    def interact(source)
      return false unless source.equal?(possessed)
      return false if source.dead? || source.staggered? || source.attack_state != :idle
      drop = drops.find { |d| d[:tile] == source.tile }
      if drop
        drops.delete(drop)
        source.pick_up(drop[:amount])
        @bus.emit(:drop_picked_up, actor: source, amount: drop[:amount], carried: source.carried)
        return true
      end
      station = map.station_at(*source.tile)
      return false unless station && station[:type] == "bank" && source.carried.positive?
      amount = source.drain_carried!
      @pack.bank!(amount)
      @bus.emit(:banked, actor: source, amount:, banked: @pack.banked)
      true
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
      validate_mark
      @pack.living.each { |m| @ai.tick(m, self) unless m.equal?(possessed) }
      humans.each { |h| emit_telegraph_edge(h); @ai.tick(h, self) }

      check_transition
      tick_impacts
      tick_taunt_pulses
      resolve_attacks
      tick_projectiles
      tick_drops
      tick_corpse_loads
      tick_expiry_flashes
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
      can_swap = @pack.living.length > 1 &&
                 !possessed.staggered? &&
                 !possessed.special_committed?
      if down && !@swap_was_down && can_swap
        from = possessed
        @pack.swap_next!
        @controller.rearm!(input)
        @bus.emit(:possession_changed, from:, to: possessed, forced: false)
      end
      @swap_was_down = down
    end

    # Active actions resolve from their own config. Tile order is fixed and
    # every victim may be hit once per action.
    #
    # Dev-of-record call: a husk killed earlier in this same frame still
    # lands its active swing (uninterruptible windup + iteration order =
    # a deterministic simultaneous trade). Killing blows don't erase a blow
    # already in flight — that's the pressure husks are for.
    def resolve_attacks
      actors.each do |attacker|
        next unless attacker.action_active?
        cfg = attacker.action_config
        case cfg[:arc]
        when "projectile"
          launch_projectile(attacker, cfg) if attacker.action_can_trigger?
        when "dash"
          resolve_dash_action(attacker, cfg)
        when "volley"
          launch_volley(attacker, cfg) if attacker.action_can_trigger?
        else
          resolve_tile_action(attacker, cfg)
        end
      end
    end

    def resolve_tile_action(attacker, cfg)
      resolve_taunt_pulse(attacker, cfg) if cfg[:taunt] && attacker.action_can_trigger?
      foes = hostiles_for(attacker)
      attacker.action_tiles.each do |tile|
        victim = foes.find { |foe| !foe.dead? && foe.tile == tile }
        next unless victim && attacker.action_can_hit?(victim)
        apply_action_hit(attacker, victim, cfg)
      end
    end

    # Taunt (A0.6): a ring-arc special carrying a taunt block pulses ONCE at
    # active entry — the one-shot flag is unused by ring damage (per-victim
    # dedup), so consuming it here cannot affect the hits. Wider than the
    # ring: every living hostile within range_tiles is re-targeted, aggro
    # gate bypassed while locked. The pulse fires whether or not the ring
    # connects — a whiffed cast still burns the full exhaust (the cost model).
    def resolve_taunt_pulse(attacker, cfg)
      attacker.action_triggered!
      t = cfg[:taunt]
      victims = hostiles_for(attacker).select do |foe|
        !foe.dead? && tile_distance(attacker.tile, foe.tile) <= t[:range_tiles]
      end
      victims.each { |v| v.taunt!(attacker, t[:duration_frames]) }
      @taunt_pulses << { tile: attacker.tile, frames_left: t[:pulse_frames],
                         pulse_frames: t[:pulse_frames], range_tiles: t[:range_tiles] }
      @bus.emit(:taunted, actor: attacker, victims: victims.length)
    end

    # Cosmetic only — the sim never reads these. Counted in tick_world so
    # hitstop and the wipe veil pause them like impacts.
    def tick_taunt_pulses
      @taunt_pulses.each { |p| p[:frames_left] -= 1 }
      @taunt_pulses.reject! { |p| p[:frames_left] <= 0 }
    end

    def resolve_dash_action(attacker, cfg)
      return unless attacker.action_can_trigger?
      attacker.action_triggered!
      foes = hostiles_for(attacker)
      attacker.action_tiles.each do |tile|
        victim = foes.find { |foe| !foe.dead? && foe.tile == tile }
        next unless victim && attacker.action_can_hit?(victim)
        apply_action_hit(attacker, victim, cfg)
      end
    end

    def apply_action_hit(attacker, victim, cfg)
      attacker.action_hit!(victim)
      landed = victim.take_hit(damage: cfg[:damage], attacker:,
                               knockback_tiles: cfg[:knockback_tiles],
                               blocked: blocked_for(victim))
      if landed
        victim.stagger!(cfg[:stagger_frames]) if cfg[:stagger_frames]
        victim.interrupt_action! if cfg[:interrupt_windup]
      end
      emit_attack_hit(attacker, victim, landed)
    end

    # A projectile swing "lands" the moment it fires — the shot itself is a
    # new sim object that carries the hit forward. Diagonal facings fly
    # diagonally (grid-faithful: one tile per window on both axes).
    def launch_projectile(attacker, cfg)
      attacker.action_triggered!
      @projectiles << Projectile.new(
        owner: attacker, map:, tile: attacker.tile, dir: attacker.facing,
        damage: cfg[:damage], range_tiles: cfg[:range_tiles],
        frames_per_tile: cfg[:projectile_frames_per_tile],
        knockback_tiles: cfg[:knockback_tiles]
      )
      @bus.emit(:projectile_fired, attacker:)
    end

    def launch_volley(attacker, cfg)
      attacker.action_triggered!
      @impacts << {
        owner: attacker,
        tiles: volley_tiles(attacker.tile, attacker.facing, cfg[:impact_distances]),
        frames_left: cfg[:delay_frames],
        damage: cfg[:damage]
      }
    end

    def volley_tiles(origin, dir, distances)
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

    # Counted only in tick_world, so hitstop pauses delayed impacts while
    # @frame continues advancing. Creation order and tile order are fixed.
    def tick_impacts
      @impacts.each do |impact|
        impact[:frames_left] -= 1
        next if impact[:frames_left].positive?
        foes = hostiles_for(impact[:owner])
        impact[:tiles].each do |tile|
          victim = foes.find { |foe| !foe.dead? && foe.tile == tile }
          next unless victim
          landed = victim.take_hit(damage: impact[:damage], attacker: impact[:owner],
                                   knockback_tiles: 0, blocked: blocked_for(victim))
          emit_attack_hit(impact[:owner], victim, landed)
        end
      end
      @impacts.reject! { |impact| impact[:frames_left] <= 0 }
    end

    # Decay ticks in EVERY zone each sim tick (nest time is real time — the
    # death-economy doc's corpse-term decision, applied to drops): leaving a
    # pile behind to bank is a real cost. Counted only in tick_world, so
    # hitstop and the wipe veil pause decay deterministically.
    def tick_drops
      @drops.each do |zone, list|
        list.each { |d| d[:frames_left] -= 1 }
        list.reject! do |d|
          next false if d[:frames_left].positive?
          @bus.emit(:drop_decayed, zone:, tile: d[:tile], amount: d[:amount])
          true
        end
      end
    end

    # Corpse-load clocks tick in EVERY zone (the tick_drops law: nest time is
    # real time). Counted only in tick_world, so hitstop and the wipe veil
    # pause them deterministically. At term zero the load is destroyed —
    # carried_lost is EXPIRY's event in D1 (actor deliberately absent: the
    # body may be long revived).
    def tick_corpse_loads
      @corpse_loads.each do |zone, list|
        list.each do |c|
          c[:settle_left] -= 1 if c[:settle_left].positive?
          c[:term_left] -= 1
        end
        list.reject! do |c|
          next false if c[:term_left].positive?
          @bus.emit(:carried_lost, amount: c[:amount], tile: c[:tile], zone:)
          release_corpse_record(zone, c[:id])
          @expiry_flashes[zone] << { tile: c[:tile], frames_left: @death[:expiry_flash_frames],
                                     frames: @death[:expiry_flash_frames] }
          true
        end
      end
    end

    def tick_expiry_flashes
      @expiry_flashes.each_value do |list|
        list.each { |f| f[:frames_left] -= 1 }
        list.reject! { |f| f[:frames_left] <= 0 }
      end
    end

    # Sim-owned, event-time (loot + expiry): clear the container link and
    # re-anchor the fade, so a body held at full strength starts fading NOW
    # instead of snapping to invisible (review CF-2). Pure readers everywhere
    # else — the renderer never mutates (taunted_target law).
    def release_corpse_record(zone, container_id)
      rec = @corpses[zone].find { |c| c[:container_id] == container_id }
      return unless rec
      rec.delete(:container_id)
      rec[:at_frame] = @frame
    end

    # Seeded roll (the sim PRNG's first consumer — rolls happen at bus-process
    # time in emit order, so consumption order is replay-deterministic). One
    # drop per tile, always: a kill on an occupied tile merges amounts but
    # KEEPS the first kill's clock — a resetting clock + the 5s rusher
    # respawn would make any camped tile an immortal zero-risk stash.
    def spawn_drop(victim)
      table = victim.kit[:drop_table]
      return unless table
      amount = table[@rng.rand(table.length)]
      decay = @balance[:drops][:decay_frames]
      list = @drops[@zone_name]
      drop = list.find { |d| d[:tile] == victim.tile }
      if drop
        drop[:amount] += amount
      else
        list << { tile: victim.tile, amount:, frames_left: decay, decay_frames: decay }
      end
      @bus.emit(:drop_spawned, tile: victim.tile, amount:)
    end

    # Creation order = resolution order (deterministic). The projectile only
    # reports the victim; damage resolves here from the OWNER's kit, exactly
    # like melee — one law for all combat.
    def tick_projectiles
      @projectiles.each do |p|
        victim = p.tick(hostiles: hostiles_for(p.owner))
        next unless victim
        landed = victim.take_hit(damage: p.damage, attacker: p.owner,
                                 knockback_tiles: p.knockback_tiles,
                                 blocked: blocked_for(victim))
        emit_attack_hit(p.owner, victim, landed)
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

    # Gates are physical terrain: ANY rest on the gate tile carries the pack
    # through — including a knockback shove (dev-of-record call, M2 review
    # finding 3). A blocker punching you through the gate mid-fight is a
    # legal escape and a legal threat; "voluntary moves only" would add
    # hidden state the player can't read.
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
      @impacts = []
      @taunt_pulses = []
      @pack.clear_mark!
      @last_damaged_target = nil
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
      # Release EVERY zone's taunt locks before reviving: a frozen victim in
      # an abandoned zone would otherwise re-lock onto the revived taunter —
      # a lock that "ended" at the taunter's death un-ending (impl review 1).
      @humans.each_value { |list| list.each(&:release_taunt!) }
      @zone_name = HOME_ZONE
      @pack.members.each_with_index { |m, i| m.revive!(map:, tile: map.pack_spawn[i]) }
      enter_zone(HOME_ZONE, map.pack_spawn)
      @bus.emit(:pack_respawned)
    end

    # A respawn DEFERS while its tile is occupied (retries next tick) — the
    # body-blocking invariant holds for every path a creature enters the
    # world by, teleports included (M2 review finding 1: a body parked on
    # the spawn at the respawn frame stacked two creatures on one tile).
    def respawn_due_humans
      occupied = actors.map(&:tile)
      ready, waiting = @human_respawns[@zone_name].partition { |r| r[:at_frame] <= @frame }
      deferred = []
      ready.each do |r|
        if occupied.include?(r[:tile])
          deferred << r
        else
          add_human(@zone_name, r[:kit_name], r[:tile])
          occupied << r[:tile]
        end
      end
      @human_respawns[@zone_name] = waiting + deferred
    end

    def prune_caches
      @flow_cache&.select! { |anchor, _| !anchor.dead? }
      @telegraphing&.select! { |actor, _| !actor.dead? }
      corpses.reject! { |c| @frame - c[:at_frame] > CORPSE_FADE_FRAMES }
    end

    def emit_attack_hit(attacker, victim, landed)
      @last_damaged_target = victim if landed && attacker.equal?(possessed)
      @bus.emit(:attack_hit, attacker:, victim:)
    end

    def validate_mark
      target = marked_target
      return unless target
      leash = @balance[:pack][:mark_leash_tiles]
      @pack.clear_mark! if target.dead? || tile_distance(possessed.tile, target.tile) > leash
    end

    def tile_distance((ax, ay), (bx, by))
      [(bx - ax).abs, (by - ay).abs].max
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

    # The container is sim truth; the serial links it to the cosmetic corpse
    # record so the renderer/prune can hold the body at full strength while
    # loaded (tile+frame is not a key — two same-frame knockback deaths can
    # share a tile). settle_alpha rides the record like decay_frames rides
    # drops: the renderer reads no balance.
    def spawn_corpse_load(actor)
      @corpse_serial += 1
      term = @death[:corpse_term_frames]
      record = { id: @corpse_serial, tile: actor.tile, amount: actor.drain_carried!,
                 term_left: term, term:, settle_left: @death[:loot_settle_frames],
                 settle_alpha: @death[:settle_pip_alpha] }
      @corpse_loads[@zone_name] << record
      corpses.last[:container_id] = @corpse_serial
      @bus.emit(:corpse_loaded, actor:, tile: record[:tile], amount: record[:amount])
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
        spawn_drop(e[:actor])
        # D1: a dying pack body's carried value transfers to a container on
        # its corpse. Term expiry is the permanent-loss tier now.
        spawn_corpse_load(e[:actor]) if e[:actor].faction == :pack && e[:actor].carried.positive?
        @pack.clear_mark! if e[:actor].equal?(marked_target)
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

    # The roster delete comes FIRST: a kit without respawn_frames must still
    # leave the roster on death, or the renderer draws its ghost forever
    # (M2 review finding 2 — latent until someone adds a no-respawn kit).
    def schedule_human_respawn(human)
      humans.delete(human)
      delay = human.kit[:respawn_frames]
      return unless delay
      spawns = map.enemy_spawns[human.kit_name] || [human.tile]
      home = spawns.min_by { |(sx, sy)| (sx - human.tile[0]).abs + (sy - human.tile[1]).abs }
      @human_respawns[@zone_name] << { kit_name: human.kit_name, tile: home, at_frame: @frame + delay }
    end
  end
end
