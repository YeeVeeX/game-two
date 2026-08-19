# Junior — CRASH na sessão 1 do ritual (joiner) + re-tentativas sem conexão

**Data:** 2026-08-19 ~03:07 (madrugada, ritual "hoje à noite") · **Assento:** Junior (joiner)
**Ação tomada:** NENHUM fix (rota-não-conserta; routing table do ritual é fechada).
Launcher `join-coop.cmd` seguiu re-tentando sozinho; host avisado pelo humano.

## O que aconteceu (timeline dos logs, máquina do Junior)

1. **03:06 — sessão 1 sobe LIMPA:** `AUDIO on: device=1 sha=15f03e0219d6` (ordem
   do dono cumprida — assento com som) e handshake OK:
   `TELEMETRY persist loaded digest=189a80723c87b90f27bc8436533d8cc1 schema=1
   banked=20 provisions=0 seals=2 marks=0 sessions=6 source=handshake`
   — digest = a âncora esperada, sem skew, sem recusa.
2. **03:06:57 — CRASH no tick (o bug):**
   ```
   src/game/telemetry.rb:190:in 'block in Game::Telemetry#initialize':
     undefined method 'hp' for nil (NoMethodError)
       hp: @world ? @world.possessed.hp / @world.possessed.max_hp.to_f : 0.0,
   via event_bus.rb:57 process → world.rb:302 tick → session.rb:481 run_tick
   → session.rb:217 update → window.rb:110/82 → main.rb:174
   ```
   Hipótese mecânica (é hipótese, não adjudicação): snapshot de telemetria por
   evento com `@world.possessed == nil` — estado sem-corpo/espectador do co-op
   (v17) não guardado no handler. O guard `@world ?` checa o world, não o
   `possessed`.
3. **03:07:29 / 03:08:01 / 03:08:34 / 03:08:44+ — re-tentativas do launcher:**
   todas bootam com `AUDIO on` e morrem em
   `session.rb:143 TCPSocket#initialize: Blocking operation timed out!
   (IO::TimeoutError)` → o host não aceita (sessão de lá presa/caída após o
   crash do joiner; accept único). Launcher trata como "host fora do ar" e
   re-tenta (até 20×), como projetado.

## Provas (ficam NESTA máquina; pedir por ponteiro)

`%TEMP%\` do Junior (`C:\Users\jr\AppData\Local\Temp`):
- Sessão 1 (crash): `game_two_session_3058117708.log` (1484 B)
- Re-tentativas (timeout): `game_two_session_251843052.log`,
  `_389815149.log`, `_1349113106.log`, `_330831944.log` (864 B cada)
- Tailscale no momento: host `100.127.52.49` ativo via DERP "mia" ~222 ms,
  sem rota direta.

## Consequências para o ritual (fatos, sem adjudicar)

- Sessão 1 do joiner terminou em crash — **sem saída limpa, sem linha
  `TELEMETRY netplay`** deste lado; save não gravado por design (só quit limpo).
- O que É evidência positiva banked: AUDIO on no assento do Junior (ramo do
  caveat 2 = novidade simétrica) e o `persist loaded ... source=handshake` com
  o digest da âncora.
- Nenhum artefato `tmp/netplay/` esperado (foi crash, não desync).
- Quarentena de priming mantida: nada de continuidade/respawn/sustain
  discutido com o jogador; perguntas seguem virgens.
