require "digest"
require "json"
require "game/character"

module Game
  # v18 persistence (spec decisions 1/3/4/5/6a) + v19 schema 2 (Lane 1
  # T1, spec P3/P8) + v22 SCHEMA 3 (T1: per-PLAYER character records):
  # the save vocabulary is FACTS, not a snapshot —
  #   party-shared: banked, provisions, breached, counters (council C8)
  #   per character (keyed by PLAYER id, never seat — L20-1/3):
  #     level, xp, xp_debt, insurance, home_zone, form,
  #     forms{kit -> hp/inscribed}, bag, equipment, attributes, bank_items
  #   migration (optional; absent in fresh worlds): the ONE 2->3 hop's
  #     record {from_schema, legacy_level, legacy_seed_claimed_by}.
  # Everything else dies at the session boundary by OMISSION (the
  # projector's transient zero-list is the classification table in
  # save_state_test.rb, test-enforced).
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
  #     living form holds after projection (asserted — a violation is a
  #     surfaced BUG, never a save). Characters project through the Party
  #     (the T1 interim live/mirror rule lives there, not here).
  #   - STRICT DECODER refusal_for: named refusals (schema/keys/character/
  #     zone/seal-tuple/type/range/duplicate/no-living), never a crash,
  #     every text naming the offending key/path.
  #   - apply! in the PINNED order (decision 4 + v19 P3, T1-shaped): host
  #     character's home -> counters + progression (clamped for churn at
  #     Party build) -> sync leveled max hp -> forms onto the roster (hp
  #     clamps against the REAL leveled ceiling) -> banked/provisions ->
  #     seat 1 resumes its saved FORM (the pointer law's "keeps a still-
  #     living body", now the persisted one; everything else claims in
  #     roster order as before) -> restore_breach! (idempotent) -> World
  #     runs enter_zone(home_zone) after apply! returns.
  #   - digest = md5 over canonical FACTS bytes; the envelope (schema,
  #     saved_at_ms) is NEVER digested (decision 5).
  # Schema history: 1 = v18 — REFUSED NAMED since schema 3 (L9: no live v1
  # chain exists; the v1 lane and its frozen key set are gone). 2 = v19
  # (shared progression + members roster) — still LOADABLE via the one-hop
  # migration lane: v2 files validate under the FROZEN v2 rules, the host
  # character derives from progression + members + home_zone, keyed by the
  # loading machine's player id, and the ORIGINAL bytes back up beside the
  # save before the first v3 write (SaveStore). Anything else refuses NAMED.
  module SaveState
    SCHEMA = 3

    class EncodeError < StandardError; end
    # The projector found a state no legal save can represent (e.g. zero
    # living members outside a resolvable judgment) — surface it, never
    # write it.
    class ProjectionBug < StandardError; end

    module_function

    # --- projector (decision 3) -----------------------------------------

    def facts(world)
      f = {
        "banked" => world.pack.banked,
        "provisions" => world.pack.provisions,
        "breached" => world.breached_tuples,
        "counters" => {
          "boss_1_defeats" => world.boss_1_defeats,
          "sessions" => world.sessions
        },
        "characters" => world.party.project
      }
      # The one-vessel floor is asserted HERE, on the save path only: the
      # digest reads the same projector every window and must never raise.
      host_forms = f["characters"].fetch(world.party.host_id).fetch("forms")
      unless host_forms.values.any? { |form| form["hp"].positive? }
        raise ProjectionBug, "projector: no living form after judgment " \
                             "(one-vessel floor violated — this is a bug, not a save)"
      end
      (mig = world.party.project_migration) and f["migration"] = mig
      f
    end

    # The host character's `forms` fact: kit -> {hp, inscribed}. A quit
    # during the wipe veil serializes what the veil's END would produce,
    # through the same rules respawn_pack applies: marked flesh revives and
    # the mark burns; unmarked dissolves; a judgment that would leave
    # nothing keeps the wipe vessel (seat-1 pointer — on a full wipe
    # forced_swap! leaves it on the dead body by design). PURE: membership
    # is computed, never mutated; nothing here draws RNG (positions are not
    # facts); never raises — the digest calls it every window, and the
    # one-vessel floor is asserted by `facts` (the save path).
    def project_forms(world)
      if world.states.current == :nest_respawn
        vessel = world.controlled_bodies.first
        floor = world.pack.members.none?(&:marked?)
        world.pack.members.to_h do |m|
          lives = m.marked? || (floor && m.equal?(vessel))
          [m.kit_name.to_s, { "hp" => lives ? m.max_hp : 0, "inscribed" => false }]
        end
      else
        world.pack.members.to_h do |m|
          [m.kit_name.to_s, { "hp" => m.hp, "inscribed" => m.marked? }]
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

    # MUNDO VIVO FASE 6.1 — L9 migration law, RETIRED SEALS. When a zone's
    # geometry changes under a live save (the medusa -> DUNGEON 1 swap
    # retired dungeon_1's internal seal [17,2] -> [18,2]), the breach
    # tuple recorded by players who paid it no longer resolves and the
    # strict decoder would refuse the whole save. The migration is a
    # NAMED list, never a wildcard: only tuples on it are dropped (no
    # refund — the door served its era; spec §2), each drop reported as a
    # notice. Runs on the parsed envelope BEFORE validation; pure
    # (returns the dropped list, mutates facts["breached"] only).
    RETIRED_SEALS = [["dungeon_1", [18, 2]]].freeze

    def migrate_retired_seals!(env)
      facts = env.is_a?(Hash) ? env["facts"] : nil
      return [] unless facts.is_a?(Hash) && facts["breached"].is_a?(Array)
      dropped = facts["breached"].select { |e| RETIRED_SEALS.include?(e) }
      facts["breached"] = facts["breached"] - dropped unless dropped.empty?
      dropped
    end

    def envelope_refusal(env, data:)
      return "save envelope: not an object" unless env.is_a?(Hash)
      schema = env["schema"]
      unless schema == SCHEMA || schema == 2
        return "save schema: #{schema.inspect} unsupported (expected #{SCHEMA})"
      end
      at = env["saved_at_ms"]
      return "save saved_at_ms: must be a non-negative Integer" unless non_neg_int?(at)
      return v2_refusal_for(env["facts"], data:) if schema == 2
      refusal_for(env["facts"], data:)
    end

    # --- schema 3 --------------------------------------------------------

    FACT_KEYS = %w[banked breached characters counters provisions].freeze
    OPTIONAL_FACT_KEYS = %w[migration].freeze
    COUNTER_KEYS = %w[boss_1_defeats sessions].freeze

    def refusal_for(facts, data:)
      return "save facts: not an object" unless facts.is_a?(Hash)
      return "save keys: must be Strings" unless facts.keys.all? { |k| k.is_a?(String) }
      missing = FACT_KEYS - facts.keys
      extra = facts.keys - FACT_KEYS - OPTIONAL_FACT_KEYS
      unless missing.empty? && extra.empty?
        parts = []
        parts << "missing #{missing.join(',')}" unless missing.empty?
        parts << "unknown #{extra.sort.join(',')}" unless extra.empty?
        return "save keys: #{parts.join('; ')} (expected #{FACT_KEYS.join(',')}[,migration])"
      end
      (r = shared_refusal(facts, data:)) and return r
      (r = characters_refusal(facts["characters"], data:)) and return r
      facts.key?("migration") ? Party.migration_refusal(facts["migration"]) : nil
    end

    # The party-shared body (council C8) — identical under schemas 2 and 3.
    def shared_refusal(facts, data:)
      return "save banked: must be a non-negative Integer" unless non_neg_int?(facts["banked"])
      return "save provisions: must be a non-negative Integer" unless non_neg_int?(facts["provisions"])
      (r = breached_refusal(facts["breached"], data)) and return r
      counters_refusal(facts["counters"])
    end

    def characters_refusal(chars, data:)
      return "save characters: not an object keyed by player id" unless chars.is_a?(Hash)
      return "save characters: at least one character required (the host's record)" if chars.empty?
      roster = roster_for(data)
      cap = insurance_cap_for(data)
      hub = hub_lookup(data)
      chars.each do |id, rec|
        (r = Character.refusal(id, rec, roster:, hub:, insurance_cap: cap)) and return r
      end
      nil
    end

    def roster_for(data) = data["balance/combat"].fetch(:pack).fetch(:members).map(&:to_s)
    # The insurance bound is DATA (death.json insurance.max_stacks — T5
    # owns its tuning); a missing key is a boot error, never a code default.
    def insurance_cap_for(data) = data["balance/death"].fetch(:insurance).fetch(:max_stacks)
    # zone name -> true (hub) | false (known, not a hub) | nil (unknown).
    def hub_lookup(data)
      ->(name) { (z = zone_data(data, name)) && (z[:hub] ? true : false) }
    end

    # --- schema 2, FROZEN (the one-hop migration lane's input rules) -----

    V2_FACT_KEYS = %w[banked breached counters home_zone members progression provisions].freeze
    V2_MEMBER_KEYS = %w[hp inscribed kit].freeze
    V2_PROGRESSION_KEYS = %w[level xp].freeze

    # v2 files validate under EXACTLY the rules they were written under,
    # then take the one-hop migration (migrate_v2). Frozen: a v2 file that
    # was legal on 2026-09-05 stays loadable forever.
    def v2_refusal_for(facts, data:)
      return "save facts: not an object" unless facts.is_a?(Hash)
      unless facts.keys.all? { |k| k.is_a?(String) } && facts.keys.sort == V2_FACT_KEYS
        return "save keys: expected #{V2_FACT_KEYS.join(',')}, got #{facts.keys.map(&:to_s).sort.join(',')}"
      end
      (r = shared_refusal(facts, data:)) and return r
      (r = Character.home_refusal(facts["home_zone"], hub: hub_lookup(data), where: "save home_zone")) and return r
      (r = v2_members_refusal(facts["members"], data)) and return r
      v2_progression_refusal(facts["progression"])
    end

    def v2_members_refusal(members, data)
      roster = roster_for(data)
      return "save members: must be an array" unless members.is_a?(Array)
      unless members.length == roster.length
        return "save roster: #{members.length} members, build roster has #{roster.length}"
      end
      members.each_with_index do |m, i|
        return "save members[#{i}]: not an object" unless m.is_a?(Hash)
        unless m.keys.all? { |k| k.is_a?(String) } && m.keys.sort == V2_MEMBER_KEYS
          return "save members[#{i}]: keys must be exactly #{V2_MEMBER_KEYS.join(',')}"
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

    def v2_progression_refusal(prog)
      return "save progression: not an object" unless prog.is_a?(Hash)
      unless prog.keys.all? { |k| k.is_a?(String) } && prog.keys.sort == V2_PROGRESSION_KEYS
        return "save progression: keys must be exactly #{V2_PROGRESSION_KEYS.join(',')}"
      end
      level = prog["level"]
      unless level.is_a?(Integer) && level >= 1
        return "save progression.level: must be an Integer >= 1"
      end
      return "save progression.xp: must be a non-negative Integer" unless non_neg_int?(prog["xp"])
      nil
    end

    # The ONE hop (L9), pure half: a v2-valid facts tree becomes schema 3.
    # The HOST character = progression (level/xp) + members (forms) +
    # home_zone, keyed by the LOADING machine's player id; xp_debt 0,
    # insurance 0, Junior's keys at their defaults. `form` = the body seat 1
    # would claim under the v2 pointer law (the initial possessed kit when
    # it lives, else the first living member in roster order) — so a
    # migrated save resumes in exactly the body it resumed in yesterday.
    # The migration block records the legacy level for the D-T1 seed
    # (claimed by nobody yet). The IO half (backing the original bytes up
    # before the first v3 write) is the SaveStore's business.
    def migrate_v2(facts, player_id:, data:)
      unless Character.player_id?(player_id)
        raise ArgumentError, "migrate_v2: #{player_id.inspect} is not a player id"
      end
      prog = facts.fetch("progression")
      members = facts.fetch("members")
      initial = data["balance/combat"].fetch(:pack).fetch(:initial_possessed).to_s
      living = members.select { |m| m.fetch("hp").positive? }
      form = (living.find { |m| m.fetch("kit") == initial } || living.first).fetch("kit")
      host = {
        "level" => prog.fetch("level"), "xp" => prog.fetch("xp"),
        "xp_debt" => 0, "insurance" => 0,
        "home_zone" => facts.fetch("home_zone"), "form" => form,
        "forms" => members.to_h do |m|
          [m.fetch("kit"), { "hp" => m.fetch("hp"), "inscribed" => m.fetch("inscribed") }]
        end
      }.merge(Marshal.load(Marshal.dump(Character::OPTIONAL_DEFAULTS)))
      {
        "banked" => facts.fetch("banked"),
        "provisions" => facts.fetch("provisions"),
        "breached" => facts.fetch("breached").map { |(z, (x, y))| [z.dup, [x, y]] },
        "counters" => facts.fetch("counters").dup,
        "characters" => { player_id => host },
        "migration" => { "from_schema" => 2, "legacy_level" => prog.fetch("level"),
                         "legacy_seed_claimed_by" => Party::UNCLAIMED }
      }
    end

    # --- shared validators ------------------------------------------------

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

    # --- the Party (v22 T1) — built on BOTH construction paths -----------
    # `players` = seat -> player id (L20-1; harness default = Party
    # .default_players). Records come from validated facts (clamped for
    # churn here, P3's law: a curve/cap retune must never brick a save —
    # level clamps to the cap, xp under the NEXT level's cost, both read
    # through the live Progression, never reimplemented); seated players
    # without a record are created under the D-T1 seed rule (Party). A new
    # character's home is the world's initial hub, its form the fresh
    # pack's possessed kit — the same start a fresh world gives seat 1.
    def build_party(world, facts, players:)
      players_refusal!(players, world.seats)
      prog = world.progression
      roster = world.pack.members.map { |m| m.kit_name.to_s }
      base = world.pack.members.to_h { |m| [m.kit_name.to_s, m.kit[:max_hp]] }
      records = {}
      (facts ? facts.fetch("characters") : {}).each do |id, rec|
        records[id] = clamp_record!(Character.from_h(id, rec), prog)
      end
      live = { level: -> { prog.level }, xp: -> { prog.xp },
               form: -> { world.possessed(1)&.kit_name&.to_s },
               home_zone: -> { world.home_zone }, forms: -> { project_forms(world) } }
      Party.new(players:, records:, migration: facts && facts["migration"]&.dup, live:)
           .create_missing!(new_level: prog.new_character_level, home_zone: world.home_zone,
                            form: world.possessed(1).kit_name.to_s, roster:,
                            max_hp: ->(level, kit) { prog.max_hp_at(level, base.fetch(kit)) },
                            clamp: ->(level) { clamp_level(level, prog, "new character") })
    end

    def players_refusal!(players, seats)
      ok = players.is_a?(Hash) && players.keys.sort == seats.sort &&
           players.values.all? { |id| Character.player_id?(id) } &&
           players.values.uniq.length == players.length
      return if ok
      raise ArgumentError,
            "players must map every seat #{seats.inspect} to a distinct player id " \
            "(uuid v4 or bot-<seed>), got #{players.inspect}"
    end

    def clamp_level(level, prog, who)
      cap = prog.level_cap
      return level unless level > cap
      warn "save: clamped level #{level} -> #{cap} (level cap changed) [#{who}]"
      cap
    end

    def clamp_record!(c, prog)
      c.level = clamp_level(c.level, prog, c.id)
      ceiling = prog.delta_e(c.level + 1)
      if c.xp >= ceiling
        warn "save: clamped xp #{c.xp} -> #{ceiling - 1} (curve changed) [#{c.id}]"
        c.xp = ceiling - 1
      end
      c
    end

    # --- apply (decision 4, pinned order) --------------------------------
    # Invoked by World construction, AFTER build_party. Facts are validated
    # UPSTREAM (both load paths run the strict decoder before any window
    # opens); apply! fetches strictly so a skipped validation still fails
    # loudly. The HOST character (seat 1) drives today's shared pack; a
    # seated guest's record exists but drives nothing until T2b (the T1
    # interim rule, Character/Party header).
    def apply!(world, facts, economy:)
      host = world.party.host
      world.load_home!(host.home_zone)

      counters = facts.fetch("counters")
      world.progression.load_counters!(
        boss_1_defeats: counters.fetch("boss_1_defeats"),
        sessions: counters.fetch("sessions")
      )
      # Level/xp were clamped at Party build (P3's churn law, one place).
      world.progression.load_progress!(level: host.level, xp: host.xp)
      # The form hp facts below must clamp against the leveled ceiling,
      # never the fresh level-1 kit max (P3 save-apply ordering law).
      world.pack.sync_max_hp!(progression: world.progression)

      world.pack.members.each do |m|
        f = host.forms.fetch(m.kit_name.to_s)
        hp = f.fetch("hp")
        if hp > m.max_hp
          warn "save: clamped #{m.kit_name} hp #{hp} -> #{m.max_hp} (kit max changed)"
          hp = m.max_hp
        end
        m.load_hp!(hp)
        f.fetch("inscribed") ? m.inscribe_mark! : m.burn_mark!
      end
      world.pack.bank!(facts.fetch("banked"))
      provisions = facts.fetch("provisions")
      cap = economy[:provision_cap]
      if provisions > cap
        warn "save: clamped provisions #{provisions} -> #{cap} (cap changed)"
        provisions = cap
      end
      world.pack.load_provisions!(provisions)

      # Seat pointers (the judgment floor rule, T1-shaped): seat 1 resumes
      # the saved FORM when that body lives (releasing any seat that
      # construction handed it); then every seat keeps a still-living body
      # or claims the first living unheld body in roster order; none left =
      # waiting. Round-trip law: facts(apply(facts)) == facts.
      body = world.pack.members.find { |m| m.kit_name.to_s == host.form }
      if body && !body.dead?
        world.seats.each { |s| world.pack.possess!(nil, seat: s) if world.pack.possessed(s)&.equal?(body) }
        world.pack.possess!(body, seat: 1)
      end
      world.seats.each do |seat|
        current = world.pack.possessed(seat)
        next if current && !current.dead?
        target = world.pack.members.find { |m| !m.dead? && !world.controlled?(m) }
        world.pack.possess!(target, seat:)
      end

      facts.fetch("breached").each do |(zone, tile)|
        world.restore_breach!(zone, [tile[0], tile[1]])
      end
    end
  end
end
