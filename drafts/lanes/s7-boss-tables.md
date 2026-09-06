---
lane: s7-boss-tables
branch: lane/s7-boss-tables
owns:
  - data/balance/drops.json
  - test/game/drop_tables_test.rb
  - tools/drops_report.rb
  - drafts/lanes/receipts/s7-boss-tables.md
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
# Raia `s7-boss-tables`

## Objetivo
TABELAS DE DROP por kind + boss (1.4): afinar `rolls`/`entries` por profundidade e por boss (3 rolagens, garantido 1 material); `tools/drops_report.rb` headless: esperado de itens por 1000 kills por kit (stream :loot); manifests dos sentinelas ganham `item_dropped` minimos (PATCH REQUEST em harness/scripts/*.json).

## Definition of Done
teste: toda entrada e kit real + item do catalogo, p em (0,1]; bosses tem >=1 entrada p=1.0; relatorio reproduzivel (mesma seed = mesmos numeros). Item NOVO no catalogo = PATCH REQUEST em data/items.json (+ icone via gerador do integrador).

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief. As leis do repo valem
   inteiras (data-driven, tick-driven, digest classificado, sem nomes de lore, fallback).
2. Trabalhe SO no branch `lane/s7-boss-tables` (crie a partir de `main`). Comite SO dentro de `owns`.
   Antes de cada commit: `ruby tools/lane_guard.rb s7-boss-tables` (rc 0 = pode commitar).
3. Precisa mudar um arquivo fora de `owns`? NAO toque. Escreva um PATCH REQUEST no SEU
   receipt `drafts/lanes/receipts/s7-boss-tables.md` (arquivo, chave/linha, valor exato, por que).
   O integrador aplica e dobra no BOARD. Briefs e BOARD sao do integrador (a cerca recusa).
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`,
   `harness/run_wall.sh`). So a suite headless: `bundle exec rake`.
5. Tocar `src/game/**` exige o SIM TOKEN no BOARD com o seu nome. Sem token: construa
   dados + modulo novo + teste proprio (padrao `Game::Loot`) e peca a fiacao por PATCH REQUEST.
6. Subagentes filhos (foreground, gpt-5.6-sol, sem `model:`) servem pra sub-tarefas SUAS:
   `reviewer`/`delegate` pra revisar seu diff antes do receipt, `scout` pra reconhecer um modulo.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/s7-boss-tables`, e o receipt em
   `drafts/lanes/receipts/s7-boss-tables.md`: `RECEIPT: s7-boss-tables <sha> READY <resumo de 1 linha>` (+ PATCH REQUESTS).
   A cerca le o brief e o BOARD do ref `main` (trusted), nao da tua arvore: mudar o proprio brief nao muda a cerca.
