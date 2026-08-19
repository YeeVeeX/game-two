require_relative "../test_helper"
require "game/creature"
require "app/renderer"

# Flywheel fix 1 (2026-08-19): the ledger beat slot must never spend its
# 150-frame dwell on a zero-information "+0" (verified against clip
# low_quay_run 104223, frames v_000729/2492/3836 — kills-only windows
# force-resolved by zone_entered render solo "+0"). The suppression
# predicate is pure logic — draw output itself is judged by the Rule 2
# gate, not here.
class RendererSilentBeatTest < Minitest::Test
  def beat(kind: :fight, gained: 0, pip: 0, dark: 0)
    { kind: kind, gained: gained, pip_amount: pip, dark_amount: dark,
      net: gained - pip - dark, recovery: false,
      beat_left: 150, beat_frames: 150 }
  end

  def test_all_zero_fight_beat_is_silent
    assert App::Renderer.silent_beat?(beat)
  end

  def test_all_zero_bank_beat_is_silent
    assert App::Renderer.silent_beat?(beat(kind: :bank))
  end

  def test_wipe_recap_is_never_silenced_even_all_zero
    refute App::Renderer.silent_beat?(beat(kind: :wipe))
  end

  def test_gained_keeps_the_beat
    refute App::Renderer.silent_beat?(beat(gained: 5))
  end

  def test_stranded_pip_keeps_the_beat
    refute App::Renderer.silent_beat?(beat(pip: 11))
  end

  def test_destroyed_dark_keeps_the_beat
    refute App::Renderer.silent_beat?(beat(dark: 3))
  end
end
