@REM 1. ������� ������ ���� �� ��������� (��. ����).
@REM 2. �������� ����� WAV �� ���� ����, �� �� ���������,
@REM ��� ������ ������ = ����� ����� ���������!
@REM ��� ������ �� ���� ����� ��������� ������� SCROLL LOCK.
@REM ����� ����������� ���� ���� �� ������� ����.
@REM _______________________________________________________
@REM 1. Set full path to program (see below). 2. Drop WAV on this file.
@REM Remember: EACH drop = new copy of a program!
@REM Press SCROLL LOCK to exit all copies.
@REM You may copy this file to Desktop.
@REM _______________________________________________________

@if exist %1 goto PLAY
@echo  RUS:  ������� WAV ���� �� ���� ���� !
@echo _______________________________________
@echo  ENG:  DROP WAV FILE ON THIS FILE !
@echo _______________________________________
@pause
@goto END

:PLAY
@REM ��������  C:\PROG  �� ������ ��� �����, ���� ��������� ���������.
@REM   (Change  ^^^^^  to full program folder name)
@pushd "C:\PROG"

@start PLAYWAV.EXE /P%1

:END