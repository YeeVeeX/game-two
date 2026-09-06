module Game
  # v22 T1 — the CHARACTER record: the persistence unit (foundation L20-3),
  # keyed by PLAYER identity, never seat (L20-1, Rule 1c). Plain object +
  # strict validator; no World coupling — World reads records through the
  # Party below (the narrow reader L20-4 asks for; T2a grows it into the
  # seat -> body owner).
  #
  # Record shape (schema 3 `characters[<player id>]`):
  #   level, xp, xp_debt, insurance, home_zone, form,
  #   forms: { <kit>: { hp, inscribed } },
  #   bag [], equipment {}, attributes {}, bank_items []   <- OPTIONAL keys,
  #     documented EMPTY defaults (absent = default); Junior's S2 merge fills
  #     them in one line. The projector always WRITES every key (a file on
  #     disk is self-describing); the validator accepts absent = default
  #     (the optional-key law, spec T1).
  # Integer-only everywhere (the digest leaf-type law): a Float anywhere in
  # a record is a NAMED refusal, never an EncodeError at write time.
  #
  # T1 INTERIM RULE (council s133 Q5/Q6 — named, not undefined): T1 ships
  # before T2b, so the field still runs ONE shared pack + ONE shared
  # Progression. The HOST character (seat 1) is that progression: its
  # level/xp/form/home_zone/forms are read LIVE from the world. A SEATED
  # GUEST's level/xp are READ-ONLY MIRRORS of the host's — live reads and
  # the clean-quit projection both report the party level (in this field
  # every seated character IS the party level; nothing else writes a
  # guest's growth until T2b). A guest's other keys are frozen at their
  # stored values. UNSEATED records (players not in this session) round-trip
  # verbatim. T2b retires the mirror when characters own their bodies.
  class Character
    UUID_V4 = /\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/
    # Bots and harness seats: "bot-<seed>" (seat 1) / "bot-<seed>-<seat>";
    # disjoint from a uuid by construction, ASCII, sorts deterministically.
    BOT_ID = /\Abot-[0-9a-z][0-9a-z-]{0,62}\z/
    PLAYER_ID = Regexp.union(UUID_V4, BOT_ID)

    REQUIRED_KEYS = %w[form forms home_zone insurance level xp xp_debt].freeze
    OPTIONAL_DEFAULTS = {
      "attributes" => {}.freeze, "bag" => [].freeze,
      "bank_items" => [].freeze, "equipment" => {}.freeze
    }.freeze
    KEYS = (REQUIRED_KEYS + OPTIONAL_DEFAULTS.keys).sort.freeze
    FORM_KEYS = %w[hp inscribed].freeze
    DIGEST_KEYS = %w[level xp xp_debt insurance form home_zone].freeze

    attr_reader :id, :forms, :bag, :equipment, :attributes, :bank_items
    attr_accessor :level, :xp, :xp_debt, :insurance, :home_zone, :form

    def self.player_id?(id) = id.is_a?(String) && PLAYER_ID.match?(id)

    # A brand-new character: `level` from the seed rule (Party), forms =
    # every roster kit at its leveled max (`max_hp.(kit) -> Integer`),
    # nothing inscribed, Junior's keys at their defaults.
    def self.create(id:, level:, home_zone:, form:, roster:, max_hp:)
      forms = roster.to_h { |kit| [kit.to_s, { "hp" => max_hp.call(kit), "inscribed" => false }] }
      new(id:, level:, xp: 0, xp_debt: 0, insurance: 0, home_zone:, form: form.to_s, forms:)
    end

    # From a VALIDATED record (Character.refusal ran upstream); optional
    # keys fill from OPTIONAL_DEFAULTS. Deep-copies so a save tree never
    # aliases live state.
    def self.from_h(id, rec)
      dup = ->(v) { Marshal.load(Marshal.dump(v)) }
      new(id:, level: rec.fetch("level"), xp: rec.fetch("xp"),
          xp_debt: rec.fetch("xp_debt"), insurance: rec.fetch("insurance"),
          home_zone: rec.fetch("home_zone"), form: rec.fetch("form"),
          forms: dup.call(rec.fetch("forms")),
          bag: dup.call(rec.fetch("bag", OPTIONAL_DEFAULTS["bag"])),
          equipment: dup.call(rec.fetch("equipment", OPTIONAL_DEFAULTS["equipment"])),
          attributes: dup.call(rec.fetch("attributes", OPTIONAL_DEFAULTS["attributes"])),
          bank_items: dup.call(rec.fetch("bank_items", OPTIONAL_DEFAULTS["bank_items"])))
    end

    def initialize(id:, level:, xp:, xp_debt:, insurance:, home_zone:, form:, forms:,
                   bag: [], equipment: {}, attributes: {}, bank_items: [])
      @id = id
      @level = level
      @xp = xp
      @xp_debt = xp_debt
      @insurance = insurance
      @home_zone = home_zone
      @form = form
      @forms = forms
      @bag = bag
      @equipment = equipment
      @attributes = attributes
      @bank_items = bank_items
    end

    # The persisted record — every key, stored values. `live` (a Hash of
    # key -> value) overrides for the seated characters (Party decides which
    # keys are live for whom; this object stays policy-free).
    def to_h(live = {})
      {
        "level" => live.fetch("level", @level), "xp" => live.fetch("xp", @xp),
        "xp_debt" => @xp_debt, "insurance" => @insurance,
        "home_zone" => live.fetch("home_zone", @home_zone),
        "form" => live.fetch("form", @form),
        "forms" => live.fetch("forms", @forms),
        "bag" => @bag, "equipment" => @equipment,
        "attributes" => @attributes, "bank_items" => @bank_items
      }
    end

    # The digest rows (spec T1): level, xp, xp_debt, insurance, form,
    # home_zone — forms ride the pack's own creature rows; Junior's keys
    # are session-inert in T1 and join the digest with the ticket that
    # reads them (S2).
    def digest_fields(live = {})
      h = to_h(live)
      DIGEST_KEYS.map { |k| [k, h.fetch(k)] }
    end

    # --- strict validator (named refusals, never a crash) -----------------

    # -> nil | refusal text naming the offending key/path. `roster` = the
    # build's kit names (Strings), `hubs` = zone name -> hub? lookup
    # (callable), `insurance_cap` = death.json insurance.max_stacks.
    def self.refusal(id, rec, roster:, hub:, insurance_cap:)
      where = "save characters[#{id}]"
      return "save characters: key #{id.inspect} is not a player id (uuid v4 or bot-<seed>)" unless player_id?(id)
      return "#{where}: not an object" unless rec.is_a?(Hash)
      return "#{where}: keys must be Strings" unless rec.keys.all? { |k| k.is_a?(String) }
      missing = REQUIRED_KEYS - rec.keys
      return "#{where}: missing key(s) #{missing.join(',')}" unless missing.empty?
      extra = rec.keys - KEYS
      return "#{where}: unknown key(s) #{extra.sort.join(',')} (schema 3 characters carry exactly #{KEYS.join(',')})" unless extra.empty?
      level = rec["level"]
      return "#{where}.level: must be an Integer >= 1" unless level.is_a?(Integer) && level >= 1
      %w[xp xp_debt].each do |k|
        return "#{where}.#{k}: must be a non-negative Integer" unless non_neg_int?(rec[k])
      end
      ins = rec["insurance"]
      unless ins.is_a?(Integer) && ins.between?(0, insurance_cap)
        return "#{where}.insurance: must be an Integer in 0..#{insurance_cap} (death.json insurance.max_stacks)"
      end
      (r = home_refusal(rec["home_zone"], hub:, where: "#{where}.home_zone")) and return r
      (r = forms_refusal(rec["forms"], roster:, where: "#{where}.forms")) and return r
      form = rec["form"]
      unless form.is_a?(String) && roster.include?(form)
        return "#{where}.form: #{form.inspect} is not a roster kit (#{roster.join(',')})"
      end
      %w[bag bank_items].each do |k|
        next unless rec.key?(k)
        return "#{where}.#{k}: must be an array" unless rec[k].is_a?(Array)
      end
      %w[equipment attributes].each do |k|
        next unless rec.key?(k)
        return "#{where}.#{k}: must be an object" unless rec[k].is_a?(Hash)
      end
      OPTIONAL_DEFAULTS.each_key do |k|
        next unless rec.key?(k)
        (r = canonical_refusal(rec[k], "#{where}.#{k}")) and return r
      end
      nil
    end

    # The hub law, shared with the migration lane: a home is a String
    # naming a hub zone (`hub.(name) -> true | false | nil` for unknown).
    def self.home_refusal(home, hub:, where:)
      return "#{where}: must be a String" unless home.is_a?(String)
      known = hub.call(home)
      return "#{where}: unknown zone #{home.inspect}" if known.nil?
      return "#{where}: #{home.inspect} is not a hub (no hub-capable start there)" unless known
      nil
    end

    def self.forms_refusal(forms, roster:, where:)
      return "#{where}: must be an object keyed by kit" unless forms.is_a?(Hash)
      unless forms.keys.all? { |k| k.is_a?(String) } && forms.keys.sort == roster.sort
        return "#{where}: kits must be exactly #{roster.sort.join(',')}, got #{forms.keys.map(&:to_s).sort.join(',')}"
      end
      forms.each do |kit, f|
        return "#{where}.#{kit}: not an object" unless f.is_a?(Hash)
        unless f.keys.all? { |k| k.is_a?(String) } && f.keys.sort == FORM_KEYS
          return "#{where}.#{kit}: keys must be exactly #{FORM_KEYS.join(',')}"
        end
        return "#{where}.#{kit}.hp: must be a non-negative Integer" unless non_neg_int?(f["hp"])
        unless [true, false].include?(f["inscribed"])
          return "#{where}.#{kit}.inscribed: must be true or false"
        end
      end
      return "#{where}: no living form (at least one hp > 0 required)" unless forms.values.any? { |f| f["hp"].positive? }
      nil
    end

    # The digest leaf-type law applied at DECODE time: every leaf inside an
    # optional container is Integer / ASCII String / Boolean with String
    # keys — so a foreign value refuses NAMED here instead of raising
    # EncodeError at the first clean quit.
    def self.canonical_refusal(node, path)
      case node
      when Hash
        node.each do |k, v|
          return "#{path}: non-String key #{k.inspect}" unless k.is_a?(String)
          (r = canonical_refusal(v, "#{path}.#{k}")) and return r
        end
        nil
      when Array
        node.each_with_index { |v, i| (r = canonical_refusal(v, "#{path}[#{i}]")) and return r }
        nil
      when Integer, true, false then nil
      when String
        node.ascii_only? ? nil : "#{path}: non-ASCII string #{node.inspect}"
      else
        "#{path}: non-canonical leaf #{node.class} #{node.inspect} (Integer/String/Boolean only)"
      end
    end

    def self.non_neg_int?(v) = v.is_a?(Integer) && v >= 0
  end

  # The seat -> character map + every record the save carries (seated or
  # not) + the optional migration block. Built by SaveState.build_party on
  # BOTH construction paths (fresh and loaded); World digests and projects
  # through it. Policy lives HERE: which keys are live for whom (the T1
  # interim rule above), the legacy-seed rule (D-T1), record clamps.
  class Party
    MIGRATION_KEYS = %w[from_schema legacy_level legacy_seed_claimed_by].freeze

    attr_reader :players, :records, :migration

    # Harness/bot default: seat s = "bot-<s>" — a CONSTANT per seat, never
    # seed-derived, because facts are seed-independent by law (v18 decision
    # 16: "field re-seeds, facts persist") and a seed-keyed host id would
    # make a save projected at seed 11 unloadable at seed 999. A real
    # `--bot <seed>` process names itself bot-<seed> (App::PlayerFile).
    def self.default_players(seats)
      seats.to_h { |s| [s, "bot-#{s}"] }
    end

    # `live`: key -> callable for the HOST's live facts (level xp form
    # home_zone forms); a nil form (seat 1 waiting for a body) falls back
    # to the stored value.
    def initialize(players:, records:, migration:, live:)
      @players = players
      @records = records
      @migration = migration
      @live = live
    end

    def host_id = @players.fetch(1)
    def host = @records.fetch(host_id)
    def id_for(seat) = @players.fetch(seat)
    def character(seat) = @records.fetch(id_for(seat))
    def seated?(id) = @players.value?(id)
    def ids = @records.keys.sort

    # D-T1 (dev-of-record rec, recorded s136): a seated player with NO
    # record is created here. While `migration.legacy_seed_claimed_by` is
    # UNCLAIMED (false — the spec wrote null, but null is outside the pinned
    # canonical vocabulary, save_state_test §1) the newcomer inherits
    # `legacy_level` (the v2 world level was earned by BOTH seats —
    # NINETEENTH evidence) and the block records THAT player's id; every
    # later newcomer starts at `new_level` (progression.json
    # new_character.level). Seat order decides who claims when two
    # newcomers arrive together (seat-order law).
    UNCLAIMED = false

    def create_missing!(new_level:, home_zone:, form:, roster:, max_hp:, clamp:)
      @players.keys.sort.each do |seat|
        id = @players.fetch(seat)
        next if @records.key?(id)
        level = new_level
        if @migration && @migration["legacy_seed_claimed_by"] == UNCLAIMED
          level = @migration["legacy_level"]
          @migration["legacy_seed_claimed_by"] = id
        end
        level = clamp.call(level)
        @records[id] = Character.create(id:, level:, home_zone:, form:, roster:,
                                        max_hp: ->(kit) { max_hp.call(level, kit) })
      end
      self
    end

    # Live overrides per record (the T1 interim rule): host = every live
    # key; seated guest = level/xp mirror; unseated = none.
    def live_for(id)
      return {} unless seated?(id)
      mirror = { "level" => @live.fetch(:level).call, "xp" => @live.fetch(:xp).call }
      return mirror unless id == host_id
      mirror.merge("home_zone" => @live.fetch(:home_zone).call,
                   "form" => @live.fetch(:form).call || host.form,
                   "forms" => @live.fetch(:forms).call)
    end

    # The `characters` fact (sorted ids — the canonicalizer sorts anyway;
    # sorted here so a reader sees the same order the digest uses).
    def project
      ids.to_h { |id| [id, @records.fetch(id).to_h(live_for(id))] }
    end

    def project_migration = @migration && MIGRATION_KEYS.to_h { |k| [k, @migration.fetch(k)] }

    # World#digest_snapshot groups: one per record, sorted player-id order
    # (uuid v4 for humans, bot-<seed> for bots — disjoint formats, so the
    # order is total and identical on both seats).
    def digest_groups
      ids.map { |id| ["character.#{id}", @records.fetch(id).digest_fields(live_for(id))] }
    end

    def self.migration_refusal(block)
      return "save migration: not an object" unless block.is_a?(Hash)
      unless block.keys.all? { |k| k.is_a?(String) } && block.keys.sort == MIGRATION_KEYS
        return "save migration: keys must be exactly #{MIGRATION_KEYS.join(',')}"
      end
      return "save migration.from_schema: must be 2 (the only hop schema 3 knows)" unless block["from_schema"] == 2
      lvl = block["legacy_level"]
      return "save migration.legacy_level: must be an Integer >= 1" unless lvl.is_a?(Integer) && lvl >= 1
      by = block["legacy_seed_claimed_by"]
      unless by == UNCLAIMED || Character.player_id?(by)
        return "save migration.legacy_seed_claimed_by: must be false (unclaimed) or a player id, got #{by.inspect}"
      end
      nil
    end
  end
end
