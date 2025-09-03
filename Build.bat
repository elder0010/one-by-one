@echo off 
SET VASM=.\bin\vbcc\bin\vasmm68k_mot.exe
SET EMU_DIR=..\hatari-2.6.0_windows64\hd
SET PNGTOPI=.\bin\pngtopi1-1.2.0\pngtopi1.exe

del main.tos /f 
del scroller.tos /f
del %EMU_DIR%\MAIN.TOS /f

%PNGTOPI% data\logo2.png data\logo2.pi1
%PNGTOPI% data\charset.png data\charset.pi1

@echo %VASM% main.s -Ftos -o MAIN.TOS
@echo %VASM% pixel.s -Ftos -o PIXEL.TOS
%VASM% scroller.s -Ftos -o SCROLLER.TOS

copy .\MAIN.TOS %EMU_DIR%\
copy .\PIXEL.TOS %EMU_DIR%\
copy .\SCROLLER.TOS %EMU_DIR%\
