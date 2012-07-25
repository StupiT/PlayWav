@REM 1. Укажите полный путь до программы (см. ниже).
@REM 2. Бросайте файлы WAV на этот файл, но не забывайте,
@REM что КАЖДЫЙ бросок = новая копия программы!
@REM Для выхода из всех копий программы нажмите SCROLL LOCK.
@REM Можно скопировать этот файл на Рабочий стол.
@REM _______________________________________________________
@REM 1. Set full path to program (see below). 2. Drop WAV on this file.
@REM Remember: EACH drop = new copy of a program!
@REM Press SCROLL LOCK to exit all copies.
@REM You may copy this file to Desktop.
@REM _______________________________________________________

@if exist %1 goto PLAY
@echo  RUS:  ЃђЋ‘њ’… WAV ”Ђ‰‹ ЌЂ ќ’Ћ’ ”Ђ‰‹ !
@echo _______________________________________
@echo  ENG:  DROP WAV FILE ON THIS FILE !
@echo _______________________________________
@pause
@goto END

:PLAY
@REM Замените  C:\PROG  на полное имя папки, куда поместите программу.
@REM   (Change  ^^^^^  to full program folder name)
@pushd "C:\PROG"

@start PLAYWAV.EXE /P%1

:END