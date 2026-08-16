require "core/data_store"
require "core/strings"
require "core/binding_map"
require "game/world"
require "game/telemetry"
require "app/renderer"
require "app/key_table"

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
                                      ))
        %i[telegraph attack_hit actor_died dodged possession_changed
           pack_wiped pack_respawned zone_entered projectile_fired
           special_started pack_mark_set drop_spawned drop_picked_up
           drop_decayed banked carried_lost taunted
           corpse_loaded corpse_looted fight_resolved
           human_retargeted human_leashed
           inscribed banked_spent tribute_paid body_regrown
           body_dissolved mark_consumed vessel_kept human_respawned
           seal_breached home_rehomed respawn_telegraphed
           challenger_engaged challenger_chant_started chant_interrupted
           vessel_seized seizure_ended inscription_burned].each do |ev|
          @world.bus.subscribe(ev) { |e| puts "EVENT #{ev} frame=#{@world.frame} #{describe(e)}" }
        end
        @telemetry = Game::Telemetry.new(@world.bus, world: @world)
      end

      def tick(input) = @world.tick(input)
      def draw = @renderer.draw(@world)
      def summary = @telemetry.summary

      private

      # Payloads carry live Creature objects — log stable identifiers.
      def describe(e)
        e.payload.map { |k, v| "#{k}=#{v.respond_to?(:name) ? v.name : v.inspect}" }.join(" ")
      end
    end
  end
end
