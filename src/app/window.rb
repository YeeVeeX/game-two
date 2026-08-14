require "gosu"
require "core/data_store"
require "core/strings"
require "core/input"
require "core/binding_map"
require "game/world"
require "game/telemetry"
require "app/renderer"
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
  class Window < Gosu::Window
    FRAME_BUDGET_MS = 17

    def initialize
      data = Core::DataStore.new(File.expand_path("../../data", __dir__))
      display = data["display"]
      super display[:view_width], display[:view_height]
      self.caption = "game-two"
      @world = Game::World.new(data)
      @telemetry = Game::Telemetry.new(@world.bus, world: @world)
      bindings = Core::BindingMap.load(data, key_table: KEY_TABLE, local: true)
      @input = Core::KeyboardInput.new(bindings: bindings.codes)
      @renderer = Renderer.new(display: display, strings: Core::Strings.new(data),
                               bindings: bindings)
      @overruns = 0
      @overrun_font = Gosu::Font.new(14)
    end

    def update
      t0 = Gosu.milliseconds
      @world.tick(@input)
      @overruns += 1 if Gosu.milliseconds - t0 > FRAME_BUDGET_MS
    end

    def draw
      @renderer.draw(@world)
      if @overruns.positive?
        @overrun_font.draw_text("overruns: #{@overruns}", width - 110, 8, 20, 1, 1,
                                Gosu::Color.new(200, 255, 120, 120))
      end
    end

    def button_down(id)
      id == Gosu::KB_ESCAPE ? close : super
    end

    # The owner's play session prints the fun-verify line to the launching
    # shell on Esc/close — the one session the verdict actually needs.
    def close
      puts @telemetry.summary
      super
    end
  end
end
