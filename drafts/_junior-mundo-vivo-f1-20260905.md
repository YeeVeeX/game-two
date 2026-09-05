# MUNDO VIVO — FASE 1: camada de arte v1 (Junior seat, 2026-09-05)

**FREEZE: liberado** (evidência: `main` `47f392e` — verdict da NINETEENTH
CUMPLIDO WITH NAMED ITEMS; `docs/CHECKPOINT.md` s125).
**CLAIMED:** FASE 1 (branch `junior/mundo-vivo`; plano FASE 0:
`drafts/_junior-mundo-vivo-plan-20260905.md`).
Classe: **presentation pura** — zero leitura pelo sim, zero entrada no
`state_digest` (grep: nenhuma referência a `App::Art` em `src/game`,
`src/core`, `src/net`).

## O que existe agora

- **`src/app/art.rb`** — `App::Art::Registry` (lê `data/art/manifest.json`
  via DataStore; imagens carregam LAZY no primeiro draw — GL context
  law), `App::Art::Atlas` (`Gosu::Image.load_tiles`, `retro: true`;
  falha de PNG → nil, nunca crash), `App::Art::Body` (facing/anim/frame
  = funções PURAS de `(world.frame, estado, facing)`; `draw` retorna
  false → quad legado). **Fallback law:** kit sem atlas = quad de hoje.
- **`data/art/manifest.json` + `data/art/atlas/<kit>.png`** — 10 kits
  (striker, blocker, lobber, rusher, rusher_hater, husk, challenger,
  lurker, warden, stinger). Grid = 4 linhas (facings down/up/left/right)
  × 12 colunas (idle 2 · walk 4 · windup 2 · active 2 · hurt 1 · dead 1),
  frame 32×32, corpo 28×28 no anchor (2,2). md5 por atlas no manifest,
  **test-pinned** (drift de bytes = suite vermelha, nunca silencioso).
- **`tools/gen_placeholder_art.py`** — gerador DETERMINÍSTICO (PIL, zero
  RNG): silhuetas distintas por kit — pack: lâmina / escudo / funda;
  hostis: cunha (rusher) · cunha com 2 riscos (hater) · anel oco (husk) ·
  bloco com coroa (challenger) · bolha baixa (lurker) · sino+tentáculos
  (warden) · sino pequeno+espinho (stinger). Paleta parte de `KIT_BODY`
  (a verdade de cor que o gate já julga). Sombra 2-tons + contorno 1px.
  **Arte substituível:** mesmo grid, PNG novo, zero código.
- **`src/app/renderer.rb`** — `draw_creature` → `draw_body`: sprite com
  tint (flash crimson do pack, dim de aliado, peso azul do seized —
  MODULAÇÃO de cor reproduzindo a gramática dos quads) ou quad legado +
  overlays. Telegraph: o frame `windup` senta dentro do flare (o core
  aparece pela margem transparente). **Todos os overlays de legibilidade
  continuam por cima** (anel, marca, underlines, pressure, notch).
  Notch de facing: continua ON (`display.json art_facing_notch`).
- **`data/display.json`** +6 chaves: `art_enabled`, `art_facing_notch`,
  `art_hurt_tint_rgb`, `art_human_hurt_tint_rgb`, `art_ally_dim_rgb`,
  `art_seized_tint_rgb` (zero constante visual nova em código).
- **`src/core/data_store.rb`** — `root` reader (1 linha; PNGs resolvem
  contra a raiz do data/).
- Wiring: `src/app/window.rb` (268 linhas, cap 300) e
  `harness/scenes/world_scene.rb` passam `art: App::Art::Registry.load(data)`.
- **`test/app/art_registry_test.rb`** — 7 testes: cobertura de todo kit
  do `combat.json`, grid (IHDR) × manifest, md5 pin, índices de anim
  dentro do grid, seleção facing/anim pura e completa, frame_col
  determinístico, manifest ausente = registry vazio (não crash).

## Evidências

| Prova | Resultado | Caminho |
|---|---|---|
| Suite | **1356 runs, 32798 assertions, 0 failures** | hooks (`bundle exec rake`) |
| Determinismo (sprites) | world_loop **10 capturas byte-idênticas** ×2 | `tmp/wall/fase1_world_loop.log` |
| Rule 2 `world_loop` | **GATE PASS — 79/79** (critic via gateway) | `drafts/_gate-verdicts.log` |
| ↳ checks-chave | `actors_distinct` ✓ "pale bone arrow humans separate cleanly from orange, rust and brown pack bodies" · `kits_distinct` ✓ "ember rect, notched rust rect and round brown blob read as three kinds" · `possessed_readable` ✓ · `facing_readable` ✓ "human arrows point their heading" · `telegraph_reads` ✓ · `corpses_persist` ✓ | idem |
| Manifest `world_loop` | PASS (banked=2 drop_picked_up=2) | idem |
| Rule 2 `floor1_run` | **GATE PASS** (79/79, manifest fight_resolved=4 actor_died=12) | `tmp/wall/fase1_floor1_run.log` |
| Rule 2 `dash_strike_rip` | **GATE PASS** (det 10/10 + vision PASS) | `tmp/wall/fase1_dash_strike_rip.log` |
| Rule 2 `aoe_specials` | vision FAIL `taunt_underline_reads` — **critic flip**: frame 1189 contém só pack (zero humanos), o underline é human-only e desenha em `y+SIZE+9` (fora do frame do sprite, caminho byte-intocado); check já oscilou em runs de quads (histórico do log). Manifest PASS (special_started=2 taunted=2). → re-run na parede | `tmp/wall/fase1_aoe_specials.log` |
| Rule 2 `lobber_volley` | vision FAIL `volley_telegraph_distinct` — **colisão pré-existente** brackets-de-volley × tile-de-estação (mesma família pálido+laranja; frames 0350 vs 4779); nenhum dos dois é corpo, o sprite não toca tiles. Primeiro FAIL em 7 runs históricos = flip. Manifest PASS. → re-run na parede | `tmp/wall/fase1_lobber_volley.log` |
| v1→v2 da arte | `aoe_specials` v1 FALHOU `kits_distinct` ("kit color swaps with possession": sombra 0.70 + dim 55% empurrava o striker não-possuído pro rust) → sombra 0.82..1.12 + dim 78% + lobber +10% → **v2 PASSA** `kits_distinct` em todos os 5 | `tmp/wall/fase1_chain_v2.log` |
| Tick-driven law | `grep milliseconds\|Time.now\|rand(` em art.rb + diff do renderer = **vazio** | — |
| Line caps | window.rb 268/300 · world.rb 1712/1800 (intocado) | `test/app/line_caps_test.rb` |
| Perf | `PERF ticks=6990 p50=0.371ms p95=0.611ms max=13.882ms zone=district` **PASS** (sim-only por construção; sprites não entram no tick) | `rake perf` |

**Ajustes pós-crítico (v2, já aplicados):** anel do possuído/parceiro
pad 3→4 sob sprites (a margem do frame comia 1px: 3px visíveis mantidos);
sombra 2-tons 0.70..1.15 → 0.82..1.12; dim de aliado 55% → 78%; lobber
+10% de luz ("muddy not pale amber"). Todos data/gerador — zero sim.

## Custo de re-pin (nomeado)

A FASE 1 muda TODO frame com criatura → parede inteira (37 scripts)
re-gated: `harness/run_wall.sh fase1` detached após os 5 gates-alvo.
Manifests são contagens de EVENTOS (não hashes de pixel) — a arte não
os move; os 9 fails pré-existentes (census T6b/T7) + `aoe_specials
challenge_reads` (dívida de coreografia) ficam comparados com baseline,
nunca mascarados.

## Fora de escopo, anotado (JUNIOR.md: bug fora da tarefa → anota e segue)

- `draw_corpses` segue quad (frame `dead` do atlas existe; ligar corpse →
  kit_name é ticket próprio: o registro de corpse não guarda `kit_name`).
- Diagonais de facing resolvem pro eixo vertical no sprite; o notch
  mantém a verdade 8-way (por isso segue ON).

## Staging proposto

`src/app/art.rb` · `src/app/renderer.rb` · `src/app/window.rb` ·
`src/core/data_store.rb` · `harness/scenes/world_scene.rb` ·
`data/display.json` · `data/art/manifest.json` · `data/art/atlas/*.png`
· `tools/gen_placeholder_art.py` · `test/app/art_registry_test.rb` ·
`drafts/_gate-verdicts.log` · este draft.

Mensagem: `feat(art): MUNDO VIVO FASE 1 - sprite layer (App::Art) under
the legibility overlays; 10 deterministic placeholder atlases (md5
test-pinned, art replaceable); quad fallback law; world_loop gate 79/79
via gateway`
