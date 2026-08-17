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

echo Abriendo el juego como HOST... salir siempre con Esc
rem Rehost SOLO en corte de link (status 2): Esc limpio (0) termina de
rem verdad; un error (1) muestra el log y para. GAME_NO_PAUSE: el loop
rem fluye sin "presiona una tecla".
rem PARSER LAW (bug cazado en vivo 2026-08-17): cmd corta un bloque "( )"
rem en el primer ")" dentro de un echo -- el rehost quedaba INCONDICIONAL
rem y Esc nunca podia cerrar el juego. Por eso: cero bloques multilinea,
rem solo if+goto de una linea, y timeout con ruta completa (un PATH con
rem Git Bash mete el timeout de GNU, que no entiende /t).
set GAME_NO_PAUSE=1
:host
call bin\play.cmd es --host
if "%errorlevel%"=="2" goto rehost
if "%errorlevel%"=="1" goto broke
echo Sesion cerrada limpia con Esc. Listo.
exit /b 0

:rehost
echo Link caido -- rehosteando en 5s... Ctrl+C corta el loop.
"%SystemRoot%\System32\timeout.exe" /t 5 /nobreak >nul
goto host

:broke
echo El juego termino con error -- revisa el log de arriba.
pause
exit /b 1
