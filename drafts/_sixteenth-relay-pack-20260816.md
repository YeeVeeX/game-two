# SIXTEENTH relay pack — night-support log (2026-08-16, dev at the owner's wheel)

Owner order (verbatim, es): "puedes hacer la mayoría por mi al menos para
dejarlo listo de solamente jugar y ya para mi?" + "I will sleep myself,
please play and coordinate with Junior in pt-br as if you were me" + "he
already knows you will be taking the steering wheel on my end".

Dev line held: coordinate + shakedown YES; the SIXTEENTH itself is NOT
run by the dev (Half B needs the OWNER playing his own seat). Tonight =
technical shakedown (link/W3/W6 proof) + Junior's first taste. The 4
pre-registered questions stay VIRGIN (not sent tonight — they burn on
first exposure; they belong to the real owner+Junior session).

## Machine prep (all verified live tonight)

- Port bind: `TCPServer 0.0.0.0:43117` + accept via 100.127.147.29 — OK.
- Firewall: NO change needed — `Tailscale-In` allows all inbound to
  100.127.147.29/32 (profile Private) and Ruby 3.4.10 has its own Allow
  rules. Verified via `netsh advfirewall firewall show rule`.
- Tailnet: this machine 100.127.147.29 (mmh-gw); Junior NOT joined at
  session start (status: only mmh-gw + offline iPhone).
- Invite link generated from the owner's admin console (CDP, Users →
  Invite external users → Copy invite link, role Member):
  `https://login.tailscale.com/uinv/iynoWDU4nv11kpmb6ggbK11`
  ("Approval is required" is ON — approve in Users when Junior signs up.)
- Launcher: `bin/host-coop.cmd` (+ Desktop `JUGAR COOP (host).cmd`) —
  pull --ff-only, live tailnet IP print + clipboard, `check` mode; both
  tested (check mode, exit 0).

## WhatsApp log (channel: owner's WA Web via CDP 9223, chat "Junior 2pac")

- 8:02 p.m. OUT (dev, disclosed): invite link + 4 steps (aceitar convite,
  avisar para aprovação, git pull, join na senha "pode entrar") + Esc/
  TELEMETRY harvest + honest note (dev body mostly idle tonight; real
  match is with Gabriel).
- 8:04 p.m. IN (Junior): "bro yo respondo eso aonde?"
- 8:05 p.m. OUT (dev): link = browser on his PC; commands = black window
  (cmd) in the game folder, git pull first, play only on signal.
- (log continues in checkpoint / next session notes)

## To send ONLY after the REAL session's telemetry is harvested (both seats)

Junior (pt-br, separately, no changelog):
1. Pareceu jogar JUNTOS ou em paralelo?
2. Sentiu atraso/espera? Incomodou?
3. Algo pareceu injusto ou quebrado?
4. Veredito livre.

Owner (es, separately):
1. ¿Se sintió como jugar JUNTOS, o como jugar en paralelo?
2. ¿Sentiste la espera/latencia? ¿Molestó?
3. ¿Algo se sintió injusto o roto?
4. Veredicto global libre.

## Tonight's telemetry law

Any `TELEMETRY netplay` line harvested tonight (dev-piloted seat 1) is
SHAKEDOWN evidence: it can prove/deny the link hold (W3/W6) and count
desyncs (a desync tonight = job-2 work item, fully valid), but it is NOT
the SIXTEENTH's Half A (the SIXTEENTH session is owner+Junior; ticks
arbiter unchanged). Recorded so nobody upgrades it later.
