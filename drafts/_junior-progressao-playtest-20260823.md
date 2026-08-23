# Playtest de progressão do assento Junior — T2+T3 ao vivo (2026-08-22/23)

Assento: Junior (pt-br). Primeiras sessões HUMANAS com a progressão ligada —
sim core (T2) e depois HUD/beat (T3). Recorte A: zero código; este rascunho
banca telemetria, depoimento e a assinatura de perf observada.

## Linhagem dos saves (importante para o Gate 0 do hub)

- **Save vivo** (`saves/world.json`): recebeu DUAS sessões humanas curtas —
  upgrade v1→v2 limpo (backup `world.json.bak-schema1-20260822233305` criado ao
  lado) e os primeiros 60 XP humanos da história. Estado final do vivo: digest
  `494be8aa8f36ae5018c3689cda0153a2 sessions=6` — intocado desde então.
- **Cópia paralela** (`tmp/inicio_com_moedas/world.json`, criada do vivo em
  2026-08-22): sandbox pessoal do Junior com home ajustada para camp (edição só
  na CÓPIA — o vivo nunca foi editado à mão). Todo o grind abaixo aconteceu lá
  e NÃO pertence ao mundo compartilhado.

## Linhas verbatim (progressão, por sessão)

    live    TELEMETRY progression level=1 xp=60 kills_xp=60      (60 XP: primeiro XP humano)
    cópia   TELEMETRY progression level=3 xp=45 kills_xp=225     (primeiros level-ups: 1→3)
    cópia   TELEMETRY progression level=7 xp=1730 kills_xp=4725  (grind: 3→7, 19 fights, 2 wipes recuperados, banked 117→500)
    cópia   TELEMETRY progression level=8 xp=495 kills_xp=525    (7→8, 3 fights, zero wipes)

Observação de leitura (não é lei): `kills_xp` aparenta ser o ganho DA SESSÃO e
`xp` o progresso dentro do nível corrente — os valores acima são consistentes
com isso.

## Depoimento do Junior (palavras exatas)

Sobre o T3 (beat do level-up + faixa de nível/XP no HUD), após jogar 1→8:

> "tudo muito legal"

Sobre performance na sessão LONGA (~10 min, a do grind 3→7):

> "senti algumas travadas nos ultimos momentos, creio que seja gargalo do
> meu pc"

## Assinatura de perf observada (bancada, sem reabrir nada)

O drift de áudio CRESCE com a duração da sessão neste assento:

- Sessões curtas (~90 s–2 min): ~+1% a ~+2,5%
- Sessão longa (~10 min, tick 36000): **+6,3%** — e é "nos últimos momentos"
  que o humano sentiu as travadas

O ticket da cauda de frames fechou em `c8f37e7` (classe 1, números deste
assento) e este relato NÃO o reabre por si — o dono sentiu leve e atribui ao
hardware. Fica bancada a assinatura "liso no começo, pesa com o tempo" para o
hub classificar se merece linha própria (candidato: acumulação em sessão longa;
os beats/HUD do T3 estreavam na sessão em questão).

## Evidência (logs nesta máquina; md5 bancados)

- Live (60 XP): `game_two_session_1951260.log` — `651b3cef227ee13a9d0f435d411017ac`
- Cópia 1→3: `game_two_session_1954099.log`* — `9e76b7e7f19d1442bfe1530a86729a1f`
  (*sessão TOWN-spawn curta; o grind 1→3 está no log seguinte da série)
- Cópia 3→7 (longa): `game_two_session_1957395.log` — `004e757e5e087f031a80aa7e61ac2f39`
- Cópia 7→8: `game_two_session_1962751.log` — `ab75e4763baffdc5d1acb4564bf0e1b7`

Todas as saídas limpas (Esc); upgrade v1→v2 exercitado em vivo E cópia.

## Rotas

- Feel do T3: veredito humano positivo bancado ("tudo muito legal") — insumo
  para o fun-verify do v19 (sem contaminar perguntas virgens do ritual: isto é
  exposição normal, não ritual).
- Assinatura de drift em sessão longa → hub classificar (dado, não defeito).
- Save vivo segue em `494be8aa… sessions=6`, pronto para coop S1.
