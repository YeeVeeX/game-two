# MUNDO VIVO — FASE 4: primitivas de comportamento (SIM) — Junior seat, 2026-09-05

**FREEZE: liberado** (s125 — sim numbers unlocked). **CLAIMED:** FASE 4
(branch `junior/mundo-vivo`). Lei: **uma primitiva por ticket, teste
boot+combat ANTES de qualquer zona depender** (precedente stinger T7).
Cada primitiva = chave em `combat.json` + kind portador + kill_xp (L6) +
arte + leitura visual própria. Nenhuma zona toca os kinds novos nesta
fase (FASE 6 os coloca) → sim-identity das zonas vivas byte-intocada.

## Ticket 4.1 — `spread` (leque de projéteis) · portador: `serpent_a` (torre, tier 2)

- **`src/game/world.rb#launch_spread`** — `spread_count` tiros saem do
  mesmo tile em direções do anel 8-way centradas no facing (3 = facing
  ±45°; 5 = ±90°). Cada tiro é um `Projectile` comum (**uma lei de
  combate**: dano/alcance/knockback do kit, atravessa aliados, para em
  parede). **UM** evento `projectile_fired` por leque (o manifest conta
  casts, não pellets). Rotação = caminhada em tabela (`SPREAD_RING`) —
  determinístico. world.rb 1712→1740 (cap 1800; extração owed no
  próximo toque material).
- `creature.rb`: `spread` é arco ranged (sem action_tiles próprios) ·
  `controllers.rb`: `RANGED_ARCS = projectile|spread` — o engage genérico
  (alinhamento 8-way, dist ∈ [2, range], line_clear, retreat_step quando
  colado) serve o leque sem código novo.
- **`combat.json` `serpent_a`**: hp 70 · dmg 12 · windup 26 · exhaust 96 ·
  `arc: spread, spread_count: 3, range_tiles: 4` · respawn 1800 ·
  `interrupt_on_hit`. **`progression.json` kill_xp 75** (L6: stinger 65 <
  serpent_a 75 < warden 90).
- Arte: `serpent_a` no gerador (S enrolado + capuz aberto violeta-cinza —
  nenhum corpo tem violeta) + `KIT_BODY` fallback; manifest md5 re-pinado.
- **Teste `test/game/spread_test.rb` (4):** kit é caster com xp row L6 ·
  **um cast → 3 projéteis reais** nas direções `[ring[i-1], facing,
  ring[i+1]]` · pellet central aterrissa e fere pela lei única · **digest
  determinístico** com leques em voo (dois Worlds, mesmo script).

**Leitura visual própria (gate "3 specials, 3 visuais"):** os 3 pellets
em leque já desenham como projéteis (retângulos pálidos); a assinatura
"leque" é a geometria. Gate owed quando um script exercitar o kind
(FASE 6, andar 2 da torre) — nenhuma zona viva mudou.

| Prova | Resultado |
|---|---|
| Suite | **1374 runs, 39062 assertions, 0 failures** |
| Zonas vivas | nenhuma referência a `serpent_a` em `data/zones/` → sim-identity intocada |

## Ticket 4.2 — `petrify` (congelamento telegrafado) · portador: `serpent_b` (torre, tier 3)

- **Sim = data-only**: `stagger_frames: 90` já flui por `apply_action_hit`;
  o kit é um `arc3` melee com **windup 44** (dodgeável por design) e dano
  baixo (10 < warden 22 — controle, não burst). `petrify: true` no attack
  é a flag de leitura do renderer.
- **Leitura visual própria (3ª família de telegraph):** o flare do windup
  vira **cinza-pedra** (edge `[120,120,130]`, core `[215,215,225]`,
  `display.json petrify_*_rgb`) — "isto vai te congelar", distinto do
  vermelho/amarelo (ferir) e dos brackets laranja (volley).
- `combat.json serpent_b`: hp 95 · step 16 · aggro 7 · exhaust 150 ·
  respawn 2100 · kill_xp **85** (75 < 85 < 90). Arte: enrosco baixo +
  capuz largo com olhos, cinza-pedra (a estátua).
- **Teste `test/game/petrify_test.rb` (3):** forma do kit (windup ≥40,
  stagger ≥60, dano < warden, L6) · **o acerto congela**: `staggered?` +
  `stagger ≥ 90-6`, e um press de movimento NÃO move o corpo · o windup é
  legível como petrify antes de aterrissar (`telegraphing?` +
  `action_config[:petrify]`).

## Ticket 4.3 — `blink` (teleporte curto pro flanco) · portador: `serpent_c` (torre, tier 4)

- **`creature.rb`**: `blink!(tile, face_toward:)` (teleport + facing +
  `@blink_cooldown` do kit + `@blink_flash` presentation), `blink_ready?`,
  tick dos dois contadores. **`blink_cooldown` entra no digest** (verdade
  de sim; classificado `session_only` no save — morre com a sessão, como
  `seize_cooldown`); o flash NÃO (presentation).
- **`controllers.rb#try_blink`** (chamado no topo de `engage`): kind com
  `kit[:blink]`, off-cooldown, a ≥ `min_tiles` do alvo → teleporta pra um
  tile livre/passável **atrás do alvo** (o lado oposto à aproximação),
  candidatos em ordem fixa (atrás → flancos) = determinístico; encara o
  alvo; emite **`:blinked`** (evento registrado em `World::EVENTS`).
- **Leitura visual própria:** quadrado violeta vazado que FECHA sobre o
  corpo nos `flash_frames` da chegada ("não estava aí um instante atrás";
  `display.json blink_flash_rgb`).
- `combat.json serpent_c`: hp 60 · step 10 (o mais rápido da família) ·
  `front1` dmg 16 windup 14 · `blink {min_tiles 4, cooldown 240, flash 10}`
  · kill_xp **88** (85 < 88 < 90). Arte: chicote fino + cauda bifurcada,
  violeta profundo.
- **Teste `test/game/blink_test.rb` (4):** forma (min ≥3, cd ≥120, L6) ·
  **hunter longe pisca pra trás do alvo e o encara** (evento 1×, tile =
  `body.x-1`, facing `[1,0]`, cooldown armado, flash armado) · sem blink
  dentro de `min_tiles` nem em cooldown · **determinístico e digested**
  (dois Worlds mesmo digest; `blink_cooldown` no snapshot).
- Pins atualizados: `state_digest_test` (CREATURE_FIELDS) e
  `save_state_test` (CLASSIFICATION) — o mecanismo que garante que
  nenhum campo novo entra no digest sem decisão de persistência.

**Família serpent completa (torre):** stinger (T1, projectile) → warden
(T1-2, ring) → **serpent_a (T2, spread 75)** → **serpent_b (T3, petrify
85)** → **serpent_c (T4, blink 88)**. Cada kind ≥ 1 primitiva diferente
dos irmãos (requisito §4.5). Boss final (BOSS 2) = FASE 5.

| Prova (4.1–4.3) | Resultado |
|---|---|
| Suite | **1381 runs, 39510 assertions, 0 failures** |
| Zonas vivas | zero referências a serpent_* em `data/zones/` → sim-identity intocada |
| world.rb | 1740/1800 (extração owed no próximo toque material) |

## Ticket 4.4 — `charge` + `beam` (as duas linhas da BRASA) · portadores: `ember_a` (T1), `ember_d` (T4)

- **`charge` = um ATAQUE que é dash** (a gramática do special do striker,
  lado hostil): `start_attack(blocked:)` planeja o dash no início (a
  linha existe no windup → telegraph de chão), `activate_action` commita
  + i-frames, `resolve_dash_action` (já genérico) fere todo hostil na
  linha cruzada e empurra (`knockback_tiles 2`). `controllers.rb`: regra
  de alcance própria — alinhado 8-way, dist ∈ [2, max_tiles], linha
  livre; adjacente ou desalinhado = anda, nunca carrega.
- **`beam` = linha reta até a primeira parede** (`action_tiles` novo
  caso: `beam_length` tiles ao longo do facing, para em `#`), resolvida
  como tile action comum (uma lei de combate; `hit_victims` = 1 acerto
  por vítima). Windup **50** (a faixa de esquiva existe). Controller:
  `RANGED_ARCS += beam` (recua se colado, como caster), alcance
  alinhado ∈ [2, beam_length].
- **Leituras visuais próprias (4ª família de telegraph = CHÃO):**
  windup desenha a linha no piso — vermelho-escuro (charge) / brasa-
  escura (beam); ativo = stroke laranja-fogo (charge) / feixe laranja
  (beam), ambos distintos do branco-ciano do pack e do vermelho do
  golpe comum. `display.json charge_*/beam_*_rgb`.
- `combat.json`: `ember_a` hp 65 · dash 6 tiles @3f · dmg 18 · kb 2 ·
  windup 30 · exhaust 120 · **kill_xp 45** (T1 da brasa) · `ember_d`
  hp 110 · beam 8 · dmg 20 · windup 50 · active 6 · exhaust 180 ·
  **kill_xp 110** (T4 < challenger 120). `grid_walker.rb`: `map` reader
  (o beam lê passabilidade). Arte: touro-cunha com chifres (charger),
  pilar alto com um olho ardente (caster) — vermelho-fogo, mais
  escuro/vermelho que o laranja do pack.
- **Teste `test/game/charge_beam_test.rb` (7):** forma/xp · **carga
  alinhada a 4 tiles inicia, corre a linha, fere e empurra** (o corpo
  muda de tile, o charger MOVEU) · adjacente/desalinhado nunca carrega ·
  forma do beam · **tiles do beam correm o facing e param na parede** ·
  **o beam fere UMA vez o corpo na linha** · charge+beam determinísticos
  (dois Worlds, mesmo digest).

**Estado da FASE 4 (4 tickets, 5 primitivas): `spread` `petrify` `blink`
`charge` `beam`** — 2 famílias servidas: serpent (T1–T4 completa) e ember
(T1 + T4; `aura` e `pool` = próximos, precisam de loop de tick próprio +
estado novo no digest). Suite **1388 runs, 0 failures**. world.rb 1740/1800.

## Ticket 4.5 — `poison` (dano ao longo do tempo) · portadores: `spore_a` (T1), `spore_b` (T2) — a família do MUSGO (piso -3)

- **`creature.rb`**: estado `poison_ticks/dmg/interval/countdown/by`;
  `poison!` (re-aplicação REFRESCA — max(ticks), nunca acumula);
  `tick_poison` em `tick_body` — o tick **atravessa i-frames e ignora
  knockback** (não é um golpe) mas **a morte passa pela mesma porta**
  (`actor_died` com o envenenador como killer → xp/drops/corpse pela lei
  única). 4 campos no digest (`session_only` no save, como
  iframes/hurt_frames).
- **`world.rb`**: `apply_action_hit` aplica `cfg[:poison]` no acerto que
  aterrissa + evento registrado **`:poisoned`**.
- **Leitura visual própria:** pulso verde-doente no corpo envenenado
  (janelas de 6 frames; sprite tint E quad fallback) — nenhum outro
  estado de corpo é verde; o DOT lê sem número.
- `combat.json`: `spore_a` hp 55 · arc3 dmg 8 · poison 3×4 a cada 30f ·
  kill_xp **70** · `spore_b` hp 90 · ring dmg 10 kb 1 · poison 4×5/30f ·
  kill_xp **95**. Arte: cogumelo fino (a) / capuz largo com anel de
  esporos (b), verde-fungo saturado (o lurker é alga pálida).
- **Economia do piso -3 (musgo A):** 14×spore_a + 9×spore_b + BOSS 1 =
  **1955 xp/clear > 1780 do -2** (L6 "deep pays more" preservado — a
  regressão interim do spec do swap deixa de existir).
- **Teste `test/game/poison_test.rb` (5):** forma + gradiente L6 + clear
  > -2 · **golpe envenena, tick passa pelos i-frames, DOT expira** ·
  refresh sem stack · **morte por veneno = actor_died com killer =
  envenenador** · digested e determinístico.

**FASE 4 fechada nesta sessão: 6 primitivas** (`spread` `petrify` `blink`
`charge` `beam` `poison`), 3 famílias servidas (serpent T1–T4, ember
T1+T4, spore T1–T2). Suite **1398 runs, 0 failures**. world.rb 1745/1800.
Ficam: `aura` `pool` `pull` `summon` (tick loop + estado próprio).

## Fila (ordem do plano FASE 0 §4)

`aura` → `pool` (brasa) · `pull` → `summon` (basement) · `pull` → `summon` (basement) · D2 decide os
da dungeon 5. Bloco `boss` = FASE 5.
