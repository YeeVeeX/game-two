require "core/data_store"
require "core/strings"
require "core/binding_map"
require "game/world"
require "game/telemetry"
require "app/renderer"
require "app/key_table"
require "app/menu"
require_relative "../event_log"

# J-6 (brief D6): WorldScene's construction + one App::Menu at the SAME
# two-line seam the window runs — the reel proves the SHIPPED routing
# (menu consumes input while open; the world receives NullInput and KEEPS
# TICKING), never a harness re-implementation. No mocks — real world,
# real renderer, real menu.
module Harness
  module Scenes
    class MenuScene
      attr_reader :world

      def initialize(width:, height:, seed: 0, start: nil)
        data = Core::DataStore.new(File.expand_path("../../data", __dir__))
        @world = Game::World.new(data, seed:)
        Harness.apply_start(@world, start)
        # Same pins as WorldScene: locale "en" (check-comparability law) +
        # canonical bindings (local: false — a machine-local override must
        # never change a capture).
        strings = Core::Strings.new(data, locale: "en")
        bindings = Core::BindingMap.load(data, key_table: App::KEY_TABLE, local: false)
        @renderer = App::Renderer.new(display: data["display"], strings:, bindings:)
        @menu = App::Menu.new(display: data["display"], strings:, bindings:,
                              view_w: width, view_h: height)
        Harness::EventLog.attach(@world) { |line| puts line }
        @telemetry = Game::Telemetry.new(@world.bus, world: @world)
      end

      # The window's two-line seam verbatim (brief D1). The QUIT action is
      # deliberately unhandled here: replay length is run_until's law, and
      # what QUIT does belongs to the window (D3) — the reel only proves
      # the rows render and the world ticks beneath them.
      def tick(input)
        @menu.tick(input)
        @world.tick(@menu.route(input))
      end

      def draw
        @renderer.draw(@world)
        # J-3: world reaches the menu as a draw ARG (the window seam
        # verbatim — the stats screen reads it, D7 keeps it unheld).
        @menu.draw(world: @world)
      end

      def summary = @telemetry.summary
    end
  end
end
