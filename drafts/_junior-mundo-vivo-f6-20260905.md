# MUNDO VIVO — FASE 6: grafo de dungeons — Junior seat, 2026-09-05

**FREEZE: liberado** (s125). **CLAIMED:** FASE 6 (branch `junior/mundo-vivo`).
Lei: **um andar por ticket**, com fauna da família, gates, pacing, `rake map
PROBES=1`, soak. Ordem do plano §7: swap → musgo → torre 2/3/4 → basement_3
→ BRASA → D5.

## Ticket 6.1 — O SWAP (+ musgo A direto no piso -3)

Spec: `drafts/_swap-spec-medusa-to-dungeon1-20260831.md` (Junior "isso aí";
Gabriel concur da torre no WhatsApp; 3 ratificações formais dele owed —
listadas no spec §6). **Decisão de execução (dev, recorded):** o "mapa
antigo interino" do spec (M1) foi PULADO — ele só existia porque o musgo
ainda não estava desenhado; com os candidatos A/C aprovados pelo Junior,
o musgo A entra DIRETO no piso -3 (uma re-gate da ZONE 5 a menos; a
regressão de economia interim do spec §3 nunca existe).

**Ferramenta:** `tools/swap_medusa_to_dungeon1.py` — determinística,
idempotente (recusa rodar 2×), registry-driven, BFS em toda chegada/
porta/spawn, edita SÓ `authoring/pilot.ldtk` + 2 sidecars (LDtk = verdade
espacial; `data/zones` re-emitido pelo importer, a única porta).
Desvios impressos e recorded:

- **DUNGEON 1 ← MEDUSA LOWER (52×52)**: chegada do buraco da ZONE 7 na
  cabeça da serpente `[10,8]`; corda de volta `[9,8]` → zone_7 `[33,16]`;
  **corda pra ZONE 8 re-endereçada `[29,4]` → `[29,7]`** (`[29,4]` é
  parede nesta geometria; `[29,7]` = andável mais próximo na borda norte
  da cabeça); **selo interno `[17,2]→[18,2]` MORRE**; buraco central
  INERTE (a escada pro andar 2 aterrissa com `dungeon_2`); fauna
  stinger×24 + warden×5 migram COM a geometria; **challenger NÃO** (BOSS 1
  não duplica — a torre ganha boss próprio: `serpent_boss`, FASE 5).
- **ZONE 5 ← MUSGO A "salão selado" (52×36)**: porta oeste `[1,18]` →
  slow_door (chegada 1 tile dentro, `[2,18]`); porta sul `[24,34]` →
  zone_7 `requires_defeats: 1` (chegada `[24,33]`); **BOSS 1 no cofre
  `[41,18]`** (15×17, 2 acessos); piso = tipo `moss` (FASE 3) com bolsões
  de `.`; fauna **spore_a ×14 + spore_b ×9** (FASE 4.5) → clear **1955 xp
  > 1780 do -2** (L6); `drop_gradient` 3.0/3.5/4.0 (hall/espinha/cofre);
  sidecar: paleta musgo, 4 tochas no cofre, `spore_drift` 6% + `light_shafts`
  no cofre (FASE 2).
- **Linhas de retorno**: zone_7→dungeon_1 spawn `[15,3]→[10,8]` e
  zone_7→low_quay `[24,50]→[24,33]` (emissão do pilot.ldtk move
  exatamente essas linhas); `slow_door.json` (hand) `[10,8]→[2,18]`;
  `zone_8.json` `[29,4]→[29,7]` — **byte-pin do intake movido
  CONSCIENTEMENTE** (`worldsmith_intake_test` `89ba053f…→fc7ccfc8…`,
  mesmo commit, 1 linha).
- **Migração L9 (save):** `Game::SaveState::RETIRED_SEALS =
  [["dungeon_1",[18,2]]]` + `migrate_retired_seals!` roda no envelope
  ANTES do decoder estrito (`SaveStore#load`); tupla nomeada é DROPADA com
  notice ("no refund"); lista nomeada, nunca wildcard; idempotente. Saves
  vivos com o selo antigo pago carregam limpos na primeira sessão pós-swap.
- **Bug pego ao vivo:** v1 do tool fazia porta = chegada (`[1,18]`) → o
  pack pousava e o gate disparava DE VOLTA no mesmo tick (ping-pong). A
  medusa evitava por 1 tile; agora toda chegada fica a 1 tile da porta
  (regra no tool, testes provam a travessia nas 2 direções).

**Parede / canary / probes (custos nomeados):** `floor3_run` (coreografado
na medusa em ZONE 5) → `harness/retired/`, stream preservado em
`F6_RETIREMENT`; `ACTIVE` = só `world_loop` (byte-UNCHANGED — asserted)
até o sentinela do musgo ser autorado pelo tuner (próximo ticket);
`rake map PROBES=1` **21/21** re-pinado (dungeon_1: void/cabeça/corda
`[9,8]`/frontier slab `[29,7]`; low_quay: musgo/cofre/posto/porta sul);
`dungeon_fork` determinismo 6/6 (crítico + `multi_floor_descent` +
`zone8_crossing` = re-gate na parede 1+2+3+6).

**Testes adaptados à geometria nova (o que cada um pina agora):**
`low_quay_test` (52×36, âncora `[1,18]`, fauna spore, clear > -2, bandas
hall/espinha/cofre) · `challenger_test` + `dread_test` (posto `[41,18]`,
stance fora de alcance recua pra espinha) · `zone_tier_test` (lê o kit
REAL da primeira fila — lei aditiva do tier) · `open_gate_composition`,
`tile_registry_test`, `pilot_loop_test`, `worldsmith_intake_test`
(portas/chegadas novas) · `interior_door_test`: os 2 testes do fork
viraram **prova da aposentadoria + da migração L9**.

| Prova | Resultado |
|---|---|
| Suite | **1397 runs, 43232 assertions, 0 failures** (byte-pin do importer verde) |
| `rake map PROBES=1` | **21/21 PASS** — god-view mostra a serpente em DUNGEON 1 e o salão selado em ZONE 5 |
| Determinismo `dungeon_fork` | 6/6 byte-idênticas ×2 |
| Rule 2 crítico (`dungeon_fork`, `town_gates`, `multi_floor_descent`, `zone8_crossing`) + sentinela do musgo + soak `ZONES=low_quay,dungeon_1` | *owed: cadeia lançada após o commit; sweep 1+2+3+6 antes do merge* |

## Ticket 6.3 — `dungeon_2` (torre andar 2 = padrão A "divisória") + cap 15→16

**Ferramenta genérica:** `tools/build_tower_floor.py <n> [--down]` — n=2/3/4
= padrões A/B/C (`drafts/_medusa-tower/build_tower_candidates.py`, agora
importável); splice do level `dungeon_<n>` no `pilot.ldtk` + sidecar,
idempotente (rebuild determinístico); liga o andar de CIMA com
`stairs_down` no tile de saída dele (dungeon_1 = buraco central `[33,25]`);
`--down` liga este andar ao de baixo quando ele existir. **Leis mecânicas
no tool:** rocha fora do anel = `%` (2ª classe de parede), muralha = `#`,
piso = `.`; chegadas a 1 tile de toda porta (ping-pong law); BFS
chegada→escada; **ratio da volta forçada impresso e recusado se < 1.8**.

- **dungeon_2**: 52×52, floor -2, "DUNGEON 2". Porta de cima `[28,44]`
  (stairs_up → dungeon_1 `[33,24]`, livre); chegada `[29,44]`; escada de
  descida `[33,22]` (INERTE até dungeon_3). **Volta forçada: real 59 vs
  Manhattan 27 = 2.19×** (a mecânica do T da Medusa Tower, pinada em
  teste). dungeon_1 ganhou `stairs_down` `[33,25]` → dungeon_2 `[29,44]`
  **`requires_level: 8`** (proposta: 8/10/12 nos andares 2/3/4 — a
  fronteira já pede 8).
- **Fauna (serpent, tier ≤ 3):** stinger ×8 · warden ×4 · serpent_a ×10
  · serpent_b ×5, distribuídas por bandas de distância da chegada (fraco
  → forte), Chebyshev ≥ 2 entre spawns. **Clear 2055 > dungeon_1 2010**
  (L6). Sidecar: pedra cinza / muralha ferrugem / rocha escura,
  `drop_gradient` 3.5/4.0/4.5, 8 tochas nas paredes internas, `dust_motes`.
- **Cap 15→16** (L5 riding o andar; `pacing_table.rb` bancado: E(16) =
  46000, ΔE 8480 ≈ 566 kills de stinger ≈ 4.1 clears do andar 2).
- **`test/game/tower_floor_test.rb` (7)** — tabela por andar (cresce com
  6.4/6.5): forma/profundidade · **tudo andável dentro do anel e
  alcançável; fora = rocha** · **volta forçada ≥ 1.8×** · escadas nos 2
  sentidos, gate só na descida, chegadas a 1 tile e passáveis ·
  fauna = censo autorado e clear > andar de cima · **descer da medusa
  aterrissa ao lado da escada e o pack FICA** (anti ping-pong ao vivo) ·
  cap 16. Pins atualizados: `tile_registry_test` (edge ratificado
  dungeon_1↔dungeon_2), `tile_map_test` (15 zonas), `map_artifact_test`
  (DUNGEON 2 no god-view), `interior_door_test` (3 ways no dungeon_1),
  `pilot_authoring_test` ZONES += dungeon_2.

| Prova | Resultado |
|---|---|
| Suite | **1404 runs, 47911 assertions, 0 failures** |
| `rake map PROBES=1` | 21/21 · god-view mostra a torre redonda com a divisória (fiel ao shot) |
| FASE 6.1 gates (cadeia) | `dungeon_fork` **GATE PASS** (manifest `seal_breached` FAIL = **esperado**: o selo foi aposentado — script owed re-author) · `multi_floor_descent` **GATE PASS + MANIFEST PASS** · zone8_crossing + soak: em curso |

## Tickets 6.4 + 6.5 — `dungeon_3` (B espiral) + `dungeon_4` (C portão-pedágio, o FUNDO com BOSS 2) + cap →18

Mesmo tool (`build_tower_floor.py 3` · `4` · `2 --down` · `3 --down`):
a torre inteira está LIGADA — zone_7 hole → DUNGEON 1 (medusa) → `[33,25]`
stairs (lvl 8) → DUNGEON 2 → `[33,22]` stairs (lvl 10) → DUNGEON 3 →
`[34,27]` stairs (lvl 12) → **DUNGEON 4 = o fundo** (sem descida; a
"escada" do padrão C vira piso comum). Voltas livres em toda escada.

| Andar | Padrão | Volta forçada (real/Manhattan) | Fauna | Clear xp |
|---|---|---|---|---|
| DUNGEON 1 | medusa (serpente) | — | stinger 24 · warden 5 | 2010 |
| DUNGEON 2 | A divisória | **59/27 = 2.19×** | stinger 8 · warden 4 · serpent_a 10 · serpent_b 5 | 2055 |
| DUNGEON 3 | B espiral | **71/25 = 2.84×** | stinger 6 · warden 4 · serpent_a 8 · serpent_b 8 · serpent_c 4 | 2382 |
| DUNGEON 4 | C portão-pedágio | **56/20 = 2.80×** | warden 4 · serpent_a 6 · serpent_b 8 · serpent_c 8 · **serpent_boss (BOSS 2)** @ `[25,13]` (a ponta mais longe da chegada, dist ≥ 40) | 2434 |

**L6 monotônico no grão do clear** (2010 < 2055 < 2382 < 2434) e no grão
do kind (tier ≤ n+1 por andar). **Cap 15 → 18** em três degraus (16/17/18
riding 2/3/4, plano §6; `pacing_table.rb`: E(18) = 66640, ΔE(18) = 10960 ≈
731 stingers ≈ 4.5 clears do andar 4). Rungs 8/10/12 monótonas, a primeira
= a da fronteira (recorded: proposta ajustável pelos peers).

**Testes (`tower_floor_test.rb`, 9):** a tabela FLOORS cobre os 3 andares
— cada lei verificada em cada andar; + **o fundo tem BOSS 2 (3 fases) na
ponta da volta e nenhuma escada adiante** + rungs monótonas. Pins: 17
zonas, god-view com DUNGEON 1–4, edges ratificados 1↔2↔3↔4, pilot ZONES.

| Prova | Resultado |
|---|---|
| Suite | **1406 runs, 57717 assertions, 0 failures** |
| `rake map PROBES=1` | 21/21 · god-view: serpente → divisória → espiral → portão (os 3 desenhos do Junior, ordem que ele aprovou "A=2, B=3, C=4") |
| Rule 2 + soak da torre | owed: `tower{2,3,4}_run` (tuner, ticket 6.2) + `rake soak ZONES=dungeon_2,dungeon_3,dungeon_4` |

## Ticket 6.7 — BRASA (DUNGEON 5/6/7): a dungeon de fogo, família ember + BOSS 4 + `aura` + cap →21

**FASE 4.6 `aura`** (a primitiva que faltava pra família): campo ao redor
do portador vivo — todo hostil a ≤ `radius_tiles` (Chebyshev) queima
`damage` a cada `period_frames`. **Cadência = `world.frame % period`** →
zero campo novo no digest (determinístico por construção). Dano de campo =
`Creature#burn!` (a porta do poison generalizada: atravessa i-frames e
knockback, morte via `actor_died` com o portador como killer). Evento
`:aura_burn` registrado. **Leitura própria:** quadrado vazado cor-de-brasa
no alcance, que RESPIRA na cadência do burn ("aqui tu cozinha") — distinto
do taunt pulse (ferrugem, expande uma vez) e do totem (verde). Portador
`ember_b`: hp 85 · ring dmg 12 · aura r2 dmg 3/20f · kill_xp **70**.
Teste `aura_test.rb` (4): dentro queima na cadência / fora não · atravessa
i-frames e a morte nomeia o portador · determinístico, nada de "aura" no
digest.

**BRASA** — `tools/build_brasa.py` (determinístico, idempotente,
registry-driven, BFS em toda porta/chegada, recusa se os clears não
subirem acima do fundo da torre). **Geometria = candidatos APROVADOS pelo
peer re-tematizados** (o "veias" C e o "labirinto" B do musgo, 2026-08-31;
o "santuário" da leva 1 da torre como coração da forja):

| Zona | Display | Padrão | Fauna | Clear xp | Rung |
|---|---|---|---|---|---|
| ember_1 | DUNGEON 5 | veias (56×36) — veias de lava no basalto, câmara-coração a leste | ember_a 30 · ember_b 20 | **2750** > 2434 (fundo da torre) | 13 (boca) |
| ember_2 | DUNGEON 6 | labirinto (62×28) — a sala de boss old-school guarda o **GUARDIÃO** (ember_d elite, D3) | ember_a 14 · ember_b 24 · ember_d 5+1 | **2970** | 15 |
| ember_3 | DUNGEON 7 | santuário (56×32) — nave de colunatas → presbitério murado, **BOSS 4 no altar** | ember_a 8 · ember_b 20 · ember_d 10 · **ember_boss** | **3180** | 17 |

Boca: **buraco no prado sul da ZONE 7 `[6,24]`** (hole, auto-fire, rung
13 = um degrau acima da última escada da torre), corda de volta pousa
`[6,23]`. Escadas nos 2 sentidos, retornos livres, chegadas a 1 tile das
portas (lei do ping-pong, testada ao vivo). Piso vestido com **lava
decorativa `L` + entulho `r`** (tipos da FASE 3; passabilidade intocada —
teste) + 10 tochas/andar + `ember_sparks` 7% + `fog_bank` 4%; paleta
basalto/brasa, `drop_gradient` 4.0–6.0 (a BRASA paga mais que a torre no
grão do drop também). **Cap 18 → 21** (pacing bancado: E(21) = 108000,
ΔE(21) = 15280 ≈ 5 clears do DUNGEON 7). Strings `zone.*.display_name`
pros 6 novos placeholders nas 3 locales.

Teste `brasa_test.rb` (7): forma/labels · boca no prado + rung 13 + corda
livre ao lado · cadeia de escadas com rungs subindo e retornos livres · o
fundo não desce · **uma dungeon, uma família** + clears acima da torre e
monótonos · guardião na sala do labirinto + BOSS 4 no altar (3 fases) ·
lava/entulho passáveis · **cair na BRASA pousa ao lado da corda e o pack
fica**.

| Prova | Resultado |
|---|---|
| Suite | **1417 runs, 0 failures** |
| `rake map PROBES=1` | 21/21 (god-view com DUNGEON 1–7) |
| Rule 2 + soak BRASA | owed: `brasa{1,2,3}_run` (tuner) + soak — cadeia após o commit |

**Grafo final desta madrugada: 5 dungeons no total** (DESCIDA -1/-2/-3 ·
TORRE 1–4 · BRASA 5–7 · BASEMENT 1–2 · fronteira ZONE 8), **20 zonas**,
**3 bosses únicos** (BOSS 1 no cofre do musgo, BOSS 2 no fundo da torre,
BOSS 4 no altar da forja), cap 21.

## Sentinelas + gates + soak (a parede das zonas novas)

`tools/tune_sentinels.rb` (tuner genérico, padrão `tune_floor3_run.rb`):
rotas por waypoint, nível de chegada = rung do andar +2, **para no último
frame estável** se o pack colapsa (o sentinela anda reto e não esquiva —
ele prova legibilidade + determinismo das primeiras lutas, não a
dificuldade do andar; essa é veredito dos peers). v1 colapsou em 5/7
zonas (as zonas fundas MATAM um pack que anda reto — o conteúdo é difícil
como planejado) → v2 rotas curtas + recuo no colapso: 7/7 scripts
escritos, manifests = contagens observadas.

**+5 rows no `gate_checks.json` (79 → 84):** `moss_vault_reads` ·
`tower_floor_reads` · `brasa_reads_as_fire` · `ground_telegraphs_read` ·
`boss_phase_pips_read` (todas com "not exercised" quando a zona não está
em câmera). `dungeon_fork` → `harness/retired/` (o selo que ele exercitava
morreu no swap). Canary `ACTIVE` += `floor3_run` (musgo) + `brasa2_run`.

| Sentinela | Zona | 1ª passada (84 checks) | Leitura |
|---|---|---|---|
| tower2_run | DUNGEON 2 | **PASS 84/84** | — |
| tower4_run | DUNGEON 4 | **PASS** | — |
| brasa1_run | DUNGEON 5 | **PASS** | — |
| brasa2_run | DUNGEON 6 | **PASS** | — |
| floor3_run | ZONE 5 musgo | FAIL 3 rows de boss | crítico leu um **spore_a com flash de hurt** (verde × tint rosa = rosa) como "BOSS 1 sem nameplate" — o boss NUNCA aparece no reel (fica no cofre). Correção: 3 rows re-redigidas (boss = nameplate + corpo osso, nunca cor) + tint de hurt humano (255,120,120)→(215,70,45). Re-gate lançado |
| tower3_run | DUNGEON 3 | FAIL `hurt_flash_not_white` | **bug real de arte**: frame `hurt` lavava 55% pra BRANCO — um serpent_b cinza ferido lia branco. Correção no gerador: hurt = +vermelho, verdes/azuis caem (nunca branco); 18 atlases regenerados, md5 re-pinados. Re-gate lançado |
| brasa3_run | DUNGEON 7 | FAIL `pressure_ring_reads` | leitura tática do crítico sobre A2 pressure ring (aggro.rb intocado) — flip; re-gate |

**Soak:** `ZONES=dungeon_2,dungeon_3,dungeon_4` **PASS** (desyncs=0) ·
`ZONES=ember_1,ember_2,ember_3` **PASS** (desyncs=0). `ZONES=low_quay,dungeon_1`
PASS (6.1). Zero crash em 20k+15k+15k ticks de bot nas 8 zonas novas/trocadas.

## A PAREDE INTEIRA (gate do merge) — 2026-09-05 03:58–06:55

**Sweep FASE 1** (worktree, HEAD `5be2558`): 37 scripts. Manifests: 9 fails
= **exatamente o census T7** (zero regressão). Vision first-pass: 9 fails.
**Sweep 1+2+3+6** (worktree2, HEAD `31d4897`): 36 scripts (dungeon_fork
aposentado). Manifests: os mesmos 9 + `dungeon_fork` (esperado). Vision
first-pass: 6 fails — **conjunto DISJUNTO do sweep 1** (mesmos bytes nos
scripts que não pisam zonas novas → o sweep 2 É o re-run do sweep 1:
nenhum script falhou duas vezes). **Re-runs dos 6:** basement_pocket PASS
· lobber_volley PASS · specials_chain PASS · loot_loop PASS (2ª) ·
grass_fixture_walk PASS após corrigir a row `flora_variants_read` (pedia
"grid lines visíveis" — o grid está OFF por design desde a FASE 3/D7) ·
**vat_economy FAIL ×2 em `hud_level_strip_reads` + `lobber_reach_reads`**
(HUD level strip + geometria do volley — superfícies que este ciclo NÃO
tocou; script sem histórico de verdicts no log = row nova pra ele).
**→ DÍVIDA NOMEADA**, não regressão: `vat_economy` entra na classe de
re-author com `aoe_specials challenge_reads` (T7).

**Sentinelas (zonas novas), estado final:** floor3_run PASS (após rows de
boss re-redigidas: identificação por nameplate, nunca cor) · tower2 PASS
· tower3 PASS (após o fix do frame hurt) · tower4 PASS · brasa1 PASS ·
brasa2 PASS · brasa3 PASS (re-run; `pressure_ring_reads` = flip).
**7/7 verdes.** Soaks: 3/3 PASS, desyncs=0.

**Bugs reais pegos pela parede nesta madrugada (todos corrigidos):**
frame `hurt` lavava pra branco (gerador) · tint de hurt humano fazia verde
virar rosa (display) · 3 rows de boss sem lei de identificação · 2 rows
pinadas na geometria da medusa em ZONE 5 (seguiram o swap → DUNGEON 1)
· 1 row exigia grid lines (D7).

**Taxa de flip observada:** ~20% first-pass em ambos os sweeps (vs ~8% no
T7) — RECORDED como observação do ciclo: o crítico está recalibrando de
quads pra sprites; protocolo = re-run, nunca relaxar. Candidato de
follow-up: rows com "silhueta/sprite" no vocabulário.

## Fila da FASE 6

6.2 sentinelas (tuner): musgo `floor3_run` + `tower2_run` · re-author `dungeon_fork` (selo aposentado) · 6.6
`basement_3` · 6.7 BRASA (4 andares, `ember_*` + `ember_boss`, cap →21) ·
6.8 D5 (palavra dos peers).
