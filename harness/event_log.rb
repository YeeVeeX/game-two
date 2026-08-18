require "net/event_serial"

module Harness
  # The wall's curated event log (v17: extracted from WorldScene so the
  # headless sim-identity canaries subscribe to the SAME list — the three
  # banked etapa-0 md5s are digests over exactly these lines). Curated on
  # purpose: capture scripts aim at these moments by name. The netplay
  # digest does NOT read this list — it folds EVERY registered bus event
  # (spec decision 6; this list misses e.g. attack_started, damage_dealt).
  module EventLog
    EVENTS = %i[telegraph attack_hit actor_died dodged possession_changed
                pack_wiped pack_respawned zone_entered projectile_fired
                special_started pack_mark_set drop_spawned drop_picked_up
                drop_decayed banked carried_lost taunted
                corpse_loaded corpse_looted fight_resolved
                human_retargeted human_leashed
                inscribed banked_spent tribute_paid body_regrown
                body_dissolved mark_consumed vessel_kept human_respawned
                seal_breached home_rehomed respawn_telegraphed
                challenger_engaged challenger_chant_started chant_interrupted
                vessel_seized seizure_ended inscription_burned
                provision_bought provision_used provision_refused].freeze

    # Subscribes the standard log to a world; the sink receives each
    # formatted line (WorldScene puts it; the headless driver collects it).
    def self.attach(world, &sink)
      EVENTS.each do |ev|
        world.bus.subscribe(ev) { |e| sink.call(Net::EventSerial.line(ev, world.frame, e)) }
      end
    end
  end
end
