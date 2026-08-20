# Junior seat — medição do item R-A3 (IA do terceiro corpo): o que deu e o que NÃO deu

**Data:** 2026-08-20 (madrugada, Junior dormindo — mandato executor dele)
**Escopo:** MEDIÇÃO apenas. Zero arquivo de `src/`, `data/`, `harness/`, `tools/` tocado.
**Anexo à oferta:** `drafts/_junior-work-split-offer-20260820.md` §5 item 2.

## O que foi executado

`N=2 TICKS=9000 SEED=20260820 ZONES=district,district_two SEED_SAVE=1 rake soak`
→ run `tmp/soak/20260820-054022`, **SOAK PASS episodes=2**.

| Episódio | Zona | ticks host/joiner | desyncs | reason | wipes | body_deaths | fights |
|---|---|---|---|---|---|---|---|
| EP1 | district | 9120 / 9123 | 0 | quit | 1 | **3** | 1 |
| EP2 | district_two | 9120 / 9124 | 0 | quit | 1 | **1** | 1 |

Cadeia intacta: `586f9e4d`(semeado) → `2c5d361e` → `9ecde198`, sessions 1→2.
Quarentena mecânica passou (save real e logs de `%TEMP%` inalterados).
Ambiente confirmado: o soak roda nesta máquina de ponta a ponta, sem AWS.

## O achado que importa: a telemetria de hoje NÃO responde a pergunta

`a2_fired` emite `body_deaths` **agregado do pack**. Não existe, em nenhuma linha de
telemetria, atribuição por **corpo** nem por **controlador** (humano vs IA). Varredura
nos logs dos dois episódios: nada de `ally`/`ai_`/`controller` por evento; a única
granularidade por kit é `v14 first_special{striker/blocker/lobber}` (frame do primeiro
special), que não fala de morte nem de distância.

Consequência direta: **não é possível quantificar "a IA morre muito" com o que o build
emite hoje.** Os números acima são do pack inteiro e, pior, vêm de assentos pilotados
por BOT — um wipe pode ser incompetência do bot, não da IA. Bot não é evidência de
comportamento humano (lei do projeto), e aqui isso é limitação real, não formalidade.

## Onde eu paro (limite que eu mesmo declarei antes de medir)

A oferta §5 diz, verbatim: *"se a medição da IA exigir uma sonda nova no código, isso
deixa de ser medição e passa a precisar da sua autorização — eu paro e pergunto"*.
É exatamente o caso. **Parei.**

Para medir R-A3 de verdade seria preciso uma sonda nova, e a forma dela é decisão do
dono. Esboço do que ela precisaria emitir (proposta, não implementação):

- morte com atribuição: `kit`, controlador no instante (`human`/`ai`), zona, tick;
- distância ao inimigo mais próximo no instante da morte (o número que testa a
  hipótese de aproximação: o lobber, alcance 6 tiles, morrendo a `dist<=1`);
- histograma de distância enquanto vivo, por kit não-controlado (kite vs colar);
- opcional: quantas vezes `fleeing?` disparou por episódio (hoje invisível).

Custo/risco: telemetria é sink; se gated por env (precedente da lane de lag P0), não
altera a sim nem os digests — mas **é código**, e código novo depende da palavra do
dono e da regra de ciclo ("nada começa antes do brainstorm").

## Resumo em uma linha

O soak funciona aqui e passou; o que falta para atacar R-A3 não é máquina nem tempo —
é **atribuição por controlador na telemetria**, que é código e precisa de autorização.
Fica bancado para a mesa do brainstorm.
