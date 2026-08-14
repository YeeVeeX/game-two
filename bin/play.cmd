@echo off
cd /d "%~dp0.."
set PATH=C:\Ruby34-x64\bin;%PATH%
rem Optional locale arg (v13 i18n, display-only): play.cmd es | pt-br
if not "%~1"=="" set GAME_LOCALE=%~1
rem Session-telemetry law: unique log per launch (never a fixed name).
set LOG=%TEMP%\game_two_session_%RANDOM%%RANDOM%.log
ruby -Isrc src\main.rb > "%LOG%" 2>&1
rem Crash visibility (v15 panel fold): a config raise (e.g. a bad
rem bindings.local.json) must not flash-and-close — show the log and wait.
if errorlevel 1 (
  echo game exited with an error — log: %LOG%
  type "%LOG%"
  pause
)
