# Recibo — respostas do dono EXECUTADAS no assento Junior (Recorte A + LDtk)

**Data:** 2026-08-20 (madrugada; Junior dormindo, mandato executor dele)
**Ratificação lida:** `df38cb7` — Recorte A **SÍ** · R-A3 **CONGELADA** · toques em
`world.rb` por **DIFF** · LDtk **SÍ** · samplers coop **autorizados**.

## 1. LDtk 1.5.3 — INSTALADO E VERIFICADO ✅

| Passo | Resultado |
|---|---|
| Origem | release oficial `deepnight/ldtk` **v1.5.3** (API do GitHub, tag consultada) |
| Arquivo | `LDtk-1.5.3-installer.exe` |
| Integridade | **167.303.856 bytes** — idêntico ao tamanho publicado no release |
| sha256 do instalador | `61db0588c5d6a3f4de4c0e4ae0414f011b07f387dd019af4fa96f5fa7eb94822` |
| Assinatura Authenticode | **Valid** — `CN=Deepnight Games, O=Deepnight Games, C=FR` |
| Instalação | silenciosa (`/S`), exit **0** |
| Binário | `C:\Users\jr\AppData\Local\Programs\LDtk\LDtk.exe` |
| Versão do produto | **1.5.3.0** — bate com `PINNED_JSON_VERSION = "1.5.3"` (`tools/import_ldtk.rb:37`) |
| Instalador guardado | `C:\Users\jr\Downloads\ldtk\` (fora do repo) |

**Limite respeitado:** ferramenta ≠ lane. **Nada de T3/T4 começou**; nenhum `.ldtk`
foi criado, editado ou importado. A máquina só passou a ser capaz de autorar quando
os donos disserem.

## 2. Recorte A — ASSUMIDO, fronteira declarada

Escopo deste assento, por escrito: escreve **apenas** em `tmp/**` (artefatos) e
`drafts/_junior-*.md` (números). **Zero** toque em `src/**`, `harness/**`, `tools/**`,
`Rakefile`, `data/**`. Se alguma medição exigir código, para e pede (precedente já
exercido: `_junior-ai-measurement-20260820.md`).

### Já entregue dentro do Recorte A

- **S0-J2** — fatos da máquina bancados (`_junior-lag-s0j2-machine-facts-20260820.md`);
  o hub marcou o segmento como EXECUTED/do-not-re-run em `638fa68` e transformou a
  leitura em **predição falsificável**: período p50 ≈ 16,9 ms com picos ~33,9 ms.
- **Soak PASS 2/2** (`_junior-ai-measurement-20260820.md`), com o GAP de atribuição
  nomeado.
- **Confundidor declarado** (ajustes de rede/energia posteriores ao ritual;
  `net-tune-revert.ps1` disponível).

### Pronto e esperando humano (não executável por este assento)

- **S0-J** — o segmento decisivo: `GAME_FRAME_PROBE=1 bin/play pt-br`, ~4 min, colar
  `TELEMETRY frame_probe` + as últimas `AUDIO drift`. **Exige o Junior jogando**; este
  assento não lança o jogo. Comando único, já conferido contra o runsheet.
- **S1/S2/S3** — coop, exigem os dois humanos + o host.
- **Samplers** (autorizados): `tailscale status` a cada 10 s + `netstat -s`
  antes/depois por segmento — este assento roda no instante em que um segmento coop
  começar.

## 3. R-A3 — CONGELADA, e é o certo

Nada será tocado. O diagnóstico (a–i, com arquivo:linha) e o GAP de atribuição ficam
bancados esperando o brainstorm do v19; se um dia for designado, os toques em
`world.rb` saem como **diff em `drafts/`** para o hub aplicar (dono único do arquivo
que carrega digest). Concordo com o motivo: `world.rb` no digest com dois donos é
convite a re-pin cego.

## 4. Estado da máquina após esta noite (para o hub saber com o que conta)

Roda hoje, sem instalar mais nada: suíte completa (919 runs / 17687 asserts verdes no
último pull com código), `soak`, `capture`, `canary`, `manifest`, `map`, `perf`,
`pilot`, importer LDtk, **LDtk GUI 1.5.3**, clipes ffmpeg, Python 3.14.
Segue **bloqueado**: metade vision-critic do gate (credenciais AWS mortas —
`InvalidClientTokenId` nos 4 perfis) e `self_eval.py`/`video_analyst.py` (perfil
`voice-dev` hardcoded, sem override por env). Nenhum dos dois é resolvível daqui.
