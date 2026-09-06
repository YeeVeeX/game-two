require_relative "../test_helper"
require "core/data_store"
require "game/character"
require "app/player_file"

# v22 T1 piece 2 — Game::Character + Game::Party as PLAIN objects: the
# player-id law (shared with App::PlayerFile by test, not by reference —
# the sim never requires the app layer), creation, deep-copied loading,
# the strict validator (every violation NAMED with its path), the T1
# interim live/mirror rule, the D-T1 legacy-seed rule, sorted digest rows.
class CharacterTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ROSTER = DATA["balance/combat"][:pack][:members].map(&:to_s).freeze
  KIT_MAX = DATA["balance/combat"][:kits].to_h { |k, v| [k.to_s, v[:max_hp]] }.freeze
  CAP = DATA["balance/death"][:insurance][:max_stacks]
  HUB = ->(name) { (z = DATA.keys.include?("zones/#{name}") ? DATA["zones/#{name}"] : nil) && z[:hub] ? true : (z ? false : nil) }
  UUID_A = "0f7e2c1a-4b3d-4c2e-9a1b-1234567890ab".freeze
  UUID_B = "9a1b2c3d-4e5f-4a6b-8c7d-0e1f2a3b4c5d".freeze

  C = Game::Character
  P = Game::Party

  def record(level: 3, xp: 10, home: "nest", form: "blocker", **over)
    {
      "level" => level, "xp" => xp, "xp_debt" => 0, "insurance" => 0,
      "home_zone" => home, "form" => form,
      "forms" => ROSTER.to_h { |k| [k, { "hp" => KIT_MAX[k], "inscribed" => false }] },
      "bag" => [], "equipment" => {}, "attributes" => {}, "bank_items" => []
    }.merge(over)
  end

  def refusal(id, rec) = C.refusal(id, rec, roster: ROSTER, hub: HUB, insurance_cap: CAP)

  # --- the player-id law ------------------------------------------------------

  def test_player_id_law_accepts_uuid_v4_and_bot_ids_and_nothing_else
    assert C.player_id?(UUID_A)
    assert C.player_id?("bot-7")
    assert C.player_id?("bot-7-2")
    refute C.player_id?("6ba7b810-9dad-11d1-80b4-00c04fd430c8"), "a v1 uuid is not v4"
    refute C.player_id?("BOT-7"), "upper case would break the sorted-order identity"
    refute C.player_id?("bot-"), "a bare prefix names nobody"
    refute C.player_id?("seat-1"), "seats are never identities (L20-1)"
    refute C.player_id?(7)
    refute C.player_id?(nil)
  end

  def test_the_app_layer_generates_ids_the_sim_accepts
    # Two laws, one contract: App::PlayerFile (uuid v4 / bot-<seed>) and
    # Game::Character::PLAYER_ID agree — pinned here because the sim may
    # never require the app layer.
    Dir.mktmpdir do |dir|
      file = App::PlayerFile.load(File.join(dir, "player.local.json"), out: StringIO.new)
      assert C.player_id?(file.player_id)
    end
    assert C.player_id?(App::PlayerFile.bot_id(12_345))
    assert C.player_id?(P.default_players([1, 2])[2])
  end

  # --- creation + loading -----------------------------------------------------

  def test_create_builds_every_form_at_the_given_max_and_default_optional_keys
    c = C.create(id: UUID_A, level: 5, home_zone: "camp", form: "lobber", roster: ROSTER,
                 max_hp: ->(kit) { KIT_MAX[kit] + 5 })
    h = c.to_h
    assert_equal C::KEYS, h.keys.sort
    assert_equal 5, h["level"]
    assert_equal 0, h["xp"]
    assert_equal 0, h["xp_debt"]
    assert_equal 0, h["insurance"]
    assert_equal "camp", h["home_zone"]
    assert_equal "lobber", h["form"]
    assert_equal ROSTER.sort, h["forms"].keys.sort
    ROSTER.each { |k| assert_equal({ "hp" => KIT_MAX[k] + 5, "inscribed" => false }, h["forms"][k]) }
    assert_equal [], h["bag"]
    assert_equal({}, h["equipment"])
    assert_equal({}, h["attributes"])
    assert_equal [], h["bank_items"]
    assert_nil refusal(UUID_A, h), "a created record passes its own validator"
  end

  def test_from_h_fills_absent_optional_keys_and_never_aliases_the_source
    rec = record
    %w[bag equipment attributes bank_items].each { |k| rec.delete(k) }
    assert_nil refusal(UUID_A, rec), "absent optional keys = their defaults"
    c = C.from_h(UUID_A, rec)
    assert_equal [], c.bag
    assert_equal({}, c.equipment)
    rec["forms"]["blocker"]["hp"] = 1
    assert_equal KIT_MAX["blocker"], c.forms["blocker"]["hp"], "forms are deep-copied"
    c.bag << "x"
    refute_equal rec.fetch("bag", []), c.bag, "the record's own containers"
  end

  def test_digest_fields_are_the_six_pinned_rows_in_order
    c = C.from_h(UUID_A, record(level: 4, xp: 9))
    assert_equal [["level", 4], ["xp", 9], ["xp_debt", 0], ["insurance", 0],
                  ["form", "blocker"], ["home_zone", "nest"]], c.digest_fields
    assert_equal C::DIGEST_KEYS, c.digest_fields.map(&:first)
  end

  def test_live_overrides_apply_only_to_named_keys
    c = C.from_h(UUID_A, record(level: 4, xp: 9))
    live = { "level" => 7, "xp" => 1, "form" => "striker", "home_zone" => "camp" }
    h = c.to_h(live)
    assert_equal [7, 1, "striker", "camp"], h.values_at("level", "xp", "form", "home_zone")
    assert_equal 4, c.level, "stored values are untouched by a live read"
    assert_equal ["level", 7], c.digest_fields(live).first
  end

  # --- the strict validator ---------------------------------------------------

  def test_valid_records_pass
    assert_nil refusal(UUID_A, record)
    assert_nil refusal("bot-3", record(home: "camp", form: "striker"))
    assert_nil refusal("bot-3-2", record(home: "zone_7"))
  end

  def test_every_violation_is_named_with_its_path
    dead_forms = ROSTER.to_h { |k| [k, { "hp" => 0, "inscribed" => false }] }
    cases = {
      "id not a player id" => ["seat-1", record, /key "seat-1" is not a player id/],
      "not an object" => [UUID_A, [1], /characters\[#{UUID_A}\]: not an object/],
      "symbol keys" => [UUID_A, record.transform_keys(&:to_sym), /keys must be Strings/],
      "missing required" => [UUID_A, record.tap { |r| r.delete("xp_debt") }, /missing key\(s\) xp_debt/],
      "unknown key" => [UUID_A, record("carried" => 4), /unknown key\(s\) carried/],
      "level zero" => [UUID_A, record(level: 0), /\.level: must be an Integer >= 1/],
      "level float" => [UUID_A, record(level: 2.0), /\.level/],
      "xp negative" => [UUID_A, record(xp: -1), /\.xp: must be a non-negative Integer/],
      "xp_debt type" => [UUID_A, record("xp_debt" => "0"), /\.xp_debt/],
      "insurance over cap" => [UUID_A, record("insurance" => CAP + 1), /\.insurance: must be an Integer in 0\.\.#{CAP} \(death\.json/],
      "insurance negative" => [UUID_A, record("insurance" => -1), /\.insurance/],
      "insurance float" => [UUID_A, record("insurance" => 1.0), /\.insurance/],
      "home type" => [UUID_A, record(home: 3), /\.home_zone: must be a String/],
      "home unknown" => [UUID_A, record(home: "atlantis"), /\.home_zone: unknown zone "atlantis"/],
      "home not hub" => [UUID_A, record(home: "district"), /\.home_zone: "district" is not a hub/],
      "forms not object" => [UUID_A, record("forms" => []), /\.forms: must be an object/],
      "forms kit set" => [UUID_A, record("forms" => record["forms"].reject { |k, _| k == "lobber" }), /\.forms: kits must be exactly/],
      "forms extra kit" => [UUID_A, record("forms" => record["forms"].merge("husk" => { "hp" => 1, "inscribed" => false })), /\.forms: kits must be exactly/],
      "form entry keys" => [UUID_A, record("forms" => record["forms"].merge("striker" => { "hp" => 1 })), /\.forms\.striker: keys must be exactly hp,inscribed/],
      "form hp type" => [UUID_A, record("forms" => record["forms"].merge("striker" => { "hp" => 1.5, "inscribed" => false })), /\.forms\.striker\.hp/],
      "form hp negative" => [UUID_A, record("forms" => record["forms"].merge("striker" => { "hp" => -1, "inscribed" => false })), /\.forms\.striker\.hp/],
      "form inscribed type" => [UUID_A, record("forms" => record["forms"].merge("striker" => { "hp" => 1, "inscribed" => 1 })), /\.forms\.striker\.inscribed/],
      "no living form" => [UUID_A, record("forms" => dead_forms), /\.forms: no living form/],
      "form not a kit" => [UUID_A, record(form: "husk"), /\.form: "husk" is not a roster kit/],
      "form names a dead body" => [UUID_A, record("forms" => record["forms"].merge("blocker" => { "hp" => 0, "inscribed" => false })), /\.form: "blocker" is dead in forms \(hp 0\)/],
      "form type" => [UUID_A, record(form: 2), /\.form: 2 is not a roster kit/],
      "bag not array" => [UUID_A, record("bag" => {}), /\.bag: must be an array/],
      "bank_items not array" => [UUID_A, record("bank_items" => "x"), /\.bank_items: must be an array/],
      "equipment not object" => [UUID_A, record("equipment" => []), /\.equipment: must be an object/],
      "attributes not object" => [UUID_A, record("attributes" => 1), /\.attributes: must be an object/],
      "bag float leaf" => [UUID_A, record("bag" => [{ "id" => "x", "qty" => 1.5 }]), /\.bag\[0\]\.qty: non-canonical leaf Float/],
      "equipment symbol key" => [UUID_A, record("equipment" => { main: "sword" }), /\.equipment: non-String key :main/],
      "attributes nil leaf" => [UUID_A, record("attributes" => { "str" => nil }), /\.attributes\.str: non-canonical leaf NilClass/],
      "bank_items non-ascii" => [UUID_A, record("bank_items" => ["caf\u00e9"]), /\.bank_items\[0\]: non-ASCII string/]
    }
    cases.each do |label, (id, rec, pattern)|
      r = refusal(id, rec)
      refute_nil r, "#{label}: expected a named refusal"
      assert_match pattern, r, "#{label}: the refusal must name the violation and its path"
    end
  end

  def test_canonical_containers_pass_with_nested_integers_strings_booleans
    rec = record("bag" => [{ "id" => "sword", "qty" => 2, "bound" => true }],
                 "equipment" => { "main" => "sword", "mods" => { "atk" => 3 } },
                 "attributes" => { "str" => 4 }, "bank_items" => [["gem", 1]])
    assert_nil refusal(UUID_A, rec)
  end

  # --- Party: defaults, seed rule, live/mirror, digest rows -----------------------

  def live(level: 13, xp: 7, form: "striker", home: "zone_7")
    { level: -> { level }, xp: -> { xp }, form: -> { form }, home_zone: -> { home },
      forms: -> { ROSTER.to_h { |k| [k, { "hp" => 1, "inscribed" => false }] } } }
  end

  def party(players:, records:, migration: nil, **live_kw)
    P.new(players:, records:, migration:, live: live(**live_kw))
  end

  def test_default_players_are_seat_constants_never_seed_derived
    # Facts are seed-independent by law (v18 decision 16); a seed-keyed
    # host id would make a save projected at one seed unloadable at another.
    assert_equal({ 1 => "bot-1" }, P.default_players([1]))
    assert_equal({ 1 => "bot-1", 2 => "bot-2" }, P.default_players([1, 2]))
    assert_equal P.default_players([1, 2]), P.default_players([1, 2])
    assert P.default_players([1, 2]).values.all? { |id| C.player_id?(id) }
  end

  def create_missing(pt, new_level: 1)
    pt.create_missing!(new_level:, home_zone: "nest", form: "blocker", roster: ROSTER,
                       max_hp: ->(level, kit) { KIT_MAX[kit] + level },
                       clamp: ->(l) { [l, 21].min })
  end

  def test_missing_seated_player_claims_the_legacy_seed_once_keyed_by_id
    host = C.from_h(UUID_A, record(level: 13))
    mig = { "from_schema" => 2, "legacy_level" => 13, "legacy_seed_claimed_by" => false }
    pt = party(players: { 1 => UUID_A, 2 => UUID_B }, records: { UUID_A => host }, migration: mig)
    create_missing(pt)
    guest = pt.records.fetch(UUID_B)
    assert_equal 13, guest.level, "the first newcomer inherits the v2 world's level (D-T1)"
    assert_equal 0, guest.xp
    assert_equal UUID_B, mig["legacy_seed_claimed_by"], "the claim is a per-player fact"
    assert_equal KIT_MAX["striker"] + 13, guest.forms["striker"]["hp"], "forms at the character's own level"
    # A third player later: the seed is spent.
    pt2 = party(players: { 1 => UUID_A, 2 => "bot-9" }, records: pt.records, migration: mig)
    create_missing(pt2)
    assert_equal 1, pt2.records.fetch("bot-9").level, "every later newcomer starts at new_character.level"
    assert_equal UUID_B, mig["legacy_seed_claimed_by"], "a spent seed never re-claims"
  end

  def test_no_migration_block_means_new_character_level
    pt = party(players: { 1 => "bot-1", 2 => "bot-1-2" }, records: {})
    create_missing(pt, new_level: 1)
    assert_equal [1, 1], [pt.records["bot-1"].level, pt.records["bot-1-2"].level]
    assert_nil pt.migration
    assert_nil pt.project_migration
  end

  def test_seat_order_decides_the_claim_when_both_seats_are_new_and_the_clamp_binds
    mig = { "from_schema" => 2, "legacy_level" => 99, "legacy_seed_claimed_by" => false }
    pt = party(players: { 2 => "bot-2", 1 => "bot-1" }, records: {}, migration: mig)
    create_missing(pt)
    assert_equal "bot-1", mig["legacy_seed_claimed_by"], "seat 1 claims first (seat-order law)"
    assert_equal 21, pt.records["bot-1"].level, "legacy level clamps to the live cap"
    assert_equal 1, pt.records["bot-2"].level
  end

  def test_live_rule_host_all_live_seated_guest_mirrors_level_xp_unseated_stored
    host = C.from_h(UUID_A, record(level: 3, xp: 1, home: "nest", form: "blocker"))
    guest = C.from_h(UUID_B, record(level: 9, xp: 5, home: "camp", form: "lobber"))
    other = C.from_h("bot-4", record(level: 2, xp: 2, home: "zone_7", form: "striker"))
    pt = party(players: { 1 => UUID_A, 2 => UUID_B },
               records: { UUID_A => host, UUID_B => guest, "bot-4" => other },
               level: 13, xp: 7, form: "striker", home: "zone_7")
    proj = pt.project
    assert_equal [13, 7, "striker", "zone_7", 1],
                 proj[UUID_A].values_at("level", "xp", "form", "home_zone").push(proj[UUID_A]["forms"]["striker"]["hp"]),
                 "host: every live key"
    assert_equal [13, 7, "lobber", "camp", KIT_MAX["striker"]],
                 proj[UUID_B].values_at("level", "xp", "form", "home_zone").push(proj[UUID_B]["forms"]["striker"]["hp"]),
                 "seated guest: level/xp mirror the host, everything else frozen"
    assert_equal [2, 2, "striker", "zone_7"], proj["bot-4"].values_at("level", "xp", "form", "home_zone"),
                 "unseated: stored values verbatim"
    assert_equal [UUID_A, UUID_B, "bot-4"].sort, proj.keys, "sorted player-id order"
    assert_equal proj.keys, pt.digest_groups.map { |g, _| g.delete_prefix("character.") }
    assert_equal [["level", 13], ["xp", 7], ["xp_debt", 0], ["insurance", 0], ["form", "lobber"], ["home_zone", "camp"]],
                 pt.digest_groups.to_h.fetch("character.#{UUID_B}")
  end

  def test_nil_live_form_falls_back_to_the_stored_form
    host = C.from_h(UUID_A, record(form: "lobber"))
    pt = party(players: { 1 => UUID_A }, records: { UUID_A => host }, form: nil)
    assert_equal "lobber", pt.project[UUID_A]["form"], "seat 1 waiting for a body keeps the saved form"
  end

  def test_migration_block_projection_and_refusals
    mig = { "from_schema" => 2, "legacy_level" => 13, "legacy_seed_claimed_by" => false }
    pt = party(players: { 1 => "bot-1" }, records: { "bot-1" => C.from_h("bot-1", record) }, migration: mig)
    assert_equal mig, pt.project_migration
    assert_nil P.migration_refusal(mig)
    assert_nil P.migration_refusal(mig.merge("legacy_seed_claimed_by" => UUID_B))
    {
      "not object" => [[], /migration: not an object/],
      "keys" => [mig.merge("extra" => 1), /migration: keys must be exactly/],
      "missing" => [mig.reject { |k, _| k == "legacy_level" }, /migration: keys must be exactly/],
      "from_schema" => [mig.merge("from_schema" => 1), /from_schema: must be 2/],
      "legacy level" => [mig.merge("legacy_level" => 0), /legacy_level: must be an Integer >= 1/],
      "claimed by shape" => [mig.merge("legacy_seed_claimed_by" => "seat-2"), /legacy_seed_claimed_by: must be false \(unclaimed\) or a player id/],
      "claimed by null" => [mig.merge("legacy_seed_claimed_by" => nil), /legacy_seed_claimed_by: must be false \(unclaimed\)/],
      "claimed by true" => [mig.merge("legacy_seed_claimed_by" => true), /legacy_seed_claimed_by: must be false \(unclaimed\)/]
    }.each do |label, (block, pattern)|
      r = P.migration_refusal(block)
      refute_nil r, "#{label}: expected a refusal"
      assert_match pattern, r, label
    end
  end
end
