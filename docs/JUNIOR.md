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
`captures/`. É o estágio 0 do plano de co-op — a etapa 1 (partidas
compartilhadas de verdade: lockstep via Tailscale, sem servidor, sem
conta AWS — você só instala o app do Tailscale e aceita um convite)
está prevista para o v17, atrás de dois gatilhos já combinados.

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
and saves frames to `captures/`. This is stage 0 of the co-op plan — real
shared play (lockstep over Tailscale, no server, no AWS account needed on
your side) is slated for v17, behind the two ratified triggers.
