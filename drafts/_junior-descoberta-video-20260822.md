# Descoberta do Junior — modelo de geração de mundos da Tencent (2026-08-22)

Tarefa 2 do doc de ratificação (reenquadrada em `7a68788`: nota curta de
descoberta; o WorldSmith é autoria do owner — o objetivo 2D-para-game-two já
está registrado lá). A descoberta é do Junior; a leitura abaixo está nas
palavras exatas dele.

## O vídeo

- Link: https://youtu.be/NC4h5kWH_-A?si=XlAdEWWlmrt75Exp
- Título (conferido por fetch deste assento): "AI News: The AI Agent Race
  Just Exploded" — vídeo de notícias de IA; o trecho da descoberta cobre o
  modelo da Tencent.

## A leitura do Junior (palavras exatas)

> "é um modelo de criação de mundos da tencent, ainda está com acesso fechado
> para o publico, acredito ser um modelo pago. Voce consegue gerar um mundo em
> 3d apenas com um prompt e ele alem de gerar o mundo tambem gera os elementos
> desse mundo e tudo pode ser editavel, tudo são elementos individuais. dentro
> do site já existe um portifolio de mundo criados para serem usados como
> exemplo. a ferramenta funciona atraves de um agente de planejamento de
> terreno que vai na web para obter mais detalhes sobre o terreno especifico,
> tudo é gerado com GPT image 2 e SAM3 da meta. ele consegue converter imagens
> em 2d para 3d.
>
> IMPORTANTE: isso foi o q eu entendi do video traduzido para portugues, pode
> ter erros de conceitos e falta de informaçoes. existe um link e github que
> seria legal de conferir se existe alguma atualização."

## O que serve pro game-two (síntese do assento, fiel à leitura acima)

- Geração de mundo + ELEMENTOS INDIVIDUAIS editáveis por prompt — rima com o
  pipeline LDtk→importer do world-builder (autoria assistida, elementos como
  dados individuais, nunca um blob).
- Agente de planejamento de terreno que busca referência na web — padrão
  interessante para o WorldSmith do owner.
- Conversão 2D→3D é a direção INVERSA da nossa (o aim 2D-for-game-two já
  registrado); o valor está no pipeline de decomposição em elementos, não no
  3D em si.

## Follow-up roteado

- O Junior pede conferência do site/github do modelo por atualizações. Este
  assento tentou extrair os links da descrição do vídeo (fetch bloqueado pelo
  YouTube; WebSearch indisponível neste gateway — 400 confirmado). Fica para a
  spoke de pesquisa do hub, que já cobriu o WorldClaw.
