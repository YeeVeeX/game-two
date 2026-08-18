# Soak em dupla — roteiro do assento do Junior (2026-08-18)

**Para: o agente/assento do Junior.** Idioma de trabalho desta folha:
pt-br. Isto NÃO é uma partida de verdade — é o robô de teste jogando
sozinho para endurecer o netplay antes de vocês dois gastarem uma noite
real. **Nada daqui vale como evidência do ritual** (as duas sessões
humanas em dias diferentes continuam sendo as únicas que contam).

## O que é

Cada lado roda UM comando; o jogo abre sozinho, um robô com semente
fixa joga (anda, luta, aperta Esc no tick alvo) e os logs ficam em
`tmp/soak/<carimbo>/`. O robô NUNCA toca o save de verdade: no lado
host ele exige `--save` para um arquivo de rascunho, e o script
confere o md5 do `saves/world.json` antes e depois — se mexer, o run
FALHA sozinho.

## Passo a passo (lado Junior = joiner)

1. `git pull` primeiro, SEMPRE (mesma regra das partidas: commit
   diferente = recusa com dica).
2. Git Bash, na pasta do repo:

```
export PATH="/c/Ruby34-x64/bin:$PATH"
JOIN_ONLY=1 HOST_ADDR=100.127.52.49 N=1 TICKS=36000 bash soak/run_soak.sh
```

3. **Combine o momento com o Gabriel** (chat): o lado dele (host) roda
   primeiro e avisa "listo"; aí você dispara o comando. O seu lado
   espera 10 s antes de entrar (dá tempo do host abrir a porta).
4. Uma janela do jogo vai abrir e se mexer sozinha uns ~10 minutos —
   não toque no teclado dela; pode minimizar. Ao final ela fecha
   sozinha.
5. O resultado sai no console (`SOAK PASS` / `SOAK FAIL`) e fica em
   `tmp/soak/<carimbo>/report.txt`.

## O que mandar de volta

- O `report.txt` inteiro e o `ep1/joiner.log` (as linhas `AUTOPILOT` e
  `TELEMETRY` são a prova) — cole no chat ou salve como
  `drafts/_junior-soak-<data>.md` e faça push.
- Se deu `exit 2` (queda de conexão): isso NÃO é fracasso do teste —
  é exatamente o que queremos observar pela internet. Manda o log do
  mesmo jeito.

## Se algo travar

- Janela parada e console sem linhas novas por >2 min: deixa o fusível
  do script matar (ele mata sozinho e marca `timeout=1`) e manda os
  logs do jeito que ficaram.
- `could not connect`: o host ainda não estava de pé — espera o
  "listo" e roda de novo.

---
Comando do lado Gabriel (host, para referência):
`HOST_ONLY=1 N=1 TICKS=36000 TIMEOUT_S=900 bash soak/run_soak.sh`
