#!/bin/bash
# Wall #4 close - ONE command (run when the sweep has printed WALL SWEEP DONE and no ruby is alive).
# A) extraction proof: gate ledger_loop + town_gates at SIG1 (lane signage commit 1 = pure extraction)
#    and compare captures byte-for-byte with wall #4's (@ cbaa4a5). Expected: IDENTICAL x2.
# B) the fixes at HEAD: bright pack spark (boss1_writ dash_strike_rip district_hunt basement_pocket),
#    halo contour (boss2_phases world_loop), aura re-cut + pressure ring rule (brasa1_run brasa2_run
#    brasa3_run aoe_specials), low-hp pulse (district_hunt), corrected rows (aim_hold floor1_run),
#    then the extraction pair at HEAD too (ledger_loop town_gates) so their pins are current.
set -u
W=/c/Users/q/Desktop/gametwo
echo "### A) extraction proof @ $(git -C $W/game-two-sig1 rev-parse --short HEAD) vs wall #4 captures"
( cd $W/game-two-sig1 && bash $W/game-two/tools/gate_batch.sh sig1 --ref $W/game-two-wall6/captures ledger_loop town_gates )
echo "### B) fixes @ $(git -C $W/game-two rev-parse --short HEAD)"
( cd $W/game-two && bash tools/gate_batch.sh build4fix --ref $W/game-two-wall6/captures \
    boss1_writ dash_strike_rip district_hunt basement_pocket boss2_phases world_loop \
    brasa1_run brasa2_run brasa3_run aoe_specials aim_hold floor1_run ledger_loop town_gates )
echo "### DONE $(date +%H:%M)"
