---
lane: signage
branch: lane/signage
owns:
  - src/app/renderer.rb
  - src/app/signage.rb
  - data/display.json
  - test/app/signage_test.rb
  - test/app/pressure_outline_test.rb
  - test/app/interact_prompt_test.rb
  - drafts/lanes/receipts/signage.md
never:
  - drafts/lanes/*.md
  - src/game/
  - src/net/
  - src/core/
  - src/app/window.rb
  - src/app/minimap.rb
  - src/app/hud.rb
  - src/app/fx.rb
  - src/app/light.rb
  - harness/
  - data/balance/
  - data/zones/
  - data/strings/
  - data/art/
  - test/app/minimap_test.rb
  - test/app/line_caps_test.rb
  - test/net/
  - test/game/
  - test/harness/
  - docs/
  - AGENTS.md
---
> DONE 2026-09-06 - delivered @ 7dcb601 (receipt c35640a), rebased + ff into junior/premium-build. Kept as record.

# Raia `signage` — duas dividas nomeadas de apresentacao, DOIS commits separados

Origem: receipt do E3 (`drafts/lanes/receipts/e3-presentation.md`: "renderer.rb 2099 -> 2124 (+25) - extraction
candidate") e a linha `pressure_ring_reads` vermelha em brasa2_run nas paredes #2, #3 e #4 ("outlined hostiles sit at
random distances, some behind walls; reads as scattered aggro tags, not encirclement"). Mecanismo ja medido pela raia
a3 (`drafts/lanes/receipts/a3-stalemate.md` §FINDING): os embers que ganham contorno sao os que ficam PRESOS na parede
da linha 6, a 6-9 tiles da possuida - tem o PAPEL `:pressuring` (reivindicaram um slot do anel) mas nunca chegam ao
slot. Esta raia e SO apresentacao (`src/app/**` + `data/display.json`): zero `src/game/**`, zero digest, canarios
intocados (`= ACTIVE bank? YES` x3 obrigatorio).

## Commit 1 — EXTRACAO byte-inerte: `src/app/signage.rb`
Mover de `renderer.rb` para um modulo `App::Signage` (mixin no `Renderer`, padrao `Game::Loot` em `src/game/loot.rb`)
o bloco de SINALIZACAO: `interact_verb` / `INTERACT_STATIONS` / `interact_prompt_for` / `draw_interact_prompt`,
`way_locked?`, a sinalizacao de saida (`draw_exit_signage` ou nome atual: vias que respiram + setas douradas fora de
camera) e `draw_pressure_outline`. Regras:
- Os NOMES PUBLICOS continuam funcionando sem mudar quem os chama: `App::Renderer.interact_verb(map, tile)`,
  `App::Renderer.way_locked?(...)` (o `minimap.rb` — never seu — chama este), `Renderer#interact_prompt_for(world)`.
  Use `extend` para os metodos de classe e `include` para os de instancia, ou delegue; `minimap.rb`, `minimap_test.rb`
  e `hud.rb` NAO mudam (never). `interact_prompt_test.rb` e seu: pode passar a testar `App::Signage` se preferir.
- Zero mudanca de comportamento: mesmas constantes, mesmas leituras de `@display`, mesma ordem de draw. O integrador
  prova byte-identidade gateando `ledger_loop` e `town_gates` neste commit e comparando o md5 das capturas com as da
  parede #4 (`captures/<script>_gate_a/*.png` @ cbaa4a5) — se um pixel mudar, a extracao esta errada.
- `wc -l src/app/renderer.rb` <= **2000** ao fim deste commit (o integrador cravara o cap em `line_caps_test.rb`, never
  seu). `signage.rb` sem cap formal; se passar de ~300, avise no receipt.
- `test/app/signage_test.rb`: o modulo existe, esta mixado, os 3 nomes publicos respondem, e um teste puro de
  `way_locked?` (zona real com `requires_level`) que hoje so existe indiretamente via minimap_test.

## Commit 2 — REGRA do contorno de pressao (mudanca visual, gate em brasa2_run)
Hoje (`renderer.rb` ~1222): contorno sse `c.faction == :human && world.pressure_role(c) == :pressuring`. Nova regra,
decidida por um metodo PURO `Signage.pressure_outline?(world, c)` (testavel sem Gosu):
  contorno sse `pressure_role(c) == :pressuring` **E** Chebyshev(c, possuida) <= `pressure_outline_max_tiles`
  **E** `world.line_clear?(c.tile, possuida.tile)`.
- `pressure_outline_max_tiles` em `data/display.json`: valor = o raio real do anel de pressao + 1 (leia
  `Creature::RING` / a geometria dos slots em `src/game/aggro.rb` `surround_slot` e `@pressure_claims`; NAO invente:
  o numero e o do anel que o sim usa; escreva-o no receipt com a linha de onde veio). Segunda chave
  `pressure_outline_needs_line: true` (permite ao dono desligar a exigencia de linha limpa sem mexer em codigo).
- O que NAO muda: `world.pressure_role` (sim), quem e `:pressuring`, o digest, o alpha/cor do contorno
  (`pressure_outline_alpha`, `HUMAN_BODY`). Um hostil pressionando LONGE ou ATRAS DE PAREDE passa a ler como o que e
  — um hostil andando — em vez de "estou cercando" a 8 tiles atras de pedra. O bolsao em si (embers presos) continua
  sendo o candidato (c) do dono (SIM, caminho OFF): esta raia NAO o toca; diga isso no receipt.
- `test/app/pressure_outline_test.rb` (headless, World real; padrao de `test/app/interact_prompt_test.rb`): (i)
  hostil `:pressuring` a <= max_tiles com linha limpa -> true; (ii) `:pressuring` a > max_tiles -> false; (iii)
  `:pressuring` perto mas com parede entre (`line_clear?` false) -> false; (iv) `:engaged` -> false (nao e contorno);
  (v) `pressure_outline_needs_line: false` -> (iii) vira true. Como forcar o papel num teste: veja como
  `test/game/*aggro*|*surround*|*pressure*` monta a particao; se precisar de um helper publico no World, PATCH REQUEST.

## Definition of Done
- 2 commits, na ordem, cerca rc 0 antes de cada (`ruby tools/lane_guard.rb signage --trust junior/premium-build`).
- `bundle exec rake` verde; `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run` = `YES` x3.
- `renderer.rb` <= 2000 linhas; `window.rb` e `world.rb` intocados (never).
- Receipt `drafts/lanes/receipts/signage.md`: `RECEIPT: signage <sha> READY <1 linha>`; o numero de
  `pressure_outline_max_tiles` e a linha do sim de onde veio; scripts pra gate do integrador (commit 1: `ledger_loop`,
  `town_gates` byte-identicos; commit 2: `brasa2_run` + qualquer reel com pressao visivel: `district_hunt`,
  `threat_pull`, `sustain_run` — liste os que voce acha que mudam); PATCH REQUESTS (cap em `line_caps_test.rb` = 2000;
  reword de `pressure_ring_reads` SO se a linha precisar — hoje ela pede "deliberate encirclement", que e o que a regra
  entrega).

## Lei da raia
1. Leia: `AGENTS.md` -> `docs/CYCLE.md` -> este brief -> receipts do E3 e da a3 (§FINDING).
2. So no branch `lane/signage` (worktree recebido), so dentro de `owns`; ref confiavel da cerca = `junior/premium-build`.
3. Fora de `owns`: NAO toque; PATCH REQUEST no receipt (arquivo, linha, valor exato, por que).
4. NUNCA abra janela (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`, `harness/run_wall.sh`) —
   uma parede esta rodando nesta maquina AGORA (janela unica). So headless: `bundle exec rake`, teste isolado,
   `tools/a3_stream_diff.rb`.
5. Sem `src/game/**`: nao precisa de SIM LANE.
6. Ajudantes (`subagent`, read-only, async): um `scout` pra mapear o bloco de sinalizacao no renderer (file:line de
   cada metodo, quem chama) e a geometria do anel de pressao em `aggro.rb`/`creature.rb` (o raio); um `reviewer`
   no diff antes do receipt. Voce e a unica escritora.
7. Ao terminar: suite verde, cerca OK, `git push -u origin lane/signage`, receipt, relatorio. Se travar, diga em que.
