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
      # aimed at exact moments (telegraph, swap, wipe, zone change).
      def initialize(width:, height:, seed: 0)
        data = Core::DataStore.new(File.expand_path("../../data", __dir__))
        @world = Game::World.new(data, seed:)
        @renderer = App::Renderer.new
        %i[telegraph attack_hit actor_died dodged possession_changed
           pack_wiped pack_respawned zone_entered projectile_fired
           special_started pack_mark_set drop_spawned drop_picked_up
           drop_decayed banked carried_lost].each do |ev|
          @world.bus.subscribe(ev) { |e| puts "EVENT #{ev} frame=#{@world.frame} #{describe(e)}" }
        end
      end

      def tick(input) = @world.tick(input)
      def draw = @renderer.draw(@world)

      private

      # Payloads carry live Creature objects — log stable identifiers.
      def describe(e)
        e.payload.map { |k, v| "#{k}=#{v.respond_to?(:name) ? v.name : v.inspect}" }.join(" ")
      end
    end
  end
end
