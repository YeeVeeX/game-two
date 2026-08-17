# v17 fun-verify — SIXTEENTH ask, skeleton (2026-08-16, STANDBY — session not yet run)

Protocol: spec `2026-08-16-v17-multiplayer-etapa1-design.md` §Fun-verify,
verbatim (no adaptations needed — the protocol was written after the
placeholder order). Two seats, two halves. Evidence harvested from BOTH
seats BEFORE any question. A dev session never runs the live session;
it adjudicates what the seats paste.

## Session ritual (what must happen before this file gets a verdict)

1. Owner sends Junior the tailnet invite; Junior accepts — DONE 2026-08-16
   (desktop-gu3bmkt, 100.71.34.81, on the moralgabriel tailnet; this
   machine is now **gabo-desktop 100.127.52.49** post tailnet surgery).
2. Junior: `git pull` on junior-tibia (fingerprint refusal names the
   stale field otherwise — W6; fired live 2026-08-16, fixed `10b6138`).
3. Owner hosts: double-click `JUGAR COOP (host)` / `bin/host-coop.cmd`
   (resolves + copies the live tailnet IP; auto-rehosts on link death).
4. Junior joins: double-click `JOGAR COOP (entrar)` / `bin\join-coop.cmd`
   (resolves the host live; auto-rejoins on link death — exit-status 2
   seam, only link faults loop).
5. Play ≥ 10 sim-minutes (ticks ≥ 36000). BOTH seats exit by Esc.
   Link deaths mid-run don't burn the attempt — the launchers relaunch
   both ends; the ticks arbiter reads the SINGLE longest session's line.
6. Both launchers print the harvest lines at close (`TELEMETRY netplay`,
   plus `desync report:` / `relaunch:` when applicable; backup = the
   session log named at launch). Paste BOTH lines here BEFORE questions.

## Contamination disclosure (honest, up front)

- **Owner (es):** ratified the v17 design at the debate — knows it is
  lockstep co-op and that stalls freeze both seats. Has NOT seen the
  build in motion (all Rule-2 netplay surfaces were gated by critic,
  never shown to him). Clean first contact: connection flow, partner
  ring, stall/gate/no-body overlays, the latency feel itself.
- **Junior (pt-br):** ratified the eight PT-BR labels (`ae4e960`,
  "ta legal assim") — TEXT-contaminated by authorship; did etapa-0
  (replay + digest ritual, "divertida, quero mais"). Has NOT played
  live co-op. Clean first contact: the live feel, the latency, the
  shared-zone-gate rule in practice.
- Neither player is shown a changelog before answering (protocol law).

## Telemetry slots (harvest BEFORE questions — verbatim lines, both seats)

```
seat 1 (owner, host):
TELEMETRY netplay seat=1 ticks=89575 desyncs=0 stalls=5149 stall_ms_max=1113 reason=quit

seat 2 (Junior, joiner — he pastes via drafts/ or message relay):
TELEMETRY netplay seat=2 ticks=89577 desyncs=0 stalls=189 stall_ms_max=1111 reason=quit
```

Provenance (2026-08-17 morning session, ~10:12→10:37 -0600): seat 1
recovered verbatim from the play.cmd session log
(`%TEMP%\game_two_session_1012229766.log`, copy preserved at
`tmp/netplay/owner_seat_session_20260817.log` with the full gameplay
telemetry block — BOSS 1 engaged AND slain, seal2 breached, 34 fights,
3 wipes). Seat 2 pasted verbatim by Junior's seat in
`drafts/_junior-sixteenth-shakedown-20260817.md` §A SESSÃO REAL.
No desync artifact appeared in `tmp/netplay/` during the session window
(dir untouched since the 07:21 gate runs) — corroborates desyncs=0.

## Half A (HELD) — arbiter, mechanical

PASS iff ALL of:
- `desyncs=0` on BOTH lines;
- `reason=quit` on BOTH lines;
- `ticks ≥ 36000` on each seat's line.

**ADJUDICATED 2026-08-17: PASS.** desyncs=0 ✓/✓ · reason=quit ✓/✓ ·
ticks 89575/89577 ≥ 36000 ✓/✓ (~24.9 sim-minutes, 2.5× the target; the
2-tick skew is the BYE landing inside the delay pipeline — both seats
inside D=8, expected shape). Stall reading (informational): seat 1
stalled 5149 updates (max 1.1s) vs seat 2's 189 — the wait lived on the
host's inbound path, consistent with the host-side NAT-rebind diagnosis;
the 45s tolerance was never approached.

Stall stats (`stalls`, `stall_ms_max`) are informational — they feed the
reading of half B, they never flip half A. Any desync ⇒ half A FAILS and
the TWO `tmp/netplay/desync_*.json` artifacts (one per seat) are the next
work item — bank the diff, don't average it. (tmp/netplay/ was swept
clean of build residue on 2026-08-16 — anything appearing there now is
live-session evidence.)

## Half B (TOGETHER) — asked SEPARATELY, no changelog shown

Owner (es, this order):
1. ¿Se sintió como jugar JUNTOS, o como jugar en paralelo?
2. ¿Sentiste la espera/latencia? ¿Molestó?
3. ¿Algo se sintió injusto o roto?
4. Veredicto global libre.

Junior (pt-br, mirrored):
1. Pareceu jogar JUNTOS ou em paralelo?
2. Sentiu atraso/espera? Incomodou?
3. Algo pareceu injusto ou quebrado?
4. Veredicto livre.

### Junior — answered 2026-08-17 morning (verbatim relay, his seat's
### capture in `_junior-sixteenth-shakedown-20260817.md`; no changelog shown)

1. **"sim."** [= juntos]
2. **"nenhum."**
3. **"nada."**
4. **"muito bom jogo, jogando em multiplayer não parece ser tão dificil,
   a AI segue se matando por nada, mas tudo bem, faz parte."**

Routing per the pre-registered table: answer 4 signal (a) multiplayer
perceived easier → dev/owner difficulty item, recorded only; signal (b)
AI third body "se matando por nada" → v17.1 embodiment debate item,
recorded only (matches the pre-registered "AI third body named weird"
row). Answers 1–3 trip no routing rows.

### Owner — PENDING (asked 2026-08-17, same protocol: separately, no
### changelog; answers paste verbatim below when given)

## Routing (pre-registered — closed at the spec, do not re-litigate)

- desyncs>0 → digest-diff work item (etapa-1 scope): diff the two
  artifacts' snapshot+lines; the differing digest_fields NAME the
  diverging system. Fix + regate + re-session.
- Stalls felt + link diagnosis → D/link tuning re-session
  (data/netplay.json knobs, probe-derived D) — NEVER rollback.
- Stall STORMS with clean digests → etapa-2 netcode debate
  (UDP+redundancy first candidate; PARKING_LOT.md carries the entry);
  higher-D re-session meanwhile.
- "Paralelo, no juntos" with a clean hold → v17.1 embodiment
  PRESENTATION debate (shared-goal cues), recorded not auto-built.
- Latency named unfair → check D derivation before touching the sim.
- AI third body named weird/in-the-way → v17.1 embodiment debate item,
  recorded only.

---

# VERDICT (pending — filled only when both seats' evidence is pasted)
