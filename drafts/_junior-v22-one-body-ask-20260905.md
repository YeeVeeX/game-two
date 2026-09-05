# Para o Junior — v22 ONE BODY: pedido de ratificação (2026-09-05, s131, seat do Gabriel)

**Resumo em uma linha:** o Gabriel aprovou hoje mudar o modelo de controle do
jogo — de "pack de três corpos com Tab" para **UM corpo por jogador** (o resto
descansa no vat), morte com preço (perde XP, seguro comprado no banco, cartão
mostrando a conta), formas trocáveis no meio da luta (o Tab vira troca de
forma, estilo troca de arma do New World), e daqui pra frente PvP e rivais.
Nada foi decidido CONTRA ti na tua ausência: o pivot está ratificado pelo
Gabriel (RATIFIED-G) e espera a TUA palavra (RATIFIED-J) — simetria total.
Fundação completa (inglês): `drafts/_v22-foundation-20260905.md`.

## Por que (evidência, não gosto)

- Verdict do DÉCIMO NONO (§h): o terceiro corpo "igual, não senti diferença"
  (tu, pela terceira vez); "el striker no hace mucha diferencia" (Gabriel);
  subir de nível não se sente 10→13 nos dois seats; "repetitivo y vacío".
- Todo jogo do corpus (Tibia, UO, OSRS, New World) = UM avatar; o grupo são
  outros jogadores. O pack era a exceção e cobrava caro em legibilidade (3
  barras, halo, chevron) e em profundidade de combate (um special por corpo).
- Com um corpo só, o preço da morte do Tibia cai 1:1 sem perguntas.

## O que fica do teu trabalho (PREMIUM v22) — quase tudo

- Personagens desenhados 32x48, tiles dual-grid, gemas: **ficam**.
- Halo dourado + chevron: **ficam, reenquadrados** — dourado = TEU corpo,
  ciano = o parceiro (já é assim no coop).
- Painel do HUD: vira **a tua linha + linhas do grupo** (mesma gramática).
- Torre da Medusa e BRASA: ficam; a dificuldade vai ser re-afinada pra um
  corpo (companheiros contratados no vat cobrem o buraco enquanto isso).
- **O teu `595b3ab` (cérebro dos aliados: foco de fogo, poção, esquiva,
  papel por arco) vira exatamente o CÉREBRO DOS COMPANHEIROS (L7 da
  fundação) — nada se perde, muda só quem manda nele (contratado no vat,
  só PvE). Segue OFF até a ratificação, como tu mesmo escreveste.**
- Teu plano MUNDO VIVO: D1 2× + D8 offset (0,0) adotados pra cidade; **D6 o
  pátio de treino vira a ARENA DE DUELO** (região `intent: "arena"`, hub
  continua safe fora dela) — primeira superfície de PvP, na tua cidade; D2
  colmeia a partir da ZONE 8 fica pra v23; D3 guardião+final mantido; D5
  fechado pela execução (MUSGO A); D7 o gate decide; D9 igual (sem lore).
  As 3 decisões do swap: ratificadas.

## O que precisamos da tua palavra (uma linha cada, no chat do hub ou em RECEIPT aqui)

1. **O pivot ONE BODY** em si (A: corpo escolhido no vat, companheiros
   opcionais e pagos, só PvE · B: cada um morre sozinho, volta pra casa,
   o parceiro continua · C: multa de XP + dívida de XP em vez de perder
   nível + seguro no banco + cartão da morte · D: troca de forma + curva de
   poder mais forte). Sim / não / "sim, mas..."?
2. **Tiles: opção 1 ou 2?** Opção 2 = o teu `gen_tileset.py` (dual-grid no
   engine, o que está no main). Opção 1 = tileset + regras no LDtk (o editor
   pinta, o jogo só desenha; brief do gamesmith §3.7 tem a tabela). Tu
   construíste a 2 — a tua palavra pesa mais aqui. Pode ser "2 agora, 1 pra
   bordas/props depois".
3. **Andares dos teus mapas (L11):** se o banner mostrar o andar ("ZONE 5 ·
   -3"), 8 linhas LEGACY do `authoring/world_graph_allowlist.json` viram
   mentira visível. Proposta: nest → -1, slow_door → -2 ou -3 (tu escolhes),
   porta leste do camp retipada/removida.
4. **A arena na tua cidade** (D6 → arena): ok?
5. **Pré-voo do AfterSave** na tua máquina: `where python` e `where ruby` no
   cmd — se `python` não resolver, me diz e eu troco a linha do comando.
6. **Aviso:** `735a37c` destrackeou 4 `.pyc` do `03259d0` (cache do Python,
   gerado por máquina) — `git pull` normal, nada a fazer.

Formato: `RECEIPT: J-v22 <n> <sim|não|texto>` (uma linha por item) neste
arquivo ou no chat. Sem pressa e sem gate: o trabalho segue nos dois seats
(ordem do Gabriel 2026-08-22); o que tu disseres entra como lei na fundação.

---

## For Junior — v22 ONE BODY ratification ask (English mirror, same content)

Gabriel approved (s131) migrating from the three-body pack to ONE BODY per
player (others rest at the vat), a priced death (XP fine + XP debt instead
of de-leveling, insurance at the bank, a death ledger card), form swap
(Tab → New World-style weapon swap on cooldown, third form earned), and a
sequenced program (v23 REWARD, v24 RIVALS/PvP). Your PREMIUM v22 work
stays (characters, tiles, gems; halo reframed as you/partner; HUD as your
row + party rows). Your MUNDO VIVO decisions are merged (D1/D8 city numbers,
D6 training yard → duel arena, D2 hive → v23, D3 kept, D5 settled, D7 gate,
D9 unchanged; swap-spec ratified). We need your line on: the pivot, the tile
fork (Option 1 vs 2), your floors (L11), the arena, AfterSave pre-flight,
and the .pyc notice. `RECEIPT: J-v22 <n> <answer>` per item.

---

## RECEIPTS — Junior (2026-09-05 15:50; escritos pelo dev seat por ordem dele: "aceito as recomendações")

RECEIPT: J-v22 1 sim. As 3 FORMAS = os 3 kits atuais (Fio/Aro/Pomo): zero arte perdida, os 3 especiais ficam, a terceira forma se ganha (D). Torre e BRASA re-afinam pra um corpo; companheiros cobrem o buraco enquanto isso, como previsto.
RECEIPT: J-v22 2 opção 2 agora (dual-grid no engine, gen_tileset.py), opção 1 pra bordas/props depois.
RECEIPT: J-v22 3 nest -1 · slow_door -2 (antessala da descida; o -3 é o musgo) · porta leste do camp: remover.
RECEIPT: J-v22 4 sim — o pátio de treino (D6) vira a ARENA DE DUELO; o hub segue safe fora dela.
RECEIPT: J-v22 5 ok — pré-voo rodado 2026-09-05 15:47 no cmd: `where python` → C:\Users\q\AppData\Local\Programs\Python\Python314\python.exe (Python 3.14.7); `where ruby` → C:\Ruby34-x64\bin\ruby.exe. A linha do comando resolve como está.
RECEIPT: J-v22 6 ciente.
RECEIPT: J-v22 L15 S1–S3 (catálogo+ícones · bolsa+drops de item · consumíveis+status) na segunda metade do v22: SIM — a metade do Junior da linha dos dois; S4–S7 no v23. Aguarda a linha do Gabriel; nada de S1 antes dela.

Evidência do dia (Junior seat): PREMIUM v22 passes 1–5b no main 03259d0→0af8c67 (personagens · tiles dual-grid · halo · HUD-painel · gemas · FX · luz · esquiva-rolagem · idle secundário + especiais), cada peça gated (visão + duplo replay byte-idêntico), suite 1463/0; parede completa (42 scripts) rodando em worktree no 064bd80.

English mirror: 1 yes (the 3 forms = the 3 current kits) · 2 option 2 now, option 1 for borders/props later · 3 nest -1, slow_door -2, camp east door removed · 4 yes (arena) · 5 ok (pre-flight run, paths above) · 6 noted · L15 S1–S3 in v22's back half: YES (Junior's half of the both-seats line; S1 waits for Gabriel's).
