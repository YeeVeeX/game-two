# MUNDO VIVO — FASE 5: sistema de boss (bloco `boss`) — Junior seat, 2026-09-05

**FREEZE: liberado** (s125). **CLAIMED:** FASE 5 (branch `junior/mundo-vivo`,
sobre FASE 4 `8bbb0ee`). Classe: SIM (data-driven, um pedaço gated).
**D3 executado na recomendação do dev: guardião + final** (o bloco suporta
ambos; esta fase entrega os FINAIS de duas dungeons; guardiões = kinds
elite existentes com 1 primitiva, sem fases — FASE 6 coloca).

## O bloco (`combat.json` → `kits.<kind>.boss`)

```
"boss": { "role": "final"|"guardian", "defeat_counts": true,
          "phases": [ {"hp_pct": 100, "skills": [<attack cfg>, …]},
                      {"hp_pct": 60,  "skills": [...]}, … ] }
```

- **`creature.rb`**: `kit` deixa de ser `attr_reader` e vira a **visão
  mesclada** — pra um boss com fases, `kit[:attack]` é a skill atual da
  fase atual (`@kit.merge(attack: skill)`, cache por (fase, índice) — zero
  alocação por frame). **Fase = f(hp%)** (última fase cujo `hp_pct` ≥ hp
  atual; autoradas descendo 100/60/30) — deriva do estado, não é estado.
  **Skill = índice rotacionado a cada `attack_started`**
  (`advance_boss_skill!` em `begin_action`) — **`boss_skill_index` entra
  no digest** (verdade de sim; `session_only` no save: o boss re-entra na
  skill 0). Todo leitor (controller range rules, world resolve, renderer
  telegraph) enxerga a skill viva sem código novo — a lei de uma-visão.
- **BOSS 1 (challenger): `boss: {role final, defeat_counts, phases: []}`**
  — com `phases: []` o `kit` retorna o MESMO objeto `@kit` (teste
  `equal?`): comportamento byte-idêntico, canaries de sim-identity
  intocados. Migrado pro bloco sem mudar números (lei do plano §4.6).
- **BOSS 2 (`serpent_boss`, fundo da torre):** hp 320 · 3 fases —
  100%: `spread×5` · 60%: `spread×5 + petrify` · 30%: `beam8 + spread×5 +
  petrify` · `blink` próprio (min 5, cd 300) · kill_xp **240**.
- **BOSS 4 (`ember_boss`, fundo da BRASA):** hp 380 · 3 fases — 100%:
  `charge8` · 50%: `charge8 + beam10` · 25%: `beam10 + charge8 + beam10`
  · kill_xp **320** (> serpent_boss 240 > challenger 120: mais fundo paga
  mais, L6 entre dungeons).
- **Unicidade (§4.6):** teste prova que nenhum par de bosses compartilha
  o mesmo conjunto de arcos.
- **Leitura visual:** nameplate pra TODO boss (`BOSS N`, placeholder law;
  `BOSS_NAMES` no renderer) + **pips de fase** sob o nome — um quadrado
  vazado por fase, o atual preenchido (`display.json boss_pip_rgb`). A
  luta tem um ARCO legível no corpo — primeira resposta concreta ao
  "vazio de objetivo" do verdict. Arte: sino largo + coroa (serpent_boss,
  violeta saturado); bloco maciço + chifres + coroa de brasas (ember_boss).

## Testes — `test/game/boss_phases_test.rb` (5)

BOSS 1 mantém o kit EXATO com fases vazias · todo boss é único e paga
mais que a elite da família (e a BRASA > torre > descida) · **fase segue
o hp e a skill ativa troca** (55% → fase 2; 20% → fase 3 abre com beam) ·
**skills rotacionam a cada início de ataque dentro da fase** (casts ficam
dentro das fases realmente alcançadas — o pack revida e o hp cruza
limiares no meio do run: a mecânica funcionando) · **rotação digested e
determinística** (dois Worlds, mesmo digest). Pins `state_digest_test` +
`save_state_test` atualizados (o mecanismo que impede campo novo sem
decisão de persistência).

| Prova | Resultado |
|---|---|
| Suite | **1393 runs, 40034 assertions, 0 failures** |
| Zonas vivas | zero referências a `*_boss` em `data/zones/` → sim-identity intocada; challenger byte-igual |

## Dívida herdada (recorded, não fechada aqui)

Re-author das coreografias `varekka_duel`/`burn_duel` (`harness/retired/`)
+ `aoe_specials challenge_reads`: continuam owed — o BOSS 1 não mudou,
então a re-autoria é sobre a GEOMETRIA nova do piso -3 (swap, FASE 6),
não sobre este bloco. Ticket próprio após o swap.
