# Bem-vindo, Junior! / Welcome, Junior!

> Português primeiro; English mirror below.

## 🇧🇷 Como rodar o jogo (Windows)

1. **Instale o Ruby 3.4 COM o DevKit** (obrigatório — a gem `gosu` compila
   do zero nesta versão):
   - Baixe o **RubyInstaller 3.4.x com DevKit** em https://rubyinstaller.org/downloads/
   - Na última tela do instalador, deixe marcado **"Run 'ridk install'"** e
     aceite a opção padrão (MSYS2 + toolchain). Sem isso o `bundle install`
     falha ao compilar a gosu.
2. **Clone e instale:**
   ```
   git clone https://github.com/YeeVeeX/game-two.git
   cd game-two
   bundle install
   ```
   (A `main` é a NOSSA linha compartilhada — os dois assentos commitam
   nela. A antiga `junior-tibia` não existe mais no origin.)
3. **Jogue:**
   ```
   bin\play.cmd pt-br      (cmd / duplo clique)
   bin/play pt-br          (Git Bash)
   ```
   Sem argumento o jogo abre em inglês; `es` = espanhol, `pt-br` = português.

### Controles

| Tecla | Ação |
|---|---|
| WASD / setas | mover |
| J / Espaço | atacar |
| K / Shift | esquiva |
| L / E | especial |
| ; / Q | marcar alvo |
| H / F | interagir (lojas do HUB 1, saque, banco) |
| Tab | trocar de corpo (possessão) |
| Esc | menu (o mundo NÃO pausa; sair = opção SAIR do menu — a saída limpa salva a telemetria) |

### Teclas personalizadas (v15)

As teclas acima são as padrão (`data/bindings.json`, versionado — não
mexa nele). Para usar as SUAS teclas, crie um arquivo **novo** chamado
`data/bindings.local.json` — ele é ignorado pelo git, então nunca gera
conflito e cada máquina pode ter o seu:

```json
{
  "mark": ["M"],
  "dodge": ["K", "RShift"]
}
```

- Só liste as ações que quer mudar; cada linha SUBSTITUI a lista inteira
  daquela ação (a primeira tecla vira a principal na barra inferior).
- Ações: `left right up down attack dodge special mark interact swap`.
- Nomes de tecla: `A`–`Z`, `0`–`9`, `Up Down Left Right`, `Space`, `Tab`,
  `Enter`, `LShift RShift LCtrl RCtrl LAlt`, `;`, `,`, `.`
- **Teclado ABNT2:** as posições vêm do layout americano (scancodes),
  então o `;` pode cair em outra tecla física — é exatamente para isso
  que o arquivo local existe: remapeie `mark` para uma letra.
- Errou um nome? O jogo NÃO abre e mostra a lista válida no console
  (a janela espera com `pause` — leia a mensagem, corrija o arquivo).
- Uma tecla não pode servir duas ações — o jogo avisa qual conflitou.

### Fluxo de colaboração (combinado com o Gabriel)

- **A `main` é a NOSSA linha compartilhada** (combinado 2026-08-23; a
  antiga `junior-tibia` foi desligada): os dois assentos commitam na
  `main` — `git pull --rebase` antes do push, commit de uma preocupação
  só, os hooks rodam a suite sozinhos.
- `git fetch` sempre antes de começar — o Gabriel empurra progresso com
  frequência.
- Os testes rodam com `bundle exec rake` (o hook de push roda sozinho).

### Sessões com agente (combinado 2026-08-18)

Se você usa um agente de código (pi, Claude, etc.) neste repo, o combinado é:

- **Uma janela por repo.** Nunca dois agentes escrevendo no mesmo repo ao
  mesmo tempo — feche a sessão antiga antes de abrir outra.
- **Começo de sessão:** `git pull` primeiro, sempre; o agente lê o
  `AGENTS.md` e as entradas novas no topo do `docs/CHECKPOINT.md` antes
  de mexer em qualquer coisa (os arquivos valem mais que a memória dele —
  é no checkpoint que o Gabriel deixa recados para este assento).
- **Fim de sessão:** testes verdes, um resumo curto em
  `drafts/_junior-<assunto>-<data>.md` (o que fez, o que falta, onde estão
  as provas) e push.
- **Provas são as linhas `TELEMETRY`** dos logs de sessão
  (`%TEMP%\game_two_session_*.log`) — guarde os arquivos; sem log, a
  partida não conta para os testes rituais.
- **Achou um bug no meio de outra tarefa?** Anota no rascunho e segue —
  consertar vira tarefa própria depois (assim ninguém quebra o que o outro
  está fazendo).
- **Trabalho nos repos vizinhos** (lore / assets / audio) sai do chat do
  Gabriel (ele orquestra tudo de um chat só); pede por um rascunho em
  `drafts/` que ele roteia.

### Editar mapas no LDtk (WB-T6, 2026-09-05)

O arquivo dos mapas é `authoring/pilot.ldtk` (13 zonas). Regras da casa:

- **Versão do LDtk: 1.5.3, fixa.** Instalador com md5
  `11f9057d5889c0e51eee2ed43e8096cf` (registro:
  `drafts/_ldtk-spike-findings-20260819.md`). Se o programa oferecer
  atualização, **recuse** — trocar de versão é uma decisão dos dois, não
  um clique.
- **Ctrl+S roda a pipeline sozinho.** O projeto tem um comando
  "AfterSave": na primeira vez o LDtk pergunta se confia nos comandos do
  projeto — diga sim. A cada salvar ele (1) arruma os bytes do arquivo
  no formato que os scripts exigem, (2) roda o importador para
  `tmp/ldtk_out` (nunca para `data/zones`) e (3) checa o grafo do mundo
  (destino existe, ponto de chegada pisável, andar certo por tipo de
  passagem). Deu certo = a janelinha fecha sozinha. Deu erro = ela fica
  aberta com o motivo; corrija e salve de novo. Copiar para `data/zones`
  continua sendo um passo consciente, com testes verdes.
- **O que precisa na sua máquina:** `python` e `ruby` acessíveis pelo
  PATH do Windows (o LDtk chama `python` direto, sem shell). Confira no
  `cmd`: `where python` e `where ruby` — os dois têm que responder com um
  caminho. Sem Python: instale o do python.org e marque "Add to PATH".
  O Ruby do jogo (`C:\Ruby34-x64\bin`) o script já encontra sozinho
  se estiver nessa pasta.
- **Nunca edite o `pilot.ldtk` num editor de texto.** GUI + Ctrl+S, ou
  script + `python tools/normalize_ldtk.py normalize authoring/pilot.ldtk`.
  Antes de commitar: `python tools/normalize_ldtk.py --check
  authoring/pilot.ldtk` tem que dizer `canonical` (a suite também checa).
- **Backups automáticos** ficam em `tmp/ldtk-backups/` (10 últimos,
  fora do git). Restaurar só pela própria tela do LDtk.
- Passe o mouse nos campos das entidades: cada um tem uma dica do que
  aceita (`to` = nome da zona, `price` = chave do balance, etc.).
  Detalhes e leis: `docs/MAP_EDITING.md` §4.
- **Cuidado (medido em 2026-09-05):** cinco passagens têm o `spawn`
  fora do retângulo da própria zona (o destino é outra zona) — o LDtk
  mostra `<ERR: Invalid field value>` em vermelho nelas. Não mexa nessas
  no editor (ele pode apagar o valor); o importador recusa e a janela
  do Ctrl+S fica aberta avisando. A correção do modelo é um ticket
  próprio (WB-T7).

### Assistir às partidas um do outro (replays determinísticos)

O jogo é 100% determinístico: um script de replay reproduz uma partida
tick a tick, idêntica. Os scripts vivem em `harness/scripts/*.json`.

```
export PATH="/c/Ruby34-x64/bin:$PATH"     # Git Bash, uma vez por shell
rake capture SCRIPT=harness/scripts/world_loop.json
```

Isso abre uma janela, reproduz a partida gravada e salva frames em
`captures/`. Era o estágio 0 do plano de co-op — e a etapa 1 chegou:

### Jogar junto pela internet (v17 — co-op)

O co-op é 1 pack, 2 pilotos: você e o Gabriel possuem corpos diferentes
do MESMO trio (a IA pilota o que sobrar). Mesmo combate, mesmo banco,
mesmas apostas — e vocês só trocam de zona juntos.

**Preparação (uma vez só):**

1. **Instale o Tailscale** (o túnel seguro entre as duas máquinas — sem
   servidor, sem conta AWS): baixe e rode
   `https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe`,
   aceite o aviso do Windows (UAC) e conclua. Instalado é suficiente —
   o login vem no passo 2.
2. **Aceite o convite do Gabriel**: ele envia um link da rede dele;
   clique e entre com a sua conta. O ícone do Tailscale na bandeja fica
   conectado e a máquina dele ganha um IP `100.x.y.z` — é esse IP que
   você usa para entrar na partida.

**Toda sessão (o ritual):**

3. **`git pull` ANTES de jogar, sempre.** O jogo confere se os dois
   builds são idênticos; se o seu estiver velho ele RECUSA entrar e
   imprime no console exatamente o que difere, com a dica (`git pull`).
   Isso é proteção, não defeito.
4. **Entre na partida** (o Gabriel hospeda e te passa o IP dele):
   ```
   bin\play.cmd pt-br --join 100.x.y.z     (cmd)
   bin/play pt-br --join 100.x.y.z         (Git Bash)
   ```
   Porta só se ele avisar (`--join ip:porta`; a padrão é 43117).

   **Atalho de um clique:** `bin\join-coop.cmd` faz os passos 3 e 4
   sozinho — puxa a linha, acha o IP do host no Tailscale ao vivo e
   entra (`bin\join-coop.cmd check` só confere tudo, sem abrir o jogo;
   um IP explícito como 1º argumento tem prioridade). Se a conexão
   cair no meio, ele **re-entra sozinho**; se o host estiver fora do ar,
   tenta de novo por alguns minutos. Sair pelo menu (Esc → SAIR) é
   saída limpa e termina de verdade — o atalho não insiste.

**O que você vai ver (tudo normal):**

- `CONECTANDO…` até o aperto de mão terminar; o jogo abre nos dois
  lados ao mesmo tempo.
- O corpo do Gabriel carrega um **anel de outra cor** — o seu continua
  como sempre.
- `AGUARDANDO PARCEIRO` + milissegundos = a conexão engasgou; o jogo
  espera em vez de dessincronizar. Não feche.
- `CONEXÃO LENTA` no início = internet ruim hoje; dá para jogar, com
  mais atraso que o normal.
- `AGUARDANDO NO PORTÃO` = trocar de zona exige os corpos controlados
  vivos juntos no portão.
- `SEM CORPO — AGUARDANDO` = você ficou sem corpo; vira espectador (a
  câmera segue o parceiro) até um corpo voltar — a repossessão é
  automática.

**Como termina:**

- **Saia sempre pelo menu (Esc abre; opção SAIR)** — os dois lados
  gravam a saída e a telemetria.
- `DESSINCRONIA NO TICK N — SESSÃO ENCERRADA`: as duas sims divergiram;
  o jogo para DE PROPÓSITO e aponta um arquivo em `tmp/netplay/` —
  guarde e compartilhe esse arquivo, ele é o trabalho do dev.
- `CONEXÃO PERDIDA — SESSÃO ENCERRADA`: a conexão caiu por mais tempo
  que a tolerância (45 segundos — internet ruim de verdade, não um
  engasgo).
- Depois de qualquer fim, o console imprime o comando exato para
  relançar dos dois lados.

**Depois de cada partida:** cole a sua linha `TELEMETRY netplay ...`
do console (em drafts/ ou mensagem) e responda as perguntas quando o
SEU dev fizer, uma por uma — é o ritual de toda verificação (a 16ª e
a 17ª fecharam assim; a 18ª está preparada). Na 18ª: as respostas vêm
depois da sessão 2 e ANTES de vocês dois comentarem a partida entre
vocês; as perguntas moram seladas na spec — não as leia antes (é o
que faz a medição valer). O roteiro:
`drafts/_v19-eighteenth-runsheet-20260826.md`.

### Som no jogo (novo — os sons que o Gabriel criou)

O jogo agora toca os sons que o Gabriel gravou (música, aviso de
chefe, confirmações). Para OUVIR na sua máquina, uma preparação única:

1. **Clone a biblioteca de som DO LADO da pasta do jogo** (mesma pasta
   mãe — o jogo procura por `../game-two-audio`):
   ```
   cd ..
   git clone https://github.com/YeeVeeX/game-two-audio.git
   cd game-two
   ```
2. **`bundle install`** (entra uma gem nova, `ffi` — já vem pronta,
   não compila nada).
3. **Jogue normal.** No log da partida aparece `AUDIO on: ...` = som
   ligado.

Se aparecer `AUDIO off` ou `AUDIO refused`: o jogo roda normal, em
silêncio, e a partida VALE do mesmo jeito — só mande a linha que
apareceu. O som nunca mexe na partida em si (não afeta o co-op nem o
mundo salvo); é só o que sai na caixa.

### O mundo agora continua (v18 — persistência)

O mundo não zera mais a cada partida: banco, selos rompidos, marcas,
poções e o contador de sessões sobrevivem entre sessões.

**De quem é o save (como funciona, sem pegadinha):**

- O mundo compartilhado mora na máquina do **host** (o Gabriel). Ele
  avança quando o Gabriel joga — sozinho ou hospedando — e quando VOCÊ
  entra com `--join`. Jogar junto conta: é assim que você move o mundo
  compartilhado.
- Você jogando solo na SUA máquina = o SEU próprio mundo, separado, no
  SEU `saves/world.json`. Ele não se mistura com o compartilhado —
  juntar linhas de mundo divergentes é assunto da era "sempre online"
  (estacionada, com gatilho nomeado).
- Quem entra (`--join`) NUNCA grava o mundo compartilhado no próprio
  disco: você recebe o mundo pelo aperto de mão, joga nele, e ele
  volta a dormir na máquina do host.

**Onde vive e como se prova:**

- O save é `saves/world.json` (ignorado pelo git). Nunca edite à mão —
  o jogo recusa um save inválido NOMEANDO o problema no console.
- O jogo grava SÓ na saída limpa (**SAIR no menu**, ou fechar a
  janela). Desync, queda de conexão
  ou crash não gravam nada — um mundo suspeito nunca envenena o save.
- As linhas `TELEMETRY persist ...` provam a continuidade (digest do
  save + banked/seals/marks/sessions). Elas ficam no log da sessão
  (`%TEMP%\game_two_session_*.log` no `.cmd`); quando você entra numa
  partida, a sua linha diz `source=handshake`.

**O aviso do `--fresh` (recomeçar do zero):**

- Se o host recomeça (`--host --fresh`), o histórico MOSTRA: o save
  antigo vira `saves/world.json.bak-<data>` (nada se perde em
  silêncio), o console do host imprime `persist fresh source=fresh`, e
  o contador `sessions=` das linhas seguintes recomeça baixo. Naquela
  primeira sessão o seu console não mostra linha `loaded` nenhuma —
  mundo novo, nada a carregar.
- `--fresh` também funciona no SEU solo (recomeça o SEU mundo, com o
  mesmo backup). Com `--join` ele RECUSA — o save mora com o host,
  não com quem entra.

**Pull antes de jogar agora é CRÍTICO:**

- O v18 mudou o protocolo (v2) e deu schema ao save. Um assento
  desatualizado é RECUSADO no aperto de mão com o campo exato no
  console (ex.: `protocol version: ours ... / theirs ...`) e a
  sugestão do fix: `git pull` nos DOIS lados, mesmo commit, e
  relançar. Proteção, não defeito — igual ao aviso de build do v17.

**Suprimentos (v18 — a cura de caçada, nas SUAS palavras):**

| O quê | Como |
|---|---|
| Comprar | parado numa estação de banco, tecla **U** (ou R) — 5 do banco por carga, até 3 |
| Usar | em QUALQUER outro lugar, mesma tecla — cura quem estiver vivo no trio |
| Recusa | `RECUSADO` na tela: sem saldo, no limite, sem carga, ou ninguém ferido |

- O par de teclas fica SEMPRE na barra de baixo (`poção`) e o contador
  `POÇÃO N` fica sempre à direita — no zero ele mostra `POÇÃO 0`
  (v20 T3: antes só apareciam com carga; agora ensinam o tempo todo).
- `POÇÃO COMPRADA` / `POÇÃO USADA` piscam na hora, em cima
  da estação ou de quem usou.
- Nunca é de graça e não regenera: é valor do banco virando fôlego de
  caçada — gaste com intenção.


## 🇧🇷 O time multi-agente do seat (2026-09-06) — como abrir uma raia sem perguntar

Um dev (o integrador = a sessão do pi) + **raias** (agentes filhos com worktree e
branch próprios) que constroem em paralelo sem colidir. Provado hoje em 3 raias
(`a3-stalemate`, `e3-presentation`, `signage`) + 3 revisores a frio.

**Agentes** (em `~/.pi/agent/agents/`, modelo `gateway-llm/fable-5.1-thinking`):
- `lane-worker` — constrói UM brief; tem o tool `subagent` → lança seus próprios
  ajudantes (`scout` pra mapear, `reviewer` pra revisar o diff antes do receipt).
- `lane-reviewer` — só lê; veredito `MERGEABLE | WITH MINORS | BLOCKED` com tabela.
- Os prontos (`worker`/`reviewer`/`delegate`/`oracle`) também estão em fable via
  `settings.json → subagents.agentOverrides`; `scout`/`researcher` ficam no default.
- Se um filho voltar `failed: model_verification_failed` com o trabalho feito, é o
  alias do gateway (`claude-fable-5-1`): a cura está em
  `~/.pi/agent/extensions/subagent/config.json → modelResponseAliases`; esse arquivo
  só é lido na carga da extensão → `/reload` depois de editar.

**A cerca** (`tools/lane_guard.rb`, v3; testes em `test/tools/lane_guard_test.rb`):
- Lê o brief `drafts/lanes/<raia>.md` e o `drafts/lanes/BOARD.md` de um **ref
  confiável** (`--trust <ref>`, default `main`; desde o pouso de 2026-09-07 os briefs
  estão na `main` — use `--trust origin/main` depois de `git fetch`; o branch longo
  `junior/premium-build` cumpriu o papel e daqui em diante o trabalho sai em ramos
  curtos a partir da `main`) — a raia não consegue alargar o próprio `owns`.
- `owns` = o que a raia pode commitar; `never` = o que ela nem toca; tudo em
  `drafts/lanes/` (menos `receipts/`) é POLICY = só do integrador; renames fecham
  pelos dois lados; branch tem de ser `lane/<raia>`; `src/game/**` exige a linha
  `SIM LANE: <raia>` no BOARD (o `SIM TOKEN:` humano é só atribuição).
- Roda em modo staged antes de CADA commit da raia: `ruby tools/lane_guard.rb <raia>
  --trust <ref>` → rc 0 pode; rc 1 recusa (lista o motivo); rc 2 = falha fechada.
- O integrador valida depois com `--base <sha-de-partida>` no worktree da raia.

**Abrir uma raia (integrador):**
1. Escrever `drafts/lanes/<raia>.md` (front matter `lane/branch/owns/never` + objetivo
   + Definition of Done + a lei da raia — copie de um brief em `done/`). Arquivos de
   duas raias abertas NUNCA se cruzam (o teste de sobreposição recusa).
2. Se toca `src/game/**`: `SIM LANE: <raia>` no BOARD (uma linha só; volta a `NONE`
   quando ela entrega). Registrar `RECEIPT: <raia> - OPEN ...` no BOARD.
3. Commit + push do brief/BOARD (a cerca lê do ref, não da árvore).
4. `git worktree add -b lane/<raia> ../game-two-lane-<x> HEAD` e sondar a cerca de lá
   (um path de `owns` → rc 0; um de `never` → rc 1).
5. Lançar `lane-worker` (async, cwd = o worktree, prazo 45–60 min) com o brief como
   spec e só logística na mensagem: nunca abrir janela (a máquina tem UMA janela GL —
   se uma parede está rodando, é dela), headless só (`bundle exec rake`, teste isolado,
   `tools/a3_stream_diff.rb`), cerca antes de cada commit, push, receipt.
6. Se a raia chamar (`contact_supervisor`), responder pelo `steer` do run — não pausar.

**Integrar (na ordem, ANTES de ler o relatório dela):** cerca `--base` no worktree →
`bundle exec rake` → `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run`
(= `ACTIVE bank? YES` ×3, senão vazou pro sim) → grep de relógio/rand no diff → ler
receipt (PATCH REQUESTS são do integrador aplicar) → rebase da raia sobre o branch +
ff → gates com janela dos scripts que ela listou (Rule 2) → dobrar o receipt no BOARD →
**mover o brief para `drafts/lanes/done/`** (senão os `owns` dele bloqueiam a próxima
raia nos mesmos arquivos — a cerca recusou `signage` por isso, e estava certa) →
remover o worktree (o branch fica em origin como registro).

**Ferramentas headless que nasceram disso** (nenhuma abre janela):
- `ruby tools/manifest_census.rb [scripts]` — a metade *manifest* da parede em ~60 s
  (42 scripts): rode ANTES de gastar 3,5 h de janela.
- `ruby tools/boss_probe.rb <script> <kit>` — onde um boss está por frame, em câmera
  ou não, CHANT/SEIZE, e as janelas onde uma captura o mostraria.
- `ruby tools/blink_probe.rb X,Y "right:30-44" N` — achar o frame exato de um blink
  pra autorar um reel. Lei das capturas: o runner grava a captura N **logo depois do
  tick N** (`frame_000N`, 0-based); os probes contam 1-based → "f31" = captura 0030.
- `ruby tools/a3_stream_diff.rb <canários>` — a prova de que o sim não mudou.

**Lições caras (já pagas):** heredoc com `\n`/`\\` em patch Python quebra o escape —
grave o `.py` com o tool `write` e rode `python tmp/_patch_x.py`; o watchdog do pi
alerta "bash aberto 240 s" em toda raia que roda `rake` (3–4 min) — é falso positivo
(`control.needsAttentionAfterMs: 600000` no lançamento); `--files` na cerca não expande
glob — o Git Bash expande antes. **Heredoc de shell com texto que tem backticks ou `$` → sempre `<<'EOF'` (quoted)**: sem aspas o bash executa os
backticks como comandos (a §12 da nota pro Gabriel saiu mutilada assim, 18:28). **Antes de gatear pela lista de um
plano, `ls harness/scripts/`**: nomes envelhecem (`loot_loop` foi aposentado pelo E1.4 e o plano ainda o citava).


**Lei do banco (paga em 2026-09-06 16:31):** um poll que sai por TIMEOUT não é um DONE. Antes de bancar
uma leva de gates ou uma parede: `grep -c 'DONE' <log>` = 1 **e** `tasklist //FI "IMAGENAME eq ruby.exe"` = 0,
no MESMO teste — senão o log banca N/M como M/M e o worktree de referência some antes do último `--ref`.
**E ler o VEREDITO, não só o fim:** bancar só com `gate_rc=0 manifest_rc=0` na linha `=== <script> ... ===` — um batch
termina DONE com manifest vermelho (paga 17:25: `8e0c942` bancou um `manifest_rc=1` como "42/42").

**Número bonito não é pior caso (paga 2026-09-06 18:51):** o primeiro teste do fio do bag deu 55 B — cheio com 2 ids
empilhados (o `to_save` funde por id). O pior caso do fio é o de ids DISTINTOS: 16 ids = 462 B. Antes de bancar um número
como evidência, pergunte "isto é o pior caso do que a lei protege?" e construa esse caso.


## 🇧🇷 Camadas da tela (z) — lei paga 3× em 2026-09-06
Gosu ordena por `z`, depois por ordem de chamada. A LUZ (vinheta base + pulso de vida baixa) desenha em **z 17**:
**tudo que é UI de tela nasce em z ≥ 18** — um `draw_rect`/`draw_text` sem `z` fica em 0, **embaixo da luz**, e a
parede reprova ("wash tints the HUD"). Pagaram isso hoje: a barra de controles (0→19), o banner de zona (10→18), o
backing do chip SAFE (0→19), o véu de fim do netplay (0/10→22/23).

| z | O quê | Arquivo |
|---|---|---|
| −1 | quadrado de aura (chão, embaixo dos corpos) | `signage.rb` |
| 0 | mundo: tiles, corpos, telegraphs, drops; **véus de propósito** (wipe, stagger, hurt bars) | `renderer.rb` |
| 6 / 8 | FX em espaço de mundo (callouts / números) | `fx.rb` |
| 17 | **LUZ**: vinheta base, pulso vinho, level flash (18) | `light.rb` |
| 18 | prompt de interação, setas de saída, banner de zona + stamps | `signage.rb`, `renderer.rb` |
| 19–21 | HUD plate (19) + barras/pips (20–21), barra de controles (19), minimapa (19–21), chip SAFE (19/20), boss bar (20), edge pips (21) | `hud.rb`, `controls_overlay.rb`, `minimap.rb`, `renderer.rb` |
| 22 / 23 | véu de fim do netplay + texto | `netplay_overlay.rb` |
| 29–31 | ledger beat | `renderer.rb` |
| 30 | tela da bolsa | `bag_screen.rb` |

Regra prática: overlay de tela novo → `z` explícito ≥ 18; véu que deve ficar **embaixo** do HUD → z 0 **com comentário**
dizendo que é de propósito. Se um gate disser "the HUD/strip reads tinted", procure um `draw_*` sem `z` antes de mexer em alpha.

---

## 🇬🇧 How to run the game (Windows)

1. **Install Ruby 3.4 WITH the DevKit** (mandatory — the `gosu` gem
   compiles from source on this version): RubyInstaller 3.4.x + DevKit
   from https://rubyinstaller.org/downloads/, keep **"Run 'ridk install'"**
   checked and accept the default (MSYS2 + toolchain).
2. **Clone + install:** `git clone https://github.com/YeeVeeX/game-two.git`,
   `cd game-two`, `bundle install`. (`main` is the shared line — both
   seats commit to it; the old `junior-tibia` branch is gone from origin.)
3. **Play:** `bin\play.cmd pt-br` (cmd) or `bin/play pt-br` (Git Bash).
   No argument = English; `es` = Spanish, `pt-br` = Portuguese.

Controls: WASD/arrows move · J/Space attack · K/Shift dodge · L/E special ·
;/Q mark · H/F interact · Tab swap possession · Esc menu (non-pausing —
the world keeps ticking; quit via the menu's QUIT row, which flushes
telemetry — always exit that way).

Custom keys (v15): create `data/bindings.local.json` (gitignored,
per-machine) listing only the actions you want to change — each entry
replaces that action's whole key list; first key becomes the primary on
the bottom strip. Valid names: A–Z, 0–9, arrows, Space, Tab, Enter,
L/RShift, L/RCtrl, LAlt, `;`, `,`, `.`. A typo or a key bound to two
actions stops the game at startup with the exact problem printed (the
window waits on `pause` — read it, fix the file). ABNT2 note: scancodes
are positional (US layout), so `;` may sit elsewhere physically — remap
`mark` to a letter in your local file.

Collaboration: `main` is the shared line — both seats commit to it
(`git pull --rebase` before push; the old `junior-tibia` is gone from
origin); `git fetch` before starting;
tests are `bundle exec rake` (the push hook runs them automatically).

Agent sessions (agreed 2026-08-18): one agent window per repo (never two
writers at once); `git pull` first and have the agent read `AGENTS.md`
plus the newest entries at the top of `docs/CHECKPOINT.md` before
touching anything (seat-addressed notes land there); close every session with green tests, a short
handoff note in `drafts/_junior-<topic>-<date>.md`, and a push; evidence =
the `TELEMETRY` lines in `%TEMP%\game_two_session_*.log` (keep the files);
bugs found mid-task get noted and routed, not fixed inline; sibling-repo
work (lore / assets / audio) is dispatched from Gabriel's hub chat — ask
via a drafts/ note.

Replays: the sim is fully deterministic; `rake capture
SCRIPT=harness/scripts/world_loop.json` replays a recorded run tick-for-tick
and saves frames to `captures/`.

Co-op (v17, LIVE): one pack, two pilots over Tailscale (install once from
`https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe` — no
winget needed; stay logged out until Gabriel's invite; accept it, note
his `100.x` IP). Every session: `git pull` FIRST (a stale build =
fingerprint refusal with the exact diff printed — protection, not a
bug), then `bin/play pt-br --join <ip[:port]>` (default port 43117).
In play: partner = distinct ring; the stall overlay waits instead of
desyncing; LINK SLOW = playable but laggier; zone gates need every
living controlled body co-located; a bodyless seat spectates until
auto-repossession. Ends: quit via the menu's QUIT row (Esc opens the
menu; both seats record + flush
telemetry); DESYNC freezes honestly and points at the `tmp/netplay/`
artifact — keep and share yours; after any end the console prints the
exact relaunch command. After each session: paste your `TELEMETRY
netplay` line and answer the questions when YOUR seat's dev asks,
one-by-one — the ritual of every verify (the SIXTEENTH and
SEVENTEENTH closed this way; the EIGHTEENTH is staged: answers come
after session 2 and BEFORE the two of you debrief each other, and the
questions live sealed in the spec — don't read them early).

Persistence (v18, LIVE): the world no longer resets — banked value,
breached seals, marks, potions and the sessions counter survive
across sessions. Who keeps the save: the shared world lives on the
HOST's machine (Gabriel); it advances when he plays (solo or hosting)
and when you JOIN him. You playing solo on your own machine = your OWN
separate world (your `saves/world.json`); merging divergent world
lines belongs to the parked always-online era. The joiner NEVER
persists the shared world to disk. The save is `saves/world.json`
(gitignored — never hand-edit; an invalid save is refused with the
problem NAMED); it writes on clean quit ONLY (the menu's QUIT row or
window close) — desync,
conn_lost, or a crash write nothing. `TELEMETRY persist` lines prove
continuity (they live in the session log,
`%TEMP%\game_two_session_*.log`); a joiner's line reads
`source=handshake`. `--fresh` starts over (solo or `--host`): the old
save moves to `.bak-<ts>` first — nothing is lost silently; the host
prints `persist fresh source=fresh`, that session shows no `loaded`
line (new world), and `sessions=` restarts low. `--join --fresh`
refuses — the joiner never keeps the save. Pull is now schema-critical:
v18 bumped the protocol to v2 and gave the save a schema — a stale
seat is REFUSED at the handshake naming the exact field (e.g.
`protocol version`) plus the git-pull hint.

Sustain (v18; renamed v20 T3): POÇÕES — buy standing on a bank station
(**U** or R; 5 banked per charge, cap 3), use anywhere else (same key) for a
heal of every living pack member; refusals flash `RECUSADO` (broke /
at cap / no charge / nobody hurt). The strip pair (`poção`) and the
`POÇÃO N` counter are ALWAYS on the strip now (v20 T3 escalation —
zero reads `POÇÃO 0`, the buy motivation); buys/uses flash
`POÇÃO COMPRADA` / `POÇÃO USADA`. Never free, never regenerating —
banked value becoming hunt endurance.
