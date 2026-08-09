@echo off
cd /d "%~dp0.."
set PATH=C:\Ruby34-x64\bin;%PATH%
ruby -Isrc src\main.rb
