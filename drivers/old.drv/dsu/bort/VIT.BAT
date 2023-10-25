@echo off

check

if errorlevel 1 goto StartClans
goto StartIni

:StartClans
clans

:StartIni
bortini.exe

if errorlevel 1 goto mEnd
bort
:mEnd