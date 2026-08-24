module Game
  # s68 difficulty tier (owner datum s67: "a partir de nivel 8 ... muy
  # fácil"; Kimi Q4 frame: per-zone stat tiers, NEVER global scaling —
  # ZONE 1 trivial at level 8 is CORRECT, the deep must bite instead).
  # Plain object (PriceSheet/Crossing pattern): parses + validates
  # data/balance/tiers.json at World construction, applies at the ONE
  # enemy spawn seam (World#add_human — seed, respawn, and boss all flow
  # through it, the v18 coop precedent). A zone with no row is IDENTITY
  # with ZERO arithmetic (the coop seats=1 law), which is what keeps the
  # sim-identity canaries byte-stable by construction. Grammar is the
  # progression house style: Integer pct on kit base, base + base·pct/100
  # with Integer division — no Float ever enters the balance path.
  # Composition pin extends P5: kit base -> zone tier (Integer) -> coop
  # scalar (Float, explicit .round) — tier BEFORE coop at the call site.
  class TierSheet
    ROW_KEYS = %i[enemy_hp_pct enemy_dmg_pct].freeze

    # config: parsed data/balance/tiers.json (symbolized). zones: the
    # loaded zone names — every row key must name one (typo honesty;
    # a row for a spawnless zone is legal dormant data: content-fill
    # and wire-ins land INTO a pre-declared tier).
    def initialize(config:, zones:)
      table = config.fetch(:zones)
      unless table.is_a?(Hash)
        raise ArgumentError, "tiers zones: must be a Hash of zone rows (got #{table.inspect})"
      end
      @rows = table.to_h { |zone, row| [zone.to_s, validate!(zone.to_s, row, zones)] }.freeze
    end

    # Integer in, Integer out; identity when the zone carries no row.
    def hp_for(zone, base)
      row = @rows[zone]
      return base unless row
      base + (base * row[:enemy_hp_pct]) / 100
    end

    def dmg_pct(zone)
      row = @rows[zone]
      row ? row[:enemy_dmg_pct] : 0
    end

    # The spawn-seam verb (World#add_human only, spawn time): stamps both
    # halves on the body. No row = no call into the creature at all —
    # the zero-arithmetic identity is structural, not numeric.
    def apply!(creature, zone)
      row = @rows[zone]
      return unless row
      creature.tier_max_hp!(row[:enemy_hp_pct])
      creature.tier_damage!(row[:enemy_dmg_pct])
    end

    private

    def validate!(zone, row, zones)
      unless zones.include?(zone)
        raise ArgumentError,
              "tiers zone #{zone.inspect}: no such zone loaded " \
              "(have: #{zones.sort.inspect}) — typo honesty, fix the key"
      end
      unless row.is_a?(Hash) && row.keys.sort == ROW_KEYS.sort
        raise ArgumentError,
              "tiers zone #{zone}: row must carry exactly enemy_hp_pct + " \
              "enemy_dmg_pct (got #{row.inspect})"
      end
      ROW_KEYS.each do |key|
        v = row[key]
        unless v.is_a?(Integer) && v >= 0
          raise ArgumentError,
                "tiers zone #{zone} #{key}: must be a non-negative Integer " \
                "(got #{v.inspect} — no Float ever enters the balance path)"
        end
      end
      row.slice(*ROW_KEYS).freeze
    end
  end
end
