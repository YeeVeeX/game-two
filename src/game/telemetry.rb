module Game
  # D1 fun-verify instrumentation (spec review FN-1): a session that never
  # fired the corpse run must be machine-distinguishable from one that fired
  # and fell flat — "N/A never fired" indicts combat threat, not the corpse
  # system. Counts only; the per-recovery metrics derive from EVENT log lines.
  class Telemetry
    EVENTS = %i[corpse_loaded corpse_looted carried_lost pack_wiped banked].freeze

    def initialize(bus)
      @counts = Hash.new(0)
      EVENTS.each { |ev| bus.subscribe(ev) { @counts[ev] += 1 } }
    end

    def summary
      "TELEMETRY d1_fired carrying_deaths=#{@counts[:corpse_loaded]} " \
        "wipes=#{@counts[:pack_wiped]} corpse_looted=#{@counts[:corpse_looted]} " \
        "carried_lost=#{@counts[:carried_lost]} banked_events=#{@counts[:banked]}"
    end
  end
end
