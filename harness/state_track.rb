require "json"
require "digest"
require "fileutils"
require "net/lockstep"

# E3a-T2 — Mode T state-track emitter, schema version "1" (spec
# docs/superpowers/specs/2026-08-26-e3a-capture-contract.md §5).
#
# A state track is the per-tick semantic layer the assets seat's
# adjudication consumes: for every executed tick in an explicit window,
# the fields the renderer's creature draw reads plus the indices the
# declared pose-selection mapping needs. Tracks are emitted ONLY from a
# verified bundle, inside the re-executor (bundle_replay.rb) — the
# Sampler here rides verification run 1, so the sampled run's digest
# chain is itself checked against the recorded chain by the two-run gate
# (a separate sampling run would be exactly the unchecked re-execution
# the gate exists to forbid).
#
# Schema pins vs the consumer's draft-1
# (game-two-assets/docs/state-track-schema.md — where this file differs,
# this file wins; their consumer adapts):
#   - schema_version "1" · class RUNTIME (SYNTHETIC stays their word).
#   - tick_ms = Net::Lockstep::TICK_MS verbatim (16.67).
#   - constants are PER-KIT (combat.json carries seven kits; a flat block
#     lies for mixed rosters): step_frames = kits.<kit>.step_frames, the
#     three *_frames from kits.<kit>.attack. Draft-1's windup_px/active_px
#     are DROPPED (renderer-side literals; the headless emitter loads no
#     renderer).
#   - provenance gains bundle_id — a track never self-certifies.
#   - per-tick record adds `possessed` (which body the human drove).
#
# Record semantics (pinned here, named in the delivery mail): a record
# with frame=F carries the world state AFTER the tick that produced
# frame F, and `masks` = the consumed masks that drove that tick
# (input_log.masks[F-1]) — press ticks align with the transition INTO
# the recorded state. Roster = the union of creatures observed in the
# window; a creature absent from a tick's map left play (death/despawn)
# or had not yet spawned. A window that crosses a zone transition
# refuses NAMED — `zone` and `view` would lie about every record past
# the crossing; split the window at the transition instead.
module Harness
  module StateTrack
    SCHEMA_VERSION = "1"
    TRACK_CLASS = "RUNTIME"
    NAME_RE = /\A[a-z0-9][a-z0-9_\-]{0,63}\z/

    # "Cannot emit this track" — never a verdict on the bundle.
    class Refused < StandardError; end

    # Per-tick state collector. Reads creatures through digest_fields —
    # the engine's own canonical leaf-typed state export (the digest
    # lane's arbiter) — so the track can never disagree with what the
    # verification gate just checked, and no frozen sim file needs a new
    # reader.
    class Sampler
      attr_reader :ticks, :zone, :view, :zone_crossing

      def initialize(range:)
        @range = range
        @ticks = []
        @roster = {}
        @zone = nil
        @view = nil
        @zone_crossing = nil
      end

      def roster = @roster.keys.sort.map { |name| @roster[name] }

      # Called by the re-executor after each executed tick of run 1,
      # with the masks that tick consumed. world.frame has already
      # advanced to the frame this record describes.
      def call(world, masks)
        frame = world.frame
        return unless @range.cover?(frame)
        if @zone.nil?
          @zone = world.zone_name.to_s
          map = world.map
          @view = { origin_px: [0, 0], width: map.cols * map.tile_size,
                    height: map.rows * map.tile_size }
        elsif @zone_crossing.nil? && world.zone_name.to_s != @zone
          @zone_crossing = { frame: frame, to: world.zone_name.to_s }
        end
        possessed = world.controlled_bodies
        creatures = {}
        (world.pack.members + world.humans).each do |c|
          @roster[c.name] ||= { name: c.name, faction: c.faction.to_s,
                                kit: c.kit_name.to_s }
          creatures[c.name] = record(c, possessed)
        end
        @ticks << { frame: frame, creatures: creatures,
                    masks: masks.each_with_index.to_h { |m, i| [(i + 1).to_s, m] } }
      end

      private

      def record(creature, possessed)
        f = creature.digest_fields.to_h
        {
          tile_x: f["tile_x"], tile_y: f["tile_y"],
          px: f["px"], py: f["py"],
          facing: [f["facing_x"], f["facing_y"]],
          tween_left: f["tween_left"], tween_total: f["tween_total"],
          attack_state: f["action_state"].to_s,
          current_action: f["action"]&.to_s,
          state_frames: f["action_frames"],
          hp: f["hp"], iframes: f["iframes"],
          possessed: possessed.any? { |b| b.equal?(creature) }
        }
      end
    end

    module_function

    # Refusals that need no execution — checked BEFORE the two-run gate
    # burns its re-executions.
    def validate_request!(dir, manifest, range:, name:)
      ticks = manifest.fetch(:ticks_executed)
      unless range.first >= 1 && range.last <= ticks && range.first <= range.last
        raise Refused,
              "track refused — tick range #{range} outside the bundle's produced " \
              "frames 1..#{ticks} (frame 0 is constructor state; no tick produced it)"
      end
      unless track_name(name, range).match?(NAME_RE)
        raise Refused,
              "track refused — name #{name.inspect} (want #{NAME_RE.inspect})"
      end
      path = track_path(dir, name, range)
      raise Refused, "track refused — #{path} already exists (tracks are write-once)" if File.exist?(path)
    end

    def track_name(name, range) = name || "t#{range.first}-#{range.last}"

    def track_path(dir, name, range)
      File.join(dir, "tracks", "#{track_name(name, range)}.json")
    end

    # Builds and writes tracks/<name>.json + sidecar sha256 from a
    # Sampler that rode a PASS verification. Returns the track path.
    # Constants are denormalized from the verifying tree's combat.json —
    # the fingerprint gate just proved this tree IS the producing build
    # (data/** is inside the handshake identity), so "at the bundle's
    # fingerprint" holds by construction.
    def write(dir, sampler:, manifest:, receipt:, root:, name: nil, range:)
      if sampler.zone_crossing
        raise Refused,
              "track refused — window crosses a zone transition at frame " \
              "#{sampler.zone_crossing[:frame]} (#{sampler.zone} -> " \
              "#{sampler.zone_crossing[:to]}); zone/view would lie past the " \
              "crossing — split the window there"
      end
      if sampler.ticks.empty?
        raise Refused, "track refused — the window sampled zero executed ticks"
      end
      doc = {
        schema_version: SCHEMA_VERSION,
        class: TRACK_CLASS,
        tick_ms: Net::Lockstep::TICK_MS,
        zone: sampler.zone,
        view: sampler.view,
        constants: constants_for(sampler.roster.map { |r| r[:kit] }.uniq.sort, root: root),
        creatures: sampler.roster,
        ticks: sampler.ticks,
        provenance: {
          class: TRACK_CLASS,
          producer: "harness/bundle_replay.rb --track (game-two, E3a-T2)",
          bundle_id: manifest.fetch(:bundle_id),
          statement: "emitted offline by re-executing bundle " \
                     "#{manifest.fetch(:bundle_id)} over frames " \
                     "#{sampler.ticks.first[:frame]}..#{sampler.ticks.last[:frame]}; " \
                     "the sampled run is run 1 of the #{receipt[:runs]}-run " \
                     "verification gate (verdict #{receipt[:verdict]})"
        }
      }
      path = track_path(dir, name, range)
      # Recheck at write time — validate_request! ran BEFORE the two-run
      # gate, and write-once must hold at the byte moment (review s84).
      raise Refused, "track refused — #{path} already exists (tracks are write-once)" if File.exist?(path)
      FileUtils.mkdir_p(File.dirname(path))
      # LF bytes on every platform — sidecar sha256s must not depend on
      # the producing machine's text-mode translation (T1 law).
      File.binwrite(path, JSON.pretty_generate(doc) << "\n")
      File.binwrite("#{path}.sha256",
                    "#{Digest::SHA256.hexdigest(File.binread(path))}  #{File.basename(path)}\n")
      path
    end

    # Per-kit constants (spec §5 correction 3, selection rule named):
    # step_frames = kits.<kit>.step_frames; the three *_frames = the
    # kit's `attack` sub-object. Attack-only is sufficient — the
    # consumer's mapping refuses unmapped-action-class for specials.
    def constants_for(kits, root:)
      combat = JSON.parse(File.binread(File.join(root, "data", "balance", "combat.json")),
                          symbolize_names: true)
      kits.to_h do |kit|
        k = combat.fetch(:kits)[kit.to_sym] or
          raise Refused, "track refused — kit #{kit.inspect} not in data/balance/combat.json"
        atk = k.fetch(:attack)
        [kit, { step_frames: k.fetch(:step_frames),
                windup_frames: atk.fetch(:windup_frames),
                active_frames: atk.fetch(:active_frames),
                recovery_frames: atk.fetch(:recovery_frames) }]
      end
    end
  end
end
