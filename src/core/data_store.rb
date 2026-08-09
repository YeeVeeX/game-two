require "json"
require "pathname"

# Loads every JSON file under data/ at startup, keyed by relative path:
# data/balance/combat.json -> store["balance/combat"].
#
# ALL tunable game values live in JSON. Zero balance constants in Ruby code.
module Core
  class DataStore
    class MissingKey < StandardError; end

    def initialize(root)
      @root = Pathname(root)
      raise ArgumentError, "data dir not found: #{@root}" unless @root.directory?
      @data = {}
      @root.glob("**/*.json").each do |file|
        key = file.relative_path_from(@root).sub_ext("").to_s.tr("\\", "/")
        @data[key] = JSON.parse(file.read, symbolize_names: true)
      end
    end

    def [](key)
      @data.fetch(key) { raise MissingKey, "no data loaded for #{key.inspect} (have: #{@data.keys.sort.inspect})" }
    end

    def keys = @data.keys.sort
  end
end
