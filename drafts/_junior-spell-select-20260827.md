# J-T6 — Spell-select / loadout layer, paper design (Junior seat, 2026-08-27)

Owner-released batch (2026-08-27). Answers pre-grill open question 4
(slate candidate 6 fence): "more verbs need a spell-select/loadout layer
(input design, J-6 family) before data rows." Grounded in the measured
substrate (`drafts/_v20-pregrill-evidence-20260827.md` §1: 13 actions
bound · 28 free key names · digit row 1-5 entirely free · clean pairs
scarce-not-exhausted). Paper-only: input/UI design, zero spell content,
zero numbers. I shipped the J-6 menu chassis (settings/volume rows), so
this is designed against the REAL menu architecture, not a sketch of it.

## 0. The problem shape

Today each kit has ONE special (L/E). Candidate 6 wants spell breadth.
Three input strategies exist; the fence says pick the LAYER before any
spell data lands. The constraint is NOT keys (28 free) — it is:

- **hand economics:** shipped scheme pairs right-hand primary +
  left-hand-near-WASD secondary; clean pairs remain but are scarce;
- **legibility:** controls strip renders every action (Rule 2 surface;
  every new action = strip growth + i18n ×3 by construction);
- **the non-pausing law:** the menu never pauses the world (J-6
  foundation) — any in-menu picking costs REAL TIME, which is a design
  feature to spend deliberately, not an accident.

## Strategy 1 — DIRECT DIGIT BINDS (Tibia hotkey model)

Each learned spell binds to 1-5. For: zero selection latency; the digit
row is free; Tibia lineage. Against: 5 new ACTIONS on the strip (growth
on the game's tightest visual surface); digits are far from WASD (hand
travel mid-fight); rebind UI is parked so bad defaults are forever-ish;
scales worst (spell 6 = new key).

## Strategy 2 — LOADOUT: one SPECIAL slot, menu-picked (recommended)

The special key (L/E) stays THE cast button; which spell it casts is a
LOADOUT choice made in the non-pausing menu (new SPELLS screen, or rows
on the existing root). Possession-native: each pack body carries its own
loadout — swapping bodies (Tab) IS the mid-fight spell swap, which the
game already teaches.

- Strip cost: ZERO new actions (L/E already rendered).
- Menu cost: one screen in the shipped chassis — exactly the settings/
  volume pattern I built for J-6: pure state resolution, draw_model
  rows, edge-nav, prefs-style selection commit. Same test lanes, same
  gate row shape (`menu_settings_reads` precedent).
- Non-pausing synergy: changing loadout mid-fight costs real seconds —
  preparation becomes a decision (the D0 "bank or push" tension family).
- Persistence: loadout is SIM state (it changes what the sim casts) —
  it belongs in the SAVE, not prefs.local (netplay/digest implication:
  one schema row, named for the grill — the J-6 prefs lane proved the
  machine-local path; this is deliberately the OTHER path).
- Scales: spell 6+ = a row, not a key.

## Strategy 3 — CAST MODIFIER (aim-style overload)

Hold aim (Ctrl) + special = secondary spell. For: zero new keys, zero
strip actions (one glyph amendment). Against: hidden-input problem (the
strip can't teach a chord cleanly); caps at 2 spells/kit; collides with
aim's actual job the moment ranged kits aim-and-cast. Honest ceiling:
a stopgap, not a layer.

## Comparison (grill's one-look)

| Axis | S1 digits | S2 loadout | S3 modifier |
|---|---|---|---|
| New strip actions | +5 | 0 | 0 (glyph edit) |
| Selection latency | none | menu seconds (real time) | none |
| Scale ceiling | ~5 | unbounded | 2 |
| Hand economics | poor (digit reach) | unchanged | good |
| Save/netplay touch | none | one schema row | none |
| Teaches through | strip | menu + swap (shipped verbs) | nothing (hidden) |
| Chassis reuse | low | HIGH (J-6 exact) | low |

## Seat recommendation (defended, not decided)

**S2 loadout.** It spends the menu chassis the project already paid for,
keeps the strip byte-stable, makes possession (the game's identity
mechanic) the mid-fight spell-swap verb, and scales past this cycle.
S1 is the right answer only if the grill wants ZERO selection friction
as a design value (Tibia purism); S3 is a stopgap that spends the aim
key's clarity. Hybrid worth naming: S2 now, S1 later as OPTIONAL
quick-slots once rebind UI unparks — they compose (digits would just BE
loadout shortcuts).

## Open forks for the grill

1. Loadout scope: per-BODY (my draw — possession-native) or per-PACK
   (simpler save row, weaker identity)?
2. Where spells COME FROM (learn on level? find? buy?) — candidate 6
   content design, entirely out of this doc's scope, needed before any
   build ticket.
3. Save-schema row for loadout: rides which build ticket, and does the
   coop handshake fingerprint it (it must — sim-affecting)?
4. SPELLS screen placement: root row (RESUME/STATS/SPELLS/...) vs
   inside SETTINGS (my read: root — it is play, not preference).

## Freeze-hygiene statement

Paper only. Bindings/key-table/menu/strip read for measured facts (all
already banked in the s96 evidence file); no edits anywhere; §9 unread;
zero spell content or numbers; save-schema implication NAMED, not built.
