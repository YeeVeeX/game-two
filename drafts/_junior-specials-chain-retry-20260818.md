# specials_chain — retry standalone do gate neste assento (2026-08-18)

Follow-up do FAIL aberto registrado em
`drafts/_junior-sixteenth-shakedown-20260817.md` (sweep `junior_critic`:
16/17 PASS, specials_chain reprovou 3 checks de ledger no frame_0029).

## O que rodou

- Protocolo W2 (variância): retry STANDALONE antes de acreditar num FAIL —
  fails reais reproduzem.
- Comando: `CRITIC_AWS_PROFILE=junior-dev bundle exec rake gate
  SCRIPT=harness/scripts/specials_chain.json` (commit `88fd36d`, após
  pull dos incrementos 5+6 do v18; checks 53→56 ADD-ONLY com os 3 de
  sustain novos).
- Comparabilidade preservada por construção: a apresentação do sustain
  não renderiza nada com provisions=0 (pin estrutural do v18), e o
  determinismo do próprio gate confirmou — **14/14 capturas
  byte-idênticas entre as duas execuções**.

## Resultado: GATE PASS (determinismo + visão)

Os 3 checks que reprovaram no sweep de 2026-08-17 agora leram (verbatim
do crítico):

    [PASS] ledger_beat_reads: No center-screen tally panel appears; not exercised by this script.
    [PASS] ledger_negative_reads: Not exercised by this script.
    [PASS] ledger_prominence: Not exercised by this script.

Ou seja: nesta tentativa o crítico classificou corretamente o "-8"
in-world do frame_0029 como fora da superfície do ledger — exatamente a
dúvida de calibração que o roteamento deixou aberta. O FAIL anterior
NÃO reproduziu.

## Leitura deste assento (evidência, decisão segue sendo do dev)

- Pelo W2, o FAIL de 2026-08-17 adjudica como **variância do crítico**
  nesta máquina (o próprio sweep já tinha observado uma tentativa
  reprovar e outra passar sobre o MESMO diretório).
- Wall neste assento: efetivamente **17/17** com o retry standalone.
- Nenhuma mudança de checks, renderer ou dados foi feita — evidência
  pura. Se o dev quiser endurecer a cláusula "not exercised" dos checks
  de ledger (calibração), é emenda ADD-ONLY com ratificação do dono.
- Log completo (machine-local): `tmp/gate_specials_chain_retry_20260818.log`.

## Strings PT-BR do sustain — ratificação PENDENTE (revisão em jogo)

O Junior foi consultado sobre os valores FLAGGED (PROVISÃO / PROVISÃO
COMPRADA / PROVISÃO USADA / RECUSADO / overlay "provisão") e escolheu
**revisar jogando antes de ratificar** — vai rodar `bin\play.cmd pt-br`,
comprar/usar provisão (U/R) e confirmar os cues em contexto. Nenhum
valor foi alterado; a lane segue "his lane, not blocked".
