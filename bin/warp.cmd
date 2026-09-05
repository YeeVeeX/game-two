@echo off
rem DEV WARP (owner order 2026-09-05): start in ANY zone at the level cap on
rem a SCRATCH save (tmp\dev\world.json, regenerated per launch). The live
rem save is never touched. Mirrors bin/warp for double-click / cmd:
rem   warp.cmd <zone> [locale] [level]     e.g.  warp.cmd dungeon_4 es
rem   warp.cmd                              lists the zones
cd /d "%~dp0.."
set PATH=C:\Ruby34-x64\bin;%PATH%
if "%~1"=="" (
  echo usage: warp.cmd ^<zone^> [locale] [level]
  echo zones:
  for %%f in (data\zones\*.json) do echo   %%~nf
  pause
  exit /b 2
)
if not exist "data\zones\%~1.json" (
  echo unknown zone: %~1
  pause
  exit /b 2
)
if not "%~2"=="" set GAME_LOCALE=%~2
set SAVE=tmp\dev\world.json
if "%~3"=="" (
  ruby -Isrc tools\dev_save.rb %SAVE%
) else (
  ruby -Isrc tools\dev_save.rb %SAVE% %~3
)
if errorlevel 1 ( pause & exit /b 1 )
rem Not game_two_session_* on purpose: warps are dev inspection, never fun evidence.
set LOG=%TEMP%\game_two_warp_%RANDOM%%RANDOM%.log
echo warp -^> %~1 (log: %LOG%)
ruby -Isrc src\main.rb --save %SAVE% --start-zone %~1 > "%LOG%" 2>&1
set GAME_RC=%errorlevel%
if not "%GAME_RC%"=="0" (
  echo game exited with code %GAME_RC% -- log: %LOG%
  type "%LOG%"
  pause
)
exit /b %GAME_RC%
