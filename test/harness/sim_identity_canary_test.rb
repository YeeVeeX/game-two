require_relative "../test_helper"
require_relative "../support/headless_script"

# The three banked etapa-0 sim-identity digests (published in
# drafts/_junior-etapa0-20260815.md, owner-seat verdict SPIKE CLOSED —
# identical on two machines, 3/3). Same seed + same inputs must reproduce
# the same tick-by-tick EVENT stream to the byte. These canaries are the
# v17 seat-refactor safety net (spec W2, blocking): a miss is a DEFECT in
# the change under test — fix it, NEVER rebank these md5s.
class SimIdentityCanaryTest < Minitest::Test
  BANKED = {
    "world_loop" => "a4150c43669b9783e59cb6c39c322b67",
    "varekka_duel" => "22dbad126c73753952574ff450e3419b",
    "burn_duel" => "d148b8386001cdc8da44fe8472e46c72"
  }.freeze

  BANKED.each do |script, md5|
    define_method("test_#{script}_event_stream_matches_banked_etapa0_digest") do
      result = Headless.run_script(
        File.expand_path("../../harness/scripts/#{script}.json", __dir__)
      )
      assert_equal md5, result.md5,
                   "#{script}: EVENT stream (#{result.lines.length} lines) diverged from " \
                   "the banked etapa-0 digest — sim-identity break; fix the change, never rebank"
    end
  end
end
