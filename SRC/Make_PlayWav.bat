@\masm32\bin\ml.exe /c /coff /nologo /Cp PlayWav.asm
@if errorlevel 1 goto ERR

@\masm32\bin\link.exe /VERSION:0.3 /nologo /SUBSYSTEM:WINDOWS /MERGE:.rdata=.text /OPT:NOWIN98 /LIBPATH:\masm32\lib PlayWav.obj kernel32.lib user32.lib winmm.lib
@if errorlevel 1 goto ERR
@del playwav.obj
@goto END
:ERR
@pause
:END