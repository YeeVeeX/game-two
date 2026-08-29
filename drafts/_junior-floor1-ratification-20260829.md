# Junior — ratificação do floor -1 (v2b jogado) + POÇÃO-ok (2026-08-29)

Respostas async às pendências nomeadas nos checkpoints s117/s118
("Junior's floor -1 ratification + L3 pick still pending" · "pt-br
potion word = his to re-word at will"). Colhidas no seat dele pela
sessão de dev; vereditos VERBATIM (typos e tudo — lei do projeto).

## 1. Floor -1 (ZONE 2 / district, o v2b dele) — RATIFICADO

Verbatim (pt-br, 2026-08-29, no chat do seat):

> "eu zerei esse mapa ontem as 5 das manhã e ele esta muit bom, gostei
> da entrada perto da saida, por mais que esteja de facil acesso vc
> ainda tem q pagar 40 moeda para liberar o portão, isso força voce a
> caçar, legal demais. falta implementarmos mais atualizaçoes."

Leitura do dev (interpretação, separada da voz):

- **RATIFIED-J do floor -1: FECHADO — aprovado sem ressalvas.** O L3
  pick (v2b, pending his veto) fica confirmado: **v2b É o floor -1**;
  "pieces of each" segue banked para os andares fundos (v3 MEDUSA já
  é a gramática nomeada do deepest, lane D).
- O detalhe que ele destacou é DESIGN, não acaso: a boca de retorno
  selada fica adjacente à chegada ([41,13]/[42,13]), acesso fácil MAS
  atrás do pedágio de 40 (data: `economy.json breach_cost=40`,
  byte-idêntico ao pré-T1 — L9 honrada). Ele nomeou a consequência
  exata: "isso força você a caçar". O loop de fome de banco
  funcionando como desenhado, confirmado por quem jogou.
- "falta implementarmos mais atualizaçoes" = apetite pelo que a fila
  já carrega (T4 totem no floor dele = o próximo delta sentível;
  floors -2/-3 na lane D — os 3 conceitos dele já estão banked em
  `_junior-floor2-directions-20260829.md`).

## 2. Contador pt-br "POÇÃO 0" (watch do T3) — MANTIDO

Verbatim: "esta bom assim."

O watch da crítica de língua do T3 (singular no zero, simetria
LEVEL-N) fica resolvido take: sem re-palavramento.

## Evidência de jogo (logs no seat dele, digests md5)

Cópias em `tmp/junior-sessions/` (gitignored; originais em `%TEMP%`):

- **Sessão 1** — a zerada que ele narra (2026-08-29 ~05:36, build T1):
  `game_two_session_3641.log` md5 `e417977652afe702bb9aba92065a2363`.
  TELEMETRY: fights=15 · level=5 · banked_end=96 · seals=1 (breach
  fired, banked_after=96) · camp_visits=2 · d2 entered=1 ·
  persist saved digest=6259102d… sessions=1 (saída limpa).
- **Sessão 2** — relance no build T2+T3 (2026-08-29 ~13:42):
  `game_two_session_4747.log` md5 `71d7cee0a077b8b66d79fc1d4e89e184`.
  TELEMETRY: persist loaded digest=6259102d… → saved digest=6a7cf5e7…
  sessions=2 — continuidade do save solo dele provada; cap-12 load
  limpo (level=5, zero clamps).

Nada de sim/balance tocado; note é docs-only. Próximo passo que este
note alimenta: hub cola estes vereditos onde a foundation espera
(RATIFIED-J do L3), e a lane D decide o floor -2 com os 3 conceitos
já na mesa.
