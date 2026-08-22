require_relative "../test_helper"
require "tmpdir"
require "json"
require "core/data_store"
require "game/world"
require "game/save_state"
require "app/save_store"

# v18 increment 2 — persistence IO (spec test lane 2, decisions 2/5/6a/14).
# REAL files in a real tmpdir, real Worlds — no mocks. Laws under test:
#   - atomic writes: same-dir .tmp -> flush+fsync -> close -> replace;
#     crash-before-rename keeps the old save; consecutive writes; the
#     Windows rename-over-existing property is pinned BY TEST;
#   - open-handle replace failure: bounded retry then a NAMED error with
#     the .tmp intact (progress never silently lost);
#   - orphan-.tmp detection named at the next load;
#   - unparseable/truncated/schema-skewed files refuse NAMED, never crash;
#   - --fresh backup law: .bak-<ts> BEFORE the first write, recoverable;
#   - save coordinator: writes IFF owner AND reason=:quit, exactly once;
#     desync/conn_lost/protocol/refusal/double-close write NOTHING;
#   - digest provenance: the persist line's digest is recomputed from the
#     bytes actually written/applied — never an echo; the file's facts
#     region IS the canonical byte form.
class SaveStoreTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  SS = Game::SaveState

  def with_store
    Dir.mktmpdir("game-two-save") do |dir|
      yield App::SaveStore.new(path: File.join(dir, "saves", "world.json")), dir
    end
  end

  def facts(banked: 12, sessions: 5)
    {
      "banked" => banked, "provisions" => 1, "home_zone" => "nest",
      "breached" => [["district", [42, 13]]],
      "members" => [
        { "kit" => "striker", "hp" => 80, "inscribed" => false },
        { "kit" => "blocker", "hp" => 0, "inscribed" => true },
        { "kit" => "lobber", "hp" => 33, "inscribed" => false }
      ],
      "counters" => { "boss_1_defeats" => 2, "sessions" => sessions },
      "progression" => { "level" => 1, "xp" => 0 }
    }
  end

  # Schema 1 on disk, byte-exact: what every pre-v19 save file carries.
  def v1_facts(banked: 12, sessions: 5)
    f = facts(banked:, sessions:)
    f.delete("progression")
    f
  end

  def write_v1!(store, f = v1_facts)
    FileUtils.mkdir_p(File.dirname(store.path))
    payload = %({"schema":1,"saved_at_ms":1,"facts":#{SS.canonical_bytes(f)}})
    File.write(store.path, payload, mode: "wb")
    payload
  end

  def world = Game::World.new(DATA, seed: 5)

  # --- write -> load round-trip ------------------------------------------

  def test_write_then_load_round_trips_facts_and_digest
    with_store do |store, _|
      f = facts
      digest = store.write(f, saved_at_ms: 777)
      assert_equal SS.digest(f), digest, "write must return the canonical facts digest"
      loaded = store.load(data: DATA)
      assert_instance_of App::SaveStore::Loaded, loaded
      assert_equal f, loaded.facts
      assert_equal digest, loaded.digest, "loaded digest recomputed from applied bytes"
      assert_empty loaded.notices
      refute File.exist?("#{store.path}.tmp"), "no .tmp left after a clean write"
    end
  end

  def test_file_facts_region_is_the_canonical_byte_form
    with_store do |store, _|
      f = facts
      store.write(f, saved_at_ms: 5)
      raw = File.read(store.path, mode: "rb")
      assert_includes raw, SS.canonical_bytes(f),
                      "the written envelope must embed the canonical facts VERBATIM " \
                      "(the digest is over bytes on disk, not a re-serialization)"
      env = JSON.parse(raw)
      assert_equal SS::SCHEMA, env["schema"]
      assert_equal 5, env["saved_at_ms"]
    end
  end

  def test_consecutive_writes_last_one_wins
    with_store do |store, _|
      store.write(facts(banked: 1), saved_at_ms: 1)
      d2 = store.write(facts(banked: 99), saved_at_ms: 2)
      loaded = store.load(data: DATA)
      assert_equal 99, loaded.facts["banked"]
      assert_equal d2, loaded.digest
      refute File.exist?("#{store.path}.tmp")
    end
  end

  # --- fault lanes (decision 14) ------------------------------------------

  def test_crash_before_rename_keeps_the_old_save_and_names_the_orphan
    with_store do |store, _|
      d1 = store.write(facts(banked: 7), saved_at_ms: 1)
      # A dead process's leftovers: a NEWER .tmp that never replaced.
      sleep 0.05
      File.write("#{store.path}.tmp", "half-written garbag")
      FileUtils.touch("#{store.path}.tmp", mtime: File.mtime(store.path) + 60)
      loaded = store.load(data: DATA)
      assert_instance_of App::SaveStore::Loaded, loaded, "old save must survive the crash"
      assert_equal 7, loaded.facts["banked"]
      assert_equal d1, loaded.digest
      assert loaded.notices.any? { |n| n.include?(".tmp") },
             "the orphan .tmp must be NAMED at the next load: #{loaded.notices}"
    end
  end

  def test_open_handle_replace_failure_bounded_retry_named_error_tmp_intact
    # The pinned property is WINDOWS rename semantics (no FILE_SHARE_DELETE:
    # rename-over-open-file refuses). POSIX replaces an open file happily,
    # so off-Windows the pin has nothing to bite — skip LOUDLY (headless-CI
    # law: platform-specific tests skip off-platform, never fake a pass).
    skip "Windows-only rename-over-open-file semantics" unless Gem.win_platform?
    with_store do |store, _|
      store.write(facts(banked: 1), saved_at_ms: 1)
      err = nil
      File.open(store.path, "rb") do |_handle|
        # Windows: rename-over-open-file refuses (no FILE_SHARE_DELETE) —
        # the second instance / editor / AV-scan lane.
        err = assert_raises(App::SaveStore::WriteError) do
          store.write(facts(banked: 2), saved_at_ms: 2)
        end
      end
      assert_match(/\.tmp/, err.message, "the named error must point at the intact .tmp")
      tmp = "#{store.path}.tmp"
      assert File.exist?(tmp), "progress must survive as the .tmp"
      assert_includes File.read(tmp, mode: "rb"), SS.canonical_bytes(facts(banked: 2))
      loaded = store.load(data: DATA)
      assert_equal 1, loaded.facts["banked"], "the old save stays intact (integrity law)"
      # Handle released: the same write now lands.
      store.write(facts(banked: 2), saved_at_ms: 3)
      assert_equal 2, store.load(data: DATA).facts["banked"]
    end
  end

  def test_unparseable_and_truncated_files_refuse_named
    with_store do |store, _|
      FileUtils.mkdir_p(File.dirname(store.path))
      File.write(store.path, "not json at all {{{")
      r = store.load(data: DATA)
      assert_instance_of App::SaveStore::Refused, r
      assert_match(/unreadable|unparseable/i, r.refusal)
      assert_includes r.refusal, store.path

      store.write(facts, saved_at_ms: 1)
      payload = File.read(store.path, mode: "rb")
      File.write(store.path, payload[0, payload.length / 2], mode: "wb")
      r = store.load(data: DATA)
      assert_instance_of App::SaveStore::Refused, r, "truncated file must refuse, never crash"
    end
  end

  def test_refusal_names_backup_recovery_hint_when_a_bak_exists
    with_store do |store, _|
      store.write(facts, saved_at_ms: 1)
      bak = store.backup_fresh!
      File.write(store.path, "garbage", mode: "wb")
      r = store.load(data: DATA)
      assert_instance_of App::SaveStore::Refused, r
      assert_includes r.refusal, File.basename(bak),
                      "recovery hint must name the newest .bak"
    end
  end

  def test_schema_skew_refuses_named
    with_store do |store, _|
      FileUtils.mkdir_p(File.dirname(store.path))
      File.write(store.path, %({"schema":3,"saved_at_ms":1,"facts":#{SS.canonical_bytes(facts)}}))
      r = store.load(data: DATA)
      assert_instance_of App::SaveStore::Refused, r
      assert_match(/schema/, r.refusal)
    end
  end

  def test_missing_file_is_fresh
    with_store do |store, _|
      r = store.load(data: DATA)
      assert_instance_of App::SaveStore::Fresh, r
      assert_empty r.notices
    end
  end

  # --- schema-1 one-hop upgrade lane (P8: upgrade at load, backup at first
  # write — COPY not rename, so a session that never saves leaves the v1
  # file untouched and read-only consumers stay side-effect-free) ----------

  def test_schema_1_file_loads_upgraded_with_a_named_notice
    with_store do |store, _|
      payload = write_v1!(store)
      loaded = store.load(data: DATA)
      assert_instance_of App::SaveStore::Loaded, loaded
      assert_equal({ "level" => 1, "xp" => 0 }, loaded.facts["progression"])
      assert_equal 12, loaded.facts["banked"]
      assert_equal SS.digest(loaded.facts), loaded.digest,
                   "digest recomputed over the UPGRADED facts"
      assert loaded.notices.any? { |n| n.include?("schema 1 upgraded") },
             "the upgrade must be NAMED at load: #{loaded.notices}"
      assert_empty Dir["#{store.path}.bak-schema1-*"],
                   "no backup at LOAD — the backup rides the first write"
      assert_equal payload, File.read(store.path, mode: "rb"),
                   "load must leave the v1 file byte-identical on disk"
    end
  end

  def test_first_write_after_v1_load_backs_up_the_original_bytes_exactly_once
    with_store do |store, _|
      payload = write_v1!(store)
      loaded = store.load(data: DATA)
      capture_io { store.write(loaded.facts, saved_at_ms: 2) }
      baks = Dir["#{store.path}.bak-schema1-*"]
      assert_equal 1, baks.length, "backup file created exactly once"
      assert_equal Digest::MD5.hexdigest(payload),
                   Digest::MD5.hexdigest(File.read(baks[0], mode: "rb")),
                   "the backup must hold the ORIGINAL v1 bytes (md5-equal)"
      env = JSON.parse(File.read(store.path, mode: "rb"))
      assert_equal SS::SCHEMA, env["schema"], "the live save is v2 after the write"
      capture_io { store.write(loaded.facts, saved_at_ms: 3) }
      assert_equal baks, Dir["#{store.path}.bak-schema1-*"],
                   "a second write must not back up again"
      reloaded = store.load(data: DATA)
      assert_empty reloaded.notices, "the upgraded save reloads as plain v2"
      assert_equal loaded.facts, reloaded.facts
    end
  end

  def test_v1_load_and_coordinator_quit_lands_v2_plus_backup
    with_store do |store, _|
      write_v1!(store)
      loaded = store.load(data: DATA)
      w = Game::World.new(DATA, seed: 5, save: loaded.facts)
      line = nil
      capture_io do
        line = App::SaveCoordinator.new(store:, owner: true).close(world: w, reason: :quit)
      end
      assert_match(/\ATELEMETRY persist saved digest=\h{32} schema=2 /, line)
      assert_equal 1, Dir["#{store.path}.bak-schema1-*"].length,
                   "the owners' v1 bytes survive the first real quit-write"
      assert_equal 6, store.load(data: DATA).facts["counters"]["sessions"],
                   "sessions bumps through the upgrade lane like any save"
    end
  end

  # --- --fresh backup law ---------------------------------------------------

  def test_backup_fresh_moves_the_save_aside_before_any_write
    with_store do |store, _|
      store.write(facts(banked: 42), saved_at_ms: 1)
      bak = store.backup_fresh!
      assert bak && File.exist?(bak), "backup must exist"
      refute File.exist?(store.path), "the save moved aside — next load is fresh"
      assert_instance_of App::SaveStore::Fresh, store.load(data: DATA)
      # Crash between backup and first write: the .bak alone still recovers.
      assert_includes File.read(bak, mode: "rb"), SS.canonical_bytes(facts(banked: 42))
      assert_nil store.backup_fresh!, "nothing left to back up"
      store.write(facts(banked: 0, sessions: 0), saved_at_ms: 2)
      assert_equal 0, store.load(data: DATA).facts["banked"]
    end
  end

  # --- save coordinator (decision 2) ---------------------------------------

  def test_coordinator_owner_clean_quit_writes_once_and_bumps_sessions
    with_store do |store, _|
      w = world
      w.pack.bank!(31)
      coord = App::SaveCoordinator.new(store:, owner: true)
      line = coord.close(world: w, reason: :quit)
      assert_match(/\ATELEMETRY persist saved digest=\h{32} schema=2 /, line)
      assert_includes line, "banked=31"
      loaded = store.load(data: DATA)
      assert_equal 31, loaded.facts["banked"]
      assert_equal w.sessions + 1, loaded.facts["counters"]["sessions"],
                   "sessions increments at each save-write"
      # The line's digest is the digest of the bytes on disk — not an echo.
      assert_includes line, "digest=#{loaded.digest}"
      assert_nil coord.close(world: w, reason: :quit), "repeated close writes once"
      assert_equal loaded.digest, store.load(data: DATA).digest
    end
  end

  def test_coordinator_negative_lanes_write_nothing
    %i[desync conn_lost protocol].each do |reason|
      with_store do |store, _|
        coord = App::SaveCoordinator.new(store:, owner: true)
        assert_nil coord.close(world:, reason:), "#{reason} must not save"
        assert_instance_of App::SaveStore::Fresh, store.load(data: DATA),
                           "#{reason} wrote a file — a diverged world poisoned the save"
      end
    end
    with_store do |store, _|
      coord = App::SaveCoordinator.new(store:, owner: false)
      assert_nil coord.close(world:, reason: :quit), "a non-owner seat must never write"
      assert_instance_of App::SaveStore::Fresh, store.load(data: DATA)
    end
  end

  def test_coordinator_replace_failure_reports_named_never_silent
    # Same Windows-only pin as the open-handle test above: POSIX replaces
    # an open file, so the coordinator's ERROR lane never fires on Linux.
    skip "Windows-only rename-over-open-file semantics" unless Gem.win_platform?
    with_store do |store, _|
      store.write(facts, saved_at_ms: 1)
      w = world
      coord = App::SaveCoordinator.new(store:, owner: true)
      line = File.open(store.path, "rb") { coord.close(world: w, reason: :quit) }
      assert_match(/persist ERROR/, line, "a failed replace must surface NAMED")
      assert_match(/\.tmp/, line)
      assert File.exist?("#{store.path}.tmp"), "progress intact at the .tmp"
    end
  end

  # --- persist lines (decision 5) -------------------------------------------

  def test_persist_line_formats
    f = facts
    d = SS.digest(f)
    saved = App::SaveStore.persist_line("saved", facts: f, digest: d)
    assert_equal "TELEMETRY persist saved digest=#{d} schema=2 banked=12 " \
                 "provisions=1 seals=1 marks=1 sessions=5", saved
    loaded = App::SaveStore.persist_line("loaded", facts: f, digest: d, source: "file")
    assert_equal "TELEMETRY persist loaded digest=#{d} schema=2 banked=12 " \
                 "provisions=1 seals=1 marks=1 sessions=5 source=file", loaded
    fresh = App::SaveStore.persist_line("fresh", source: "fresh")
    assert_equal "TELEMETRY persist fresh schema=2 source=fresh", fresh
  end

  def test_loaded_line_digest_matches_what_a_world_actually_applies
    with_store do |store, _|
      w = world
      w.pack.bank!(9)
      w.restore_breach!("district", [42, 13])
      App::SaveCoordinator.new(store:, owner: true).close(world: w, reason: :quit)
      loaded = store.load(data: DATA)
      resumed = Game::World.new(DATA, seed: 123, save: loaded.facts)
      assert_equal loaded.digest, SS.digest(SS.facts(resumed)),
                   "the digest chain: loaded digest == digest of the resumed world's facts"
      assert_equal 9, resumed.pack.banked
      assert resumed.breached?("district", [42, 13])
    end
  end
end
