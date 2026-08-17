@echo off
rem Junior one-click co-op JOIN launcher (v17 SIXTEENTH support) - mirror of
rem host-coop.cmd, second-seat side. Usage: join-coop.cmd [ip] [check]
rem   no args -> resolve the host on the tailnet live and join
rem   "check" -> preflight only (pull + resolve + tunnel ping), no game.
rem PT-BR strings are ASCII-safe on purpose (cmd codepages mangle accents;
rem same precedent as host-coop.cmd's Spanish).
cd /d "%~dp0.."
set PATH=C:\Ruby34-x64\bin;%PATH%
echo === game-two co-op (entrar) ===

rem 1) Same line as the host (fingerprint law): fast-forward pull only.
git pull --ff-only
if errorlevel 1 (
  echo AVISO: git pull falhou - o jogo roda com a linha local.
)

rem 2) Resolve the host on the tailnet LIVE (no hardcoded IP). First arg
rem    wins; otherwise the peer named gabo-desktop in `tailscale status`.
set HOSTIP=
set MODE=
if /i "%~1"=="check" (set MODE=check) else (set HOSTIP=%~1)
if /i "%~2"=="check" set MODE=check
if not defined HOSTIP (
  for /f "tokens=1,2" %%a in ('"C:\Program Files\Tailscale\tailscale.exe" status 2^>nul') do (
    if /i "%%b"=="gabo-desktop" if not defined HOSTIP set HOSTIP=%%a
  )
)
if not defined HOSTIP (
  echo ERRO: host gabo-desktop fora do tailnet - abra o Tailscale da bandeja e tente de novo.
  pause
  exit /b 1
)

echo(
echo Host no tailnet: %HOSTIP%   (porta 43117)
echo Comando completo:   bin\play.cmd pt-br --join %HOSTIP%
echo(

rem 3) Preflight: the TUNNEL must answer before joining. Probing the game
rem    port is FORBIDDEN (a TCP probe eats the host's single accept and
rem    aborts the session - live lesson, 2026-08-17).
"C:\Program Files\Tailscale\tailscale.exe" ping -c 1 --timeout 5s %HOSTIP% >nul 2>&1
if errorlevel 1 (
  echo AVISO: sem resposta do host no Tailscale agora - o join pode falhar; espere e rode de novo.
) else (
  echo Link Tailscale OK.
)

if /i "%MODE%"=="check" (
  echo [check] preflight OK - sem abrir o jogo neste modo.
  exit /b 0
)

echo Abrindo o jogo para ENTRAR na partida... saia sempre com Esc
rem Rejoin loop (SIXTEENTH support): corte de link (status 2) = re-entra
rem sozinho; host fora do ar (status 1 sem "refused") = tenta de novo ate
rem 20x (o host relanca sozinho em ~5s); recusa de fingerprint = para na
rem hora (precisa de git pull). Esc limpo (0) termina de verdade.
set GAME_NO_PAUSE=1
set TRIES=0
:join
call bin\play.cmd pt-br --join %HOSTIP%
set RC=%errorlevel%
if "%RC%"=="0" (
  echo Sessao fechada limpa (Esc). Pronto.
  exit /b 0
)
if "%RC%"=="2" (
  echo(
  echo Link caiu -- re-entrando em 8s... (Ctrl+C para parar)
  timeout /t 8 /nobreak >nul
  set TRIES=0
  goto join
)
rem RC 1: recusa (para) ou host fora do ar (re-tenta). O log da tentativa
rem fica em %LOG% (play.cmd nao usa setlocal -- a variavel chega aqui).
findstr /I /C:"refus" "%LOG%" >nul 2>&1
if not errorlevel 1 (
  echo Entrada RECUSADA pelo host -- rode git pull e tente de novo.
  pause
  exit /b 1
)
set /a TRIES+=1
if %TRIES% GEQ 20 (
  echo Host nao respondeu em %TRIES% tentativas -- avise o outro lado.
  pause
  exit /b 1
)
echo Host fora do ar (tentativa %TRIES%/20) -- tentando de novo em 10s...
timeout /t 10 /nobreak >nul
goto join
