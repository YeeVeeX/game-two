module Game
  # Fun-verify instrumentation: D1 corpse-run counts (spec FN-1) plus the
  # fight-ledger counts (LB-1) — a session that never fired a system must be
  # machine-distinguishable from one that fired and fell flat. Counts only;
  # per-event metrics (cadence, net distribution) derive from the harness
  # EVENT log lines.
  #
  # A2 threat/pull economy line (FN-2): retarget causes, leashes, body deaths,
  # deepest gradient band reached — the fairness/consequence oracle for the
  # owner's sixth fun-verify.
  class Telemetry
    D1_EVENTS = %i[corpse_loaded corpse_looted carried_lost pack_wiped banked].freeze
    A2_RETARGET_CAUSES = %i[hate lowhp proximity acquired].freeze

    D1B_EVENTS = %i[inscribed mark_consumed body_dissolved body_regrown
                    tribute_paid vessel_kept].freeze

    def initialize(bus, world: nil)
      @world = world
      @counts = Hash.new(0)
      @retargets = Hash.new(0)
      @max_band = 0

      # D1 subscriptions
      D1_EVENTS.each { |ev| bus.subscribe(ev) { @counts[ev] += 1 } }
      bus.subscribe(:fight_resolved) do |e|
        @counts[:fights] += 1
        @counts[:recovery_fights] += 1 if e[:opened_by] == :recovery
        @counts[:negative_fights] += 1 if e[:net].negative?
      end

      # A2 subscriptions
      bus.subscribe(:human_retargeted) do |e|
        cause = e[:cause]
        @retargets[cause] += 1 if A2_RETARGET_CAUSES.include?(cause)
      end
      bus.subscribe(:human_leashed) { @counts[:leashes] += 1 }
      bus.subscribe(:actor_died) do |e|
        @counts[:body_deaths] += 1 if e[:faction] == :pack
      end
      bus.subscribe(:drop_spawned) do |e|
        next unless @world
        bands = @world.map.drop_gradient
        next unless bands
        d = @world.gate_distance(e[:tile])
        next if d == Float::INFINITY
        idx = bands.rindex { |(min, _)| d >= min }
        @max_band = idx if idx && idx > @max_band
      end

      # D1b subscriptions (FN-3): the meaning oracle — a session that never
      # spent must be machine-distinguishable from one that spent and felt
      # nothing.
      @spent = Hash.new(0)
      @banked_end = 0
      D1B_EVENTS.each { |ev| bus.subscribe(ev) { @counts[ev] += 1 } }
      bus.subscribe(:banked_spent) do |e|
        @spent[e[:sink]] += e[:amount]
        @banked_end = e[:banked]
      end
      bus.subscribe(:banked) { |e| @banked_end = e[:banked] }

      # Q6 cadence (v10.1): bank-trip sizes + kills by depth band — the
      # bank-now-or-push-deeper oracle. Trip yield == :banked amount (banking
      # drains all carried).
      @bank_amounts = []
      @kills_by_band = [0, 0, 0]
      bus.subscribe(:banked) { |e| @bank_amounts << e[:amount] }
      bus.subscribe(:actor_died) do |e|
        next unless e[:faction] == :human && @world
        bands = @world.map.drop_gradient
        next unless bands
        d = @world.gate_distance(e[:actor].tile)
        idx = bands.rindex { |(min, _)| d >= min }
        @kills_by_band[idx] += 1 if idx
      end
    end

    def summary
      "TELEMETRY d1_fired carrying_deaths=#{@counts[:corpse_loaded]} " \
        "wipes=#{@counts[:pack_wiped]} corpse_looted=#{@counts[:corpse_looted]} " \
        "carried_lost=#{@counts[:carried_lost]} banked_events=#{@counts[:banked]} " \
        "fights=#{@counts[:fights]} recovery_fights=#{@counts[:recovery_fights]} " \
        "negative_fights=#{@counts[:negative_fights]}\n" \
        "#{a2_summary}\n" \
        "#{d1b_summary}\n" \
        "#{q6_summary}"
    end

    def a2_summary
      "TELEMETRY a2_fired wipes=#{@counts[:pack_wiped]} " \
        "body_deaths=#{@counts[:body_deaths]} " \
        "retargets{hate=#{@retargets[:hate]} lowhp=#{@retargets[:lowhp]} " \
        "proximity=#{@retargets[:proximity]} acquired=#{@retargets[:acquired]}} " \
        "leashes=#{@counts[:leashes]} deepest_band=#{deepest_band} " \
        "banked=#{@counts[:banked]}"
    end

    def d1b_summary
      "TELEMETRY d1b_fired inscriptions=#{@counts[:inscribed]} " \
        "marks_consumed=#{@counts[:mark_consumed]} " \
        "dissolved=#{@counts[:body_dissolved]} regrown=#{@counts[:body_regrown]} " \
        "tributes=#{@counts[:tribute_paid]} floor_fired=#{@counts[:vessel_kept]} " \
        "banked_spent{inscribe=#{@spent[:inscribe]} tribute=#{@spent[:tribute]}} " \
        "banked_end=#{@banked_end}"
    end

    def q6_summary
      n = @bank_amounts.length
      mean = n.positive? ? (@bank_amounts.sum / n.to_f).round : 0
      "TELEMETRY q6_cadence banks{n=#{n} mean=#{mean} max=#{@bank_amounts.max || 0}} " \
        "kills_by_band{b0=#{@kills_by_band[0]} b1=#{@kills_by_band[1]} b2=#{@kills_by_band[2]}}"
    end

    private

    def deepest_band = @max_band
  end
end
