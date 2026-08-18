module App
  # v18 session-8 soak (brief D1/D2): the seeded test driver behind
  # --bot. A PURE input source on the existing seam (update(tick) /
  # down?(action)) — the session samples it once per executed lockstep
  # tick exactly like a keyboard, solo samples it per world frame. Never
  # OS events: hidden/unfocused windows must still play (the ticks=0
  # idle-seat trap), and SendKeys dies against Windows focus rules.
  #
  # Policy is DELIBERATELY dumb (test driver, not gameplay AI — the
  # moment this gets tuned for realism, stop and record): seeded RNG
  # direction bursts with persistence, fixed modular verb cadences
  # phase-shifted by seed so two seats never mirror each other, quit at
  # quit_tick (the WINDOW watches quit? and drives its own Esc path —
  # quitting is an app-layer concern, not an input bit).
  #
  # Determinism (brief D2): held actions are a pure function of
  # (seed, sampled tick sequence) — same seed + same peer ⇒ same
  # episode; the banner line makes every soak episode re-runnable from
  # its log. RNG is consumed only at burst boundaries (tick >= @until),
  # so re-sampling a stalled tick never advances the stream.
  class Autopilot
    DEFAULT_QUIT_TICK = 36_000 # the ritual floor (>= 10 sim-min)

    DIRECTIONS = %i[left right up down].freeze
    # Verb cadence: [action, period, hold] — hold `action` for `hold`
    # ticks every `period` ticks. Every legal Protocol::ACTIONS verb gets
    # exercised (code-path coverage, not realism); movement dominates.
    VERBS = [[:attack, 45, 6], [:dodge, 210, 4], [:special, 420, 4],
             [:interact, 300, 8], [:mark, 900, 4], [:swap, 1200, 2],
             [:sustain, 1500, 4]].freeze

    attr_reader :seed, :quit_tick

    def initialize(seed:, quit_tick: DEFAULT_QUIT_TICK)
      @seed = seed
      @quit_tick = quit_tick
      @rng = Random.new(seed)
      @phase = seed % 97
      @held_dirs = []
      @until = 0
      @current = []
    end

    # The one new output line (oracle surface frozen): printed by main.rb
    # ONLY under --bot; a soak episode replays from these two numbers.
    def banner = "AUTOPILOT seed=#{@seed} quit_tick=#{@quit_tick}"

    def quit?(tick) = tick >= @quit_tick

    def update(tick)
      roll_directions(tick) if tick >= @until
      @current = @held_dirs + VERBS.filter_map do |action, period, hold|
        action if (tick + @phase) % period < hold
      end
    end

    def down?(action) = @current.include?(action)

    private

    # Movement persistence: hold a direction set for 20-90 ticks; some
    # bursts idle, some go diagonal — enough variety to roam zones and
    # trip transitions without any notion of goals.
    def roll_directions(tick)
      @until = tick + 20 + @rng.rand(71)
      roll = @rng.rand(48)
      @held_dirs =
        if roll < 8
          []
        elsif roll < 16
          [DIRECTIONS[@rng.rand(4)], DIRECTIONS[@rng.rand(4)]].uniq
        else
          [DIRECTIONS[@rng.rand(4)]]
        end
    end
  end
end
