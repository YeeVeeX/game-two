# Multi-agent LANES — poucas frentes, arquivos disjuntos, um integrador (2026-09-06)

Pedido (Junior): "multiagentes para trabalhar em várias coisas ao mesmo tempo ... alguns
arquivos para eles não se perderem e conseguir efetuar a tarefa sem um sobrescrever ou
conflitar com outro ... poucos e funcionais ... em harmonia. Talvez dentro desse
multiagente subagentes para ajudar eles."

## 0. O que funciona NESTA máquina (verificado hoje)
- Uma sessão do `pi` = um agente. **Paralelismo real = várias sessões** (um terminal por
  raia), cada uma com seu branch e sua pasta de trabalho. É o que o Gabriel já faz com os
  seats (uiux, assets) + brief por e-mail + RECEIPT.
- Dentro de uma sessão, o tool `subagent` roda **filhos em foreground** (`async:false`) —
  eles BLOQUEIAM a sessão-mãe enquanto rodam, então servem para sub-tarefas curtas da
  própria raia (revisar o diff, reconhecer um módulo, rodar a suíte e resumir), não para
  paralelizar. `async:true` falha (binário standalone). Modelos: filhos = gpt-5.6-sol
  (default, sem `model:`); raias/sessões = fable-5.1-thinking (ordem Junior 06/09).
- Gargalos SERIAIS que nenhum número de agentes muda: **uma janela Gosu** (gate/parede),
  **um crítico**, **`world.rb` a 1799/1800**, **hooks de ~3 min por commit**, **a lei do
  canário** (toda mudança de sim reaudita 3 streams — duas raias no sim ao mesmo tempo =
  auditoria combinatória).

## 1. Topologia: raias + INTEGRADOR
```
              ┌──────────── INTEGRADOR (1 sessão; dono de main) ────────────┐
              │ merge em ordem · regenera arte · roda a PAREDE 1×/janela     │
              │ aplica PATCH REQUESTS nos arquivos compartilhados            │
              │ concede o SIM TOKEN · audita canários · empurra main         │
              └──┬──────────┬───────────┬───────────┬──────────┬────────────┘
   lane/s4-equip  lane/s5-attr  lane/s6-vendor  lane/s7-boss   lane/review   lane/validator
   (branch, owns) (branch, owns)(branch, owns)  (branch, owns) (read-only)   (worktree, gates)
```
- **Raia** = 1 sessão + 1 branch `lane/<nome>` + um brief `drafts/lanes/<nome>.md` com
  `owns:` (caminhos que pode tocar) e `never:` (caminhos proibidos). Comita SÓ dentro de
  `owns`. Filhos em foreground para ajudar a si mesma.
- **Integrador** = 1 sessão (o dev seat). Único que toca `main` e os ARQUIVOS COMPARTILHADOS.
- **Arquivos compartilhados** (nunca de uma raia): `src/game/world.rb`, `src/game/creature.rb`,
  `src/net/protocol.rb`, `src/game/save_state.rb`, `data/display.json`, `data/strings/*.json`,
  `data/bindings.json`, `data/balance/economy.json`, `harness/gate_checks.json`,
  `test/net/state_digest_test.rb`, `test/game/save_state_test.rb`, `data/art/**/*.png`,
  `data/art/*manifest*.json`. Mudança neles = **PATCH REQUEST** no receipt (valor exato,
  arquivo, chave); o integrador aplica.

## 2. Protocolo de harmonia (mecânico, não prosa)
1. **Brief** por raia (`drafts/lanes/<raia>.md`, front matter YAML: lane, branch, owns, never,
   objective, DoD). A raia lê AGENTS.md → CYCLE.md → o brief, nessa ordem.
2. **Cerca**: `tools/lane_guard.rb <raia>` recusa (rc 1) qualquer arquivo tocado fora de
   `owns` ou dentro de `never`. A raia roda antes de cada commit; o integrador roda antes de
   cada merge. Conflito de arquivo fica **impossível por construção**, não por confiança.
3. **Handoff** = uma linha `RECEIPT:` em `drafts/lanes/BOARD.md` (raia · sha · estado · resumo)
   + os PATCH REQUESTS. O integrador lê o board, não o chat.
4. **SIM TOKEN**: uma linha no board diz quem pode tocar `src/game/**` agora. Sem token, a
   raia constrói **dados + módulo novo + teste próprio** (padrão `Game::Loot`) e pede a
   fiação de 1–3 linhas por PATCH REQUEST. Mudou stream de evento? anexa
   `ruby tools/a3_stream_diff.rb ...` ao receipt.
5. **Janela**: nenhuma raia abre Gosu (`main.rb`, `replay_runner`, `rake gate/capture/map`,
   `run_wall.sh`). Só a suíte headless. Gate/parede = VALIDADOR (worktree) e INTEGRADOR.

## 3. Mapa de propriedade (v24 THE REWARD — o que o dono sequenciou pra depois)
| Raia | owns | never (pede por PATCH REQUEST) |
|---|---|---|
| s4-equipment | `src/game/equipment.rb`, `src/game/stat_resolver.rb`, `test/game/equipment_test.rb`, `data/balance/equipment.json`, `src/app/equip_screen.rb` | world.rb, creature.rb (`kit` merged view), protocol.rb (`:equip/:unequip`), bindings, digest/save tests |
| s5-attributes | `src/game/attributes.rb`, `data/balance/attributes.json`, `test/game/attributes_test.rb`, `src/app/attributes_panel.rb` | progression.rb (pontos por nível), StatResolver (s4 — coordena no board), protocol (`:spend_point`), save |
| s6-vendor-bank | `src/game/vendor.rb`, `src/game/bank_storage.rb`, `test/game/vendor_test.rb`, `data/balance/vendors.json`, `src/app/vendor_screen.rb` | stations.rb (tipo `vendor`), economy.json (`vendor_markup`, `bank_slots`), sidecars das zonas, protocol (`:trade`) |
| s7-boss-tables | `data/balance/drops.json`, `test/game/drop_tables_test.rb`, `tools/drops_report.rb` | items.json (catálogo — pede item novo por PATCH REQUEST), field_economy.rb |
| review | `drafts/_review-*.md`, `tmp/review_*.md` | tudo (read-only) |
| validator | `tmp/wall/**`, `drafts/_wall-*.log` | src/, data/ |
| integrador (dev seat) | `main`, todos os compartilhados, merges, regeneração de arte, parede | — |

Colisão conhecida e resolvida no desenho: s4 e s5 convergem em `Creature#kit` (merged view).
Regra: **s4 leva o SIM TOKEN primeiro** (StatResolver é dele); s5 constrói dados + módulo +
teste e entrega os mods como `{attr => {mod_key => valor}}` que o StatResolver de s4 já soma.

## 4. Onde o paralelismo realmente rende (honesto)
- Ganho: construção de dados/módulos/testes/telas em 3–4 raias ao mesmo tempo (~2× na
  fase de build), revisão fresh-eyes por pacote sem parar a construção, parede em outra
  máquina (Gabriel roda metade = 2× na validação).
- Não ganha: a parede na mesma GPU (fila), o sim (token), os hooks (serial). O integrador é
  o gargalo humano/agent: a cada janela ele mergeia N raias em ordem, regenera, roda a
  parede UMA vez, classifica flips. Por isso "poucos e funcionais": 4 raias + revisor +
  validador é o teto útil nesta máquina.

## 5. Como lançar uma raia (o que o Junior faz)
1. Terminal novo: `cd Desktop\gametwo\game-two` → `pi` → modelo `fable-5.1-thinking`.
2. Primeira mensagem (colar): *"Você é a raia `<nome>`. Leia AGENTS.md, docs/CYCLE.md e
   drafts/lanes/<nome>.md nessa ordem. Trabalhe SÓ no branch lane/<nome>, SÓ nos caminhos
   `owns`. Antes de cada commit rode `ruby tools/lane_guard.rb <nome>`. Nunca abra janela
   Gosu. Ao terminar, escreva a linha RECEIPT no drafts/lanes/BOARD.md e empurre o branch."*
3. O integrador (esta sessão ou a próxima) lê o BOARD e mergeia.

## 6. Agora (v22) vs depois (v24)
- **v22, hoje**: as raias ativas são do Gabriel (T1 schema — SIM TOKEN dele; E1 harness;
  arte A0–A5 com o assets seat). Minha frente (S1–S3) está construída, revisada (8/8
  achados respondidos) e espera o T1 pra pousar. O validador (parede #3) e o revisor já
  rodaram como raias de fato. Abrir s4–s7 agora colidiria com o T1 e adiantaria o que o
  dono sequenciou — não abre.
- **v24, quando abrir**: os 4 briefs em `drafts/lanes/` estão prontos pra colar; a cerca
  (`tools/lane_guard.rb`) está testada; o board existe. Eu viro integrador.
