;	PlayWav 0.3  [ NT/2000/XP ] 20.11.2006 - 24.02.2007
; Воспроизведение звуковых файлов в формате WAV.
; Работает лишь в NT/XP, так как используются W-версии функций.
; Файл целиком загружается в память и играется бесконечно.
; Выход из программы ТОЛЬКО по нажатию SCROLL LOCK !
; Командная строка:	playwav.exe /Pимя_файла.WAV

; Редактор:	"Блокнот XP".	Шрифт: Lucida console, 10.
; Ассемблер:	MASM32 v5(8)+.
;______________________________________________________________________
.386P
.MODEL FLAT,STDCALL

;Клавиша остановки воспроизведения и выхода из программы.
C_EXIT_PROG_KEY equ	91h ;VK_SCROLL

EXTERN	ExitProcess@4:NEAR,\
	GetAsyncKeyState@4:NEAR,\
	GetCommandLineW@0:NEAR,\
	GetFileAttributesW@4:NEAR,\
	GetLastError@0:NEAR,\
	Sleep@4:NEAR,\
	PlaySoundW@12:NEAR

.DATA?
	W_FILENAME		DQ 512/8 DUP(?)			; 512 байт.
.CODE

_GO:
	CALL GetCommandLineW@0
;	TEST EAX,EAX
;	JE _ER_EXIT

;Командная строка: "exe" /Pfile.wav
;Ищем ключ /P
_FIND_P_CMD:
	MOV ECX,[EAX]
	TEST CX,CX
	JE _BadCommandLine
	ROR ECX,16
	TEST CX,CX
	JE _EXIT
	ADD EAX,2
	CMP ECX,[('/' SHL 16) OR 'P']				; '/P'
	JNE _FIND_P_CMD
;Сразу после ключа должно идти имя файла до нуля на конце.
	ADD EAX,2
	CMP WORD PTR[EAX],0
	JE _BadCommandLine

;PlaySoundW не может найти имя файла, если оно в кавычках!
;Копируем имя файла в буфер, попутно убирая кавычки.
	MOV EBX,256						; EBX = длина буфера в символах, включая 0.
	LEA EDX,W_FILENAME					; EDX = адрес буфера.
	MOV EDI,EDX						; EDI = в PlaySound.
_CopyFileName_SkipAllDoubleQuotes:
	MOV CX,[EAX]
	MOV [EDX],CX
	TEST CX,CX
	JE @F
	DEC EBX							; Проверка длины буфера.
	JE _FileNameTooLong
	ADD EAX,2
	CMP CX,'"'						; Просто пропускаем двойные кавычки.
	JE _CopyFileName_SkipAllDoubleQuotes
	ADD EDX,2
	JMP _CopyFileName_SkipAllDoubleQuotes
@@:
;Проверить длину имени файла. Меньше 5 символов не принимать (x.WAV).
	MOV EAX,EDX
	SUB EAX,EDI						; EAX = конец-начало = длина имени в байтах.
	CMP EAX,5*2						; 5 W-символов = 10 байт.
	JL _FileNameTooShort

;Проверить последние буквы имени файла. Если не "AV", то считаем, что не WAV.
;Это частично позволит избежать открытия не звукового файла.
	MOV ECX,[EDX-4]						; ECX = 2 последних символа имени.
	AND ECX,[NOT 200020h]					; К ВЕРХНЕМУ регистру (только английские).
	CMP ECX,[ ('V' SHL 16) OR 'A' ]				; "AV"
	JNE _FileNameNotWav

;Проверить есть ли файл с таким именем.
	PUSH EDI
	CALL GetFileAttributesW@4				; -1 - ошибка, 10h - папка.
	INC EAX							; Выход, если ошибка или папка.
	JE _ER_EXIT
	DEC EAX
	TEST AL,10h
	JNE _FileIsFolder

;Играем звук бесконечно и асинхронно (возврат будет сразу, а звук будет в отдельном потоке).
;Без SND_NODEFAULT=2: если файла нет, то будет системный звук по умолчанию.
;С SND_NODEFAULT: файла нет - звука не будет.
;В любом случае возврат не 0, если указано имя ЛЮБОГО существующего файла.
;Но с флагом SND_NODEFAULT программа будем молча висеть в памяти,
;а без него пользователь услышит системный звук (если он не отключен).
	PUSH 20000h+8+1 ;[SND_FILENAME+SND_LOOP+SND_ASYNC]	; 3. Тип звука.
	PUSH 0							; 2. Если не ресурс, то 0.
	PUSH EDI						; 1. Имя звука. Файл, память, ресурс. 0 - остановить текущий.
	CALL PlaySoundW@12					; 0 - ошибка.
	TEST EAX,EAX
	JE _ER_EXIT

_WAIT_KEY_LOOP:
;Пока система играет звук, мы "спим" в цикле по 50 мсек,
;и отслеживаем нажатие клавиши "Scroll Lock", чтобы закончить играть.
	PUSH 50
	CALL Sleep@4

	PUSH C_EXIT_PROG_KEY					; Код клавиши - задан в начале файла.
	CALL GetAsyncKeyState@4					; бит0=1 - была нажата, бит15=1 - сейчас нажата.
	TEST AX,AX
	JE _WAIT_KEY_LOOP

;Даем команду остановить все играемые звуки.
	XOR EAX,EAX
	PUSH 40h ;SND_PURGE
	PUSH EAX ;0
	PUSH EAX ;0
	CALL PlaySoundW@12
;Выходим из программы.
	TEST EAX,EAX
	MOV EAX,0						; Код выхода = 0.
	JNE _EXIT
_ER_EXIT:
	CALL GetLastError@0					; Код ошибки - будет кодом выхода.
_EXIT:
	PUSH EAX
	CALL ExitProcess@4

_BadCommandLine:
_FileNameTooLong:
_FileNameTooShort:
_FileNameNotWav:
_FileIsFolder:
	XOR EAX,EAX
	DEC EAX							; -1.
	JMP _EXIT

END _GO