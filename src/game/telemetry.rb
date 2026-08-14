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
    A2_RETARGET_CAUSES = %i[hate lowhp proximity acquired challenged].freeze

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

      # Density (v11): arrivals by anchor kind + a pocket sample per
      # arrival — the re-massing oracle. A session where home dominates or
      # singles_pct sits near 100 is machine-distinguishable from one where
      # re-massing fired. Samples run post-spawn: the handler fires at
      # bus-process, after respawn_due_humans already placed the body.
      @density_arrivals = Hash.new(0)
      @pocket_samples = []
      @pocket_max = 0
      @single_pockets = 0
      @total_pockets = 0
      bus.subscribe(:human_respawned) do |e|
        @density_arrivals[e[:anchor]] += 1
        next unless @world
        pockets = @world.density_pockets
        @pocket_samples << pockets.length
        biggest = pockets.map(&:length).max || 0
        @pocket_max = biggest if biggest > @pocket_max
        @single_pockets += pockets.count { |p| p.length == 1 }
        @total_pockets += pockets.length
      end

      # Arc (v12): the advance oracle — breach chain, re-homes, new-ground
      # kills. A session that never found the door must be machine-
      # distinguishable from one that opened it and shrugged.
      @arc = Hash.new(0)
      @arc_first_frame = nil
      @arc_banked_after = nil
      bus.subscribe(:seal_breached) do |e|
        @arc[:fired] += 1
        @arc_first_frame ||= @world ? @world.frame : 0
        @arc[:seal2] = 1 if e[:zone] == "district_two"
      end
      bus.subscribe(:banked_spent) do |e|
        @arc_banked_after ||= e[:banked] if e[:sink] == :breach
      end
      bus.subscribe(:home_rehomed) { @arc[:rehomed] += 1 }
      bus.subscribe(:zone_entered) do |e|
        @arc[:camp_visits] += 1 if e[:zone] == "camp"
        @arc[:d2_entered] = 1 if e[:zone] == "district_two"
      end
      bus.subscribe(:actor_died) do |e|
        next unless e[:faction] == :human && @world
        @arc[:d2_kills] += 1 if @world.zone_name == "district_two"
      end

      # Q6 margins (v12): WHY each bank trip happened — sampled at bank
      # time, so the tenth verify's Q5 conversation starts from data, not
      # a blind retune (the third-regression law).
      @margin_samples = []
      @margin_gaps = []
      @last_bank_frame = nil
      bus.subscribe(:banked) do |e|
        frame = @world ? @world.frame : 0
        @margin_gaps << frame - @last_bank_frame if @last_bank_frame
        @last_bank_frame = frame
        @margin_samples << {
          amount: e[:amount],
          hp: @world ? @world.possessed.hp / @world.possessed.max_hp.to_f : 0.0,
          dead: @world ? @world.pack.members.count(&:dead?) : 0,
          wounded: @world ? @world.pack.living.count { |m| m.hp < m.max_hp } : 0
        }
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
        "#{q6_summary}\n" \
        "#{density_summary}\n" \
        "#{arc_summary}\n" \
        "#{q6_margins_summary}"
    end

    def a2_summary
      "TELEMETRY a2_fired wipes=#{@counts[:pack_wiped]} " \
        "body_deaths=#{@counts[:body_deaths]} " \
        "retargets{hate=#{@retargets[:hate]} lowhp=#{@retargets[:lowhp]} " \
        "proximity=#{@retargets[:proximity]} acquired=#{@retargets[:acquired]} " \
        "challenged=#{@retargets[:challenged]}} " \
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

    # Format pinned by the v12 spec: always prints, all-zero when the arc
    # never fired — a zero-arc session routes as UNEXERCISED, never defect.
    def arc_summary
      "TELEMETRY arc breach{fired=#{@arc[:fired]} " \
        "first_frame=#{@arc_first_frame || 0} " \
        "banked_after=#{@arc_banked_after || 0}} " \
        "rehomed=#{@arc[:rehomed]} camp_visits=#{@arc[:camp_visits]} " \
        "d2{entered=#{@arc[:d2_entered]} kills=#{@arc[:d2_kills]}} " \
        "seal2_breached=#{@arc[:seal2]}"
    end

    # Format pinned by the v12 spec. Hypothesis separation for the debate:
    # high pure share + high hp.mean = carry anxiety; low hp.mean or high
    # dead.mean = maintenance; short gaps + small amounts = cadence.
    def q6_margins_summary
      n = @margin_samples.length
      amounts = @margin_samples.map { |s| s[:amount] }
      pure = @margin_samples.count { |s| s[:dead].zero? && s[:wounded].zero? }
      mean = n.positive? ? (amounts.sum / n.to_f).round : 0
      hp = n.positive? ? @margin_samples.sum { |s| s[:hp] } / n : 0.0
      dead = n.positive? ? @margin_samples.sum { |s| s[:dead] } / n.to_f : 0.0
      wounded = n.positive? ? @margin_samples.sum { |s| s[:wounded] } / n.to_f : 0.0
      gap = @margin_gaps.empty? ? 0 : (@margin_gaps.sum / @margin_gaps.length / 60.0).round
      format("TELEMETRY q6_margins banks{n=%d pure=%d} amount{mean=%d max=%d} " \
             "hp{mean=%.2f} dead{mean=%.1f} wounded{mean=%.1f} gap{mean_s=%d}",
             n, pure, mean, amounts.max || 0, hp, dead, wounded, gap)
    end

    # Format pinned by the v11 spec: the line ALWAYS prints (all-zero at
    # zero arrivals — presence is the subscriber-alive proof).
    def density_summary
      n = @pocket_samples.length
      mean = n.positive? ? (@pocket_samples.sum / n.to_f).round(1) : 0.0
      pct = @total_pockets.positive? ? (100.0 * @single_pockets / @total_pockets).round : 0
      "TELEMETRY density pockets{mean=#{mean} max=#{@pocket_max}} " \
        "arrivals{pocket=#{@density_arrivals[:pocket]} seed=#{@density_arrivals[:seed]} " \
        "home=#{@density_arrivals[:home]}} singles_pct=#{pct}"
    end

    private

    def deepest_band = @max_band
  end
end
