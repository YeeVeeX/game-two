# Soak joiner — retorno do assento do Junior (2026-08-18)

Executado conforme `drafts/_v18-soak-runsheet-junior-20260818.md`
(md5 conferido `78601600d82ea6901057fd4f7d46f345`), commit `65d60de`
nos dois disparos, host `100.127.52.49` (Tailscale). **Corrida de robô —
nunca evidência do ritual** (linha do esqueleto respeitada).

## Tentativa 1 — 17:52, falha de agendamento (registro D7)

Disparo antes do host estar de pé: `TCPSocket` estourou
`IO::TimeoutError` no connect (`src/net/session.rb:143`), exit 1,
`SOAK FAIL: joiner has no TELEMETRY netplay line`. Sondagem na hora:
ping ao IP Tailscale OK (~212 ms), porta 43218 fechada — host ausente
(fusível expirado ou ainda não lançado). Caso previsto no runsheet
("could not connect" → esperar "listo" novo). Artefatos:
`tmp/soak/20260818-175253/` (local, gitignored).

## Tentativa 2 — 18:01, pós-"listo": **SOAK PASS**

Run `tmp/soak/20260818-180058`, EP1 port=43218, joiner pid 6480.

`report.txt` verbatim:

```
SOAK CHECK mode=join_only min_ticks=36000 episodes=1
EP1 SKIP host (join_only run)
EP1 joiner: seed=1003175435 ticks=36121 desyncs=0 reason=quit exit=0
EP1 SKIP host persistence (joiner never persists)
EP1 PASS
SOAK PASS episodes=1
```

`ep1/joiner.log` verbatim (16 linhas, íntegra):

```
AUTOPILOT seed=1003175435 quit_tick=39720
TELEMETRY d1_fired carrying_deaths=0 wipes=0 corpse_looted=0 carried_lost=0 banked_events=0 fights=0 recovery_fights=0 negative_fights=0
TELEMETRY a2_fired wipes=0 body_deaths=0 retargets{hate=0 lowhp=0 proximity=0 acquired=0 challenged=0} leashes=0 deepest_band=0 banked=0
TELEMETRY d1b_fired inscriptions=0 marks_consumed=0 dissolved=0 regrown=0 tributes=0 floor_fired=0 banked_spent{inscribe=0 tribute=0} banked_end=0
TELEMETRY q6_cadence banks{n=0 mean=0 max=0} kills_by_band{b0=0 b1=0 b2=0}
TELEMETRY density pockets{mean=0.0 max=0} arrivals{pocket=0 seed=0 home=0} singles_pct=0
TELEMETRY arc breach{fired=0 first_frame=0 banked_after=0} rehomed=0 camp_visits=0 d2{entered=0 kills=0} seal2_breached=0
TELEMETRY q6_margins banks{n=0 pure=0} amount{mean=0 max=0} hp{mean=0.00} dead{mean=0.0} wounded{mean=0.0} gap{mean_s=0}
TELEMETRY v13 whirl{casts=23 hits{1=0 2=0 3=0 4=0 5plus=0} kills=0} challenge{casts=26 retargets=0}
TELEMETRY drift thirds{k1=0 k2=0 k3=0} pockets{p1=0.0 p2=0.0 p3=0.0} span_thirds{k1=0 k2=0 k3=0 span=0}
TELEMETRY v14 telegraphs_shown=0 first_special{striker=772 blocker=363 lobber=1192}
TELEMETRY quay entries=0 frames=0 kills=0 deaths=0 banked_after{events=0 amount=0}
TELEMETRY varekka engaged=0 chants=0 interrupted=0 seized=0 swap_escapes=0 slain=0 deaths_while_seized=0 burns=0 ends{expired=0 slain=0 died=0 zone_left=0 wiped=0}
TELEMETRY sustain bought=0 used=0 refused=27
TELEMETRY netplay seat=2 ticks=36121 desyncs=0 stalls=0 stall_ms_max=0 reason=quit
```

Destaque: `desyncs=0 stalls=0 stall_ms_max=0` em 36.121 ticks pela
internet real — a conexão nem engasgou.

## Observações anotadas (não mexi em nada — lei de rotear, não consertar)

1. **Heartbeat em JOIN_ONLY spamma erro cosmético:** a cada 60 s,
   `soak/run_soak.sh: line 91: tmp/soak/<run>/ep1/host.log: No such
   file or directory` — em join_only não existe host.log local; o stat
   do heartbeat podia pular o lado ausente.
2. **Log do joiner fica em 43 B durante a partida inteira** (só o
   banner; heartbeats `joiner=43B` do início ao fim) — o TELEMETRY
   descarrega na saída limpa. Para heartbeat de vida do JOINER, o log
   não diferencia "jogando" de "travado"; o fusível cobre, mas fica o
   registro.
3. `sustain refused=27` = robô apertando a tecla de suprimento sem
   saldo no save de rascunho — ruído esperado de bot, não sinal.

Sem pendências deste lado; próximo passo é do dev (colher isto na
sessão 8). O ritual continua intocado — duas sessões humanas em dias
diferentes.
