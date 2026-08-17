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

## Roteamento

- Job 2/3 do close-out (W6): as duas quedas conn_lost + o diagnóstico de
  NAT flap acima.
- Decisão do dono/dev: tolerância `abort_stall_ms` vs conserto de NAT
  (UPnP/porta fixa no roteador do host) — design call de lá; evidência
  daqui é neutra.
- O SIXTEENTH real (owner+Junior, perguntas virgens) segue pendente e
  intacto.
