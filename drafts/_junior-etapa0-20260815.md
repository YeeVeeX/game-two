# Etapa 0 — Junior's replay exchange + cross-machine determinism evidence (2026-08-15)

> **RE-RUN AT THE RESOLVED LINE (2026-08-16, the owner checkpoint's
> explicit ask):** the md5 blocks BELOW this note were computed against
> the pre-race Junior-seat line and are history only. The valid exchange
> set for the v17 trigger is THIS one, computed at junior-tibia
> `9b755dc` (the two-seat-resolved line, owner implementation):
>
> **world_loop** (`captures/world_loop`):
> ```
> 487e2a946a60314491c6712906bc618e  frame_0000.png
> d4ce27adb3a44cc7fb9ede8d9252cdb5  frame_0300.png
> 3e3733be06abd33fd501e3692fcc63a0  frame_0303.png
> 1184c150976042664c0dc5ab54057b1d  frame_0397.png
> 09d1ad1107c92c0b9477b51e42c15a51  frame_0431.png
> ef1cc0a8e8c2601fac1b00cca406e1d9  frame_0441.png
> b85db3188e08aaf461afb4e35e6c3f86  frame_0701.png
> 1284dddfca221ecb4532b339fe878165  frame_0805.png
> c197efb9f98cc857dd1602dd6a155bd5  frame_0983.png
> b84b544c4ff75f628e9e3ebd5def6729  frame_1248.png
> ```
> **varekka_duel** (`captures/pilot/quay9_r2_replay`):
> ```
> 8bcf0814fc60d7b47ea6cb1bfc07bf60  frame_0149.png
> d60d5e8989487c8d662ec615ef249ca2  frame_0937.png
> 8f7fa75d447b25057804bbe14052ed9d  frame_0998.png
> 93ac09ea5a9542de80ba6376a2f4842c  frame_2578.png
> 596daa3b499025501e69a7e5079722af  frame_2682.png
> ```
> **burn_duel** (`captures/pilot/burn_duel`):
> ```
> 3c00ac5691f950e38eeeb1410d21f40a  frame_0420.png
> 6bbb57fde8aa81fab084cd12c1665286  frame_0485.png
> 4f313f5d9a3e56150c0bd6fcb842b2bd  frame_0495.png
> 35aa779a62ae4ac41df28394be39e999  frame_0535.png
> cc6af2ab7be36644ff627ca29ebb106a  frame_0634.png
> af2b96c40c4558c6c20bb3e39f932ff2  frame_0700.png
> ```
> Same machine facts as below (Ruby 3.4.10 exact, gosu 1.4.6). All
> three replays REPLAY_DONE with telemetry identical to the owner-seat
> wall (varekka_duel: chants=3 interrupted=2 seized=1 zone_left=1).
> Owner: run the same three captures on your seat and diff — a match =
> the stage-1 cross-machine spike CONFIRMED on the line that ships.

The STRICT form of v17 trigger #1 (async replay exchange through the
repo, `docs/JUNIOR.md`): Gabriel's canonical replays reproduced on
JUNIOR'S machine, per-frame md5 published here so the owner seat can
verify byte-identity without a shared session — this doubles as the
multiplayer stage-1 spike evidence (same seed+inputs on two PCs →
identical frames; the pre-registered risks were exact Ruby version,
float ops, hash-iteration order).

## Machine (Junior)

- Windows 10 Enterprise LTSC 2021, `C:\Users\jr\Desktop\game-two`
- ruby 3.4.10 (2026-06-30 revision 2b0b7728dc) +PRISM [x64-mingw-ucrt]
  (exact match with the dev machine's pinned 3.4.10)
- gosu 1.4.6 (Gemfile.lock), bundle install clean
- Build: junior-tibia HEAD `4c988ba` + the PT-BR pass (this commit) —
  strings do not affect captures (harness pins locale=en)

## world_loop (`harness/scripts/world_loop.json`, 10 captures)

```
cfeda0c13212495ec1f4596eb716aed7  frame_0000.png
6a512e6ef61d3fab93f9a7d7a59e1dec  frame_0300.png
b9af4dba2415d6be593fbfce0552b712  frame_0303.png
639ad7c76301b9bf6e2b0ce4eb541733  frame_0397.png
e1381ff019c6464d1d9467fc8cc6760d  frame_0431.png
2c214b4761c4cc24f56e540f3c45c51a  frame_0441.png
da003b31d3aa8943d3c9c409c23d7636  frame_0701.png
e833f8f89a956bf364a8b5762a80c0d4  frame_0805.png
e173d479a7c7cf50b64d37c0172dd3ab  frame_0983.png
3b076a92da8edc24e833ad4f206e7981  frame_1248.png
```

## varekka_duel (`harness/scripts/varekka_duel.json`, 5 captures)

```
cac30e8b06e3e0667acdad4e30f94976  frame_0149.png
10094a099647e62fc0f663e4513f907e  frame_0937.png
24fe8846daed648a1d499443e3aefd7b  frame_0998.png
5b03aec402eccf26d5ab5cc9a3398fd8  frame_2578.png
054c9a30c9ce092d2864e5f3082b8bd2  frame_2682.png
```

## To verify on the owner seat (one command each)

```
rake capture SCRIPT=harness/scripts/world_loop.json
rake capture SCRIPT=harness/scripts/varekka_duel.json
md5sum captures/world_loop/*.png captures/pilot/quay9_r2_replay/*.png
```

Hashes match → cross-machine determinism CONFIRMED on real hardware,
stage-1 spike burned down without a live session. Hashes differ → the
divergence is the v17 work item (bank the diff, don't average it).

## Session evidence already on file

Junior's first live session (telemetry + structured answers):
`drafts/_junior-first-session-20260815.md`. PT-BR post-edit pass
ratified by Junior same day (this commit): strip labels harmonized to
infinitives (atacar/esquivar/marcar — mirrors the ratified ES), The
Longrow PT "O Corredor" → "A Rua Longa" (the corridor collision with
A Porta Lenta undone; mirrors ES "La Rúa Larga"), payment stamps and
UM SE PLANTA ratified as-is. stamp.mark_void PT-BR deliberately
DEFERRED — the pipeline law says Junior post-edits from brief +
RATIFIED ES, and the ES waits on the owner's language lane.

> **OWNER-SEAT COMPARISON RESULT (2026-08-16, this seat):** the RE-RUN
> md5 blocks above were diffed against this machine's wall gate captures
> (same scripts, same frames, same code line): **0/21 files
> byte-identical.** This is the EXPECTED result and it retires the
> instrument, not the claim: PNG bytes are machine-local (Gosu::Font
> rasterizes through the host font stack; the PNG encoder is compiled
> per machine) — pixel-file identity across machines was never the
> invariant lockstep needs. The invariant that matters is SIM identity:
> same inputs → same tick-by-tick event stream and telemetry.
> **Protocol correction for the strict exchange (v17 stage-1 spike):**
> publish the per-script TELEMETRY lines + an md5 over the EVENT log
> (the `EVENT ... frame=` stream from the teed replay log), never PNG
> md5s. The RE-RUN's "telemetry identical to the owner-seat wall" claim
> is CREDIBLE but unverifiable as published (the lines themselves were
> not included) — Junior seat: re-publish with the telemetry lines +
> event-log digest and the spike closes for real. Within-machine
> determinism stands proven on BOTH machines (double replays
> byte-identical each side).
