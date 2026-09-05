require_relative "../test_helper"
require "json"
require "open3"
require "tmpdir"
require "fileutils"
require_relative "normalize_ldtk_test"

# WB-T6 (S0): the AfterSave driver LDtk runs on Ctrl+S -- normalize, then
# import into a scratch dir, then lint. Real python -> real ruby, real
# files; exit code is the contract (LDtk keeps its runner window open on
# nonzero). Shares the interpreter probe + loud skip with the normalizer
# test.
class LdtkAftersaveTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  TOOL = File.join(ROOT, "tools/ldtk_aftersave.py")
  PROJECT = File.join(ROOT, "authoring/pilot.ldtk")
  COMMAND = "python ../tools/ldtk_aftersave.py ../authoring/pilot.ldtk".freeze

  def setup
    return if NormalizeLdtkTest.interpreter
    reason = "no Python interpreter found -- ldtk_aftersave tests need one (WB-T6)"
    warn "SKIP #{self.class}: #{reason}"
    skip reason
  end

  def run_driver(*args, chdir:)
    Open3.capture2e(*NormalizeLdtkTest.interpreter, TOOL, *args, chdir:)
  end

  # The registration LDtk reads: a GUI edit that drops the command or the
  # backups is named here, not discovered at the next broken build.
  def test_pilot_project_registers_the_aftersave_command_and_backups
    doc = JSON.parse(File.read(PROJECT))
    assert_equal [{ "command" => COMMAND, "when" => "AfterSave" }], doc["customCommands"]
    assert_equal true, doc["backupOnSave"]
    assert_equal 10, doc["backupLimit"]
    assert_equal "../tmp/ldtk-backups", doc["backupRelPath"], "backups stay under gitignored tmp/"
  end

  # LDtk's shape: cwd = the project directory, relative paths, no shell.
  # An un-normalized copy of the live project must come back canonical
  # with the importer green and exit 0.
  def test_driver_normalizes_imports_and_exits_zero_on_a_clean_project
    Dir.mktmpdir do |dir|
      copy = File.join(dir, "pilot.ldtk")
      out = File.join(dir, "out")
      File.binwrite(copy, JSON.pretty_generate(JSON.parse(File.read(PROJECT))).gsub("\r\n", "\n"))
      output, status = run_driver("pilot.ldtk", "--out", out, chdir: dir)
      assert status.success?, output
      assert_match(/\[aftersave\] normalized/, output)
      assert_match(/\[aftersave\] import: exit 0/, output)
      assert_match(/\[aftersave\] ok/, output)
      assert_equal 13, Dir[File.join(out, "*.json")].length, "13 pilot zones emitted"
      _, _, check = Open3.capture3(*NormalizeLdtkTest.interpreter,
                                   File.join(ROOT, "tools/normalize_ldtk.py"), "--check", copy)
      assert check.success?, "the driver leaves the project canonical"
    end
  end

  def test_driver_exits_nonzero_when_the_importer_refuses
    Dir.mktmpdir do |dir|
      copy = File.join(dir, "pilot.ldtk")
      doc = JSON.parse(File.read(PROJECT))
      doc["jsonVersion"] = "1.4.0"
      File.binwrite(copy, JSON.generate(doc))
      output, status = run_driver("pilot.ldtk", "--out", File.join(dir, "out"), chdir: dir)
      assert_equal 1, status.exitstatus
      assert_match(/IMPORT REFUSED: jsonVersion "1\.4\.0"/, output)
      assert_match(/\[aftersave\] FAILED: import/, output)
    end
  end

  def test_driver_exits_nonzero_on_unparseable_input
    Dir.mktmpdir do |dir|
      bad = File.join(dir, "bad.ldtk")
      File.binwrite(bad, "{ nope")
      output, status = run_driver("bad.ldtk", chdir: dir)
      assert_equal 1, status.exitstatus
      assert_match(/\[aftersave\] NORMALIZE REFUSED/, output)
    end
  end
end
