# Junior — setup de áudio concluído (recibo pré-ritual)

**Data:** 2026-08-19 · **Assento:** Junior (máquina do Junior, sessão com agente)
**Referência:** CHECKPOINT s13 addendum ("Junior's side NOW PENDING: the one-time
audio setup before tomorrow's ritual") + JUNIOR.md §"Som no jogo" + owner amendment 2.

## O que foi feito

1. `git pull --ff-only` nos quatro repos antes de tudo (protocolo do assento):
   - `game-two` → `52a07e0` (r5 spark + JUNIOR.md audio setup + bridge M5a presentes)
   - `game-two-audio` → `c1123af` — exatamente o commit cuja bootabilidade de origem
     foi provada pelo dev (skeleton: `AUDIO on: device=0 sha=15f03e0219d6`)
   - `game-two-lore` e `game-two-assets` atualizados (sem pendência para este assento)
2. Clone irmão já estava no lugar que o jogo procura (`../game-two-audio`, mesma
   pasta mãe); DLL via checkout do repo deles — **nada copiado** (no-second-copy law).
   Pin local confere: `vendor/VERSION` sha256 da DLL = `15f03e0219d6630e…f4e65`.
3. `bundle install` no `game-two`: entrou `ffi 1.17.4 (x64-mingw-ucrt)` prebuilt
   (sem compilação). `bundle check` → "The Gemfile's dependencies are satisfied".
4. Suíte local: `bundle exec rake` verde (saída no fim da sessão do agente).

## O que falta (e de quem é)

- **Prova definitiva = a linha `AUDIO on:` no log do boot real** — sai no launch do
  ritual de hoje; não lançamos o jogo nesta sessão (guarda de instância única +
  launch é do ritual, não do setup). Se sair `AUDIO off/refused`, mando a linha
  verbatim — a linha decide o caveat na colheita, nunca assumida.
- Ritual em si (owner hospeda, este assento entra com `--join`) + as 8 respostas
  depois — perguntas são do owner; nenhum priming feito nesta sessão.

## Provas

- `bundle check` verde nesta máquina (2026-08-19).
- `game-two-audio` local em `c1123af` = origin/master; `vendor/VERSION` acima.
- Oracle surface intocada: nenhum arquivo de `data/**`, `bin/play*`, JUNIOR.md,
  run-sheet ou TELEMETRY foi alterado — este draft é o único arquivo novo.
