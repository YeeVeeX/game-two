require "net/protocol"

module Net
  # v17 increment 4 — the PURE lockstep scheduler (spec fork 2 + decisions
  # 1/2/8). No I/O, no sockets, no clock reads: wall-ms values flow IN from
  # the app layer (record_stall), wire traffic flows in via receive_remote/
  # receive_digest, and Net::Session (increment 5) owns everything impure.
  #
  # Laws enforced mechanically here:
  #   - ticks 0..D-1 consume empty masks BY DEFINITION (pre-filled queues);
  #   - sampling law (decision 1): the local mask for slot T+D is submitted
  #     exactly ONCE per executed tick, and submit precedes advance!
  #     (sample -> submit -> consume -> tick; W4's ordering sin raises);
  #   - a received duplicate slot with a DIFFERING mask is a protocol
  #     fault; an identical duplicate is idempotent;
  #   - seat-order law (decision 2): consumed masks come back {1 =>, 2 =>}
  #     in pinned seat order regardless of which seat is local;
  #   - stall time is WALL ms fed by the caller; warn/abort thresholds are
  #     data (netplay.json), verdicts are returned, never acted on here;
  #   - digest boundaries are retained IMMUTABLE until the peer pair
  #     arrives (decision 8 artifact source), retention bounded by
  #     ceil((D + RTT_ticks)/N) + 1 — exceeding it means the peer broke
  #     digest cadence (protocol fault);
  #   - a mismatch latches the machine: ready? goes false forever (halt
  #     tick admission), drain-phase traffic is ignored, never faulted.
  class Lockstep
    # 60 Hz tick duration used by the spec's D-derivation formula
    # (fork 5, pinned there as ms/16.67) — an engine invariant like the
    # protocol bit order, not a tunable.
    TICK_MS = 16.67

    Delay = Data.define(:d, :link_slow)
    Stall = Data.define(:elapsed_ms, :warn, :abort) do
      def warn? = warn
      def abort? = abort
    end
    Desync = Data.define(:tick, :local_md5, :peer_md5, :record)

    # Fork 5: D = clamp(ceil(median_RTT_ms/2 / TICK_MS) + jitter_margin,
    # min, max); probe failure -> default; a raw value above the clamp
    # starts anyway with the LINK SLOW flag (trusted seats decide).
    def self.derive_delay(rtt_samples_ms, delay_cfg)
      samples = Array(rtt_samples_ms)
      return Delay.new(d: delay_cfg.fetch(:default), link_slow: false) if samples.empty?
      sorted = samples.sort
      mid = sorted.length / 2
      median = sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
      raw = (median / 2.0 / TICK_MS).ceil + delay_cfg.fetch(:jitter_margin_ticks)
      Delay.new(d: raw.clamp(delay_cfg.fetch(:min), delay_cfg.fetch(:max)),
                link_slow: raw > delay_cfg.fetch(:max))
    end

    attr_reader :tick, :delay, :stall_updates, :stall_run, :stall_run_max,
                :stall_ms_max, :stall_worst_run, :desyncs, :boundaries_compared, :desync

    def initialize(local_seat:, delay:, digest_every:, stall_warn_ms:, abort_stall_ms:, rtt_ticks: 0)
      raise ArgumentError, "local_seat must be 1 or 2" unless [1, 2].include?(local_seat)
      @local_seat = local_seat
      @remote_seat = 3 - local_seat
      @delay = delay
      @digest_every = digest_every
      @stall_warn_ms = stall_warn_ms
      @abort_stall_ms = abort_stall_ms
      # Decision 8: unresolved boundaries are bounded by construction; the
      # formula is the documented ceiling, exceeding it = broken cadence.
      @retention_bound = ((delay + rtt_ticks).to_f / digest_every).ceil + 1
      @queues = { 1 => {}, 2 => {} }
      delay.times do |t|
        @queues[1][t] = 0
        @queues[2][t] = 0
      end
      @tick = 0            # executed count == the next tick to execute
      @next_local_slot = delay
      @stall_updates = 0
      @stall_run = 0
      @stall_run_max = 0
      @stall_ms_max = 0
      @stall_worst_run = 0
      @stall_started_ms = nil
      @local_windows = {}  # boundary tick => retained Window (awaiting peer md5)
      @peer_md5s = {}      # boundary tick => md5 (awaiting our boundary)
      @compared = {}       # boundary tick => matched md5 (duplicate-law memory)
      @boundaries_compared = 0
      @desyncs = 0
      @desync = nil
    end

    def desynced? = !@desync.nil?

    # Both seats' masks for tick t present? Local is present by
    # construction (pre-fill + submit-per-executed-tick), so this gates on
    # the peer. A latched desync halts tick admission forever.
    def ready?(t = @tick)
      return false if desynced?
      @queues[1].key?(t) && @queues[2].key?(t)
    end

    # Sampling law: exactly once per executed tick, BEFORE advance!, and
    # never on a stalled update (a stalled update samples NOTHING — it
    # only pumps the socket). Returns the slot (T+D) the caller must send
    # as INPUT{t, bits}.
    def submit_local(mask)
      raise "submit_local while desynced (the session is ending)" if desynced?
      unless ready?
        raise "submit_local on a stalled tick #{@tick} (a stalled update samples NOTHING)"
      end
      slot = @tick + @delay
      if @next_local_slot != slot
        raise "submit_local called twice for slot #{@next_local_slot - 1} " \
              "(sampling law: exactly once per EXECUTED tick)"
      end
      @queues[@local_seat][slot] = mask
      @next_local_slot += 1
      slot
    end

    # Peer INPUT{slot, bits}. Slots below D contradict the by-definition
    # empties unless they agree (mask 0). Consumed slots stay in the queue
    # so late duplicates are still checkable.
    def receive_remote(slot, mask)
      return if desynced?
      queue = @queues[@remote_seat]
      if queue.key?(slot)
        return if queue[slot] == mask
        raise Protocol::Fault,
              "duplicate INPUT slot #{slot} differs (had #{queue[slot]}, got #{mask})"
      end
      queue[slot] = mask
    end

    # Execute one tick: consumes both seats' slot-t masks in pinned seat
    # order and ends any stall run. Caller order is enforced: submit_local
    # for T+D must have happened (sample -> submit -> advance).
    def advance!
      raise "advance! while desynced (tick admission is halted)" if desynced?
      raise "advance! without ready? (tick #{@tick})" unless ready?
      unless @next_local_slot == @tick + @delay + 1
        raise "advance! before submit_local (sampling law: sample -> submit -> advance)"
      end
      masks = { 1 => @queues[1].fetch(@tick), 2 => @queues[2].fetch(@tick) }
      @tick += 1
      @stall_run = 0
      @stall_started_ms = nil
      masks
    end

    # One stalled update (ready? was false). now_ms is the app-layer
    # monotonic clock; the run's elapsed time is measured from the FIRST
    # stalled update after the last advance. Returns the verdict — acting
    # on warn (overlay) or abort (conn_lost) is the caller's job.
    # stall_worst_run pairs COHERENTLY with stall_ms_max: it is the update
    # count of the run that set stall_ms_max (the last record of the worst
    # run wins, since elapsed grows within a run). Read the ratio as
    # stall_ms_max/(stall_worst_run-1) inter-update gaps (elapsed spans
    # N-1 gaps for N updates; a 1-update run reads 0/0 — degenerate but
    # coherent): ≈16.7 separates waiting-while-healthy from frozen-locally
    # (≫16.7); direction-safe even at small N. stall_run_max alone may
    # come from a DIFFERENT run and the ratio would lie (lag P0 spec).
    def record_stall(now_ms)
      @stall_started_ms ||= now_ms
      @stall_updates += 1
      @stall_run += 1
      @stall_run_max = @stall_run if @stall_run > @stall_run_max
      elapsed = now_ms - @stall_started_ms
      if elapsed > @stall_ms_max
        @stall_ms_max = elapsed
        @stall_worst_run = @stall_run
      end
      Stall.new(elapsed_ms: elapsed, warn: elapsed >= @stall_warn_ms,
                abort: elapsed >= @abort_stall_ms)
    end

    # Our own StateDigest window at a boundary: retained immutable until
    # the peer's md5 arrives. Returns a Desync verdict if the peer's md5
    # was already held and differs, else nil.
    def record_boundary(window)
      return nil if desynced?
      t = window.tick
      raise "duplicate local boundary #{t}" if @local_windows.key?(t) || @compared.key?(t)
      if @peer_md5s.key?(t)
        compare(window, @peer_md5s.delete(t))
      else
        @local_windows[t] = window
        check_retention(@local_windows, "local boundary windows await peer digests")
        nil
      end
    end

    # Peer DIGEST{t, md5}. Compared when the pair is complete; pending
    # peer digests are bounded the same way (a peer running unboundedly
    # ahead broke lockstep). Duplicates follow the input-duplicate law.
    def receive_digest(t, md5)
      return nil if desynced?
      unless t.positive? && (t % @digest_every).zero?
        raise Protocol::Fault, "DIGEST tick #{t} is not a boundary (cadence #{@digest_every})"
      end
      if (window = @local_windows[t])
        verdict = compare(window, md5)
        @local_windows.delete(t) unless desynced?
        verdict
      elsif @compared.key?(t) || @peer_md5s.key?(t)
        known = @compared[t] || @peer_md5s[t]
        return nil if known == md5
        raise Protocol::Fault, "duplicate DIGEST #{t} differs (had #{known}, got #{md5})"
      else
        @peer_md5s[t] = md5
        check_retention(@peer_md5s, "peer digests await local boundaries")
        nil
      end
    end

    # Session-level latch (increment 5): the PEER declared DESYNC{t} —
    # halt with whatever we retain for that boundary (we may not have
    # reached it). Counted here so desyncs=N reads the same on both seats.
    def latch_desync!(t)
      return @desync if desynced?
      window = @local_windows[t]
      latch(Desync.new(tick: t, local_md5: window&.md5, peer_md5: @peer_md5s[t],
                       record: window))
    end

    private

    def compare(window, peer_md5)
      if window.md5 == peer_md5
        @compared[window.tick] = peer_md5
        @boundaries_compared += 1
        nil
      else
        latch(Desync.new(tick: window.tick, local_md5: window.md5,
                         peer_md5: peer_md5, record: window))
      end
    end

    def latch(verdict)
      @desyncs += 1
      @desync = verdict
    end

    def check_retention(map, what)
      return if map.size <= @retention_bound
      raise Protocol::Fault,
            "digest retention exceeded: #{map.size} #{what} " \
            "(bound ceil((D+RTT)/N)+1 = #{@retention_bound} — peer broke digest cadence)"
    end
  end
end
