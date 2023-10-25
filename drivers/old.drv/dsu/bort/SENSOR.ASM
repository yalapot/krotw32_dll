		.MODEL large
		PUBLIC _getSens
		PUBLIC _SensArray

;include inc\bort.inc
include bort.inc

; уровень шумов при диагностике ласт
LOW_LEVEL	equ 4

		.DATA
_SensArray db 128 dup (0)
SensFlag dw (0)

		.CODE
.386

_getSens PROC

	push si
	push di
	push dx
	push cx
	push bx

	mov di, OFFSET _SensArray
	mov ax, 0
	mov SensFlag, ax
	mov cl, 31
	mov ax, cx
	; запрашиваем чтение 4 секторов, номер датчика находиться в cx
	mov dx, REQUEST_DATA_PORT
	out dx, al
	jmp short $+2
WaitACPloop:
	mov dx, DATA_READY_PORT
	in al, dx
	and al, DATA_READY_BIT
	jnz WaitACPloop ; ждем готовности данных

	; дергаем бит синхронизации
	mov dx, REQUEST_DATA_PORT
	mov ax, cx
	or al, 80h ; выставляем старший бит в 1
	out dx, al
	jmp short $+2

	; запускаем АЦП на следующие 4 датчика
	dec cl
	mov al, cl
	dec al
	mov dx, REQUEST_DATA_PORT
	out dx, al

	mov dx, PORT_2_3_SECTOR ; читаем из 101h датчики 2 и 3 сектора
	in al, dx
	jmp short $+2
	mov ah, al ; сохраняем 2 и 3 сектора
	mov dx, PORT_0_1_SECTOR ; читаем из 100h датчики 2 и 3 сектора
	in al, dx
	jmp short $+2
	xor ax, 0ffffh ; инвертируем показания датчиков
	mov bx, ax

	call SensProc

	cmp cl, 0
	jnz WaitACPloop

WaitLastACPloop:

	mov dx, DATA_READY_PORT
	in al, dx
	and al, DATA_READY_BIT
	jnz WaitLastACPloop ; ждем готовности данных

	; дергаем бит синхронизации
	mov dx, REQUEST_DATA_PORT
	mov ax, cx
	or al, 80h ; выставляем старший бит в 1
	out dx, al
	jmp short $+2

	mov dx, PORT_2_3_SECTOR ; читаем из 101h датчики 2 и 3 сектора
	in al, dx
	jmp short $+2
	mov ah, al ; сохраняем 2 и 3 сектора
	mov dx, PORT_0_1_SECTOR ; читаем из 100h датчики 2 и 3 сектора
	in al, dx
	jmp short $+2
	xor ax, 0ffffh ; инвертируем показания датчиков
	mov bx, ax
	mov cx, 31 ; обход 0<->32 датчика

	call SensProc

	pop bx
	pop cx
	pop dx
	pop di
	pop si
	mov ax, SensFlag

	ret

_getSens ENDP

; на входе
; di - начало массива
; ax, bx - показания 4 датчиков
; cl - номер сектора
; разрушаемый регистр si
SensProc PROC	near

	or bx, 0		; если все датчики пустые их
	jz ExitProc		; не обрабатываем и выходим

	or bl, 0		; если датчики 0 и 1 сектора пустые их не
	jz TestBH		; обрабатываем а проверяем датчики 2 и 3 секторов

	mov al, 0Fh
	and al, bl		; тестируем датчик 0 сектора
	jz Test1sect
	cmp al, LOW_LEVEL	; отсекаем ненужные уровни
	jle Test1sect
	mov ax, 1
	mov SensFlag, ax	; флаг срабатывания датчиков

	mov si, di
	add si, cx

	; пишем максимальное показание датчика
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle Test1sect
	mov BYTE PTR [si], al

Test1sect:
	mov al, 0F0h
	and al, bl		; тестируем датчик 1 сектора
	jz TestBH
	ror al, 4
	cmp al, LOW_LEVEL	; отсекаем ненужные уровни
	jle TestBH
	mov ax, 1
	mov SensFlag, ax	; флаг срабатывания датчиков

	mov si, di
	add si, cx
	add si, 32

	; пишем максимальное показание датчика
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle TestBH
	mov BYTE PTR [si], al

TestBH:
	or bh, 0		; если датчики 2 и 3 сектора пустые их
	jz ExitProc		; не обрабатываем и выходим

	mov al, 0Fh
	and al, bh		; тестируем датчик 2 сектора
	jz Test3sect
	cmp al, LOW_LEVEL	; отсекаем ненужные уровни
	jle Test3sect
	mov ax, 1
	mov SensFlag, ax	; флаг срабатывания датчиков

	mov si, di
	add si, cx
	add si, 64

	; пишем максимальное показание датчика
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle Test3sect
	mov BYTE PTR [si], al

Test3sect:
	mov al, 0F0h
	and al, bh		; тестируем датчик 3 сектора
	jz ExitProc
	ror al, 4
	cmp al, LOW_LEVEL	; отсекаем ненужные уровни
	jle ExitProc
	mov ax, 1
	mov SensFlag, ax	; флаг срабатывания датчиков

	mov si, di
	add si, cx
	add si, 96

	; пишем максимальное показание датчика
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle ExitProc
	mov BYTE PTR [si], al

ExitProc:
	ret

SensProc ENDP

END