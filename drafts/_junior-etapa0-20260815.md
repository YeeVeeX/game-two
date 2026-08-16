# Etapa 0 — Junior's replay exchange + cross-machine determinism evidence (2026-08-15)

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
