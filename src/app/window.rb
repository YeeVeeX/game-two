require "gosu"
require "core/data_store"
require "core/strings"
require "core/input"
require "core/binding_map"
require "game/world"
require "game/telemetry"
require "app/renderer"
require "app/menu"
require "app/prefs"
require "app/netplay_overlay"
require "app/frame_probe"
require "app/vsync_release"
require "app/scale"
require "app/key_table"

module App
  # Orchestrator (scope contract: <= ~300 lines). Owns the Gosu window, wires
  # data -> world -> renderer, and maps the keyboard to abstract actions.
  # ALL game logic lives in Game::World and below.
  #
  # Bindings (v15): data/bindings.json + optional per-machine
  # data/bindings.local.json, resolved through App::KEY_TABLE by
  # Core::BindingMap — the SAME map feeds KeyboardInput and the controls
  # strip. Live play is the only local-override consumer (the harness pins
  # canonical — gate comparability law).
  #
  # Timebase: update() = exactly ONE sim tick (tick-locked; replays are
  # deterministic by tick count). Under load the game slows rather than
  # skipping — the overrun counter below makes that visible so a sluggish
  # playtest is diagnosed as perf, not misread as balance.
  #
  # v16 (a): the window opens at view*scale and ONE Gosu.scale wraps the
  # draw — everything below draws in LOGICAL 960×540 space, unchanged. The
  # harness never uses this class (replay windows open at script dims), so
  # captures are scale-blind by construction.
  class Window < Gosu::Window
    FRAME_BUDGET_MS = 17

    attr_reader :scale, :view_width, :view_height

    def initialize(session: nil, relaunch: nil, seed: 0, save: nil, saver: nil, bot: nil,
                   audio: nil, start_zone: nil, players: nil)
      data = Core::DataStore.new(File.expand_path("../../data", __dir__))
      display = data["display"]
      # J6-B: machine-local client prefs (presentation only — never the
      # world save). A pref beats display.json; the launcher locale arg
      # stays king via GAME_LOCALE (brief D9/D10).
      @prefs = Prefs.load(File.expand_path("../../data/prefs.local.json", __dir__))
      @view_width = display[:view_width]
      @view_height = display[:view_height]
      @scale = App::Scale.factor(@prefs.window_scale || display[:window_scale],
                                 view_w: @view_width, view_h: @view_height,
                                 screen_w: Gosu.screen_width, screen_h: Gosu.screen_height)
      super @view_width * @scale, @view_height * @scale
      self.caption = "game-two"
      self.fullscreen = true if @prefs.fullscreen
      # Lag P0 T4: env-gated vsync release — the ONE site that reads the
      # flag; absent = nil = zero cost (the wall never sets it). Must run
      # after super: the GL context exists and Gosu's own
      # SDL_GL_SetSwapInterval(1) has already run (Window.cpp:111).
      if (vsync = App::VsyncRelease.apply)
        puts vsync
      end
      # v17 session mode: the two-seat World waits for handshake params
      # (seed comes from the host); solo mode constructs it now with the
      # per-session seed + validated save facts from main.rb (v18
      # decisions 4/16). @saver is the save coordinator — solo player or
      # netplay HOST (the joiner carries none: it never persists the
      # shared world).
      @session = session
      @relaunch = relaunch
      @saver = saver
      @audio = audio # M5a: pure sink; attach where the world is born
      AudioBridge.apply_volume_prefs(@audio, @prefs) if @audio
      # Lane 1 (2026-08-19): bot-gated coverage start (World#start_in, the
      # harness primitive) — applied at world birth on BOTH paths; netplay
      # seats receive the same zone by construction (run_soak.sh).
      @start_zone = start_zone
      @data = data
      strings = Core::Strings.new(data, locale: ENV.fetch("GAME_LOCALE", nil) || @prefs.locale)
      if @session
        @netplay = NetplayOverlay.new(display:, strings:,
                                      view_w: @view_width, view_h: @view_height)
      else
        @world = Game::World.new(data, seed:, save:, players:) # v22 T1: {1 => this machine's id}
        @telemetry = Game::Telemetry.new(@world.bus, world: @world)
        @audio&.attach(bus: @world.bus, world: @world)
        @world.start_in(@start_zone) if @start_zone
      end
      bindings = Core::BindingMap.load(data, key_table: KEY_TABLE, local: true)
      # v18 soak (brief D1): a bot seat swaps the keyboard for the seeded
      # autopilot at the SAME seam — sim and session code never know.
      @autopilot = bot
      @input = @autopilot || Core::KeyboardInput.new(bindings: bindings.codes)
      # J-6 (drafts/_j6-menu-brief-20260823.md): the non-pausing menu at
      # the ONE input seam — open routes NullInput (idle frames keep
      # flowing; the sim never knows). Bots never emit :menu.
      @menu = Menu.new(display:, strings:, bindings:, prefs: @prefs, audio: @audio,
                       on_locale: ->(l) { strings.switch!(data, l) },
                       on_scale: ->(k) { apply_scale(k) },
                       on_fullscreen: ->(v) { self.fullscreen = v },
                       view_w: @view_width, view_h: @view_height)
      @bag_codes = bindings.respond_to?(:codes) ? Array(bindings.codes[:bag]) : []
      @renderer = Renderer.build(data, display: display, strings:, bindings: bindings,
                                 local_seat: @session ? @session.seat : 1)
      @overruns = 0
      @overrun_font = Gosu::Font.new(14)
      # Lag P0 T1b: env-gated frame probe — nil when off, so every site
      # below is a bare nil-check (no clock read, no allocation, no
      # branch into sim/draw). Values leave ONLY as the close-time line.
      @frame_probe = ENV["GAME_FRAME_PROBE"] ? FrameProbe.new : nil
    end

    def update
      @frame_probe&.update_begin
      t0 = Gosu.milliseconds
      if @session
        update_session
      else
        # Uniform sampling law: the caller updates the source (no-op for
        # a keyboard, the tick function for a bot/script).
        @input.update(@world.frame)
        handle_menu(@menu.tick(@input)) if menu_active?
        @world.tick(@menu.route(@input))
      end
      autopilot_watch if @autopilot
      @audio&.update(@world.frame) if @world # after the tick; bus already flushed
      @overruns += 1 if Gosu.milliseconds - t0 > FRAME_BUDGET_MS
      @frame_probe&.update_end
    end

    # One update = one session pump (and at most one sim tick inside it).
    # The app layer owns the clock (monotonic ms) — the sim never reads
    # one. Esc quits via the drain (button_down); ended sessions hold the
    # end screen until the player closes it (the state must be READABLE).
    def update_session
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0
      if @world.nil? && @session.params_known?
        # v18 decision 4: BOTH seats construct from the handshake-frozen
        # Params — the host's validated tree IS the joiner's parsed wire
        # bytes (digest law), so the two sims start identical.
        @world = Game::World.new(@data, seed: @session.params.seed, seats: 2,
                                 save: @session.params.save, players: @session.players)
        @telemetry = Game::Telemetry.new(@world.bus, world: @world)
        # T3: the bridge polls the LOCAL seat's possessed body (footstep
        # materials — each seat hears its own steps; pure sink, sim blind).
        @audio&.attach(bus: @world.bus, world: @world, seat: @session.seat)
        @world.start_in(@start_zone) if @start_zone
        @session.attach(@world)
        # Lag P0 (2026-08-20): bank the handshake-frozen numbers (d /
        # link_slow / host probe RTTs) at world birth — the close line
        # only prints on a clean end; this one survives a dirty death.
        puts @session.handshake_line
      end
      handle_menu(@menu.tick(@input)) if menu_active?
      @session.update(now, @menu.route(@input))
      @menu.close! if @menu.open? && @session.ended? # end screen owns the frame (J6-C)
      close if @session.ended? && @quitting
    end

    # The menu ticks only over a live world: never in hosting/connecting
    # (button_down owns Esc there), never on an end screen, never during
    # the BYE drain (no reopen mid-drain — brief D2).
    def menu_active? = @world && !@quitting && !@session&.ended?

    # D3: QUIT lands on the OLD Esc body verbatim — a live session quits
    # via the BYE drain, solo closes (the save write IS this path).
    def handle_menu(action)
      return unless action == :quit
      if @session && !@session.ended?
        request_quit
      else
        close
      end
    end

    def draw
      @frame_probe&.draw_begin
      Gosu.scale(@scale) do
        @renderer.draw(@world) if @world
        @netplay&.draw(@session, @world)
        @menu.draw(session: @session, world: @world)
        if @overruns.positive?
          @overrun_font.draw_text("overruns: #{@overruns}", @view_width - 110, 8, 20, 1, 1,
                                  Gosu::Color.new(200, 255, 120, 120))
        end
      end
      @frame_probe&.draw_end
    end

    # Bot seat (v18 soak): quit through the SAME Esc path at quit_tick,
    # and never hold an end screen — a bot reads logs, not screens (a
    # held DESYNC/CONNECTION LOST screen would hang every episode).
    def autopilot_watch
      return if @bot_done
      if @session
        if @session.ended? && !@quitting
          @bot_done = true
          close
        elsif !@quitting && @autopilot.quit?(@session.ticks)
          request_quit
        end
      elsif @autopilot.quit?(@world.frame)
        @bot_done = true
        close
      end
    end

    def request_quit
      @quitting = true # quit! begins the BYE drain; update closes at ended?
      @session.quit!(Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0)
    end

    # J6-B (D12): live re-scale — presentation only. Captures are
    # scale-blind by law (the harness renders at script dims), so this
    # path ships as unit math + an observation note (the v16 precedent).
    def apply_scale(setting)
      @scale = App::Scale.factor(setting, view_w: @view_width, view_h: @view_height,
                                 screen_w: Gosu.screen_width, screen_h: Gosu.screen_height)
      self.width = @view_width * @scale
      self.height = @view_height * @scale
    end

    def button_down(id)
      # S2: the bag key toggles the bag SCREEN (UI only - the sim, the
      # protocol and the digest never see it; both seats keep their own).
      if @world && @world.items_enabled? && @bag_codes.include?(id) # DARK-SHIP: toggle inert while items are off
        @renderer.bag_open = !@renderer.bag_open
        return
      end
      return super unless id == Gosu::KB_ESCAPE
      # J-6 (brief D2), Esc semantics changed ON PURPOSE: while playing,
      # Esc falls through to the :menu binding — QUIT is a menu row. Kept
      # here: ended session → close (end-screen law); session with no
      # world yet (HOSTING/CONNECTING) → cancel via the drain.
      if @session&.ended?
        close
      elsif @session && @world.nil? && !@quitting
        request_quit
      end
    end

    # The owner's play session prints the fun-verify line to the launching
    # shell on Esc/close — the one session the verdict actually needs. In
    # session mode the netplay TELEMETRY line prints beside it, plus the
    # relaunch command (honest-end friction fold) and the desync artifact
    # path when one exists.
    def close
      puts @frame_probe.line if @frame_probe
      puts @telemetry.summary if @telemetry
      # v18 decision 2: the coordinator writes IFF this seat owns the save
      # AND the end is clean. Solo close IS the clean quit (Esc or the
      # window X). Session mode: resolve the session end FIRST (the X
      # path quits here), then gate the write on the session's OWN reason
      # — either seat's Esc lands :quit on both seats; desync/conn_lost/
      # protocol write NOTHING. Idempotent: a double close writes once.
      if @session && !@session.ended?
        @session.quit!(Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0)
      end
      reason = @session ? @session.reason : :quit
      if @world && (line = @saver&.close(world: @world, reason:))
        puts line
      end
      if @session
        puts @session.telemetry_line
        puts "desync report: #{@session.artifact_path}" if @session.artifact_path
        puts "relaunch: #{@relaunch}" if @relaunch
      end
      @audio&.shutdown # contract §3 teardown: sink -> engine -> window close
      super
    end
  end
end
