---
lane: s4-equipment
branch: lane/s4-equipment
owns:
  - src/game/equipment.rb
  - src/game/stat_resolver.rb
  - src/app/equip_screen.rb
  - data/balance/equipment.json
  - test/game/equipment_test.rb
  - test/game/stat_resolver_test.rb
  - drafts/lanes/s4-equipment.md
never:
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
# Raia `s4-equipment`

## Objetivo
EQUIPAMENTO (proposta 1.2 + 2): 3 slots por corpo (hand/body/charm) de item ids do catalogo; `Game::Equipment` (por corpo), `Game::StatResolver` = kit base x (1 + soma dos mods pct) + soma dos mods flat, cap `max_per_attribute`; `fits` do catalogo respeitado; tela de equipar (read-only ate o verbo).

## Definition of Done
testes: cada mod_key do catalogo altera o numero certo; equipar item que nao `fits` recusa nomeado; resolver e puro e deterministico. PATCH REQUESTS previstos: `Creature#kit` passa a ler a merged view do resolver (creature.rb, 1 linha); verbos `:equip/:unequip` no protocolo (protocol.rb + controllers) - SO com o SIM TOKEN; campos `equip_hash` no digest + CLASSIFICATION (persisted via T1).

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief. As leis do repo valem
   inteiras (data-driven, tick-driven, digest classificado, sem nomes de lore, fallback).
2. Trabalhe SO no branch `lane/s4-equipment` (crie a partir de `main`). Comite SO dentro de `owns`.
   Antes de cada commit: `ruby tools/lane_guard.rb s4-equipment` (rc 0 = pode commitar).
3. Precisa mudar um arquivo fora de `owns`? NAO toque. Escreva um PATCH REQUEST no
   `drafts/lanes/BOARD.md` (arquivo, chave/linha, valor exato, por que). O integrador aplica.
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`,
   `harness/run_wall.sh`). So a suite headless: `bundle exec rake`.
5. Tocar `src/game/**` exige o SIM TOKEN no BOARD com o seu nome. Sem token: construa
   dados + modulo novo + teste proprio (padrao `Game::Loot`) e peca a fiacao por PATCH REQUEST.
6. Subagentes filhos (foreground, gpt-5.6-sol, sem `model:`) servem pra sub-tarefas SUAS:
   `reviewer`/`delegate` pra revisar seu diff antes do receipt, `scout` pra reconhecer um modulo.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/s4-equipment`, e UMA linha no
   BOARD: `RECEIPT: s4-equipment <sha> READY <resumo de 1 linha>` (+ os PATCH REQUESTS).
