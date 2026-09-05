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
# ACTIVE bank (2026-08-30, v20 T7 — floor-3 MEDUSA LOWER retheme,
# RATIFIED map change: foundation L3 + spec §SECOND WAVE, owner-approved
# spark): low_quay is re-authored 52x52 through the importer door, and
# the two boss scripts' choreographies died with the old geometry BY
# DESIGN — varekka_duel + burn_duel are RETIRED to harness/retired/
# pending their own boss-seizure re-author session (burn_duel's seizure
# staging was already broken since T1: vessel_seized=0/2, baseline-proven
# in the T6b sweep record). Their outgoing hashes are preserved IMMUTABLE
# below (T7_RETIREMENT); the re-author session re-cuts inputs and rebanks
# under this protocol (S73 precedent: input re-cut = prefix identity N/A).
# world_loop is byte-UNCHANGED — the low_quay retheme provably shifted no
# other zone's stream. floor3_run (the zone's new wall member) joins the
# bank in the same ticket once its reel is tuned.
#
# PREVIOUS bank (2026-08-28, v20 T1 — floor-1 v2b retheme, RATIFIED map
# change: foundation L3 + spec T1, owner-ratified live s114): district is
# re-authored 52x88 through the importer door (two halves, wall-ringed
# chasm, 4 bridges, 27 spawns) and world_loop's district leg was RE-CUT
# for the new geometry (input re-cut, S73 precedent — prefix identity
# holds through line 5 / frame 390, first divergent line = the retarget
# actor name; every divergent class explained in
# drafts/_v20-t1-floor1-20260828.md §canary). varekka_duel + burn_duel
# are byte-UNCHANGED from S80 — the district roster change provably
# shifted no other zone's stream.
#
# S80_HISTORY (2026-08-26, IMMUTABLE — C2 ally defensive-default,
# RATIFIED sim change, v19 foundation Lane 3 row 13, RATIFIED-G +
# RATIFIED-J 2026-08-22): free
# pack bodies acquire PROVOKED humans only, so every unprovoked
# free-ally engagement leaves the streams and all downstream combat
# re-sequences. Stream-diff audit (prefix identity to each script's
# first effect — world_loop line 5, varekka/burn line 3 — every
# divergent line classed): drafts/_c2-canary-rebank-20260826.md.
# burn_duel now ends pack_wiped under its fixed choreography (authored
# against offensive allies) — recorded there as a ritual watch item.
#
# S73_HISTORY (2026-08-25, IMMUTABLE — RATIFIED re-cut, option (a),
# s66 line 2, Junior's pick): varekka_duel's INPUT STREAM was re-cut —
# not a sim change. The old choreography earned its manifest through
# the pre-J7-B door-bounce exploit (s60 evidence:
# drafts/_varekka-repilot-rebrief-20260824.md); 17 pilot generations
# (tmp/pilot/vk3, s73) established the honest profile under the laws of
# its day: one chant per session (completion + vessel-died), no
# interrupt, no boss kill — the boss's post-shed home-deafness made any
# second cycle unreachable pre-Lane-3 C2. Prefix identity N/A
# (different inputs by design); record:
# drafts/_j7b-canary-rebank-20260824.md §s73 +
# drafts/_varekka-recut-20260825.md. world_loop + burn_duel were
# UNCHANGED from S59.
#
# S59_HISTORY (2026-08-24, IMMUTABLE — J7-B cold catch-up, ratified
# lane, foundation row 12): the script's mid-duel 1-frame slow_door
# bounce no longer snap-teleports the room home (elapsed 1 <= linger 90
# = nobody moves). Stream-diff audit (prefix identical through line 159,
# every divergent line explained):
# drafts/_j7b-canary-rebank-20260824.md. Under this bank the OLD
# choreography wiped at 2198; its manifest was unearnable — the s73
# re-cut (above) replaced the stream.
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

  S59_HISTORY = {
    "world_loop" => "a4150c43669b9783e59cb6c39c322b67",
    "varekka_duel" => "31c699cb2ecea5257cd55ec801aa0805",
    "burn_duel" => "fedf0452fc35b62850895016710abdea"
  }.freeze

  S73_HISTORY = {
    "world_loop" => "a4150c43669b9783e59cb6c39c322b67",
    "varekka_duel" => "bf35628a3d2ba50b0aa7d78f9749755e",
    "burn_duel" => "fedf0452fc35b62850895016710abdea"
  }.freeze

  S80_HISTORY = {
    "world_loop" => "982bfd66085005e73d808fcf5d05761d",
    "varekka_duel" => "ecc750ec4577bed854f1d210ba41aac5",
    "burn_duel" => "36d6281cb5988432eda9022fe16acc3c"
  }.freeze

  # MUNDO VIVO FASE 6.1 (2026-09-05, the SWAP — spec
  # drafts/_swap-spec-medusa-to-dungeon1-20260831.md, Junior direction +
  # Gabriel's tower concur): MEDUSA LOWER geometry moved to DUNGEON 1;
  # low_quay became MUSGO A (Junior-approved). floor3_run was choreographed
  # on the medusa in ZONE 5 → RETIRED with its stream preserved below
  # (F6_RETIREMENT); the MUSGO sentinel is authored by the tuner in the
  # follow-up ticket and joins ACTIVE then. world_loop never enters ZONE 5
  # or DUNGEON 1 → byte-UNCHANGED (asserted).
  ACTIVE = {
    "world_loop" => "e0b1f38f0f6a5e3910a45a48f0f7bd3e"
  }.freeze

  F6_RETIREMENT = {
    "floor3_run" => "66bbc9e2056ab8c5bd8e84eb8f246884"
  }.freeze

  # v20 T7 (IMMUTABLE): the boss scripts' final streams on the pre-T7 map,
  # preserved at retirement (never asserted, never deleted — the re-author
  # session banks their successors).
  T7_RETIREMENT = {
    "varekka_duel" => "ecc750ec4577bed854f1d210ba41aac5",
    "burn_duel" => "36d6281cb5988432eda9022fe16acc3c"
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
