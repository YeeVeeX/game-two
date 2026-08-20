# Spark — game-two intake of gamesmith Round 7B (bank + deduplicating triage; no active task)

> Banked VERBATIM from the hub chat at session-24 close (2026-08-20) so the
> executing session has the full text on disk — it arrived only in chat.
> Everything below this note is the gamesmith seat's spark, unedited.

---

**Seat:** `game-two`. Run ONLY in a fresh session whose cwd is
`C:/Users/gabri/workspace/game-two`, after the current game-two session has closed and released
the seat. **Authorization:** owner, 2026-08-20 — approved proceeding to the next bounded session;
Round 7B itself was approved, completed, committed, and pushed in gamesmith.

## Mission

Bank the completed gamesmith Round 7B evidence document into game-two using the existing ignored
addenda/provenance pattern, then create a tracked four-row intake triage and ONE concise
`PARKING_LOT.md` pointer. Record the intake at the top of `docs/CHECKPOINT.md`, commit, and push.

This is **docs-only evidence intake**, not implementation and not a v19 brainstorm. It must not
reopen v18, alter the current audio/coop queue, promote a mechanic, change telemetry, or adopt any
gamesmith FR. The source explicitly says no game-two demand existed; preserve that fact.

## Critical preflight — before any write

1. Read this repo's live `AGENTS.md` completely, then the top of `docs/CHECKPOINT.md`. Live local
   law beats this spark.
2. Run `fleet`. The `game-two` seat must be FREE. If held, STOP with `SEAT CONFLICT`; never route
   around it and never `/seat take` unless the user has explicitly closed the holding session.
3. Run `git status --short --branch`. The tree must be clean. At spark-design time another session
   owned dirty audio work (`data/audio/cues.json`, `src/app/audio_bridge.rb`, tests, and drafts);
   those are FOREIGN work. If anything is dirty now, STOP and print the paths — do not stash,
   discard, commit, or edit them.
4. `git pull --ff-only` FIRST. If it cannot fast-forward cleanly, STOP; do not improvise a merge.
5. Re-read the top checkpoint after pulling. Confirm v18 remains closed, v19 remains owner-gated,
   and this intake does not displace the live queue.

## Source identity — md5 is the arbiter

Read the source with the **read tool**; never write into the sibling gamesmith tree.

- Source: `C:/Users/gabri/workspace/gamesmith/docs/round7-synthesis-threads.md`
- Source commit: `c4e49f38da175fba4f22397886a8c7686f55d1ac`
- Required md5: `8f0ac085bf77f5a00b9def7f40454049`
- Source HTML exists gamesmith-side with md5 `0a8f9c2f62a59ec3b5fa46f6b358247f`, but do **not** copy it;
  game-two's addenda precedent banks Markdown only.
- Current gamesmith bundle cited by the source: GATE-4 output digest
  `e7fb58cfafd23b019f3802e2e6f8047648c9ab44820f174103eaaf86933a53d1`.

Verify the source md5 before any edit. A later gamesmith HEAD is acceptable only if this file's md5
still matches. On mismatch, STOP and report; do not adapt silently.

## Idempotency / backfill check

Round 5 is ALREADY banked. Verify, do not replay it:

- `docs/design-corpus/gamesmith/addenda/round5-synthesis-threads-20260819.md`
  md5 `a044f986fa3fbebdd1bdc8481939a41c`;
- matching `_PROVENANCE.md` block;
- existing `PARKING_LOT.md` entry `Corpus round-5 synthesis threads`.

If those are absent or drifted, STOP and report an intake-state mismatch. Round 5/6 repair is out
of scope.

For Round 7, first check whether all of these already exist and agree: target copy, provenance
block, triage doc, PARKING pointer, checkpoint entry. If complete and digest-correct, make no
changes and print an `ALREADY COMPLETE` receipt. If partially present, reconcile only when every
existing byte/claim matches this spark; otherwise STOP rather than overwriting ambiguous work.

## Action 1 — immutable addendum copy (ignored by design)

1. Read the source file via the read tool and write it byte-identical to:
   `docs/design-corpus/gamesmith/addenda/round7-synthesis-threads-20260820.md`.
2. Verify target md5 equals `8f0ac085bf77f5a00b9def7f40454049`.
3. Read-before-edit
   `docs/design-corpus/gamesmith/addenda/_PROVENANCE.md`, then append one provenance block in its
   established voice containing:
   - target filename and delivery date;
   - "round-7B gamesmith synthesis product ($0 pipeline), owner-fired corpus completion — NOT part
     of game-two's approved/frozen GATE-4 handoff digest";
   - source path, source commit `c4e49f3`, source md5, and byte-identical verification date;
   - completed 13-game corpus; four standing threads 4/6/7/8; no game-two pull manufactured;
   - FR ids are gamesmith provenance and non-binding here;
   - NW-Aeternum material is explicitly a reference study outside the 13-game corpus;
   - source bundle title split: `spec.md` = Lanternvale, `direction.md` = MARROWFEN; do not resolve
     it locally;
   - footage/rules/reference evidence is era-tagged, never current-game truth, never redistribute;
   - ignored/untracked by design; committed citation lives in the triage + PARKING pointer.
4. Verify both addenda paths are ignored with `git check-ignore -v`; never force-add them.

## Action 2 — tracked deduplicating triage

Create `drafts/_gamesmith-round7-intake-triage-20260820.md`.

Required header facts:

- owner authorization and source commit/md5;
- current game-two state read from live AGENTS/checkpoint;
- this is banking, not adoption; active queue unchanged;
- no gamesmith FR binds game-two; no tuning number transfers;
- title split and NW-reference provenance caveats;
- the source's citation gate: 96 obs + 4 say, zero dangling/malformed/alias leaks.

Required table columns: `Thread | Corpus answer | Existing game-two overlap | Disposition | Named trigger`.
Use exactly these dispositions unless live local law materially conflicts (then STOP):

1. **T4 front events — BANK / NO ACTION.** Corpus has staging grammar but no observed payoff
   baseline; current gamesmith bundle does not carry front events as a named system. No code or
   v19 idea is created. Trigger: an owner-opened world/front-event design debate explicitly asks
   for this evidence.
2. **T6 screen-event cap — DEDUPE / BANK METHOD.** The qualitative readability finding was already
   consumed through Itexo triage 2.9. Bank the deterministic replay-sweep method only; do not
   invent a cap and do not create a duplicate wall task. Trigger: a named target-renderer surface
   needs a numeric event budget; its own replay captures must produce the number.
3. **T7 instrumentation corrosion — BANK / ZERO TELEMETRY CHANGE.** v18 instrumentation is closed
   and pre-registered. The register/diagnose/steer taxonomy is evidence for a future debate only.
   Trigger: the owners explicitly open an instrumentation/overlay decision.
4. **T8 DaD wager map — DEDUPE / BANK MAP.** The existing `Session-ledger / carried-fact shape`
   entry already carries the closest active overlap. Bank the observed-vs-[SYNTHESIS] map; adopt
   no current gamesmith FR and create no economy/death task. Trigger: an owner-opened
   death/economy/session-loop debate asks for the full map.

End with an explicit **No action owed now** section: no code/data/harness/audio changes, no v19
promotion, no re-handoff, no pipeline spend, no lore, and no change to the live queue inherited
at preflight (design-time queue: cue duplication → ducking → Junior coop).

## Action 3 — ONE PARKING_LOT pointer

Read `PARKING_LOT.md` first. Insert the following block immediately after the existing
`Corpus round-6 demand adjudication` entry and before the next section. Do not anchor an edit on
a section header, and do not alter/reflow existing entries.

```markdown
- **Corpus round-7 completion threads (gamesmith, 2026-08-20) — evidence pointer, no active
  task.** Owner-fired completion against the finished 13-game corpus; no game-two demand was
  manufactured. Dispositions: T4 BANK/no payoff baseline; T6 DEDUPE the already-consumed
  readability finding and bank only the target-renderer replay-sweep method; T7 BANK with ZERO
  change to closed v18 telemetry; T8 DEDUPE the existing session-ledger pointer and bank the full
  wager map. Gamesmith FR ids remain provenance-only and bind nothing here; no tuning number
  transfers. Evidence:
  `docs/design-corpus/gamesmith/addenda/round7-synthesis-threads-20260820.md`
  (source: gamesmith `docs/round7-synthesis-threads.md` @ `c4e49f3`, md5
  `8f0ac085bf77f5a00b9def7f40454049`). Intake dispositions:
  `drafts/_gamesmith-round7-intake-triage-20260820.md`. Mechanics only; no-lore order respected.
```

Gate: `git diff -- PARKING_LOT.md` must show exactly this one insertion and no reflow.

## Action 4 — checkpoint, review, commit, push

1. Add a compact top entry to `docs/CHECKPOINT.md` using the next truthful live session label:
   - Round-7 source/copy md5 and ignored-addenda provenance;
   - four dispositions in one compact line;
   - Round 5 verified existing, not replayed;
   - active queue unchanged; v19 not opened by intake;
   - review/gate/commit receipt.
2. Human-facing text gate (Rule 2/6): Kimi critique of the exact triage + PARKING + checkpoint
   diff, scoring **accuracy and presentation separately** and quoting every defect. Council budget
   ≤$0.20 total; at most two Kimi calls, second only if the first BLOCKs after genuine fixes.
   Reverify every REFUTED claim against the primary files; models fabricate. Stop after SHIP or
   after two calls — never weaken the gate.
3. No visual gate is owed: no player-visible surface changes. No manual code edits or tests.
   Let the repo's pre-commit and pre-push hooks run `bundle exec rake`; never bypass them.
4. Before commit verify:
   - source md5 == target md5;
   - Round 5 existing target still matches its pinned md5;
   - `git diff --check` passes;
   - tracked diff contains ONLY `PARKING_LOT.md`,
     `drafts/_gamesmith-round7-intake-triage-20260820.md`, and `docs/CHECKPOINT.md`;
   - ignored addendum/provenance are not staged;
   - active queue wording is unchanged except the checkpoint's intake record.
5. Stage explicit tracked paths only; never `git add .` / `-A` and never force-add ignored files.
6. Commit message:
   `docs(intake): bank gamesmith round-7 synthesis threads`
7. If remote moved after the initial pull, run `git pull --rebase`; on conflict STOP and report.
   Then `git push`. Verify local HEAD equals upstream HEAD.

## Receipt back to gamesmith

After a successful push, write a short receipt to
`C:/Users/gabri/.pi/agent/mail/gamesmith/from-game-two-round7-intake-receipt.md` and print this
as the final line:

`RECEIPT: game-two round7 intake commit=<hash> | source_md5=8f0ac085bf77f5a00b9def7f40454049 copy_md5=8f0ac085bf77f5a00b9def7f40454049 | provenance=updated-ignored | triage=drafts/_gamesmith-round7-intake-triage-20260820.md | PARKING_LOT=+1 | checkpoint=+1 | round5=verified-existing | active_queue=unchanged | hooks=<pass> | drift=<none|details>`

## Hard stops / out of scope

STOP without writing if: seat held; tree dirty; source/target digest mismatch; Round-5 bank drift;
live local law conflicts; pull/rebase conflict; text gate remains BLOCK after two calls; or a hook
fails.

Never touch the active cue-duplication/ducking/coop work, code, data, tests, harness, audio,
AGENTS.md, gamesmith artifacts, paid pipeline commands, lore, v19 scope, or the frozen gamesmith
bundle. Do not re-bank rounds 5/6 and do not re-handoff the synthesis bundle.

---

> Hub-seat notes at banking time (session 24, not part of the gamesmith text):
> the "design-time queue" its preflight names (cue duplication → ducking → coop)
> SHIPPED in session 24 — the live queue at execution time is the session-25
> spark's; "unchanged" means THAT queue. Spot-verified at banking: Round-5
> addendum md5 `a044f986fa3fbebdd1bdc8481939a41c` ✓, PARKING_LOT anchors
> `Corpus round-5` (line ~54) + `Corpus round-6` (line ~74) both present.
