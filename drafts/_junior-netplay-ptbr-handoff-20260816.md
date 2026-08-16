# Junior-seat handoff — increment-8 raw material: JUNIOR.md netplay section (PT-BR first) + functional labels (2026-08-16)

Coordination-law handoff (drafts channel — NOT a race): increments 7-8
stay owner-seat work. This banks the two parts that are natively this
seat's: the PT-BR (the reader lives on this seat) and the second
machine's install truth (performed live TODAY, not imagined). Fold,
edit, or ignore at will.

## Machine truth the docs can lean on (verified live, Junior's machine)

- Tailscale **1.102.2 installed 2026-08-16**: winget is ABSENT on this
  Windows (10 Enterprise LTSC 2021) — the working path is the direct
  download `https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe`
  (1.3 MB bootstrapper, MZ-verified), run + UAC accept, ~2 min total.
- Post-install state: `Logged out` — DELIBERATE. Login waits for the
  tailnet invite link (avoids an orphan tailnet on Junior's account).
- `tailscale.exe` is NOT on PATH here; tray app or absolute path
  (`C:\Program Files\Tailscale\tailscale.exe`).

## Part A — proposed JUNIOR.md section (drop-in PT-BR; EN mirror below)

Register matches the existing doc (bold numbered steps, both shells,
why-with-every-step, failure modes explicit). On-screen strings quoted
in PT-BR assume Part B ships; if increment 7 lands EN-only, swap the
quoted labels for the EN ones.

```markdown
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
- `CONEXÃO PERDIDA — SESSÃO ENCERRADA`: a conexão caiu por mais de 10
  segundos.
- Depois de qualquer fim, o console imprime o comando exato para
  relançar dos dois lados.

**Depois da primeira partida:** cole a sua linha `TELEMETRY netplay ...`
do console (em drafts/ ou mensagem) e responda as 4 perguntas
pré-registradas — é o 16º veredito.
```

EN mirror (condensed, doc convention): Co-op is one pack, two pilots
over Tailscale (install once from the URL above — no winget on LTSC;
stay logged out until the invite; accept the invite, note the host's
`100.x` IP). Every session: `git pull` FIRST (stale build = fingerprint
refusal with the exact diff printed — protection, not a bug), then
`bin/play pt-br --join <ip[:port]>` (default 43117). In play: partner =
distinct ring; stall overlay waits instead of desyncing; LINK SLOW =
playable but laggier; zone gates need every living controlled body
co-located; bodyless seat spectates until auto-repossession. Ends: Esc
always (both seats record + flush telemetry); DESYNC freezes honestly
and points at the `tmp/netplay/` artifact — share it; after any end the
console prints the exact relaunch command. After the first session:
paste your `TELEMETRY netplay` line, answer the four pre-registered
questions (the SIXTEENTH).

## Part B — PT-BR functional labels for the increment-7 strings

Proposed by this seat (functional lane, standing order compliant:
placeholders/verbs only, PARTNER wording law kept — never "JOGADOR 2").
Key names are increment 7's call; EN strings verbatim from the spec
§Presentation. **Ratification: pending Junior's read (in-session).**

| EN (spec) | PT-BR (proposal) |
|---|---|
| `CONNECTING…` | `CONECTANDO…` |
| `HOSTING — WAITING FOR PARTNER` | `HOSPEDANDO — AGUARDANDO PARCEIRO` |
| `WAITING FOR PARTNER` (stall overlay) | `AGUARDANDO PARCEIRO` |
| `LINK SLOW` | `CONEXÃO LENTA` |
| `DESYNC AT TICK <N> — SESSION ENDED` | `DESSINCRONIA NO TICK <N> — SESSÃO ENCERRADA` |
| `CONNECTION LOST — SESSION ENDED` | `CONEXÃO PERDIDA — SESSÃO ENCERRADA` |
| `NO BODY — WAITING` | `SEM CORPO — AGUARDANDO` |
| `WAITING AT GATE` | `AGUARDANDO NO PORTÃO` |

Register note: `DESSINCRONIA` is the one technical word — alternative
if it fails the "words the reader owns" test: `AS PARTIDAS DIVERGIRAM
NO TICK <N> — SESSÃO ENCERRADA`. Junior adjudicates (his language).

## What this is NOT

- Not a JUNIOR.md edit — increment 8 lands the section, owner's wording
  call. The old co-op teaser at JUNIOR.md:86-90/124-128 gets replaced by
  it (it still says "aceita um convite" — consistent with this draft).
- Not shipped strings — Part B enters `data/strings/pt-br.json` only
  when increment 7 creates the keys and the owner folds them.
