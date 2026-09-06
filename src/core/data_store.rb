require "json"
require "pathname"

# Loads every JSON file under data/ at startup, keyed by relative path:
# data/balance/combat.json -> store["balance/combat"].
#
# ALL tunable game values live in JSON. Zero balance constants in Ruby code.
module Core
  class DataStore
    class MissingKey < StandardError; end

    # J6-B D9: data/prefs.local.json is MACHINE-written (App::Prefs owns it
    # and reads the file directly with its own lenient-NAMED decode — a
    # crash-corrupt prefs file must never brick boot). Every other data file
    # is hand-edited and keeps the loud parse-abort (bindings.local's law: a
    # typo needs an abort that reaches the person who typed it). Exempting
    # by exact key HERE covers every construction site (window, main, map,
    # harness scenes, soak) — a caller opt-in would re-brick whichever
    # surface forgot it. TWIN LAW: Net::Fingerprint::EXCLUDED must also
    # carry every machine-written file (a gitignored per-machine file in
    # the handshake hash = permanent coop refusal — s55 review finding).
    # v22 T1: player.local is the second member — App::PlayerFile owns it
    # (the machine's player id; lenient-NAMED reader, never a brick).
    MACHINE_WRITTEN = ["prefs.local", "player.local"].freeze

    def initialize(root)
      @root = Pathname(root)
      raise ArgumentError, "data dir not found: #{@root}" unless @root.directory?
      @data = {}
      @root.glob("**/*.json").each do |file|
        key = file.relative_path_from(@root).sub_ext("").to_s.tr("\\", "/")
        next if MACHINE_WRITTEN.include?(key)
        @data[key] = JSON.parse(file.read, symbolize_names: true)
      end
    end

    def [](key)
      @data.fetch(key) { raise MissingKey, "no data loaded for #{key.inspect} (have: #{@data.keys.sort.inspect})" }
    end

    def keys = @data.keys.sort

    # Where the JSON tree lives — presentation loaders (art atlases) resolve
    # non-JSON siblings (PNG) against it. Read-only; never a sim input.
    def root = @root
  end
end
