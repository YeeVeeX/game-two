---
lane: s5-attributes
branch: lane/s5-attributes
owns:
  - src/game/attributes.rb
  - src/app/attributes_panel.rb
  - data/balance/attributes.json
  - test/game/attributes_test.rb
  - drafts/lanes/s5-attributes.md
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
# Raia `s5-attributes`

## Objetivo
ATRIBUTOS (1.3): pool de pontos do bando (points_per_level), gasto por corpo em vigor/might/grit/pace/focus com `per_point` mods; respec no altar (preco em economy - PATCH REQUEST). Entrega os mods como `{attr => {mod_key => valor}}` que o StatResolver de s4 SOMA (coordene no BOARD: s4 tem o SIM TOKEN primeiro).

## Definition of Done
testes: pontos por nivel batem progression; cap por atributo; `mods_for(body)` puro. PATCH REQUESTS: `:spend_point` no protocolo; `attr_points` no digest + CLASSIFICATION; progression.rb expoe pontos ganhos (1 linha).

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief. As leis do repo valem
   inteiras (data-driven, tick-driven, digest classificado, sem nomes de lore, fallback).
2. Trabalhe SO no branch `lane/s5-attributes` (crie a partir de `main`). Comite SO dentro de `owns`.
   Antes de cada commit: `ruby tools/lane_guard.rb s5-attributes` (rc 0 = pode commitar).
3. Precisa mudar um arquivo fora de `owns`? NAO toque. Escreva um PATCH REQUEST no
   `drafts/lanes/BOARD.md` (arquivo, chave/linha, valor exato, por que). O integrador aplica.
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`,
   `harness/run_wall.sh`). So a suite headless: `bundle exec rake`.
5. Tocar `src/game/**` exige o SIM TOKEN no BOARD com o seu nome. Sem token: construa
   dados + modulo novo + teste proprio (padrao `Game::Loot`) e peca a fiacao por PATCH REQUEST.
6. Subagentes filhos (foreground, gpt-5.6-sol, sem `model:`) servem pra sub-tarefas SUAS:
   `reviewer`/`delegate` pra revisar seu diff antes do receipt, `scout` pra reconhecer um modulo.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/s5-attributes`, e UMA linha no
   BOARD: `RECEIPT: s5-attributes <sha> READY <resumo de 1 linha>` (+ os PATCH REQUESTS).
