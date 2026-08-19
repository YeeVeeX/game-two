# App::AudioBridge — the ONE game-two seam to the sibling audio library
# (../game-two-audio), per its integration contract
# (game-two-audio docs/integration-readiness.md @ 69b73ec) and the owner
# override of 2026-08-18 (M5a — AGENTS.md scope block).
#
# Library laws that bind THIS file (game-two-audio AGENTS.md @ 69b73ec):
#   1. The audio thread never enters Ruby — no FFI callbacks anywhere; the
#      bridge only polls through AudioSystem#update on the control thread.
#   2. Audio is a PURE SINK — events flow in, nothing flows back. No sim,
#      save, or netplay state may ever read audio state (lockstep and the
#      save digest chain stay audio-blind by construction). The only
#      readers are the close-time diagnostics printed by #shutdown.
#   3. The sim tick is the only clock fed to audio (frame = tick *
#      tick_frames; the engine clock is read ONLY at drift anchor points,
#      never per-command, never in the per-event path).
#   4. Cue ids stay mechanical; the event->cue mapping tables live in the
#      AUDIO repo's data/ (custody: its seat lands cue entries behind its
#      gate). This repo defines NO cues — it forwards events and the sink
#      ignores unmapped ones BY DESIGN.
#   5. Runtime audio files: the library's generated-tone fixtures or
#      game-two-assets exports ONLY. The evaluation stems
#      (data/audio_listen/) are FORBIDDEN at runtime — nothing here can
#      reference them (fixture_dir renders from data/audio/fixtures.json).
#
# D1 — how game-two loads the library (dev of record, M5a): a $LOAD_PATH
# path dependency on the sibling checkout (LIB_ROOT below). Rationale: the
# two repos are a same-machine program pair, no gemspec exists today, and
# the audio seat's own recommendation is the path dependency for the PoC;
# packaging happens later if distribution ever demands it. The DLL loads
# from the LIBRARY's vendor tree (native.rb resolves its own path — never
# a second copy); its sha256 is verified against vendor/VERSION here at
# boot and audio REFUSES (named line, game runs silent) on mismatch — the
# vendor law travels with the DLL.
#
# ABSENCE IS NOT AN ERROR: a machine without the library (Junior's) prints
# one named `AUDIO off` line and plays silent; netplay seats stay
# byte-identical either way (law 2). Bot seats never boot audio (soak
# processes need no device and must stay cheap).
require "digest"
require "json"

module App
  module AudioBridge
    LIB_ROOT = File.expand_path("../../../game-two-audio", __dir__)
    FIXTURE_DIR = File.expand_path("../../tmp/audio_fixtures", __dir__)

    # Drift probe cadence (contract §3 open item — measurement, not a
    # balance tunable): sample the engine clock vs tick*tick_frames every
    # 30 s of play, control thread only, printed at close.
    DRIFT_SAMPLE_TICKS = 1800

    # Dev smoke choreography (--audio-smoke; tooling, below the sim — these
    # events are the library's identity-mapped placeholders, NOT bus
    # events): tick => [event, payload]. Proves on the real device: ui cue,
    # sfx stinger + music duck, music state machine both ways.
    SMOKE_SCRIPT = {
      120 => ["toll_paid", nil],
      300 => ["boss1_spawn", nil],
      1200 => ["music_set_state", { state: "combat" }],
      2400 => ["music_set_state", { state: "calm" }],
      3000 => ["toll_paid", nil]
    }.freeze

    module_function

    # Boot per contract §3. Returns a live Bridge or a Null (named line
    # printed either way; audio failures NEVER kill the game).
    # device: 1 = real default device (runtime), 0 = noDevice (tests — the
    # library's own gate mode; real DLL, real render graph, no hardware).
    def boot(lib_root: LIB_ROOT, bot: false, smoke: false, device: 1, out: $stdout)
      return null(out, "AUDIO off: bot seat") if bot
      dll = File.join(lib_root, "vendor/miniaudio.dll")
      version = File.join(lib_root, "vendor/VERSION")
      unless File.exist?(dll) && File.exist?(version)
        return null(out, "AUDIO off: library not present at #{lib_root}")
      end
      pinned = File.read(version)[/^([0-9a-f]{64})\s+miniaudio\.dll/, 1]
      return null(out, "AUDIO refused: vendor/VERSION carries no dll sha") if pinned.nil?
      actual = Digest::SHA256.file(dll).hexdigest
      unless actual == pinned
        return null(out, "AUDIO refused: vendor dll sha mismatch (pin #{pinned[0, 12]}…, dll #{actual[0, 12]}…) — the vendor law travels with the DLL")
      end
      src = File.join(lib_root, "src")
      $LOAD_PATH.unshift(src) unless $LOAD_PATH.include?(src)
      require "gta/audio_system"
      require "gta/fixtures"
      data_dir = File.join(lib_root, "data/audio")
      engine_cfg = JSON.parse(File.read(File.join(data_dir, "engine.json")))
      GTA::Fixtures.ensure!(File.join(data_dir, "fixtures.json"), FIXTURE_DIR,
                            sample_rate: engine_cfg.fetch("sample_rate"))
      engine = GTA::Native.gta_engine_create(device, engine_cfg.fetch("channels"),
                                             engine_cfg.fetch("sample_rate"))
      if engine.null?
        return null(out, "AUDIO refused: engine create failed (ma result #{GTA::Native.gta_last_result})")
      end
      audio = GTA::AudioSystem.new(engine:, data_dir:, fixture_dir: FIXTURE_DIR)
      out.puts "AUDIO on: device=#{device} sha=#{actual[0, 12]} lib=#{lib_root}"
      Bridge.new(engine:, audio:, tick_frames: engine_cfg.fetch("tick_frames"),
                 smoke:, out:)
    rescue StandardError => e
      null(out, "AUDIO refused: #{e.class}: #{e.message}")
    end

    def null(out, line)
      out.puts line
      Null.new
    end

    # Library absent/refused/bot: every seam is a no-op; the game runs
    # silent and identical (pure-sink law makes the two paths equivalent).
    class Null
      def active? = false
      def attach(bus:, world:) = nil
      def update(_tick) = nil
      def handle_event(_tick, _name, _payload = nil) = nil
      def shutdown = nil
    end

    class Bridge
      def initialize(engine:, audio:, tick_frames:, smoke:, out:)
        @engine = engine
        @audio = audio
        @tf = tick_frames
        @smoke = smoke
        @out = out
        @anchor_tick = nil
        @anchor_pcm = nil
        @drift = [] # [tick, engine_pcm] pairs, anchor cadence only
        @dead = false
      end

      def active? = true

      # One-way wiring: EVERY registered event forwards into the sink
      # (unmapped = nil by design — the mapping lives audio-side). The
      # world reference is read for its frame counter only.
      def attach(bus:, world:)
        bus.registered_types.each do |type|
          bus.subscribe(type) { |ev| @audio.handle_event(world.frame, ev.type, ev.payload) }
        end
        nil
      end

      # Direct injection seam (dev smoke + tests) — below the sim, never
      # through the bus (placeholder events are not whitelisted there).
      def handle_event(tick, name, payload = nil)
        @audio.handle_event(tick, name, payload)
      end

      # Once per frame AFTER the sim tick (bus flushed inside World#tick).
      def update(tick)
        return if @dead
        if @smoke && (cue = SMOKE_SCRIPT[tick])
          @audio.handle_event(tick, cue[0], cue[1])
        end
        drift_sample(tick) if (tick % DRIFT_SAMPLE_TICKS).zero?
        @audio.update(tick)
        nil
      end

      # Contract §3 teardown order: voices/stems/groups (AudioSystem#destroy)
      # -> engine -> caller closes the window. Idempotent (double close
      # writes once — window.rb law).
      def shutdown
        return if @dead
        @dead = true
        drift_report
        @audio.destroy
        GTA::Native.gta_engine_destroy(@engine)
        @out.puts "AUDIO teardown clean (dropped_cues=#{@audio.dropped_cues})"
        nil
      end

      private

      # Contract §3 open item: engine clock vs tick clock, sampled at
      # anchor points on the CONTROL thread only (never per-command).
      def drift_sample(tick)
        pcm = GTA::Native.gta_engine_time_pcm(@engine)
        if @anchor_tick.nil?
          @anchor_tick = tick
          @anchor_pcm = pcm
        end
        @drift << [tick, pcm]
        nil
      end

      def drift_report
        return if @drift.empty? || @anchor_tick.nil?
        @out.puts "AUDIO drift anchor tick=#{@anchor_tick} engine_pcm=#{@anchor_pcm} tick_frames=#{@tf}"
        @drift.each do |tick, pcm|
          expected = @anchor_pcm + (tick - @anchor_tick) * @tf
          @out.puts "AUDIO drift tick=#{tick} engine_pcm=#{pcm} expected=#{expected} drift_frames=#{pcm - expected}"
        end
        nil
      end
    end
  end
end
