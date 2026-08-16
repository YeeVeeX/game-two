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
require "game/fight_ledger"

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
      corpse_loaded corpse_looted fight_resolved
      human_retargeted human_leashed human_respawned
      inscribed banked_spent tribute_paid body_regrown body_dissolved mark_consumed vessel_kept
      seal_breached home_rehomed respawn_telegraphed
      challenger_engaged challenger_chant_started chant_interrupted vessel_seized seizure_ended
      inscription_burned
    ].freeze

    TRANSITIONS = { world: %i[nest_respawn], nest_respawn: %i[world] }.freeze

    HOME_ZONE = "nest".freeze # the INITIAL home only — @home_zone advances (v12)

    attr_reader :bus, :pack, :feel, :states, :frame, :camera, :zone_name, :rng

    def initialize(data, seed: 0)
      @data = data
      @display = data["display"]
      @balance = data["balance/combat"]
      @death = data["balance/death"]
      @threat = data["balance/threat"]
      @economy = data["balance/economy"]
      @rng = Random.new(seed)
      # Respawn scatter draws from its OWN derived stream (v14): the
      # telegraph moves consumption ~120f earlier, and on the shared
      # stream that would reorder every drop roll behind it. Salt is
      # stream derivation (determinism plumbing), not balance.
      @respawn_rng = Random.new(seed ^ RESPAWN_STREAM_SALT)
      @bus = Core::EventBus.new.register(*EVENTS)
      @states = Core::StateStack.new(initial: :world, transitions: TRANSITIONS)
      @feel = Feel.new(@balance[:feel])
      @frame = 0
      @respawn_timer = 0
      # v15 banner FIFO (panel fold W6): zone banners + court stamps share
      # the slot as QUEUED entries {text_key:, fallback:, color:,
      # frames_left:} — keys, never locale-baked text (locale-at-render
      # law). The active entry plays out; queued follow; nothing is eaten.
      @banner_queue = []
      @called_stamped = false
      # v16 (c) decision 4: located stamps also mark the WORLD — floor seal
      # records {zone:, tile:, frames_left:, total:} on the banner clock
      # (the act dwells with its stamp). Renderer is a pure reader.
      @seal_marks = []
      @station_cue = nil
      @breach_line = nil
      @breached = {}
      @home_zone = HOME_ZONE
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
      @kill_pops = []
      @pop_frames = @balance[:feel][:pop_frames]
      @controller = PossessedController.new
      @ai = AiController.new
      @swap_was_down = false
      @rearm_needed = false
      load_zones
      spawn_pack
      # First-possession registry (v14): cosmetic sim state the sim never
      # reads (taunt_pulses precedent) — the controls overlay derives its
      # one-time pulse from it as a pure function of world state, so both
      # gate replays render bit-equal strips (draw-side accumulation would
      # not be tick-locked). Seeded with the initial body at frame 0;
      # wire_events keeps it fed on every possession change.
      @kit_first_possessed = { @pack.possessed.kit_name => 0 }
      wire_events
      # Constructed after wire_events ON PURPOSE: World's actor_died handler
      # must queue corpse_loaded/pack_wiped ahead of the ledger's handlers in
      # the same flush (the wipe-ordering pin, spec M6).
      @fight_ledger = FightLedger.new(@bus, world: self,
                                      config: data["balance/ledger"])
      enter_zone(@home_zone, map.pack_spawn)
    end

    def map = @zones.fetch(@zone_name)

    # Focused-scene start (v15 harness `start` param): begin the session in
    # a named zone. Same arrival path as any gate crossing — enter_zone owns
    # the banner/home/leash law. No in-game system calls this.
    def start_in(zone)
      raise ArgumentError, "unknown zone #{zone}" unless @zones.key?(zone)
      enter_zone(zone, @zones.fetch(zone).pack_spawn)
    end
    def humans = @humans[@zone_name]
    def possessed = @pack.possessed
    def banner? = !active_banner.nil?
    def active_banner = @banner_queue.first
    def actors = (@pack.members + humans).reject(&:dead?)
    def projectiles = @projectiles
    def impacts = @impacts
    def corpses = @corpses[@zone_name]
    def drops = @drops[@zone_name]
    # Non-autovivifying: the renderer reads these every draw and a default-proc
    # index would insert keys into sim state from the draw path (pure-reader law).
    def corpse_loads(zone = @zone_name) = @corpse_loads.fetch(zone) { [] }
    def expiry_flashes(zone = @zone_name) = @expiry_flashes.fetch(zone) { [] }
    def ledger_beat = @fight_ledger.beat
    def total_stranded = @corpse_loads.values.sum { |list| list.sum { |c| c[:amount] } }
    def marked_target = @pack.mark
    def taunt_pulses = @taunt_pulses
    def kill_pops = @kill_pops

    # Floor seal marks of the CURRENT zone (v16 c): court acts stamped at
    # their event tile. Zone-stamped, never cleared on transition — a writ
    # outlives the walk through the gate it opened; the filter keeps other
    # zones' coordinates out of this zone's draw.
    def seal_marks = @seal_marks.select { |m| m[:zone] == @zone_name }

    # Active respawn tells of the CURRENT zone, for the renderer (v14).
    # Non-autovivifying fetch: the draw path must never insert zone keys
    # into sim state (the corpse_loads pure-reader law). frames_left
    # clamps at 0 — a materialize-deferred tell holds at full intensity.
    def respawn_tells
      lead = @threat[:telegraph_frames]
      @human_respawns.fetch(@zone_name) { [] }
                     .select { |r| r[:pinned_tile] }
                     .map do |r|
        { tile: r[:pinned_tile], kit_name: r[:kit_name],
          frames_left: [r[:at_frame] - @frame, 0].max, total: lead }
      end
    end
    def station_cue = @station_cue
    def breach_line = @breach_line

    # Session-scoped and wipe-proof BY DESIGN: wipes never close the door —
    # that is the arc. Only a fresh World (restart) re-seals.
    def breached?(zone, tile) = @breached.key?([zone, tile])

    # kit_name => first frame that kind was possessed (v14 overlay pulse).
    def kit_first_possessed = @kit_first_possessed

    # Renderer-facing price reader (renderer computes nothing): what THIS
    # station charges right now. Bank has no price (nil).
    def station_price(station)
      case station[:type]
      when "altar" then @economy[:inscribe_cost]
      when "vat"
        @economy[:regrow_cost] * @pack.members.count(&:dead?) +
          @economy[:heal_cost_per_body] * @pack.living.count { |m| m.hp < m.max_hp }
      when "seal"
        # A spent seal shows no price — the toll line is the discovery
        # mechanism while sealed, and noise once the way stands open.
        breached?(@zone_name, station[:opens]) ? nil : @economy.fetch(station[:price].to_sym)
      end
    end

    def tick(input)
      if @feel.hitstop?
        @feel.tick
        @bus.process
        @frame += 1
        return
      end

      if (b = @banner_queue.first)
        # v16 (c): a located stamp lands its floor mark the frame its
        # banner ACTIVATES — mark and stamp share one clock from birth
        # (decision 4: the mark dwells WITH the banner; adversarial review
        # caught the enqueue-time anchor draining marks behind a queued
        # stamp). An evicted queued stamp never stamps the floor at all.
        stamp_floor!(b[:at]) if b[:at] && b[:frames_left] == b[:total]
        b[:frames_left] -= 1
        @banner_queue.shift if b[:frames_left] <= 0
      end
      # Seal marks share the banner clock (not tick_world) so a mark dwells
      # in lockstep with its stamp — both pause under hitstop above.
      @seal_marks.each { |m| m[:frames_left] -= 1 }
      @seal_marks.reject! { |m| m[:frames_left] <= 0 }
      @station_cue = nil if @station_cue && (@station_cue[:frames_left] -= 1) <= 0
      @breach_line = nil if @breach_line && (@breach_line[:frames_left] -= 1) <= 0

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

    # A2 position pressure: per focus-target, the nearest engaged_cap_per_target
    # humans fight; the rest PRESSURE (follow, block, never swing). Sorting is
    # (distance, roster index) -- deterministic. Taunt-bound humans partition
    # like everyone else: taunt locks attention, not the right to swing.
    def partition_pressure
      cap = @threat[:engaged_cap_per_target]
      @pressure_roles = {}
      humans.reject(&:dead?).group_by(&:focus).each do |target, group|
        next unless target
        group.each_with_index
             .sort_by { |h, i| [tile_distance(h.tile, target.tile), i] }
             .each_with_index { |(h, _), rank| @pressure_roles[h] = rank < cap ? :engaged : :pressuring }
      end
    end

    def pressure_role(creature) = (@pressure_roles || {}).fetch(creature, :engaged)

    # Ring slots mirror surround_slot one ring further out: the Chebyshev ring at
    # pressure_ring_tiles, claimed per target per tick, fixed perimeter order.
    def pressure_slot(attacker, target)
      claims = (@pressure_claims[target] ||= {})
      already = claims.find { |_, who| who.equal?(attacker) }
      return already[0] if already
      r = @threat[:pressure_ring_tiles]
      tx, ty = target.tile
      ring = (-r..r).flat_map { |d| [[tx + d, ty - r], [tx + d, ty + r], [tx - r, ty + d], [tx + r, ty + d]] }
                    .uniq
      slot = ring.find { |t| map.passable?(*t) && !claims.key?(t) }
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

    def threat_config = @threat

    # v15 seized walk (controllers call this — view API): the named flesh
    # goes to the voice on the EXISTING flow_to moving-anchor cache.
    # Routes through creature.step, so windup/active/stagger gates hold —
    # fighting back drags your feet (intended depth, spec fold 4).
    # Adjacent = arrived: it answered its name; it waits.
    def seized_step(creature)
      seizer = creature.seized_by
      return unless seizer
      return if creature.moving?
      return if tile_distance(creature.tile, seizer.tile) <= 1
      blocked = blocked_for(creature)
      dir = flow_to(seizer).downhill_from(*creature.tile, blocked:)
      return unless dir
      creature.face(dir)
      creature.step(dir[0], dir[1], blocked:)
    end

    # v11 density: pockets = connected groups of living humans in the
    # current zone within join_radius_tiles of each other (chain distance,
    # Chebyshev). Public on purpose — the respawn anchor path, telemetry,
    # and tests must all read the SAME computation. Roster order in, so
    # grouping is deterministic.
    def density_pockets
      radius = @threat[:density][:join_radius_tiles]
      alive = humans.reject(&:dead?)
      seen = {}
      pockets = []
      alive.each do |h|
        next if seen[h]
        group = [h]
        seen[h] = true
        queue = [h]
        until queue.empty?
          current = queue.shift
          alive.each do |other|
            next if seen[other] || tile_distance(current.tile, other.tile) > radius
            seen[other] = true
            group << other
            queue << other
          end
        end
        pockets << group
      end
      pockets
    end

    # Beachhead (A2): arrival is not an ambush. Blocks ACQUISITION only —
    # taunt/anchor bind first in the chain, and a human the pack has attacked
    # is waived for life (you don't get the doormat's protection while
    # swinging from it).
    def beachhead_shields?(human, target)
      return false if human.beachhead_waived?
      radius = @threat[:beachhead_tiles]
      arrival_tiles_for(@zone_name).any? { |a| tile_distance(target.tile, a) <= radius }
    end

    def arrival_tiles_for(zone) = @arrivals.fetch(zone) { [] }

    def gate_distance(tile)
      field = @gate_fields[@zone_name]
      field ? field.distance(*tile) : Float::INFINITY
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

    # Home fields are keyed by TILE and never invalidated inside a zone —
    # homes don't move. Cleared with the flow cache on zone change. Keyed by
    # the EFFECTIVE home (v13 guard-scope), so shifted and true anchors
    # coexist deterministically.
    def flow_home(creature)
      @home_fields ||= {}
      anchor = leash_home_tile(creature)
      @home_fields[anchor] ||= FlowField.new(map).tap { |f| f.recompute!(anchor) }
    end

    # v13 guard-scope (fairness only, spec §4): a leashing wanderer whose
    # home sits inside the corpse guard of the NEWEST live corpse load
    # re-homes to the nearest walkable tile outside the radius along the
    # away ray — live humans cannot camp the corpse run. Engaged humans
    # never read this (leash runs no-focus only); same anchor source as
    # the respawn guard (corpse_loads, not visual corpses).
    def leash_home_tile(creature)
      home = creature.home_tile
      load = corpse_loads.last
      return home unless load
      guard = @threat[:density][:corpse_guard_tiles]
      return home if tile_distance(load[:tile], home) > guard
      shifted_home(home, load[:tile], guard)
    end

    # One :human_leashed per episode: the flag arms on emit, disarms when the
    # human regains a focus (reset_leash! call sites) — track via leash_frames
    # equality: emit exactly when the counter crosses the linger threshold.
    # steered (v13): this episode's destination was guard-shifted.
    def human_leashed!(creature)
      return unless creature.leash_frames == @threat[:leash_linger_frames]
      @bus.emit(:human_leashed, actor: creature, tile: creature.tile, hp: creature.hp,
                steered: leash_home_tile(creature) != creature.home_tile)
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
      # D1 recovery: settle-gated, full transfer, creation order on stacked
      # tiles (a settling container falls through — deterministic skip). A
      # drop on the tile won the press above: the D0 two-press rule extended.
      load = corpse_loads.find { |c| c[:tile] == source.tile && c[:settle_left] <= 0 }
      if load
        corpse_loads.delete(load)
        release_corpse_record(@zone_name, load[:id])
        source.pick_up(load[:amount])
        @bus.emit(:corpse_looted, actor: source, tile: load[:tile],
                  amount: load[:amount], carried: source.carried,
                  term_left: load[:term_left], term: load[:term])
        return true
      end
      station = map.station_at(*source.tile)
      return false unless station
      case station[:type]
      when "bank"  then interact_bank(source)
      when "altar" then interact_altar(source)
      when "vat"   then interact_vat(source)
      when "seal"  then interact_seal(source, station)
      else false
      end
    end

    private

    def tick_world(input)
      @slot_claims = {}
      @pressure_claims = {}
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
      assign_human_focus
      partition_pressure
      tick_challengers
      # A chanting challenger STANDS — pronunciation is stillness (his AI
      # tick is the only thing suspended; timers/attack-state still ran).
      humans.each { |h| emit_telegraph_edge(h); @ai.tick(h, self) unless h.chanting? }

      check_transition
      tick_impacts
      tick_taunt_pulses
      tick_kill_pops
      resolve_attacks
      tick_projectiles
      # AFTER every damage source on purpose: a body killed this frame ends
      # its seizure THIS frame (why=:died — the zero-frame seizure is legal
      # and ordered; spec same-frame race).
      tick_seizures
      tick_drops
      tick_corpse_loads
      tick_expiry_flashes
      @fight_ledger.tick
      telegraph_due_humans
      respawn_due_humans
      prune_caches
    end

    def assign_human_focus
      humans.each do |h|
        next if h.dead?
        target, cause = @ai.select_target(h, self)
        if target && !target.equal?(h.focus)
          @bus.emit(:human_retargeted, actor: h, from: h.focus, to: target, cause:)
          # Cue-keyed causes only (spec section 5): taunt/anchor turns carry
          # their own tells (underline, pulse) and have no cue color — but
          # every turn invalidates a live cue, or a stale cause would explain
          # a turn it did not drive (impl review, Codex finding 2).
          if %i[hate lowhp proximity].include?(cause)
            h.retarget_cue!(cause, @economy[:retarget_cue_frames])
          else
            h.clear_retarget_cue!
          end
        end
        h.focus = target
      end
    end

    # --- v15 the Challenger: chant -> seizure ---------------------------

    # World-driven (the taunt-pulse precedent): creatures hold state, this
    # owns the clock, the interrupt, and every event. Runs BEFORE the
    # human AI loop (a chanting challenger's AI tick is suspended) and
    # after assign_human_focus (the engagement stamp reads focus).
    def tick_challengers
      humans.each do |h|
        next if h.dead?
        seize = h.kit[:seize]
        next unless seize
        h.tick_seize_cooldown unless h.chanting?
        if h.chanting?
          # ANY damage since chant start interrupts — hp comparison covers
          # every source (melee, whirl, volley, projectile) without
          # touching the hit paths. Interrupt buys the room the full
          # cooldown (legible reward).
          if h.hp < h.chant_hp
            h.abort_chant!
            h.seize_cooldown!(seize[:cooldown_frames])
            @bus.emit(:chant_interrupted, actor: h)
            next
          end
          h.tick_chant
          next if h.chanting?
          # Completion: the sentence lands on the body PINNED at chant
          # start (decision 3) — if that body died first, it lands on
          # nothing and the cooldown starts now. On a landed seize the
          # cooldown starts at SEIZURE END instead (spec pacing fold).
          target = h.chant_target
          h.abort_chant!
          if target && !target.dead?
            target.seize!(h, seize[:duration_frames])
            unless @called_stamped
              @called_stamped = true
              enqueue_stamp("challenger.called.line", "THE FLESH IS CALLED")
            end
            @bus.emit(:vessel_seized, actor: h, body: target,
                      frames: seize[:duration_frames])
          else
            h.seize_cooldown!(seize[:cooldown_frames])
          end
          next
        end
        # ONE STANDS: first pack contact, once per session. Deviation from
        # the spec letter recorded: focus on ANY pack body announces him
        # (contact is contact) — waiting for possessed-specific focus
        # could leave his first fight unannounced.
        if !h.engaged_announced? && h.focus && !h.focus.dead? &&
           h.focus.faction == :pack
          h.announce_engaged!
          enqueue_stamp("challenger.stands.line", "ONE STANDS")
          @bus.emit(:challenger_engaged, actor: h)
        end
        next unless h.seize_cooldown.zero?
        next if h.staggered? || h.attack_state != :idle
        # Never chant while his own seizure holds (cooldown starts at
        # seizure END, so this guard is what prevents chant-chaining).
        next if @pack.members.any? { |m| m.seize_active? && m.seizure_seizer.equal?(h) }
        body = possessed
        next if body.dead? || tile_distance(h.tile, body.tile) > seize[:range_tiles]
        h.start_chant!(body, seize[:chant_frames])
        @bus.emit(:challenger_chant_started, actor: h, body:)
      end
    end

    # Exactly-once end sweep (spec): first cause wins, later causes find
    # no state. Runs AFTER every damage source in tick_world so a body
    # killed this frame ends why=:died THIS frame.
    def tick_seizures
      @pack.members.each do |m|
        next unless m.seize_active?
        m.tick_seizure
        if m.dead?
          end_seizure(m, :died)
        elsif m.seizure_seizer.dead?
          end_seizure(m, :slain)
        elsif m.seized_frames.zero?
          end_seizure(m, :expired)
        end
      end
    end

    def end_seizure(body, why)
      # Exactly-once keys on the RAW seizer presence, NOT on seize_active?:
      # at expiry the frame count is already zero (this tick's decrement),
      # so an active?-guard would swallow the :expired event and leave
      # dangling-but-inert state (caught by the expiry test, live).
      seizer = body.seizure_seizer
      return unless seizer
      # v16 (d): the court's claim overrides the vat's — a body that DIES
      # seized burns its god-mark (the one loss the economy cannot
      # refund). Read + burn HERE, in the same sweep that saw the death:
      # corpse bookkeeping rides the later bus flush and the judgment
      # reads marked? whole states later, so burn and wipe-consumption
      # can never double-fire (spec ordering discipline, TDD-enforced).
      if why == :died && body.marked? && seizer.kit[:seizure_burns_inscription]
        body.burn_mark!
        @bus.emit(:inscription_burned, body:, at: body.tile)
        enqueue_stamp("stamp.mark_void", "THE MARK IS VOID", at: body.tile)
        # The expiry-flash is the burn's UNCONDITIONAL channel (spec d):
        # the stamp can wait in the FIFO or be cap-evicted in a wipe arc —
        # the flash on the body tile always lands (review-caught gap).
        @expiry_flashes[@zone_name] << { tile: body.tile,
                                         frames_left: @death[:expiry_flash_frames],
                                         frames: @death[:expiry_flash_frames] }
      end
      body.release_seize!
      if seizer && !seizer.dead? && (cfg = seizer.kit[:seize])
        seizer.seize_cooldown!(cfg[:cooldown_frames])
      end
      @bus.emit(:seizure_ended, body:, why:)
    end

    def abort_all_chants!
      @humans.each_value do |list|
        list.each do |h|
          next unless h.chanting?
          h.abort_chant!
          h.seize_cooldown!(h.kit[:seize][:cooldown_frames]) if h.kit[:seize]
        end
      end
    end

    # Court stamps + zone banners share one FIFO slot. Cap applies to the
    # QUEUE only — the active entry is never dropped; past the cap the
    # oldest QUEUED entry yields (display key banner_queue_max).
    def enqueue_banner(text_key:, fallback:, color:, frames:, at: nil)
      cap = @display.fetch(:banner_queue_max, 2)
      @banner_queue.delete_at(1) while @banner_queue.length - 1 >= cap
      # total: feeds the renderer's delivery clock (v16 c scale-in age);
      # at: is the tile locus of a located stamp (floor mark on activation).
      @banner_queue << { text_key:, fallback:, color:, frames_left: frames,
                         total: frames, at: }
    end

    # A stamp with a tile locus (seal breach, mark void, term paid) also
    # lands a floor seal mark at the event tile (v16 c, decision 4) — the
    # mark lands when the stamp ACTIVATES (tick), never at enqueue.
    def enqueue_stamp(key, fallback, at: nil)
      enqueue_banner(text_key: key, fallback:, color: :gold, at:,
                     frames: @display.fetch(:stamp_banner_frames, 150))
    end

    # frames: lets a mark ride its companion beat's own window (the breach
    # writ line runs breach_banner_frames — data may retune them apart).
    def stamp_floor!(tile, frames: nil)
      total = frames || @display.fetch(:stamp_banner_frames, 150)
      @seal_marks << { zone: @zone_name, tile:, frames_left: total, total: }
    end

    # Tab swap: rising edge only, world-level (the controller mask handles
    # every OTHER action; swap itself must not autorepeat while held).
    # Refused while the possessed is staggered — otherwise an instant Tab
    # after a forced swap hands you an unstaggered third body and the
    # death penalty never lands (law 2).
    def handle_swap(input)
      down = input.down?(:swap)
      # v15 seized exemption (Codex pass-2 CONFIRMED defect): while the
      # possessed is seized, Tab ALWAYS works — a crew hit staggering the
      # seized body must not trap the echo inside it (the ratified
      # fairness ladder). Scoped to seized-only so law 2's forced-swap
      # stagger hole stays closed.
      can_swap = @pack.living.length > 1 &&
                 (possessed.seized_by ||
                  (!possessed.staggered? && !possessed.special_committed?))
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
      resolve_taunt_pulse(attacker, cfg) if cfg[:challenge] && attacker.action_can_trigger?
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
      t = cfg[:challenge]
      # Data ships the cause as a String; the sim speaks Symbols (Codex fold).
      cause = (t[:cause] || "taunt").to_sym
      victims = hostiles_for(attacker).select do |foe|
        !foe.dead? && tile_distance(attacker.tile, foe.tile) <= t[:range_tiles]
      end
      victims.each { |v| v.taunt!(attacker, t[:duration_frames], cause:) }
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

    # v16 (e): pops age in tick_world only — hitstop and the wipe veil pause
    # them like impacts (the tick_drops law). Renderer is a pure reader.
    def tick_kill_pops
      @kill_pops.each { |p| p[:frames_left] -= 1 }
      @kill_pops.reject! { |p| p[:frames_left] <= 0 }
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

    # Seeded roll (rolls happen at bus-process time in emit order, AFTER the
    # tick_world scatter picks — consumption order is replay-deterministic).
    # One drop per tile, always: a kill on an occupied tile merges amounts
    # but KEEPS the first kill's clock — a resetting clock + the 5s rusher
    # respawn would make any camped tile an immortal zero-risk stash. The
    # merge also keeps the band: band is a function of tile, so a same-tile
    # kill can never disagree with the record it merges into (v11 rider).
    def spawn_drop(victim)
      table = victim.kit[:drop_table]
      return unless table
      amount = (table[@rng.rand(table.length)] * gradient_multiplier(victim.tile)).round
      decay = @balance[:drops][:decay_frames]
      list = @drops[@zone_name]
      drop = list.find { |d| d[:tile] == victim.tile }
      if drop
        drop[:amount] += amount
      else
        list << { tile: victim.tile, amount:, frames_left: decay, decay_frames: decay,
                  band: gradient_band(victim.tile) }
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
      # v12: a sealed door is not a gate until its toll is paid.
      return if t[:sealed] && !breached?(@zone_name, t[:at])
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
      # v15: the whole pack teleports through gates (arrival_tiles), so a
      # seized body would cross zones with dangling state — seizures end
      # and every chant aborts BEFORE the move (spec lifecycle fold i).
      @pack.members.each { |m| end_seizure(m, :zone_left) if m.seize_active? }
      abort_all_chants!
      @zone_name = name
      @flow_cache = {}
      @home_fields = {}
      @projectiles = []
      @impacts = []
      @taunt_pulses = []
      @kill_pops = []
      @pack.clear_mark!
      @last_damaged_target = nil
      # Cross-zone leash resolves as snap-home: only the current zone ticks, so
      # "they walked home while you were away" lands as relocation with KEPT hp
      # (frozen-zone law; recorded plan deviation 1).
      @humans[name].each do |h|
        h.focus = nil
        next if h.dead?
        if h.tile != h.home_tile
          h.rebind(map: @zones.fetch(name), tile: h.home_tile)
          @bus.emit(:human_leashed, actor: h, tile: h.home_tile, hp: h.hp)
        end
        h.reset_leash!
      end
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
      enqueue_banner(text_key: "zone.#{name}.display_name",
                     fallback: map.display_name, color: :banner,
                     frames: @display[:zone_banner_frames])
      @bus.emit(:zone_entered, zone: name)
      # v12: home = the last hub entered, session-only. Wipe respawn and vat
      # regrowth read @home_zone — the arc advances the pack's anchor.
      if map.hub && name != @home_zone
        @home_zone = name
        @bus.emit(:home_rehomed, zone: name)
      end
    end

    def load_zones
      names = @data.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
      names.each { |n| @zones[n] = Core::TileMap.new(@data["zones/#{n}"]) }
      @arrivals = Hash.new { |h, k| h[k] = [] }
      @zones.each_value do |zmap|
        zmap.transitions.each { |t| @arrivals[t[:to]] << t[:spawn] }
      end
      # Gate fields anchor on the zone's DECLARED gradient_anchor when it has
      # one — arrival-list order follows sorted zone keys, so adding a zone
      # would otherwise silently re-anchor a neighbor's whole band map (v12
      # review-verified trap). Fallback = first arrival, today's behavior.
      @gate_fields = {}
      @zones.each do |zone, zmap|
        anchor = zmap.gradient_anchor ||
                 (@arrivals.key?(zone) ? @arrivals[zone].first : nil)
        next unless anchor
        f = FlowField.new(zmap)
        f.recompute!(anchor)
        @gate_fields[zone] = f
      end
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
    # Returns the creature (v11: respawn_due_humans emits it as the
    # :human_respawned actor — Array#<< would hand back the whole roster).
    def add_human(zone, kit_name, tile)
      kit = @balance[:kits].fetch(kit_name.to_sym)
      @human_serial ||= Hash.new(0)
      serial = @human_serial[zone]
      @human_serial[zone] += 1
      creature = Creature.new(bus: @bus, kit:, kit_name: kit_name.to_sym,
                              map: @zones[zone], tile:, faction: :human,
                              name: "#{kit_name}#{serial}")
      @humans[zone] << creature
      creature
    end

    def spawn_pack
      cfg = @balance[:pack]
      home = @zones.fetch(@home_zone)
      @zone_name = @home_zone
      members = cfg[:members].each_with_index.map do |kit_name, i|
        Creature.new(bus: @bus, kit: @balance[:kits].fetch(kit_name.to_sym),
                     kit_name: kit_name.to_sym, map: home, tile: home.pack_spawn[i],
                     faction: :pack, name: kit_name)
      end
      @pack = Pack.new(members:, stagger_frames: cfg[:swap_stagger_frames],
                       initial_kit: cfg[:initial_possessed])
    end

    # --- D1b station verbs (the only banked sinks; spec S2-3) -----------

    def interact_bank(source)
      return false unless source.carried.positive?
      amount = source.drain_carried!
      @pack.bank!(amount)
      @bus.emit(:banked, actor: source, amount:, banked: @pack.banked)
      true
    end

    def interact_altar(source)
      return station_refuse!(source.tile) if source.marked?
      return station_refuse!(source.tile) unless spend_banked(source, @economy[:inscribe_cost], :inscribe)
      source.inscribe_mark!
      @bus.emit(:inscribed, body: source, cost: @economy[:inscribe_cost], banked: @pack.banked)
      station_cue!(:inscribed, source.tile)
      true
    end

    # All-or-nothing full maintenance (spec S3): one price, one decision.
    # Regrowth is a hard rebind onto the home spawn tile (occupancy is soft:
    # only voluntary movement is blocked — same as respawn_pack).
    def interact_vat(source)
      dead = @pack.members.select(&:dead?)
      wounded = @pack.living.select { |m| m.hp < m.max_hp }
      cost = @economy[:regrow_cost] * dead.length +
             @economy[:heal_cost_per_body] * wounded.length
      return station_refuse!(source.tile) if cost.zero?
      return station_refuse!(source.tile) unless spend_banked(source, cost, :tribute)
      home = @zones.fetch(@home_zone)
      dead.each do |m|
        m.revive!(map: home, tile: home.pack_spawn[@pack.members.index(m)])
        @bus.emit(:body_regrown, body: m)
      end
      wounded.each(&:heal_full!)
      @bus.emit(:tribute_paid, cost:, regrown: dead.length,
                healed: wounded.length, banked: @pack.banked)
      station_cue!(:tribute, source.tile)
      true
    end

    # The breach (v12): pay the toll standing at the seal, and the way
    # opens — permanently for the session. One price, one decision (the
    # station law); the beat is LOUD (strongest feel kick + the writ line
    # in the banner slot) because opening the way IS the arc's payoff.
    def interact_seal(source, station)
      opens = station[:opens]
      return false if breached?(@zone_name, opens)
      price = @economy.fetch(station[:price].to_sym)
      return station_refuse!(station[:at]) unless spend_banked(source, price, :breach)
      @breached[[@zone_name, opens]] = true
      @breach_line = { text: station[:line],
                       frames_left: @display[:breach_banner_frames] }
      @feel.on_kill
      @bus.emit(:seal_breached, zone: @zone_name, tile: opens, cost: price)
      # v16 (c): the breach is a located stamp — the court marks the seal
      # fixture, not the gate tile (gold mark on gold floor would vanish).
      # The writ line starts NOW (own slot, no queue), so its mark lands
      # now too, on the writ's own window — lockstep by construction.
      stamp_floor!(station[:at], frames: @display[:breach_banner_frames])
      station_cue!(:breached, station[:at])
    end

    def spend_banked(source, amount, sink)
      return false unless @pack.spend!(amount)
      @bus.emit(:banked_spent, actor: source, amount:, sink:, banked: @pack.banked)
      true
    end

    # The cue pins the fixture tile at transaction time — deriving it from
    # proximity at draw time would let a moving player drag the flash onto a
    # neighboring fixture (impl review, Codex finding 4).
    def station_cue!(kind, tile)
      @station_cue = { kind:, at: tile, frames_left: @display[:station_cue_frames] }
      true
    end

    def station_refuse!(tile)
      station_cue!(:refused, tile)
      false
    end

    # The judgment (D1b, spec S4): marked flesh revives and the mark burns;
    # unmarked dissolves (stays dead-and-regrowable — dissolution IS the
    # absence of revival). Floor: a judgment that would leave nothing
    # returns the body possessed at the wipe — the gods keep you alive to
    # pay. Taunt-release sweep and home re-entry unchanged (impl
    # review 1 law).
    def respawn_pack
      @humans.each_value { |list| list.each(&:release_taunt!) }
      @zone_name = @home_zone
      vessel = @pack.possessed
      floor = @pack.members.none?(&:marked?)
      revived = []
      @pack.members.each_with_index do |m, i|
        if m.marked?
          m.revive!(map:, tile: map.pack_spawn[i])
          m.burn_mark!
          @bus.emit(:mark_consumed, body: m)
          revived << m
        elsif floor && m.equal?(vessel)
          # The kept vessel never emits :body_dissolved — dissolution means
          # staying dead, and the telemetry line counts it as exactly that
          # (impl review, Codex finding 1).
          m.revive!(map:, tile: map.pack_spawn[i])
          @bus.emit(:vessel_kept, body: m)
          revived << m
        else
          @bus.emit(:body_dissolved, body: m)
        end
      end
      clear_unloaded_pack_husks
      snap_possession_after_judgment(revived)
      enter_zone(@home_zone, map.pack_spawn)
      @bus.emit(:pack_respawned)
    end

    # Dissolved flesh leaves no field husk (spec S Presentation-5). Loaded
    # records are D1 pile markers under wipe grace — never touched.
    def clear_unloaded_pack_husks
      @corpses.each_value do |list|
        list.reject! { |c| c[:faction] == :pack && !c[:container_id] }
      end
    end

    def snap_possession_after_judgment(revived)
      return if revived.include?(@pack.possessed)
      from = @pack.possessed
      target = revived.min_by do |m|
        [tile_distance(m.tile, from.tile), @pack.members.index(m)]
      end
      @pack.possess!(target)
      @bus.emit(:possession_changed, from:, to: target, forced: true)
    end

    # v14 telegraph phase 1 (spec Sim 1): records inside their tell window
    # (at_frame - telegraph_frames <= frame < at_frame) pin their landing
    # tile through TODAY'S exact cascade + defer predicates, and the tell
    # fires. A blocked pin stays unpinned and retries next tick (the same
    # law release-time deferral always had, shifted 120f earlier). Sibling
    # pins count as occupied — two tells never share a tile. A record past
    # due and never pinned (veil resume, exhausted window, W5 unpin) is
    # NOT touched here: it releases through the v13 path below.
    def telegraph_due_humans
      records = @human_respawns.fetch(@zone_name) { [] }
      lead = @threat[:telegraph_frames]
      pending = records.select do |r|
        !r[:pinned_tile] && @frame >= r[:at_frame] - lead && @frame < r[:at_frame]
      end
      return if pending.empty?
      occupied = actors.map(&:tile) + records.filter_map { |r| r[:pinned_tile] }
      block = @threat[:respawn_block_tiles]
      guard = @threat[:density][:corpse_guard_tiles]
      pack_tiles = @pack.living.map(&:tile)
      load_tiles = corpse_loads.map { |c| c[:tile] }
      pending.each do |r|
        tile, anchor = respawn_target(r, occupied)
        next if tile.nil? || occupied.include?(tile) ||
                pack_tiles.any? { |t| tile_distance(t, tile) <= block } ||
                load_tiles.any? { |t| tile_distance(t, tile) <= guard }
        r[:pinned_tile] = tile
        r[:pinned_anchor] = anchor
        r[:defer_frames] = 0
        occupied << tile
        @bus.emit(:respawn_telegraphed, tile:, kit_name: r[:kit_name],
                  at_frame: r[:at_frame])
      end
    end

    # v11 density law, split-phase since v14: a PINNED record materializes
    # at its UNCHANGED at_frame on the pinned tile, re-running today's
    # occupied/block/guard checks — blocked defers and the tell persists
    # (standing near a tell delays it: plannable, honest). The tile never
    # re-rolls WHILE told (a moving tell is a lie); past
    # telegraph_defer_unpin_frames of deferral the record UNPINS (W5 —
    # today's recompute could escape a camper, a permanent pin could not)
    # and takes the UNPINNED path: today's release-time law verbatim —
    # choose at release, recompute on defer, re-mass better not worse.
    def respawn_due_humans
      occupied = actors.map(&:tile)
      block = @threat[:respawn_block_tiles]
      guard = @threat[:density][:corpse_guard_tiles]
      pack_tiles = @pack.living.map(&:tile)
      load_tiles = corpse_loads.map { |c| c[:tile] }
      records = @human_respawns[@zone_name]
      pins = records.filter_map { |r| r[:pinned_tile] }
      ready, waiting = records.partition { |r| r[:at_frame] <= @frame }
      deferred = []
      ready.each do |r|
        if r[:pinned_tile]
          tile = r[:pinned_tile]
          if occupied.include?(tile) ||
             pack_tiles.any? { |t| tile_distance(t, tile) <= block } ||
             load_tiles.any? { |t| tile_distance(t, tile) <= guard }
            r[:defer_frames] = (r[:defer_frames] || 0) + 1
            if r[:defer_frames] > @threat[:telegraph_defer_unpin_frames]
              r.delete(:pinned_tile)
              r.delete(:pinned_anchor)
            end
            deferred << r
          else
            creature = add_human(@zone_name, r[:kit_name], tile)
            occupied << tile
            @bus.emit(:human_respawned, actor: creature, tile:,
                      anchor: r[:pinned_anchor])
          end
        else
          tile, anchor = respawn_target(r, occupied + pins)
          if tile.nil? || occupied.include?(tile) || pins.include?(tile) ||
             pack_tiles.any? { |t| tile_distance(t, tile) <= block } ||
             load_tiles.any? { |t| tile_distance(t, tile) <= guard }
            deferred << r
          else
            creature = add_human(@zone_name, r[:kit_name], tile)
            occupied << tile
            @bus.emit(:human_respawned, actor: creature, tile:, anchor:)
          end
        end
      end
      @human_respawns[@zone_name] = waiting + deferred
    end

    def prune_caches
      @flow_cache&.select! { |anchor, _| !anchor.dead? }
      @telegraphing&.select! { |actor, _| !actor.dead? }
      corpses.reject! { |c| !c[:container_id] && @frame - c[:at_frame] > CORPSE_FADE_FRAMES }
    end

    def emit_attack_hit(attacker, victim, landed)
      @last_damaged_target = victim if landed && attacker.equal?(possessed)
      # kind/landed (v13): stamped at EMIT time — sim-exact even if the
      # action state transitions before the bus processes.
      @bus.emit(:attack_hit, attacker:, victim:,
                kind: attacker.current_action, landed:)
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

    # Deeper = richer (A2 gradient): multiplier bands over gate distance,
    # from zone data. Zones without a gradient (nest) multiply by 1.
    def gradient_multiplier(tile)
      bands = map.drop_gradient
      return 1.0 unless bands
      bands[gradient_band(tile)].last
    end

    # The band INDEX for a tile — one lookup law for the multiplier, the
    # drop-record stamp (v11 rider), and telemetry. No gradient -> band 0.
    def gradient_band(tile)
      bands = map.drop_gradient
      return 0 unless bands
      d = gate_distance(tile)
      bands.rindex { |(min, _)| d >= min } || 0
    end

    # A body stays where it fell and fades (vision critique: kills that
    # vanish erase the fight's history). Records, not creatures — the sim
    # never reads them; only renderer/tests do. Cap guards the roster.
    CORPSE_FADE_FRAMES = 600
    CORPSE_CAP = 40

    # Respawn-stream derivation salt (v14) — determinism plumbing like the
    # corpse constants above, not a tunable.
    RESPAWN_STREAM_SALT = 0x52455350

    # Returns the record it appended, or nil when that record was itself the
    # cap-eviction victim (every other record linked) — the caller must stamp
    # THIS identity, never corpses.last, or a foreign container's link gets
    # clobbered (impl review fold 3).
    def leave_corpse(actor)
      list = corpses
      record = { tile: actor.tile, x: actor.x, y: actor.y,
                 faction: actor.faction, at_frame: @frame }
      list << record
      if list.length > CORPSE_CAP
        evict = list.index { |c| !c[:container_id] }
        list.delete_at(evict) if evict
      end
      list.any? { |c| c.equal?(record) } ? record : nil
    end

    # The container is sim truth; the serial links it to the cosmetic corpse
    # record so the renderer/prune can hold the body at full strength while
    # loaded (tile+frame is not a key — two same-frame knockback deaths can
    # share a tile). settle_alpha rides the record like decay_frames rides
    # drops: the renderer reads no balance.
    def spawn_corpse_load(actor, corpse_record)
      @corpse_serial += 1
      term = @death[:corpse_term_frames]
      record = { id: @corpse_serial, tile: actor.tile, amount: actor.drain_carried!,
                 term_left: term, term:, settle_left: @death[:loot_settle_frames],
                 settle_alpha: @death[:settle_pip_alpha] }
      @corpse_loads[@zone_name] << record
      corpse_record[:container_id] = @corpse_serial if corpse_record
      @bus.emit(:corpse_loaded, actor:, tile: record[:tile], amount: record[:amount])
    end

    # Feel is scoped to the possessed body (law 5): its fights hitstop and
    # shake; ally/AI-vs-AI hits emit events only — the world never freezes
    # for a fight the player isn't in.
    def wire_events
      # Covers voluntary swaps, forced death-swaps, and judgment snaps in
      # one seam — every path emits :possession_changed. First time per
      # kind only (||=); bus FIFO keeps the stamp deterministic.
      @bus.subscribe(:possession_changed) do |e|
        @kit_first_possessed[e[:to].kit_name] ||= @frame
      end

      @bus.subscribe(:attack_hit) do |e|
        if e[:victim].equal?(possessed)
          @feel.on_player_hit
        elsif e[:attacker].equal?(possessed)
          @feel.on_hit
        end
      end

      @bus.subscribe(:actor_died) do |e|
        corpse_record = leave_corpse(e[:actor])
        spawn_drop(e[:actor])
        # D1: a dying pack body's carried value transfers to a container on
        # its corpse. Term expiry is the permanent-loss tier now.
        if e[:actor].faction == :pack && e[:actor].carried.positive?
          spawn_corpse_load(e[:actor], corpse_record)
        end
        @pack.clear_mark! if e[:actor].equal?(marked_target)
        # v16 (e): every death POPS — transient render record, integer phase
        # seeded by (tile, frame) so replays are byte-identical.
        @kill_pops << { tile: e[:actor].tile, frames_left: @pop_frames,
                        pop_frames: @pop_frames,
                        phase: (e[:actor].tile[0] * 31 + e[:actor].tile[1] * 17 + @frame) % 997 }
        if e[:faction] == :human
          @feel.on_kill if e[:killer].equal?(possessed)
          # v15: the challenger's death is a court event — the term-looter
          # finally pays the term's price (canon-exact; Codex pass-2
          # replaced the NAME IS STRUCK draft).
          if e[:actor].kit[:seize]
            enqueue_stamp("challenger.term.line", "THE TERM IS PAID",
                          at: e[:actor].tile)
          end
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
        # D1 wipe grace: the run back must always be possible — every
        # container's remaining term rises to at least the grace floor.
        # (The grace covers the RUN BACK, not the veil: terms are frozen
        # during nest_respawn and the veil is only 90 frames — review CF-6.)
        grace = @death[:wipe_grace_frames]
        @corpse_loads.each_value do |list|
          list.each { |c| c[:term_left] = [c[:term_left], grace].max }
        end
        # v15: chants + seizures clear AT :nest_respawn ENTRY, not at
        # respawn — the veil bypasses tick_world, so a chant aborted only
        # in respawn_pack would freeze mid-count under it (Codex pass-2).
        # Seizures on dead bodies already ended why=:died this frame; the
        # sweep is the idempotent safety net.
        @pack.members.each { |m| end_seizure(m, :wiped) if m.seize_active? }
        abort_all_chants!
        @respawn_timer = @balance[:respawn_frames]
        @states.transition_to(:nest_respawn)
      end
    end

    # The roster delete comes FIRST: a kit without respawn_frames must still
    # leave the roster on death, or the renderer draws its ghost forever
    # (M2 review finding 2 — latent until someone adds a no-respawn kit).
    # v11: the record carries NO landing tile — that choice moves to
    # respawn_due_humans at release time. fallback_tile preserves today's
    # exact no-spawn-list edge only (a kit absent from the zone's
    # enemy_spawns respawns at its death tile, as it always did).
    def schedule_human_respawn(human)
      humans.delete(human)
      delay = human.kit[:respawn_frames]
      return unless delay
      @human_respawns[@zone_name] << { kit_name: human.kit_name,
                                       fallback_tile: human.tile,
                                       at_frame: @frame + delay }
    end

    # Release-time anchor selection (v11 spec §1): join the nearest eligible
    # pocket, else seed at the spawn farthest from the pack, else home.
    # Returns [tile, anchor_kind] with anchor_kind ∈ :pocket|:seed|:home.
    def respawn_target(record, occupied)
      spawns = map.enemy_spawns[record[:kit_name]]
      return [record[:fallback_tile], :home] if spawns.nil? || spawns.empty?
      cfg = @threat[:density]
      if (anchor = pocket_anchor(spawns, cfg[:pocket_cap]))
        tile = scatter_pick(anchor, cfg[:scatter_radius_tiles], occupied)
        return [tile, :pocket] if tile
        return [nearest_spawn(spawns, anchor), :home]
      end
      if @pack.living.any?
        seed = seed_anchor(spawns)
        tile = scatter_pick(seed, cfg[:scatter_radius_tiles], occupied)
        return [tile, :seed] if tile
        return [seed, :home]
      end
      [spawns.first, :home] # empty pack: "where you aren't" has no referent
    end

    # The eligible pocket (size < cap) whose nearest member is closest to
    # ANY of the kit's spawn tiles — a double-minimum over pocket-members ×
    # spawn-tiles, because the record carries no death tile to score from.
    # Neutral depth (fork 2); roster-index tie-break. Returns that member's
    # tile (the anchor), or nil when no pocket is eligible.
    def pocket_anchor(spawns, cap)
      best_key = nil
      best_tile = nil
      density_pockets.each do |pocket|
        next unless pocket.length < cap
        pocket.each do |member|
          d = spawns.map { |s| tile_distance(member.tile, s) }.min
          key = [d, humans.index(member)]
          next if best_key && (key <=> best_key) >= 0
          best_key = key
          best_tile = member.tile
        end
      end
      best_tile
    end

    # Crowds re-form where you aren't: the spawn tile farthest from the
    # NEAREST living pack member; tie-break lowest index in zone-data order.
    def seed_anchor(spawns)
      spawns.each_with_index.max_by do |tile, i|
        [@pack.living.map { |m| tile_distance(m.tile, tile) }.min, -i]
      end.first
    end

    def nearest_spawn(spawns, anchor)
      spawns.each_with_index.min_by { |tile, i| [tile_distance(anchor, tile), i] }.first
    end

    # Seeded pick among walkable, unoccupied tiles within the scatter
    # radius. Candidates build in fixed row-major order. Draws from the
    # DEDICATED respawn stream (v14): pins consume ~120f earlier than
    # releases did, and on the old shared stream that reordering would
    # have moved every drop roll behind it. Drop rolls and respawn picks
    # can no longer perturb each other.
    def scatter_pick(anchor, radius, occupied)
      ax, ay = anchor
      candidates = []
      (-radius..radius).each do |dy|
        (-radius..radius).each do |dx|
          t = [ax + dx, ay + dy]
          candidates << t if map.passable?(*t) && !occupied.include?(t)
        end
      end
      return nil if candidates.empty?
      candidates[@respawn_rng.rand(candidates.length)]
    end
  end
end
