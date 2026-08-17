@echo off
rem Owner one-click co-op host launcher (v17 SIXTEENTH support).
rem Usage: host-coop.cmd [check]  -- "check" = preflight only, no game.
cd /d "%~dp0.."
set PATH=C:\Ruby34-x64\bin;%PATH%
echo === game-two co-op (host) ===

rem 1) Same line as Junior (fingerprint law): fast-forward pull only.
git pull --ff-only
if errorlevel 1 (
  echo AVISO: git pull fallo o no era fast-forward — se juega con la version local.
)

rem 2) Tailnet IP (live, not hardcoded).
set TSIP=
for /f %%i in ('"C:\Program Files\Tailscale\tailscale.exe" ip -4 2^>nul') do if not defined TSIP set TSIP=%%i
if not defined TSIP (
  echo ERROR: Tailscale no responde — abri la app de la bandeja y proba de nuevo.
  pause
  exit /b 1
)

echo(
echo Tu IP tailnet: %TSIP%   (puerto 43117)
echo Comando para Junior:   bin\play.cmd pt-br --join %TSIP%
echo(%TSIP%|clip
echo (la IP ya quedo copiada al portapapeles)
echo(

if /i "%~1"=="check" (
  echo [check] preflight OK — no se lanza el juego.
  exit /b 0
)

echo Abriendo el juego como HOST... (sali siempre con Esc)
call bin\play.cmd es --host
