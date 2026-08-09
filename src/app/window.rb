require "gosu"
require "core/data_store"
require "core/input"
require "game/arena"
require "app/renderer"

module App
  # Orchestrator (scope contract: <= ~300 lines). Owns the Gosu window, wires
  # data -> arena -> renderer, and maps the keyboard to abstract actions.
  # ALL game logic lives in Game::Arena and below.
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
      super Game::Arena::WIDTH, Game::Arena::HEIGHT
      self.caption = "game-two"
      data = Core::DataStore.new(File.expand_path("../../data", __dir__))
      @arena = Game::Arena.new(data)
      @input = Core::KeyboardInput.new(bindings: BINDINGS)
      @renderer = Renderer.new
    end

    def update
      @arena.tick(@input)
    end

    def draw
      @renderer.draw(@arena)
    end

    def button_down(id)
      id == Gosu::KB_ESCAPE ? close : super
    end
  end
end
