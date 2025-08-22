@echo off 
SET EMU_DIR=..\hatari-2.6.0_windows64\hd
SET PNGTOPI=.\bin\pngtopi1-1.2.0\pngtopi1.exe

del main.tos /f 
del %EMU_DIR%\MAIN.TOS /f

%PNGTOPI% data\logo.png data\logo.pi1
.\bin\vbcc\bin\vasmm68k_mot.exe  main.s -Ftos -o MAIN.TOS
copy .\MAIN.TOS %EMU_DIR%\