---
lane: review
branch: lane/review
owns:
  - drafts/_review-*.md
  - tmp/review_*.md
  - drafts/lanes/receipts/review.md
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
# Raia `review`

## Objetivo
REVISAO FRESH-EYES read-only de um range de commits (o integrador indica no BOARD): leis do AGENTS.md, corretude, regressao, digest/classificacao, canarios (`ruby tools/a3_stream_diff.rb ...`), suite. Relatorio em `drafts/_review-<pacote>-<data>.md` com veredito MERGEABLE / WITH MINORS / BLOCKED e tabela de achados (sev - file:line - achado - lei - fix de 1 linha).

## Definition of Done
Nunca edita codigo. `bundle exec rake` 1x e cita a linha. Receipt no BOARD com o veredito.

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief. As leis do repo valem
   inteiras (data-driven, tick-driven, digest classificado, sem nomes de lore, fallback).
2. Trabalhe SO no branch `lane/review` (crie a partir de `main`). Comite SO dentro de `owns`.
   Antes de cada commit: `ruby tools/lane_guard.rb review` (rc 0 = pode commitar).
3. Precisa mudar um arquivo fora de `owns`? NAO toque. Escreva um PATCH REQUEST no SEU
   receipt `drafts/lanes/receipts/review.md` (arquivo, chave/linha, valor exato, por que).
   O integrador aplica e dobra no BOARD. Briefs e BOARD sao do integrador (a cerca recusa).
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`,
   `harness/run_wall.sh`). So a suite headless: `bundle exec rake`.
5. Tocar `src/game/**` exige o SIM TOKEN no BOARD com o seu nome. Sem token: construa
   dados + modulo novo + teste proprio (padrao `Game::Loot`) e peca a fiacao por PATCH REQUEST.
6. Subagentes filhos (foreground, gpt-5.6-sol, sem `model:`) servem pra sub-tarefas SUAS:
   `reviewer`/`delegate` pra revisar seu diff antes do receipt, `scout` pra reconhecer um modulo.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/review`, e o receipt em
   `drafts/lanes/receipts/review.md`: `RECEIPT: review <sha> READY <resumo de 1 linha>` (+ PATCH REQUESTS).
   A cerca le o brief e o BOARD do ref `main` (trusted), nao da tua arvore: mudar o proprio brief nao muda a cerca.
