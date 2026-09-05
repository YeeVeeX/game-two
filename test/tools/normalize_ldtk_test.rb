require_relative "../test_helper"
require "json"
require "open3"
require "tmpdir"
require "fileutils"

# WB-T6 (S0): the normalizer is the bridge between LDtk's own writer
# (tabs + LF on every GUI save) and the builders' byte-format pin
# (json.dumps(indent=2) + CRLF, tools/build_tower_floor.py:83-88). Real
# python process, real files, no mocks. A missing interpreter SKIPS
# LOUDLY (named), never passes silently.
class NormalizeLdtkTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  TOOL = File.join(ROOT, "tools/normalize_ldtk.py")
  PROJECT = File.join(ROOT, "authoring/pilot.ldtk")
  # LDtk-resaved bytes (T1 spike, drafts/_ldtk-spike-findings-20260819.md):
  # tab-indented, LF -- exactly what a GUI save produces.
  FIXTURE = File.join(ROOT, "test/fixtures/spike_district.ldtk")
  CANDIDATES = [%w[py -3.12], %w[python], %w[python3]].freeze

  # First candidate whose --version exits 0 (the WindowsApps python3
  # alias is a Store stub that exits nonzero -- it must not be picked).
  def self.interpreter
    return @interpreter if defined?(@interpreter)
    @interpreter = CANDIDATES.find do |cmd|
      _, _, status = Open3.capture3(*cmd, "--version")
      status.success?
    rescue Errno::ENOENT
      false
    end
  end

  def setup
    return if self.class.interpreter
    reason = "no Python interpreter found (tried: #{CANDIDATES.map { |c| c.join(' ') }.join(', ')}) " \
             "-- normalize_ldtk tests need one (LDtk AfterSave law, WB-T6)"
    warn "SKIP #{self.class}: #{reason}"
    skip reason
  end

  def run_tool(*args)
    Open3.capture3(*self.class.interpreter, TOOL, *args, chdir: ROOT)
  end

  def test_committed_pilot_project_is_canonical
    stdout, stderr, status = run_tool("--check", PROJECT)
    assert status.success?, "pilot.ldtk drifted from the byte-format pin: #{stdout}#{stderr}"
    assert_match(/\Acanonical /, stdout)
  end

  def test_check_refuses_ldtk_resaved_bytes_with_a_named_reason
    stdout, _, status = run_tool("--check", FIXTURE)
    assert_equal 1, status.exitstatus
    assert_match(/\ANOT CANONICAL .*spike_district\.ldtk: tab-indented/, stdout)
    assert_equal 1, stdout.lines.length, "one-line reason"
  end

  def test_normalize_is_semantics_preserving_and_idempotent
    Dir.mktmpdir do |dir|
      copy = File.join(dir, "spike.ldtk")
      FileUtils.cp(FIXTURE, copy)
      stdout, stderr, status = run_tool("normalize", copy)
      assert status.success?, stderr
      assert_match(/\Anormalized /, stdout)
      first = File.binread(copy)
      refute_equal File.binread(FIXTURE), first, "bytes must move (the fixture is LDtk-style)"
      assert_equal JSON.parse(File.read(FIXTURE)), JSON.parse(first), "values untouched"
      assert first.end_with?("\r\n"), "CRLF pin"
      refute_includes first, "\t", "no tabs (2-space pin)"

      _, _, status = run_tool("--check", copy)
      assert status.success?, "normalized output must pass --check"

      stdout, _, status = run_tool("normalize", copy)
      assert status.success?
      assert_match(/\Aalready canonical /, stdout)
      assert_equal first, File.binread(copy), "second pass = same bytes (idempotent)"

      _, _, status = run_tool("--semantic-diff", copy, FIXTURE)
      assert status.success?, "normalized copy must be parsed-equal to the original"
    end
  end

  def test_semantic_diff_names_the_differing_paths
    Dir.mktmpdir do |dir|
      a = File.join(dir, "a.json")
      b = File.join(dir, "b.json")
      File.binwrite(a, JSON.generate({ "x" => 1, "y" => [1, 2], "z" => { "k" => true }, "s" => "caf\u00e9 \u{1F600}" }))
      File.binwrite(b, JSON.generate({ "x" => 1.0, "y" => [1, 3], "z" => { "k" => 1 }, "s" => "cafe" }))
      stdout, stderr, status = run_tool("--semantic-diff", a, b)
      assert_equal 1, status.exitstatus, stderr
      assert_match(/\$\.y\[1\]: 2 != 3/, stdout)
      assert_match(/\$\.z\.k: true != 1/, stdout, "bool never equals int")
      assert_match(/\$\.s: "caf\\u00e9/, stdout, "non-ASCII values print escaped (cp1252 console safety)")
      refute_match(/\$\.x/, stdout, "1 vs 1.0 is formatting, not semantics")
    end
  end

  def test_invalid_input_is_a_named_refusal
    Dir.mktmpdir do |dir|
      bad = File.join(dir, "bad.ldtk")
      File.binwrite(bad, "{ not json")
      stdout, _, status = run_tool("--check", bad)
      assert_equal 2, status.exitstatus
      assert_match(/\ANORMALIZE REFUSED: /, stdout)
    end
  end
end
