require "core/event_bus"
require "core/state_stack"
require "core/tile_map"
require "core/tile_registry"
require "core/counting_rng"
require "core/input"
require "game/creature"
require "game/pack"
require "game/projectile"
require "game/controllers"
require "game/aggro"
require "game/feel"
require "game/camera"
require "game/flow_field"
require "game/fight_ledger"
require "game/field_economy"
require "game/price_sheet"
require "game/stations"
require "game/tier_sheet"
require "game/crossing"
require "game/homecoming"
require "game/progression"
require "game/transients"
require "game/volleys"
require "game/save_state"

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
      human_retargeted human_leashed human_respawned blinked poisoned aura_burn
      inscribed banked_spent tribute_paid body_regrown body_dissolved mark_consumed vessel_kept
      provision_bought provision_used provision_refused totem_pulse
      seal_breached home_rehomed respawn_telegraphed
      challenger_engaged challenger_chant_started chant_interrupted vessel_seized seizure_ended
      inscription_burned level_up
    ].freeze

    TRANSITIONS = { world: %i[nest_respawn], nest_respawn: %i[world] }.freeze

    HOME_ZONE = "nest".freeze # the INITIAL home only — @home_zone advances (v12)

    attr_reader :bus, :pack, :feel, :states, :frame, :zone_name, :rng, :respawn_rng,
                :home_zone, :progression, :field_economy, :tile_registry

    def initialize(data, seed: 0, seats: 1, save: nil)
      # v17 seat map (spec Sim spec): seat ids are PINNED [1..n]; every
      # per-seat loop iterates this order on both machines (seat-order
      # law, decision 2). Single-seat construction is byte-identical to
      # the walled line by design.
      @seats = (1..seats).to_a
      @data = data
      @display = data["display"]
      @balance = data["balance/combat"]
      @death = data["balance/death"]
      @threat = data["balance/threat"]
      @economy = data["balance/economy"]
      # v18 decision 11 (+7ii): the seat-count scalar block — nil unless
      # data/balance/coop.json carries THIS seat count ("1" has no block
      # by design, so single-player executes ZERO coop arithmetic and the
      # wall stays byte-identical by construction; scaled values under
      # seats>=2 are explicit .round Integers — no Float ever enters the
      # digest).
      @coop = data["balance/coop"][:seats][:"#{seats}"]
      @rng = Core::CountingRng.new(Random.new(seed))
      # Respawn scatter draws from its OWN derived stream (v14): the
      # telegraph moves consumption ~120f earlier, and on the shared
      # stream that would reorder every drop roll behind it. Salt is
      # stream derivation (determinism plumbing), not balance.
      # Both streams count their draws (v17 digest lane, CountingRng —
      # value-transparent by construction).
      @respawn_rng = Core::CountingRng.new(Random.new(seed ^ RESPAWN_STREAM_SALT))
      @bus = Core::EventBus.new.register(*EVENTS)
      @states = Core::StateStack.new(initial: :world, transitions: TRANSITIONS)
      @feel = Feel.new(@balance[:feel])
      @frame = 0
      @respawn_timer = 0
      # v15 banner FIFO (panel fold W6): zone banners + court stamps share
      # the slot as QUEUED entries {text_key:, fallback:, color:,
      # frames_left:} — keys, never locale-baked text (locale-at-render
      # law). The active entry always plays out; past banner_queue_max the
      # oldest QUEUED entry yields (enqueue_banner — the uiux M3 audit
      # caught this comment claiming "nothing is eaten").
      @banner_queue = []
      @station_cue = nil
      @breach_line = nil
      @gate_wait = nil
      @breached = {}
      # J7-B (D2): zone -> frame stamped when the pack LEAVES it; consumed
      # (deleted) by the catch-up at re-entry. World transient — never a
      # save fact (zone positions die at the session boundary by omission,
      # so a persisted stamp would point at state that no longer exists).
      @zone_left_at = {}
      @home_zone = HOME_ZONE
      @zones = {}
      @humans = Hash.new { |h, k| h[k] = [] }
      @human_respawns = Hash.new { |h, k| h[k] = [] }
      @projectiles = []
      # Volley records live in a plain object (T4 carve, line-cap law);
      # hit resolution reaches back through these callables.
      @volleys = Volleys.new(hostiles: method(:hostiles_for),
                             blocked: method(:blocked_for),
                             hit_sink: method(:emit_attack_hit))
      @last_damaged = {}
      # The field-value economy (drops, corpse records, carried
      # containers, expiry flashes) is a plain object — explicit call
      # order, no bus mediation (extract-on-touch, v18).
      @field = FieldEconomy.new(bus: @bus, rng: @rng,
                                drops_cfg: @balance[:drops], death_cfg: @death)
      @field_economy = @field
      # Every persistent growth fact (v18 counters, v19 level/xp) lives
      # in ONE plain object (Lane 1 T1, spec P14) — World delegates.
      @progression = Progression.new(config: data["balance/progression"])
      @transients = Transients.new(pop_frames: @balance[:feel][:pop_frames])
      @controllers = @seats.to_h { |s| [s, PossessedController.new] }
      @ai = AiController.new
      # Acquisition/threat brain (B1-T1 extraction, line-cap law): focus
      # assignment (incl. the B1 safe-zone refusal), pressure partition,
      # ring claims, density pockets, beachhead shielding live in a plain
      # object — per-tick claim state resets from tick_world exactly where
      # the old ivars did.
      @aggro = Aggro.new(humans: -> { humans }, map: method(:map),
                         arrivals: -> { arrival_tiles_for(@zone_name) },
                         threat: @threat, economy: @economy, bus: @bus, ai: @ai)
      @null_input = Core::NullInput.new
      @swap_was_down = @seats.to_h { |s| [s, false] }
      @rearm_needed = @seats.to_h { |s| [s, false] }
      load_zones
      spawn_pack
      # Prices are quoted by a plain reader object (line-cap extraction,
      # 2026-08-20) — constructed after spawn_pack so it holds the live Pack.
      # B4: the session-open mercy — armed at boot, consumed by the session's
      # first regrow, never persisted (per-session by definition).
      @vat_mercy_armed = true
      @price_sheet = PriceSheet.new(economy: @economy, pack: @pack,
                                    breached: method(:breached?),
                                    mercy: ->(zone) { @vat_mercy_armed && zone == @home_zone })
      # Station transactions (L10 extraction, v20 T4): banked sinks + the
      # sustain verb live in a plain object; World keeps the dispatch, the
      # guards, the seal, and every presentation write (cue callables).
      @stations = Stations.new(bus: @bus, pack: @pack, economy: @economy,
                               sustain_cfg: data["balance/sustain"],
                               price_sheet: @price_sheet, zone: -> { @zone_name },
                               map: method(:map),
                               cue: method(:station_cue!), refuse: method(:station_refuse!),
                               regrow_binding: method(:regrow_binding),
                               consume_mercy: ->(kept) { @vat_mercy_armed &&= kept },
                               assign_seats: method(:assign_waiting_seats))
      # Crossing policy (T4 extraction, line-cap law): open/consent/arrival
      # decisions live in a plain object; World does the moving.
      @crossing = Crossing.new(zones: @zones, breached: method(:breached?),
                               defeats: -> { @progression.boss_1_defeats },
                               level: -> { @progression.level },
                               living: -> { @pack.living.length })
      # Go-home policy (J7-A extraction, line-cap law): effective home,
      # cached home fields, and the emit-once leash decision live in a
      # plain object; World does the emitting.
      @homecoming = Homecoming.new(map: method(:map), corpse_loads: method(:corpse_loads),
                                   threat: @threat)
      # First-possession registry (v14): cosmetic sim state the sim never
      # reads (taunt_pulses precedent) — the controls overlay derives its
      # one-time pulse from it as a pure function of world state, so both
      # gate replays render bit-equal strips (draw-side accumulation would
      # not be tick-locked). Seeded with the initial body at frame 0;
      # wire_events keeps it fed on every possession change.
      @kit_first_possessed = {}
      controlled_bodies.each { |b| @kit_first_possessed[b.kit_name] ||= 0 }
      wire_events
      # Constructed after wire_events ON PURPOSE: World's actor_died handler
      # must queue corpse_loaded/pack_wiped ahead of the ledger's handlers in
      # the same flush (the wipe-ordering pin, spec M6).
      @fight_ledger = FightLedger.new(@bus, world: self,
                                      config: data["balance/ledger"])
      # v18 decision 4 + v19 P3: facts apply during construction in the
      # PINNED order (home -> growth facts -> leveled max hp -> members ->
      # seats -> breaches), then initial enter_zone lands the loaded spawn.
      # save: nil (the wall, replay, pilot) takes the identical fresh path.
      SaveState.apply!(self, save, economy: @economy) if save
      enter_zone(@home_zone, @zones.fetch(@home_zone).pack_spawn)
    end

    def map = @zones.fetch(@zone_name)

    # v18 decision 13 (god-view artifact): read-only view of every zone's
    # TileMap — the offline map composite renders ALL zones from the same
    # objects the renderer draws. No sim system iterates this.
    def zone_maps = @zones

    # Focused-scene start (v15 harness `start` param): begin the session in
    # a named zone. Same arrival path as any gate crossing — enter_zone owns
    # the banner/home/leash law. No in-game system calls this.
    def start_in(zone)
      raise ArgumentError, "unknown zone #{zone}" unless @zones.key?(zone)
      enter_zone(zone, @zones.fetch(zone).pack_spawn)
    end
    def humans = @humans[@zone_name]
    # Bare = seat 1 (existing call sites unchanged, spec Sim spec);
    # possessed(2) = the partner seat's body, nil while that seat waits.
    def possessed(seat = 1) = @pack.possessed(seat)
    # Decision 11 seat semantics: the seat-ordered pointer list and its
    # lookups. AI dispatch, feel scoping, verb guards, seizure targeting,
    # and zone gates read THESE — never bare possessed.
    def controlled_bodies = @seats.filter_map { |s| @pack.possessed(s) }
    def seat_for(creature) = @seats.find { |s| @pack.possessed(s)&.equal?(creature) }
    def controlled?(creature) = !seat_for(creature).nil?
    def seats = @seats
    # Per-seat cameras (decision 5): presentation state, digest-excluded;
    # the renderer draws through the LOCAL seat's camera.
    def camera(seat = 1) = @cameras[seat]
    def banner? = !active_banner.nil?
    def active_banner = @banner_queue.first
    def actors = (@pack.members + humans).reject(&:dead?)
    def projectiles = @projectiles
    def impacts = @volleys.records
    def corpses = @field.corpses(@zone_name)
    def drops = @field.drops(@zone_name)
    # Non-autovivifying (FieldEconomy law): the renderer reads these every
    # draw and a default-proc index would insert keys into sim state from
    # the draw path (pure-reader law).
    def corpse_loads(zone = @zone_name) = @field.corpse_loads(zone)
    def expiry_flashes(zone = @zone_name) = @field.expiry_flashes(zone)
    def ledger_beat = @fight_ledger.beat
    def total_stranded = @field.total_stranded
    def marked_target = @pack.mark

    # v18 decision 12: the seat-gated third-body caution threshold — nil
    # when no coop block exists (seats=1: the flee guard never evaluates).
    def ally_flee_hp_pct = @coop && @coop[:ally_flee_hp_pct]
    def taunt_pulses = @transients.taunt_pulses
    def totem_pulses = @transients.totem_pulses
    def kill_pops = @transients.kill_pops
    def level_up_pops = @transients.level_up_pops
    def seal_marks = @transients.seal_marks

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
    # v17 gate-wait cue feed (decision 11 co-location consent): the gate
    # tile blocked ONLY on partner co-location this tick, else nil.
    # Presentation reader, digest-excluded; unreachable single-seat (no
    # partner to wait for) — the walled line is untouched by construction.
    def gate_wait = @gate_wait

    # Session-scoped and wipe-proof BY DESIGN: wipes never close the door —
    # that is the arc. Only a fresh World (restart) re-seals.
    def breached?(zone, tile) = @breached.key?([zone, tile])

    # v18 decision 4: the ONE breach-restoring path — idempotent and
    # side-effect-free (no spend, no events, no hitstop/cues/marks).
    # Shared by the live seal verb (which adds spend + emit + cues) and
    # by save apply. Tiles are copied so facts arrays never alias sim
    # state.
    def restore_breach!(zone, tile)
      @breached[[zone, [tile[0], tile[1]]]] = true
    end

    # Persisted view of @breached (spec decision 1): sorted [[zone,
    # [x, y]], ...] with fresh arrays — mutating facts can never reach
    # sim state.
    def breached_tuples
      @breached.keys.sort_by { |(zone, (x, y))| [zone, x, y] }
                .map { |(zone, tile)| [zone.dup, [tile[0], tile[1]]] }
    end

    # --- v18 save-apply seams (SaveState.apply! only — construction
    # time, before the initial enter_zone; never called mid-session) -----

    def load_home!(zone)
      raise ArgumentError, "unknown zone #{zone}" unless @zones.key?(zone)
      @home_zone = zone
    end

    # Persistent growth facts read through the Progression carve (P14).
    def boss_1_defeats = @progression.boss_1_defeats
    def sessions = @progression.sessions

    def save_facts = SaveState.facts(self)

    # kit_name => first frame that kind was possessed (v14 overlay pulse).
    def kit_first_possessed = @kit_first_possessed

    # Renderer-facing price readers — one-line delegations to PriceSheet
    # (the extraction keeps every call site and test byte-identical).
    def station_price(station) = @price_sheet.station_price(station, @zone_name)
    def provision_cost = @price_sheet.provision_cost
    def provision_cap = @price_sheet.provision_cap

    def tick(input)
      inputs = input.is_a?(Hash) ? input : { 1 => input }
      if @feel.hitstop?
        @feel.tick
        @bus.process
        @frame += 1
        return
      end

      if (b = @banner_queue.first)
        b[:frames_left] -= 1
        @banner_queue.shift if b[:frames_left] <= 0
      end
      # v16 (c): floor seal marks dwell on the banner clock — same pause
      # law (hitstop skips this whole branch), fading with their stamp.
      @transients.tick_banner_clock!
      @station_cue = nil if @station_cue && (@station_cue[:frames_left] -= 1) <= 0
      @breach_line = nil if @breach_line && (@breach_line[:frames_left] -= 1) <= 0
      # Gate-wait cue: recomputed every non-hitstop tick — check_transition
      # re-sets it while the co-location block holds (hitstop keeps the
      # frozen frame's value, same law as banners).
      @gate_wait = nil

      case @states.current
      when :world
        tick_world(inputs)
      when :nest_respawn
        @respawn_timer -= 1
        if @respawn_timer <= 0
          @states.transition_to(:world)
          respawn_pack
        end
      end

      @seats.each do |seat|
        a = camera_anchor(seat)
        @cameras[seat].tick(a.x + Creature::SIZE / 2.0, a.y + Creature::SIZE / 2.0)
      end
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

    # Surround/pressure ring claims, the engaged/pressuring partition,
    # density pockets, and beachhead shielding are Aggro policy (B1-T1
    # extraction) — these delegates ARE the AiController/renderer/telemetry
    # view surface, byte-compatible with the pre-carve methods.
    def surround_slot(attacker, target) = @aggro.surround_slot(attacker, target)

    def pressure_role(creature) = @aggro.pressure_role(creature)

    def pressure_slot(attacker, target) = @aggro.pressure_slot(attacker, target)

    def density_pockets = @aggro.density_pockets

    def beachhead_shields?(human, target) = @aggro.beachhead_shields?(human, target)

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

    # Density pockets moved to Aggro with the acquisition family (B1-T1);
    # the respawn anchor path, telemetry, and tests read this delegate.

    # Beachhead shielding: Aggro policy (see delegate above).

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

    # Go-home policy delegates (J7-A extraction): the controllers' view
    # contract (flow_home / leash_home_tile / human_leashed!) stays on
    # World; Homecoming decides, World emits.
    def flow_home(creature) = @homecoming.flow_home(creature)

    def leash_home_tile(creature) = @homecoming.leash_home_tile(creature)

    def human_leashed!(creature)
      payload = @homecoming.leash_emission(creature)
      @bus.emit(:human_leashed, **payload) if payload
    end

    def set_mark(source)
      seat = seat_for(source)
      return false unless seat
      range = @balance[:pack][:mark_range_tiles]
      foes = hostiles_for(source)
      preferred = @last_damaged[seat]
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
      return false unless controlled?(source)
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
        @field.release_corpse_record(@zone_name, load[:id], frame: @frame)
        source.pick_up(load[:amount])
        @bus.emit(:corpse_looted, actor: source, tile: load[:tile],
                  amount: load[:amount], carried: source.carried,
                  term_left: load[:term_left], term: load[:term])
        return true
      end
      station = map.station_at(*source.tile)
      if station
        case station[:type]
        when "bank"  then @stations.bank(source)
        when "altar" then @stations.altar(source)
        when "vat"   then @stations.vat(source)
        when "seal"  then interact_seal(source, station)
        # totem: deliberate no-op — it pulses on its own clock, no
        # interact verb (the L4 PRICED-activation flip would land here).
        else false
        end
      else
        interact_rope(source)
      end
    end

    # T4 (D4): the way back up — a rope spot is a FREE station-type
    # interact (v0; rope-as-item waits for the items cycle).
    def interact_rope(source)
      t = map.transition_at(*source.tile)
      return false unless t && t[:type] == "rope_spot"
      cross_through(source, t)
    end

    # v18 decision 9 — the sustain verb: transaction lives in Stations
    # (L10 extraction, v20 T4); World keeps the verb guards (input
    # validity) and the station lookup interact shares.
    def sustain(source)
      return false unless controlled?(source)
      return false if source.dead? || source.staggered? || source.attack_state != :idle
      @stations.sustain(source, station: map.station_at(*source.tile))
    end

    # PREMIUM v22 ally brain: a FREE ally drinks (never buys — buying is a
    # bank act and the player's call). Same station verb, same pack flask,
    # same one-per-frame seat race, same events — only the seat gate differs.
    def ally_sustain(source)
      return false if controlled?(source)
      return false if source.dead? || source.staggered? || source.attack_state != :idle
      @stations.sustain(source, station: nil)
    end

    # --- v17 digest lane (spec decision 6) ------------------------------
    # The authoritative desync-detection snapshot: every gameplay-affecting
    # field, as [group, [[name, scalar], ...]] with stable actor ids
    # (roster index for pack, spawn-order name for humans, zones in sorted
    # order). Presentation records are EXCLUDED by law — banners, stamps,
    # station cues, breach lines, taunt pulses, kill pops, seal marks,
    # expiry flashes, visual corpse records, kit_first_possessed, cameras,
    # shake: no sim system reads them (standing prohibition, spec decision
    # 6). RNG streams are covered by DRAW COUNTS (panel fold): a diverged
    # stream surfaces through positions/drops/spawns within one window.
    # Empty autovivified zone lists contribute no groups, so reader-side
    # autovivification can never skew the digest.
    def digest_snapshot
      world_fields = [
        ["frame", @frame], ["zone", @zone_name], ["state", @states.current],
        ["respawn_timer", @respawn_timer], ["home_zone", @home_zone],
        ["breached", @breached.keys.map(&:inspect).sort.join("|")],
        ["zone_left_at", @zone_left_at.map { |z, f| "#{z}:#{f}" }.sort.join("|")],
        ["last_damaged", @seats.map { |s| "#{s}:#{@last_damaged[s]&.name}" }.join("|")],
        ["swap_was_down", @seats.map { |s| "#{s}:#{@swap_was_down[s]}" }.join("|")],
        ["rearm_needed", @seats.map { |s| "#{s}:#{@rearm_needed[s]}" }.join("|")],
        ["corpse_serial", @field.corpse_serial],
        ["rng_draws", @rng.draws], ["respawn_rng_draws", @respawn_rng.draws],
        ["boss_1_defeats", boss_1_defeats], ["sessions", sessions],
        ["level", @progression.level], ["xp", @progression.xp]
      ] + @feel.digest_fields
      groups = [["world", world_fields], ["pack", @pack.digest_fields]]
      @pack.members.each_with_index { |m, i| groups << ["pack.#{i}", m.digest_fields] }
      @humans.keys.sort.each do |zone|
        @humans[zone].each { |h| groups << ["human.#{zone}.#{h.name}", h.digest_fields] }
      end
      @projectiles.each_with_index { |p, i| groups << ["projectile.#{i}", p.digest_fields] }
      groups.concat(@volleys.digest_groups)
      groups.concat(@field.digest_groups)
      groups.concat(@stations.digest_groups)
      @human_respawns.keys.sort.each do |zone|
        @human_respawns[zone].each_with_index do |r, i|
          groups << ["respawn.#{zone}.#{i}", [
            ["kit", r[:kit_name]], ["at_frame", r[:at_frame]],
            ["fallback_x", r[:fallback_tile][0]], ["fallback_y", r[:fallback_tile][1]],
            ["pinned_x", r[:pinned_tile]&.[](0)], ["pinned_y", r[:pinned_tile]&.[](1)],
            ["anchor", r[:pinned_anchor]], ["defer", r[:defer_frames]]
          ]]
        end
      end
      groups
    end

    private

    def tick_world(inputs)
      @aggro.reset!
      @stations.reset!
      @seats.each { |seat| handle_swap(seat, seat_input(inputs, seat)) }
      # Forced swap happens at bus-process time (no input in scope there), so
      # the edge-trigger re-arm is deferred to the next tick — law 2 applies
      # to BOTH swap kinds (per seat): no held key may leak into the new body.
      @seats.each do |seat|
        next unless @rearm_needed[seat]
        @controllers[seat].rearm!(seat_input(inputs, seat))
        @rearm_needed[seat] = false
      end
      @pack.members.each(&:tick_body)
      humans.each(&:tick_body)

      # Seat-order law (decision 2): seat 1's controller always resolves
      # before seat 2's, on both machines. A waiting seat has no body —
      # its inputs are ignored (decision 3).
      @seats.each do |seat|
        body = @pack.possessed(seat)
        next unless body
        controller = @controllers[seat]
        controller.blocked = blocked_for(body)
        controller.tick(body, seat_input(inputs, seat), self)
      end
      validate_mark
      @pack.living.each { |m| @ai.tick(m, self) unless controlled?(m) }
      @aggro.assign_focus!(self)
      @aggro.partition_pressure!
      tick_challengers
      # A chanting challenger STANDS — pronunciation is stillness (his AI
      # tick is the only thing suspended; timers/attack-state still ran).
      humans.each { |h| emit_telegraph_edge(h); @ai.tick(h, self) unless h.chanting? }

      check_transition
      # Volleys tick here only, so hitstop pauses delayed impacts while
      # @frame continues advancing (the pause law rides this call order).
      @volleys.tick!
      @transients.tick_combat!
      resolve_attacks
      tick_auras
      tick_projectiles
      # AFTER every damage source on purpose: a body killed this frame ends
      # its seizure THIS frame (why=:died — the zero-frame seizure is legal
      # and ordered; spec same-frame race).
      tick_seizures
      @field.tick_drops
      @field.tick_corpse_loads(frame: @frame)
      @field.tick_expiry_flashes
      # v20 T4: totem cadence rides tick_world (hitstop + respawn veil
      # pause it); heals land AFTER every damage source this tick — a body
      # killed this frame is dead, the pulse never revives (vat monopoly).
      @stations.tick_totems!
      @fight_ledger.tick
      telegraph_due_humans
      respawn_due_humans
      prune_caches
    end

    # Hostile focus acquisition (incl. the B1 safe-zone refusal) lives in
    # Aggro#assign_focus! (B1-T1 extraction) — tick_world calls it at the
    # exact call site the private method held since A2.

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
            # C2 (s80): idempotent re-stamp at the landing — the law reads
            # "every hostile act stamps", so the hardest act in data does
            # not depend on the chant-start stamp having survived.
            h.provoke!
            # v16 owner order (2026-08-16): the called-stamp TEXT is removed
            # — the lore rework renames or retires it; the seizure's
            # delivery is the writ-frame + ring + seized weight until then.
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
          enqueue_stamp("challenger.stands.line", "BOSS 1 SPAWNED")
          @bus.emit(:challenger_engaged, actor: h)
        end
        next unless h.seize_cooldown.zero?
        next if h.staggered? || h.attack_state != :idle
        # Never chant while his own seizure holds (cooldown starts at
        # seizure END, so this guard is what prevents chant-chaining).
        next if @pack.members.any? { |m| m.seize_active? && m.seizure_seizer.equal?(h) }
        # B1 safe-zone law (D3 reopen, s71): chant-start is an ACQUISITION
        # verb that bypasses focus — start_chant! pins a body directly —
        # so the sanctuary refusal names it explicitly (the spec's own
        # reopen clause; every other hostile verb needs a live focus).
        next if map.safe
        # Decision 11: seizure targets the NEAREST controlled body
        # (Chebyshev; tie -> lower roster index) — deterministic on both
        # machines.
        body = nearest_controlled_to(h)
        next if body.nil? || body.dead? || tile_distance(h.tile, body.tile) > seize[:range_tiles]
        h.start_chant!(body, seize[:chant_frames])
        # C2 (s80): the chant IS the aggression — provoking at START is
        # what lets FREE allies help interrupt it (the designed
        # counterplay must not be possessed-only).
        h.provoke!
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
      # v16 (d): a seized body that DIES while held loses its god-mark —
      # the court's claim overrides the vat's (data switch on the seizer's
      # kit). Read AT the seizure-death moment, BEFORE corpse bookkeeping
      # (the actor_died flush runs after tick_world — DeepSeek ordering
      # fold holds by construction). burn_mark! zeroes the state, so the
      # wipe path's mark-consumption can never double-consume.
      if why == :died && body.marked? && seizer.kit[:seizure_burns_inscription]
        body.burn_mark!
        @bus.emit(:inscription_burned, body:, at: body.tile)
        enqueue_stamp("stamp.mark_void", "MARK LOST", at: body.tile)
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
    def enqueue_banner(text_key:, fallback:, color:, frames:, suffix: nil)
      cap = @display.fetch(:banner_queue_max, 2)
      @banner_queue.delete_at(1) while @banner_queue.length - 1 >= cap
      @banner_queue << { text_key:, fallback:, color:, suffix:,
                         frames_left: frames, frames_total: frames }
    end

    # v16 (c): a stamp with a tile locus ALSO presses a seal mark into the
    # floor at the event tile (GLM review fold — the act happens IN the
    # world, not just on screen). Unlocated stamps stay screen-only.
    def enqueue_stamp(key, fallback, at: nil, suffix: nil)
      enqueue_banner(text_key: key, fallback:, color: :gold, suffix:,
                     frames: @display.fetch(:stamp_banner_frames, 150))
      mark_seal!(at) if at
    end

    def mark_seal!(at)
      frames = @display.fetch(:stamp_banner_frames, 150)
      @transients.seal_mark!(at:, frames:)
    end

    # Tab swap: rising edge only, world-level (the controller mask handles
    # every OTHER action; swap itself must not autorepeat while held).
    # Refused while the possessed is staggered — otherwise an instant Tab
    # after a forced swap hands you an unstaggered third body and the
    # death penalty never lands (law 2).
    def handle_swap(seat, input)
      down = input.down?(:swap)
      body = @pack.possessed(seat)
      unless body # waiting-for-body: inputs ignored, edge state still tracked
        @swap_was_down[seat] = down
        return
      end
      # v15 seized exemption (Codex pass-2 CONFIRMED defect): while the
      # possessed is seized, Tab ALWAYS works — a crew hit staggering the
      # seized body must not trap the echo inside it (the ratified
      # fairness ladder). Scoped to seized-only so law 2's forced-swap
      # stagger hole stays closed. Applies PER SEAT (decision 11); the
      # swap target never includes the partner's body (decision 3).
      can_swap = @pack.swap_target(seat) &&
                 (body.seized_by ||
                  (!body.staggered? && !body.special_committed?))
      if down && !@swap_was_down[seat] && can_swap
        from = body
        @pack.swap_next!(seat)
        @controllers[seat].rearm!(input)
        @bus.emit(:possession_changed, from:, to: @pack.possessed(seat), forced: false)
      end
      @swap_was_down[seat] = down
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
        when "spread"
          launch_spread(attacker, cfg) if attacker.action_can_trigger?
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
      burst = pack_burst?(attacker, cfg)
      attacker.action_tiles.each do |tile|
        victim = foes.find { |foe| !foe.dead? && burst_covers?(burst, foe, tile) }
        next unless victim && attacker.action_can_hit?(victim)
        apply_action_hit(attacker, victim, cfg)
      end
    end

    # D2 family (s66, owner-picked scope): PACK burst actions — ring
    # specials (whirl / blocker ring) and the dash arc — hit what the eye
    # sees: a foe still tweening off a tile is IN the burst (walker
    # covers?, the law the volley shipped this session). Enemy actions and
    # pack precision attacks (front1/arc3/projectile) keep committed-tile
    # equality — leading a target stays melee skill, and enemy fairness
    # against dodging humans is untouched.
    def pack_burst?(attacker, cfg)
      attacker.faction == :pack && %w[ring dash].include?(cfg[:arc])
    end

    def burst_covers?(burst, foe, tile)
      burst ? foe.walker.covers?(*tile) : foe.tile == tile
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
      @transients.taunt_pulse!(tile: attacker.tile,
                                pulse_frames: t[:pulse_frames], range_tiles: t[:range_tiles])
      @bus.emit(:taunted, actor: attacker, victims: victims.length)
    end

    def resolve_dash_action(attacker, cfg)
      return unless attacker.action_can_trigger?
      attacker.action_triggered!
      foes = hostiles_for(attacker)
      burst = pack_burst?(attacker, cfg)
      attacker.action_tiles.each do |tile|
        victim = foes.find { |foe| !foe.dead? && burst_covers?(burst, foe, tile) }
        next unless victim && attacker.action_can_hit?(victim)
        apply_action_hit(attacker, victim, cfg)
      end
    end

    # P5 composition pin: kit base -> level growth (Integer) -> coop
    # scalar. No coop scalar touches pack damage today; enemies never read
    # a level term — their term is the zone tier stamped at spawn (s68).
    # Projectiles/impacts store this result at launch time.
    def leveled_damage(attacker, cfg)
      base = cfg[:damage]
      return base + (base * attacker.tier_dmg_pct) / 100 unless attacker.faction == :pack
      @progression.damage_for(base)
    end

    # P10 sibling of leveled_damage — the level laws share ONE home:
    # spell growth applies to the PACK only (P7 stays mechanical), the
    # active array replaces the kit base whole (no arithmetic on
    # arrays), and distances take NO coop term (composition stops at
    # level growth for geometry — spec P10).
    def volley_distances(attacker, cfg)
      return cfg[:impact_distances] unless attacker.faction == :pack
      @progression.special_impact_distances_for(attacker.kit_name,
                                                base: cfg[:impact_distances])
    end

    def apply_action_hit(attacker, victim, cfg)
      attacker.action_hit!(victim)
      landed = victim.take_hit(damage: leveled_damage(attacker, cfg), attacker:,
                               knockback_tiles: cfg[:knockback_tiles],
                               blocked: blocked_for(victim))
      if landed
        victim.stagger!(cfg[:stagger_frames]) if cfg[:stagger_frames]
        victim.interrupt_action! if cfg[:interrupt_windup]
        if (ps = cfg[:poison]) && !victim.dead?
          victim.poison!(ticks: ps[:ticks], dmg_per: ps[:dmg_per],
                         interval_frames: ps[:interval_frames], by: attacker)
          @bus.emit(:poisoned, attacker:, victim:)
        end
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
        damage: leveled_damage(attacker, cfg), range_tiles: cfg[:range_tiles],
        frames_per_tile: cfg[:projectile_frames_per_tile],
        knockback_tiles: cfg[:knockback_tiles]
      )
      @bus.emit(:projectile_fired, attacker:)
    end

    # MUNDO VIVO FASE 4 — `spread`: a FAN of projectiles. `spread_count`
    # shots leave the same tile in 8-way directions centered on the facing
    # (count 3 = facing ±45°; 5 = ±90°). Each shot is an ordinary
    # Projectile (one combat law: damage/range/knockback from the kit,
    # friendlies pass through, walls stop). ONE projectile_fired event per
    # volley (the manifest/telemetry grammar counts casts, not pellets).
    # Deterministic: rotation is a table walk on the 8-way ring.
    SPREAD_RING = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]].freeze

    def launch_spread(attacker, cfg)
      attacker.action_triggered!
      count = cfg.fetch(:spread_count, 3)
      base = SPREAD_RING.index(attacker.facing) || 0
      half = count / 2
      (-half..half).each do |k|
        dir = SPREAD_RING[(base + k) % 8]
        @projectiles << Projectile.new(
          owner: attacker, map:, tile: attacker.tile, dir:,
          damage: leveled_damage(attacker, cfg), range_tiles: cfg[:range_tiles],
          frames_per_tile: cfg[:projectile_frames_per_tile],
          knockback_tiles: cfg[:knockback_tiles]
        )
      end
      @bus.emit(:projectile_fired, attacker:)
    end

    def launch_volley(attacker, cfg)
      attacker.action_triggered!
      @volleys.launch(owner: attacker, map:, origin: attacker.tile,
                      dir: attacker.facing, distances: volley_distances(attacker, cfg),
                      delay_frames: cfg[:delay_frames],
                      damage: leveled_damage(attacker, cfg))
    end

    # Decay/term/flash clocks + drop/corpse records live in FieldEconomy
    # (plain object, explicit call order from tick_world — hitstop and
    # the wipe veil pause the whole field economy deterministically,
    # exactly as before the extraction).

    # Creation order = resolution order (deterministic). The projectile only
    # reports the victim; damage resolves here from the OWNER's kit, exactly
    # like melee — one law for all combat.
    # MUNDO VIVO FASE 4.6 — `aura` (ember family): while an aura-bearer
    # lives, every hostile within kit[:aura][:radius_tiles] (Chebyshev)
    # burns kit[:aura][:damage] every kit[:aura][:period_frames] frames.
    # Cadence = world.frame % period (no per-creature clock → nothing new
    # in the digest; deterministic by construction). Emits :aura_burn once
    # per victim per tick for telemetry/manifests.
    def tick_auras
      actors.each do |bearer|
        aura = bearer.kit[:aura]
        next unless aura && (@frame % aura[:period_frames]).zero?
        bx, by = bearer.tile
        hostiles_for(bearer).each do |foe|
          next if foe.dead?
          fx, fy = foe.tile
          next if [(fx - bx).abs, (fy - by).abs].max > aura[:radius_tiles]
          next unless foe.burn!(leveled_damage(bearer, aura), by: bearer)
          @bus.emit(:aura_burn, attacker: bearer, victim: foe)
        end
      end
    end

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
      trigger = controlled_bodies.find do |c|
        !c.dead? && !c.walker.moving? && map.transition_at(*c.tile)
      end
      return unless trigger
      t = map.transition_at(*trigger.tile)
      # T4 (D3/D4): rope spots never auto-fire (climbing is the interact
      # verb); every other shape keeps the rest-on-tile law BYTE-EXACT.
      return if t[:type] == "rope_spot"
      cross_through(trigger, t)
    end

    # ONE crossing grammar for gates and ropes — policy in Game::Crossing;
    # World does the moving and owns the cue write (the only mutator).
    def cross_through(trigger, t)
      unless @crossing.open?(@zone_name, t)
        # T5 (P9/D3): the level refusal SPEAKS — station-cue refusal
        # grammar at the way tile, rewritten per stationary tick (the
        # gate_wait recompute law). Other shut-way causes stay silent
        # (defeats parity; a defeats cue = unratified parity candidate).
        if (n = @crossing.unmet_level(t))
          station_cue!(:level_required, t[:at], n: n)
        end
        return false
      end
      if (wait = @crossing.group_wait(controlled_bodies, trigger, t))
        @gate_wait = wait
        return false
      end
      enter_zone(t[:to], @crossing.arrival_tiles(t[:to], t[:spawn]))
      true
    end

    def enter_zone(name, tiles)
      raise ArgumentError, "unknown zone #{name}" unless @zones.key?(name)
      # v15: the whole pack teleports through gates (arrival_tiles), so a
      # seized body would cross zones with dangling state — seizures end
      # and every chant aborts BEFORE the move (spec lifecycle fold i).
      @pack.members.each { |m| end_seizure(m, :zone_left) if m.seize_active? }
      abort_all_chants!
      # J7-B (D2): stamp the zone being LEFT, only on an actual change —
      # respawn_pack reassigns @zone_name directly, so wipe-abandoned
      # zones stay unstamped (their humans keep today's snap-home), and
      # spawn_pack pre-assigns @zone_name so the construction-time entry
      # never stamps nil.
      @zone_left_at[@zone_name] = @frame if @zone_name != name
      @zone_name = name
      @flow_cache = {}
      @homecoming.clear!
      @projectiles = []
      @volleys.clear!
      @transients.clear!
      @pack.clear_mark!
      @last_damaged = {}
      # Cross-zone leash (J7-B, D4): a STAMPED re-entry advances displaced
      # living humans finitely along their home paths (linger first, then
      # kit-speed walk — Homecoming computes, World mutates), with KEPT hp;
      # resume_leash! pre-sets the linger so nobody double-lingers. No
      # stamp (first entry, same-zone wipe) = snap-home verbatim (frozen-
      # zone law; recorded plan deviation 1).
      stamp = @zone_left_at.delete(name)
      elapsed = stamp && @frame - stamp
      placements = stamp && @homecoming.catchup_placements(@humans[name], elapsed:)
      advanced = 0
      @humans[name].each do |h|
        h.focus = nil
        # C2 (s80): re-entry is a fresh slate — provocation clears with
        # focus (the fight the pack left is over).
        h.clear_provocation!
        next if h.dead?
        if h.tile == h.home_tile
          h.reset_leash!
        elsif placements
          tile = placements.fetch(h)
          if tile != h.tile
            h.rebind(map: @zones.fetch(name), tile:)
            @bus.emit(:human_leashed, actor: h, tile:, hp: h.hp)
            advanced += 1
          end
          h.resume_leash!(@threat[:leash_linger_frames])
        else
          h.rebind(map: @zones.fetch(name), tile: h.home_tile)
          @bus.emit(:human_leashed, actor: h, tile: h.home_tile, hp: h.hp)
          h.reset_leash!
        end
      end
      # D9 (wording pinned in-brief): forensics/soak line, stdout only —
      # never sim state, never an event.
      puts "TELEMETRY catchup zone=#{name} elapsed=#{elapsed} advanced=#{advanced}" if advanced.positive?
      placed = 0
      # Controlled bodies take the first tiles in SEAT order (single-seat:
      # exactly the old possessed-first law); living allies the rest, in
      # roster order. Dead flesh stays where it fell.
      controlled = controlled_bodies.reject(&:dead?)
      (controlled + (@pack.living - controlled)).each do |m|
        m.rebind(map:, tile: tiles[placed] || tiles.first)
        placed += 1
      end
      # Per-seat cameras INSIDE World (decision 5): constructed and snapped
      # here, ticked at the same call site v16's single camera used. A
      # waiting seat spectates the partner (camera_anchor).
      @cameras = @seats.to_h do |seat|
        cam = Camera.new(
          view_w: @display[:view_width], view_h: @display[:view_height],
          world_w: map.pixel_width, world_h: map.pixel_height,
          lerp: @display[:camera_lerp]
        )
        a = camera_anchor(seat)
        cam.snap!(a.x + Creature::SIZE / 2.0, a.y + Creature::SIZE / 2.0)
        [seat, cam]
      end
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
      # T2 (world-builder D7): the tile-type registry rides the same
      # data root; every zone's char->type mapping cross-checks against
      # it at load. Absent file (trimmed fixture data dirs) = no
      # registry, no cross-check — additive by construction.
      @tile_registry =
        @data.keys.include?("tiles") ? Core::TileRegistry.new(@data["tiles"]) : nil
      names = @data.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
      names.each do |n|
        @zones[n] = Core::TileMap.new(@data["zones/#{n}"])
        @tile_registry&.validate_map!(@zones[n])
      end
      # s31 (s30 review nit 6): edge legality + arrival geometry through
      # the crossing policy object — illegal edges refuse NAMED at boot,
      # never a crossing-time KeyError or an in-wall placement.
      @arrivals = Crossing.validated_arrivals(@zones)
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
      @tiers = TierSheet.new(config: @data["balance/tiers"], zones: @zones.keys)
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
      # v18 decision 11: coop difficulty applies at SPAWN (Junior's ask);
      # every human — the boss included — flows through here. s68: zone
      # tier stamps FIRST (TierSheet header: base -> tier -> coop pin).
      @tiers.apply!(creature, zone)
      creature.scale_max_hp!(@coop[:human_hp_scale]) if @coop
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
                       initial_kit: cfg[:initial_possessed], seats: @seats.length)
    end

    # --- D1b station verbs (the only banked sinks; spec S2-3) -----------
    # Transactions live in Stations (L10 extraction, v20 T4); World keeps
    # the seal (breach registry is save-law-coupled + presentation-heavy)
    # and the regrow binding (zone-binding law) Stations reaches back for.

    # Regrowth binding (coop-night crash fix, 2026-08-26): at the HOME vat
    # the hard rebind onto the home spawn tile stands byte-identical (S3
    # law). At a FIELD vat the flesh regrows AT THE VAT, beside the payer —
    # a body may never bind to a map the world is not showing: the old
    # away-vat home-rebind shipped bodies into another zone's coordinate
    # space, visibly off-map, and the ally AI's first flow-field read on
    # the foreign tile crashed the session (repro: economy_vat_test).
    def regrow_binding(source, member)
      if @zone_name == @home_zone
        home = @zones.fetch(@home_zone)
        { map: home, tile: home.pack_spawn[@pack.members.index(member)] }
      else
        { map:, tile: regrow_tile_beside(source) }
      end
    end

    # First free passable neighbor in STEPS order (deterministic — the
    # yield_aside precedent), ignoring occupancy when everything is taken,
    # the payer's own tile as the last resort (occupancy is soft: only
    # voluntary movement is blocked — the respawn_pack law).
    def regrow_tile_beside(source)
      taken = actors.map(&:tile)
      ring = FlowField::STEPS.map { |(dx, dy)| [source.tile[0] + dx, source.tile[1] + dy] }
      ring.find { |t| map.passable?(*t) && !taken.include?(t) } ||
        ring.find { |t| map.passable?(*t) } ||
        source.tile
    end

    # The breach (v12): pay the toll standing at the seal, and the way
    # opens — permanently for the session. One price, one decision (the
    # station law); the beat is LOUD (strongest feel kick + the writ line
    # in the banner slot) because opening the way IS the arc's payoff.
    def interact_seal(source, station)
      opens = station[:opens]
      return false if breached?(@zone_name, opens)
      price = @economy.fetch(station[:price].to_sym)
      return station_refuse!(station[:at]) unless @stations.spend_banked(source, price, :breach)
      restore_breach!(@zone_name, opens)
      @breach_line = { text: station[:line],
                       frames_left: @display[:breach_banner_frames],
                       frames_total: @display[:breach_banner_frames] }
      # v16 (c): the breach is a located court act — the seal presses at
      # the STATION (where the toll was paid), not the opened way: the way
      # flips to gate-gold the same frame, and a gold mark on a gold tile
      # cannot read (live deviation from the spec's exemplar, capture-
      # verified frame 1430; the slab→gold flip already marks the way).
      mark_seal!(station[:at])
      @feel.on_kill
      @bus.emit(:seal_breached, zone: @zone_name, tile: opens, cost: price)
      station_cue!(:breached, station[:at])
    end

    # The cue pins the fixture tile at transaction time — deriving it from
    # proximity at draw time would let a moving player drag the flash onto a
    # neighboring fixture (impl review, Codex finding 4). n: optional
    # numeral for <N>-substituting kinds (T5) — digest-excluded like the cue.
    def station_cue!(kind, tile, n: nil)
      @station_cue = { kind:, at: tile, n:, frames_left: @display[:station_cue_frames] }
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
      # The wipe vessel = the first seat-held body in seat order (bare
      # possessed, as today; a waiting seat 1 falls through to seat 2's).
      vessel = controlled_bodies.first
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
      @field.clear_unloaded_pack_husks
      assign_seats_after_judgment(revived)
      enter_zone(@home_zone, map.pack_spawn)
      @bus.emit(:pack_respawned)
    end

    # Judgment seats (decision 3): seats claim over the ACTUAL revived set
    # in seat order. A seat whose body revived keeps it (no event — the
    # old law); otherwise it claims the nearest unclaimed revived body
    # (the old snap selection, per seat); none left = waiting-for-body
    # (the one-vessel floor: seat 1 takes the kept vessel, seat 2 waits —
    # recorded half-B feel risk).
    def assign_seats_after_judgment(revived)
      claimed = []
      @seats.each do |seat|
        old = @pack.possessed(seat)
        if old && revived.include?(old) && !claimed.include?(old)
          claimed << old
          next
        end
        candidates = revived.reject { |m| claimed.include?(m) }
        target =
          if old
            candidates.min_by { |m| [tile_distance(m.tile, old.tile), @pack.members.index(m)] }
          else
            candidates.min_by { |m| @pack.members.index(m) }
          end
        @pack.possess!(target, seat:)
        if target
          claimed << target
          @bus.emit(:possession_changed, from: old, to: target, forced: true)
        end
      end
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
      @field.prune_corpses!(@zone_name, @frame)
    end

    def emit_attack_hit(attacker, victim, landed)
      if landed && (seat = seat_for(attacker))
        @last_damaged[seat] = victim
      end
      # kind/landed (v13): stamped at EMIT time — sim-exact even if the
      # action state transitions before the bus processes.
      @bus.emit(:attack_hit, attacker:, victim:,
                kind: attacker.current_action, landed:)
    end

    def validate_mark
      target = marked_target
      return unless target
      leash = @balance[:pack][:mark_leash_tiles]
      # v17 decision 4: the mark holds while ANY seat-held body stays in
      # leash (both seats set it). Deliberately NO dead? filter — the old
      # law measured from the possessed pointer even mid-death-flush
      # (forced swap lands at bus-process; the mark must survive that gap
      # exactly as it always did). Waiting seats (nil) drop out naturally.
      held = controlled_bodies.any? do |b|
        tile_distance(b.tile, target.tile) <= leash
      end
      @pack.clear_mark! if target.dead? || !held
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

    # A body stays where it fell and fades — the records + cap live in
    # FieldEconomy now; the constant stays addressable here for the
    # renderer and the corpse tests (Game::World::CORPSE_FADE_FRAMES).
    CORPSE_FADE_FRAMES = FieldEconomy::CORPSE_FADE_FRAMES

    # Respawn-stream derivation salt (v14) — determinism plumbing like the
    # corpse constants above, not a tunable.
    RESPAWN_STREAM_SALT = 0x52455350

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

      # v20 T4: the pulse's world-located presentation record (taunt-pulse
      # grammar; digest-excluded like every transient) — the sim half
      # already happened inside Stations#tick_totems!.
      @bus.subscribe(:totem_pulse) do |e|
        @transients.totem_pulse!(at: e[:at], pulse_frames: @display[:totem_pulse_frames],
                                 range_tiles: e[:range])
      end

      @bus.subscribe(:attack_hit) do |e|
        if controlled?(e[:victim])
          @feel.on_player_hit
        elsif controlled?(e[:attacker])
          @feel.on_hit
        end
      end

      @bus.subscribe(:actor_died) do |e|
        corpse_record = @field.leave_corpse(e[:actor], zone: @zone_name, frame: @frame)
        @field.spawn_drop(e[:actor], zone: @zone_name,
                          multiplier: gradient_multiplier(e[:actor].tile),
                          band: gradient_band(e[:actor].tile))
        # D1: a dying pack body's carried value transfers to a container on
        # its corpse. Term expiry is the permanent-loss tier now.
        if e[:actor].faction == :pack && e[:actor].carried.positive?
          @field.spawn_corpse_load(e[:actor], corpse_record, zone: @zone_name)
        end
        @pack.clear_mark! if e[:actor].equal?(marked_target)
        # v16 (e): every death POPS — transient render record, integer phase
        # seeded by (tile, frame) so replays are byte-identical.
        @transients.kill_pop!(tile: e[:actor].tile, frame: @frame)
        if e[:faction] == :human
          # P2/A2: any pack body feeds the shared pack progression.
          if e[:killer]&.faction == :pack &&
             @progression.award_kill(e[:actor].kit_name) == :level_up
            @pack.sync_max_hp!(progression: @progression)
            @bus.emit(:level_up, level: @progression.level)
            # T3 feel beat (P4, presentation pushes only): gold stamp +
            # gold pops on every LIVING tile — the pack is the carrier (A2).
            enqueue_stamp("stamp.level_up", "LEVEL", suffix: " #{@progression.level}")
            @pack.living.each { |m| @transients.level_up_pop!(tile: m.tile, frame: @frame) }
          end
          @feel.on_kill if controlled?(e[:killer])
          # v15: the challenger's death closes the boss fight (placeholder
          # text per the 2026-08-16 owner order: no lore in this repo).
          # v18 F1: the defeat ACCRUES (persisted, Progression's ledger).
          if e[:actor].kit[:seize]
            @progression.record_boss_1_defeat!
            enqueue_stamp("challenger.term.line", "BOSS 1 DEFEATED",
                          at: e[:actor].tile)
          end
          schedule_human_respawn(e[:actor])
        elsif (seat = seat_for(e[:actor]))
          handle_seat_death(seat)
        end
      end
    end

    def handle_seat_death(seat)
      from = @pack.possessed(seat)
      survivor = @pack.forced_swap!(seat)
      if survivor
        @rearm_needed[seat] = true
        @feel.on_kill # losing a body lands like a kill against you
        @bus.emit(:possession_changed, from:, to: survivor, forced: true)
      elsif @pack.wipe?
        # Exactly-once guard (Codex fold #6): two controlled bodies dying
        # in the SAME bus flush must not double-emit or double-transition —
        # the second death finds the state already switched.
        return if @states.current == :nest_respawn
        @bus.emit(:pack_wiped)
        # D1 wipe grace: the run back must always be possible — every
        # container's remaining term rises to at least the grace floor.
        # (The grace covers the RUN BACK, not the veil: terms are frozen
        # during nest_respawn and the veil is only 90 frames — review CF-6.)
        grace = @death[:wipe_grace_frames]
        @field.apply_wipe_grace!(grace)
        # v15: chants + seizures clear AT :nest_respawn ENTRY, not at
        # respawn — the veil bypasses tick_world, so a chant aborted only
        # in respawn_pack would freeze mid-count under it (Codex pass-2).
        # Seizures on dead bodies already ended why=:died this frame; the
        # sweep is the idempotent safety net.
        @pack.members.each { |m| end_seizure(m, :wiped) if m.seize_active? }
        abort_all_chants!
        @respawn_timer = @balance[:respawn_frames]
        @states.transition_to(:nest_respawn)
      else
        # Waiting-for-body (decision 3): the partner holds the last living
        # flesh — forced_swap! nil'd this seat's pointer; the camera
        # spectates the partner; auto-repossess at the first revive/regrow.
        # Losing the body still lands like a kill (feel is global sim
        # state, decision 11). Unreachable single-seat.
        @feel.on_kill
      end
    end

    # Decision 3: a waiting seat takes the first living uncontrolled body
    # in ROSTER order the moment one exists (vat regrow; the judgment runs
    # its own seat assignment). Re-arm applies — no held key leaks into
    # the new body (law 2).
    def assign_waiting_seats
      @seats.each do |seat|
        next if @pack.possessed(seat)
        target = @pack.members.find { |m| !m.dead? && !controlled?(m) }
        next unless target
        @pack.possess!(target, seat:)
        @rearm_needed[seat] = true
        @bus.emit(:possession_changed, from: nil, to: target, forced: true)
      end
    end

    # Decision 11 seizure targeting: nearest living controlled body,
    # Chebyshev, tie -> lower roster index.
    def nearest_controlled_to(creature)
      controlled_bodies.reject(&:dead?).min_by do |b|
        [tile_distance(creature.tile, b.tile), @pack.members.index(b)]
      end
    end

    # Decision 3 spectate: a waiting seat's camera follows the partner;
    # the roster head is the total fallback (unreachable outside a full
    # wipe, where pointers keep their dead bodies).
    def camera_anchor(seat)
      @pack.possessed(seat) || controlled_bodies.first || @pack.members.first
    end

    def seat_input(inputs, seat) = inputs.fetch(seat) { @null_input }

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
      # v18 decision 11: respawn relief at SCHEDULE time (owner Q3a — the
      # cross-zone walk-back), explicit Integer; seats=1 never evaluates.
      delay = (delay * @coop[:respawn_delay_scale]).round if @coop
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
