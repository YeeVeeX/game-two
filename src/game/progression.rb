module Game
  # Lane 1 T1 (spec P14, the Crossing/FieldEconomy/PriceSheet pattern):
  # ONE home for every persistent growth fact — the pack level, xp
  # (progress INTO the current level, P3 — never cumulative), and the
  # v18 growth counters (boss_1_defeats accrues across sessions while
  # the fight re-arms each session; sessions is bumped by the save
  # coordinator at write time, never by the sim). Plain object: World
  # constructs it, calls it, digests through it — no bus subscription
  # inside, no IO, all constants from data/balance/progression.json
  # (Rule 3). T1 carves + persists; nothing calls award yet — the kill
  # hook, stat growth and TELEMETRY go live in T2.
  class Progression
    attr_reader :level, :xp, :boss_1_defeats, :sessions

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
      @level = 1
      @xp = 0
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

    # P2/P4 award core — pure state math; T2 wires actor_died into it
    # (award_kill(kit_name) reading the kill_xp table lands there).
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
  end
end
