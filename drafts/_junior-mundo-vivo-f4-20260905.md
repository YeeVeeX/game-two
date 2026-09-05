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

## Fila (ordem do plano FASE 0 §4)

`petrify` → `blink` (torre) · `charge` → `aura` → `pool` → `beam`
(brasa) · `pull` → `summon` (basement) · `poison` (musgo) · D2 decide os
da dungeon 5. Bloco `boss` = FASE 5.
