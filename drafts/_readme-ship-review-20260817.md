# README ship review — 2026-08-17

Surface: repository landing page (`README.md`) plus `docs/assets/gameplay.png`.
Audience: owner, Junior, and a technical player cloning the Windows Ruby/Gosu project.

## Accuracy — PASS (5/5)

- Image is byte-identical to deterministic `world_loop` capture `frame_0983.png` (`cmp` exit 0), 960×540 RGBA.
- Image shows the current placeholder build: ZONE 1, player 1, pack bodies, HUD, stations, controls, and a +2 post-fight tally; no lore or personal information.
- All four relative Markdown targets exist: gameplay image, `docs/JUNIOR.md`, `AGENTS.md`, `docs/CHECKPOINT.md`.
- Launch commands exist and match current entry points: `bin\play.cmd`, `bin/play`, `bin\host-coop.cmd`, `bin\join-coop.cmd`.
- Setup names the verified exact runtime, Ruby 3.4.10 with DevKit.

## Presentation — PASS (5/5)

- Truncated pyramid: one-sentence game shape → representative frame → placeholder disclosure → Play / Co-op / Setup / deterministic-gate / Tests.
- The image sits above setup detail, has accurate functional alt text, and remains readable at README thumbnail scale.
- Commands are scan-friendly and grouped by user intent; prose stays technical and concise.

## Visual gate — PASS

Bedrock vision verdict `20260817-071556`, exact image under `tmp/readme_image_gate`, 4/4:

- `representative_gameplay`: PASS
- `placeholder_compliance`: PASS
- `readable_crop`: PASS
- `readme_thumbnail_value`: PASS

Full structured verdict: `drafts/_gate-verdicts.log`.

## Verdict

PASS. Accuracy and presentation independently clear the human-facing ship gate.
