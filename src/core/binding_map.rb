module Core
  # Rebindable controls (v15): action -> ordered key-name arrays from
  # data/bindings.json, with an optional per-machine override file
  # data/bindings.local.json (gitignored; DataStore auto-loads it when
  # present) merged per action — whole-array replace, never element merge.
  #
  # Engine-agnostic BY LAW (spec panel fold): src/core has zero Gosu
  # references, so the platform key table (name -> key code) is INJECTED
  # by the caller — App::KEY_TABLE in live play, a fake integer table in
  # tests. All validation is load-time and fail-loud: a config typo must
  # never surface mid-session as a silently dead key.
  class BindingMap
    class BadBinding < StandardError; end

    # data: anything answering [](key) and keys (Core::DataStore contract).
    # local: false pins the canonical map — the HARNESS setting (gate
    # comparability law: a machine-local override must never change what
    # a capture renders; the locale=en pin precedent).
    def self.load(data, key_table:, local: true)
      merged = data["bindings"].to_h { |action, keys| [action, Array(keys)] }
      if local && data.keys.include?("bindings.local")
        data["bindings.local"].each do |action, keys|
          unless merged.key?(action)
            raise BadBinding, "bindings.local.json: unknown action #{action.inspect} " \
                              "(valid: #{merged.keys.sort.join(', ')})"
          end
          merged[action] = Array(keys)
        end
      end
      new(merged, key_table:)
    end

    attr_reader :codes

    def initialize(bindings, key_table:)
      @bindings = bindings
      @codes = {}
      owners = {}
      bindings.each do |action, names|
        raise BadBinding, "action #{action.inspect} has no keys" if names.empty?
        names.each do |name|
          unless key_table.key?(name)
            raise BadBinding, "unknown key name #{name.inspect} for #{action.inspect} " \
                              "(valid: #{key_table.keys.sort.join(' ')})"
          end
          if (other = owners[name]) && other != action
            # Junior's most likely mistake: rebinding onto a letter the
            # canonical map already uses (e.g. mark -> "W" while W = up)
            # would dual-fire both actions every frame. Fail loud instead.
            raise BadBinding, "key #{name.inspect} bound to both #{other.inspect} " \
                              "and #{action.inspect} — one key, one action"
          end
          owners[name] = action
        end
        @codes[action] = names.map { |n| key_table.fetch(n) }
      end
    end

    # Display names for the strip, binding order (primary first).
    def glyphs(action) = @bindings.fetch(action, [])

    def actions = @bindings.keys
  end
end
