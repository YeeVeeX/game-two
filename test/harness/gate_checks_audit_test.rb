require_relative "../test_helper"
require "json"
require "game/world"

# Gate-checks SURFACE AUDIT (v22 prep, s131). harness/gate_checks.json (what
# the vision critic judges) and harness/scripts/*.json (what the wall stages)
# are two sources that must agree — the same trap class as the LDtk IntGrid
# values undeclared in the Terrain def (WB-T6): each file was internally fine
# while the pair silently drifted. harness/gate_scope.json names which check
# rows read a SPECIFIC zone; this test binds all three files.
class GateChecksAuditTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  CHECKS = File.join(ROOT, "harness", "gate_checks.json")
  SCOPE = File.join(ROOT, "harness", "gate_scope.json")
  SCRIPTS = Dir[File.join(ROOT, "harness", "scripts", "*.json")].sort
  ZONES = Dir[File.join(ROOT, "data", "zones", "*.json")].map { |p| File.basename(p, ".json") }.sort

  def checks = @checks ||= JSON.parse(File.read(CHECKS, encoding: "utf-8")).fetch("checks")
  def check_ids = @check_ids ||= checks.map { |c| c.fetch("id") }
  def scope_doc = @scope_doc ||= JSON.parse(File.read(SCOPE, encoding: "utf-8"))
  def scope = scope_doc.fetch("scope")
  def unread = scope_doc.fetch("unread_start_zones")

  # A wall script's staged start zone: `start.zone`, else the world's home.
  def start_zones
    @start_zones ||= SCRIPTS.to_h do |path|
      script = JSON.parse(File.read(path, encoding: "utf-8"))
      zone = script.fetch("start", {}).fetch("zone", Game::World::HOME_ZONE)
      [File.basename(path, ".json"), zone]
    end
  end

  def test_fixtures_exist_and_have_the_expected_shape
    refute_empty checks, "gate_checks.json has no checks"
    assert_equal check_ids.uniq, check_ids, "duplicate check ids in gate_checks.json"
    refute_empty scope, "gate_scope.json scope is empty"
    assert_operator SCRIPTS.size, :>=, 30, "wall scripts went missing"
    refute_empty ZONES
  end

  def test_every_scoped_id_is_a_live_check_row
    stale = scope.keys - check_ids
    assert_empty stale, "gate_scope.json names check ids that no longer exist in gate_checks.json: #{stale.inspect}"
  end

  def test_every_scoped_zone_exists_in_data_zones
    named = (scope.values.flatten + unread.keys).uniq
    unknown = named - ZONES
    assert_empty unknown, "gate_scope.json names zones with no data/zones/<zone>.json: #{unknown.inspect}"
  end

  def test_every_scoped_check_is_staged_by_at_least_one_wall_script
    staged = start_zones.values.uniq
    orphans = scope.select { |_id, zones| (zones & staged).empty? }
    assert_empty orphans,
                 "gate rows read a zone no wall script starts in (the critic can only ever answer " \
                 "'not exercised'): #{orphans.inspect}. Author a wall script for the zone or retire the row."
  end

  def test_every_wall_start_zone_is_read_by_a_scoped_check_or_explicitly_allowlisted
    read_zones = scope.values.flatten.uniq
    gaps = start_zones.reject { |_s, z| read_zones.include?(z) || unread.key?(z) }
    assert_empty gaps,
                 "wall scripts stage a start zone that no gate row reads by name and that is not " \
                 "allowlisted in gate_scope.json unread_start_zones: #{gaps.inspect}"
  end

  def test_unread_allowlist_is_exact
    read_zones = scope.values.flatten.uniq
    staged = start_zones.values.uniq
    unread.each do |zone, reason|
      refute_includes read_zones, zone,
                      "#{zone} is allowlisted as unread but a scoped check now reads it — remove the allowlist row"
      assert_includes staged, zone,
                      "#{zone} is allowlisted as unread but no wall script stages it — remove the allowlist row"
      assert_kind_of String, reason
      assert_operator reason.length, :>=, 20, "unread_start_zones[#{zone}] needs a real reason"
    end
  end

  def test_scoped_check_texts_mention_their_zone_by_display_name_or_id
    # Guards the scope map itself against drift: a scoped row's prose must
    # name the zone (display name like ZONE 5 / DUNGEON 1 / HUB 1 / TEST 2,
    # or the id like district_two / low_quay), or a family word the row
    # is scoped by (MEDUSA TOWER, BRASA, moss, nest, BOSS).
    strings = JSON.parse(File.read(File.join(ROOT, "data", "strings", "en.json"), encoding: "utf-8"))
    families = %w[TOWER BRASA moss MOSS nest Nest BOSS boss CHARGE BEAM camp station vat]
    by_id = checks.to_h { |c| [c["id"], c["check"]] }
    scope.each do |id, zones|
      text = by_id.fetch(id)
      names = zones.flat_map { |z| [z, strings["zone.#{z}.display_name"]].compact }
      hit = (names + families).any? { |n| text.include?(n) }
      assert hit, "scoped row #{id} never mentions #{names.inspect} (or a family word) — scope drifted from the prose"
    end
  end
end
