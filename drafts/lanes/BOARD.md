# BOARD - estado vivo das raias (INTEGRADOR-ONLY; a cerca recusa raias aqui)

SIM TOKEN: Gabriel (T1 schema 3 / player record) - next: s4-equipment (v24)
SIM LANE: NONE
(a3-stalemate teve a concessao de 10:45 a 11:24 em 2026-09-06, so `controllers.rb`, so no branch `lane/a3-stalemate`;
entregou e devolveu. Ref confiavel da cerca enquanto os briefs nao estao em `main` = `junior/premium-build`.)
INTEGRADOR: dev seat (Junior's session)

Duas linhas: `SIM TOKEN: <quem, humano> ...` = atribuicao (prosa); `SIM LANE: <lane|NONE>` = a linha que a
cerca LE (machine row). So a raia nomeada em SIM LANE pode tocar `src/game/**`.
Raias escrevem SEUS receipts em `drafts/lanes/receipts/<lane>.md`; o integrador dobra aqui.

## Receipts (dobrados pelo integrador)
RECEIPT: e3-presentation - OPEN lane-worker (fable) + scout + reviewer; ticket E3 (spec §5; T0 b3/b4/b5/F-A3-1); brief drafts/lanes/e3-presentation.md; worktree ../game-two-lane-e3; apresentacao pura, sem SIM LANE
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
- a3-stalemate: `controllers.rb` 628 (> ~620) -> extrair o bloco do cerebro aliado (`ally_config`..`advance_step`) para
  `src/game/ally_brain.rb` (mixin byte-inerte) quando A3 pousar. Candidatos (c)/(d) do stalemate = tickets do dono
  (audit §4 corrigido). Footgun de dados: `ranged_hold_tiles` >= 4 com `stalemate_advance_tiles` >= hold-1 faz ping-pong (3/1 e seguro).
