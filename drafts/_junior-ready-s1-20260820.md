# Junior está PRONTO e esperando o convite — segmento S1 (coop)

**Recado do Junior, verbatim:**
> estou pronto e esperando o convite dele

**Data:** 2026-08-20 · **Assento:** Junior · **Alvo:** o item "Coop with Junior = lag
segment S1" do spark da sessão 25 (`746ee8b`). Nada foi lançado; este arquivo é só o
aviso de prontidão — quem convida é o Gabriel, no ritmo dele.

## Pré-voo já cumprido deste lado (verificado agora, não presumido)

| Requisito do spark | Estado nesta máquina |
|---|---|
| Pull ≥ `f5b4356` (protocolo v3) | ✅ `HEAD = 746ee8b`; `f5b4356` é ancestral de HEAD (verificado com `merge-base --is-ancestor`) |
| Em sincronia com o remoto | ✅ `## main...origin/main`, sem divergência |
| Suíte verde no build atual | ✅ 936 runs / 17735 asserts / 0 falhas (rodada aqui após o último pull com código) |
| Instância única (nenhum jogo aberto) | ✅ nenhum `ruby.exe` em execução |
| Áudio | ✅ `AUDIO on device=1 sha=15f03e0219d6` nas últimas sessões |
| `GAME_FRAME_PROBE=1` | ✅ já exercido no S0-J desta máquina (127.506 quadros bancados) |
| Rede | ✅ NAT fácil, UPnP, IP público, porta UDP 41641 fixa + regra de firewall (ajustes desta madrugada, `net-tune-revert.ps1` disponível) |
| Ctrl+direção (aim v3) | ✅ presente no build (`data/bindings.json`: `aim: [LCtrl, RCtrl]`) — estreia em coop nesta sessão |

**Tailnet neste instante:** `gabo-desktop` (100.127.52.49) listado, **sem sessão ativa**
— ou seja, o host ainda não está no ar. Este assento não insiste e não sonda a porta do
jogo (lei do runsheet: sondar a porta come o accept do host).

## O que este assento fará quando o convite vier

1. Guarda de instância única em chamada separada, julgada pela saída impressa.
2. `git pull --ff-only` (o launcher também faz) e conferência de que os dois estão no
   mesmo commit — se o protocolo recusar, a recusa é o comportamento projetado e vai
   bancada com o campo nomeado.
3. Lança com `GAME_FRAME_PROBE=1` (segmento S1), sem `--fresh`.
4. **Samplers autorizados sob o Recorte A** rodando durante o segmento: `tailscale
   status` a cada ~10 s e `netstat -s` antes/depois.
5. Ao fechar com Esc: colhe `NETPLAY handshake`, `TELEMETRY netplay`,
   `TELEMETRY frame_probe` e as linhas `AUDIO` do log, banca conforme o checklist
   (`drafts/_lag-t2-evidence/README.md`) e dá push.

## Fora de escopo, dito para não haver dúvida

Este assento **não** lança o jogo sem o pedido do Junior, **não** toca `src/**`,
`data/**`, `harness/**` nem `tools/**` (fronteira do Recorte A), e a proposta do
debug-menu (`63d7b9d`) segue esperando a validação do Gabriel — sem cobrança.
