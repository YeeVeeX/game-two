module Game
  # Renderer-facing price sheet — extracted from World 2026-08-20 when the
  # R-A2 provision readers tripped the world.rb growth ceiling (line-cap
  # law: extract the subsystem you are touching). Plain object, explicit
  # deps, no in-sim bus mediation: economy data (Rule 3 — every number
  # lives in data/balance/economy.json), the live Pack, and World's breach
  # predicate as a method object (synchronous + deterministic — never a
  # bus hop). World keeps one-line delegations so every call site and test
  # reads exactly as before; the sim quotes, the renderer computes nothing.
  class PriceSheet
    def initialize(economy:, pack:, breached:, mercy:)
      @economy = economy
      @pack = pack
      @breached = breached
      @mercy = mercy
    end

    # What THIS station charges right now. Bank has no price (nil) — its
    # interact verb (banking) is free; the SUSTAIN buy price is the
    # provision reader pair below.
    def station_price(station, zone)
      case station[:type]
      when "altar" then @economy[:inscribe_cost]
      when "vat" then vat_quote(zone)[:cost]
      when "seal"
        # A spent seal shows no price — the toll line is the discovery
        # mechanism while sealed, and noise once the way stands open.
        @breached.call(zone, station[:opens]) ? nil : @economy.fetch(station[:price].to_sym)
      end
    end

    # R-A2: the bank BUY hint composes verb + price from these.
    def provision_cost = @economy[:provision_cost]
    def provision_cap = @economy[:provision_cap]

    # B4 mercy floor (foundation row 9, RATIFIED-G+J): the session's FIRST
    # regrow, taken at the HOME hub, is guaranteed affordable — when the
    # pack cannot pay the full tribute, the charge clamps to a data-tuned
    # share of banked (mercy_floor_spend_pct: 100 = everything they have,
    # integer floor). Field/dungeon vats never clamp; an affordable tribute
    # pays full price everywhere (a floor, not a discount). World owns the
    # arming/consumption state (the mercy: method object); this object only
    # prices — and it is the ONE source of the vat number, so the renderer
    # hint and the charge can never drift apart.
    def vat_quote(zone)
      dead = @pack.members.count(&:dead?)
      base = @economy[:regrow_cost] * dead +
             @economy[:heal_cost_per_body] * @pack.living.count { |m| m.hp < m.max_hp }
      if dead.positive? && base > @pack.banked && @mercy.call(zone)
        { cost: @pack.banked * @economy.fetch(:mercy_floor_spend_pct) / 100, mercy: true }
      else
        { cost: base, mercy: false }
      end
    end
  end
end
