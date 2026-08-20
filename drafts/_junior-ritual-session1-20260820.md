# Junior — sessão de ritual COMPLETA (joiner, saída limpa) — evidência bancada

**Data:** 2026-08-20, fim 01:28:22 · **Assento:** Junior (seat=2, joiner)
**Build:** `56440e4` (pull antes de entrar; suíte local 908 runs / 17649 asserts verde)
**Log:** `drafts/_v18-seventeenth-evidence/game_two_session_2874720530.log`
(5387 B, md5 `78c684d654648ca2b55a0a012e2582bf`; original em `%TEMP%` desta máquina)

## Linhas do oráculo (verbatim do log deste assento)

```
AUDIO on: device=1 sha=15f03e0219d6 lib=C:/Users/jr/Desktop/projeto-game-two/game-two-audio
TELEMETRY persist loaded digest=66784a92f268776eeb917efb655449c6 schema=1 banked=12 provisions=0 seals=2 marks=0 sessions=8 source=handshake
TELEMETRY netplay seat=2 ticks=74470 desyncs=0 stalls=136 stall_ms_max=1059 reason=quit
TELEMETRY sustain bought=0 used=0 refused=0
```

## Fatos mecânicos (sem adjudicar — a adjudicação é do dev of record no harvest)

- **Saída LIMPA** (`reason=quit`), **desyncs=0**, **ticks=74470** (≥36000 exigido, ~2.07×).
- **Handshake carregou a âncora vigente** `66784a92…` sessions=8 — casa com o link #6
  bancado no lado do host; `source=handshake` como esperado para o joiner.
- **AUDIO ON neste assento** (device=1, sha do vendor conferido) → pelo amendment 2 do
  dono, o ramo do caveat 2 lê **novidade simétrica**, não a assimetria original.
  Registro do fato; a leitura formal é do harvest.
- Stalls: 136, pior 1059 ms (link engasgou às vezes — o jogo esperou em vez de
  dessincronizar, comportamento projetado). Rota Tailscale era DIRETA (~174 ms no
  pré-voo).
- `sustain bought=0 used=0 refused=0` neste assento — fato, roteamento é do harvest.
- **AUDIO drift:** cresce linear até `drift_frames=7187040` no tick 73800
  (≈97 frames/tick de PCM excedente ≈ mesma classe do débito ~800 fr/s já medido e
  atribuído ao assento de áudio no veredito M5a). Não afeta a sim (áudio é sink puro);
  registro para a lane de áudio.

## Estado do ritual após esta sessão (contagem, não veredito)

- Esta é **UMA** sessão coop válida deste assento. Half A exige **duas** (a sessão 2
  deve carregar o save que a sessão 1 gravou — custódia do host).
- **Respostas: 0/8** — quarentena de priming MANTIDA neste assento: nenhuma pergunta
  do ritual foi feita, sugerida ou comentada pelo agente; as perguntas são do dono.
- Nada do lado do jogador foi consertado nem tocado durante a sessão (pull de
  `game-two-assets` foi DEFERIDO durante a partida por higiene de medição; executado
  depois do fecho).
