require_relative "../test_helper"
require "app/vsync_release"

# Lag P0 T4 (2026-08-20): env-gated vsync release — the PLUMBING only
# (flag gate, boot-line wording, refusal/failure naming, zero-cost-when-
# absent). The real SDL_GL_SetSwapInterval effect is machine behavior,
# proven by the A/B frame_probe runs banked in
# drafts/_lag-t4-vsync-20260820.md — never by these tests.
class VsyncReleaseTest < Minitest::Test
  # A scripted SDL surface: Get returns before-then-after; Set records.
  class FakeSDL
    attr_reader :set_calls

    def initialize(before:, after:, rc: 0)
      @gets = [before, after]
      @rc = rc
      @set_calls = []
    end

    define_method(:SDL_GL_GetSwapInterval) { @gets.shift }
    define_method(:SDL_GL_SetSwapInterval) do |interval|
      @set_calls << interval
      @rc
    end
  end

  def test_absent_flag_is_nil_and_never_touches_sdl
    poison = BasicObject.new # any call = NoMethodError = the test fails loudly
    assert_nil App::VsyncRelease.apply(env: {}, lib: poison)
    assert(!$LOADED_FEATURES.any? { |f| f.include?("/ffi.rb") },
           "the absent-flag path must never require ffi (laziness law; " \
           "nothing else in this suite loads it)")
  end

  def test_flag_on_releases_the_interval_and_prints_the_named_boot_line
    sdl = FakeSDL.new(before: 1, after: 0)
    line = App::VsyncRelease.apply(env: { "GAME_VSYNC_OFF" => "1" }, lib: sdl)
    assert_equal "VSYNC off (swap_interval=0 was=1 rc=0)", line,
                 "was=1 is the same-instance proof (gosu set 1 at construction)"
    assert_equal [0], sdl.set_calls
  end

  def test_a_driver_refusal_is_named_never_hidden
    sdl = FakeSDL.new(before: 1, after: 1, rc: -1)
    line = App::VsyncRelease.apply(env: { "GAME_VSYNC_OFF" => "1" }, lib: sdl)
    assert_equal "VSYNC off REFUSED (swap_interval=1 was=1 rc=-1)", line
  end

  def test_a_load_failure_names_itself_on_ONE_line_and_never_kills_the_game
    boom = Object.new
    def boom.SDL_GL_GetSwapInterval
      raise LoadError, "no SDL2:\nSearched in <system library path>"
    end
    line = App::VsyncRelease.apply(env: { "GAME_VSYNC_OFF" => "1" }, lib: boom)
    assert_equal "VSYNC off FAILED (LoadError: no SDL2: Searched in <system library path>)",
                 line,
                 "foreign e.messages embed newlines (ffi's did, live); the boot line stays ONE line"
  end
end
