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

      # v13 (B+D): the eleventh ask's oracle. whirl.hits buckets landed
      # special hits between :special_started edges (bus processes in
      # order); a fat 3+ tail = density became ammunition, a 1-spike = a
      # worse dash. challenge casts/retargets tell D's story beside
      # d1.carrying_deaths (tenth baseline: 21).
      @whirl_hist = Hash.new(0)
      @whirl = Hash.new(0)
      @whirl_open = nil
      bus.subscribe(:special_started) do |e|
        case e[:attacker].kit_name
        when :striker
          close_whirl_cast!
          @whirl_open = 0
          @whirl[:casts] += 1
        when :blocker
          @whirl[:challenge_casts] += 1
        end
      end
      bus.subscribe(:attack_hit) do |e|
        next unless e[:kind] == :special && e[:landed] && e[:attacker].kit_name == :striker
        @whirl_open = (@whirl_open || 0) + 1
        @whirl[:kills] += 1 if e[:victim].dead?
      end

      # v14: discovery + telegraph arbiters. first_special is pack-only
      # (a future human special must not pollute the discovery read);
      # frame stamped at bus-process time, deterministic. The telegraph
      # counter subscribes only where the event exists — Telemetry also
      # serves pre-v14 test buses, and the line's zero must still print
      # (subscriber-alive law).
      @first_special = {}
      bus.subscribe(:special_started) do |e|
        a = e[:attacker]
        @first_special[a.kit_name] ||= (@world ? @world.frame : 0) if a.faction == :pack
      end
      if bus.registered?(:respawn_telegraphed)
        bus.subscribe(:respawn_telegraphed) { @counts[:telegraphs_shown] += 1 }
      end

      # Drift instrumentation (v13, Q6 lane): kill frames + pocket-size
      # samples, bucketed into session thirds at SUMMARY time — measures
      # WHERE the field drifts instead of guessing dose three.
      @kill_frames = []
      @drift_pockets = []
      bus.subscribe(:actor_died) do |e|
        @kill_frames << (@world ? @world.frame : 0) if e[:faction] == :human
      end
      bus.subscribe(:human_respawned) do
        next unless @world
        pockets = @world.density_pockets
        next if pockets.empty?
        mean = pockets.map(&:length).sum.fdiv(pockets.length)
        @drift_pockets << [@world.frame, mean]
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

      # v15: the thirteenth's arbiters. quay{} tracks the descent (half A);
      # varekka{} tracks the peak (half B). swap_escapes is EVENT-ORDERED
      # (panel telemetry-race fold): the bus flushes after the whole tick,
      # so open/close flags ride the queue order, never live sim state —
      # and only voluntary swaps count (a forced death-swap is not an
      # escape). Subscriber-alive law: pre-v15 test buses lack the events.
      @quay = Hash.new(0)
      @quay_frames = 0
      @quay_entered_at = nil
      @quay_trip = false
      @vk = Hash.new(0)
      @vk_ends = Hash.new(0)
      @chant_open = false
      @seizure_open = false
      @seized_body = nil
      bus.subscribe(:zone_entered) do |e|
        if e[:zone] == "low_quay"
          @quay[:entries] += 1
          @quay_entered_at ||= (@world ? @world.frame : 0)
          @quay_trip = true
        elsif @quay_entered_at
          @quay_frames += (@world ? @world.frame : 0) - @quay_entered_at
          @quay_entered_at = nil
        end
      end
      bus.subscribe(:actor_died) do |e|
        in_quay = @world && @world.zone_name == "low_quay"
        @quay[:kills] += 1 if in_quay && e[:faction] == :human
        @quay[:deaths] += 1 if in_quay && e[:faction] == :pack
        if @seizure_open && e[:actor].equal?(@seized_body)
          @vk[:deaths_while_seized] += 1
        end
        # respond_to? guard: pre-v15 test buses emit actor stand-ins
        # without kits (subscriber-alive law).
        if e[:faction] == :human && e[:actor].respond_to?(:kit) &&
           e[:actor].kit[:seize]
          @vk[:slain] = 1
        end
      end
      bus.subscribe(:banked) do |e|
        if @quay_trip
          @quay[:banked_events] += 1
          @quay[:banked_amount] += e[:amount]
          @quay_trip = false
        end
      end
      bus.subscribe(:pack_wiped) { @quay_trip = false }
      if bus.registered?(:challenger_chant_started)
        bus.subscribe(:challenger_engaged) { @vk[:engaged] = 1 }
        bus.subscribe(:challenger_chant_started) do
          @vk[:chants] += 1
          @chant_open = true
        end
        bus.subscribe(:chant_interrupted) do
          @vk[:interrupted] += 1
          @chant_open = false
        end
        bus.subscribe(:vessel_seized) do |e|
          @vk[:seized] += 1
          @chant_open = false
          @seizure_open = true
          @seized_body = e[:body]
        end
        bus.subscribe(:seizure_ended) do |e|
          @vk_ends[e[:why]] += 1
          @seizure_open = false
          @seized_body = nil
        end
        # v16 (d): the stakes knob's arbiter — burns>0 at the fifteenth
        # means the court actually pierced the vat on a real session.
        bus.subscribe(:inscription_burned) { @vk[:burns] += 1 }
        bus.subscribe(:possession_changed) do |e|
          next if e[:forced]
          @vk[:swap_escapes] += 1 if @chant_open || @seizure_open
        end
      end

      # v18 sustain (decision 9): the SEVENTEENTH's routing arbiter — a
      # bought=0 session routes to discoverability FIRST (the tuning-lever
      # order is pre-registered in the spec), never to a verb redesign.
      # Guarded: pre-v18 test buses lack the events; the line still prints
      # zeros (subscriber-alive law).
      @sustain = Hash.new(0)
      if bus.registered?(:provision_bought)
        bus.subscribe(:provision_bought) { @sustain[:bought] += 1 }
        bus.subscribe(:provision_used) { @sustain[:used] += 1 }
        bus.subscribe(:provision_refused) { @sustain[:refused] += 1 }
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
        "#{q6_margins_summary}\n" \
        "#{v13_summary}\n" \
        "#{drift_summary}\n" \
        "#{v14_summary}\n" \
        "#{v15_summary}\n" \
        "#{sustain_summary}"
    end

    # Format pinned by the v18 spec: sustain bought/used/refused.
    def sustain_summary
      "TELEMETRY sustain bought=#{@sustain[:bought]} used=#{@sustain[:used]} " \
        "refused=#{@sustain[:refused]}"
    end

    # v15: quay + varekka in one line pair — the thirteenth's arbiters.
    def v15_summary
      frames = @quay_frames +
               (@quay_entered_at && @world ? @world.frame - @quay_entered_at : 0)
      ends = %i[expired slain died zone_left wiped]
             .map { |w| "#{w}=#{@vk_ends[w]}" }.join(" ")
      "TELEMETRY quay entries=#{@quay[:entries]} frames=#{frames} " \
        "kills=#{@quay[:kills]} deaths=#{@quay[:deaths]} " \
        "banked_after{events=#{@quay[:banked_events]} amount=#{@quay[:banked_amount]}}\n" \
        "TELEMETRY varekka engaged=#{@vk[:engaged]} chants=#{@vk[:chants]} " \
        "interrupted=#{@vk[:interrupted]} seized=#{@vk[:seized]} " \
        "swap_escapes=#{@vk[:swap_escapes]} slain=#{@vk[:slain]} " \
        "deaths_while_seized=#{@vk[:deaths_while_seized]} burns=#{@vk[:burns]} ends{#{ends}}"
    end

    # Format pinned by the v14 spec: `never` (not 0) marks a kit that never
    # cast — World starts at frame 0, so a 0 sentinel would collide with a
    # legal first-tick cast (Codex fold).
    def v14_summary
      fs = %i[striker blocker lobber]
           .map { |k| "#{k}=#{@first_special[k] || 'never'}" }.join(" ")
      "TELEMETRY v14 telegraphs_shown=#{@counts[:telegraphs_shown]} " \
        "first_special{#{fs}}"
    end

    def v13_summary
      close_whirl_cast!
      "TELEMETRY v13 whirl{casts=#{@whirl[:casts]} " \
        "hits{1=#{@whirl_hist[1]} 2=#{@whirl_hist[2]} 3=#{@whirl_hist[3]} " \
        "4=#{@whirl_hist[4]} 5plus=#{@whirl_hist[5]}} " \
        "kills=#{@whirl[:kills]}} " \
        "challenge{casts=#{@whirl[:challenge_casts]} " \
        "retargets=#{@retargets[:challenged]}}"
    end

    # Session thirds by summary-time frame (tick-locked: frames ARE time).
    # span_thirds (v14 companion) re-buckets the SAME kills over the
    # first->last-kill span — a long pre-combat head or idle tail can no
    # longer compress the curve (the eleventh's all-k3 shape). The legacy
    # field stays untouched beside it: comparability both directions.
    def drift_summary
      total = @world ? @world.frame : (@kill_frames.max || 0) + 1
      third = [total.fdiv(3).ceil, 1].max
      kills = [0, 0, 0]
      @kill_frames.each { |f| kills[[f / third, 2].min] += 1 }
      pockets = [[], [], []]
      @drift_pockets.each { |(f, mean)| pockets[[f / third, 2].min] << mean }
      p1, p2, p3 = pockets.map { |s| s.empty? ? 0.0 : s.sum.fdiv(s.length) }
      "TELEMETRY drift thirds{k1=#{kills[0]} k2=#{kills[1]} k3=#{kills[2]}} " \
        "pockets{p1=#{format('%.1f', p1)} p2=#{format('%.1f', p2)} p3=#{format('%.1f', p3)}} " \
        "#{span_thirds_segment}"
    end

    def span_thirds_segment
      return "span_thirds{k1=0 k2=0 k3=0 span=0}" if @kill_frames.empty?
      first = @kill_frames.first
      span = @kill_frames.last - first + 1
      third = [span.fdiv(3).ceil, 1].max
      k = [0, 0, 0]
      @kill_frames.each { |f| k[[(f - first) / third, 2].min] += 1 }
      "span_thirds{k1=#{k[0]} k2=#{k[1]} k3=#{k[2]} span=#{span}}"
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

    # Push the open whirl-cast bucket into the histogram (idempotent —
    # nil means no open cast; 0-hit casts count as casts, not hist rows).
    def close_whirl_cast!
      return if @whirl_open.nil?
      @whirl_hist[[@whirl_open, 5].min] += 1 if @whirl_open.positive?
      @whirl_open = nil
    end

    def deepest_band = @max_band
  end
end
