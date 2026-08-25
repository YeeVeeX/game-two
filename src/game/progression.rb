module Game
  # Lane 1 T1 (spec P14, the Crossing/FieldEconomy/PriceSheet pattern):
  # ONE home for every persistent growth fact — the pack level, xp
  # (progress INTO the current level, P3 — never cumulative), and the
  # v18 growth counters (boss_1_defeats accrues across sessions while
  # the fight re-arms each session; sessions is bumped by the save
  # coordinator at write time, never by the sim). Plain object: World
  # constructs it, calls it, digests through it — no bus subscription
  # inside, no IO, all constants from data/balance/progression.json
  # (Rule 3). T1 carved + persisted it; T2 wires kill XP and stat growth
  # into the live sim.
  class Progression
    attr_reader :level, :xp, :kills_xp, :boss_1_defeats, :sessions

    def initialize(config:)
      curve = config.fetch(:curve)
      @k = curve.fetch(:k)
      @level_cap = curve.fetch(:level_cap)
      unless @k.is_a?(Integer) && @k.positive? &&
             @level_cap.is_a?(Integer) && @level_cap >= 1
        raise ArgumentError,
              "progression curve: k and level_cap must be positive Integers " \
              "(got k=#{@k.inspect}, level_cap=#{@level_cap.inspect} — " \
              "no Float ever enters the balance path)"
      end
      growth = config.fetch(:growth)
      @dmg_growth_pct = growth.is_a?(Hash) ? growth[:dmg_growth_pct] : nil
      @hp_growth_pct = growth.is_a?(Hash) ? growth[:hp_growth_pct] : nil
      unless @dmg_growth_pct.is_a?(Integer) && @dmg_growth_pct >= 0 &&
             @hp_growth_pct.is_a?(Integer) && @hp_growth_pct >= 0
        raise ArgumentError,
              "progression growth: dmg_growth_pct and hp_growth_pct must be " \
              "non-negative Integers (got dmg=#{@dmg_growth_pct.inspect}, " \
              "hp=#{@hp_growth_pct.inspect} — no Float ever enters the balance path)"
      end
      @kill_xp = config.fetch(:kill_xp)
      unless @kill_xp.is_a?(Hash) && @kill_xp.keys.all? { |key| key.is_a?(Symbol) } &&
             @kill_xp.values.all? { |amount| amount.is_a?(Integer) && amount.positive? }
        raise ArgumentError,
              "progression kill_xp: keys must be Symbols and every amount a positive " \
              "Integer (got #{@kill_xp.inspect})"
      end
      @spell_growth = parse_spell_growth(config.fetch(:spell_growth))
      @level = 1
      @xp = 0
      @kills_xp = 0
      @boss_1_defeats = 0
      @sessions = 0
    end

    attr_reader :level_cap

    # P1: ΔE(L) = k·(L² − 3L + 4) — the XP cost of going from level L−1
    # to L (shelf-verified Tibia-family quadratic, k data-driven; the
    # −3L term keeps early levels near-free). Integer in, Integer out.
    def delta_e(level)
      @k * (level * level - 3 * level + 4)
    end

    # P5: kit base -> level growth, Integer-only. Level 1 is identity.
    def damage_for(base) = base + (base * (@level - 1) * @dmg_growth_pct) / 100
    def max_hp_for(base) = base + (base * (@level - 1) * @hp_growth_pct) / 100

    # P10 reader: floor-match — the active array is the highest threshold
    # <= level; below the first threshold the kit BASE array returns by
    # IDENTITY (the wall's below-threshold md5 no-op is this line).
    # Progression never reads combat.json: the base arrives as an
    # argument (damage_for precedent — values in, values out).
    def special_impact_distances_for(kit_name, base:)
      rows = @spell_growth[kit_name]
      return base unless rows
      active = base
      rows.each { |threshold, distances| active = distances if threshold <= @level }
      active
    end

    # J-3 panel reader (presentation asks, progression answers): the
    # lowest growth threshold STRICTLY above the current level for this
    # kit — nil when no further tier exists or the kit never grows. The
    # stats panel shows the mid/late-bloomer curve honestly without ever
    # walking the growth table itself.
    def next_spell_growth_level(kit_name)
      rows = @spell_growth[kit_name]
      return nil unless rows
      row = rows.find { |threshold, _| threshold > @level }
      row&.first
    end

    # P2: session-earned XP counts the configured amount even when the
    # progression bar is pinned at cap (P12's observability semantics).
    def award_kill(kit_name)
      amount = @kill_xp.fetch(kit_name) do
        raise ArgumentError,
              "no kill_xp for kit #{kit_name.inspect} in data/balance/progression.json"
      end
      @kills_xp += amount
      award(amount)
    end

    # P2/P4 award core — pure state math; actor_died reaches it through
    # award_kill so every income amount comes from the kit table.
    # Returns :level_up when at least one level landed, else nil.
    # Invariant on exit: xp < ΔE(level+1) ALWAYS — a save projected
    # mid-session must reload without clamp warnings (the projector-
    # invariant law); at the cap, overflow xp pins just under the
    # ceiling (T2 may revisit what a capped bar displays).
    def award(amount)
      @xp += amount
      leveled = false
      while @level < @level_cap && @xp >= delta_e(@level + 1)
        @xp -= delta_e(@level + 1)
        @level += 1
        leveled = true
      end
      ceiling = delta_e(@level + 1)
      @xp = ceiling - 1 if @xp >= ceiling
      leveled ? :level_up : nil
    end

    def record_boss_1_defeat! = @boss_1_defeats += 1

    # --- save-apply seams (SaveState.apply! only — construction time;
    # values are validated + clamped upstream by the strict decoder) ---

    def load_counters!(boss_1_defeats:, sessions:)
      @boss_1_defeats = boss_1_defeats
      @sessions = sessions
    end

    def load_progress!(level:, xp:)
      @level = level
      @xp = xp
    end

    private

    # P10: per-kit spell growth — full-array replacement per level
    # threshold; {} is legal (no growth anywhere). Parsed ONCE into
    # frozen sorted-ascending [threshold, distances] pairs. Refusals
    # are NAMED (kill_xp style): unknown spell keys (typo honesty),
    # non-Integer or non-positive threshold keys, thresholds above
    # level_cap (a row no reachable level can activate is dead data —
    # authors own balance files and refuse; players own saves, which
    # clamp), and empty or non-positive-Integer distance arrays.
    # Ascending order INSIDE a distances array is not legislated —
    # volley geometry is order-insensitive (max + include?).
    def parse_spell_growth(table)
      unless table.is_a?(Hash)
        raise ArgumentError,
              "progression spell_growth: must be a Hash of kits (got #{table.inspect})"
      end
      table.to_h do |kit_name, spells|
        unless spells.is_a?(Hash) && spells.keys.all? { |k| k == :special_impact_distances }
          raise ArgumentError,
                "progression spell_growth #{kit_name}: only special_impact_distances " \
                "grows today (got #{spells.inspect})"
        end
        rows = spells.fetch(:special_impact_distances, {})
        unless rows.is_a?(Hash)
          raise ArgumentError,
                "progression spell_growth #{kit_name}: special_impact_distances must be " \
                "a Hash of level-threshold rows (got #{rows.inspect})"
        end
        [kit_name, parse_growth_rows(kit_name, rows)]
      end.freeze
    end

    def parse_growth_rows(kit_name, rows)
      rows.map do |key, distances|
        threshold = Integer(key.to_s, 10, exception: false)
        unless threshold&.positive?
          raise ArgumentError,
                "progression spell_growth #{kit_name}: threshold #{key.inspect} must be " \
                "a positive Integer level"
        end
        if threshold > @level_cap
          raise ArgumentError,
                "progression spell_growth #{kit_name}: threshold #{threshold} exceeds " \
                "level_cap #{@level_cap} — dead row; delete or re-key it consciously"
        end
        unless distances.is_a?(Array) && !distances.empty? &&
               distances.all? { |d| d.is_a?(Integer) && d.positive? }
          raise ArgumentError,
                "progression spell_growth #{kit_name} #{threshold}: distances must be a " \
                "non-empty Array of positive Integers (got #{distances.inspect} — " \
                "no Float ever enters the balance path)"
        end
        [threshold, distances.freeze]
      end.sort_by(&:first).freeze
    end
  end
end
