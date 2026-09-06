---
lane: validator
branch: lane/validator
owns:
  - tmp/wall/**
  - drafts/_wall-*.log
  - drafts/lanes/receipts/validator.md
never:
  - drafts/lanes/*.md
  - src/game/world.rb
  - src/game/creature.rb
  - src/net/protocol.rb
  - src/game/save_state.rb
  - data/display.json
  - data/strings/
  - data/bindings.json
  - data/balance/economy.json
  - harness/gate_checks.json
  - test/net/state_digest_test.rb
  - test/game/save_state_test.rb
  - data/art/
  - docs/
  - AGENTS.md
---
# Raia `validator`

## Objetivo
VALIDACAO: em worktree destacado (`git worktree add --detach ../game-two-wallN <sha>`), roda `CRITIC_TRANSPORT=gateway harness/run_wall.sh <tag>` (42 scripts, ~3,5 h), depois re-gate dos vision fails no MESMO worktree; classifica flip (passa na 2a) vs real (falha 2x com a mesma frase) vs divida; manifests vs census T7. Log em `drafts/_wall-<tag>-<data>.log`.

## Definition of Done
Uma maquina = um validador (uma janela GL). Nunca corrige codigo: os REAIS vao como achados no BOARD para o integrador. Receipt: `RECEIPT: validator <sha> DONE manifests=<n fails = census?> vision=<flips/reais/dividas>`.

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief. As leis do repo valem
   inteiras (data-driven, tick-driven, digest classificado, sem nomes de lore, fallback).
2. Trabalhe SO no branch `lane/validator` (crie a partir de `main`). Comite SO dentro de `owns`.
   Antes de cada commit: `ruby tools/lane_guard.rb validator` (rc 0 = pode commitar).
3. Precisa mudar um arquivo fora de `owns`? NAO toque. Escreva um PATCH REQUEST no SEU
   receipt `drafts/lanes/receipts/validator.md` (arquivo, chave/linha, valor exato, por que).
   O integrador aplica e dobra no BOARD. Briefs e BOARD sao do integrador (a cerca recusa).
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`,
   `harness/run_wall.sh`). So a suite headless: `bundle exec rake`.
5. Tocar `src/game/**` exige o SIM TOKEN no BOARD com o seu nome. Sem token: construa
   dados + modulo novo + teste proprio (padrao `Game::Loot`) e peca a fiacao por PATCH REQUEST.
6. Subagentes filhos (foreground, gpt-5.6-sol, sem `model:`) servem pra sub-tarefas SUAS:
   `reviewer`/`delegate` pra revisar seu diff antes do receipt, `scout` pra reconhecer um modulo.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/validator`, e o receipt em
   `drafts/lanes/receipts/validator.md`: `RECEIPT: validator <sha> READY <resumo de 1 linha>` (+ PATCH REQUESTS).
   A cerca le o brief e o BOARD do ref `main` (trusted), nao da tua arvore: mudar o proprio brief nao muda a cerca.
