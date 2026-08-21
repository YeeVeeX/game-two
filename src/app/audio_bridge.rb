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
#   4. Cue ids stay mechanical; the event->cue mapping now lives in THIS
#      repo's data/audio/*.json (custody moved game-side 2026-08-18, owner
#      order: owner originals or silence — no placeholder tones). The
#      tables are validated by the library's own AudioData loader.
#   5. Runtime audio files: the owner's original renders ONLY (fixture
#      manifest data/audio/fixtures.json — file-type entries, sha-pinned,
#      converted from game-two-audio/handoff/audio-v1 with source shas
#      verified against THAT manifest). The library's evaluation stems
#      (data/audio_listen/) remain FORBIDDEN at runtime; the assets-lane
#      LUFS gate is a recorded debt (verdict doc).
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
    DATA_DIR = File.expand_path("../../data/audio", __dir__)
    FIXTURE_DIR = File.expand_path("../../tmp/audio_fixtures", __dir__)

    # Drift probe cadence (contract §3 open item — measurement, not a
    # balance tunable): sample the engine clock vs tick*tick_frames every
    # 30 s of play, control thread only, printed at close.
    DRIFT_SAMPLE_TICKS = 1800

    # Dev smoke choreography (--audio-smoke; tooling, below the sim — fired
    # by DIRECT handle_event, so music derivation is exercised via explicit
    # music_set_state entries): tick => [event, payload]. Proves on the real
    # device: ui confirm, stinger + music duck, music state machine both ways.
    SMOKE_SCRIPT = {
      120 => ["banked", nil],
      300 => ["challenger_engaged", nil],
      1200 => ["music_set_state", { state: "combat" }],
      2400 => ["music_set_state", { state: "calm" }],
      3000 => ["zone_entered", nil]
    }.freeze

    module_function

    # Boot per contract §3. Returns a live Bridge or a Null (named line
    # printed either way; audio failures NEVER kill the game).
    # device: 1 = real default device (runtime), 0 = noDevice (tests — the
    # library's own gate mode; real DLL, real render graph, no hardware).
    def boot(lib_root: LIB_ROOT, bot: false, smoke: false, device: 1, out: $stdout)
      # Lane-1 coverage override (2026-08-19): SOAK_AUDIO=1 boots bot
      # seats in noDevice mode — the real DLL + full render graph process
      # an hour of cue traffic with zero hardware contention (two bot
      # processes must never fight over the device). Default stays off:
      # bot seats are silent and cheap.
      if bot
        return null(out, "AUDIO off: bot seat") unless ENV["SOAK_AUDIO"]
        device = 0
      end
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
      data_dir = DATA_DIR # game-two's own tables (owner originals only)
      engine_cfg = JSON.parse(File.read(File.join(data_dir, "engine.json")))
      variants = load_variants(data_dir)
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
                 smoke:, out:, variants:, ambience: load_ambience(data_dir))
    rescue StandardError => e
      null(out, "AUDIO refused: #{e.class}: #{e.message}")
    end

    # Variant tables (v1.1/v2) — game-side custody, OPTIONAL file. events:
    # per-fire cue-take rotation. music_rotation: calm-family stem rotation
    # on a tick cadence. The library never reads this file.
    def load_variants(data_dir)
      path = File.join(data_dir, "variants.json")
      return {} unless File.exist?(path)
      JSON.parse(File.read(path))
    end

    # T3 ambience keying table (D9) — game-side custody, OPTIONAL file.
    # intents: region intent tag -> bed key; zones: zone name -> default
    # bed key. The library never reads this file.
    def load_ambience(data_dir)
      path = File.join(data_dir, "ambience.json")
      return {} unless File.exist?(path)
      JSON.parse(File.read(path))
    end

    # The possessed body's ambience KEY (T3, D9): the first region whose
    # rect contains the tile maps through its intent; otherwise the zone
    # default; otherwise nil (silence — live zones carry no beds yet).
    # Pure function — unit-tested headlessly.
    def ambience_key(table, map, zone, (tx, ty))
      region = map.regions.find do |r|
        x, y, w, h = r[:rect]
        tx >= x && tx < x + w && ty >= y && ty < y + h
      end
      if region && (key = table.dig("intents", region[:intent]))
        return key
      end
      table.dig("zones", zone.to_s)
    end

    def null(out, line)
      out.puts line
      Null.new
    end

    # Library absent/refused/bot: every seam is a no-op; the game runs
    # silent and identical (pure-sink law makes the two paths equivalent).
    class Null
      def active? = false
      def attach(bus:, world:, seat: 1) = nil
      def update(_tick) = nil
      def handle_event(_tick, _name, _payload = nil) = nil
      def shutdown = nil
    end

    # T3 footstep detection (pure; presentation-side). A step is the SAME
    # body committing an ADJACENT tile (Chebyshev 1 — grid steps commit one
    # tile at a time) in the SAME zone. Zone changes, possession swaps, and
    # any multi-tile jump (respawn rebind, teleport-class moves — same body
    # object, distant tile) reset the anchor WITHOUT firing: a jump is not
    # a step. Returns the material to voice, nil otherwise; materials come
    # from the tile registry (nil = unregistered char = silence, never an
    # error).
    class FootstepPoller
      def initialize = @last = nil
      def step(zone:, body_id:, tile:, material:)
        prev = @last
        @last = [zone, body_id, tile]
        return nil if prev.nil? || prev[0] != zone || prev[1] != body_id
        return nil if prev[2] == tile
        return nil unless (prev[2][0] - tile[0]).abs <= 1 && (prev[2][1] - tile[1]).abs <= 1
        material
      end
    end

    # Deterministic take rotation for multi-render cue families (v1.1).
    # "Random" to the ear, mechanical to the machine: an LCG stepped once
    # per fire, seeded from the take-name list, with the no-immediate-repeat
    # rule (next pick always differs from the last when n > 1). Both replay-
    # and netplay-stable: seats derive picks from the same lockstep event
    # stream, no sim state is read, nothing flows back (pure-sink law).
    class VariantRotor
      def initialize(names)
        @names = names
        @state = names.join.each_byte.reduce(5381) { |a, b| ((a * 33) ^ b) & 0x7fffffff }
        @last = nil
        @last_tick = nil
      end

      def next!
        return @names.first if @names.length == 1
        @state = (@state * 1_103_515_245 + 12_345) & 0x7fffffff
        idx = if @last.nil?
                @state % @names.length
              else
                (@last + 1 + (@state % (@names.length - 1))) % @names.length
              end
        @last = idx
        @names[idx]
      end

      # Presentation density: one take per event family per world tick. A
      # coalesced event does not advance the rotor, so lockstep seats sample
      # the same deterministic sequence from the same event/tick stream.
      def next_for_tick(tick)
        return if @last_tick == tick
        @last_tick = tick
        next!
      end

      # Anchor the no-immediate-repeat rule to an externally-known current
      # value (ambient v2: the initial music state) — nil index is a no-op.
      def prime(index)
        @last = index if index
        self
      end
    end

    class Bridge
      # Diagnostics-only reader (tests + drift probe); the sim never sees it.
      attr_reader :audio

      def initialize(engine:, audio:, tick_frames:, smoke:, out:, variants: {}, ambience: {})
        @engine = engine
        @audio = audio
        @tf = tick_frames
        @smoke = smoke
        @out = out
        @variants = variants.fetch("events", {})
        @ambience = ambience
        rotation = variants["music_rotation"]
        @rot_period = rotation&.fetch("period_ticks", nil)
        @rot_states = rotation&.fetch("states", nil)
        @rot_rotor = @rot_states && VariantRotor.new(@rot_states)
        @music_state = nil # last state REQUESTED through this bridge (family gate)
        @anchor_tick = nil
        @anchor_pcm = nil
        @drift = [] # [tick, engine_pcm] pairs, anchor cadence only
        @dead = false
        # T3 world polling (footsteps + ambience keying): read-only
        # presentation reads of the possessed body, renderer-style; set at
        # attach. Nothing flows back (pure-sink law).
        @world = nil
        @seat = 1
        @poller = FootstepPoller.new
        @last_material = nil
        @last_ambience = :unset
      end

      def active? = true

      # One-way wiring: EVERY registered event forwards into the sink
      # (unmapped = nil by design — the mapping lives in data/audio). The
      # world reference is read for its frame counter only. Music derivation
      # (music.json state_events — data-driven, contract recommendation (a)):
      # the named sim events request music states; the sink itself still
      # only knows music_set_state.
      def attach(bus:, world:, seat: 1)
        @world = world
        @seat = seat
        bus.registered_types.each do |type|
          bus.subscribe(type) { |ev| @audio.handle_event(world.frame, ev.type, ev.payload) }
        end
        (@audio.config.music["state_events"] || {}).each do |event, state|
          payload = { state: }.freeze
          bus.subscribe(event.to_sym) do |_ev|
            @music_state = state
            @audio.handle_event(world.frame, "music_set_state", payload)
          end
        end
        @music_state = @audio.config.music["initial_state"]
        @rot_rotor&.prime(@rot_states.index(@music_state))
        # Take rotation (v1.1): listed events ALSO fire one synthetic cue
        # per event-family/tick batch (the raw forward above maps to nothing
        # by design — only the synthetic names carry cue rows). Multi-target
        # sim facts stay intact without layering near-identical transients.
        @variants.each do |event, names|
          rotor = VariantRotor.new(names)
          bus.subscribe(event.to_sym) do |ev|
            cue = rotor.next_for_tick(world.frame)
            # First event in the batch carries the payload (v1 cues are
            # payload-blind; revisit when spatial variants land).
            @audio.handle_event(world.frame, cue, ev.payload) if cue
          end
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
        poll_world(tick)
        rotate_music(tick)
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

      # T3 (D7/D9 SAFE family): footstep materials + ambience keying —
      # per-frame read-only polling of the local seat's possessed body
      # (positions are deterministic sim state; emissions go ONLY into the
      # sink, so replay/netplay digests cannot move — pinned by the
      # pure-sink test). Synthetic sink names (footstep_<material> /
      # ambience_<key>) stay unmapped no-ops until the owner's renders
      # land (cue-spec mail from-game-two-t3-cue-spec.md). The AUDIO log
      # lines fire on CHANGE only — bounded, and the noDevice walkthrough
      # evidence the T3 done-condition names.
      def poll_world(tick)
        return unless @world
        body = @world.possessed(@seat)
        return unless body
        zone = @world.zone_name
        tile = body.tile
        map = @world.map
        material = @world.tile_registry&.material_at(map, *tile)
        fired = @poller.step(zone:, body_id: body.object_id, tile:, material:)
        if fired
          @audio.handle_event(tick, "footstep_#{fired}", nil)
          if fired != @last_material
            @last_material = fired
            @out.puts "AUDIO footstep material=#{fired} zone=#{zone}"
          end
        end
        key = AudioBridge.ambience_key(@ambience, map, zone, tile)
        return if key == @last_ambience
        @last_ambience = key
        @audio.handle_event(tick, "ambience_#{key}", nil) if key
        @out.puts "AUDIO ambience key=#{key || 'none'} zone=#{zone}"
      end

      # Ambient v2: while the last-requested music state sits in the calm
      # family, request the rotor's next variant every period (tick cadence
      # — deterministic, replay/netplay-stable; the library's bar-quantized
      # crossfade makes the seam musical). Combat entry pauses rotation
      # naturally: state_events moves @music_state out of the family; the
      # data-driven return lands on "calm" and rotation resumes. A pick
      # equal to the current state is fired anyway (same-state request is a
      # sink-side no-op) — simplicity over cleverness.
      def rotate_music(tick)
        return unless @rot_rotor && @rot_period
        return unless tick.positive? && (tick % @rot_period).zero?
        return unless @rot_states.include?(@music_state)
        state = @rot_rotor.next!
        @music_state = state
        @audio.handle_event(tick, "music_set_state", { state: }.freeze)
        nil
      end

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
