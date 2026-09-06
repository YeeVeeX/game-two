module Game
  # The INTERACT verb, extracted from World (2026-09-06: the merge of T1 put
  # world.rb at 1800/1800; Game::Loot precedent). One shared path - pickup
  # first, bank second; the seal breach is the toll paid AT the station.
  # Mixed into World; every ivar/method it touches lives there. Byte-inert
  # at extraction (canaries OFF = ACTIVE x3).
  module Interact
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
      picked = pick_up_item(source) # S2/A4 (Game::Loot): true = took; false = refused -> station only
      return true if picked
      return refused_pickup_fallthrough(source) if picked == false

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
      station ? interact_station(source, station) : interact_rope(source)
    end

    def interact_station(source, station)
      case station[:type]
      when "bank"  then @stations.bank(source)
      when "altar" then @stations.altar(source)
      when "vat"   then @stations.vat(source)
      when "seal"  then interact_seal(source, station)
      else false # totem: deliberate no-op (pulses on its own clock; the L4 flip would land here)
      end
    end

    # T4 (D4): the way back up — a rope spot is a FREE station-type
    # interact (v0; rope-as-item waits for the items cycle).
    def interact_rope(source)
      t = map.transition_at(*source.tile)
      return false unless t && t[:type] == "rope_spot"
      cross_through(source, t)
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
  end
end
