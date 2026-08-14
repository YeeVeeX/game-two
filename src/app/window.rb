require "gosu"
require "core/data_store"
require "core/strings"
require "core/input"
require "game/world"
require "game/telemetry"
require "app/renderer"

module App
  # Orchestrator (scope contract: <= ~300 lines). Owns the Gosu window, wires
  # data -> world -> renderer, and maps the keyboard to abstract actions.
  # ALL game logic lives in Game::World and below.
  #
  # Timebase: update() = exactly ONE sim tick (tick-locked; replays are
  # deterministic by tick count). Under load the game slows rather than
  # skipping — the overrun counter below makes that visible so a sluggish
  # playtest is diagnosed as perf, not misread as balance.
  class Window < Gosu::Window
    BINDINGS = {
      left:   [Gosu::KB_LEFT, Gosu::KB_A],
      right:  [Gosu::KB_RIGHT, Gosu::KB_D],
      up:     [Gosu::KB_UP, Gosu::KB_W],
      down:   [Gosu::KB_DOWN, Gosu::KB_S],
      attack: [Gosu::KB_J, Gosu::KB_SPACE],
      dodge:  [Gosu::KB_K, Gosu::KB_LEFT_SHIFT],
      special: [Gosu::KB_L, Gosu::KB_E],
      mark: [Gosu::KB_SEMICOLON, Gosu::KB_Q],
      interact: [Gosu::KB_H, Gosu::KB_F],
      swap:   [Gosu::KB_TAB]
    }.freeze

    FRAME_BUDGET_MS = 17

    def initialize
      data = Core::DataStore.new(File.expand_path("../../data", __dir__))
      display = data["display"]
      super display[:view_width], display[:view_height]
      self.caption = "game-two"
      @world = Game::World.new(data)
      @telemetry = Game::Telemetry.new(@world.bus, world: @world)
      @input = Core::KeyboardInput.new(bindings: BINDINGS)
      @renderer = Renderer.new(display: display, strings: Core::Strings.new(data))
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
