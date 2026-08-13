@echo off
cd /d "%~dp0.."
set PATH=C:\Ruby34-x64\bin;%PATH%
rem Session-telemetry law: unique log per launch (never a fixed name).
ruby -Isrc src\main.rb > "%TEMP%\game_two_session_%RANDOM%%RANDOM%.log" 2>&1
