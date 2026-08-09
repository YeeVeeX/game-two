require "core/data_store"
require "game/arena"
require "app/renderer"

# Replay adapter: the REAL arena sim + REAL renderer under scripted input.
# No mocks — what the harness captures is what the player sees.
module Harness
  module Scenes
    class ArenaScene
      attr_reader :arena

      # Logs key sim events with frame numbers so capture scripts can be
      # aimed at exact moments (telegraph, death, respawn).
      def initialize(width:, height:)
        data = Core::DataStore.new(File.expand_path("../../data", __dir__))
        @arena = Game::Arena.new(data)
        @renderer = App::Renderer.new
        %i[enemy_telegraph attack_hit entity_died player_hit player_died player_respawned].each do |ev|
          @arena.bus.subscribe(ev) { puts "EVENT #{ev} frame=#{@arena.frame}" }
        end
      end

      def tick(input)
        @arena.tick(input)
      end

      def draw
        @renderer.draw(@arena)
      end
    end
  end
end
