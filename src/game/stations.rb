module Game
  # Station transactions — extracted from World 2026-08-29 (v20 T4,
  # foundation L10: world.rb at 1769/1800, the totem is the touching
  # ticket). Plain object, FieldEconomy/Volleys grammar: explicit deps,
  # World-owned effects reached through callables, no IO. World keeps
  # the interact dispatch + verb guards, interact_seal (breach registry is
  # save-law-coupled), regrow_binding (zone-binding law), and every
  # presentation write (station cues via the cue:/refuse: callables).
  class Stations
    def initialize(bus:, pack:, economy:, price_sheet:, zone:,
                   cue:, refuse:, regrow_binding:, consume_mercy:, assign_seats:)
      @bus = bus
      @pack = pack
      @economy = economy
      @price_sheet = price_sheet
      @zone = zone
      @cue = cue
      @refuse = refuse
      @regrow_binding = regrow_binding
      @consume_mercy = consume_mercy
      @assign_seats = assign_seats
      @sustain_done = false
    end

    # Per-tick transient reset (the old `@sustain_done = false` site in
    # tick_world, beside @aggro.reset! — never digest state).
    def reset! = @sustain_done = false

    def bank(source)
      return false unless source.carried.positive?
      amount = source.drain_carried!
      @pack.bank!(amount)
      @bus.emit(:banked, actor: source, amount:, banked: @pack.banked)
      true
    end

    def altar(source)
      return @refuse.(source.tile) if source.marked?
      return @refuse.(source.tile) unless spend_banked(source, @economy[:inscribe_cost], :inscribe)
      source.inscribe_mark!
      @bus.emit(:inscribed, body: source, cost: @economy[:inscribe_cost], banked: @pack.banked)
      @cue.(:inscribed, source.tile)
      true
    end

    # All-or-nothing full maintenance (spec S3): one price, one decision.
    # Regrowth binding stays World's (zone-binding law) — reached through
    # the regrow_binding callable; B4 mercy consumption is the session's
    # first regrow (consume_mercy callable owns the World ivar).
    def vat(source)
      dead = @pack.members.select(&:dead?)
      wounded = @pack.living.select { |m| m.hp < m.max_hp }
      return @refuse.(source.tile) if dead.empty? && wounded.empty?
      quote = @price_sheet.vat_quote(@zone.call)
      return @refuse.(source.tile) unless spend_banked(source, quote[:cost], :tribute)
      @consume_mercy.(dead.empty?)
      dead.each do |m|
        m.revive!(**@regrow_binding.(source, m))
        @bus.emit(:body_regrown, body: m)
      end
      wounded.each(&:heal_full!)
      @assign_seats.call
      @bus.emit(:tribute_paid, cost: quote[:cost], regrown: dead.length,
                healed: wounded.length, banked: @pack.banked)
      @cue.(:tribute, source.tile)
      true
    end

    # v18 decision 9 — the sustain verb (owner law 2026-08-11: priced,
    # portable, banked-funded — never a free cooldown). One edge-press,
    # one resolution through the SAME station lookup interact uses:
    # standing ON the bank station BUYS (banked reduces through the pack's
    # guarded verb — player-initiated at a station, the never-taxed law
    # holds); anywhere else USES (one charge, every living member healed
    # clamped; dead untouched — the vat keeps its regrowth monopoly).
    # Refusals cue + spend NOTHING (at_cap/broke/none/no_effect/seat_race
    # — never a silent eat). @sustain_done is the first-success-per-tick
    # latch: the seat-ordered controller loop resolves seat 1 first on
    # both machines, so a same-tick race deterministically awards the
    # action to seat 1 and refuses seat 2 THAT tick. World owns the verb
    # guards (controlled/dead/staggered/attack-idle) at its call site.
    def sustain(source, station:)
      return sustain_refuse!(source, :seat_race) if @sustain_done
      if station && station[:type] == "bank"
        refusal = @pack.buy_provision!(cost: @economy[:provision_cost],
                                       cap: @economy[:provision_cap])
        return sustain_refuse!(source, refusal) if refusal
        @sustain_done = true
        @bus.emit(:banked_spent, actor: source, amount: @economy[:provision_cost],
                  sink: :provision, banked: @pack.banked)
        @bus.emit(:provision_bought, actor: source,
                  provisions: @pack.provisions, banked: @pack.banked)
        @cue.(:provision_bought, source.tile)
      else
        refusal = @pack.use_provision!(heal: @economy[:provision_heal])
        return sustain_refuse!(source, refusal) if refusal
        @sustain_done = true
        @bus.emit(:provision_used, actor: source, provisions: @pack.provisions)
        @cue.(:provision_used, source.tile)
      end
      true
    end

    # Public on purpose: World's interact_seal spends through the SAME
    # audited seam (one banked_spent emitter; quote and charge never drift).
    def spend_banked(source, amount, sink)
      return false unless @pack.spend!(amount)
      @bus.emit(:banked_spent, actor: source, amount:, sink:, banked: @pack.banked)
      true
    end

    private

    # Sustain refusal (decision 9) = cue + event + NOTHING spent. Its OWN
    # cue kind (never :refused): the provision X-bar draws ABOVE the
    # presser's body with a text line — add-only, so the walled station
    # refusals keep their exact draw. The cue rides the station-cue channel
    # at the PRESSER's tile, pinned at press time (use refusals happen
    # anywhere; the cue-drag law).
    def sustain_refuse!(source, reason)
      @bus.emit(:provision_refused, actor: source, reason:)
      @cue.(:provision_refused, source.tile)
      false
    end
  end
end
