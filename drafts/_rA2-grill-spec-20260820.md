# R-A2 — sustain discoverability: grill spec + tickets (2026-08-20)

Route P1 of the post-T1 router spark (`drafts/_post-t1-router-spark-20260820.md`).
Dev of record: Gabriel's hub seat. v18 CLOSED; this is the verdict's RECORDED
item R-A2 (row 4, TRIGGERED hard), presentation FIRST — the price debate stays
at the brainstorm.

## Problem (verdict §row 4)

`sustain bought=0` on 4/4 ritual lines; owner P3 "cuales provisiones?";
Junior pre-registered "não entendeu o que a provisão era"; two `refused=1`
events in session 2 with NO reason logged. The owner's question is BURNED as a
measure — the next measure is BEHAVIOR (`bought>0` in future session lines).

## Grill answers (each cited)

**Q1 — where does a player LEARN provisions exist today? NOWHERE until one is
owned.** The strip's sustain pair + the `PROVISION n` counter render ONLY while
`provisions > 0` (decision 7iii, `src/app/controls_overlay.rb:55-58,72-78`).
The bank station shows only the banked numeral (`src/app/renderer.rb:393-413`
`draw_station_ledger` — altar/vat get `-price`, the bank branch does not). The
refusal cue is a generic "REFUSED" X-bar (`renderer.rb:430-441`,
`cue.provision_refused`). Net: the ONLY discovery path is an accidental U/R
press, which at 0 stock off-bank refuses `:none` → generic REFUSED — exactly
session 2's two unexplained refusals. Chicken-and-egg by construction.

**Q2 — smallest visible exposure that plausibly changes behavior?** A
bank-adjacent BUY hint: `U PROVISION -5` (glyph + the ratified `hud.provisions`
word + the established `-price` grammar from altar/vat), drawn in the station
cue's text slot (y-32) above the bank tile, ONLY when a buy would succeed:

- body within Chebyshev 3 of a bank (the ledger's own radius + its "I'm at it"
  rationale, `renderer.rb:385-391`)
- `banked >= provision_cost` AND `provisions < provision_cap`
- suppressed while a station cue lives on that bank tile (the transaction
  receipt owns the slot; hint returns when it expires — a teaching loop)

Why this beats the verdict's literal "controls strip" suggestion, argued:
(1) **Eye-line**: the player's eyes are AT the bank tile when banking — they
demonstrably read the banked numeral there (owner reports banked totals in
ritual answers). A 7th subdued pair appearing at the screen-bottom strip is off
the action's eye-line. (2) **Touchstone**: Tibia's sustain is legible because
stock + spend are visible AT the point of action (corpus brief §1: Supplies
rise 1,091,030→1,091,680 while Balance falls 3,784,639→3,778,789 in one fight
window — "combat has a visible gold cost per second"; shape evidence only,
never numbers). The hint puts verb + price at the vendor, Tibia-style.
(3) **Decision 7iii stands**: the strip's provisions>0 gate is a RECORDED wall
pin; reversing it re-pins every capture's strip line in all 18 scripts.
(4) **Teaches success, not failure**: shown only when the buy would succeed —
never advertises a verb that refuses.

**Q3 — which wall scripts' captures change? COSTED, not guessed.** Critical
finding: camp `pack_spawn` (10,5) and nest spawn (14,8) are Chebyshev-2 from
their banks (8,4)/(12,8) — INSIDE radius 3. An unconditional hint would change
frame 1 of nearly every script (near-strip-level cost). The `banked >=
provision_cost` condition makes spawn frames byte-identical (banked=0 at
start). Only scripts that accumulate banked≥5 with a body near a bank move.
Exact set determined EMPIRICALLY: pre-change baseline sweep (one replay per
script → md5 manifests, `tmp/rA2_base/`) vs post-change sweep; every diffed
script owes the full Rule 2 gate. `sustain_run` moves by construction (10 buys,
4 uses, 6 refusals in its manifest) and carries the surface's own targeted
critique.

**Q4 — what must the refusal log discriminate?** The five reason symbols that
already exist at the refusal sites: `:at_cap`/`:broke` (buy,
`src/game/pack.rb:72-77`), `:none`/`:no_effect` (use, `pack.rb:83-90`),
`:seat_race` (same-tick latch, `world.rb:599`). The event already carries
`reason:` (`world.rb:1365`); telemetry drops it today (`telemetry.rb:284`).
Line gains a fixed-order brace block (house style = `ends{...}`):
`TELEMETRY sustain bought=N used=N refused=N reasons{at_cap=A broke=B none=C no_effect=D seat_race=E}`.
Append-only: `sustain_test.rb:221` (assert_match on prefix) survives;
`telemetry_test.rb:55` (assert_equal, full summary) must be updated.
`soak/chain_check.rb` has zero sustain regex — verified safe. Manifest checker
counts event names in teed logs; reason tokens never collide with event names.

## Non-goals (named, out of scope)

- Provision PRICE/effect/cap values — `data/balance/economy.json` untouched
  (recorded brainstorm debate; measure-before-tuning).
- Strip decision 7iii — untouched (recorded, and the wall cost is the point).
- Refusal CUE text stays generic "REFUSED" — the verdict's sub-item asks for
  the reason in TELEMETRY only; a per-reason cue is scope creep with real wall
  cost. Revisit only if refusals persist AFTER exposure ships.
- Vat/use-side hint — the strip row already teaches "use" once provisions>0.
- R-A1 respawn scalars, R-A3/R-A4 (frozen), any sim-class change.

## Escalation path (recorded, not implemented)

If a later session still shows `bought=0` with the hint live, the recorded next
step is the strip escalation (always-on sustain pair) — full-wall re-pin,
priced above.

## Tickets

### Ticket A — bank BUY hint (code + strings-reuse; Rule 2 + wall diff owed)

- **Files**: `src/game/world.rb` (+2 public readers `provision_cost`,
  `provision_cap` — data passthrough, Rule 3), `src/app/renderer.rb` (store
  `@bindings`; pure content method `sustain_hint(world, station)` → string or
  nil; draw call in `draw_station_ledger` bank branch at y-32, `hud_font`,
  `DROP_CORE`), `test/app/` new hint test (pattern:
  `station_cue_text_test.rb` — pure method, headless), `test/game/` reader
  asserts folded in.
- **Strings**: ZERO new keys — compose `"#{glyph} #{t('hud.provisions')} -#{cost}"`
  from the ratified locale trio (PROVISION / PROVISIÓN / SUPRIMENTOS); glyph =
  `bindings.glyphs(:sustain).first`, Renderer-local fallback `"U"` (the
  VESSEL_FALLBACK precedent). Locale-invariant glyph + numeral; only the noun
  translates — placeholder register preserved.
- **Verify (its own step)**: TDD suite green → post-change sweep
  (`tmp/rA2_after/`) vs baseline (`tmp/rA2_base/`) → diff names the moved set →
  full `rake gate` per moved script (detached, judged by rc lines) → ONE
  targeted vision critique of sustain_run's hint frames via `CHECKS=` custom
  checklist (hint visible when affordable / absent at spawn / receipt
  suppression / legible) → language critique of the 3 rendered lines
  (accuracy vs presentation, separate axes) — BLOCKING.
- **Done**: all moved scripts PASS the gate; targeted critique PASS; language
  critique PASS; suite green.

### Ticket B — telemetry refusal reasons (log-only; no wall debt)

- **Files**: `src/game/telemetry.rb` (subscriber takes payload, per-reason
  counts; `sustain_summary` gains fixed-order `reasons{...}`),
  `test/game/telemetry_test.rb` (pinned summary updated),
  `test/game/sustain_test.rb` (extend to assert reasons split).
- **Verify**: TDD (red first on the new assertion) → `bundle exec rake` green.
  chain_check regex audit already done (no sustain pattern).
- **Done**: suite green; line shape documented here; zero capture bytes moved
  (log-only — no gate).

Order: B first (independent, no wall interplay), then A while the baseline
sweep finishes.

## Ship discipline

One-concern commits (B, then A). Fresh-eyes review (scrubbed pi, diff + this
file) BLOCKING before push; receipt in `drafts/_rA2-review-20260820.md`.
Checkpoint + owner queue es-CR (everyday gamer words) + push. Budget: grill
half spent as declared; implementation ≤ grill; gates detached.
