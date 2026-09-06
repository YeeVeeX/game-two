> LANDED 2026-09-06 18:4x @ 3a7f6fc (S1 on T1): save = facts syncs host.bag <- bag.to_save; load = Loot#load_bag! after build_party; CLASSIFICATION contents/used :persisted; ONE source of truth = the live Game::Bag. Landing gate (loot_loop + basement_pocket): see drafts/_wall-premium-build4-20260906.log last block. S2+S3 wait for the TWENTIETH.

# S1–S3 landing plan on T1 (schema 3) — ready-to-apply, 2026-09-06

Owner sequencing (foundation §RATIFICATION s133, spec §"Merge point 1"): **S1 any time after T1**
(data-only), **S2 + S3 after the TWENTIETH verdict**. Spec §T1 already reserves the keys in the
per-PLAYER character record with EMPTY defaults: `bag []`, `equipment {}`, `attributes {}`,
`bank_items []`. Optional-key law: anything after T1 lands is an optional key with a default INSIDE
schema 3, never schema 4. This document makes the landing a **mechanical** step for whoever holds
the seat when T1 merges (Gabriel's `t1-schema3`, CLAIMED s136 `a41ca0c`).

## What is already built on `junior/premium-build` (validated @ wall #3 + re-gate, suite 1510/0)
- S1 `data/items.json` (16 items) + `Game::ItemCatalog` (strict) + icons + strings ×3 locales.
- S2 `Game::Bag` (slots from `economy.json bag_slots`, order-free digest) + `Game::Loot` mixin
  (drops, pickup through interact, cure) + bag screen (UI only) — bag digest classified
  **`session_only` (NAMED debt until T1)** in `test/game/save_state_test.rb` CLASSIFICATION.
- S3 statuses (`status.json`, burn DOT, cure) — no persistence need (statuses are session state).
- **NEW (this commit): `Game::Bag#to_save` / `Game::Bag.from_save`** — the canonical persisted
  form + strict loader, tested (`test/game/bag_test.rb` ×2): empty bag ⇒ `[]` (= the T1 default);
  same contents in any pickup order / stack split ⇒ byte-identical bytes; loader raises `ArgumentError` on SHAPE only
  (not an Array, bad entry types) and CLAMPS value drift with a printed `save: ...` line - unknown
  catalog id, overflow after a `bag_slots` retune, `qty` ≤ 0, duplicate ids - the P3 churn law of
  `save_state.rb` ("a retune must never brick a save"; landing review 2026-09-06 MAJOR 2).

## PATCH REQUEST → T1 (Gabriel), 3 lines, apply when the record exists
1. **Serialize** (wherever the host character record is written, per player id):
   `record["bag"] = world.bag.to_save` — canonical `[{"id" => <catalog id>, "qty" => <Integer>}]`,
   sorted by id, one entry per id. Default when no world/bag: `[]` (already the spec default).
2. **Load** (character validator / world boot from a record):
   `Game::Bag.from_save(record.fetch("bag", []), catalog: catalog, slots: economy.fetch(:bag_slots))`
   — CHURN LAW (P3, `save_state.rb` "a retune must never brick a save"): unknown ids / overflow /
   `qty` ≤ 0 / duplicates are CLAMPED with a printed `save: ...` line (exactly like level/xp/hp/provisions);
   only a SHAPE error raises `ArgumentError` ⇒ the validator refuses the record (same lane as
   `home_refusal`). `@pinned` (bag-screen pin order) is display state and is not saved.
3. **Wire** (`Game::Loot#init_loot!` today does `@bag = Game::Bag.new(...)`): accept an optional
   loaded bag — `@bag = loaded_bag || Game::Bag.new(catalog: @catalog, slots: @economy.fetch(:bag_slots))`.
   One keyword on `init_loot!(data, seed, bag: nil)`; `World` passes the record's bag when it has one.

Then, on the dev seat (mine), same commit or the next: `test/game/save_state_test.rb` CLASSIFICATION
`"bag"` ⇒ `:persisted` for `contents` (keep `slots`/`used` derived), pin the field in
`test/net/state_digest_test.rb` BAG_FIELDS (unchanged names), delete the NAMED-debt comment.
Canary law is untouched: persistence is outside the sim stream; the canaries run from a fresh world.

## Per-player vs per-pack (the one design fact the seat must not get wrong)
The bag today is **one per pack** (`World#bag`, S2 §2 of the proposal). The T1 record is
**per PLAYER**. In v22 the pack = one player's body set (ONE BODY), so `pack bag` = `host character's
bag` — write it into the HOST's record (`characters[host_player_id].bag`); a guest's record keeps
`bag []` in v22. The split into per-character bags is a **v23 grill item** next to "how the server
splits a coin bank two players earned together" (spec §7) — do not solve it in T1.

## Gate for the landing (integrator)
`bundle exec rake` green · `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run` = ACTIVE ×3 ·
save→load→save round-trip test on a real world with a non-empty bag (add to `save_state_test.rb`) ·
`rake gate` on `loot_loop` + `basement_pocket` (drops/pickup surfaces unchanged — flip guard only).
