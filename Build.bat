@echo off 
SET VASM=.\bin\vbcc\bin\vasmm68k_mot.exe
SET EMU_DIR=..\hatari-2.6.0_windows64\hd
SET PNGTOPI=.\bin\pngtopi1-1.2.0\pngtopi1.exe

del main.tos /f 
del scroller.tos /f
del %EMU_DIR%\MAIN.TOS /f

%PNGTOPI% data\logo_multi.png data\logo_multi.pi1
%PNGTOPI% data\charset_8x8.png data\charset_8x8.pi1

%VASM% main.s -Ftos -o MAIN.TOS
REM %VASM% pixel.s -Ftos -o PIXEL.TOS
REM %VASM% scroller.s -Ftos -o SCROLLER.TOS
REM %VASM% scroller8.s -Ftos -o SCRX.TOS

%VASM% onebyone.s -Ftos -tos-flags=3 -o ONEBYONE.TOS

copy .\MAIN.TOS %EMU_DIR%\
copy .\ONEBYONE.TOS %EMU_DIR%\