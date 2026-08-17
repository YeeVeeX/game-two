require "gosu"
require "core/data_store"
require "core/strings"
require "core/input"
require "core/binding_map"
require "game/world"
require "game/telemetry"
require "app/renderer"
require "app/netplay_overlay"
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

    def initialize(session: nil, relaunch: nil)
      data = Core::DataStore.new(File.expand_path("../../data", __dir__))
      display = data["display"]
      @view_width = display[:view_width]
      @view_height = display[:view_height]
      @scale = App::Scale.factor(display[:window_scale],
                                 view_w: @view_width, view_h: @view_height,
                                 screen_w: Gosu.screen_width, screen_h: Gosu.screen_height)
      super @view_width * @scale, @view_height * @scale
      self.caption = "game-two"
      # v17 session mode: the two-seat World waits for handshake params
      # (seed comes from the host); solo mode constructs it now, unchanged.
      @session = session
      @relaunch = relaunch
      @data = data
      strings = Core::Strings.new(data)
      if @session
        @netplay = NetplayOverlay.new(display:, strings:,
                                      view_w: @view_width, view_h: @view_height)
      else
        @world = Game::World.new(data)
        @telemetry = Game::Telemetry.new(@world.bus, world: @world)
      end
      bindings = Core::BindingMap.load(data, key_table: KEY_TABLE, local: true)
      @input = Core::KeyboardInput.new(bindings: bindings.codes)
      @renderer = Renderer.new(display: display, strings:, bindings: bindings,
                               local_seat: @session ? @session.seat : 1)
      @overruns = 0
      @overrun_font = Gosu::Font.new(14)
    end

    def update
      t0 = Gosu.milliseconds
      @session ? update_session : @world.tick(@input)
      @overruns += 1 if Gosu.milliseconds - t0 > FRAME_BUDGET_MS
    end

    # One update = one session pump (and at most one sim tick inside it).
    # The app layer owns the clock (monotonic ms) — the sim never reads
    # one. Esc quits via the drain (button_down); ended sessions hold the
    # end screen until the player closes it (the state must be READABLE).
    def update_session
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0
      if @world.nil? && @session.params_known?
        @world = Game::World.new(@data, seed: @session.params.seed, seats: 2)
        @telemetry = Game::Telemetry.new(@world.bus, world: @world)
        @session.attach(@world)
      end
      @session.update(now, @input)
      close if @session.ended? && @quitting
    end

    def draw
      Gosu.scale(@scale) do
        @renderer.draw(@world) if @world
        @netplay&.draw(@session, @world)
        if @overruns.positive?
          @overrun_font.draw_text("overruns: #{@overruns}", @view_width - 110, 8, 20, 1, 1,
                                  Gosu::Color.new(200, 255, 120, 120))
        end
      end
    end

    def button_down(id)
      return super unless id == Gosu::KB_ESCAPE
      if @session && !@session.ended? && !@quitting
        @quitting = true # quit! begins the BYE drain; update closes at ended?
        @session.quit!(Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0)
      else
        close
      end
    end

    # The owner's play session prints the fun-verify line to the launching
    # shell on Esc/close — the one session the verdict actually needs. In
    # session mode the netplay TELEMETRY line prints beside it, plus the
    # relaunch command (honest-end friction fold) and the desync artifact
    # path when one exists.
    def close
      puts @telemetry.summary if @telemetry
      if @session
        @session.quit!(Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0) unless @session.ended?
        puts @session.telemetry_line
        puts "desync report: #{@session.artifact_path}" if @session.artifact_path
        puts "relaunch: #{@relaunch}" if @relaunch
      end
      super
    end
  end
end
