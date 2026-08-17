require_relative "../test_helper"

# The canary sweep runner is load-bearing enforcement for the v18 cycle
# (a byte-identity sweep follows every sim-touching increment — spec
# decision 7 / W3). Same shell-level invariants as run_wall.sh: pipe
# exits captured via PIPESTATUS, directory-glob iteration, loud nonzero
# failure, bundled rake.
class RunCanaryTest < Minitest::Test
  SCRIPT = File.expand_path("../../harness/run_canary.sh", __dir__)

  def source
    @source ||= File.read(SCRIPT)
  end

  def test_exists_and_bash_syntax_is_valid
    assert File.exist?(SCRIPT), "harness/run_canary.sh missing"
    assert system("bash", "-n", SCRIPT), "bash -n rejected harness/run_canary.sh"
  end

  def test_guards_against_pipe_exit_masking
    assert_includes source, "pipefail", "pipefail guard missing"
    assert_includes source, "PIPESTATUS", "PIPESTATUS capture missing (never trust $? after tee)"
  end

  def test_iterates_the_scripts_directory_not_an_inline_list
    assert_includes source, "harness/scripts/*.json",
                    "sweep must glob harness/scripts/ (inline lists went stale once)"
  end

  def test_fails_loudly_with_nonzero_exit
    assert_includes source, "exit 1", "sweep must exit nonzero on any script failure"
  end

  def test_runs_rake_under_bundler
    assert_includes source, "bundle exec rake",
                    "unbundled rake drifted from Gemfile.lock once (2026-08-11)"
  end
end
