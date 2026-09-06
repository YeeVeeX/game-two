---
lane: e3-presentation
branch: lane/e3-presentation
owns:
  - src/app/renderer.rb
  - src/app/minimap.rb
  - src/app/hud.rb
  - src/app/fx.rb
  - src/app/light.rb
  - src/app/controls_overlay.rb
  - src/app/menu.rb
  - src/app/stats_panel.rb
  - src/app/ambience.rb
  - src/app/tileset.rb
  - src/app/netplay_overlay.rb
  - data/display.json
  - test/app/display_knobs_test.rb
  - test/app/interact_prompt_test.rb
  - test/app/minimap_test.rb
  - drafts/lanes/receipts/e3-presentation.md
never:
  - drafts/lanes/*.md
  - src/game/
  - src/net/
  - src/core/
  - src/app/window.rb
  - src/app/bag_screen.rb
  - src/app/item_icons.rb
  - harness/
  - data/balance/
  - data/zones/
  - data/strings/
  - data/bindings.json
  - data/art/
  - test/net/
  - test/game/
  - test/harness/
  - docs/
  - AGENTS.md
---
> DONE 2026-09-06 - delivered @ f880c7c (folded d557f67). Kept as record; a delivered brief leaves drafts/lanes/ so its `owns` stop
> fencing the next lane (the overlap test reads only the top level; done/ stays POLICY for every lane).

# Raia `e3-presentation` — ticket E3 do v22 ("presentation truth")

Spec: `docs/superpowers/specs/2026-09-05-v22-one-body-cycle.md` §5 linha **E3** ("Junior's surfaces → his line
first, either seat executes. Rule 2 gates on the touched scripts"). Achados de origem: `drafts/_t0-review-20260905.md`
linhas 43-47 (b3, b4, b5, F-A3-1) e 45 (d12). Esta raia e SO apresentacao (`src/app/**` + `data/display.json`):
zero `src/game/**`, zero digest, zero protocolo. Os canarios NAO podem mudar (o sim nao e tocado).

## Objetivo (4 pecas, cada uma com teste proprio)
1. **b3 — prompt INTERACT so onde o verbo existe.** Hoje `Renderer#draw_interact_prompt` (renderer.rb ~1764)
   mostra o balao "H INTERACT" quando a possuida esta EM ou AO LADO de qualquer estacao (4 tiles + totens, onde H nao
   faz nada), e NAO mostra no `rope_spot` (que E um interact: world.rb:524). Verdade unica: o prompt aparece **sse**
   `World#interact(source)` faria algo neste tick - i.e. `map.station_at(*tile)` na PROPRIA tile da possuida com um
   tipo que `interact_station` despacha, OU a tile e `rope_spot` (world.rb:479-534, 1090). Voce NAO pode tocar
   `world.rb`: leia o dispatch e espelhe a condicao no renderer a partir do MAPA (`station_at`, `t[:type]`); se
   precisar de um predicado publico no World (`World#interact_available?(source)`), escreva-o como PATCH REQUEST com o
   corpo exato (1 metodo, <=6 linhas) e, enquanto isso, implemente a leitura pelo mapa. Teste: `test/app/interact_prompt_test.rb`
   (headless, sem Gosu: extraia a decisao "mostra?" para um metodo puro, ex. `Renderer.interact_prompt_for(world, body)`
   -> `nil | {verb:, key:}`; teste em tile de estacao, tile adjacente, totem, rope_spot, tile vazia).
2. **b4 — minimapa: vias vivas coloridas por `way_locked?`.** `minimap.rb:58-67` pinta TODA `transition_at` de
   ouro (ouro = "da pra passar", lei do `exit_signage_reads`; d12: a linha `minimap_reads` se contradiz). Fazer: via
   ABERTA = ouro (`minimap_way_open_rgb`), via TRANCADA = a cor da tranca (`minimap_way_locked_rgb`, proposta
   cinza-frio [120,130,150]) - a decisao vem do MESMO predicado que a sinalizacao de saida usa (procure `way_locked?`
   / o que `exit_signage` le em renderer.rb), nunca de uma lista propria. Teste: `test/app/minimap_test.rb` (headless:
   o minimapa ja tem `scale_for(map)`; extraia `Minimap.way_color(map, world, tx, ty)` ou equivalente puro e prove
   aberta vs trancada com um mapa/zona real que tenha `requires_level`).
3. **b5 — cada `@display.fetch(:k, default)` vira chave ESCRITA em `data/display.json`, sem default no codigo.**
   Hoje: 176 chamadas, 157 chaves distintas, **38 FALTAM** no display.json: `art_dodge_tint_rgb boss_bar boss_bar_h
   boss_bar_w boss_bar_y enemy_hp_bars exit_arrow_margin exit_arrow_max exit_arrows exit_pulse exit_pulse_alpha
   fx_ally_callouts fx_damage_numbers fx_enabled fx_number_big_px fx_number_font_px hud_chips_y hud_plate_alpha
   hud_plate_edge_rgb hud_plate_rect hud_plate_rgb hud_portrait_ox hud_portrait_oy interact_prompt kill_punch
   level_flash light_enabled light_fire_alpha light_fire_rgb light_glows low_hp_alpha low_hp_pct low_hp_rgb minimap
   tileset tileset_gain vignette_alpha vignette_alpha_safe`. Escreva cada uma com o valor que o default do codigo
   tem HOJE (byte-identico na tela: o gate e a prova), remova o default (`fetch(:k)` estrito) e escreva
   `test/app/display_knobs_test.rb`: varre `src/app/*.rb` por `display.fetch(:(\w+)` e falha se alguma chave nao
   existir em `data/display.json` OU se alguma chamada ainda tiver default (regex `fetch\(:\w+,`). Excecoes so com
   comentario `# display-optional:` na linha e listadas no teste (ex.: `tileset` false forca fallback - se for
   intencional, a chave existe com `true` e o teste aceita). `hud_plate_rect` esta duplicado (hud.rb:51 +
   renderer.rb:1652): UMA chave, dois leitores.
4. **F-A3-1 — chip SAFE:** `safe_chip_y` 98 -> **138** em `data/display.json` (hub confirmou no frame do tour:
   o chip verde SAFE cobria o chip `0 COINS` em toda zona segura). So o numero.

## Definition of Done
- 4 pecas + 3 testes novos; `bundle exec rake` verde; `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run`
  = `ACTIVE bank? YES` x3 (voce nao tocou o sim - se mudar, vazou).
- `wc -l src/app/window.rb` intocado (never). `renderer.rb` sem cap formal, mas NAO cresca: b3 e b5 devem
  ENCOLHER (defaults removidos); se b4 exigir >30 linhas novas, extraia para `minimap.rb`.
- Receipt `drafts/lanes/receipts/e3-presentation.md`: `RECEIPT: e3-presentation <sha> READY <1 linha>`; a lista dos
  **wall scripts cujas superficies mudaram** (o integrador gateia com janela - voce NAO): pelo menos os que mostram
  prompt/minimapa/HUD safe (candidatos: `town_gates`, `ledger_loop`, `world_loop`, `basement_pocket`, `menu_tour`);
  **PATCH REQUEST d12**: o texto novo da linha `minimap_reads` em `harness/gate_checks.json` (never seu) descrevendo
  ouro = aberta, cinza = trancada; PATCH REQUEST `World#interact_available?` se voce precisou dele.
- `ruby tools/lane_guard.rb e3-presentation --trust junior/premium-build` rc 0 antes de CADA commit.

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief -> `drafts/_t0-review-20260905.md` 40-50.
2. Trabalhe SO no branch `lane/e3-presentation` (worktree que voce recebeu). Comite SO dentro de `owns`.
   Ref confiavel da cerca nesta rodada = `junior/premium-build` (os briefs nao estao em `main`).
3. Fora de `owns`? NAO toque: PATCH REQUEST no seu receipt (arquivo, linha, valor exato, por que).
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`, `harness/run_wall.sh`).
   So headless: `bundle exec rake`, arquivos de teste isolados, `tools/a3_stream_diff.rb`.
5. Sem `src/game/**` (never): nao precisa de SIM LANE.
6. Ajudantes com o tool `subagent` (read-only, async): um `scout` pra mapear `interact`/`interact_station`/
   `station_at`/`way_locked?`/`exit_signage` e listar as 38 chaves com seus defaults atuais (file:line:default);
   um `reviewer` no seu diff antes do receipt. Voce e a unica escritora.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/e3-presentation`, receipt escrito, relatorio.
   Se travar, diga exatamente em que; nunca alargue o escopo pra destravar.
