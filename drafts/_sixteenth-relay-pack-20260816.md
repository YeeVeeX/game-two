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

## Night log (2026-08-16, 20:02–23:00 — what actually happened)

- 20:02–21:03 WA coordination: invite sent → Junior signed up (user PPX,
  jrmaciell92@gmail.com) → approved via console → his device
  desktop-gu3bmkt joined (100.71.34.81, TS 1.102.2, Win10 21H2).
- **Tailnet surgery (recorded):** the local client was logged into the
  YeeVeeX@github tailnet, but the owner's browser console (where the
  invite came from) is the moralgabriel@gmail.com tailnet — two different
  tailnets; Junior landed in the second. Fix: `tailscale login` on this
  machine under moralgabriel@gmail.com (browser-auth driven via CDP).
  Machine is now **gabo-desktop 100.127.52.49** on moralgabriel's
  tailnet; the YeeVeeX account remains available — revert =
  `tailscale switch yeeveex.github`. Firewall rule auto-followed the new
  IP; bind+accept re-verified on it.
- **Junior's seat is ALSO agent-driven tonight** (owner pre-cleared:
  "he already knows"). Their agent port-PROBED the host before joining —
  the probe consumed the single accept and killed host #1 (found dead
  with empty log; server socket closes at accept by design). Lesson
  relayed: no probes, the game's join IS the test.
- **W6 fired FOR REAL and was fixed:** first genuine join refused —
  `sim fingerprint: ours ≠ theirs` at both-on-6f700d6. Root cause: EOL.
  My working tree had Gemfile.lock w/crlf (git ls-files --eol) while
  their clone differs in flavor — tree_md5 hashed raw bytes, so NO clean
  clone could ever match. Fix `10b6138`: fingerprint md5s are
  EOL-normalized (\r\n|\r → \n); TDD (failing CRLF-vs-LF test first),
  suite 645/9315 green, all three netplay gates re-PASS with critic.
- **Handshake PROVEN cross-machine after the fix.** Connection #1 (22:20):
  `TELEMETRY netplay seat=1 ticks=81 desyncs=0 stalls=745
  stall_ms_max=10014 reason=conn_lost` — 81 real lockstep ticks, ZERO
  desyncs, then their process went silent → honest 10 s abort. Connection
  #2: `ticks=0 … reason=conn_lost` (died pre-handshake — crash or another
  probe). Their primary evidence (their %TEMP% session log) REQUESTED and
  pending; host intentionally left down until it arrives.
- End-screen harvesting from an agent seat: PostMessage WM_KEYDOWN Esc to
  the Gosu hwnd works (SendKeys/SetForegroundWindow do NOT — focus-steal
  rules); helper banked at tmp/esc_ruby2.ps1 (session-local).
- No desync artifact from the live sessions (tmp/netplay/ tick-60 files
  are tonight's gate/suite regenerations — timestamps 21:50–21:52,
  pre-connection).

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
