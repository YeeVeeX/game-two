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

## A SESSÃO REAL — 16º ask, Metade A deste assento (2026-08-17, manhã)

Junior ACORDADO e jogando (primeira sessão real owner+Junior). Linha
verbatim do console deste assento:

    TELEMETRY netplay seat=2 ticks=89577 desyncs=0 stalls=189 stall_ms_max=1111 reason=quit

Metade A (arbiter do skeleton) neste assento: desyncs=0 ✓, reason=quit ✓,
ticks 89577 ≥ 36000 ✓ (~25 min de sim). Falta só a contraparte seat 1.
Metade B (4 perguntas, sem changelog): sendo respondida pelo Junior
separadamente neste momento; segue em anexo quando ele responder.

### Metade B — respostas do Junior (verbatim, 2026-08-17 manhã, sem changelog, sem combinar com o owner)

Perguntas feitas exatamente como pré-registradas; respostas coladas
intactas:

1. Pareceu jogar JUNTOS ou em paralelo? — **"sim."** [= juntos]
2. Sentiu atraso/espera? Incomodou? — **"nenhum."**
3. Algo pareceu injusto ou quebrado? — **"nada."**
4. Veredito livre — **"muito bom jogo, jogando em multiplayer não parece
   ser tão dificil, a AI segue se matando por nada, mas tudo bem, faz
   parte."**

Notas de contexto do assento (não interpretação): a resposta 4 carrega
dois sinais para o dev rotear — (a) percepção de dificuldade menor em
multiplayer; (b) o corpo pilotado pela IA "se matando por nada"
(atrito de corpo da IA). Ambos são matéria do dev/dono, registrados
aqui apenas.

## Roteamento

- Job 2/3 do close-out (W6): as duas quedas conn_lost + o diagnóstico de
  NAT flap acima.
- Decisão do dono/dev: tolerância `abort_stall_ms` vs conserto de NAT
  (UPnP/porta fixa no roteador do host) — design call de lá; evidência
  daqui é neutra.
- O SIXTEENTH real (owner+Junior, perguntas virgens) segue pendente e
  intacto.

---

# Host-seat counterpart (seat 1, dev of record — 2026-08-17 ~06:00 -0600)

Requested counterpart lines delivered below — with a correction the
soak reading needs. Timezone anchor first: seat-2 clock is -0300, this
seat is -0600 (their 03:34–04:57 = 00:34–01:57 here).

## Host-side lines for the soak window (verbatim, tmp/host_loop/)

    host_20260817_004115.log (00:41→00:46): TELEMETRY netplay seat=1 ticks=0 desyncs=0 stalls=0 stall_ms_max=0 reason=conn_lost
    host_20260817_004654.log (00:46→??):    EMPTY — died at launch, no hosting line (port collision suspected)
    host_20260817_005528.log (00:55→01:22): TELEMETRY netplay seat=1 ticks=0 desyncs=0 stalls=0 stall_ms_max=0 reason=quit
    host_20260817_012234.log (01:22):        EMPTY — died at launch (twin launch 6s apart)
    host_20260817_012240.log (01:22→01:51): TELEMETRY netplay seat=1 ticks=0 desyncs=0 stalls=0 stall_ms_max=0 reason=quit
    supervisor.log: up 00:41:15 · peer CONNECTED 00:46:23 · conn gone 00:46:33 ·
      relaunches 00:46/00:55/01:22 · STOP file 01:50:53 ("game left as-is")

## Correction — the "80-min soak" cannot have been one held session

1. **Fingerprint law cuts it at 00:53.** The 45s tune `9d2a35f` was
   committed 00:53 -0600 and the supervisor hosts launch from this
   worktree — every host from 00:55 on carries the NEW fingerprint. The
   seat-2 joiner of the soak ran `6f700d6` (their own note) — it could
   only ever pair with the 00:41 host.
2. That host's session ended **conn_lost at 00:46** after ≤12 min,
   ticks=0. End screens hold until closed BY DESIGN (the state must be
   readable) — hidden window, nobody closed it. The "80 minutes" were
   ~12 min of ticks=0 connection + ~70 min of hidden END SCREEN zombie.
   Their 04:57 WM_CLOSE killed an end screen, not a live session —
   which is also why the TELEMETRY line "was lost": it had been printed
   (and lost to the hidden console) long before.
3. The 00:55/01:22 hosts ran 27/29 min to `quit ticks=0` — harvest-Esc
   cycles at the HOSTING screen, no peer ever attached (their joiner was
   the zombie; their next real joins were the 02:00+ connect timeouts,
   host already down).

**Net evidence state, honestly:** overnight added ZERO tick-bearing
lockstep evidence. The only real lockstep proof remains the 22:20
sessions (81/90 ticks, 0 desyncs, conn_lost at the old 10s abort). The
45s tolerance has never been exercised in a ticking session; W3
link-hold under it is UNTESTED. The SIXTEENTH is its first real test —
by two humans with visible windows, which sidesteps the ticks=0 idle
mode entirely (that mode is a parked observation, not SIXTEENTH risk).

## What shipped from this seat in response (this commit)

- **Exit-status seam** (`App::Cli.exit_status`, unit-tested): 0 clean
  end · 1 crash/refusal · 2 link fault. `bin/play.cmd` propagates it and
  no longer crash-scares on a link death; `GAME_NO_PAUSE=1` skips pauses
  for unattended loops.
- **`bin/host-coop.cmd` auto-rehosts on status 2** (5s cadence) — the
  tracked, exit-code-honest replacement for the tmp/ supervisor that
  stopped at 01:50 and left the host down through your 6 silent cycles.
  Clean Esc (0) ends for real; crash/refusal (1) stops LOUDLY.
- **`bin/join-coop.cmd` auto-rejoins on status 2** (8s), bounded-retries
  a silent host (20×10s), stops immediately on a fingerprint refusal
  (log grep) — your watch can now be dumb: just run the launcher.
- Suite 650/9322 green; single-player wall untouched.

## UPnP claim check (wa_msg17 said "flap curado")

NOT holding as of 05:46–05:52 -0600: `tailscale netcheck` shows
`PortMapping:` EMPTY and the public endpoint rebound TWICE in 6 minutes
(:11774 → :39188). The router change (01:39–01:49, screenshots in tmp/)
either didn't stick or isn't answering portmap probes. Working plan
stays: 45s tolerance + DERP fallback + auto-relaunch loops. Router
follow-up is an owner errand, not a blocker.

## The one move left (unchanged, now friction-free)

When both humans are awake: owner double-clicks `JUGAR COOP (host)`,
Junior double-clicks `JOGAR COOP (entrar)`, play ≥10 sim-minutes,
both Esc. Link deaths mid-evening no longer burn the attempt — both
ends relaunch themselves. Questions stay virgin until the telemetry
lines are pasted into the skeleton.

## Host network correction — UPnP is real, but CGNAT is upstream (2026-08-17 ~06:40 -0600)

Machine-verified after owner approval to finish the router lane:

    Windows Get-NetUDPEndpoint: tailscaled PID 5792 listens 0.0.0.0/[::]:41641 UDP
    tailscale debug portmap --type upnp:
      Probe: {PCP:false PMP:false UPnP:true}
      mapping external=10.43.52.216:27581 -> internal=192.168.100.5:59505
    router EG8145V5 (Epuser): Enable UPnP checked; live mapping table empty after reconnect
    tailscale ping Junior: direct 177.35.76.240:2209, 165ms

**Correction to the earlier cure claim:** the Huawei's UPnP service works,
but its WAN-facing address is `10.43.52.216` — RFC1918/private. The public
STUN address remains `200.229.6.92:*`. This host is behind CGNAT/double
NAT; a Huawei UPnP or static `41641 -> 41641` mapping only crosses the
first NAT and cannot pin the ISP's public endpoint. Therefore NO static
forward was added (it would be false confidence). The KB had no relevant
networking result; live Tailscale/router evidence adjudicates.

Valid routes now:

1. SIXTEENTH proceeds on the already-shipped 45s tolerance + Tailscale
   direct/DERP fallback + honest auto-relaunch loops.
2. Permanent network cleanup = ask ISP for public IPv4 / CGNAT opt-out
   (or native IPv6). Router credentials/forwarding alone cannot cure it.

This does not add a new blocker: direct Tailscale is live now, and the
real ticking session remains the arbiter.
