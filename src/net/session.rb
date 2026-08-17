require "socket"
require "json"
require "fileutils"
require "core/input"
require "net/protocol"
require "net/fingerprint"
require "net/lockstep"
require "net/state_digest"
require "net/wire"

module Net
  # v17 increment 5 — the impure orchestrator: owns socket + Lockstep +
  # StateDigest (spec Netplay spec). Phase machine
  # LISTEN->HELLO->PROBE->SESSION->READY->RUN->END; a message outside its
  # phase is a protocol fault. Termination machine per decision 8: DESYNC
  # exchange + bounded drain, BYE{quit} drain, reason precedence
  # desync > protocol > conn_lost > quit; the desync artifact is written
  # on BOTH seats. No threads (decision 7): everything happens inside
  # update(now_ms, input), driven by the caller's loop with the caller's
  # monotonic clock — the sim itself never reads a clock.
  #
  # Handshake pins: host = seat 1; session_id = seed XOR epoch (host
  # picks, human-readable hex); D = derive_delay over the MEDIAN of
  # probe_count RTTs measured host-side; SESSION carries d/digest_every
  # (+ link_slow as an OPTIONAL field — decode validates required shape
  # only, so the pinned vocabulary is untouched).
  class Session
    ROOT = File.expand_path("../..", __dir__)
    PRECEDENCE = { quit: 0, conn_lost: 1, protocol: 2, desync: 3 }.freeze
    BYE_REASONS = { "quit" => :quit, "conn_lost" => :conn_lost, "desync" => :desync }.freeze
    ALLOWED = {
      listen: [],
      hello: %i[hello bye],
      probe: %i[probe probe_ack session bye],
      session: %i[session ready bye],
      ready: %i[start bye],
      run: %i[input digest desync bye],
      draining: %i[input digest desync bye]
    }.freeze

    Params = Data.define(:session_id, :seed, :d, :digest_every, :link_slow)

    attr_reader :seat, :phase, :reason, :params, :refusal, :fault_message,
                :artifact_path, :digest_log, :lockstep, :link_slow

    def self.host(port:, config:, seed:, bind: "0.0.0.0", epoch: Time.now.to_i, hello: nil)
      new(role: :host, config:, hello:) do |s|
        s.listen(bind, port, seed:, epoch:)
      end
    end

    def self.join(host:, port:, config:, hello: nil)
      new(role: :join, config:, hello:) do |s|
        s.connect(host, port)
      end
    end

    def initialize(role:, config:, hello: nil)
      @role = role
      @seat = role == :host ? 1 : 2
      @config = config
      @hello = hello || Fingerprint.hello(root: ROOT)
      @phase = :listen
      @phase_started = nil
      @drain = nil
      @reason = nil
      @params = nil
      @refusal = nil
      @fault_message = nil
      @artifact_path = nil
      @pending_desync = nil
      @rtts = []
      @probe_sent_at = nil
      @ready_received = false
      @link_slow = false
      @stall_warning_ms = nil
      @digest_log = []
      @null_input = Core::NullInput.new
      yield self
    end

    # --- construction plumbing (called from the factories) -----------------

    def listen(bind, port, seed:, epoch:)
      @server = TCPServer.new(bind, port)
      # Cached at bind: the HOSTING screen reads it every frame, and the
      # server socket closes at accept (addr would raise IOError then).
      @port = @server.addr[1]
      @seed = seed
      @epoch = epoch
    end

    def connect(host, port)
      open_wire(TCPSocket.new(host, port))
    end

    attr_reader :port

    # --- caller surface -----------------------------------------------------

    def host? = @role == :host
    def ended? = @phase == :end
    def running? = @phase == :run
    def draining? = !@drain.nil?
    def params_known? = !@params.nil?

    # Current-stall overlay feed (presentation spec 3): ms of continuous
    # stall once past stall_warn_ms, else nil.
    def stall_warning_ms = @stall_warning_ms

    def ticks = @lockstep ? @lockstep.tick : 0

    def telemetry_line
      "TELEMETRY netplay seat=#{@seat} ticks=#{ticks} " \
        "desyncs=#{@lockstep ? @lockstep.desyncs : 0} " \
        "stalls=#{@lockstep ? @lockstep.stall_updates : 0} " \
        "stall_ms_max=#{@lockstep ? @lockstep.stall_ms_max.round : 0} " \
        "reason=#{@reason}"
    end

    # The handshake told us seed/d/digest_every; the caller builds the
    # two-seat World and hands it over. Session owns the digest + lockstep
    # from here. rtt_ticks: d on BOTH seats (D already embeds half-RTT +
    # jitter margin, and the retention bound must read the same on both).
    def attach(world)
      raise "attach before SESSION params are known" unless params_known?
      raise "attach twice" if @world
      @world = world
      @digest = StateDigest.new(world:, every: @params.digest_every)
      @lockstep = Lockstep.new(local_seat: @seat, delay: @params.d,
                               digest_every: @params.digest_every,
                               stall_warn_ms: @config.fetch(:stall_warn_ms),
                               abort_stall_ms: @config.fetch(:abort_stall_ms),
                               rtt_ticks: @params.d)
      if host?
        try_start
      else
        send_msg(:ready)
        set_phase(:ready) # awaiting START
      end
      nil
    end

    # One update: pump reads, dispatch, flush writes, then either execute
    # one lockstep tick or record the stall. now_ms is the app layer's
    # monotonic clock; input is the LOCAL seat's live source (sampled once
    # per executed tick — decision 1).
    def update(now_ms, input = nil)
      return if ended?
      @now = now_ms
      accept_if_listening
      if @wire
        @wire.pump_reads.each do |line|
          handle(Protocol.decode(line))
          break if ended?
        end
        @wire.flush_writes unless ended?
      end
      return if ended?
      if wire_dead?
        conclude(:conn_lost)
        finish!
        return
      end
      if draining?
        finish! if @now >= @drain[:deadline]
      elsif running?
        run_tick(input || @null_input)
      else
        handshake_timeout_check
      end
      nil
    rescue Protocol::Fault => e
      fault!(e)
      nil
    end

    # Clean local quit (Esc): BYE{quit}, then a bounded drain for the
    # peer's BYE ack (decision 8) — both seats record reason=quit. With no
    # wire yet (Esc on the HOSTING screen) there is no peer to drain for:
    # end immediately — a 2 s freeze on cancel would read as a hang.
    def quit!(now_ms)
      return if ended?
      @now = now_ms
      conclude(:quit)
      if @wire.nil?
        finish!
        return
      end
      send_msg(:bye, reason: "quit")
      begin_drain(:bye)
      nil
    end

    # Harness fault injection (netplay_conn_lost script): hard-close the
    # socket with NO BYE — simulates process death; the peer discovers it
    # as EOF on its next pump (conn_lost taxonomy). Never called in live
    # play; the replay scene stops updating a severed seat.
    def sever!
      @wire&.close
      @server.close if @server && !@server.closed?
      nil
    end

    private

    # --- wiring ---------------------------------------------------------------

    def open_wire(socket)
      @wire = Wire.new(socket)
      send_msg(:hello, **@hello)
      set_phase(:hello)
    end

    def accept_if_listening
      return unless @phase == :listen && @server
      socket = @server.accept_nonblock(exception: false)
      return if socket == :wait_readable
      @server.close
      open_wire(socket)
    rescue Errno::ECONNRESET, Errno::ECONNABORTED
      nil # a joiner died mid-connect: keep listening
    end

    def wire_dead? = @wire && @wire.dead?

    def send_msg(type, **fields)
      @wire&.send_line(Protocol.encode(type, **fields))
    end

    def set_phase(phase)
      @phase = phase
      @phase_started = @now
    end

    # Handshake phases must move or die honestly: a CONNECTED peer stuck
    # before RUN for abort_stall_ms is a dead handshake (bounds every
    # waiting screen AND every test loop). :listen is exempt — hosting
    # waits for a partner indefinitely (Esc cancels at the app layer).
    def handshake_timeout_check
      return if @phase == :listen
      @phase_started ||= @now
      return if @now - @phase_started <= @config.fetch(:abort_stall_ms)
      conclude(:conn_lost)
      send_msg(:bye, reason: "conn_lost")
      finish!
    end

    # --- message dispatch (phase-checked) ---------------------------------------

    def handle(msg)
      type = msg[:m]
      allowed = ALLOWED.fetch(draining? ? :draining : @phase)
      unless allowed.include?(type)
        raise Protocol::Fault, "#{type.upcase} out of phase (#{@phase}#{" draining" if draining?})"
      end
      send(:"handle_#{type}", msg)
    end

    def handle_hello(msg)
      theirs = msg.slice(:version, :ruby, :platform, :fingerprint, :digest_version)
      if (message = Fingerprint.mismatch(@hello, theirs))
        @refusal = message
        conclude(:protocol)
        send_msg(:bye, reason: "fingerprint")
        finish!
        return
      end
      set_phase(:probe)
      send_probe if host?
    end

    def send_probe
      @probe_sent_at = @now
      send_msg(:probe, n: @rtts.length)
    end

    def handle_probe(msg)
      raise Protocol::Fault, "PROBE received by the prober" if host?
      send_msg(:probe_ack, n: msg[:n])
    end

    def handle_probe_ack(msg)
      raise Protocol::Fault, "PROBE_ACK received by the responder" unless host?
      raise Protocol::Fault, "PROBE_ACK n=#{msg[:n]} out of order" unless msg[:n] == @rtts.length
      @rtts << (@now - @probe_sent_at)
      if @rtts.length < @config.fetch(:probe_count)
        send_probe
      else
        derived = Lockstep.derive_delay(@rtts, @config.fetch(:delay))
        @link_slow = derived.link_slow
        @params = Params.new(session_id: format("%08x", @seed ^ @epoch), seed: @seed,
                             d: derived.d, digest_every: @config.fetch(:digest_every),
                             link_slow: derived.link_slow)
        send_msg(:session, session_id: @params.session_id, seed: @params.seed,
                 d: @params.d, digest_every: @params.digest_every,
                 link_slow: @params.link_slow)
        set_phase(:session)
      end
    end

    def handle_session(msg)
      raise Protocol::Fault, "SESSION received by the host" if host?
      @link_slow = msg[:link_slow] ? true : false
      @params = Params.new(session_id: msg[:session_id], seed: msg[:seed], d: msg[:d],
                           digest_every: msg[:digest_every], link_slow: @link_slow)
      # Now awaiting the caller's attach (the READY -> START barrier gates
      # on both seats holding a constructed sim).
      set_phase(:session)
    end

    def handle_ready(_msg)
      raise Protocol::Fault, "READY received by the joiner" unless host?
      @ready_received = true
      try_start
    end

    def try_start
      return unless @ready_received && @world
      send_msg(:start)
      set_phase(:run)
    end

    def handle_start(_msg)
      raise Protocol::Fault, "START received by the host" if host?
      set_phase(:run)
    end

    def handle_input(msg)
      @lockstep.receive_remote(msg[:t], msg[:bits])
    end

    def handle_digest(msg)
      verdict = @lockstep.receive_digest(msg[:t], msg[:md5])
      desync!(verdict) if verdict
    end

    def handle_desync(msg)
      if draining? && @drain[:awaiting] == :desync
        finish! # the peer's DESYNC is our ack
      else
        # The peer saw the mismatch first (or we were quit-draining):
        # latch with what we retain, ack, end. reason precedence upgrades
        # a pending quit to desync.
        @pending_desync ||= @lockstep.latch_desync!(msg[:t])
        conclude(:desync)
        send_msg(:desync, t: msg[:t])
        finish!
      end
    end

    def handle_bye(msg)
      if draining? && @drain[:awaiting] == :bye
        finish!
      else
        reason = BYE_REASONS.fetch(msg[:reason], :protocol)
        @refusal ||= "peer refused: #{msg[:reason]}" if msg[:reason] == "fingerprint"
        conclude(reason)
        send_msg(:bye, reason: "quit") if reason == :quit # ack a clean Esc
        finish!
      end
    end

    # --- the run loop (one lockstep tick per update, or a stall) ----------------

    def run_tick(input)
      if @lockstep.ready?
        t = @lockstep.tick
        input.update(t)
        mask = Protocol.mask(input)
        slot = @lockstep.submit_local(mask)
        send_msg(:input, t: slot, bits: mask)
        masks = @lockstep.advance!
        @stall_warning_ms = nil
        @digest.fold_input(t, [masks[1], masks[2]])
        @world.tick({ 1 => SampledInput.new(masks[1]), 2 => SampledInput.new(masks[2]) })
        if (window = @digest.after_tick)
          @digest_log << [window.tick, window.md5]
          send_msg(:digest, t: window.tick, md5: window.md5)
          verdict = @lockstep.record_boundary(window)
          desync!(verdict) if verdict
        end
      else
        verdict = @lockstep.record_stall(@now)
        @stall_warning_ms = verdict.warn? ? verdict.elapsed_ms : nil
        if verdict.abort?
          conclude(:conn_lost)
          send_msg(:bye, reason: "conn_lost") # best effort for the frozen peer
          finish!
        end
      end
    end

    # --- termination machine (decision 8) ----------------------------------------

    def conclude(reason)
      return if @reason && PRECEDENCE.fetch(@reason) >= PRECEDENCE.fetch(reason)
      @reason = reason
    end

    def desync!(verdict)
      @pending_desync = verdict
      conclude(:desync)
      send_msg(:desync, t: verdict.tick)
      begin_drain(:desync)
    end

    def fault!(error)
      @fault_message = error.message
      conclude(@wire&.dead_reason == :oversize ? :conn_lost : :protocol)
      send_msg(:bye, reason: "protocol")
      finish!
    end

    def begin_drain(awaiting)
      @drain = { awaiting:, deadline: @now + @config.fetch(:drain_timeout_ms) }
      @stall_warning_ms = nil
    end

    def finish!
      write_artifact if @pending_desync
      @wire&.flush_writes
      @wire&.close
      @server.close if @server && !@server.closed?
      @drain = nil
      @stall_warning_ms = nil
      set_phase(:end)
    end

    # Decision 8: manifest + boundary tick + own/peer digest + retained
    # snapshot + window event lines, on BOTH seats. Junior shares his;
    # the DIFF is the work item.
    def write_artifact
      v = @pending_desync
      dir = File.join(ROOT, "tmp", "netplay")
      FileUtils.mkdir_p(dir)
      @artifact_path = File.join(dir, "desync_#{@params.session_id}_tick#{v.tick}.json")
      File.write(@artifact_path, JSON.pretty_generate(
        session_id: @params.session_id, seat: @seat, tick: v.tick,
        own_md5: v.local_md5, peer_md5: v.peer_md5,
        manifest: @hello,
        snapshot: v.record&.snapshot, lines: v.record&.lines
      ))
    end
  end
end
