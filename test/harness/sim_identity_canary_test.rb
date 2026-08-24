require_relative "../test_helper"
require_relative "../support/headless_script"

# Sim-identity canaries: same seed + same inputs must reproduce the same
# tick-by-tick EVENT stream to the byte, on every machine.
#
# THE LAW (teeth intact): a miss against the ACTIVE bank is a blocking
# DEFECT in the change under test — fix the change, NEVER rebank —
# UNLESS a new RATIFIED sim change repeats the versioned-bank protocol
# in full: owner approval + an old-vs-new stream-diff audit (every
# divergent line explained, byte-exact prefix identity up to the
# change's first effect) + the outgoing bank preserved below as
# immutable history.
#
# ACTIVE bank (2026-08-24, s59 — RATIFICATION PENDING, async per owner
# order 2026-08-22): varekka_duel moved by J7-B cold catch-up (ratified
# lane, foundation row 12): the script's mid-duel 1-frame slow_door
# bounce no longer snap-teleports the room home (elapsed 1 <= linger 90
# = nobody moves). Stream-diff audit (prefix identical through line 159,
# every divergent line explained):
# drafts/_j7b-canary-rebank-20260824.md. world_loop + burn_duel:
# UNCHANGED. varekka_duel's choreography is stale under the new law
# (wipes at 2198; manifest unearnable) — re-pilot queued, wall slot RED.
#
# S43_HISTORY (2026-08-22, IMMUTABLE — owner-approved rebank, Gabriel,
# s43 chat): moved by T2 progression (spec P2/P4/P5) — level-2 stat
# growth compresses kill timing after the first level-up. Stream-diff
# audit lives in drafts/_prog-t2-close-20260822.md. world_loop never
# levels, so its digest is UNCHANGED from etapa 0 (level-1 identity
# proof).
#
# ETAPA0_HISTORY (v17, IMMUTABLE): the original bank, published in
# drafts/_junior-etapa0-20260815.md (owner-seat verdict SPIKE CLOSED —
# identical on two machines, 3/3). Preserved forever, never asserted
# against, never deleted.
class SimIdentityCanaryTest < Minitest::Test
  ETAPA0_HISTORY = {
    "world_loop" => "a4150c43669b9783e59cb6c39c322b67",
    "varekka_duel" => "22dbad126c73753952574ff450e3419b",
    "burn_duel" => "d148b8386001cdc8da44fe8472e46c72"
  }.freeze

  S43_HISTORY = {
    "world_loop" => "a4150c43669b9783e59cb6c39c322b67",
    "varekka_duel" => "68fa69f6e23f0ae39361eec2fbc8c5d1",
    "burn_duel" => "fedf0452fc35b62850895016710abdea"
  }.freeze

  ACTIVE = {
    "world_loop" => "a4150c43669b9783e59cb6c39c322b67",
    "varekka_duel" => "31c699cb2ecea5257cd55ec801aa0805",
    "burn_duel" => "fedf0452fc35b62850895016710abdea"
  }.freeze

  ACTIVE.each do |script, md5|
    define_method("test_#{script}_event_stream_matches_active_bank") do
      result = Headless.run_script(
        File.expand_path("../../harness/scripts/#{script}.json", __dir__)
      )
      assert_equal md5, result.md5,
                   "#{script}: EVENT stream (#{result.lines.length} lines) diverged from " \
                   "the ACTIVE sim-identity bank — a DEFECT in the change under test; " \
                   "fix the change, never rebank (versioned-bank protocol: file header)"
    end
  end
end
