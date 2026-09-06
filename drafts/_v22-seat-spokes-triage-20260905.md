# v22 seat spokes — routing/triage (2026-09-05, s132, Gabriel seat, hub)

Owner order (hub chat s131, verbatim): "orchestrate the ui/ux and assets seats". Standing:
"cost is not a concern, quality over cost if its inside AWS". Skill: seat-orchestration
(hub decides on disk FIRST; digest-stamped prompts; free seats only; one pass per spoke;
RECEIPTs harvested back here). Fan-out is pre-authorized (owner ruling 2026-08-28).

## 0. Inbox harvest at orient (`~/.pi/agent/mail/game-two/inbox/`, s132)

| Mail | md5 (file) | Disposition |
|---|---|---|
| `from-uiux-a3-one-body-spec.md` | — | ABSENT → spoke U launched (below) |
| `from-assets-v22-art-direction.md` | — | ABSENT → spoke A launched (below) |
| `from-gamesmith-tour-pipeline-receipt.md` (2026-09-05 09:46) | `see §0.1` | BANKED docs-only: DONE-PARTIAL, $8.43, `mechanics-inventory.md` PASSED, `core-loops.md` FAILED ×2 (citation gate) → a third `extract` is the OWNER's call; the uiux commission already cites the passing artifacts by path. Moved to `done/`. |
| `from-gamesmith-owner-depth-priorities-and-grid-blending.md` (2026-08-29, v2) | `see §0.1` | BANKED docs-only. **R1 grid order recorded here as an owner order (verbatim):** "I would like that the grid in the game is less visible and each grid visually merged with each other when we start to add textures and assets into the game, so it looks more fluid but still holds the grid function" → the art charter's tile grammar law (logic grid stays byte-authoritative; only the RENDER layer blends; functional reads never blur). Junior's dual-grid tiles (`7189be7`, D7 grid lines OFF) are the first execution of it. R2 (C3 evidence asks) → the v20 C3 rung was superseded by the v22 pivot; will be answered when the party-hunt grammar reaches a spec (v23/v24). R3 paths+md5s: not re-verified this session (docs-only pass; verify when a lane cites them). R4 (gap-audit trigger at "T4/T5 close") → the v20 T4/T5 tickets closed with the NINETEENTH; the trigger is spent — a v22 re-arm is the owner's call. Moved to `done/`; RECEIPT mailed to gamesmith. |
| `20260829-g2a-v33-renderer-repin-note.md` (2026-08-29) | `see §0.1` | BANKED informational (assets seat's approve-by-default re-pin note; nothing owed). Moved to `done/`. |

### 0.1 digests (computed at harvest, `md5sum` of the inbox files before the move)

```
0332855877ae40e725a8d1a00232b11a  from-gamesmith-tour-pipeline-receipt.md
8c42fa946a4a64af52114a3e1824b1cd  from-gamesmith-owner-depth-priorities-and-grid-blending.md
c4a96cf62a083c024a82b505c38941cf  20260829-g2a-v33-renderer-repin-note.md
```

## 1. Routes (both seats FREE per `fleet` at launch; game-two-assets tree is DIRTY from a
prior session — `M AGENTS.md` + 4 untracked docs — the spoke is told to leave them untouched)

| Spoke | Seat | Brief (verbatim mail, digest-stamped) | Budget (Rule 7) | Stop |
|---|---|---|---|---|
| U — A3 legibility spec for ONE BODY | `game-two-uiux` | `~/.pi/agent/mail/game-two-uiux/inbox/from-game-two-a3-one-body-commission.md` md5 `5a364f69c3d05590202a806cf407b07f` | ~$5 at the default model (Claude Fable 5.1, $10/$50 per M; judged design work rides the default, never a cheaper tier) · one pass · ≤1 relaunch on infra failure only | DoD in the mail §3 (spec + rubric + 7 mocks + RECEIPT) or a fence, named |
| A — art direction pass + Aseprite pipeline + tile-fork input | `game-two-assets` | `~/.pi/agent/mail/game-two-assets/inbox/from-game-two-v22-art-direction-commission.md` md5 `75e16992941f1dbd677de2e21873b0a6` | ~$5, same terms | DoD in the mail §3 (critique + bible + pipeline + striker proof + RECEIPT) or a fence, named |

Amendments carried in both prompts (cite this doc by path): (a) the foundation moved since the
mail was written — council pass folded in s132; re-read it live and verify the blob md5 printed
in the prompt; (b) council amendment A1 (coop respawn at the current zone's arrival tile) is
PENDING the owner's word — spec the death ledger card + respawn veil so they read the same in
solo (home) and coop (arrival tile) — never decide it; (c) touch NOTHING in game-two, including
seat mail other than your own RECEIPT file; (d) the assets tree's pre-existing dirty files are
not yours — commit only your own new paths; (e) final line = the RECEIPT.

## 2. Receipts (record-first: UNCHECKED until harvested)

- [x] U — **HARVESTED s133 (21:1x; spoke exited ~14:16, receipt mail md5 `f2cd29cd919c0758b57992e84699eb37`, moved to `done/`).** Verbatim:
  `RECEIPT: uiux A3-one-body docs/specs/one-body-a3.md 503d010d52ba1265b219ec0d3ebc4b4e 33`
  **Spot-check vs the mail's DoD (read-only `git -C game-two-uiux`, HEAD `18e6c7c`, pushed, hooks 141 runs / 0 failures):** spec `docs/specs/one-body-a3.md` blob md5 `503d010d…` = RECEIPT ✓ · data delta `data/ui/ob_one_body.json` blob `c064c872…` (54 keys / 31 new) ✓ · rubric: 14 `a3_*` gate rows in `handoff/a3-one-body-20260905/a3_gate_rows.json` (5 accuracy / 9 presentation; §9 maps the 7 L17 pack rows they replace) ✓ · mocks: 24 capture dirs (8 screens × 3 locales), 57 PNGs in the handoff bank (33 frames + 24 sheets), scripted Gosu renders, double-fresh-process pixel-hash equal, **UI-GATE PASS ×3 locales 36/36 (axes separate)** ✓ · one sheet eyeballed by the hub (`ob_hud_party_proposed_en`: gold-framed single bar, FORM row with the hollow earned-third slot, cyan partner / hollow-grey companion rows, hollow red XP DEBT segment on the LEVEL bar, 3 INSURANCE pips) ✓ · fences: zero writes into game-two ✓ · spend ≈ $5–6 vs ~$5 declared (one hung pt critic call, rerun).
  **Grammar banked for the spec (T2c HUD, T5 pip, T6 card, T7 form glyph, F1 banner):** your body = the ONLY gold-framed bar; FORM row (kit-colored slots, active gold, earned-third hollow, cooldown bar length = state, `FORM n`); party class smaller + unframed (cyan mark partner / hollow grey companion); XP DEBT = hollow red outline from the LEVEL bar's left; INSURANCE = 3 labeled pips; death card = SIX fixed lines (who · `XP LOST -n` · hollow `XP DEBT n` · `INSURANCE SAVED +n` · empty pips = upsell · `CONTINUE IN n`) location-free; bank/vat verbs on the live purple hint class; goals board on `requires_level` doors; banner `ZONE 5 · -3` + hole/stairs/rope shapes + `DOWN · -4`.
  **Findings for game-two:** **F-A3-1 CONFIRMED by the hub on the tour frame at t=12 s (HUB 1): the green SAFE chip overdraws the `0 COINS` chip** (`tmp/s133/tour_12s_hud.png`; proposed `safe_chip_y` 98 → 138) → T0 findings doc (area b addendum) · F-A3-2 D1 cue chip vs station numeral overlap (recorded) · probe-driven contrast deltas (`hud_plate_alpha` 220, `hud_slot_hollow_rgb`, `hud_debt_rgb` [220,50,50]) · **locale finding: es/pt SEGURO collides with the SAFE chip's word** → spec T5 strings become a peers' choice (PÓLIZA / APÓLICE rendered as the alternative). 13 open questions in its §14 (A1 is now moot — owner word s132; L11 CLOSED s133; the rest land at their tickets).
  **Owed back by mail after AS (art charter):** a re-render of the 8 mocks at the chosen scale.
- [ ] **A2 — bible bridge + commit unblock (s133):** owner word "yes" on `ring_expand_rect` (foundation §RATIFICATION s133 (0)) + "A now" (3b) → mail `~/.pi/agent/mail/game-two-assets/inbox/from-game-two-v22-bible-is-law.md` (md5 `2cc12d0eae72085264bb04e893ff4938`; charter blob md5 `e891fb8e74101b3e0e18ab0b3c5f56c1` stamped inside) → spoke launched 21:04 (`tmp/spokes/run_assets_s133.sh`, log `tmp/spokes/assets_s133.log`, done-marker `assets_s133.done`; Rule 7: one pass ~$5, NO image spend, stop = RECEIPT or fence). Expected RECEIPT: commit hash of the 44 files + derived-palette md5 + AS frame-size note. UNCHECKED until harvested.
- [x] A — HARVESTED s132 (mail md5 `e693055ed11f96a8ad6601ac855a1cdd`, moved to `done/`). Verbatim:
  `RECEIPT: assets v22-art-direction reviews/art-direction-v34/critique.md docs/v22-style-bible.md docs/aseprite-atlas-pipeline.md critique=67f62f4908b39c05b8291d645682d35c bible=58c98cf33ee7a2f51a2094cc6a46c0a4 pipeline=0ef4c4f89b0e81dc34cdc8b198c7707b tile-fork=126f718cf0480da9890d149d661c7676 tool=760989ce03354244b11fb5ca8123cf57 striker-export=3e22b6261e69e25adfee048130502db5 commit=BLOCKED-live-pin-owner-review`
  **Spot-check vs the mail's DoD:** critique (accuracy 6/10, presentation 5/10, 10 ranked fixes, every claim cites `<kit>.png[c,r]` or a tour frame) ✓ · style bible + swatches (40-colour master palette, outline/shadow/hurt law, depth tints, timing table, 5 reference looks as pixels) ✓ · Aseprite → atlas pipeline (tool + 2 Lua scripts + 18 tests incl. a live headless Aseprite round trip; CI check = manifest md5 + dims) ✓ · **striker proof: export md5 == manifest pin `3e22b626…`, manifest diff NONE, 0 px diff** ✓ · tile-fork input (art side: SPLIT grammar — dual-grid fill stays, LDtk rules for props/wall-shadow/variant clumps; Junior decides — consistent with his Option-2-now / Option-1-for-borders+props line) ✓ · fences: game-two untouched, $0 image spend, no fiction names, dirty files untouched ✓.
  **Surfaced for the humans (the one spoke item that needs a word):** the assets repo's own pre-commit live-pin gate BLOCKED its commit — game-two HEAD drifted 4 pinned files vs its baseline `d749458d`, and the derived constant `ring_expand_rect` (the old possession ring, superseded by Junior's PREMIUM halo `58e6153`) is gone → the assets protocol classes a draw-value removal as OWNER REVIEW. The 44 files sit STAGED on disk in `game-two-assets` (nothing lost). To land: owner word "retire `ring_expand_rect` (ring → halo)" → the assets seat applies the four `sha256_lf` pin pairs `pin_drift.py` printed → commit → detached push (its pre-push gauntlet ~3.5 h). One owner line; recorded in CYCLE owner-pending.
  **Art-charter inputs banked (top findings, detail in the critique):** pack and ember families share the 13–25° hue band; the player's hood shares hue+value with wall tints in district_two / dungeon_2-4; ember creatures on lava_deco are luminance-flat; the flagstone texture re-introduces a 16 px mortar grid (vs the owner's grid order); 283 body colours, no master palette; outline weight varies per material; husk ≡ rusher silhouette; 1-wide dual-grid walls read as pills. None is a redraw; atlas-byte changes re-pin md5s + L17 rows (priced in the charter). Spoke's "for next time": a byte-hash contract makes the PNG encoder part of the contract — pin the encoder fingerprint beside the md5s (`pil 12.3.0 zlib 1.3.1.zlib-ng`).

Harvest law: read the log tail + the RECEIPT + spot-check artifacts against the mail's DoD;
bank docs-only (this file + the art charter cite them); a missing/failed receipt goes to the
humans with the log quoted — never a silent re-run.
