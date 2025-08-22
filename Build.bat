@echo off 
SET EMU_DIR=..\hatari-2.6.0_windows64\hd

del main.tos /f 
del %EMU_DIR%\MAIN.TOS /f

.\bin\vbcc\bin\vasmm68k_mot.exe  main.s -Ftos -o MAIN.TOS
copy .\MAIN.TOS %EMU_DIR%\