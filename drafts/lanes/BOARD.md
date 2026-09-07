# BOARD - estado vivo das raias (INTEGRADOR-ONLY; a cerca recusa raias aqui)
> EN: machine rows `SIM LANE:` / `RECEIPT:` and every path are English; prose is pt-br for the running seat.

SIM TOKEN: Gabriel (T1 schema 3 / player record) - next: s4-equipment (v24)
SIM LANE: NONE
(a3-stalemate teve a concessao de 10:45 a 11:24 em 2026-09-06, so `controllers.rb`, so no branch `lane/a3-stalemate`;
entregou e devolveu. Ref confiavel da cerca = `origin/main` (briefs pousados na main em 2026-09-07, ff 72a3ae6).)
INTEGRADOR: dev seat (Junior's session)

Duas linhas: `SIM TOKEN: <quem, humano> ...` = atribuicao (prosa); `SIM LANE: <lane|NONE>` = a linha que a
cerca LE (machine row). So a raia nomeada em SIM LANE pode tocar `src/game/**`.
Raias escrevem SEUS receipts em `drafts/lanes/receipts/<lane>.md`; o integrador dobra aqui.

## Receipts (dobrados pelo integrador)
RECEIPT: signage 7dcb601 READY (lane/signage @ c35640a, rebased + ff) commit 1 = App::Signage extracted from renderer.rb
  2124 -> 1969 byte-inert (bodies textually identical, integrator gates md5 vs wall #4) · commit 2 = pressure outline only
  when the body IS on the ring: Signage.pressure_outline? (role :pressuring AND Chebyshev <= pressure_outline_max_tiles 3 =
  ring radius 2 + 1 [aggro.rb:108, threat.json:5] AND Signage.sight_open? - a PRESENTATION Bresenham, NOT the sim's 8-way
  shot ray; integrator decision B in-thread after the lane proved the sim ray refuses 8 of the 16 ring slots; agreement
  test 57,280 aligned pairs / 0 disagreements). Integrator validated: fence --base 193e148 rc 0 (6 paths = owns), suite
  1534/0, canaries YES x3, no clock/rand. PATCH REQUEST applied: renderer.rb cap 2000 in line_caps_test. Team: lane-worker
  (fable) + scout + reviewer (OK, no P1; P2s fixed c35640a). Rule 2: gates after wall #4 closes (window).
RECEIPT: e3-presentation f880c7c READY (branch lane/e3-presentation, rebased + ff into junior/premium-build) ticket E3 4/4:
  b5 38 knobs escritos + 176 defaults removidos + teste de existencia · F-A3-1 safe_chip_y 138 · b3 prompt sse World#interact age
  na propria tile (rope_spot prompta; ao lado/totem nao) · b4 minimapa: aberta = ouro, trancada = cinza, MESMO predicado
  Renderer.way_locked? da sinalizacao. Integrador validou no worktree: cerca --base 13a223c rc 0 (16 paths = owns), suite
  1519/0, canarios OFF = ACTIVE x3, sem relogio/rand. PATCH REQUESTS aplicados pelo integrador: d12 minimap_reads (ouro =
  aberta, cinza = trancada) + clausula interact_prompt_reads. Time: lane-worker (fable) + scout + reviewer (fable: 1 P1 real
  - ControlsOverlay recebia display nil num Renderer.new nu - corrigido f880c7c com teste). Rule 2: gates com janela +
  parede #4 pelo integrador. renderer.rb 2099 -> 2124 (+25, extracao b3) = divida nomeada (sem cap formal).
RECEIPT: a3-stalemate 97ce289 READY (branch lane/a3-stalemate @ ca4beb3, pushed) ranged-hold stalemate rule, brain-ON only, data
  `ally.stalemate_frames`=180 / `stalemate_advance_tiles`=1 (PROPOSTAS pro dono), 9 testes sinteticos; integrador validou no
  worktree: cerca --base 8034192 rc 0 (4 paths, so owns), suite 1510/0, canarios OFF = ACTIVE x3, ON md5 = audit §3 (regra nunca
  dispara nos canarios), world.rb 1798 intocado, sem relogio/rand. FINDING: mecanismo do audit §4 corrigido (dobrado no audit).
  Time: lane-worker (fable) + scout (gpt-5.6-sol) + reviewer (fable, PASS WITH MINORS -> 1 MAJOR + 1 MINOR corrigidos em 97ce289).
  Pouso em main: SO com palavra do dono (A3 esta OFF; s133 'nao me convence').
RECEIPT: review ea8b5ab DONE S1-S3 fresh-eyes: BLOCKED -> 8/8 respondidos (drafts/_review-s1s3-freshEyes-20260906.md)
RECEIPT: review 5595c11 DONE lanes fresh-eyes: BLOCKED -> 7/7 + A4/A6 respondidos no commit seguinte (drafts/_review-lanes-freshEyes-20260906.md)
RECEIPT: review a13e5bf DONE fence v2 fresh-eyes: WITH MINORS -> 4 menores + 3 parciais respondidos no commit seguinte (drafts/_review-fence2-freshEyes-20260906.md)
RECEIPT: review b40ab7f DONE lane-reviewer (fable-5.1-thinking) fence v3: WITH MINORS -> 3 menores + 2 notas respondidos no commit seguinte (drafts/_review-fence3-laneReviewer-20260906.md)
RECEIPT: validator 3892c1f DONE wall #3 42/42 + re-gate @ 3a0ef57: 4/5 PASS, brasa2 pressure_ring_reads = named debt (drafts/_wall-premium-build-20260906.log) parede #3 (game-two-wall5, 01:51 ->)

## PATCH REQUESTS pendentes (dobrados dos receipts)
(nenhum)

## Dividas nomeadas (dobradas dos receipts)
- STATUS 2026-09-06 18:5x (fim da sessao): renderer.rb 2124 -> 1979 (Signage extraido; cap 2000 em line_caps_test) FECHADA ·
  world.rb 1800 -> 1727 (Game::Interact extraido) FECHADA · brasa2 pressure_ring_reads PASS (regra do anel) FECHADA ·
  toll_pocket re-autorado (censo 42/42) FECHADA · banner/stamp z 18 FECHADA · S1 pousado (bag no record do T1) FECHADA.
  ABERTAS: ally_brain.rb (espera A3), drop-sob-corpo (pergunta de sim, dono), zone8 linhas finas (nao reproduziu no HEAD;
  observar na parede #5), netplay (halo do parceiro + overlay acima do veu de fim; so com 2 seats). Raias abertas: nenhuma.
- a3-stalemate: `controllers.rb` 628 (> ~620) -> extrair o bloco do cerebro aliado (`ally_config`..`advance_step`) para
  `src/game/ally_brain.rb` (mixin byte-inerte) quando A3 pousar. Candidatos (c)/(d) do stalemate = tickets do dono
  (audit §4 corrigido). Footgun de dados: `ranged_hold_tiles` >= 4 com `stalemate_advance_tiles` >= hold-1 faz ping-pong (3/1 e seguro).
