# MUNDO VIVO — plano de ciclo v21 (FASE 0) — Junior seat, 2026-09-05

**Direção:** Junior (FULL SEAT SYMMETRY, owner order 2026-08-28).
**Ratificação owed:** Gabriel — este doc é a superfície; decisões D1–D9
no §8 (o dev propõe, os peers fecham). **Restore point:** tag
`restore/pre-mundo-vivo-20260904` (= `cf9a6a6`). **Trabalho:** branch
`junior/mundo-vivo`; merge em `main` só por fase 100% gated (suite +
Rule 2 + perf + re-pin nomeado). Nada aqui relaxa as leis do repo
(Rule 2, caps de linha, data-driven, eventos registrados, tick-driven,
placeholder law, um pedaço SIM gated por ticket).

**Por que agora (evidência, não opinião):** a NINETEENTH fechou
CUMPLIDO WITH NAMED ITEMS (`drafts/_v20-fun-verify-verdict-20260904.md`)
e nomeou exatamente o que este ciclo ataca: **(1) verticalidade não se
lê** ("nada diferencia un hoyo o bajada de una escalera o subida" —
owner P4) → blocos 1/2/6; **(2) crescimento não se sente** ("igual" /
"continua a mesma", 10→13 em sessão) → bloco 3/4 (famílias com
skills diversificadas + bosses únicos dão ao nível algo pra morder);
**(3) vazio de objetivo** ("repetitivo… vacío y sin objetivo") →
blocos 5/6 (cidade-hub + 5 dungeons = destino). Os dois peers
disseram em chat que "o jogo não anda" — este ciclo é a resposta.

## 1. Os seis blocos → fases

| Bloco (visão) | Fase | Classe | Item do verdict que responde |
|---|---|---|---|
| Mapas VIVOS (ambiência) | 2 | presentation | lane G (executa) + verticalidade (pisos com identidade) |
| Fim do "tudo quadrado" (arte) | 1, 3 | presentation | legibilidade geral; base pra facing/estado lerem |
| Famílias de inimigos por dungeon | 4 | SIM | crescimento-não-sentido (skills diversas por tier) |
| Bosses únicos por andar | 5 | SIM | objetivo (o fundo tem um nome/posto) |
| ZONE 7 → cidade | 7 | conteúdo+save | objetivo + hub-destino |
| 5 dungeons × 3–5 andares | 6 | conteúdo+grafo | verticalidade + objetivo |
| Lore fora do repo | 8 | externo | — (só entra com linha do Gabriel) |

## 2. Princípio organizador (ratificável)

`1 dungeon = 1 elemento = 1 família = 1 paleta+ambiência = 1 boss final`.
Ids internos são mecânicos/dicionário (`root, tide, spore, serpent,
ember, frost|hive`) — legais pela regra de-slop; player-visível segue
`DUNGEON N`, `BOSS N`, `ZONE N`.

## 3. Tabela mestra — famílias × dungeons × andares × bosses

| # | Dungeon (player-visível) | Elemento / família | Andares (zonas) | Kinds (tier→nome; T1 topo … Tn fundo) | Primitivas da família | Guardiões / boss final | Entrada |
|---|---|---|---|---|---|---|---|
| 1 | **DESCIDA** (ZONE 2 → 3 → 5) | root→tide→spore (transição por andar — já autorado) | -1 district · -2 district_two · -3 low_quay (**MUSGO novo**, D5) | existentes: rusher/hater (root), lurker/warden (tide), stinger (serpent, migra pra torre no swap) · NOVOS spore: `spore_a` (T3, `poison`), `spore_b` (T3, `pool`) | `poison`, `pool` | guardião -1 (rusher_hater elite: `charge`) · guardião -2 (warden: `pull`) · **BOSS 1** final (-3, challenger: `seize`+`ring`, migra pro bloco `boss`) | camp |
| 2 | **TORRE DA MEDUSA** (DUNGEON 1→2→3→4, invertida) | serpent / pedra | D1 MEDUSA LOWER (swap) · D2 "A divisória" · D3 "B espiral" · D4 "C portão-pedágio" (`drafts/_medusa-tower-concepts-20260831.md`) | stinger (T1, `projectile`) · warden (T1–2) · `serpent_a` (T2, `spread`) · `serpent_b` (T3, `petrify`) · `serpent_c` (T4, `blink`) | `spread`, `petrify`, `blink` | guardião D2 (`serpent_a` elite) · guardião D3 (`serpent_b` elite) · **BOSS 2** final D4: `petrify` + `spread` + fase 2 `summon` stinger | ZONE 7 hole @lvl6 (existente) |
| 3 | **BASEMENT** (basement_1→2→**3 novo**) | root / terra (entrada, tier baixo) | basement_1 @lvl4 · basement_2 @lvl5 · basement_3 (novo, 16×12) | husk (T0–1) · rusher (T1) · `root_a` (T2, `pull`) · `root_b` (T3, `summon` husk) | `pull`, `summon` | guardião b2 (rusher elite) · **BOSS 3** final b3: `pull` + `summon` | ZONE 7 (existente) |
| 4 | **DUNGEON 4 — BRASA** (nova) | ember / fogo | 3–4 andares novos (40×30 → 48×36 → 52×40 [→ 44×44 arena]) | `ember_a` (T1, `charge`) · `ember_b` (T2, `aura`) · `ember_c` (T3, `pool` lava) · `ember_d` (T4, `beam`) | `charge`, `aura`, `pool`, `beam` | guardiões T2/T3 · **BOSS 4** final: `beam` + `aura` + fase 2 `pool` | cidade (quarteirão sul) |
| 5 | **DUNGEON 5** (nova; D2) | **frost/névoa** (`slow`, `fog_bank`) OU **hive/colmeia** (`summon`, `heal_ally`) | 3–5 andares; candidato: nasce da ZONE 8 (fronteira, 64×40, vazia — reaproveita geometria) | frost: `frost_a` (`slow` aura), `frost_b` (`beam`), `frost_c` (`shield`) · hive: `hive_a` (`summon`), `hive_b` (`heal_ally`), `hive_c` (`leap`) | frost: `slow`,`beam`,`shield` · hive: `summon`,`heal_ally`,`leap` | **BOSS 5** final (2 fases) | ZONE 8 rope (existente) |

**Regras:** andar N usa kinds de tier ≤ N+1 da própria família · 3–5
kinds por família · cada kind ≥ 1 primitiva diferente dos irmãos ·
kill_xp cresce com tier E profundidade (L6 monotônico; `pacing_table.rb`
prova por ticket) · cap nunca corre na frente do conteúdo (L5).

## 4. Primitivas de comportamento (FASE 4) — uma por ticket, teste boot+combat ANTES de zona depender

| Primitiva | Leitura visual própria (gate "3 specials, 3 visuais") | Chave combat.json | Evento(s) novo(s) |
|---|---|---|---|
| `charge` | linha telegrafada no chão + corpo esticado | `charge:{range,windup,dmg,kb}` | `charge_started/landed` |
| `leap` | sombra crescendo no pouso + arco | `leap:{range,air_frames,area}` | `leap_landed` |
| `spread` | leque de 3–5 projéteis | `spread:{count,angle,speed}` | (reusa `projectile_*`) |
| `beam` | linha longa, windup longo, fio fino→grosso | `beam:{length,windup,active}` | `beam_fired` |
| `summon` | círculo de invocação + cap por invocador | `summon:{kind,cap,cooldown}` | `summoned` |
| `aura` | anel pulsante enquanto vivo | `aura:{radius,dps|slow}` | `aura_tick` |
| `heal_ally` | pulso verde no alvo | `heal_ally:{amount,range,cd}` | `ally_healed` |
| `shield` | contorno sólido; quebra com special | `shield:{frames,cd}` | `shield_up/broken` |
| `pool` | poça no chão N ticks (fere/lentifica) | `pool:{frames,dps|slow}` | `pool_spawned` |
| `poison` | DOT: tint verde piscando | `poison:{ticks,dmg_per}` | `poisoned` |
| `pull` | linha até o alvo + arrasto N tiles | `pull:{range,tiles}` | `pulled` |
| `blink` | flash + reaparece no flanco | `blink:{range,cd}` | `blinked` |
| `petrify` | stagger longo telegrafado (cinza) | `petrify:{windup,stagger}` | `petrified` |
| `slow` | (modificador de aura/pool) | dentro de aura/pool | — |

Ordem sugerida (dependências dos andares): `spread` → `petrify` →
`blink` (torre) · `charge` → `aura` → `pool` → `beam` (brasa) ·
`pull` → `summon` (basement) · `poison` (musgo) · D2 decide os 3 da
dungeon 5. **BOSS 1 (challenger) migra pro bloco `boss` byte-untouched
nos números** (FASE 5).

## 5. Sistema de boss (FASE 5) — D3 decide guardião+final (recomendado) vs boss por andar

`"boss": {"role":"guardian"|"final","phases":[{"hp_pct":100,"skills":[..]},{"hp_pct":50,"skills":[..]}],"telegraph_frames","arena_lock","defeat_counts"}`
— guardião = 1 assinatura + 1 comum, sem fases · final = 2–3 únicas +
2 fases · **nenhuma dupla de bosses com o mesmo conjunto** ·
`requires_defeats` já existente vira a moeda entre andares/dungeons.
Re-author das coreografias `varekka_duel`/`burn_duel` (dívida em
`harness/retired/`) aproveita esta fase.

## 6. Cap e pacing (D4 — degraus recomendados)

15 (hoje) → **18** riding torre D2–D4 → **21** riding BRASA → **25**
riding DUNGEON 5. Cada degrau = ticket data-only + `pacing_table.rb`
bancada (precedente 12→13→15). k=40 mantido até a tabela pedir.

## 7. Cidade (FASE 7) — grow-`zone_7` (D1 escala, D8 migração)

Mesmo nome interno `zone_7` (zero migração de nome nos saves) · escala
2× (88×56) mínima, 3×/4× decidido pelo spike de perf da FASE 3
(flow_field `recompute!` é O(rows×cols); `rake perf` cenário cidade;
piso = máquina do Junior) · quarteirões por `regions[].intent`: praça
do poço (identidade atual) · banco+selo · **5 entradas** (uma por
cardeal + poço — reconcilia o cardinal sketch do Gabriel) · pátio de
treino (D6) · mercado placeholder (sem item system — PARKING_LOT) ·
cais pra ZONE 5 · portão pra ZONE 8 · LDtk `authoring/pilot.ldtk` →
importer estrito → BFS obrigatório. **L9:** todas as tuplas
`(zone_7,[x,y])` de selo/estação/transição remapeiam → tabela de
remap + teste em CÓPIA do save + backup `.bak-<ts>`; nunca no save
vivo. Scripts re-autorados: `town_gates`, `multi_floor_descent`,
`zone8_crossing`.

## 8. DECISÕES ABERTAS (o dev propõe; os peers fecham — uma linha cada no hub)

| # | Decisão | Recomendação do dev |
|---|---|---|
| D1 | Escala da cidade 2×/3×/4× | o número do `rake perf` na máquina do Junior decide (FASE 3) |
| D2 | Dungeon 5: frost (`slow`) vs hive (`summon`); nasce da ZONE 8? | **hive** (summon+heal_ally = mecânica que nenhuma outra família tem) · **sim, da ZONE 8** (geometria pronta, fronteira ganha propósito) |
| D3 | Boss por andar vs guardião+final | **guardião+final** (15–25 bosses = custo/legibilidade insustentável) |
| D4 | Cap: degraus vs salto | **degraus** 15→18→21→25 riding andares (L5) |
| D5 | Musgo -3: A salão selado / B labirinto / C veias | Junior aprovou A e C; **palavra do Gabriel** |
| D6 | Pátio de treino (husk T0) na cidade — quebra `safe: true` | **sim, com region `intent: "training"`** própria (hub segue safe fora dela) |
| D7 | Grid de linhas OFF por default após tiles com borda | **o gate decide** (FASE 3) |
| D8 | Migração L9 da cidade: remap vs `--fresh` | **remap** (o save de 19 sessões do Gabriel é história, não cobaia) |
| D9 | Lore no repo | **só o Gabriel reverte** a ordem 2026-08-16; até lá tudo em `game-two-lore-junior/` |
| + | Totem COEXISTENCE (do verdict) | owner word: manter grátis / re-preçar / aposentar |

## 9. Orçamento de re-pin da parede (custo nomeado por fase)

FASE 1 (arte) e FASE 3 (tiles) mudam TODO frame → parede inteira
(37 scripts × ~5 min ≈ 3h, detached) **duas vezes no ciclo, só**.
FASE 2 → só zonas que ganham ambiência (por dados). FASES 4–7 → por
zona/script tocado. Falha de manifest pré-existente = comparar com
baseline (precedente T7), nunca mascarar. 9 fails de manifest
pré-existentes conhecidos (census T6b/T7) + `aoe_specials
challenge_reads` (dívida de coreografia) ficam nomeados, não
escondidos.

## 10. Arquitetura da FASE 1 (contrato de atlas — pra arte do Gabriel encaixar depois)

`data/art/manifest.json` por kit: `{atlas, frame_w:32, frame_h:32,
anchor:[2,2], facings:["down","up","left","right"], anims:{idle:{frames:[..],frames_per_step},walk,windup,active,hurt,dead}, md5}`
· atlas = grid **linhas = facings, colunas = frames** (`Gosu::Image.load_tiles`,
`retro: true`) · frame = função pura de `(world.frame, estado, facing)`
· `App::Art::Body.draw` substitui o quad em `draw_creature`; **fallback
= quad atual** (kit sem entrada nunca quebra) · overlays de legibilidade
(anel, marca, underline, telegraph, pressure, notch) CONTINUAM por cima
· arte v1 = placeholder GERADO (`tools/gen_placeholder_art.py`,
determinístico, md5 no manifest, test-pinned) · trocar arte = mesmo
grid, PNG novo, zero código. Nada do sim é tocado: `state_digest`
inalterado por construção.

## 11. Harness (já feito nesta sessão, machine-local, legal)

`harness/vision_critic.py` ganhou `CRITIC_TRANSPORT=gateway`
(anthropic-messages pelo gateway do programa; Bedrock byte-intocado) —
Rule 2 roda na máquina do Junior: baseline `world_loop` **79/79 PASS**
(`drafts/_gate-verdicts.log`, branch `219aa53`).

## 12. FASE 8 — lore fora do repo

`C:/Users/q/Desktop/gametwo/game-two-lore-junior/` (fora de qualquer
git do projeto): bíblia do mundo, uma ficha por família/dungeon/boss,
**tabela de mapeamento placeholder↔nome** (`DUNGEON 4 ↔ …`, `BOSS 2 ↔
…`, `ember ↔ …`) alinhada às tabelas §3. Roda em paralelo; entra no
repo SÓ com linha do Gabriel (D9).
