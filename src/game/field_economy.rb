module Game
  # The field-value economy as a plain object (v18 extract-on-touch: the
  # 2026-08-15 process-debt review named drops/corpses the cleanest seam,
  # and the line-cap gate called it due) — drop piles, cosmetic corpse
  # records, carried-value containers (corpse loads), expiry flashes.
  #
  # World CALLS these in explicit tick order; there are no bus
  # subscriptions here (in-sim bus mediation is banned — determinism +
  # debuggability). Every method body moved VERBATIM from World; zone and
  # frame arrive as parameters where World read @zone_name/@frame. The
  # wall canary sweep pins byte-identity of the move.
  class FieldEconomy
    # A body stays where it fell and fades (vision critique: kills that
    # vanish erase the fight's history). Records, not creatures — the sim
    # never reads them; only renderer/tests do. Cap guards the roster.
    CORPSE_FADE_FRAMES = 600
    CORPSE_CAP = 40

    attr_reader :corpse_serial

    def initialize(bus:, rng:, drops_cfg:, death_cfg:)
      @bus = bus
      @rng = rng
      @drops_cfg = drops_cfg
      @death = death_cfg
      @corpses = Hash.new { |h, k| h[k] = [] }
      @drops = Hash.new { |h, k| h[k] = [] }
      @corpse_loads = Hash.new { |h, k| h[k] = [] }
      @expiry_flashes = Hash.new { |h, k| h[k] = [] }
      @corpse_serial = 0
    end

    # Live per-zone lists — station verbs mutate them in place (pickup /
    # loot delete records), exactly as they did on World's ivars.
    def drops(zone) = @drops[zone]
    def corpses(zone) = @corpses[zone]

    # Non-autovivifying: the renderer reads these every draw and a
    # default-proc index would insert keys into sim state from the draw
    # path (pure-reader law).
    def corpse_loads(zone) = @corpse_loads.fetch(zone) { [] }
    def expiry_flashes(zone) = @expiry_flashes.fetch(zone) { [] }

    def total_stranded = @corpse_loads.values.sum { |list| list.sum { |c| c[:amount] } }

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
    def tick_corpse_loads(frame:)
      @corpse_loads.each do |zone, list|
        list.each do |c|
          c[:settle_left] -= 1 if c[:settle_left].positive?
          c[:term_left] -= 1
        end
        list.reject! do |c|
          next false if c[:term_left].positive?
          @bus.emit(:carried_lost, amount: c[:amount], tile: c[:tile], zone:)
          release_corpse_record(zone, c[:id], frame:)
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
    def release_corpse_record(zone, container_id, frame:)
      rec = @corpses[zone].find { |c| c[:container_id] == container_id }
      return unless rec
      rec.delete(:container_id)
      rec[:at_frame] = frame
    end

    # Seeded roll (rolls happen at bus-process time in emit order, AFTER the
    # tick_world scatter picks — consumption order is replay-deterministic).
    # One drop per tile, always: a kill on an occupied tile merges amounts
    # but KEEPS the first kill's clock — a resetting clock + the 5s rusher
    # respawn would make any camped tile an immortal zero-risk stash. The
    # merge also keeps the band: band is a function of tile, so a same-tile
    # kill can never disagree with the record it merges into (v11 rider).
    # multiplier/band are computed by World (they read the zone gradient —
    # pure lookups, no draws, so evaluation order vs the roll is inert).
    def spawn_drop(victim, zone:, multiplier:, band:)
      table = victim.kit[:drop_table]
      return unless table
      amount = (table[@rng.rand(table.length)] * multiplier).round
      decay = @drops_cfg[:decay_frames]
      list = @drops[zone]
      drop = list.find { |d| d[:tile] == victim.tile }
      if drop
        drop[:amount] += amount
      else
        list << { tile: victim.tile, amount:, frames_left: decay, decay_frames: decay,
                  band: }
      end
      @bus.emit(:drop_spawned, tile: victim.tile, amount:)
    end

    # Returns the record it appended, or nil when that record was itself the
    # cap-eviction victim (every other record linked) — the caller must stamp
    # THIS identity, never corpses.last, or a foreign container's link gets
    # clobbered (impl review fold 3).
    def leave_corpse(actor, zone:, frame:)
      list = @corpses[zone]
      record = { tile: actor.tile, x: actor.x, y: actor.y,
                 faction: actor.faction, at_frame: frame,
                 kit_name: actor.kit_name } # presentation: the corpse sprite
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
    def spawn_corpse_load(actor, corpse_record, zone:)
      @corpse_serial += 1
      term = @death[:corpse_term_frames]
      record = { id: @corpse_serial, tile: actor.tile, amount: actor.drain_carried!,
                 term_left: term, term:, settle_left: @death[:loot_settle_frames],
                 settle_alpha: @death[:settle_pip_alpha] }
      @corpse_loads[zone] << record
      corpse_record[:container_id] = @corpse_serial if corpse_record
      @bus.emit(:corpse_loaded, actor:, tile: record[:tile], amount: record[:amount])
    end

    # Dissolved flesh leaves no field husk (spec S Presentation-5). Loaded
    # records are D1 pile markers under wipe grace — never touched.
    def clear_unloaded_pack_husks
      @corpses.each_value do |list|
        list.reject! { |c| c[:faction] == :pack && !c[:container_id] }
      end
    end

    # D1 wipe grace: the run back must always be possible — every
    # container's remaining term rises to at least the grace floor.
    # (The grace covers the RUN BACK, not the veil: terms are frozen
    # during nest_respawn and the veil is only 90 frames — review CF-6.)
    def apply_wipe_grace!(grace)
      @corpse_loads.each_value do |list|
        list.each { |c| c[:term_left] = [c[:term_left], grace].max }
      end
    end

    # Cosmetic corpse fade (records the sim never reads; prune keeps the
    # roster bounded). Loaded records hold at full strength.
    def prune_corpses!(zone, frame)
      @corpses[zone].reject! { |c| !c[:container_id] && frame - c[:at_frame] > CORPSE_FADE_FRAMES }
    end

    # v17 digest lane (spec decision 6): drop + load groups, zones in
    # sorted order — spliced into World#digest_snapshot between impacts
    # and respawns (the pinned group order).
    def digest_groups
      groups = []
      @drops.keys.sort.each do |zone|
        @drops[zone].each_with_index do |d, i|
          groups << ["drop.#{zone}.#{i}", [
            ["tile_x", d[:tile][0]], ["tile_y", d[:tile][1]], ["amount", d[:amount]],
            ["frames_left", d[:frames_left]], ["band", d[:band]]
          ]]
        end
      end
      @corpse_loads.keys.sort.each do |zone|
        @corpse_loads[zone].each do |c|
          groups << ["load.#{zone}.#{c[:id]}", [
            ["tile_x", c[:tile][0]], ["tile_y", c[:tile][1]], ["amount", c[:amount]],
            ["term_left", c[:term_left]], ["settle_left", c[:settle_left]]
          ]]
        end
      end
      groups
    end
  end
end
