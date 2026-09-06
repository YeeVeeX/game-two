require "digest"
require "net/event_serial"

module Net
  # v17 decision 6: the desync detector. Per window this folds
  #   (a) EVERY registered bus event — the EventBus whitelist is the
  #       subscription source, NOT the harness's curated list (which
  #       misses registered events like attack_started/damage_dealt);
  #   (b) the consumed input masks per executed tick (fold_input — the
  #       netplay Session calls it; a lane that skips it skips it on BOTH
  #       seats by construction, so digests stay comparable);
  #   (c) at the boundary, the canonical state snapshot
  #       (World#digest_snapshot — flat named scalars, stable ids).
  # One md5 per window. The returned Window record RETAINS snapshot +
  # folded lines: decision 8's desync artifact is written from it when a
  # boundary pair mismatches.
  class StateDigest
    # Versions the canonical byte form; exchanged at the netplay handshake
    # (a mismatch there refuses the session before any tick runs).
    # 3: v19 J7-B — the world zone_left_at row (cold catch-up stamps).
    # 4: v22 T1 — character.<player id> rows (sorted id order; level/xp
    #    moved there from the world row).
    DIGEST_VERSION = 4

    Window = Data.define(:tick, :md5, :snapshot, :lines)

    def initialize(world:, every:)
      @world = world
      @every = every
      @lines = []
      world.bus.registered_types.each do |type|
        world.bus.subscribe(type) { |e| @lines << EventSerial.line(type, world.frame, e) }
      end
    end

    # Seat-ordered masks consumed for the tick about to execute (sampling
    # law: frozen masks, never live reads). Catches input-delivery
    # divergence at the source.
    def fold_input(tick, masks)
      @lines << "INPUT tick=#{tick} masks=#{masks.inspect}"
    end

    # Call once after every EXECUTED World#tick (a stalled update executes
    # no tick and must not call this). Returns the closed Window at each
    # boundary (frame % every == 0), else nil.
    def after_tick
      return nil unless (@world.frame % @every).zero?
      snapshot = @world.digest_snapshot
      md5 = Digest::MD5.hexdigest(self.class.canonical(snapshot, lines: @lines))
      window = Window.new(tick: @world.frame, md5:, snapshot:, lines: @lines)
      @lines = []
      window
    end

    # The one canonical byte form (versioned). Scalars only — enforced by
    # the leaf-type test in the suite: a live object leaking into the
    # snapshot would #inspect with a memory address and desync the digest
    # against itself.
    def self.canonical(snapshot, lines: [])
      "digest_v#{DIGEST_VERSION}\n#{lines.join("\n")}\n#{snapshot.inspect}"
    end
  end
end
