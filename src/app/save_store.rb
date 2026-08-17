require "json"
require "digest"
require "fileutils"
require "game/save_state"

module App
  # v18 persistence IO (spec decisions 2/5/6a/14): ONE machine-local,
  # host-authoritative save file. App-layer on purpose — the sim never
  # does IO (World only ever sees a validated facts tree via `save:`).
  #
  # Write law (decision 14, Windows-safe): same-dir `.tmp` -> flush +
  # fsync -> CLOSE -> replace onto the target, bounded retry (3 x 50ms)
  # on a refused replace (open handle: second instance / editor / AV) ->
  # NAMED WriteError with the .tmp intact. Durability is best-effort BY
  # DESIGN (no directory fsync on Windows/Ruby): the crash lanes
  # guarantee INTEGRITY of the old save, not last-write durability
  # against a power cut — recorded, accepted for a hobby save.
  #
  # The written envelope embeds the canonical facts byte form VERBATIM
  # (decision 5): the digest a persist line prints is md5 over exactly
  # those bytes, recomputed at print time — never an echo.
  class SaveStore
    Loaded = Data.define(:facts, :digest, :notices)
    Refused = Data.define(:refusal, :notices)
    Fresh = Data.define(:notices)

    class WriteError < StandardError; end

    REPLACE_RETRIES = 3
    REPLACE_RETRY_SLEEP_S = 0.05

    attr_reader :path

    def initialize(path:)
      @path = path
    end

    # -> Loaded | Refused | Fresh. Both load paths run the strict decoder
    # BEFORE any window opens (decision 6a); an unparseable or truncated
    # file is itself a NAMED refusal with recovery hints (.bak if present,
    # orphan .tmp named), never a raw JSON crash.
    def load(data:)
      notices = orphan_notices
      return Fresh.new(notices:) unless File.exist?(@path)
      raw = File.read(@path, mode: "rb")
      begin
        env = JSON.parse(raw)
      rescue JSON::ParserError => e
        return Refused.new(refusal: "save file unreadable: #{@path} — #{e.class}#{bak_hint}",
                           notices:)
      end
      refusal = Game::SaveState.envelope_refusal(env, data:)
      return Refused.new(refusal: "#{refusal}#{bak_hint}", notices:) if refusal
      facts = env["facts"]
      Loaded.new(facts:, digest: Game::SaveState.digest(facts), notices:)
    end

    # Atomic write; returns the digest of the canonical facts bytes that
    # are now on disk. Raises WriteError (named, .tmp intact) when the
    # replace is refused past the bounded retry.
    def write(facts, saved_at_ms: (Time.now.to_f * 1000).to_i)
      canonical = Game::SaveState.canonical_bytes(facts)
      digest = Digest::MD5.hexdigest(canonical)
      payload = %({"schema":#{Game::SaveState::SCHEMA},"saved_at_ms":#{Integer(saved_at_ms)},"facts":#{canonical}})
      FileUtils.mkdir_p(File.dirname(@path))
      tmp = "#{@path}.tmp"
      File.open(tmp, "wb") do |f|
        f.write(payload)
        f.flush
        f.fsync
      end
      replace!(tmp)
      digest
    end

    # --fresh backup law (decision 14): the existing save moves to
    # .bak-<ts> BEFORE the fresh session's first write — the
    # irreversibility guard. A crash between backup and write leaves the
    # .bak recoverable (and the next plain launch honestly fresh).
    def backup_fresh!
      return nil unless File.exist?(@path)
      bak = "#{@path}.bak-#{Time.now.strftime('%Y%m%d%H%M%S')}"
      File.rename(@path, bak)
      bak
    end

    # The pinned persist-line vocabulary (decision 5; the SEVENTEENTH's
    # Half A compares these verbatim across sessions and seats).
    def self.persist_line(kind, facts: nil, digest: nil, source: nil)
      parts = ["TELEMETRY persist #{kind}"]
      parts << "digest=#{digest}" if digest
      parts << "schema=#{Game::SaveState::SCHEMA}"
      if facts
        parts << "banked=#{facts['banked']}"
        parts << "provisions=#{facts['provisions']}"
        parts << "seals=#{facts['breached'].length}"
        parts << "marks=#{facts['members'].count { |m| m['inscribed'] }}"
        parts << "sessions=#{facts['counters']['sessions']}"
      end
      parts << "source=#{source}" if source
      parts.join(" ")
    end

    private

    def replace!(tmp)
      attempts = 0
      begin
        File.rename(tmp, @path)
      rescue SystemCallError => e
        attempts += 1
        if attempts <= REPLACE_RETRIES
          sleep(REPLACE_RETRY_SLEEP_S)
          retry
        end
        raise WriteError,
              "save replace refused (#{e.class}: target open elsewhere?) — " \
              "progress intact at #{tmp}; close the other instance and quit again"
      end
    end

    def orphan_notices
      tmp = "#{@path}.tmp"
      return [] unless File.exist?(tmp)
      return [] if File.exist?(@path) && File.mtime(tmp) <= File.mtime(@path)
      last_good = File.exist?(@path) ? @path : "absent"
      ["orphan save temp #{tmp} (a save write did not complete; last good save: #{last_good})"]
    end

    def bak_hint
      bak = Dir["#{@path}.bak-*"].max
      bak ? " (recovery: newest backup #{File.basename(bak)})" : ""
    end
  end

  # Decision 2: ONE idempotent close seam. Writes IFF this seat owns the
  # save (solo player, or the netplay HOST) AND the session ended clean
  # (reason=:quit — either seat's Esc lands :quit on BOTH seats via
  # BYE_REASONS). Desync, conn_lost, protocol fault, refusal, or a crash
  # write NOTHING — a diverged world is suspect state and must never
  # poison the save. Repeated close callbacks write once. `sessions`
  # increments here, at the write (never in the sim).
  class SaveCoordinator
    def initialize(store:, owner:)
      @store = store
      @owner = owner
      @closed = false
    end

    # -> the persist line to print, or nil when nothing was written.
    def close(world:, reason:)
      return nil if @closed
      @closed = true
      return nil unless @owner && reason == :quit
      facts = world.save_facts
      facts["counters"]["sessions"] += 1
      digest = @store.write(facts)
      SaveStore.persist_line("saved", facts:, digest:)
    rescue SaveStore::WriteError => e
      "persist ERROR #{e.message}"
    end
  end
end
