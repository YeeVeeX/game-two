require "digest"
require "json"

module Game
  # v18 persistence v1 (spec decisions 1/3/4/5/6a): the save vocabulary is
  # FACTS, not a snapshot — {banked, provisions, home_zone, breached,
  # members(kit/hp/inscribed), counters}. Everything else dies at the
  # session boundary by OMISSION (the projector's transient zero-list is
  # the classification table in save_state_test.rb, test-enforced).
  #
  # Laws carried here:
  #   - PINNED CANONICALIZER (ours, not JSON.generate — Ruby doesn't sort):
  #     recursive key sort, pinned separators, String keys only, leaves
  #     Integer/String(ASCII)/Boolean — anything else RAISES (the digest
  #     leaf-type law applied to saves; floats are unrepresentable).
  #   - facts(world) is a PURE projector: pending judgment resolves through
  #     the live rules (inscription consumption, dissolution, one-vessel
  #     floor) WITHOUT mutating the world or touching an RNG stream;
  #     carried does NOT fold anywhere (F1 — bank it or lose it); >=1
  #     living member holds after projection (asserted — a violation is a
  #     surfaced BUG, never a save).
  #   - STRICT DECODER refusal_for: named refusals (schema/keys/roster/
  #     zone/seal-tuple/type/range/duplicate/no-living), never a crash.
  #   - apply! in the PINNED order (decision 4): home_zone -> member facts
  #     (kit-matched, roster order; hp CLAMPS to the kit's current max,
  #     provisions clamp to cap — balance churn must not brick saves) ->
  #     seat pointers over the LIVING set (seat order; keep a living body,
  #     else first living unheld in roster order, else waiting) ->
  #     restore_breach! (idempotent, side-effect-free) -> World runs
  #     enter_zone(home_zone) after apply! returns.
  #   - digest = md5 over canonical FACTS bytes; the envelope (schema,
  #     saved_at_ms) is NEVER digested (decision 5).
  module SaveState
    SCHEMA = 1

    class EncodeError < StandardError; end
    # The projector found a state no legal save can represent (e.g. zero
    # living members outside a resolvable judgment) — surface it, never
    # write it.
    class ProjectionBug < StandardError; end

    module_function

    # --- projector (decision 3) -----------------------------------------

    def facts(world)
      members = project_members(world)
      unless members.any? { |m| m["hp"].positive? }
        raise ProjectionBug, "projector: no living member after judgment " \
                             "(one-vessel floor violated — this is a bug, not a save)"
      end
      {
        "banked" => world.pack.banked,
        "provisions" => world.pack.provisions,
        "home_zone" => world.home_zone.dup,
        "breached" => world.breached_tuples,
        "members" => members,
        "counters" => {
          "boss_1_defeats" => world.boss_1_defeats,
          "sessions" => world.sessions
        }
      }
    end

    # A quit during the wipe veil serializes what the veil's END would
    # produce, through the same rules respawn_pack applies: marked flesh
    # revives and the mark burns; unmarked dissolves; a judgment that
    # would leave nothing keeps the wipe vessel (seat-1 pointer — on a
    # full wipe forced_swap! leaves it on the dead body by design). PURE:
    # membership is computed, never mutated; nothing here draws RNG
    # (positions are not facts).
    def project_members(world)
      if world.states.current == :nest_respawn
        vessel = world.controlled_bodies.first
        floor = world.pack.members.none?(&:marked?)
        world.pack.members.map do |m|
          lives = m.marked? || (floor && m.equal?(vessel))
          { "kit" => m.kit_name.to_s, "hp" => lives ? m.max_hp : 0,
            "inscribed" => false }
        end
      else
        world.pack.members.map do |m|
          { "kit" => m.kit_name.to_s, "hp" => m.hp, "inscribed" => m.marked? }
        end
      end
    end

    # --- pinned canonicalizer (decisions 1/5) ---------------------------

    def canonical_bytes(node)
      case node
      when Hash
        inner = node.keys.map do |k|
          raise EncodeError, "non-String key #{k.inspect} (string keys only)" unless k.is_a?(String)
          k
        end.sort.map { |k| "#{encode_string(k)}:#{canonical_bytes(node[k])}" }
        "{#{inner.join(',')}}"
      when Array
        "[#{node.map { |v| canonical_bytes(v) }.join(',')}]"
      when Integer
        node.to_s
      when true, false
        node.to_s
      when String
        encode_string(node)
      else
        raise EncodeError,
              "non-canonical leaf #{node.class}: #{node.inspect} " \
              "(Integer/String/Boolean only — the digest leaf-type law)"
      end
    end

    def encode_string(str)
      raise EncodeError, "non-ASCII string #{str.inspect}" unless str.ascii_only?
      str.to_json
    end

    def digest(facts) = Digest::MD5.hexdigest(canonical_bytes(facts))

    # Envelope metadata is NEVER digested (decision 1). saved_at_ms is a
    # wall clock for humans reading the file — the sim never reads it.
    def envelope(facts, saved_at_ms: (Time.now.to_f * 1000).to_i)
      { "schema" => SCHEMA, "saved_at_ms" => saved_at_ms, "facts" => facts }
    end

    # --- strict decoder (decision 6a): named refusals, never a crash ----

    def envelope_refusal(env, data:)
      return "save envelope: not an object" unless env.is_a?(Hash)
      schema = env["schema"]
      return "save schema: #{schema.inspect} unsupported (expected #{SCHEMA})" unless schema == SCHEMA
      at = env["saved_at_ms"]
      return "save saved_at_ms: must be a non-negative Integer" unless non_neg_int?(at)
      refusal_for(env["facts"], data:)
    end

    FACT_KEYS = %w[banked breached counters home_zone members provisions].freeze
    MEMBER_KEYS = %w[hp inscribed kit].freeze
    COUNTER_KEYS = %w[boss_1_defeats sessions].freeze

    def refusal_for(facts, data:)
      return "save facts: not an object" unless facts.is_a?(Hash)
      unless facts.keys.all? { |k| k.is_a?(String) } && facts.keys.sort == FACT_KEYS
        return "save keys: expected #{FACT_KEYS.join(',')}, got #{facts.keys.map(&:to_s).sort.join(',')}"
      end
      return "save banked: must be a non-negative Integer" unless non_neg_int?(facts["banked"])
      return "save provisions: must be a non-negative Integer" unless non_neg_int?(facts["provisions"])
      (r = home_refusal(facts["home_zone"], data)) and return r
      (r = breached_refusal(facts["breached"], data)) and return r
      (r = members_refusal(facts["members"], data)) and return r
      counters_refusal(facts["counters"])
    end

    def home_refusal(home, data)
      return "save home_zone: must be a String" unless home.is_a?(String)
      zone = zone_data(data, home)
      return "save home_zone: unknown zone #{home.inspect}" unless zone
      return "save home_zone: #{home.inspect} is not a hub (no hub-capable start there)" unless zone[:hub]
      nil
    end

    def breached_refusal(breached, data)
      return "save breached: must be an array of [zone, [x, y]] entries" unless breached.is_a?(Array)
      seen = {}
      breached.each do |entry|
        shape_ok = entry.is_a?(Array) && entry.length == 2 &&
                   entry[0].is_a?(String) && entry[1].is_a?(Array) &&
                   entry[1].length == 2 && entry[1].all? { |c| c.is_a?(Integer) }
        return "save breached: malformed entry #{entry.inspect} (expected [zone, [x, y]])" unless shape_ok
        zone_name, tile = entry
        zone = zone_data(data, zone_name)
        return "save breached: unknown zone #{zone_name.inspect}" unless zone
        opens = zone.fetch(:stations, []).select { |s| s[:type] == "seal" }.map { |s| s[:opens] }
        unless opens.include?(tile)
          return "save breached: #{tile.inspect} is not a seal in #{zone_name.inspect}"
        end
        key = [zone_name, tile]
        return "save breached: duplicate entry #{entry.inspect}" if seen[key]
        seen[key] = true
      end
      nil
    end

    def members_refusal(members, data)
      roster = data["balance/combat"][:pack][:members]
      return "save members: must be an array" unless members.is_a?(Array)
      unless members.length == roster.length
        return "save roster: #{members.length} members, build roster has #{roster.length}"
      end
      members.each_with_index do |m, i|
        return "save members[#{i}]: not an object" unless m.is_a?(Hash)
        unless m.keys.all? { |k| k.is_a?(String) } && m.keys.sort == MEMBER_KEYS
          return "save members[#{i}]: keys must be exactly #{MEMBER_KEYS.join(',')}"
        end
        unless m["kit"] == roster[i]
          return "save roster: members[#{i}].kit #{m['kit'].inspect} != #{roster[i].inspect} " \
                 "(kit set and order must match the build roster)"
        end
        return "save members[#{i}].hp: must be a non-negative Integer" unless non_neg_int?(m["hp"])
        unless [true, false].include?(m["inscribed"])
          return "save members[#{i}].inscribed: must be true or false"
        end
      end
      unless members.any? { |m| m["hp"].positive? }
        return "save roster: no living member (at least one hp > 0 required)"
      end
      nil
    end

    def counters_refusal(counters)
      return "save counters: not an object" unless counters.is_a?(Hash)
      unless counters.keys.all? { |k| k.is_a?(String) } && counters.keys.sort == COUNTER_KEYS
        return "save counters: keys must be exactly #{COUNTER_KEYS.join(',')}"
      end
      COUNTER_KEYS.each do |k|
        return "save counters.#{k}: must be a non-negative Integer" unless non_neg_int?(counters[k])
      end
      nil
    end

    def non_neg_int?(v) = v.is_a?(Integer) && v >= 0

    def zone_data(data, name)
      key = "zones/#{name}"
      data.keys.include?(key) ? data[key] : nil
    end

    # --- apply (decision 4, pinned order) --------------------------------
    # Invoked by World construction. Facts are validated UPSTREAM (both
    # load paths run the strict decoder before any window opens); apply!
    # fetches strictly so a skipped validation still fails loudly.
    def apply!(world, facts, economy:)
      world.load_home!(facts.fetch("home_zone"))

      roster = world.pack.members
      facts.fetch("members").each_with_index do |mf, i|
        m = roster[i]
        hp = mf.fetch("hp")
        if hp > m.max_hp
          warn "save: clamped #{m.kit_name} hp #{hp} -> #{m.max_hp} (kit max changed)"
          hp = m.max_hp
        end
        m.load_hp!(hp)
        mf.fetch("inscribed") ? m.inscribe_mark! : m.burn_mark!
      end
      world.pack.bank!(facts.fetch("banked"))
      provisions = facts.fetch("provisions")
      cap = economy[:provision_cap]
      if provisions > cap
        warn "save: clamped provisions #{provisions} -> #{cap} (cap changed)"
        provisions = cap
      end
      world.pack.load_provisions!(provisions)

      # Seat pointers over the LIVING set, seat order (the judgment floor
      # rule): a seat keeps a still-living body; otherwise it claims the
      # first living unheld body in roster order; none left = waiting.
      world.seats.each do |seat|
        current = world.pack.possessed(seat)
        next if current && !current.dead?
        target = world.pack.members.find { |m| !m.dead? && !world.controlled?(m) }
        world.pack.possess!(target, seat:)
      end

      facts.fetch("breached").each do |(zone, tile)|
        world.restore_breach!(zone, [tile[0], tile[1]])
      end

      counters = facts.fetch("counters")
      world.load_counters!(boss_1_defeats: counters.fetch("boss_1_defeats"),
                           sessions: counters.fetch("sessions"))
    end
  end
end
