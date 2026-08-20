# S0-J2 EXECUTADO — fatos da máquina do assento Junior (segmento do runsheet de lag)

**Data:** 2026-08-20 (madrugada; Junior dormindo, mandato executor)
**Runsheet:** `drafts/_lag-probe-runsheet-20260820.md` §S0-J2
**O que este assento pode e não pode fazer aqui:** S0-J2 é uma linha de PowerShell —
**executada**. **S0-J (o segmento decisivo) NÃO foi executado**: exige o Junior jogando
4 min e este assento não lança o jogo sem pedido explícito dele. Fica para ele acordar.

## Saída crua

```
Name                        : Intel(R) HD Graphics 3000
CurrentRefreshRate          : 59
CurrentHorizontalResolution : 1366
CurrentVerticalResolution   : 768
DriverVersion               : 9.17.10.4459
Esquema de Energia          : 6873d705-... (ChrisTitus - Ultimate Power Plan)
CPU                         : Intel(R) Core(TM) i3-2310M @ 2.10GHz — 2 cores / 4 threads
RAM                         : 5,9 GB
```

## Leitura do assento (marcada como leitura, não como veredito)

**Isto provavelmente já responde a pergunta central do T2** ("a máquina do Junior roda
~53,5 Hz SOZINHA?") antes mesmo de rodar o S0-J, e a resposta aponta para **hardware,
não configuração**:

1. **O monitor atualiza a 59 Hz, não 60.** Se a janela sincroniza com o vsync (padrão do
   Gosu), o teto físico da máquina já é 59 fps — e 53,5 é ~91% desse teto, o que é
   exatamente a cara de "quase segura o vsync, derruba quadros às vezes".
2. **GPU Intel HD Graphics 3000 (2011) com driver `9.17.10.4459`** — geração Sandy
   Bridge, driver de ~2013. O caminho de desenho (OpenGL via Gosu) é o suspeito
   natural, não a sim: o `rake perf` mede p95 de tick da SIM (budget 16,6 ms) e passa;
   o que o `frame_probe` vai medir é período/update/**draw**, e é no draw que esta GPU
   cobra.
3. **CPU i3-2310M, 2 núcleos / 4 threads a 2,1 GHz** (notebook 2011). Ruby sem YJIT
   (deviação já registrada no AGENTS.md) num dual-core dessa geração deixa pouca folga.
4. **Consequência para o lockstep:** o assento mais lento dita o passo dos dois. Isso
   fecha o círculo com a forense corrigida (`~53,5 Hz` do lado do Junior, host esperando)
   e com a medição de rede desta madrugada, que mostrou a rede dele como o lado BOM
   (NAT fácil, UPnP, IP público, rota direta). **Nem rede nem ajuste de SO derruba um
   teto de 59 Hz num iGPU de 2011.**

## Confundidor que EU criei — declarado antes que alguém tropece nele

Nesta madrugada, a pedido do Junior, este assento **mudou configuração desta máquina**
(`drafts/` não cobre isto porque é fora do repo; scripts em
`C:\Users\jr\Desktop\projeto-game-two\net-tune-*.ps1`):

- porta UDP fixa 41641 no serviço Tailscale + regra de firewall entrante;
- Wi-Fi power-save → desempenho máximo (AC+DC); USB selective suspend → off (AC).

Nada disso muda CPU/GPU/refresh, mas **as sessões do ritual (as que a forense usa como
linha de base) rodaram ANTES dessas mudanças**. Qualquer S0-J/S1 medido de agora em
diante é numa máquina levemente diferente. Reversível por
`net-tune-revert.ps1` se a lane quiser reproduzir as condições exatas do ritual.

## O que falta e de quem é

- **S0-J** (Junior solo, `GAME_FRAME_PROBE=1`, ~4 min, colar `frame_probe` + `AUDIO
  drift`): dele, quando acordar.
- **S1/S2/S3** (coop): dos dois, com o Gabriel hospedando.
- Este assento pode rodar os samplers (`tailscale status` a cada 10 s, `netstat -s`
  antes/depois) durante os segmentos coop — se autorizado, é só medição.
