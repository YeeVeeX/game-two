require_relative "../test_helper"

# Architecture caps, script-enforced (the hooks philosophy: enforced, not
# prompt-requested). Non-negotiable #1 from the Kethral post-mortem: the
# Gosu orchestrator stays a thin shell (kethral/game.py hit 2,663 lines
# WITH a bus available). The world.rb ceiling is the 2026-08-15
# process-debt review's cap + extract-on-touch rule: the next cycle that
# materially edits a subsystem moves it to a plain object with explicit
# call order (drops/corpses are the cleanest seam; NO bus mediation
# inside the sim — determinism + debuggability).
class LineCapsTest < Minitest::Test
  def count(path)
    File.foreach(File.expand_path("../../#{path}", __dir__)).count
  end

  def test_window_orchestrator_stays_thin
    assert_operator count("src/app/window.rb"), :<=, 300,
                    "window.rb breached the orchestrator cap (non-negotiable #1) — " \
                    "systems talk via the event bus or they don't ship"
  end

  def test_world_growth_ceiling
    assert_operator count("src/game/world.rb"), :<=, 1_800,
                    "world.rb hit the growth ceiling — extract the subsystem " \
                    "you are touching into a plain object (explicit call " \
                    "order, no in-sim bus mediation) instead of growing the god-file"
  end
end
