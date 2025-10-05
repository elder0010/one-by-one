@echo off 
SET VASM=.\bin\vbcc\bin\vasmm68k_mot.exe
SET PNGTOPI=.\bin\pngtopi1-1.2.0\pngtopi1.exe

del scroller.tos /f

%PNGTOPI% data\logo_multi.png data\logo_multi.pi1
%PNGTOPI% data\charset_8x8.png data\charset_8x8.pi1

%VASM% onebyone.s -Ftos -tos-flags=3 -o ONEBYONE.PRG
