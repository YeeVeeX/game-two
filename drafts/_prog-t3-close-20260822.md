# T3 close — presentation: level/XP HUD strip + level-up feel beat (s46, 2026-08-22)

Brief executed: `drafts/_prog-t3-presentation.md` (cut s45). Spec:
`docs/superpowers/specs/2026-08-22-progression-v1.md` P4/P12, T3 row.
TWO commits, in brief order:

- **A `fa57a41` feat(hud)** — level/XP strip in `draw_hud` (label +
  thin gold bar under the vitals, bar-only progress, cap draws FULL),
  6 display keys, `hud.level` ×3 locales, `hud_level_strip_reads`
  gate check, `test/core/strings_parity_test.rb` (three-way key-set
  identity). Suite 1069/0F.
- **B `efc65a0` feat(feel)** — `Transients#level_up_pop!` (combat
  clock, kill-pop record shape), world.rb pushes from the EXISTING
  `:level_up` branch (gold stamp via new banner `suffix` +
  `level_up_pop!` per living member), `draw_level_pops` (shards-only,
  gold, NO white flash), banner suffix at draw, `stamp.level_up` ×3,
  harness `progression` start param (T5's fixture primitive),
  `harness/scripts/level_up_beat.json`, `level_up_beat_reads` check,
  test lanes (transients, banner suffix, world integration with
  dead-member exclusion, scene_start progression). Suite 1075/0F.

## Scope-fence audit

- Sim numbers: ZERO moved — `data/balance/**` untouched (git diff
  proves it; only `data/display.json` + `data/strings/*` grew, both
  lawful presentation surfaces).
- window.rb: 217 lines, untouched. save_state.rb: untouched (NIT 1
  stays parked for the next save_state ticket). No audio.
- world.rb arithmetic: 1790 → **1795** (net +5 ≤ +6, final ≤ 1796,
  hard cap 1800): enqueue_banner suffix 0 · enqueue_stamp suffix 0 ·
  `:level_up` branch +4 (2 push lines + 2 comment) · delegator +1.
  No new ivars, no new sim state — records live in Transients.
- Decision 1 HELD: `:level_up` is NOT in `harness/event_log.rb`
  EVENTS. The ACTIVE canary bank is untouched by construction; the
  full versioned-bank protocol (owner approval + stream-diff audit +
  history row) remains the recorded price for any future ticket that
  wants it. Byte proof instead: `TELEMETRY progression …` in every
  replay log.
- Live save: `98fe75edb6d72deab18cd48eaa88bdaf` before AND after
  (measured at open, mid-ladder, close; reviewer re-measured
  independently).

## Wall-script authoring (the instrumented-run record)

Throwaway headless driver (T2 stream-diff pattern; deleted): candidate
= world_loop inputs + `start.progression {level:1, xp:79}` (ΔE(2)=80).
Beat frame **643** — `actor_died rusher1 killer=blocker` (an ALLY
kill feeding the pack — A2 exercised in the wall). Second rusher dies
692 mid-dwell (xp 29 < 160 → no second stamp; lawful, kept — the reel
proves one-crossing-one-stamp). Inputs trimmed to ≤ 822, captures
[620 pre-kill, 645 beat+2, 651 beat+8, 723 mid-dwell, 813 post-dwell],
run_until 823, manifest {actor_died: 4, attack_hit: 8}. Pinned
telemetry: `level=2 xp=29 kills_xp=30` (the recipe's illustrative
`xp=14 kills_xp=15` assumed a one-kill reel; the authoring run pins
the real two-kill values — shape is what binds: level=2, kills_xp>0).

## Verify ladder (all green)

- Hook suite at A (1069/0F) and B (1075/0F); baseline was 1068/0F.
- Post-A iteration aid: SKIP_CRITIC world_loop — 10 captures
  byte-identical; strip eyeballed on frame_0701 (NOT ship evidence).
- **Full gate `level_up_beat.json` (critic ON): PASS** — 5 captures
  byte-identical ×2 runs; vision PASS on all checks including both
  new ones. `MANIFEST PASS: actor_died=4 attack_hit=36`. Telemetry
  grep: `TELEMETRY progression level=2 xp=29 kills_xp=30` ×2.
- **Full wall sweep `harness/run_wall.sh t3-hud`** (~3.5h detached,
  22 scripts): **determinism 22/22 PASS · vision 21/22 on the first
  pass · manifests 15/22.** The two failure families, both resolved
  or dispatched below: (1) ONE real T3 regression the gate caught
  (varekka — next section), fixed + re-gated PASS; (2) seven scripts
  with manifests stale since T2's ratified sim change — mechanically
  attributed (every missing row reproduces byte-for-byte at pre-T3
  `354f2b2` via worktree headless runs), split into an audited
  row-drop class (shipped here) and a re-author class (surfaced as a
  priority work item). `level_up_beat.json` itself: gate + manifest
  PASS inside the sweep.
- **Netplay gates ×3** (post-fix tree): session 12 captures · desync
  4 · conn_lost 4 — all byte-identical ×2 runs, vision PASS ×3.
- `rake perf`: **PASS** — ticks=6990 p50=0.205ms p95=0.449ms
  max=3.320ms (<< 16.6ms).
- Caps: world.rb 1795 ≤ 1796 · window.rb 217 · line_caps green in
  suite.
- Fresh-eyes review (Rule 6): **PASS, 0 blockers, 3 NITs** — headless
  scrubbed pi over the diff + brief + spec, read-only, seat mail
  untouched (it flagged the incoming assets-seat note and correctly
  left it; the seat holder archived it — fire-and-forget receipt, no
  reply owed). The reviewer independently verified: diff
  byte-identity vs 354f2b2..efc65a0, the scope fence (zero balance/
  window/save_state/audio), Decision 1 (no `:level_up` in EventLog;
  zero in-sim subscribers), renderer purity (no clocks/records/
  respond_to?; delta_e pure), fill math (197 < 200 max; cap ternary
  short-circuits; positive-guard), suffix cleanliness (no numerals in
  locale tables), pause-law parity, suite arithmetic 1068→1069→1075,
  manifest floor semantics, telemetry reconciliation (79+15−80=14,
  +15=29 < ΔE(3)=160), and SAVE_MD5 `98fe75ed…` live. NITs:
  1. `level_up_beat_reads` escape wording narrower than reality — a
     reel can CONTAIN a level-up with no straddling capture pair (hit
     live: aoe_specials in the sweep; the critic generalized
     sensibly). RESOLVED post-sweep: wording amended to cover the
     no-straddling-pair case (recalibration, not weakening — strictly
     more permissive on the escape, so every sweep pass under the old
     wording remains valid; the beat script's positive judgment
     unaffected, its reel straddles).
  2. Multi-level single kill stamps once with the FINAL level by
     construction (award loops before the handler reads level); the
     integration lane stages only 1→2. Accepted per ticket — recorded
     here; a multi-level boundary lane rides whichever future ticket
     next touches award flow.
  3. Ladder steps 5-8 owed after the review — tracked in this draft's
     ladder section (all landed before push).

## The varekka catch — a REAL T3 regression, gate-caught, fixed (`350a185`)

The sweep's varekka_duel gate FAILED `challenger_tell_reads` at
frame_0937: "blue chant square on the boss but no hollow blue square
floats above any pack vessel." Pixel forensics (pre-T3 canary frame
vs sweep frame, PIL diff): the ONLY deltas in the frame were the
hp-fill edge (lawful T2 stat drift) and the strip band y80-88 — the
chant vessel-tell (8×8 world-anchored square at `t.y - 20`) landed
EXACTLY in the strip's bar band and the opaque backing/fill buried it
to a 3px sliver. A safety-critical cue ("he is calling THAT body")
occluded by chrome — the exact class `writ_frame_reads` legislates
against. Rule 2 worked: s44's identical world frame passed; T3's
strip moved it to hidden; the critic refused.

**Fix (one rule):** the vessel-tell's two rects ride at z 15 — above
every z-0 HUD rect (level strip AND the hp bars, whose occlusion of
the tell was a pre-existing latent case) and above the writ veil,
below HUD numerals (z 20). Frames without a pinned vessel are
byte-identical by construction (the two rects only draw on
`chant_target`).

**Blast radius, mechanically closed:** chant events exist in exactly
3 of 22 reels (grep across all sweep logs). varekka_duel re-gate:
**PASS** (tell reads over the strip; determinism 5/5). burn_duel
re-gate: **PASS** (its frame_0420 legitimately changed — the tell on
a vessel pinned OUTSIDE the writ now burns through the veil instead
of being incidentally dimmed; critic passed writ/seizure/tell family
on the new frames; determinism 6/6). multi_floor_descent (chant at
2880, captures 2890/2911): fresh captures **byte-identical** to the
sweep's — no re-gate owed. All other scripts carry zero chant events.

## Manifest staleness — seven scripts, T2's wake, mechanically attributed

Worktree headless runs at `354f2b2` (pre-T3, post-T2) reproduce every
missing row at the sweep's exact counts — T3 moved ZERO streams (the
suite's canaries said so; the worktree runs prove it per script):

| script | rows short (got/want per double) | pre-T3 | class |
|---|---|---|---|
| burn_duel | pack_wiped 0/2 | 0 | row-drop (T2 audit traced THIS wipe aversion BY NAME) |
| district_hunt | pack_wiped 0/1 · pack_respawned 0/1 | 0·0 | row-drop (same audited mechanism; wipe coverage survives via corpse_run + nest_advance rows) |
| corpse_run | banked 0/1 (wipes still fire 14×) | 0 | RE-AUTHOR — terminal bank beat gone |
| low_quay_run | banked 0/4 · tribute 2/4 · drops 2/10 · looted 0/2 · regrown 2/6 | same | RE-AUTHOR — economy loop diverges mid-reel |
| nest_advance | corpse_loaded 0/1 · corpse_looted 0/1 (banked + wipes still fire) | 0·0 | RE-AUTHOR — corpse sub-beat gone |
| sustain_run | provision_bought 4/10 · banked 4/6 | same | RE-AUTHOR — partial completion |
| vat_economy | tribute 0/1 · regrown 0/1 · banked 0/1 · inscribed 0/1 | all 0 | RE-AUTHOR — whole story gone |

**Shipped here (`95a796f`):** the two row-drop manifests (re-judged
against the SAME teed sweep logs: both MANIFEST PASS — manifest_check
is a pure function of script+log, no re-render owed) + the
`level_up_beat_reads` escape widened to unstraddled reels (review
NIT 1; strictly more permissive escape, so every sweep verdict under
the old wording stays valid — recalibration, not weakening).

**SURFACED, not fixed — the re-author five (owner-visible priority
call):** five long-reel scripts no longer complete their staged
stories under T2's ratified stat growth. Their gates (determinism +
vision) all PASS — Rule 2 held for T3's visual change — but the wall's
semantic net is degraded until they are re-authored (pilot sessions,
full gate each; none is canary-banked, so no versioned-bank protocol
fires). Recommendation recorded for the peers: re-author WITH
`start.progression` staging (stage e.g. level 5 so mid-reel level-ups
cannot flip outcomes — ΔE(6)=880 is unreachable in a reel), making
the wall stat-stable against the COMING pacing retunes (the sim
numbers are unfrozen until the ritual); land it before the ritual
stages, sequencing vs T4/T5 = the humans' call.

## KB-rubric vision critique (Rule 2 vision half, R-A2 precedent)

Rubric derived from the verified shelf (`hub kb query --domain
uiux-design` + game-research): `game-ui-ux-patterns` (Stonehouse
diegetic-spatial taxonomy R 191; Swink/juice R 193; Nielsen-for-games
H8 R 194), `uiux-foundational-principles-encyclopedia` (Krug 7.6
visual hierarchy), `interaction-design-catalog` (progress-indicator
semantics), `rpg-xp-curves-and-leveling-formulas` (Aversa: level-ups
are THE reward event — "we want to see the number"). Judged on the
five gate captures (both runs byte-identical):

1. **Quadrant choice** (R 191): non-diegetic HUD-plane strip beside
   the vitals is the correct cell for persistent, frequently-read
   progress — legibility over immersion. PASS (frames 0620/0813:
   strip reads at a glance mid-combat).
2. **Minimalist H8** (R 194): bar-only progress, no numeral churn,
   fixed layout (bar pinned at x140 independent of label width) —
   zero layout shift across all 5 frames. PASS.
3. **Hierarchy** (Krug 7.6): 6px gold bar + attached label sits
   visually BELOW the 14px kit bars + possession ring; never reads as
   a fourth hp bar (critic concurs — `hud_level_strip_reads` PASS).
   The stamp briefly dominates at the beat — intended, it IS the
   reward event. PASS.
4. **Juice on a real event** (R 193): the beat layers polish on an
   actual stat change (P4 sim effect shipped in T2); shards-only gold
   pops (14f), no second white flash (white stays spawn/holy;
   `hurt_flash_not_white` family), kill pop + level pop co-fire at
   DIFFERENT tiles with color separation (frame 0645); burst budget
   held (`burst_legibility_budget` PASS — bodies + ground readable
   through the beat). PASS.
5. **Reward-event naming** (Aversa): the stamp names the NUMBER
   ("LEVEL 2"), not a numberless "LEVEL UP" — suffix mechanism keeps
   numerals out of the flat K/V locale tables. PASS.
6. **Progress semantics** (interaction-design-catalog): determinate
   bar, honest integer mapping (197/200px at 79/80 pre-kill →
   ~36/200px at 29/160 post-dwell), fill never overflows backing;
   cap-draws-full decision recorded (not exercisable in this reel).
   PASS.

Note (recorded, no action): at 0645 the two far pack bodies sit near
the viewport bottom, so their pops render close to the controls strip
band; strip stays legible (subdued backing) and the critic passed
`controls_overlay_reads` + `burst_legibility_budget` on the reel.
Worth re-checking when J-6's menu work touches that band.

## Locale critique (BLOCKING — human-facing-output checklist; accuracy and presentation scored separately)

Surfaces: `hud.level` (HUD label) + `stamp.level_up` (stamp banner)
× en/es-CR/pt-br; suffix " N" locale-invariant, appended after
translation. Register target: generic-videogame placeholder,
functional labels translate (owner order 2026-08-16).

- **Accuracy: PASS ×3.** en "LEVEL"/"LEVEL 2" — standard. es "NIVEL"/
  "NIVEL 2" — THE es gamer word (not grado/rango); noun-numeral order
  natural; no gender/article issue. pt-br "NÍVEL"/"NÍVEL 2" — the
  standard BR word; acute accent correctly kept on the uppercase Í
  (pt-br orthography keeps accents on capitals); noun-numeral order
  natural. Suffix order valid in all three (the Decision-5 premise
  held).
- **Presentation: PASS ×3.** Flat declarative, TOLL PAID / BOSS 1
  DEFEATED register family; all-caps consistent with both surfaces'
  siblings (`hud.provisions`, `stamp.mark_void`); zero
  foreclosure/judicial drift (es/pt everyday-gamer-word law, project
  memory 2026-08-18); widest label "NÍVEL 10" fits the reserved slot
  (~64px of 108px). UTF-8 literals in the JSON verified rendering
  (gate captures render en by the comparability law; es/pt resolve
  through the same tested Strings path).
- Note: `hud.level` and `stamp.level_up` share values per locale —
  intentional (two surfaces, one word). pt-br values await Junior's
  async ratification per his lane (development never gates on peer
  availability — owner order 2026-08-22); if he re-words, it is a
  strings-only follow-up.

## T4/T5 amendments (flagged for the next brief-cutters)

0. **The re-author five outrank presentation niceties**: corpse_run ·
   low_quay_run · nest_advance · sustain_run · vat_economy re-authored
   with `start.progression` staging (stat-stability against pacing
   retunes), one pilot + full gate each — before the ritual stages;
   sequencing vs T4/T5 is the peers' call (recorded above).

1. **T5 inherits the `progression` start param** (shipped in B —
   `harness/support.rb`; scene_start lanes prove level staging + hp
   sync). A `requires_level` fixture scene stages its level in one
   line.
2. **Wall grew to 22 scripts** (`level_up_beat.json` — ~5 min/script
   standing price, accepted by the ticket). T4's reach-change capture
   should follow the same instrumented-authoring pattern (headless
   driver → pin frames → delete driver).
3. **Post-T2 reels cross levels on their own** (e.g. aoe_specials now
   ends `level=2 xp=80 kills_xp=160`): any script whose reel straddles
   a level-up gets judged by `level_up_beat_reads` (no escape) — a
   mid-reel stamp colliding with a zone banner DELAYS lawfully (FIFO,
   never dropped). If a future script's captures land inside such a
   collision, route around it in the script, never weaken the check.
4. **Flywheel staleness stands** (brief note, re-affirmed): ALL
   pre-T3 clip/critique baselines are stale for HUD-region claims —
   the strip is in every frame now. Re-baseline before trusting old
   critiques there.
5. NIT 1 (save_state `cap` shadow) still parked — T3 never opened the
   file; the next save_state ticket owes the rename.

## Measurement hygiene

Ritual wording UNWRITTEN · zero sim numbers moved (balance/ untouched;
display/strings keys are presentation) · bot logs never fun-evidence ·
live save byte-identical · canary bank untouched (Decision 1) —
Junior's next hook run re-proves it cross-machine; a red there is
SIGNAL, never rebank.
