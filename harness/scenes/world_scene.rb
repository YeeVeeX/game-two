require "core/data_store"
require "core/strings"
require "core/binding_map"
require "game/world"
require "game/telemetry"
require "app/renderer"
require "app/key_table"
require_relative "../event_log"

# Replay adapter: the REAL world sim + REAL renderer under scripted input.
# No mocks — what the harness captures is what the player sees.
module Harness
  module Scenes
    class WorldScene
      attr_reader :world

      # Logs key sim events with frame numbers so capture scripts can be
      # aimed at exact moments (telegraph, swap, wipe, zone change).
      def initialize(width:, height:, seed: 0, start: nil)
        data = Core::DataStore.new(File.expand_path("../../data", __dir__))
        @world = Game::World.new(data, seed:)
        Harness.apply_start(@world, start)
        # THE LAW (v13 spec): gate/replay captures render locale "en"
        # regardless of env or display.json — translated text never enters
        # a capture (check-comparability law).
        # Same law, bindings (v15): captures render the CANONICAL binding
        # map only — a machine-local bindings.local.json must never change
        # a capture (cross-machine gate comparability; local: false).
        @renderer = App::Renderer.new(display: data["display"],
                                      strings: Core::Strings.new(data, locale: "en"),
                                      bindings: Core::BindingMap.load(
                                        data, key_table: App::KEY_TABLE, local: false
                                      ),
                                      art: App::Art::Registry.load(data))
        # v17: the curated list + serialization live in Harness::EventLog /
        # Net::EventSerial (shared with the headless canaries and the
        # netplay digest) — these lines are the banked etapa-0 instrument
        # and must stay byte-identical.
        Harness::EventLog.attach(@world) { |line| puts line }
        @telemetry = Game::Telemetry.new(@world.bus, world: @world)
      end

      def tick(input) = @world.tick(input)
      def draw = @renderer.draw(@world)
      def summary = @telemetry.summary
    end
  end
end
