require_relative "../test_helper"
require "json"
require "tmpdir"
require "rbconfig"
require "fileutils"

# Wall pin ledger (v22 prep, s131): harness/pins.rb + harness/pins.json +
# `rake pins`. Same class as manifest_check / run_wall tests: harness
# tooling is enforcement, so it gets real-process tests (no mocks — the
# script is executed exactly as run_wall.sh and the Rakefile execute it).
class PinsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  SCRIPT = File.join(ROOT, "harness", "pins.rb")
  LEDGER = File.join(ROOT, "harness", "pins.json")
  RUBY = RbConfig.ruby

  def run_pins(*args)
    out = IO.popen([RUBY, SCRIPT, *args], err: [:child, :out], chdir: ROOT, &:read)
    [out, $?.exitstatus]
  end

  def test_tracked_ledger_is_a_json_array_of_complete_rows
    rows = JSON.parse(File.read(LEDGER, encoding: "utf-8"))
    assert_kind_of Array, rows, "harness/pins.json must be a JSON array (starts as [])"
    rows.each do |r|
      assert_equal [], %w[script tag commit date gate_rc manifest_rc] - r.keys,
                   "pins.json row missing keys: #{r.inspect}"
    end
  end

  def test_rakefile_exposes_rake_pins_over_the_report_verb
    rakefile = File.read(File.join(ROOT, "Rakefile"))
    assert_includes rakefile, "task :pins", "Rakefile lacks `task :pins`"
    assert_includes rakefile, "harness/pins.rb report", "`rake pins` must run the report verb"
  end

  def test_run_wall_records_a_pin_per_script
    wall = File.read(File.join(ROOT, "harness", "run_wall.sh"))
    assert_includes wall, "harness/pins.rb record", "run_wall.sh must record a pin after every script"
    assert_includes wall, "--gate-rc \"$gate_rc\"", "the pin must carry the captured gate rc"
    assert_includes wall, "--manifest-rc \"$man_rc\"", "the pin must carry the captured manifest rc"
  end

  def test_report_on_an_empty_ledger_says_so_and_exits_zero
    Dir.mktmpdir do |dir|
      path = File.join(dir, "pins.json")
      File.write(path, "[]\n")
      out, rc = run_pins("report", "--pins", path)
      assert_equal 0, rc, out
      assert_includes out, "no pins recorded yet"
    end
  end

  def test_record_then_report_classifies_pinned_stale_failed_unpinned_and_retired
    Dir.mktmpdir do |dir|
      path = File.join(dir, "pins.json")
      head = IO.popen(%w[git rev-parse --short=7 HEAD], chdir: ROOT, &:read).strip
      scripts = Dir[File.join(ROOT, "harness", "scripts", "*.json")].map { |p| File.basename(p, ".json") }.sort
      pinned, stale, failed = scripts.first(3)
      # A commit that certainly predates HEAD and has render/sim changes after it.
      old = IO.popen(%w[git rev-list --max-parents=0 HEAD], chdir: ROOT, &:read).split.first[0, 7]

      out, rc = run_pins("record", "--pins", path, "--script", pinned, "--tag", "t", "--gate-rc", "0", "--manifest-rc", "0")
      assert_equal 0, rc, out
      assert_includes out, "PIN recorded: #{pinned}"
      _, rc = run_pins("record", "--pins", path, "--script", "#{stale}.json", "--tag", "t", "--gate-rc", "0",
                       "--manifest-rc", "0", "--commit", old, "--date", "2026-01-01T00:00:00Z")
      assert_equal 0, rc
      _, rc = run_pins("record", "--pins", path, "--script", failed, "--tag", "t", "--gate-rc", "1", "--manifest-rc", "0")
      assert_equal 0, rc
      _, rc = run_pins("record", "--pins", path, "--script", "gone_script", "--tag", "t", "--gate-rc", "0", "--manifest-rc", "0")
      assert_equal 0, rc

      rows = JSON.parse(File.read(path))
      assert_equal 4, rows.size
      assert_equal stale, rows[1]["script"], "record strips .json from the script name"
      assert_equal head, rows[0]["commit"], "record stamps HEAD when --commit is absent"

      out, rc = run_pins("report", "--pins", path)
      assert_equal 0, rc, out
      assert_match(/^PINNED\s+#{Regexp.escape(pinned)}\s+#{head}/, out)
      assert_match(/^STALE\s+#{Regexp.escape(stale)}\s+#{old}.*render\/sim commit/, out)
      assert_match(/^FAILED\s+#{Regexp.escape(failed)}\s+.*gate_rc=1/, out)
      assert_match(/^RETIRED\s+gone_script/, out)
      assert_equal scripts.size - 3, out.scan(/^UNPINNED/).size
      assert_match(/^PINS: #{scripts.size} scripts .* pinned=1 stale=1 failed=1 unpinned=#{scripts.size - 3}/, out)
    end
  end

  def test_refusals_are_named_and_nonzero
    Dir.mktmpdir do |dir|
      bad = File.join(dir, "bad.json")
      File.write(bad, "{}\n")
      out, rc = run_pins("report", "--pins", bad)
      assert_equal 2, rc
      assert_includes out, "must be a JSON array"

      path = File.join(dir, "pins.json")
      out, rc = run_pins("record", "--pins", path, "--script", "x", "--tag", "t", "--gate-rc", "abc", "--manifest-rc", "0")
      assert_equal 2, rc
      assert_includes out, "--gate-rc must be an integer"
      refute File.exist?(path), "a refused record must not create the ledger"

      out, rc = run_pins("frobnicate")
      assert_equal 2, rc
      assert_includes out, "usage:"
    end
  end

  # --- E1 (T0 d4): pins + verdict log write to the MAIN clone's ledger from
  # any worktree. The 064bd80 sweep ran in worktree game-two-wall3 (pruned);
  # its pins and verdict JSON died with it while the tracked ledger stayed [].
  # Both resolvers key on `git rev-parse --git-common-dir` — a no-op in the
  # main clone, the main clone's .git from any linked worktree.

  # Under the pre-commit hook git exports GIT_DIR/GIT_INDEX_FILE; a child
  # `git worktree add` inheriting them dies on the parent's index path.
  GIT_SCRUB = { "GIT_DIR" => nil, "GIT_INDEX_FILE" => nil,
                "GIT_WORK_TREE" => nil, "GIT_PREFIX" => nil }.freeze

  # First interpreter whose --version exits 0 (normalize_ldtk_test pattern).
  def self.python
    return @python if defined?(@python)
    @python = [%w[python], %w[py -3.12], %w[python3]].find do |cmd|
      IO.popen([*cmd, "--version"], err: File::NULL, &:read)
      $?.success?
    rescue Errno::ENOENT
      false
    end
  end

  def probe_default_path(dir)
    IO.popen([RUBY, "-e", 'require File.expand_path("harness/pins.rb"); puts Harness::Pins::DEFAULT_PATH'],
             chdir: dir, &:read).strip.tr("\\", "/")
  end

  def probe_critic_root(dir)
    code = "import sys; sys.path.insert(0, 'harness'); " \
           "import vision_critic as vc; print(vc._main_repo_root())"
    IO.popen({ "CRITIC_TRANSPORT" => "gateway" }, [*self.class.python, "-c", code],
             chdir: dir, err: File::NULL, &:read).strip.tr("\\", "/")
  end

  def test_ledger_paths_resolve_to_the_main_clone_in_the_plain_clone
    assert_equal File.join(ROOT, "harness", "pins.json"), probe_default_path(ROOT)
    skip "no Python interpreter" unless self.class.python
    assert_equal ROOT, probe_critic_root(ROOT), "vision_critic._main_repo_root must be the repo root"
  end

  def test_ledger_paths_resolve_to_the_main_clone_from_a_worktree
    Dir.mktmpdir do |dir|
      wt = File.join(dir, "wt")
      out = IO.popen(GIT_SCRUB, %W[git worktree add --detach #{wt}], chdir: ROOT, err: [:child, :out], &:read)
      assert $?.success?, "git worktree add failed: #{out}"
      begin
        # The worktree checks out HEAD; the resolver under test is the
        # WORKING-TREE source — copy it in so uncommitted fixes are judged.
        FileUtils.cp(File.join(ROOT, "harness", "pins.rb"), File.join(wt, "harness", "pins.rb"))
        FileUtils.cp(File.join(ROOT, "harness", "vision_critic.py"), File.join(wt, "harness", "vision_critic.py"))
        assert_equal File.join(ROOT, "harness", "pins.json"), probe_default_path(wt),
                     "a worktree pin must land in the main clone's ledger"
        if self.class.python
          assert_equal ROOT, probe_critic_root(wt),
                       "a worktree gate's verdict log must land in the main clone's drafts/"
        end
      ensure
        IO.popen(GIT_SCRUB, %W[git worktree remove --force #{wt}], chdir: ROOT, err: [:child, :out], &:read)
      end
    end
  end
end
