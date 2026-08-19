# Quality flywheel — plan (2026-08-19, owner-directed)

Owner direction (es, live chat, dev session 16 — verbatim fragments):
"arrancar con mejorar ese soak ahora ... testear todas las áreas y con
todo el movimiento de enemigos, habilidades, efectos, sonidos y
acciones paralelas actuando a la vez ... grabar una ventana para
pasarla por el pipeline de Gamesmith ... evaluar lo visual, gameplay y
audio, + la experiencia del juego y calidad en general ... tomar
máximo provecho de las herramientas que hemos ido armando ... mejorar
la calidad de nuestro juego aún más desde una etapa más temprana".

Frame: the tools already exist — this plan WIRES them, it does not
invent new ones. Deterministic replay (harness) + frame capture
(Gosu.render) + ffmpeg (8.1 on PATH, verified) + video_analyst.py
(Tibia-era, in-repo) + Gamesmith (sibling, paid, citation-gated) +
soak (session 8) + KB rubrics. Findings become RECORDED work items
with evidence; the same clip that found an issue re-verifies its fix.

## Lane 1 — Soak v2: zone-seeded coverage (S-M, first)

Problem: autopilot is a random walker + wipes respawn at home_zone →
bots live in the starting zone forever (owner observed this live).
The test-driver law (autopilot header: "DELIBERATELY dumb ... the
moment this gets tuned for realism, stop and record") stays — bots
get NO intelligence.

Solution: seed the SCRATCH save per episode. A soak-side fabricator
(soak/seed_save.rb) writes a schema-valid world.json (through the
real SaveStore encode path, never hand-rolled JSON) with:
- `home_zone` = the episode's target zone (respawns keep bots there),
- `breached` = the seals needed for that zone to be reachable/alive,
- members alive, banked enough to exercise sustain buys (bots press
  U on cadence — banked>0 turns refusals into real buys/uses).

Episode plan (run_soak.sh gains a ZONES= list, default today's
behavior): ep-per-zone across every zone in data/zones/*; coverage
asserted per-episode in chain_check (evidence of life in the target
zone from existing telemetry counters/log lines; missing coverage =
named FAIL). Quarantine laws unchanged (real save md5 + temp-log
count). AUDIO on bots: env flag SOAK_AUDIO=1 boots the bridge in
noDevice mode on bot seats (real mixer graph, no hardware; watch
dropped_cues + teardown lines). Default stays off.

Constraint honored: no edits to soak/* or src/* while the live
6-episode run executes (memory law) — lane 1 lands after it closes.

## Lane 2 — Deterministic video + tiered critique (M, same day)

1. **Frame dump → MP4:** replay_runner gains a video mode (dump every
   Nth rendered frame as PNG during a scripted run; ffmpeg assembles
   30 fps MP4). Deterministic: same script + seed ⇒ byte-stable frames
   ⇒ comparable videos across builds. First targets: the wall's
   canonical trio (world_loop, low_quay_run, varekka_duel).
2. **Cheap continuous critique (in-repo):** adapt video_analyst.py →
   harness/self_eval.py with a SELF-evaluation persona/lens (appeal /
   entertainment / fluidity / action readability / juice), rubric
   pulled from KB (uiux-design + game-research domains). Cost ≈ $2-5
   per clip (voice-dev Bedrock, batch caps + tripwire kept). Run per
   meaningful change; verdicts land beside the gate verdicts.
3. **Deep milestone review (Gamesmith, paid):** record a REAL session
   (OS capture with audio — ffmpeg gdigrab + WASAPI — or the
   assembled clips), `ingest` local file, per-recording stages →
   reverse design doc of OUR game under the same lens that read
   Tibia/Daggerfall/Warhaven/New World/RuneScape. Budget: ~$691
   remaining of $1000; estimate $20-50/recording; **each paid run
   needs the owner's explicit go with the cost named** (gamesmith
   repo law). Cadence: milestones (post-v18 verdict, post-assets),
   not per-change.
4. **Assets-era payoff (recorded now):** when game-two-assets exports
   land, re-run the SAME scripts → before/after videos → diff the
   critiques. Same for audio passes (owner renders) once OS capture
   carries sound.

## Lane 3 — Discipline (what ships when)

- Infra, soak, video/eval tooling, audio/data polish: ship now
  (owner's 2026-08-19 freeze lift).
- **Respawn / difficulty / sustain mechanics: WAIT for the ritual
  verdict** — they are the SEVENTEENTH's own questions; retuning them
  mid-measure destroys the pre-registered reading (dev
  recommendation, owner may override).
- Eval findings: RECORDED items with evidence (clip + timestamp +
  critique quote); fixes re-verified against the same clip; visual
  changes still pass the Rule 2 gate (vision critic) as today.
- Measurement hygiene unchanged: ritual questions virgin, bot logs
  never fun-evidence, verbatim harvest.
- v19 brainstorm inherits: first flywheel findings + corpus brief +
  v19 idea pool + M5a deferred lanes.

## Sequencing (from 2026-08-19)

1. TODAY (soak run in flight): this plan doc; self-eval persona/rubric
   prep (KB query); no soak/src edits.
2. Soak run closes → lane 1 (seed fabricator + ZONES + coverage
   assert + SOAK_AUDIO) with tests; zone-coverage soak overnight-able.
3. Lane 2 frame-dump + assembly; pilot clip (world_loop) → adapted
   self-eval run (≤$5, tripwired); results to the owner.
4. Owner go-points: full 3-clip eval (cheap), Gamesmith deep run
   (paid, named cost), any mechanics retune (post-verdict).

## Budgets / stop conditions

- Lane 1+2 build: this session + next; no fan-out sessions needed.
- Bedrock spend without a fresh owner go: ≤ $5 (one pilot clip).
- Gamesmith paid stages: ZERO runs without explicit owner go.
- Any defect found by soak/eval: recorded; tripwire-shape fixes only
  in-session (TDD, own commit, wall owed detached).
