---
lane: a3-stalemate
branch: lane/a3-stalemate
owns:
  - src/game/controllers.rb
  - data/balance/threat.json
  - test/game/ally_brain_test.rb
  - test/game/ally_stalemate_test.rb
  - drafts/lanes/receipts/a3-stalemate.md
never:
  - drafts/lanes/*.md
  - src/game/world.rb
  - src/game/creature.rb
  - src/game/aggro.rb
  - src/net/protocol.rb
  - src/game/save_state.rb
  - data/display.json
  - data/strings/
  - data/bindings.json
  - data/balance/economy.json
  - harness/gate_checks.json
  - harness/scripts/
  - test/net/state_digest_test.rb
  - test/game/save_state_test.rb
  - test/harness/sim_identity_canary_test.rb
  - data/art/
  - docs/
  - AGENTS.md
---
# Raia `a3-stalemate` (raia de PROVA do time multi-agente; trabalho util)

## Objetivo
Corrigir o STALEMATE de "ranged hold" do cerebro aliado (A3), achado nomeado em
`drafts/_a3-ally-brain-audit-20260905.md` §4: com o cerebro ON em `brasa2_run`, dois `ember_a`
ficam ~280 frames em cadencia leash -> re-acquire -> leash, hp congelado, sem dano pra nenhum
lado. O aliado a distancia segura `ranged_hold_tiles` e alinha o tiro; o ember nunca fecha o
gap (caminho bloqueado / slot de pressao) e nunca desengaja. **Candidato (a), preferido pelo
audit §5**: *o aliado avanca quando o alvo nao consegue alcanca-lo* — se o humano focado NAO se
moveu por N frames e esta fora do proprio alcance de ataque do aliado, o aliado a distancia fecha
UM tile (numero em dados: `ally.stalemate_frames` em `data/balance/threat.json`; sem numero magico
no codigo). Fora do stalemate, comportamento identico ao atual.

O cerebro segue **OFF por padrao** (`ally.enabled: false` — palavra do dono, s133 "nao me convence").
Esta raia muda codigo que so roda com ON; o caminho OFF tem de ficar byte-identico.

## Definition of Done
1. `src/game/controllers.rb`: em `ally_engage` (ramo `projectile?`), a regra do stalemate, lida de
   `cfg` (a `ally_config(view)` ja entrega o bloco `ally`). Deteccao **tick-driven** (contagem de
   frames do sim, nunca relogio) e **deterministica** (ordem fixa; nada de `rand`/`Time`). O estado
   "ha quantos frames o alvo esta parado" pode viver no controller (nao e digest) — se precisar de
   campo novo em `Creature`, NAO toque `creature.rb`: PATCH REQUEST com a linha exata.
2. `data/balance/threat.json`: `ally.stalemate_frames` (sugestao inicial 180 = 3 s a 60 fps; o
   numero e do dono, marque como proposta no receipt) e `ally.stalemate_advance_tiles: 1`.
3. `test/game/ally_stalemate_test.rb` (novo, seu): prova deterministica, sem janela: (i) alvo parado
   N frames + fora do alcance -> o aliado a distancia da UM passo em direcao ao alvo; (ii) alvo em
   movimento -> nao avanca (comportamento antigo); (iii) `ally.enabled: false` -> caminho intocado.
   Teste local pode ligar o cerebro **na config do teste** (nunca em `threat.json` commitado).
4. Canarios byte-identicos: `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run` tem de
   mostrar `= ACTIVE bank? | YES` x3 (o cerebro esta OFF: o diff OFF-vs-bank nao pode mudar).
   Se mudar, a alteracao vazou pro caminho OFF -> bug seu.
5. `world.rb` NAO muda (1798/1800 linhas: nem uma linha). `controllers.rb` sem cap, mas extraia se
   passar de ~620.
6. Suite verde (`bundle exec rake`), `ruby tools/lane_guard.rb a3-stalemate --trust junior/premium-build`
   rc 0 antes de cada commit, branch publicado, receipt escrito.

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief -> o audit §4-§5. As leis do repo
   valem inteiras (data-driven, tick-driven, digest classificado, sem nomes de lore, fallback).
2. Trabalhe SO no branch `lane/a3-stalemate` (ja criado pelo integrador a partir de
   `junior/premium-build`, no worktree que voce recebeu). Comite SO dentro de `owns`. Antes de cada
   commit: `ruby tools/lane_guard.rb a3-stalemate --trust junior/premium-build` (rc 0 = pode).
   **Nesta rodada o ref confiavel e `junior/premium-build`** (os briefs ainda nao estao em `main`).
3. Precisa mudar um arquivo fora de `owns`? NAO toque. Escreva um PATCH REQUEST no SEU receipt
   `drafts/lanes/receipts/a3-stalemate.md` (arquivo, chave/linha, valor exato, por que). O
   integrador aplica e dobra no BOARD. Briefs e BOARD sao do integrador (a cerca recusa).
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`,
   `harness/run_wall.sh`). So headless: `bundle exec rake`, arquivos de teste isolados,
   `tools/a3_stream_diff.rb`, `tools/a3_leash_trace.rb`.
5. `src/game/**` exige `SIM LANE: a3-stalemate` no BOARD do ref confiavel — concedido para esta
   rodada (veja `drafts/lanes/BOARD.md`). So `controllers.rb`; `world.rb`/`creature.rb`/`aggro.rb`
   continuam fechados (never).
6. Voce PODE lancar ajudantes com o tool `subagent` (read-only): um `scout` pra mapear
   `ally_engage`/`leash_home`/`aggro.rb` e o caminho do `human_leashed` antes de editar; um
   `reviewer` pra olhar seu diff antes do receipt. Voce continua o unico escritor da raia.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/a3-stalemate`, e o receipt
   `RECEIPT: a3-stalemate <sha> READY <resumo de 1 linha>` (+ PATCH REQUESTS + numero proposto).
   Se travar, diga exatamente em que; nunca alargue o escopo pra destravar.
