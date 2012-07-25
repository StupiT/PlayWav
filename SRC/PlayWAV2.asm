;	2012-01-29
; �������� �����, ����������� ���-������ � ����, ���� ������ ����� ��������� � 1,5 �� 1 ��.
;______________________________________________________________________
;	PlayWav 0.3  [ NT/2000/XP ] 20.11.2006 - 24.02.2007
; ��������������� �������� ������ � ������� WAV.
; �������� ���� � NT/XP, ��� ��� ������������ W-������ �������.
; ���� ������� ����������� � ������ � �������� ����������.
; ����� �� ��������� ������ �� ������� SCROLL LOCK !
; ��������� ������:	playwav.exe /P���_�����.WAV

; ��������:	"������� XP".	�����: Lucida console, 10.
; ���������:	MASM32 v5(8)+.
;______________________________________________________________________
.386P
.MODEL FLAT,STDCALL

;������� ��������� ��������������� � ������ �� ���������.
C_EXIT_PROG_KEY equ	91h ;VK_SCROLL

EXTERN	_imp__ExitProcess@4:NEAR,\
	_imp__GetAsyncKeyState@4:NEAR,\
	_imp__GetCommandLineW@0:NEAR,\
	_imp__GetFileAttributesW@4:NEAR,\
	_imp__GetLastError@0:NEAR,\
	_imp__Sleep@4:NEAR,\
	_imp__PlaySoundW@12:NEAR

.DATA?
	W_FILENAME		DQ 512/8 DUP(?)			; 512 ����.
.CODE

_GO:
	XOR ESI,ESI	;����� ������ 0 ��� ���������� ������� ����

	CALL DWORD PTR[_imp__GetCommandLineW@0]

;��������� ������: "exe" /Pfile.wav
;���� ���� /P
_FIND_P_CMD:
	MOV ECX,[EAX]
	TEST CX,CX
	JE _BadCommandLine
	ROR ECX,16
	TEST CX,CX
	JE _EXIT
	INC EAX
	INC EAX
	CMP ECX,[('/' SHL 16) OR 'P']				; '/P'
	JNE _FIND_P_CMD
;����� ����� ����� ������ ���� ��� ����� �� ���� �� �����.
	INC EAX
	INC EAX
	CMP WORD PTR[EAX],SI ;0
	JE _BadCommandLine

;PlaySoundW �� ����� ����� ��� �����, ���� ��� � ��������!
;�������� ��� ����� � �����, ������� ������ �������.
	XOR EBX,EBX
	MOV BL,255						; EBX = ����� ������ � ��������, ������� 0.
	LEA EDX,W_FILENAME					; EDX = ����� ������.
	MOV EDI,EDX						; EDI = � PlaySound.
_CopyFileName_SkipAllDoubleQuotes:
	MOV CX,[EAX]
	MOV [EDX],CX
	TEST CX,CX
	JE @F
	DEC EBX							; �������� ����� ������.
	JE _FileNameTooLong
	INC EAX
	INC EAX
	CMP CX,'"'						; ������ ���������� ������� �������.
	JE _CopyFileName_SkipAllDoubleQuotes
	INC EDX
	INC EDX
	JMP _CopyFileName_SkipAllDoubleQuotes
@@:
;��������� ����� ����� �����. ������ 5 �������� �� ��������� (x.WAV).
	MOV EAX,EDX
	SUB EAX,EDI						; EAX = �����-������ = ����� ����� � ������.
	CMP EAX,5*2						; 5 W-�������� = 10 ����.
	JL _FileNameTooShort

;��������� ��������� ����� ����� �����. ���� �� "AV", �� �������, ��� �� WAV.
;��� �������� �������� �������� �������� �� ��������� �����.
	MOV ECX,[EDX-4]						; ECX = 2 ��������� ������� �����.
	AND ECX,[NOT 200020h]					; � �������� �������� (������ ����������).
	CMP ECX,[ ('V' SHL 16) OR 'A' ]				; "AV"
	JNE _FileNameNotWav

;��������� ���� �� ���� � ����� ������.
	PUSH EDI
	CALL DWORD PTR[_imp__GetFileAttributesW@4]				; -1 - ������, 10h - �����.
	INC EAX							; �����, ���� ������ ��� �����.
	JE _ER_EXIT
	DEC EAX
	TEST AL,10h
	JNE _FileIsFolder

;������ ���� ���������� � ���������� (������� ����� �����, � ���� ����� � ��������� ������).
;��� SND_NODEFAULT=2: ���� ����� ���, �� ����� ��������� ���� �� ���������.
;� SND_NODEFAULT: ����� ��� - ����� �� �����.
;� ����� ������ ������� �� 0, ���� ������� ��� ������ ������������� �����.
;�� � ������ SND_NODEFAULT ��������� ����� ����� ������ � ������,
;� ��� ���� ������������ ������� ��������� ���� (���� �� �� ��������).
	PUSH 20000h+8+1 ;[SND_FILENAME+SND_LOOP+SND_ASYNC]	; 3. ��� �����.
	PUSH ESI ;0							; 2. ���� �� ������, �� 0.
	PUSH EDI						; 1. ��� �����. ����, ������, ������. 0 - ���������� �������.
	MOV EDI,DWORD PTR[_imp__PlaySoundW@12]					; 0 - ������.
	CALL EDI
	TEST EAX,EAX
	JE _ER_EXIT

_WAIT_KEY_LOOP:
;���� ������� ������ ����, �� "����" � ����� �� 50 ����,
;� ����������� ������� ������� "Scroll Lock", ����� ��������� ������.
	PUSH 50
	CALL DWORD PTR[_imp__Sleep@4]

	XOR EAX,EAX
	MOV AL,C_EXIT_PROG_KEY
	PUSH EAX					; ��� ������� - ����� � ������ �����.
	CALL DWORD PTR[_imp__GetAsyncKeyState@4]					; ���0=1 - ���� ������, ���15=1 - ������ ������.
	TEST AX,AX
	JE _WAIT_KEY_LOOP

;���� ������� ���������� ��� �������� �����.
	PUSH 40h ;SND_PURGE
	PUSH ESI ;0
	PUSH ESI ;0
	CALL EDI ;DWORD PTR[_imp__PlaySoundW@12]
;������� �� ���������.
	TEST EAX,EAX
	MOV EAX,ESI ;0						; ��� ������ = 0.
	JNE _EXIT
_ER_EXIT:
	CALL DWORD PTR[_imp__GetLastError@0]					; ��� ������ - ����� ����� ������.
_EXIT:
	PUSH EAX
	CALL DWORD PTR[_imp__ExitProcess@4]

_BadCommandLine:
_FileNameTooLong:
_FileNameTooShort:
_FileNameNotWav:
_FileIsFolder:
	XOR EAX,EAX
	DEC EAX							; -1.
	JMP _EXIT

END _GO