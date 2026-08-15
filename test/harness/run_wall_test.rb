require_relative "../test_helper"

# The wall runner is load-bearing enforcement (manifest_check precedent:
# harness tooling gets tests). Its failure mode is silent false-passes —
# the old untracked tmp/ runner masked critic failures for ~2 cycles via a
# bare-$?-after-pipe bug. Guard the shell-level invariants that prevent a
# recurrence; the runner's semantics are exercised by the wall itself.
class RunWallTest < Minitest::Test
  SCRIPT = File.expand_path("../../harness/run_wall.sh", __dir__)

  def source
    @source ||= File.read(SCRIPT)
  end

  def test_exists_and_bash_syntax_is_valid
    assert File.exist?(SCRIPT), "harness/run_wall.sh missing"
    assert system("bash", "-n", SCRIPT), "bash -n rejected harness/run_wall.sh"
  end

  def test_guards_against_pipe_exit_masking
    assert_includes source, "pipefail", "pipefail guard missing"
    assert_includes source, "PIPESTATUS", "PIPESTATUS capture missing (never trust $? after tee)"
  end

  def test_iterates_the_scripts_directory_not_an_inline_list
    assert_includes source, "harness/scripts/*.json",
                    "wall must glob harness/scripts/ (inline lists went stale once)"
  end

  def test_fails_loudly_with_nonzero_exit
    assert_includes source, "exit 1", "wall must exit nonzero on any script failure"
  end

  def test_runs_rake_under_bundler
    assert_includes source, "bundle exec rake",
                    "unbundled rake drifted from Gemfile.lock once (2026-08-11)"
  end
end
