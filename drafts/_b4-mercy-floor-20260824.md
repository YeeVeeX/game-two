# B4 — mercy floor (session-open first regrow at the home hub) — SHIPPED s67 (2026-08-24)

Foundation row 9, RATIFIED-G + RATIFIED-J at the v19 foundation; owner
re-cited s66 and greenlit execution live in chat s67 ("dale, arranca
ya"). The session-open farm pain it kills is the owner's own P1 from
the v18 fun-verify (verdict §row 9): "siempre debía matar algunos
enemigos antes de poder revivir a mis compañeros … no creo que debería
al iniciar una sesión" — banked=5 vs a 24+ tribute, testified + decoded
from save bytes.

## Shape picks (dev of record; foundation left floor-vs-discount open)

1. **Guarantee, not discount.** The recorded candidates were "first-open
   regrow discount · a floor that guarantees the first regrow · scaling
   by last-session end". A discount dies on the reported evidence: 50%
   of a 24 tribute is still > banked 5 — the exact reported case would
   still refuse. Picked: the guarantee — the charge clamps to what the
   pack can pay. Corpus touchstone honored (brief §2: failure priced in
   supplies and time, never in progression): mercy still TAKES the
   supplies you have; it never gifts progression.
2. **Context gate (per the foundation sentence):** HOME hub only +
   session-open only. Home = `@home_zone` (the pack's live anchor — it
   advances at hub rehoming, so after a camp/town rehome the mercy hub
   follows the anchor; discovered live: `HOME_ZONE` is nest, NOT camp).
   Field/dungeon vats never clamp. Affordable tributes pay full price
   everywhere — mercy is a floor, not a price cut for the rich.
3. **Armed at boot, consumed by the session's FIRST regrow — wherever
   it happens.** Consuming on any first regrow (not only a mercy-priced
   one) keeps the letter of "session-open first regrow" and closes the
   keep-it-armed-then-die-broke-late exploit. Heal-only tributes never
   consume it (no regrow happened). Never persisted — per-session by
   definition; save schema untouched; lockstep-safe (both sims arm at
   construction, consume deterministically).
4. **Data knob (Rule 3):** `mercy_floor_spend_pct` in
   `data/balance/economy.json` (100 = the guarantee takes everything
   they have; integer floor share of banked; 0 = free first regrow —
   a valid future owner retune, pinned as a data law in
   economy_data_test).
5. **The line-cap extraction rides the touch (world.rb was 1787/1800):**
   the vat price formula existed TWICE (PriceSheet quote + interact_vat
   charge — a real drift bug waiting once prices went contextual).
   Consolidated: `PriceSheet#vat_quote(zone)` is now the ONE vat-price
   source; `interact_vat` charges what the sheet quotes, so the renderer
   hint can never disagree with the charge. world.rb closes at 1793
   (wiring only: arm ivar + mercy lambda + consume line; all pricing
   logic lives in the plain object).

## Evidence

- Suite 1189 → **1196** green (7 new: mercy charge/consume/no-discount/
  heal-only/field-refusal/quote-surface/pct-knob; the old
  short-refusal test rewritten onto a FIELD vat — its fresh-world
  scenario at the home vat IS the mercy context now).
- Sim identity: suite-pinned canaries (world_loop/varekka_duel/
  burn_duel) untouched; `vat_economy` headless EVENT md5
  `61d768b8…` byte-identical pre/post (its replay never stands
  short-with-corpses at the home vat — mercy is unreachable there).
- **Wall script 28: `harness/scripts/mercy_floor.json`** (staged
  `start: {banked: 5, dead: 2}` via a new harness-only `dead:` staging
  key in `Harness.apply_start` — same take_hit path combat uses).
  Captures: frame_0080 = vat quoting **-5** (mercy price; base 24)
  with two dead HP bars; frame_0130 = three live bars, banked 0, hint
  gone. Replay events: `banked_spent amount=5 sink=tribute banked=0` +
  `tribute_paid cost=5 regrown=2 healed=0 banked=0` at frame 90.
- **Rule 2 gate: PASS** (double replay, 3 captures byte-identical ×2
  runs; vision checklist all-PASS) — appended to
  `drafts/_gate-verdicts.log`.

## Field notes

- First hand-authored hold overshot the vat (40f = 3 walker windows →
  the body sailed THROUGH the station tile; the pilot-reel lesson
  applies to wall scripts too). 22f lands exactly.
- Junior async ratification of the SHIP (not the shape — the shape was
  foundation-ratified) travels with tonight's ledger.
