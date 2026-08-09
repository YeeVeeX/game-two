require "core/data_store"
require "game/world"
require "app/renderer"

# Replay adapter: the REAL world sim + REAL renderer under scripted input.
# No mocks — what the harness captures is what the player sees.
module Harness
  module Scenes
    class WorldScene
      attr_reader :world

      # Logs key sim events with frame numbers so capture scripts can be
      # aimed at exact moments (telegraph, death, respawn, zone change).
      def initialize(width:, height:)
        data = Core::DataStore.new(File.expand_path("../../data", __dir__))
        @world = Game::World.new(data)
        @renderer = App::Renderer.new
        %i[enemy_telegraph attack_hit entity_died player_hit player_died
           player_respawned zone_entered].each do |ev|
          @world.bus.subscribe(ev) { |e| puts "EVENT #{ev} frame=#{@world.frame} #{e.payload}" }
        end
      end

      def tick(input)
        @world.tick(input)
      end

      def draw
        @renderer.draw(@world)
      end
    end
  end
end
