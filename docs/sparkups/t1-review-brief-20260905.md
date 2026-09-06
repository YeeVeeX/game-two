# T1 fresh-eyes review brief (staged s133; run by a context that did NOT write T1)

Usage (from the T1 session, after the suite is green and BEFORE push):
`cd <repo>; git diff <base>..HEAD > tmp/t1/diff.patch` then launch a headless scrubbed pi
(detached; PI_* unset; `--no-session --thinking max --tools read,bash`) with THIS file and
the patch path as the prompt. Its final message must be the verdict block below.

## You are
A skeptical staff engineer reviewing a SAVE MIGRATION in a deterministic-lockstep coop
game (Ruby). Default to REJECT when uncertain. Read only. Touch nothing. Quote lines.

## Ground truth to read (in this order)
1. `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md` §1 (laws) and §3 T1 (the
   ticket, with its `[council s133]` amendments).
2. `drafts/_v22-foundation-20260905.md` L9 (save-chain law), L20 (server-ready laws 1-7).
3. The diff (`tmp/t1/diff.patch`) and the CURRENT files it touches: `src/game/save_state.rb`,
   `src/game/character.rb`, `src/game/progression.rb`, `src/core/data_store.rb`,
   `src/net/fingerprint.rb`, `src/net/protocol.rb`, `src/net/session.rb`,
   `src/app/player_file.rb`, `src/game/world.rb` (`digest_snapshot`, `apply!` callers),
   `data/balance/progression.json`, `.gitignore`, and every test the diff adds or changes.
4. The ticket record `drafts/_v22-t1-record-<date>.md` (proofs pasted there).

## Two-way alignment (report gaps BOTH ways)
A. Requirement -> check. For EACH row, VERDICT (MET / NOT MET / UNCERTAIN) + the line:
   1. `SCHEMA = 3`; schema 1 refuses NAMED ("save schema: 1 unsupported (expected 3)");
      `upgrade_v1` and `V1_FACT_KEYS` deleted; any unknown key/shape refuses NAMED with the
      offending path in the text.
   2. `characters` keyed by player id (never seat); record shape exactly as the ticket
      (level, xp, xp_debt, insurance, home_zone, form, forms{kit->{hp,inscribed}}, bag,
      equipment, attributes, bank_items); Junior's keys default EMPTY; validator accepts
      absent optional keys = default; CLASSIFICATION rows pin every key's status.
   3. Integer-only: `xp < dE(level+1)` per character; `xp_debt >= 0`; insurance within
      `death.json` cap (or the ticket's stated interim cap); `home_zone` hub-only via the
      character validator (old `home_refusal` retired or moved, not duplicated).
   4. `data/player.local.json`: machine-written on first boot, uuid v4, lenient-NAMED
      reader (corrupt -> regenerated + printed line, never a brick), listed in
      `DataStore::MACHINE_WRITTEN` AND `Fingerprint::EXCLUDED`, gitignored; bots/harness
      use `bot-<seed>` deterministic ids; the id is never shown on a surface.
   5. HELLO carries `player_id`; `Fingerprint.mismatch` compares the five build fields
      ONLY; equal ids refuse NAMED ("player id collision ...").
   6. Migration 2->3 is ONE hop: host character from progression + members + home_zone;
      `migration {from_schema, legacy_level, legacy_seed_claimed_by}` block written;
      `--fresh` creates a NEW host character with NO migration block; backup `.bak-<ts>`
      is written BEFORE the first schema-3 write (prove from the record's paste).
   7. Guest record created DETERMINISTICALLY ON BOTH SEATS at session start from HELLO +
      SESSION facts; legacy seed claimed by player id once; read-only mirror rule for
      guest level/xp until T2b, test-pinned; both digests equal from tick 0.
   8. `Character#digest_fields` per character in SORTED player-id string order enter
      `digest_snapshot`; `state_digest_test` pins them; nothing presentation-only enters.
   9. Bridge: `apply!` rebuilds today's three-body pack losslessly from the host
      character's `forms`; seat pointers unchanged; the field plays as before.
  10. Proofs in the record: copies of BOTH chains (or the recorded gap + synthetic v2/v1),
      `--fresh` backup, `rake soak SEED_SAVE=1 N=1` tail, netplay gate verdict, canary
      UNCHANGED (no rebank), suite line `N runs, 0 failures`.
  11. Fences: no surfaces/HUD/field behaviour; live save never read or written by the
      proofs; `data/zones/**` untouched; `world.rb` net lines <= 0.
B. Check -> requirement. List every test/assertion the diff adds that traces to NO row
   above (scope creep or hidden behaviour) and every new code path with NO test.

## Also answer
- Lockstep: any new code path that reads wall clock, Float, per-machine state, or
  hash-ordering of an unsorted collection into a sim fact or the digest? Quote it.
- Refusal completeness: name one malformed schema-3 file the validator would ACCEPT.
- The biggest risk the ticket did not name.

## Output contract (final message, nothing after it)
```
T1 REVIEW -- HEAD <sha> -- VERDICT: PASS | BLOCK
A. <11 rows: n. MET/NOT MET/UNCERTAIN -- file:line -- one clause>
B. untraced checks: <list or none> · untested paths: <list or none>
Lockstep: <finding or none> · Accepts-malformed: <example or none> · Biggest unnamed risk: <one sentence>
BLOCK reasons (if any): <numbered>
```
