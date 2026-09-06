require "json"
require "securerandom"
require "fileutils"

module App
  # v22 T1 — the PLAYER IDENTITY file (foundation Rule 1c, L20-1: characters
  # are keyed by PLAYER identity, never seat). `data/player.local.json` is
  # MACHINE-written on first boot:
  #
  #   { "player_id": "<uuid v4>", "created_at_ms": <int> }
  #
  # The id names this machine's characters in every save it ever touches
  # (the host's own record, and the guest record the host keeps for a
  # partner — v18's joiner-never-keeps law stands). It travels ONLY in the
  # netplay HELLO; no surface shows it (player N stays the label, owner
  # placeholder order).
  #
  # Laws carried here:
  #   - TWIN LAW (J6-B D9 / s55): a machine-written file lands in BOTH
  #     DataStore::MACHINE_WRITTEN (the loud parse-abort is for hand-edited
  #     files) and Net::Fingerprint::EXCLUDED (a gitignored per-machine
  #     file in the handshake hash = a permanent coop refusal). prefs.local
  #     is the working precedent; this file is its second member.
  #   - LENIENT-NAMED reader (App::Prefs precedent): a corrupt or foreign
  #     file NEVER bricks boot — it is backed up beside itself
  #     (.corrupt-<ts>, the bytes survive for a hand recovery), a fresh id
  #     is written, and ONE printed line names what happened, including the
  #     consequence: the old id's characters stay in every save as unseated
  #     records until someone restores the id by hand.
  #   - Bots and harness seats never read this file: `bot_id(seed)` derives
  #     "bot-<seed>" deterministically so replays and soaks stay
  #     byte-identical (the format is disjoint from a uuid by construction;
  #     Game::Character::PLAYER_ID pins both shapes).
  class PlayerFile
    UUID_V4 = /\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/
    DEFAULT_PATH = File.expand_path("../../data/player.local.json", __dir__)

    attr_reader :player_id, :created_at_ms, :path

    def self.bot_id(seed) = "bot-#{Integer(seed)}"

    # -> PlayerFile. Never raises for file trouble; every recovery prints
    # one named line on `out`.
    def self.load(path = DEFAULT_PATH, out: $stdout, now_ms: (Time.now.to_f * 1000).to_i)
      raw = File.exist?(path) ? File.binread(path) : nil
      values = parse(raw)
      id = values.is_a?(Hash) ? values["player_id"] : nil
      if id.is_a?(String) && UUID_V4.match?(id)
        at = values["created_at_ms"]
        return new(path:, player_id: id, created_at_ms: at) if at.is_a?(Integer) && at >= 0
        file = new(path:, player_id: id, created_at_ms: now_ms)
        file.write(out:)
        out.puts "player file: created_at_ms invalid (#{at.inspect}); repaired, id kept"
        return file
      end
      file = new(path:, player_id: SecureRandom.uuid, created_at_ms: now_ms)
      if raw.nil?
        file.write(out:)
        out.puts "player file: created #{path} (this machine's player id names its " \
                 "characters in every save — keep it)"
      else
        bak = "#{path}.corrupt-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        File.binwrite(bak, raw)
        file.write(out:)
        out.puts "player file: #{path} unreadable (#{describe(raw, values)}); original kept " \
                 "at #{File.basename(bak)}, NEW id written — the old id's characters stay " \
                 "in every save as unseated records until the id is restored by hand"
      end
      file
    end

    def initialize(path:, player_id:, created_at_ms:)
      @path = path
      @player_id = player_id
      @created_at_ms = created_at_ms
    end

    def to_h = { "player_id" => @player_id, "created_at_ms" => @created_at_ms }

    # Best-effort write (Prefs precedent): a refused write is one named
    # line, and the in-memory id still serves the session.
    def write(out: $stdout)
      FileUtils.mkdir_p(File.dirname(@path))
      File.write(@path, JSON.pretty_generate(to_h) + "\n")
      true
    rescue SystemCallError => e
      out.puts "player file: write failed (#{e.message}); id #{@player_id} is in memory only"
      false
    end

    class << self
      private

      def parse(raw)
        return nil if raw.nil?
        JSON.parse(raw)
      rescue JSON::ParserError
        :unparseable
      end

      def describe(raw, values)
        return "empty file" if raw.strip.empty?
        return "invalid JSON" if values == :unparseable
        return "not an object" unless values.is_a?(Hash)
        "player_id #{values['player_id'].inspect} is not a uuid v4"
      end
    end
  end
end
