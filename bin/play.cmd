@echo off
cd /d "%~dp0.."
set PATH=C:\Ruby34-x64\bin;%PATH%
rem Optional locale arg (v13 i18n, display-only): play.cmd es | pt-br
rem v17 netplay: everything past the locale forwards to the game --
rem   play.cmd [locale] --host [port] ^| --join ip[:port]
set "FIRST=%~1"
if defined FIRST if not "%FIRST:~0,1%"=="-" (
  set GAME_LOCALE=%FIRST%
  shift
)
rem Rebuild forwarded args (cmd wart: %* ignores shift).
set ARGS=
:build
if "%~1"=="" goto run
set ARGS=%ARGS% %~1
shift
goto build
:run
rem Session-telemetry law: unique log per launch (never a fixed name).
set LOG=%TEMP%\game_two_session_%RANDOM%%RANDOM%.log
ruby -Isrc src\main.rb%ARGS% > "%LOG%" 2>&1
rem Crash visibility (v15 panel fold): a config raise (e.g. a bad
rem bindings.local.json) must not flash-and-close -- show the log and wait.
rem Netplay sessions keep the console up so TELEMETRY + relaunch stay
rem readable (the fun-verify harvest reads these lines).
if errorlevel 1 (
  echo game exited with an error -- log: %LOG%
  type "%LOG%"
  pause
) else (
  findstr /B /C:"TELEMETRY netplay" /C:"desync report:" /C:"relaunch:" "%LOG%"
  if not "%ARGS%"=="" pause
)
