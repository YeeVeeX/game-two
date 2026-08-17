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
   git clone -b junior-tibia https://github.com/YeeVeeX/game-two.git
   cd game-two
   bundle install
   ```
   (O `-b junior-tibia` importa: essa é a nossa linha compartilhada — a
   `main` é só o backup do Gabriel e fica atrás.)
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
| Esc | sair (salva a telemetria — sempre saia com Esc) |

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

- **Nunca dê push na `main`** — ela é a linha de backup do Gabriel.
- **`junior-tibia` é a NOSSA linha compartilhada**: trabalhe nela (ou em
  branches seus) e abra PRs para `junior-tibia`.
- `git fetch` sempre antes de começar — o Gabriel empurra progresso com
  frequência.
- Os testes rodam com `bundle exec rake` (o hook de push roda sozinho).

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
   tenta de novo por alguns minutos. Esc (saída limpa) termina de
   verdade — o atalho não insiste.

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

- **Saia sempre com Esc** — os dois lados gravam a saída e a telemetria.
- `DESSINCRONIA NO TICK N — SESSÃO ENCERRADA`: as duas sims divergiram;
  o jogo para DE PROPÓSITO e aponta um arquivo em `tmp/netplay/` —
  guarde e compartilhe esse arquivo, ele é o trabalho do dev.
- `CONEXÃO PERDIDA — SESSÃO ENCERRADA`: a conexão caiu por mais tempo
  que a tolerância (45 segundos — internet ruim de verdade, não um
  engasgo).
- Depois de qualquer fim, o console imprime o comando exato para
  relançar dos dois lados.

**Depois da primeira partida:** cole a sua linha `TELEMETRY netplay ...`
do console (em drafts/ ou mensagem) e responda as 4 perguntas
pré-registradas — é o 16º veredito.

---

## 🇬🇧 How to run the game (Windows)

1. **Install Ruby 3.4 WITH the DevKit** (mandatory — the `gosu` gem
   compiles from source on this version): RubyInstaller 3.4.x + DevKit
   from https://rubyinstaller.org/downloads/, keep **"Run 'ridk install'"**
   checked and accept the default (MSYS2 + toolchain).
2. **Clone + install:** `git clone -b junior-tibia https://github.com/YeeVeeX/game-two.git`,
   `cd game-two`, `bundle install`. (The `-b junior-tibia` matters — that is
   our shared line; `main` is Gabriel's backup and runs behind.)
3. **Play:** `bin\play.cmd pt-br` (cmd) or `bin/play pt-br` (Git Bash).
   No argument = English; `es` = Spanish, `pt-br` = Portuguese.

Controls: WASD/arrows move · J/Space attack · K/Shift dodge · L/E special ·
;/Q mark · H/F interact · Tab swap possession · Esc quit (flushes telemetry
— always exit with Esc).

Custom keys (v15): create `data/bindings.local.json` (gitignored,
per-machine) listing only the actions you want to change — each entry
replaces that action's whole key list; first key becomes the primary on
the bottom strip. Valid names: A–Z, 0–9, arrows, Space, Tab, Enter,
L/RShift, L/RCtrl, LAlt, `;`, `,`, `.`. A typo or a key bound to two
actions stops the game at startup with the exact problem printed (the
window waits on `pause` — read it, fix the file). ABNT2 note: scancodes
are positional (US layout), so `;` may sit elsewhere physically — remap
`mark` to a letter in your local file.

Collaboration: never push `main` (Gabriel's backup line); `junior-tibia`
is the shared line — work there or PR into it; `git fetch` before starting;
tests are `bundle exec rake` (the push hook runs them automatically).

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
auto-repossession. Ends: Esc always (both seats record + flush
telemetry); DESYNC freezes honestly and points at the `tmp/netplay/`
artifact — keep and share yours; after any end the console prints the
exact relaunch command. After the first session: paste your
`TELEMETRY netplay` line and answer the four pre-registered questions
(the SIXTEENTH verify).
