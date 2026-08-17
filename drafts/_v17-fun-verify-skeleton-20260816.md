# v17 fun-verify — SIXTEENTH ask, skeleton (2026-08-16, STANDBY — session not yet run)

Protocol: spec `2026-08-16-v17-multiplayer-etapa1-design.md` §Fun-verify,
verbatim (no adaptations needed — the protocol was written after the
placeholder order). Two seats, two halves. Evidence harvested from BOTH
seats BEFORE any question. A dev session never runs the live session;
it adjudicates what the seats paste.

## Session ritual (what must happen before this file gets a verdict)

1. Owner sends Junior the tailnet invite; Junior accepts (his machine is
   NOT on the tailnet as of 2026-08-16 — verified via `tailscale status`:
   only mmh-gw + an offline iPhone).
2. Junior: `git pull` on junior-tibia (fingerprint refusal names the
   stale field otherwise — W6).
3. Owner hosts: `bin/play es --host` → passes his tailnet IP
   (**100.127.147.29**, port default 43117).
4. Junior joins: `bin\play.cmd pt-br --join 100.127.147.29`.
5. Play ≥ 10 sim-minutes (ticks ≥ 36000). BOTH seats exit by Esc.
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
(paste: TELEMETRY netplay seat=1 ticks=... desyncs=... stalls=... stall_ms_max=... reason=...)

seat 2 (Junior, joiner — he pastes via drafts/ or message relay):
(paste: TELEMETRY netplay seat=2 ticks=... desyncs=... stalls=... stall_ms_max=... reason=...)
```

## Half A (HELD) — arbiter, mechanical

PASS iff ALL of:
- `desyncs=0` on BOTH lines;
- `reason=quit` on BOTH lines;
- `ticks ≥ 36000` on each seat's line.

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
