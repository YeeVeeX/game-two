# Shakedown do SIXTEENTH — assento do Junior (2026-08-17, madrugada)

Evidência formal deste assento (seat 2) da primeira noite de tentativas
de sessão cross-machine real. NÃO é o SIXTEENTH (lei do relay pack:
shakedown nunca vira Half A); é evidência de W3/W6 e insumo do job 2/3.

## Telemetria colhida (verbatim, %TEMP%\game_two_session_*.log)

Tentativa A — a sessão que RODOU (handshake pós-fix `10b6138` PASSOU,
lockstep real entre as duas máquinas):

    TELEMETRY netplay seat=2 ticks=90 desyncs=0 stalls=546 stall_ms_max=9847 reason=conn_lost

Contraparte seat 1 (recebida via WhatsApp, verbatim do outro assento):

    TELEMETRY netplay seat=1 ticks=81 desyncs=0 stalls=745 stall_ms_max=10014 reason=conn_lost

Tentativa B — conectou e caiu no tick 0 (flap no meio do handshake):

    TELEMETRY netplay seat=2 ticks=0 desyncs=0 stalls=0 stall_ms_max=0 reason=conn_lost

Leitura: **zero desyncs em lockstep real** — a integridade da sim
cross-machine segurou; tudo que caiu foi LINK. Ticks divergentes
(81 vs 90) = cada sim rodou sozinha os últimos instantes de surdez antes
do abort de 10s de cada lado — assinatura de corte no meio do caminho,
não de processo morto.

## Diagnóstico de rede (medido deste assento)

- Tailnet ok: esta máquina (`desktop-gu3bmkt`, 100.71.34.81) enxerga
  `gabo-desktop` (100.127.52.49); disco ping ~160ms direto.
- **Causa raiz das quedas: NAT rebind no lado host** — endpoint público
  de lá flipa `200.229.6.92:28960 ↔ :1024`; a cada flip o caminho
  WireGuard fica surdo por segundos-minutos. O stall de 9.8s da
  tentativa A morreu por décimos contra `abort_stall_ms: 10000`.
- Este assento: netcheck limpo (UDP ok, NAT estável, UPnP, DERP sao
  49ms) — o flap não é daqui.
- Padrão observado: túnel decai minutos após cada restart do Tailscale
  de lá; depois ESTABILIZOU (~30+ min contínuos de pong no fim da noite).

## Fix validado ao vivo

`10b6138` (fingerprint EOL-normalizado) **confirmado entre as duas
máquinas**: o REFUSED de fingerprint sumiu e o handshake fechou na
primeira janela pós-fix. (Antes do fix, este assento provou por
`git cat-file blob` que 6f700d6 limpo só tem 2 renderizações — CRLF
`848fc704...`, LF `09a8a0fd...` — e o hash do host não era nenhuma:
era o Gemfile.lock CRLF no worktree de lá.)

## Estado ao estacionar (~02h30 local)

- Host de lá NO CHÃO desde a queda da tentativa B (~40+ min); 16
  tentativas silenciosas de re-join deste assento, todas connect
  timeout (nada escutando). Túnel vivo e estável no fim.
- Proposto ao outro assento (WhatsApp): host em laço `:loop` /
  `call bin\play.cmd es --host` / `goto loop`; este assento re-entra
  sozinho a cada janela viva.
- Lições operacionais deste assento: (1) NUNCA sondar a 43117 com TCP —
  probe consome o único accept e o host aborta em 10s (derrubou o host
  na 1ª janela da noite); (2) join silencioso p/ laço:
  `ruby -Isrc src/main.rb --join <ip>` via `Start-Process -WindowStyle
  Hidden` com stdout redirecionado (sem janela de erro; Gosu abre a
  janela do jogo normalmente ao conectar).

## Adendo (mesma madrugada, pós-estacionamento)

Verificação cross-machine do `10b6138` COMPLETA neste assento: suíte
verde no hook do commit desta evidência; os 3 gates de netplay PASS
(`SKIP_CRITIC=1`, metade determinismo — 12/4/4 capturas byte-idênticas);
PNGs inspecionados no olho (protocolo local sem crítico): `LINK SLOW` +
anel do player 2 + faixa de controles legíveis no netplay_session;
`CONNECTION LOST — SESSION ENDED` honesto no netplay_conn_lost.

Ferramenta do assento shippada: `bin/join-coop.cmd` — espelho PT-BR do
`host-coop.cmd` (pull --ff-only, resolve o host AO VIVO pelo
`tailscale status`, preflight de link só com ping Tailscale — porta do
jogo jamais sondada —, modo `check` testado exit 0). Atalho de Desktop
local criado fora do git, como no assento host.

## Vigília noturna (armada ~03h local, DISCLOSED)

O Junior foi dormir; este assento fica em **vigília automática** (agente,
owner pre-cleared — "he already knows"): a cada ~10 min, `git pull
--ff-only` + ping Tailscale no host; se o host estiver de pé, um join
silencioso entra com o **assento 2 OCIOSO**. Regras da vigília, na lei
do relay pack:

- Toda linha `TELEMETRY netplay` colhida assim é **shakedown W3/W6**
  (prova de link hold / contagem de desyncs) — NUNCA Half A do
  SIXTEENTH. As 4 perguntas seguem VIRGENS.
- Linhas colhidas são anexadas abaixo (verbatim) e pushadas.
- A porta do jogo jamais é sondada; o join do jogo é o único probe.
- Sessão real (Junior acordado) retoma quando os dois humanos
  coincidirem.

### Linhas colhidas pela vigília

- **SOAK ~80 min (03:34→~04:57 local, join deste assento no build
  6f700d6/abort-10s):** sessão segurou de ponta a ponta sem abort — link
  hold ~8× a meta de 10 min, atravessando inclusive a janela do conserto
  de UPnP no roteador do host. A linha TELEMETRY deste lado FOI PERDIDA
  no encerramento (lição: o join oculto via `-WindowStyle Hidden`
  esconde a janela do Gosu → Esc postado não chega e o WM_CLOSE não
  flusha o stdout; joins da vigília agora saem `-WindowStyle Minimized`).
  **A contraparte do host tem a linha** — supervisor de lá, favor anexar.
- Encerramento da soak foi ESTE assento (WM_CLOSE ~04:57) de propósito:
  liberar o slot para re-entrar no build novo `9d2a35f` (fingerprint
  mudou). Pós-pull, 2 joins (~05:00 e ~05:03) deram connect timeout —
  túnel OK (pong 165ms, endpoint novo 63746), logo o host não estava
  escutando nesses instantes (ciclo do supervisor?). O laço daqui segue
  tentando a cada ~10 min.
- **~05:00→06:04: host mudo em 6 ciclos seguidos** (túnel ok via
  DERP-mia ~600ms — caminho direto ainda renegociando pós-UPnP; todo
  join = connect timeout). Leitura: o supervisor/host de lá parou de
  ciclar por volta das 05:00 (~02:00 -0600). Este assento segue
  tentando a cada ~10 min, sem intervenção necessária aqui.

**Resposta à pergunta do assento host ("O Junior está acordado?"): NÃO
— dorme.** A mensagem chegou colada aqui com "sleep" no fim. Portanto:
tudo desta madrugada segue sendo shakedown W3/W6 de assento ocioso; as
4 perguntas continuam VIRGENS; a sessão REAL espera o Junior acordar
(manhã dele). Quando ele acordar, o join está a um duplo-clique
(`JOGAR COOP (entrar)` no Desktop dele).

## Roteamento

- Job 2/3 do close-out (W6): as duas quedas conn_lost + o diagnóstico de
  NAT flap acima.
- Decisão do dono/dev: tolerância `abort_stall_ms` vs conserto de NAT
  (UPnP/porta fixa no roteador do host) — design call de lá; evidência
  daqui é neutra.
- O SIXTEENTH real (owner+Junior, perguntas virgens) segue pendente e
  intacto.
