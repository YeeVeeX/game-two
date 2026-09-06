# Lanes - como as raias trabalham em paralelo sem se pisar

Desenho completo: `drafts/_multiagent-lanes-design-20260906.md`. Resumo operacional:

- **1 raia = 1 sessao do pi (fable-5.1-thinking) + 1 branch `lane/<nome>` + 1 brief aqui.**
- A raia so toca os caminhos `owns` do seu brief; a **cerca** `ruby tools/lane_guard.rb <nome>`
  recusa o resto (roda antes de cada commit; o integrador roda antes de cada merge).
- Arquivos compartilhados (world.rb, creature.rb, protocol, save, display/strings/bindings/
  economy, gate_checks, testes de digest/classificacao, PNGs) mudam **so por PATCH REQUEST**
  no `BOARD.md`, aplicado pelo integrador.
- `src/game/**` exige o **SIM TOKEN** (linha no BOARD). Um dono por vez.
- Ninguem alem do **validador**/**integrador** abre janela Gosu.
- Handoff = `RECEIPT:` no receipt DA RAIA (`drafts/lanes/receipts/<lane>.md`); o integrador dobra no
  BOARD, mergeia em ordem, regenera arte, roda a parede 1x por janela de integracao, empurra `main`.
- A cerca (v3) le brief + BOARD do ref `main` (trusted); canonicaliza caminhos (`./`, `//`, `\\`; `..` =
  MALFORMED); POLICY = tudo em drafts/lanes/ menos receipts/, por INTERSECAO de glob (um owns que
  possa cobrir policy e recusado no parse); renames/copies fecham pelos dois lados; branch da raia em
  TODO modo (`--no-branch-check` so para sondas); `src/game/**` exige `SIM LANE: <lane>` no BOARD;
  schema estrito (listas, `branch: lane/<lane>`); falha FECHADA (rc 2).

## Lancar uma raia (Junior)
```
cd Desktop\gametwo\game-two
pi                       # modelo: fable-5.1-thinking
```
Primeira mensagem: *"Voce e a raia `<nome>`. Leia AGENTS.md, docs/CYCLE.md e
drafts/lanes/<nome>.md nessa ordem e cumpra o brief."*

## Raias prontas
`s4-equipment` - `s5-attributes` - `s6-vendor-bank` - `s7-boss-tables` (v24 THE REWARD - abrem
quando o dono abrir o ciclo) - `review` - `validator` (podem rodar a qualquer momento).
