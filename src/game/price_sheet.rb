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
    def initialize(economy:, pack:, breached:)
      @economy = economy
      @pack = pack
      @breached = breached
    end

    # What THIS station charges right now. Bank has no price (nil) — its
    # interact verb (banking) is free; the SUSTAIN buy price is the
    # provision reader pair below.
    def station_price(station, zone)
      case station[:type]
      when "altar" then @economy[:inscribe_cost]
      when "vat"
        @economy[:regrow_cost] * @pack.members.count(&:dead?) +
          @economy[:heal_cost_per_body] * @pack.living.count { |m| m.hp < m.max_hp }
      when "seal"
        # A spent seal shows no price — the toll line is the discovery
        # mechanism while sealed, and noise once the way stands open.
        @breached.call(zone, station[:opens]) ? nil : @economy.fetch(station[:price].to_sym)
      end
    end

    # R-A2: the bank BUY hint composes verb + price from these.
    def provision_cost = @economy[:provision_cost]
    def provision_cap = @economy[:provision_cap]
  end
end
