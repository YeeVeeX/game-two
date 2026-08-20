# Oferta de divisão de trabalho entre máquinas / Oferta de reparto de trabajo entre máquinas

**De / De:** agente dev of record do assento do JUNIOR (Windows, `C:\Users\jr\Desktop\projeto-game-two\game-two`)
**Para / Para:** Gabriel — assento hub / asiento hub
**Data / Fecha:** 2026-08-20
**Tipo / Tipo:** oferta. Nada aqui foi executado. / oferta. Nada de esto fue ejecutado.

**Ordem do Junior (verbatim, pt-br) / Orden de Junior (verbatim):**

> "se o gabriel mandar alguma coisa que vc possa fazer de forma autonoma, resolva, e talvez ajudalo a escrever o codigo das proximas atualizaçoes dividindo o trabalho, seja pro ativo e combine com ele em dividir o trablho entre maquinas para que seja eficiente. sempre que puder proponha a ele ajuda na execução de tarefas, baixe e execute o q puder aqui nessa sessçao de forma autonoma."

**Regra permanente do Junior / Regla permanente de Junior:** opinião e proposta **não são lei**. Tudo abaixo depende da validação do Gabriel. Precedente registrado: `drafts/_junior-v19-ideas-20260819.md` e `drafts/_junior-note-difficulty-items-20260820.md` (commit `3b9821b`) foram entregues com a mesma ressalva.

**ES — resumen del documento:** este asiento puede correr suite, soak, capture, canary, perf, importer LDtk y clips ffmpeg **hoy**. Ofrece tomar **un lane completo** (no archivos sueltos dentro de tu lane). Candidato #1 propuesto: la IA del tercer cuerpo (R-A3), que Junior mismo reportó en la R3 del ritual — pero es **sim-touching**, así que requiere tu autorización porque v19 no abre aquí. Sección 7 tiene 4 preguntas de una palabra.

---

## 1. Por que agora / Por qué ahora

1. **O v18 fechou.** `AGENTS.md` l.58-65: "ADJUDICATED 2026-08-20 — the SEVENTEENTH is CUMPLIDO, v18 CLOSES ... v19 opens at the owners' brainstorm, not here". Fonte: `drafts/_v18-fun-verify-verdict-20260820.md`.
2. **Existe fila pós-veredito, escrita e priorizada.** `drafts/_v18-fun-verify-verdict-20260820.md` §"Post-verdict queue — RECORDED, not started" + prioridade P0–P6 em `drafts/_lag-p0-spark-20260820.md` (commit `1fd00c8`; o anterior é `fd82f1a`).
3. **A fila não começou.** `git status --porcelain` vazio nesta máquina; HEAD = `1fd00c8`; `drafts/_lag-tickets-20260820.md` e `drafts/_lag-t1-review-20260820.md` não existem no repo. Ou seja: o P0 está montado e parado.
4. **Duas máquinas paradas em paralelo é desperdício.** Enquanto um assento escreve código, o outro pode estar medindo, reproduzindo ou preparando ambiente — sem tocar os mesmos arquivos.

**ES:** v18 cerró, la cola P0–P6 está escrita y **no arrancó** (árbol limpio, HEAD `1fd00c8`). Dos asientos ociosos al mismo tiempo es desperdicio.

---

## 2. O que esta máquina consegue fazer / Qué puede hacer esta máquina

Base verificada ao vivo nesta sessão: Ruby 3.4.10 (`C:/Ruby34-x64`), Bundler 2.6.9, `bundle check` → "dependencies are satisfied", `gosu 1.4.6` carrega.

| Capacidade / Capacidad | Status | Evidência / O que falta |
|---|---|---|
| `rake -T` | **DISPONÍVEL** | 10 tasks: `canary`, `capture`, `gate`, `manifest`, `map`, `perf`, `pilot`, `run`, `soak`, `test` |
| Suíte (`rake test`) | **DISPONÍVEL** | Prova de capacidade rodada: `test/tools/import_ldtk_test.rb` → 41 runs / 119 assertions / 0 failures / 0 errors em 2,24 s. Inventário local: 86 arquivos `*_test.rb`, 905 métodos — coerente com "suite 908/0" em `docs/CHECKPOINT.md:138`. Não rodei a suíte inteira |
| `rake soak` | **DISPONÍVEL** | `soak/run_soak.sh` + `chain_check.rb` + `seed_save.rb`; bash, `/usr/bin/timeout`, Gosu, TCP loopback (`PORT_BASE` 43217) presentes. Já rodou aqui: `tmp/soak/20260818-175253`, `tmp/soak/20260818-180058`. Custo ≈10 min/episódio × `N` (default 3). **Não usa AWS** |
| `rake capture` / `canary` / `manifest` / `map` / `perf` / `run` / `pilot` | **DISPONÍVEL** | Ruby+Gosu puro |
| `rake gate` — metade determinismo | **DISPONÍVEL com ressalva** | 2 replays + md5 byte-a-byte rodam com `SKIP_CRITIC=1`, que o próprio Rakefile marca como "NOT a shippable pass" |
| `rake gate` — metade vision critic | **BLOQUEADO (credencial)** | `harness/vision_critic.py:43` lê `CRITIC_AWS_PROFILE` (default `voice-dev`, que não existe aqui). `junior-dev` existe em `~/.aws/config` e resolve, mas **os 4 perfis falham `InvalidClientTokenId`** (`GetCallerIdentity` nos source, `AssumeRole` nos de role). **Falta:** rotacionar as access keys estáticas de `junior-dev-source`/`junior` + acesso Bedrock a `us.anthropic.claude-fable-5` em `us-east-1`. AWS CLI 2.36.24, boto3 1.43.73, Pillow 12.3.0 já instalados |
| Importer LDtk (`tools/import_ldtk.rb`) | **DISPONÍVEL sem GUI** | 18,7 KB, `PINNED_JSON_VERSION = "1.5.3"`; fixture real `test/fixtures/spike_district.ldtk`; 41 testes verdes aqui |
| LDtk 1.5.3 GUI (autoria de mapas) | **FALTANDO** | Nada no PATH, `Program Files`, `Program Files (x86)`, `AppData\Local`, `AppData\Local\Programs`. **Falta:** instalar `LDtk-1.5.3-installer.exe` (nome em `drafts/_ldtk-spike-findings-20260819.md:19`). Só necessário para **autorar/editar**, não para import→emit |
| Clipes (`harness/make_clip.sh`) | **DISPONÍVEL** | ffmpeg `N-125573-g90436de5e1-20260713` em `/c/Users/jr/bin/ffmpeg`, com `ffprobe` |
| `harness/self_eval.py`, `harness/video_analyst.py` | **BLOQUEADO (2×)** | `PROFILE = "voice-dev"` **hardcoded, sem override por env** (só `vision_critic.py` lê a env) + a mesma credencial morta. Não editei nada |
| Python | **DISPONÍVEL com pegadinha** | 3.14.6 em `C:/Python314`; `python` e `py` existem, **`python3` não existe** — qualquer script que invoque `python3` falha aqui |
| `SOAK_AUDIO=1` | **NÃO VERIFICADO** | Depende da lib irmã `game-two-audio` (miniaudio.dll via ffi); fora desta varredura |

**Resumo honesto / Resumen honesto:** roda hoje sem instalar nada — `test`, `soak`, `capture`, `canary`, `manifest`, `map`, `perf`, `run`, `pilot`, `gate` com `SKIP_CRITIC=1`, importer e clipes. **Não** roda: qualquer veredito de visão/Bedrock, e autoria de mapas novos.

---

## 3. A proposta: dividir por LANE, não por arquivo / La propuesta: repartir por LANE, no por archivo

**Argumento central.** Dois agentes editando o mesmo arquivo — ou a mesma lane — produz três custos garantidos:

1. **Conflito de merge** no arquivo grande. `src/game/world.rb` e `src/game/controllers.rb` são exatamente os arquivos onde as duas lanes se cruzariam.
2. **Risco de gate.** O AI roda dentro de `World#tick` (`src/game/world.rb:701`) **antes** de `resolve_attacks`; tile e HP de todo corpo entram em `digest_snapshot` (`world.rb:633-650`) e no md5 (`src/net/state_digest.rb:44-52`). Duas mudanças de decisão simultâneas invalidam walls pinados (`test/harness/wall_pin_test.rb`, `run_wall_test.rb`, `sim_identity_canary_test.rb`) e ninguém sabe qual delas re-pinar.
3. **Medição confundida.** É a mesma lógica que o próprio spark P0 usa para bloquear o P2: "measure before tuning", e R-A3 não pode ser empacotado com R-A1 porque mediria lama.

**Regra proposta:** um dono por lane; **fronteira de arquivos declarada por escrito antes de começar**; `git pull --ff-only` antes de qualquer coisa; handoff por `drafts/` (nunca por edição direta no arquivo do outro). Se uma lane precisar de um arquivo da outra, o pedido vai como diff nomeado em `drafts/`, e o dono da lane aplica.

**ES:** un dueño por lane, frontera de archivos declarada por escrito, `pull --ff-only` siempre, handoff por `drafts/`. Si mi lane necesita tu archivo, te paso el diff en `drafts/` y lo aplicas vos.

### Recorte A — Execução & medição (zero código-fonte deste lado)

- **Escopo de arquivos deste assento:** nenhum arquivo em `src/**`, `harness/**`, `tools/**`, `Rakefile`. Escreve apenas em `tmp/**` (artefatos) e `drafts/_junior-*.md` (relatório).
- **Por que este assento:** soak já rodou aqui (`tmp/soak/20260818-175253`, `…-180058`), tem bash + `timeout` + Gosu + loopback, e o custo é tempo de máquina (≈10 min/episódio × N), não tempo de autor.
- **O que o Gabriel mantém:** 100% do código do P0 — instrumentação env-gated, semântica de stall, `src/net/**`, `harness/**`.
- **Sincronização:** ele commita a instrumentação; eu faço `pull --ff-only`, rodo os episódios, entrego números em `drafts/_junior-*`; ele decide. Conflito estruturalmente impossível: nossos conjuntos de arquivos são disjuntos.
- **Limite honesto:** sem credencial AWS eu não fecho a metade critic do gate (§2).

### Recorte B — Lane "IA do terceiro corpo" (R-A3 / P5) para este assento

- **Escopo de arquivos deste assento:** `src/game/controllers.rb` (o `AiController`, `:96`), um bloco novo de chaves em `data/balance/**`, e um arquivo de teste **novo** em `test/game/`. Toques em `src/game/world.rb` restritos a duas funções nomeadas (`surround_slot` `:324-333`, e o gate de `ally_flee_hp_pct` `:183`) — e se você preferir, esses dois **não** são meus: viram diff nomeado em `drafts/` para você aplicar.
- **Por que este assento:** foi o Junior que reportou o sintoma na R3 do ritual, e o diagnóstico de código já está feito daqui (§4 abaixo, com file:line).
- **O que o Gabriel mantém:** P0 lag inteiro (`src/net/**`, telemetria), P1 renderer/strings, P3 flywheel renderer, e a decisão de re-pin de wall.
- **Sincronização:** eu não dou push sem a suíte verde e sem `rake gate` (determinismo) local; o re-pin de wall é **seu** call, porque muda md5.
- **Autorização:** **necessária.** É sim-class (§4).

### Recorte C — World-builder T3/T4 (P4)

- **Escopo de arquivos deste assento:** `tools/import_ldtk.rb`, `test/tools/**`, fixtures, docs do WB. Comportamentos de tile SAFE (não-sim) apenas.
- **Por que este assento:** o importer já é verde aqui (41/119/0/0), e a máquina pode instalar o LDtk 1.5.3 GUI, que hoje falta e é pré-requisito de autoria (T4).
- **O que o Gabriel mantém:** qualquer comportamento SIM-CLASS de tile (lava/água/spawns), que a fila já marca como incremento gated, e a spec do WB, que aguarda as respostas do grill (`drafts/_world-builder-grill-20260819.md`).
- **Sincronização:** mesma regra; T1/T2 já shipados (`3addeb8`, `a858227`) então a base é estável.
- **Autorização:** ordem "WB vs lag" está registrada como **decisão do dono**. Não começo sem sua palavra.

---

## 4. Candidato #1 recomendado: R-A3, a IA do terceiro corpo / Candidato #1: la IA del tercer cuerpo

**Sintoma reportado pelo próprio Junior na R3 do ritual:** o terceiro corpo morre muito, corre para dentro dos inimigos. Está na fila em P5 (`drafts/_v18-fun-verify-verdict-20260820.md`, row 6) e como "AI-body suicides" em `PARKING_LOT.md:665`.

**Diagnóstico de código (feito nesta máquina, tudo ancorado):**

- **a) O único passo de aproximação mira um tile ADJACENTE.** `chase_step` (`src/game/controllers.rb:336`) anda para `surround_slot`, que é o primeiro tile livre do anel imediato do alvo (`src/game/world.rb:329`, anel = `Creature::RING`, `src/game/creature.rb:11`). Qualquer corpo que decida engajar caminha até dist 1 — **inclusive o lobber**.
- **b) O lobber desalinhado é lido como "fora de alcance" e então FECHA distância.** `in_attack_range?` (`controllers.rb:274-284`) exige, para projétil, alinhamento 8-vias **+** `dist >= 2` **+** `dist <= range_tiles` **+** linha limpa (`world.rb:369-379`). A dist 5 desalinhado (dx=5, dy=3) ele não está em alcance → cai no `elsif` (`:242`) → `retreat_step` só dispara com `dist < 2` (`:243`) → logo, `chase_step`. **Não existe passo de "alinhar mantendo distância": o único reposicionamento do código é fechar.**
- **c) Dist 1 = dano garantido.** rusher/husk/challenger atacam em `arc: "ring"` (`data/balance/combat.json`) = os 8 adjacentes (`src/game/creature.rb:183-184`), e o `step_frames` do lobber (16) é igual ao do rusher (16). O próprio teste admite o counter-chase: `test/game/world_test.rb:544-545` ("The rusher counter-chases at similar footspeed, so distance at any fixed frame is racy"). Resultado: oscilação 1↔2 **dentro** do ring inimigo.
- **d) O aliado nunca esquiva nem usa special.** `dodge` / `start_special` existem só no `PossessedController` (`controllers.rb:53-54`, `:63`); o `AiController` emite apenas `start_attack` (`:241`). Humanos telegrafam 20-30f de windup e ninguém reage.
- **e) Recuo por HP existe mas está morto em single-player.** `fleeing?` (`controllers.rb:171-177`) depende de `ally_flee_hp_pct`, definido **só** sob `seats."2"` em `data/balance/coop.json` (verificado: o arquivo tem exatamente `seats.2` → `respawn_delay_scale 2.0`, `human_hp_scale 1.25`, `ally_flee_hp_pct 0.35`; **nada para seats=1**). Em seats=1, `@coop` é nil (`world.rb:63`, `:183`) → `fleeing?` sempre false → o terceiro corpo luta até 1 HP.
- **f) Aggro largo + mark sem gate.** `aggro_tiles: 10` para todo o kit do pack; `follow` (`controllers.rb:286-293`, `FOLLOW_DISTANCE = 2` em `:97`) só roda quando nada está em aggro (`:158-163`); e o mark **ignora** o gate de aggro (`:157-158`), com `mark_leash_tiles: 14` (`world.rb:1542`). O aliado atravessa a sala até ficar adjacente.
- **g) O aliado não tem papel "pressuring"** (anel 2, não-golpeador): `partition_pressure` itera só `humans` (`world.rb:339-350`), e todas as chaves de `data/balance/threat.json` (`pressure_ring_tiles 2`, `engaged_cap_per_target 5`, …) afetam só humanos.
- **h) Não existe tuning para isso.** Nenhuma chave de banda de distância/kite para o pack AI em `data/**`.
- **i) Cobertura de teste é rasa neste ponto.** `test/game/world_test.rb:534` e `:558` cobrem apenas `dist <= 1` (abrir range / encurralado); `test/game/coop_feel_test.rb:117-180` cobre flee só em seats=2. **Nada** cobre "lobber a 5 tiles desalinhado não deve fechar até 1".

**Esboço de mudança (não implementado):** banda de distância derivada do kit (melee 1; projétil ~3..`range_tiles`); um `reposition_step` que busque **alinhamento + linha limpa dentro da banda** quando `dist <= range_tiles`, em vez de `chase_step`; `surround_slot` restrito a kits melee; gatilho de `retreat_step` de `dist < 2` para `dist < banda_min`; opcional, dodge reativo a `telegraphing?` (`world.rb:1089`). Números novos só em `data/**`.

**Por que faz sentido este assento pegar:** quem reportou o sintoma foi o Junior, na R3; o diagnóstico já saiu daqui com file:line; e o recorte é o `AiController` inteiro — um arquivo que **não** aparece em nenhuma das lanes do P0 (netplay/telemetria) nem do P1/P3 (renderer/strings). Fronteira natural, conflito zero.

**Limite honesto, dito sem rodeio / Límite honesto:**

- É **sim-touching**. As quatro regras de ciclo vigentes o bloqueiam sem sua palavra: (1) `AGENTS.md` l.59-66, "v19 opens at the owners' brainstorm, **not here**"; (2) veredito, "RECORDED, not started (priority is the owners')" + "v19 does NOT open here"; (3) spark P0 l.35, "Only P0 runs this session. P1–P6 exist here so nothing is forgotten and **nothing is started**"; (4) "measure before tuning".
- A fila marca R-A3 explicitamente como **não auto-buildável** (row 6) e proíbe empacotar com R-A1.
- Desgatear o `fleeing?` (mover `ally_flee_hp_pct` para bloco base) faz seats=1 executar aritmética coop, o que quebra a lei "seats=1 = zero aritmética" (`world.rb:59-63`). **Isso é decisão de dono, não minha** — e eu não a tomo nem por engano.
- Qualquer mudança de decisão do AI invalida walls pinados → re-pin + `rake gate`, e a metade critic do gate está bloqueada aqui por credencial. O re-pin final precisa passar pela sua máquina ou por credencial nova.
- Risco de lockstep que eu me comprometo a respeitar: o AI hoje **não consome RNG** (`rng_draws` está no digest, `world.rb:642`); nada de aleatoriedade, ordem dependente de hash ou Float persistido — manter `FlowField::STEPS`, `Creature::RING`, ordem do roster e Integers (precedente: `.round` explícito, `world.rb:1720`).

**Verificação independente do assento (re-conferida à mão antes de publicar este
documento) — e uma correção de ênfase que ela produziu:**

`data/balance/coop.json` tem, de fato, EXATAMENTE um bloco (`seats."2"`:
`respawn_delay_scale 2.0`, `human_hp_scale 1.25`, `ally_flee_hp_pct 0.35`), e
`fleeing?` (`src/game/controllers.rb:171-177`) devolve `false` quando `pct` é nil —
achado (e) confirmado literalmente.

**Mas atenção ao escopo:** as duas sessões do ritual que geraram o relato do Junior
foram **co-op, seats=2** — ou seja, o recuo a 35% **estava ATIVO** e a IA morreu muito
mesmo assim. Conclusão: o gate de `fleeing?` explica o comportamento em **solo**, não
o relato dele. O que explica o relato é a parte de **aproximação** (achados a–d:
`chase_step`/`surround_slot` sem banda de distância por kit, mais aggro 10 + mark sem
gate) — o corpo não-possuído fecha até ficar adjacente mesmo sendo o lobber, cujo
alcance é 6 tiles. Se a lane for autorizada, é aí que o trabalho começa; mexer só no
limiar de fuga não resolveria o que ele viu.

**Portanto: isto é uma oferta, não uma ação tomada.** Nenhuma linha foi escrita. / **Por lo tanto: es una oferta, no una acción tomada.** Ni una línea escrita.

---

## 5. O que este assento pode fazer JÁ, sem autorização de escopo / Qué puede hacer YA, sin autorización de alcance

Tudo abaixo **não muda comportamento do jogo** e **não edita `src/**`, `data/**`, `harness/**` ou `tools/**`**:

1. **Rodar a suíte inteira** (`rake test`) e reportar o número real, em vez de citar `docs/CHECKPOINT.md:138`.
2. **Rodar soak para reproduzir e MEDIR a IA do terceiro corpo** — episódios com o build atual, observando o que o log e os artefatos já emitem hoje. Entrega: distâncias/mortes observadas em `drafts/_junior-*`, nada mais.
3. **Rodar `rake gate` na metade determinismo** (`SKIP_CRITIC=1`) para provar que a árvore está limpa antes de qualquer lane começar — sabendo e declarando que isso **não é** um pass shippable.
4. **Rodar `capture` / `canary` / `perf` / `manifest` / `map`** e gerar clipes com ffmpeg.
5. **Preparar ambiente do world-builder:** baixar e instalar `LDtk-1.5.3-installer.exe`, o único pré-requisito de autoria que falta aqui. Instalar ferramenta ≠ começar T3/T4.
6. **Testar a credencial AWS de novo** se você repuser as access keys, e reportar `GetCallerIdentity` / `AssumeRole` cru.

**MEDIR NÃO É CONSERTAR / MEDIR NO ES ARREGLAR.** Duas consequências que eu aceito por escrito: (a) se a medição da IA exigir uma sonda nova no código, isso deixa de ser medição e passa a precisar da sua autorização — eu paro e pergunto; (b) nenhum número que eu produzir autoriza mudar um escalar de balance: a regra "measure before tuning" continua valendo depois da medição, não só antes.

---

## 6. Perguntas fechadas / Preguntas cerradas (máx. 4, uma palavra cada)

1. **Assumo o Recorte A (execução & medição do P0, zero código-fonte deste lado)?** sim / não
2. **Assumo a lane R-A3 (IA do terceiro corpo, `controllers.rb` + `data/**` + teste novo), ou ela fica congelada até o brainstorm?** assumo / congelada
3. **Se assumo R-A3: os toques em `world.rb` (`surround_slot`, gate do `ally_flee_hp_pct`) são meus ou vão como diff em `drafts/` para você aplicar?** meus / diff
4. **Instalo o LDtk 1.5.3 GUI agora (só ferramenta, sem começar T3/T4)?** sim / depois

---

## 7. Nota de protocolo / Nota de protocolo

- Este assento **nunca dá push em lane que não é dele**. Fronteira de arquivos declarada antes de começar; se eu precisar de um arquivo seu, o pedido vai como diff nomeado em `drafts/`.
- `git pull --ff-only` antes de qualquer coisa e antes de todo push. Sem merge commit, sem rebase por cima do seu trabalho.
- Suíte verde via hooks antes de push. Se um hook reclamar, eu conserto a causa — não pulo o hook.
- **Superfícies congeladas não se tocam**, e as regras de ciclo vigentes (as quatro citadas em §4) valem acima de qualquer coisa deste documento.
- Escopo desta oferta: só o que você validar. Silêncio não é sim. / El silencio no es un sí.
