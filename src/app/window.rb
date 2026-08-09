require "gosu"
require "core/data_store"
require "core/input"
require "game/world"
require "app/renderer"

module App
  # Orchestrator (scope contract: <= ~300 lines). Owns the Gosu window, wires
  # data -> world -> renderer, and maps the keyboard to abstract actions.
  # ALL game logic lives in Game::World and below.
  class Window < Gosu::Window
    BINDINGS = {
      left:   [Gosu::KB_LEFT, Gosu::KB_A],
      right:  [Gosu::KB_RIGHT, Gosu::KB_D],
      up:     [Gosu::KB_UP, Gosu::KB_W],
      down:   [Gosu::KB_DOWN, Gosu::KB_S],
      attack: [Gosu::KB_J, Gosu::KB_SPACE],
      dodge:  [Gosu::KB_K, Gosu::KB_LEFT_SHIFT]
    }.freeze

    def initialize
      data = Core::DataStore.new(File.expand_path("../../data", __dir__))
      display = data["display"]
      super display[:view_width], display[:view_height]
      self.caption = "game-two"
      @world = Game::World.new(data)
      @input = Core::KeyboardInput.new(bindings: BINDINGS)
      @renderer = Renderer.new
    end

    def update
      @world.tick(@input)
    end

    def draw
      @renderer.draw(@world)
    end

    def button_down(id)
      id == Gosu::KB_ESCAPE ? close : super
    end
  end
end
