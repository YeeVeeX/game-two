---
lane: s6-vendor-bank
branch: lane/s6-vendor-bank
owns:
  - src/game/vendor.rb
  - src/game/bank_storage.rb
  - src/app/vendor_screen.rb
  - data/balance/vendors.json
  - test/game/vendor_test.rb
  - test/game/bank_storage_test.rb
  - drafts/lanes/receipts/s6-vendor-bank.md
never:
  - drafts/lanes/*.md
  - src/game/world.rb
  - src/game/creature.rb
  - src/net/protocol.rb
  - src/game/save_state.rb
  - data/display.json
  - data/strings/
  - data/bindings.json
  - data/balance/economy.json
  - harness/gate_checks.json
  - test/net/state_digest_test.rb
  - test/game/save_state_test.rb
  - data/art/
  - docs/
  - AGENTS.md
---
# Raia `s6-vendor-bank`

## Objetivo
VENDEDOR + ARMAZEM (1.5-1.6): estacao `vendor` com estoque e `buys` por kind; precos = catalogo x `vendor_markup` / `vendor_buyback` (economy - PATCH REQUEST); banco ganha `bank_storage` (cap `bank_slots`), deposito/retirada; verbo `:trade {item, qty, dir}` (PATCH REQUEST, SIM TOKEN).

## Definition of Done
testes: comprar sem moeda recusa nomeado; vender material da `sell`; deposito respeita cap; digest `bank_hash`. PATCH REQUESTS: stations.rb aceita type `vendor` (padrao bank/seal); sidecars ZONE 7 praca + camp cerca (via importer LDtk - pedir ao dono do conteudo); economy rows.

## Lei da raia (igual para todas)
1. Leia nesta ordem: `AGENTS.md` -> `docs/CYCLE.md` -> este brief. As leis do repo valem
   inteiras (data-driven, tick-driven, digest classificado, sem nomes de lore, fallback).
2. Trabalhe SO no branch `lane/s6-vendor-bank` (crie a partir de `main`). Comite SO dentro de `owns`.
   Antes de cada commit: `ruby tools/lane_guard.rb s6-vendor-bank` (rc 0 = pode commitar).
3. Precisa mudar um arquivo fora de `owns`? NAO toque. Escreva um PATCH REQUEST no SEU
   receipt `drafts/lanes/receipts/s6-vendor-bank.md` (arquivo, chave/linha, valor exato, por que).
   O integrador aplica e dobra no BOARD. Briefs e BOARD sao do integrador (a cerca recusa).
4. Nunca abra janela Gosu (`src/main.rb`, `harness/replay_runner.rb`, `rake gate|capture|map`,
   `harness/run_wall.sh`). So a suite headless: `bundle exec rake`.
5. Tocar `src/game/**` exige o SIM TOKEN no BOARD com o seu nome. Sem token: construa
   dados + modulo novo + teste proprio (padrao `Game::Loot`) e peca a fiacao por PATCH REQUEST.
6. Subagentes filhos (foreground, gpt-5.6-sol, sem `model:`) servem pra sub-tarefas SUAS:
   `reviewer`/`delegate` pra revisar seu diff antes do receipt, `scout` pra reconhecer um modulo.
7. Ao terminar: suite verde, `lane_guard` OK, `git push -u origin lane/s6-vendor-bank`, e o receipt em
   `drafts/lanes/receipts/s6-vendor-bank.md`: `RECEIPT: s6-vendor-bank <sha> READY <resumo de 1 linha>` (+ PATCH REQUESTS).
   A cerca le o brief e o BOARD do ref `main` (trusted), nao da tua arvore: mudar o proprio brief nao muda a cerca.
