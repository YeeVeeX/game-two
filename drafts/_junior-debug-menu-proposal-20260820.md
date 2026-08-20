# Mod menu / debug menu — avaliação do pedido do Junior

> **Documento de avaliação. Nada foi implementado, nada foi executado.** Nenhum `rake`, nenhum `soak`, nenhuma sessão de jogo, nenhuma escrita em `saves/`. O levantamento abaixo é 100% leitura de arquivos do repo (`sed`/`wc` sobre `src/`, `harness/`, `soak/`, `test/`, `AGENTS.md`, `PARKING_LOT.md`). Todo número de linha citado foi conferido na árvore de hoje (2026-08-20).

## 0. Cabeçalho — pedido, regra e escopo desta resposta

**Pedido do Junior, verbatim (pt-br):**

> "fala pro gabriel que seria legal produzir um mod menu para nós conseguirmos explorar todo o jogo sem precisalo jogar, com opçoes como modo invisivel, god mod infinite coins e mais coisas que tu pode dar ideias. avalie."

**Regra permanente do Junior (dele, sobre ele):** opinião/ideia do Junior **não é lei**. Ideia entra como *proposta*; só vira trabalho depois da validação do Gabriel. Este documento é a proposta + a avaliação, não uma decisão e não um compromisso de implementação.

**Regra de ciclo, que este pedido cruza de frente:** `AGENTS.md:120-121` — "v19 intake (7 ideas banked): `drafts/_junior-v19-ideas-20260819.md` — **v19 opens at the post-verdict brainstorm, not before**". Ou seja: nada novo entra antes do brainstorm do v19. Este documento é intake/proposta, e como intake ele é legítimo agora; como código, não.

**"avalie" foi cumprido — incluindo as objeções.** A avaliação está nas seções 5 (leis que colidem), 8 (crítica adversarial sem filtro) e 9 (recomendação com defesa). A parte que diz "não" está escrita com o mesmo cuidado que a parte que diz "sim". Se o Junior queria só a lista de opções legais, a seção 7 existe — mas ela vem depois das leis de propósito.

---

## 1. Resumen para Gabriel (es-CR, ~5 líneas)

1. **Lo que se pide:** Junior quiere un "mod menu" dentro del juego — modo invisible, god mode, monedas infinitas y más — para poder **recorrer todo el mundo sin tener que jugarlo bien**.
2. **Lo que ya existe hoy:** `rake pilot` (ventana real, comandos por archivo, `goto` con pathfinding real, `speed 1..60`, `state`/`dump`), `soak/seed_save.rb` (siembra `banked`/`provisions`), `--start-zone` (bot-gated por ley, `src/app/cli.rb:48-49`) y `rake map` (PNG offline del mundo entero). Eso cubre **buena parte** del deseo, sin tocar el juego.
3. **El riesgo real:** el menú dentro del binario choca con cinco leyes — feature PARKED (`AGENTS.md:112-115`), determinismo/wall (Rule 2), lockstep (fingerprint + desync), persistencia (nunca escribir el save real) e higiene de oráculo (precedente `AUTOPILOT`). Y el riesgo mayor no es técnico: **estamos midiendo dificultad justo ahora**, y god mode borra exactamente la señal que medimos.
4. **Lo barato vs. lo caro:** F1 (harness + save scratch) entrega ~60% del deseo con **cero código nuevo en el juego**; el menú in-game con verbos mutantes es F3, post-veredicto y solo si vos lo promovés desde `PARKING_LOT.md`.
5. **Recomendación en una frase:** sí a la herramienta de harness ahora (F1), sí a un HUD de debug read-only después (F2), **no** al mod menu con god mode dentro del binario que jugamos hasta que el veredicto de dificultad esté cerrado.

---

## 2. A necessidade real por trás do pedido

O pedido literal é "mod menu". A **necessidade** é outra, e é mais simples: *ver e percorrer todo o conteúdo que existe, rápido, sem depender de habilidade de jogo nem de grind*.

Isso é uma necessidade **legítima e recorrente de desenvolvimento**, não preguiça:

- Para autorar bug: você precisa chegar no estado que quebra, em segundos, dez vezes seguidas.
- Para revisar conteúdo: você precisa ver as 6 zonas (`data/zones/`: `camp, district, district_two, low_quay, nest, slow_door`) sem pagar pedágio e sem morrer no caminho.
- Para revisar arte/render: você precisa parar o tempo e olhar o frame.
- Para revisar IA: você precisa **ver** o que a IA vê (aggro, flow field, alcance, threat) — hoje isso é invisível.

O projeto **já reconheceu essa necessidade três vezes** e a atendeu três vezes por caminhos que não são um menu in-game: `rake pilot`, `soak/seed_save.rb`, `--start-zone`, `rake map`. Ou seja: a discussão não é "essa vontade é válida?" (é), é "**por qual porta ela entra?**".

---

## 3. O que JÁ EXISTE e talvez resolva metade do pedido HOJE

### 3.1 `rake pilot` / `harness/pilot.rb` — o esqueleto quase pronto de um "modo explorador"

Âncoras: `Rakefile:28-32`, `harness/pilot.rb:38-259`, núcleo puro em `harness/pilot_session.rb`.

**Entrega hoje:**
- Janela Gosu **real**, com sim real e renderer real — não é simulação de segunda classe.
- **Interativo ao vivo, mas file-driven**: você *appenda* linhas em `tmp/pilot/<NAME>/inbox.txt` e lê `tmp/pilot/<NAME>/log.txt` (`pilot.rb:6-12`); o `Inbox#poll` faz tail por offset (`pilot_session.rb:153-173`).
- Vocabulário conferido em `pilot_session.rb:26-44`: `hold / press / wait / goto <tx> <ty> [guard=N] / capture / state / dump / speed 1..60 / export / reset [seed] / quit`.
- **`goto` é pathfinding real via `FlowField`** (`GotoEngine`, `pilot_session.rb:307-355`) → **"navegar sem jogar bem" já existe**, e existe com a IA de navegação do próprio jogo.
- `state`/`dump` dão introspecção JSON completa: frame, zona, tile, hp, drops, banked, mark (`pilot_session.rb:261-294`).
- `speed` acelera até 60 ticks por update → "explorar rápido" já existe.
- Sessão exporta script de replay (`export`, e sempre em `quit`/crash) → o que você achou é reproduzível.

**NÃO entrega:**
- Nenhum input de teclado humano — só arquivo. Você "joga" digitando comandos em outro editor.
- **Não carrega save.** `WorldScene.new(width:, height:, seed:, start:)` (`pilot.rb:97`) e `Game::World.new(data, seed:)` (`src/scenes/world_scene.rb:21`) **ignoram `save:`**. Então: mundo sempre fresco, selos sempre fechados, banked sempre zero.
- Sem áudio. Sem `START` documentado no header (só `ENV["START"]` em `pilot.rb:254`, JSON `{zone, banked, inscribed}` via `Harness.apply_start`, `harness/support.rb:24-35`).
- Nenhum god mode, nenhuma invisibilidade, nenhum HUD de debug.

**Reaproveitável:** é o esqueleto de um "modo explorador" a **duas peças de distância**: um driver de teclado no lugar do inbox, e um `save:`.

### 3.2 `soak/seed_save.rb` — o "save de exploração" a ~10 linhas de distância

Âncoras: arquivo inteiro, 53 linhas (conferido).

**Entrega hoje:** semeia exatamente `home_zone=hub` (default `"nest"`), `banked=60`, `provisions=3` (`linhas 27-29, 38-40`), partindo de `world.save_facts` de um mundo fresco (`36-37`). É **scratch por lei**: aborta se o path for `saves/world.json` (`31-33`). Escreve e **re-valida pelo decodificador estrito** (`42-50`).

**NÃO entrega (mas poderia, sem inventar nada):** os fatos aceitos são `banked breached counters home_zone members provisions` (`src/game/save_state.rb:137`, conferido). Isto é: **`breached` (selos abertos), `members` (kit/hp/inscribed) e `counters` (boss_1_defeats/sessions) já são semeáveis e simplesmente não são usados**. `src/map_main.rb:26-35` (`PROBE_FACTS`) já demonstra os três funcionando.

**Reaproveitável quase sem mudança:** aceitar args/JSON para `breached` + `members` + `counters` = **"save de exploração" com todos os selos abertos, HP cheio, boss já derrotado e moedas altas** — o que cobre "moedas infinitas" e "romper selo" do pedido, fora do jogo, num save scratch, sem um único `if @god` no tick.

### 3.3 `--start-zone` — teleporte que existe, com a razão da tranca escrita no código

Âncoras: `src/app/cli.rb:48-49` (gate), `cli.rb:43-47` (comentário-razão), `cli.rb:117-121` (quarentena do bot, conferida).

**Entrega hoje:** `raise ArgumentError, "--start-zone needs --bot"` — **bot-gated na CLI**, não env. O comentário declara a razão: em assento humano seria teleport-cheat no save real; a lane de mapa/teleporte in-game está parked (`PARKING_LOT.md:633-634`). E `--bot` em assento com save exige `--save` (`cli.rb:117-121`: "*a bot never touches the real save*"). O fluxo é o mesmo de qualquer portão: `src/main.rb:59-60` imprime `START_ZONE zone=...`, `src/app/window.rb:73` e `:121` chamam `@world.start_in(zone)`, primitivo em `src/game/world.rb:152-155` (`enter_zone(zone, pack_spawn)`).

**NÃO entrega:** humano **não** consegue usar. O que dá hoje é `--bot --save tmp/x.json --start-zone district_two` — aí quem joga é o autopilot e você assiste. Assistir não é explorar.

**Reaproveitável:** a mecânica está pronta e testada; o que falta é **uma condição de liberação que não seja "bot"** (candidata óbvia: exigir `--save` scratch em vez de `--bot`). Isso é mudança de lei na CLI → precisa do Gabriel, não de mim.

### 3.4 `rake map` — "ver o mundo todo", estático

Âncoras: `Rakefile:12-14` → `src/map_main.rb`, lógica pura em `src/app/map_artifact.rb:17-90`.

**Entrega hoje:** renderiza **offline** (janela GL 320×180 que fecha) UM PNG com **todas as zonas** em painéis 3-col, grid de tiles completo, 6px/tile, cores da mesma palette do renderer, marcador de home, stamps `SEALED/OPEN` por selo, header `BANKED · MARKS · PROVISIONS · BOSS 1 DEFEATS`. Lê o save real, ou `PROBES=1` com fatos encenados (`map_main.rb:57-78`).

**NÃO entrega:** é planta baixa. Sem criaturas, sem estações rotuladas, sem player ao vivo, sem interação, sem "andar lá".

**Reaproveitável:** é exatamente a base do mapa in-game — que é a lane parked (`PARKING_LOT.md:843`: "map table (= the PARKED in-game map view; promotion candidate named, not promoted)").

### 3.5 O padrão do projeto para "ligar extra sem sujar o jogo normal"

Três camadas, todas presentes hoje:

- **(a) flag CLI order-free com refusal nomeada e `USAGE`** — `cli.rb:8-10, 32-58, 117-121`.
- **(b) env var lida no ponto de uso, `nil` = custo zero** — `@frame_probe = ENV["GAME_FRAME_PROBE"] ? FrameProbe.new : nil` (`src/app/window.rb:87`, conferido), com todos os sites em `&.` (`window.rb:91,104,142,183`) e o comentário-lei em `src/app/frame_probe.rb:2-7` (conferido): valores "**NEVER flow back into sim, wire, digest, or draw: samples aggregate here and leave as ONE close-time log line**". Mesmo padrão em `ENV["SOAK_AUDIO"]` (`audio_bridge.rb:74-82`), `ENV["PROBES"]` (`map_main.rb:57,65`), `ENV["VIDEO_EVERY"]` (`replay_runner.rb:54`).
- **(c) troca no mesmo seam de input** — `@input = @autopilot || Core::KeyboardInput.new(...)` (`window.rb:78-79`, conferido); o bot é só um duck `update(tick)/down?(action)` (`autopilot.rb:50-57`).

Resumo do padrão: *extra entra por flag/env, no ponto de uso, `nil` quando desligado, saída só em log, sim intocado.*

### 3.6 Menu/overlay de debug: **não existe**

Só há `ControlsOverlay` (strip de teclas, `src/app/controls_overlay.rb:12-30` — UI de jogo, 149 linhas), `NetplayOverlay`, e o contador `overruns` desenhado direto na window (`window.rb:137-140`). Nenhum dev console, nenhum toggle. `data/bindings.json` mapeia apenas as 11 ações de jogo → **F1/M/`~` estão livres**. Falta tudo: overlay, toggle, comandos in-game. Reaproveitável: o padrão (b)+(c) é o molde exato.

**Veredito honesto da seção 3:** entre pilot (`goto`, `speed`, `state`, `dump`, `export`), `seed_save` estendido (`breached`, `members`, `counters`) e `rake map`, **metade ou mais do pedido é alcançável sem tocar no binário do jogo**. O que sobra e realmente não existe: teclado humano no explorador, god mode/invisibilidade ao vivo, e HUD de debug da IA.

---

## 4. As leis que um menu desses colide, e o requisito derivado de cada uma

### LEI 0 — o feature está PARKED; não é código, é entrada de lista

`AGENTS.md:112-115` (conferido): "**OUT of scope — goes to PARKING_LOT.md, never to code:** … in-game world editing, map view, teleport". `PARKING_LOT.md:630-637` escalona explicitamente: god-view v0 = ferramenta **OFFLINE** (`rake map`) → mapa/teleporte **read-only** in-game (teleporte = "*lockstep-carried verb or it desyncs*") → **edição** do mundo. `PARKING_LOT.md:827-832` reafirma (2026-08-19): "*Live in-game select-and-place god mode … the lockstep desync-mine honesty stands*".

**REQUISITO:** sem promoção **explícita dos donos** no brainstorm pós-verdict, o menu **não merge** — vai para `PARKING_LOT.md` como entrada, junto com esta avaliação. Somado a `AGENTS.md:120-121` (v19 abre no brainstorm pós-verdict, não antes), a janela para *decidir* isso é o brainstorm do v19; a janela para *codar* é depois dela.

### LEI 1 — Determinismo / Rule 2 (wall + canary)

- `AGENTS.md:161-163` (conferido): Rule 2 é **ship-gate bloqueante** — replay + captura de frame + critique **antes** de shippar; "*Never eyeball loops*". `AGENTS.md:26-27`: **até placeholder é mudança visual** (wall + recalibração).
- `Rakefile:125-129` — o gate aborta se qualquer PNG diferir entre dois replays (md5). `Rakefile:94-99` — o canary compara md5 **por frame** contra baseline preservada: **qualquer overlay novo no caminho de draw da wall invalida as baselines pinadas**.
- O que entra no digest: `src/net/state_digest.rb:28-30` dobra **todo** evento registrado no bus; `:36-38` dobra as máscaras de input consumidas por tick; `:44-46` dobra `World#digest_snapshot` na fronteira; `:56-58` fixa a forma canônica (só escalares — objeto vivo desincroniza contra si mesmo).
- O snapshot (`src/game/world.rb:629-666`): `frame, zone, state, respawn_timer, home_zone, breached, last_damaged, corpse_serial, rng_draws, respawn_rng_draws, boss_1_defeats, sessions` + feel + pack + cada membro + humanos por zona + projéteis + impactos + `@field.digest_groups` + respawns.

**REQUISITO:** god mode / moedas / teleporte tocam `hp`, `banked`, tiles e `rng_draws` (`world.rb:65,72` — `CountingRng` **conta** draws). Logo o cheat tem de viver **fora do sim**: zero mutação de estado, zero evento emitido, zero draw de RNG — **ou** ser estruturalmente inalcançável nos caminhos que o gate mede. `test/harness/wall_pin_test.rb:16-25` é o precedente estrutural: a wall constrói `save: nil` e **proíbe tokens** → o menu tem de ser **inalcançável no harness**, com teste que asserta isso.

### LEI 2 — Lockstep

- `src/net/lockstep.rb:176-187` + `:224-233`: fronteiras retidas, md5 comparado, mismatch **trava** (`:88-96` — `ready?` false para sempre, admissão de tick morre). `src/net/session.rb:40`: desync tem **precedência máxima**; `:539-543` conclui + envia DESYNC + drena; `:559` grava artefato.
- `soak/chain_check.rb:74` — `desyncs>0` = "hard fail, always".
- `src/net/fingerprint.rb:29-41` — fingerprint md5 sobre `src/**/*.rb` + `data/**`; `:56-62` recusa **nomeando o campo**. Adicionar o arquivo do menu **já muda o fingerprint**: sem `git pull` nos dois assentos, a sessão recusa.
- `PARKING_LOT.md:633-636` — "teleport = lockstep-carried verb or it desyncs"; "In-session editing during netplay is a desync mine (every mutation must ride the input stream)".

**REQUISITO:** host-autoritativo **não basta** — não há rollback/resync (`AGENTS.md:116-117` lista rollback/resync como OUT of scope). Então, das duas, uma: **(a)** o menu é **RECUSADO por nome** quando `@session` existe (`src/app/window.rb:56,93`), ou **(b)** cada mutação é verbo do `Protocol` carregado no input stream nos dois assentos — o que muda `Protocol::VERSION` **e** o fingerprint, e transforma o cheat em código sim-class de primeira classe. **Escolha desta proposta: (a).**

### LEI 3 — Persistência

- `src/game/save_state.rb:52-62` — facts: `banked, provisions, home_zone, breached, members(kit/hp/inscribed), counters(boss_1_defeats, sessions)`; `:90-111` canonicalizador pinado; `:118` digest = md5 dos facts. `:137-146` (conferido) valida chaves e tipos; `banked` só precisa ser Integer ≥ 0 — **não há teto**.
- `src/app/save_store.rb:143-161` (conferido, `SaveCoordinator`) — lei "só grava em saída limpa": escreve **IFF** o assento dona o save **E** `reason == :quit`; o comentário `:140-142`: "*Desync, conn_lost, protocol fault, refusal, or a crash write NOTHING — a diverged world is suspect state and must never poison the save*". `sessions` incrementa **ali, na escrita**. `AGENTS.md:206-208`: clean quit ONLY, never hand-edit; `--fresh` move o save para `.bak-<ts>` **primeiro** (a backup law).
- `soak/chain_check.rb:154-159` + `:174-176` — a cadeia: `loaded digest == previous saved digest` e `sessions +1`. Um save com cheat entra na cadeia como **link legítimo**.

**REQUISITO:** copiar a quarentena do bot, literalmente. `cli.rb:117-121`: "`--bot` needs `--save <path>` in solo or `--host` mode (a bot never touches the real save)". O menu armado deve **recusar sem `--save` scratch**, ou o `SaveCoordinator` deve retornar `nil`. E deve copiar `soak/seed_save.rb:31-33`: **abortar se o path resolver para `saves/world.json`**. Marcador disponível hoje sem inventar campo: o `source=` da persist line (`save_store.rb:89-101`).

### LEI 4 — Higiene de medição / oráculo (existe precedente exato)

- `src/app/autopilot.rb:44-46`: `banner = "AUTOPILOT seed=… quit_tick=…"` — "*the ONE new output line (oracle surface frozen)*", impressa só sob `--bot` (`src/main.rb:41,54`).
- `soak/chain_check.rb:68` **exige** o banner; `:12-13` — "*a soak verdict is NEVER oracle evidence*".
- `docs/CHECKPOINT.md:1107` — "**the bot-disqualification law: any log with an `AUTOPILOT seed=` line is never session evidence**"; `drafts/_v18-fun-verify-skeleton-20260818.md:906-909` (residue trap); aplicação real: `drafts/_v18-fun-verify-verdict-20260820.md:112` — `grep -c AUTOPILOT` = **0** nos quatro logs; `AGENTS.md:223-224` ("*A bot session is never oracle evidence*", conferido).

**REQUISITO:** um token **único e grep-ável** em stdout no boot (ex.: `CHEAT armed=…`), **não removível em runtime**, mais uma linha TELEMETRY **add-only atrás do prefixo pinado** (`src/game/telemetry.rb:319-321` — conferido: "*Format pinned by the v18 spec … extended ADD-ONLY … reasons{...} rides BEHIND the pinned prefix, so every existing `refused=N` consumer still matches*"). Assim a desqualificação é **mecânica**, igual à do bot, e não depende de ninguém lembrar.

### LEI 5 — Caps / arquitetura

- `test/app/line_caps_test.rb:16-20` (conferido) — `window.rb ≤ 300`; hoje **207** → **93 livres**. `:22-27` — `world.rb ≤ 1800`; hoje **1795** → **5 livres**. Qualquer lógica de cheat dentro de `world.rb` **quebra o suite**.
- `AGENTS.md:160-161` — "Systems talk via the event bus or they don't ship"; `AGENTS.md:164` (Rule 3) — zero constantes de balance em código (valores de cheat iriam para `data/`, que **é hasheado no fingerprint**).
- Event bus: `src/core/event_bus.rb:63-65` levanta `UnknownEvent`; whitelist em `src/game/world.rb:26-37`, registrada em `:73`. `event_bus.rb:33-36`: `registered_types` **é** a fonte de subscrição do digest → **registrar um evento novo muda as linhas do digest** (e o fingerprint).

**REQUISITO:** o código mora em `src/app/`, como **overlay puro irmão** de `controls_overlay.rb`/`netplay_overlay.rb`, no molde de `frame_probe.rb` (`window.rb:85-87`: env-gated, `nil` quando off, "*no clock read, no allocation, no branch into sim/draw*") — **leitura de estado apenas, nunca escrita**, e **zero evento novo**. Na window entra só o seam (ivar + `&.`), não a lógica.

---

## 5. Desenho proposto que respeita todas as leis

**Renomeando o objeto, de propósito:** não é "mod menu no jogo". É **ferramenta de dev com quarentena**, no molde que o projeto já usa três vezes. O nome importa porque o nome define onde o código pode morar.

### 5.1 Invariantes não-negociáveis do desenho (as 6)

1. **Gate por env/flag, padrão do projeto.** `ENV["GAME_DEBUG_MENU"]` lido **no ponto de uso**, `nil` = custo zero, todos os sites em `&.` — cópia literal de `window.rb:87` + `frame_probe.rb:2-7`. Off = nenhum branch entra em sim/draw → **as baselines pinadas do canary continuam válidas** (`Rakefile:94-99`).
2. **REFUSAL nomeada em netplay.** Se `@session` existe (`window.rb:56,93`), armar o menu **recusa por nome** e sai pelo caminho de abort existente (`App::Cli.exit_status` 1 = refusal, `AGENTS.md:204-205`). **Não** escolho espelhamento host-autoritativo: sem rollback/resync (`AGENTS.md:116-117`), espelhar mutação = mina de desync (`PARKING_LOT.md:635-636`), e o custo é `Protocol::VERSION` + fingerprint + digest, isto é, o cheat vira sim-class e cai dentro do Rule 2 para sempre.
3. **Proibição absoluta de gravar no save real — scratch obrigatório.** Refusal nomeada sem `--save <path>`, no molde `cli.rb:117-121`; abort se o path resolver para `saves/world.json`, no molde `soak/seed_save.rb:31-33`; e, na dúvida, `SaveCoordinator#close` retorna `nil` (`save_store.rb:151-153`).
4. **Marca de contaminação na telemetria e no stdout.** `CHEAT armed=<lista>` impresso no boot, não removível em runtime (precedente `AUTOPILOT seed=`, `autopilot.rb:44-46`), + linha TELEMETRY **add-only** atrás do prefixo pinado (`telemetry.rb:319-321`), + `source=` marcado na persist line (`save_store.rb:89-101`). Consequência escrita e aceita: **qualquer log com `CHEAT armed=` nunca é evidência de sessão** — mesma lei do bot (`docs/CHECKPOINT.md:1107`).
5. **Exclusão do wall/canary, testada.** O menu é **inalcançável** no harness: precedente estrutural `test/harness/wall_pin_test.rb:16-25` (wall constrói `save: nil` e proíbe tokens). Teste novo asserta que a env não está setada nos caminhos de wall/canary/replay e que, sem ela, nada muda no draw.
6. **NUNCA entrar em `Net::Fingerprint::EXCLUDED`.** O arquivo novo muda o fingerprint (`fingerprint.rb:29-41`) e **isso é correto**: os dois assentos dão `git pull` e segue. Colocar config que afeta sim no `EXCLUDED` (hoje só `data/bindings.local.json`, display-only) seria **desarmar o detector de desync para poder trapacear** — é a objeção (a1) da seção 8 e é linha vermelha.

### 5.2 Onde o código moraria sem estourar caps

| Local | Orçamento hoje | O que entra |
|---|---|---|
| `src/app/debug_overlay.rb` (novo, irmão de `controls_overlay.rb`) | arquivo novo, sem cap | **toda** a lógica: leitura de estado, layout, toggles |
| `src/app/window.rb` | 207/300 → **93 livres** (`line_caps_test.rb:16-20`) | **só o seam**: 1 ivar env-gated + sites `&.` (molde `window.rb:87`) |
| `src/game/world.rb` | 1795/1800 → **5 livres** | **ZERO.** Nenhum `if @god`, nenhuma linha. Verbos de F3 chamam primitivos públicos existentes (ex. `enter_zone`, `world.rb:152-155`) **de fora** |
| `data/debug/*.json` | — | qualquer numérico (Rule 3, `AGENTS.md:164`) — ciente de que `data/**` é hasheado |
| `harness/` + `soak/` | sem cap de linha | F1 inteiro mora aqui |

O cap de `world.rb` (5 linhas livres) é o **blocker arquitetural mais duro** e precisa ser dito sem maquiagem: se algum verbo de F3 exigir lógica dentro do world, primeiro vem uma **extração de subsistema** — que é um ciclo próprio, não um item de menu.

### 5.3 Fases

**F1 — mínimo útil, ZERO código novo no binário do jogo.** *Escopo: harness + scratch save.*
- Estender `soak/seed_save.rb` para aceitar `breached` + `members` + `counters` além de `banked`/`provisions` — **todos já aceitos pelo decodificador** (`save_state.rb:137`) e já demonstrados por `map_main.rb:26-35` (`PROBE_FACTS`). Resultado: "save de exploração" com selos abertos, HP cheio, `banked` alto, BOSS 1 já contado. Mantém as duas travas do arquivo: scratch-only (`:31-33`) + re-validação estrita (`:42-50`).
- Fazer `harness/pilot.rb` **honrar `save:`** — hoje `pilot.rb:97` e `world_scene.rb:21` ignoram. Com F1a acima, isso é "pilot com o mundo destravado".
- Usar o que já existe sem escrever nada: `goto` (`pilot_session.rb:307-355`), `speed 1..60`, `state`/`dump` (`:261-294`), `capture`, `export`, `reset [seed]`.
- **Entrega:** ver as 6 zonas, atravessar sem jogar bem, 60× de velocidade, introspecção JSON, replay do que achou. **Não entrega:** teclado, god mode ao vivo, HUD de IA.
- **Custo de gate:** nenhum draw novo → nenhuma recalibração de wall. Fingerprint muda (arquivos em `src`? não; `soak/` e `harness/` estão fora de `src/**/*.rb` — a conferir antes de qualquer trabalho, `fingerprint.rb:29-41`).

**F2 — driver de teclado + HUD de debug READ-ONLY.**
- Driver de teclado para o pilot, no seam de input existente (`window.rb:78-79`; o bot é só um duck, `autopilot.rb:50-57`) — o explorador passa a ser jogável com as mãos.
- Overlay **read-only** env-gated (`src/app/debug_overlay.rb`), molde `frame_probe.rb`: tiles de aggro, flow field, alcances, threat, tick/frame, zona/tile, hp/banked. **Só leitura**, zero evento novo (`event_bus.rb:33-36`), zero escrita.
- **Custo de gate honesto:** quando **armado**, é mudança visual → Rule 2 (wall + captura + critique, `AGENTS.md:161-163`). Quando **off**, `nil` em todos os sites → baselines do canary intactas. É por isso que off-por-default não é detalhe, é o desenho.

**F3 — verbos mutantes (o "mod menu" propriamente dito).** *Só pós-verdict, só com promoção dos donos.*
- Todos os seis invariantes de 5.1 valendo, mais: solo-only com refusal nomeada, scratch save obrigatório, `CHEAT armed=` no boot, taint na telemetria.
- Verbos que **não** desenham RNG primeiro (set `hp`, set `banked`, marcar/desmarcar); verbos que desenham RNG (spawn, teleporte com `pack_spawn` — `world.rb:152-155`) entram sabendo que **contaminam `rng_draws`** (`world.rb:65,72`, snapshot `:629-666`) → sessão nunca comparável com baseline. Isso é aceitável **só** num run marcado como contaminado.

---

## 6. Lista de opções do menu

`[J]` = pedido explícito do Junior. `[dev]` = ideia minha, para avaliação.

| # | Opção | O que faz | Toca a sim? | Risco | Cabe na F1? |
|---|---|---|---|---|---|
| 1 | **[J] Modo invisível** | inimigos deixam de te perceber/perseguir | **Sim** — desliga threat pull / leash / beachhead (`controllers.rb`) | **Alto de design**: apaga justamente a IA que faz o mundo parecer vivo enquanto você "explora o mundo vivo" | Não |
| 2 | **[J] God mode** | dano recebido = 0 / HP travado | **Sim** — `hp` está no snapshot (`world.rb:629-666`) | **Alto**: apaga dread do BOSS 1, MARK LOST, one-vessel floor, veil de wipe — o sinal que estamos medindo | Não |
| 3 | **[J] Moedas infinitas** | `banked` arbitrário | **Sim** — `banked` está no snapshot e no save | **Alto**: apaga `price_sheet` + `field_economy` + a lei F1 "bank it or lose it"; e `save_state.rb:146` **não tem teto** → `banked=999999` é save legal e indistinguível depois | **Sim, parcial** — via `seed_save` num save scratch (fora do jogo) |
| 4 | [dev] **Teleporte entre zonas** | pular para qualquer uma das 6 zonas | **Sim** — `enter_zone` (`world.rb:152-155`), possivelmente com draw de RNG no `pack_spawn` | Médio; em netplay é **verbo lockstep ou desync** (`PARKING_LOT.md:633-636`) | **Sim, parcial** — `--start-zone` (hoje bot-gated, `cli.rb:48-49`) + `goto` dentro da zona |
| 5 | [dev] **Spawnar / limpar inimigos** | popular ou esvaziar a zona | **Sim** — pack + humanos por zona + RNG | Alto; útil de verdade para autorar bug de IA | Não |
| 6 | [dev] **Dar / tirar provisões** | `provisions = N` | Sim (fact + snapshot) | Baixo isolado, **alto** para medir sustain | **Sim** — `seed_save.rb:29,39` já faz |
| 7 | [dev] **Romper selo (breach)** | abre selo sem pagar pedágio | Sim (`breached` no snapshot e nos facts) | Médio; é o principal atrito entre "ver tudo" e "medir progressão" | **Sim** — `breached` já é semeável (`save_state.rb:137`; `map_main.rb:26-35`) |
| 8 | [dev] **Marcar / desmarcar (mark)** | força estado de mark | Sim | Médio — mark é peça central do loop de risco | Parcial (`inscribed` via `members`) |
| 9 | [dev] **HUD de debug read-only** (aggro tiles, flow field, alcances, threat) | desenha o que a IA vê | **Não** — leitura pura | **Baixo, e é o item de maior valor por risco**; só custa Rule 2 quando armado | Não (é F2) |
| 10 | [dev] **Congelar + avançar tick a tick** | pausa e passo único | Fronteira: não muda estado, muda *quando* o estado avança | Baixo solo; **inviável** em netplay (admissão de tick, `lockstep.rb:88-96`) | Parcial — `wait`/não-appendar no pilot (`pilot_session.rb:26-44`) |
| 11 | [dev] **Velocidade da sim** | 1×…60× | Não muda regras, muda ritmo | Baixo | **Sim, já existe** — `speed 1..60` |
| 12 | [dev] **Revelar mapa** | mostra o mundo inteiro | Read-only se for só desenho | Baixo/médio; é literalmente a lane parked (`AGENTS.md:113`, `PARKING_LOT.md:843`) | **Sim, offline** — `rake map` (`map_artifact.rb:17-90`) |
| 13 | [dev] **Invocar BOSS 1** | força o encontro | **Sim** — spawn + RNG | Alto; **e queima o instrumento**: as perguntas do ritual são virgens por lei | Não |
| 14 | [dev] **Resetar cooldowns** | zera timers | Sim (feel/timers no snapshot) | Médio; apaga o custo de tempo que é metade do combate | Não |
| 15 | [dev] **Alternar a IA do terceiro corpo** | liga/desliga o companheiro autônomo | Sim | Médio-alto; ótimo para isolar bug de pack | Não |
| 16 | [dev] **Log verboso** | despeja estado por tick | **Não** se sair só como log (lei `frame_probe.rb:2-7`) | Baixo — o padrão do projeto **já autoriza** essa forma | **Sim** — `state`/`dump` (`pilot_session.rb:261-294`) |
| 17 | [dev] **Modo frágil (1 HP)** — o espelho do god mode | você morre de tudo | Sim (`hp`) | Baixo de design e **positivo de medição**: intensifica o sinal em vez de apagá-lo. Se vamos furar a regra, prefiro furar para o lado que ensina | Não |
| 18 | [dev] **Capturar frame / exportar replay** | PNG + script reproduzível | Não | Nenhum — é infraestrutura de Rule 2 | **Sim, já existe** — `capture` / `export` |

**Leitura da tabela:** das 18, **7 já são alcançáveis hoje ou quase** (3 parcial, 6, 7, 11, 12, 16, 18) e **uma (9) é a de melhor razão valor/risco do documento**. As três do Junior são, por coincidência infeliz, exatamente as três que colidem mais forte com o que estamos medindo.

---

## 7. A crítica adversarial, dita sem filtro

### (a) Corrupção — o pior, e é concreto

1. `Net::Fingerprint.tree_md5` hasheia `src/**/*.rb` + `data/**` + `Gemfile.lock` (`fingerprint.rb:29-41`). Um mod menu = arquivo novo em `src` + tunables em `data` → o HELLO **recusa** toda sessão co-op até os dois pull (`:56-62` recusa nomeando o campo). Para o menu ser "local", o config teria de entrar em `EXCLUDED` — hoje só `data/bindings.local.json`, **display-only**. No instante em que um arquivo que **afeta a sim** entra nessa lista, o handshake **para de pegar divergência real**. Você desarma o detector de desync para poder trapacear.
2. `StateDigest` dobra todo evento registrado + máscaras de input + snapshot, um md5 por janela (`state_digest.rb:28-46`). Toggle fora da máscara → md5 divergente na fronteira → artefato de desync (`session.rb:559`) e horas caçando um "bug" que é o cheat. Rotear pela máscara/bus → o cheat vira **sim-class**: entra em `EVENTS` (`world.rb:26-37`), no digest, no fingerprint e no gate Rule 2. **Não existe terceira porta.**
3. `SaveState` valida schema/tipos/faixas, mas **não tem proveniência nem monotonicidade**: `banked=999999` é save perfeitamente legal e **indistinguível depois** (`save_state.rb:146`). `SaveStore#write` faz replace atômico **sobre o save real**; `.bak-<ts>` só nasce em `--fresh` (`AGENTS.md:208-210`). Uma gravação com moedas infinitas **mata o mundo persistente sem backup**.
4. `persist_line` imprime `banked/provisions/seals/marks/sessions` + digest (`save_store.rb:89-101`) — e a **Metade A do DÉCIMO SÉTIMO comparou esses bytes verbatim** entre sessões e assentos (veredito 2026-08-20). Save tocado por cheat **contamina a cadeia de digests do próximo ciclo** (`chain_check.rb:154-159`), e **não existe bit "tainted"** hoje. `AGENTS.md`: higiene de medição é uma das duas coisas que **nunca** relaxam.

### (b) Cheat cega o design — a objeção principal

O que vocês estão medindo **agora** é respawn/dificuldade/sustain. **God mode apaga exatamente esse sinal**: dread do BOSS 1, MARK LOST, one-vessel floor, o veil de wipe. Moedas infinitas apagam `price_sheet` + `field_economy` + a lei F1 ("bank it or lose it", carried não dobra) — sobra um jogo sem economia. Invisibilidade desliga threat pull / leash / beachhead (`controllers.rb`), isto é, **justamente a IA que faz o mundo parecer vivo** enquanto vocês "exploram o mundo vivo". E a amostra de playtest são **duas pessoas**: não existe outro *n* para corrigir a leitura depois. Um jogo com god mode não ensina **nada** sobre dificuldade — e dificuldade é a pergunta aberta do ciclo.

### (c) Custo / superfície

`window.rb` está em **207 de 300** (`line_caps_test.rb:16-20`). Um menu custa overlay + `state_stack` + `binding_map`/`key_table` + strings en/es/pt-br (`AGENTS.md:124-127`: as três locales são superfície humana) + **wall Rule 2 a cada mudança visual** + minitest **sem mocks, com Gosu real** (`AGENTS.md:168-169`). Cada `if @god` dentro de `world.rb` (**1795 de 1800**) é ramo **permanente** no caminho do tick e **dobra o espaço de estado** sobre o qual você confia no digest. O custo é pago em **gates**, não em linhas.

### (d) Muleta

Se dá para pular pedágio e boss, **todo balance vira opinião**. Pior: as perguntas do ritual são **virgens por lei** — quem já viu ZONE 5 em god mode **não pode** responder virgem outra vez. O instrumento é one-shot; cheat o queima.

### (e) Menos invasivo já resolve

`--save <path>` (scratch) + `--bot [seed]` + `--bot-ticks` + `--start-zone` — que é **bot-gated por lei** com a justificativa literal "*on a human seat this would be a teleport cheat on the real save*" (`cli.rb:43-49`) — + `--fresh` com backup, `harness/scenes`, `soak`, `captures`/`frame_probe`, e override de tunables num `data/balance` scratch (reversível, versionado, **zero ramo no tick**). Para "ver o mundo": o loop LDtk offline + hot-reload da lane 3. `PARKING_LOT.md:827-832` já registrou god mode in-game como o degrau **depois** disso, com "*the lockstep desync-mine honesty stands*".

### O corte

**Claramente BOA** se: ferramenta de **harness/console** (não menu no jogo), **solo-only** recusando `--host/--join`, quarentena igual à do bot (recusa sem `--save`), zero escrita no save de custódia, zero ramo em `world.rb`/lockstep, fingerprint mudando **de propósito**, e uso = **autoria/repro de bug** — depois do veredito.

**Claramente RUIM** se: liga no binário que vocês **jogam**, escreve no save real, exige exclusão no fingerprint, ou serve para explorar **conteúdo que ainda vão medir**. Aí não é ferramenta: **é apagar o experimento.**

---

## 8. Recomendação final do dev of record

**FAZER (e só depois de o Gabriel dizer sim, e depois do brainstorm do v19 — `AGENTS.md:120-121`):**

1. **F1 primeiro, porque é quase de graça e entrega mais da metade do pedido.** Estender `soak/seed_save.rb` para `breached` + `members` + `counters` (já aceitos: `save_state.rb:137`; já provados: `map_main.rb:26-35`) e fazer `harness/pilot.rb` honrar `save:` (`pilot.rb:97`, `world_scene.rb:21`). Zero código novo no binário do jogo, zero ramo no tick, zero recalibração de wall. **Defesa:** é o mesmo caminho que o projeto já escolheu três vezes (pilot, seed_save, start-zone) e nenhuma das cinco leis é tocada.
2. **F2 depois, e nesta ordem interna: driver de teclado antes do HUD.** O teclado transforma o pilot em explorador de verdade e não desenha nada novo. O HUD read-only (item 9 da tabela) é a **melhor razão valor/risco do documento inteiro** — mostra o que a IA vê, não muda o que a IA faz — mas quando armado é mudança visual e paga Rule 2 (`AGENTS.md:161-163`).
3. **Registrar isto em `PARKING_LOT.md`** como a entrada in-game do escalonamento que já existe lá (`PARKING_LOT.md:630-637`, `827-832`), com link para este draft — para a decisão não se perder e para a próxima pessoa não reabrir a discussão do zero.

**NÃO FAZER:**

1. **Não** colocar god mode / invisibilidade / moedas ao vivo no binário que vocês jogam **enquanto o veredito de dificuldade estiver aberto**. Não é conservadorismo: é que o experimento em curso mede exatamente o que esses três apagam, e a amostra são duas pessoas (seção 7b, 7d).
2. **Não** espelhar mutação em netplay, em nenhuma variante. Sem rollback/resync (`AGENTS.md:116-117`), é mina de desync (`PARKING_LOT.md:635-636`) e trava o lockstep para sempre (`lockstep.rb:88-96`). Em netplay: **refusal nomeada**, ponto.
3. **Não** adicionar nada ao `EXCLUDED` do fingerprint. Nunca. Essa é a linha que, se cruzada, torna o detector de desync mentiroso (seção 7a1).
4. **Não** deixar o menu alcançar `saves/world.json` em nenhuma circunstância, nem "só para testar".
5. **Não** escrever `if @god` em `world.rb`. Há 5 linhas livres de 1800 (`line_caps_test.rb:22-27`) e o cap existe justamente contra esse tipo de crescimento.

**QUANDO:** F1 e F2 são candidatos do **brainstorm do v19, pós-verdict** (`AGENTS.md:120-121`) — não antes, e como itens de intake, não como código já começado. F3 (verbos mutantes) só se os donos promoverem explicitamente do `PARKING_LOT.md`, e a minha recomendação é que F3 espere o veredito de dificuldade **fechar**. Se a escolha for uma só coisa: **F1 + item 9 da tabela**. Isso atende a necessidade real do Junior (ver o jogo sem grind) sem gastar o instrumento com que vocês estão medindo o jogo.

**Reconhecimento devido ao Junior:** o instinto está certo e a necessidade é real. O que este documento faz é trocar a *porta*: o que ele pediu como menu, o projeto entrega melhor como harness — e a parte do pedido que só um menu resolve (o HUD de debug) é justamente a que eu recomendaria construir primeiro.

---

## 9. Perguntas fechadas para o Gabriel (resposta de uma palavra)

1. **F1** (estender `seed_save` + `save:` no pilot) — aprovado? → **sí / no**
2. **F2** (teclado no pilot + HUD debug read-only, env-gated) — aprovado? → **sí / no**
3. **F3** (verbos mutantes: god/coins/invisível) — espera o veredicto? → **sí / no**
4. **Timing** — decidir no brainstorm do v19 ou já? → **v19 / ya**
