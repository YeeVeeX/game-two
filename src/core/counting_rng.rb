module Core
  # Value-transparent counting delegate over a Random stream (v17 digest
  # lane, panel fold): the netplay digest compares DRAW COUNTS instead of
  # Marshal.dump(Random) bytes (not a documented-stable serialization).
  # rand returns the SAME values as the naked stream — wall byte-identity
  # is untouched by construction. A diverged stream surfaces at its next
  # draw through positions/drops/spawns already in the state snapshot, so
  # detection lag is at most one digest window.
  class CountingRng
    attr_reader :draws

    def initialize(rng)
      @rng = rng
      @draws = 0
    end

    def rand(*args)
      @draws += 1
      @rng.rand(*args)
    end
  end
end
