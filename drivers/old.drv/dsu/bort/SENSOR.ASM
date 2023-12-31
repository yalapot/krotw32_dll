		.MODEL large
		PUBLIC _getSens
		PUBLIC _SensArray

;include inc\bort.inc
include bort.inc

; �஢��� �㬮� �� �������⨪� ����
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
	; ����訢��� �⥭�� 4 ᥪ�஢, ����� ���稪� ��室����� � cx
	mov dx, REQUEST_DATA_PORT
	out dx, al
	jmp short $+2
WaitACPloop:
	mov dx, DATA_READY_PORT
	in al, dx
	and al, DATA_READY_BIT
	jnz WaitACPloop ; ���� ��⮢���� ������

	; ��࣠�� ��� ᨭ�஭���樨
	mov dx, REQUEST_DATA_PORT
	mov ax, cx
	or al, 80h ; ���⠢�塞 ���訩 ��� � 1
	out dx, al
	jmp short $+2

	; ����᪠�� ��� �� ᫥���騥 4 ���稪�
	dec cl
	mov al, cl
	dec al
	mov dx, REQUEST_DATA_PORT
	out dx, al

	mov dx, PORT_2_3_SECTOR ; �⠥� �� 101h ���稪� 2 � 3 ᥪ��
	in al, dx
	jmp short $+2
	mov ah, al ; ��࠭塞 2 � 3 ᥪ��
	mov dx, PORT_0_1_SECTOR ; �⠥� �� 100h ���稪� 2 � 3 ᥪ��
	in al, dx
	jmp short $+2
	xor ax, 0ffffh ; �������㥬 ��������� ���稪��
	mov bx, ax

	call SensProc

	cmp cl, 0
	jnz WaitACPloop

WaitLastACPloop:

	mov dx, DATA_READY_PORT
	in al, dx
	and al, DATA_READY_BIT
	jnz WaitLastACPloop ; ���� ��⮢���� ������

	; ��࣠�� ��� ᨭ�஭���樨
	mov dx, REQUEST_DATA_PORT
	mov ax, cx
	or al, 80h ; ���⠢�塞 ���訩 ��� � 1
	out dx, al
	jmp short $+2

	mov dx, PORT_2_3_SECTOR ; �⠥� �� 101h ���稪� 2 � 3 ᥪ��
	in al, dx
	jmp short $+2
	mov ah, al ; ��࠭塞 2 � 3 ᥪ��
	mov dx, PORT_0_1_SECTOR ; �⠥� �� 100h ���稪� 2 � 3 ᥪ��
	in al, dx
	jmp short $+2
	xor ax, 0ffffh ; �������㥬 ��������� ���稪��
	mov bx, ax
	mov cx, 31 ; ��室 0<->32 ���稪�

	call SensProc

	pop bx
	pop cx
	pop dx
	pop di
	pop si
	mov ax, SensFlag

	ret

_getSens ENDP

; �� �室�
; di - ��砫� ���ᨢ�
; ax, bx - ��������� 4 ���稪��
; cl - ����� ᥪ��
; ࠧ��蠥�� ॣ���� si
SensProc PROC	near

	or bx, 0		; �᫨ �� ���稪� ����� ��
	jz ExitProc		; �� ��ࠡ��뢠�� � ��室��

	or bl, 0		; �᫨ ���稪� 0 � 1 ᥪ�� ����� �� ��
	jz TestBH		; ��ࠡ��뢠�� � �஢��塞 ���稪� 2 � 3 ᥪ�஢

	mov al, 0Fh
	and al, bl		; ����㥬 ���稪 0 ᥪ��
	jz Test1sect
	cmp al, LOW_LEVEL	; ��ᥪ��� ���㦭� �஢��
	jle Test1sect
	mov ax, 1
	mov SensFlag, ax	; 䫠� �ࠡ��뢠��� ���稪��

	mov si, di
	add si, cx

	; ��襬 ���ᨬ��쭮� ��������� ���稪�
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle Test1sect
	mov BYTE PTR [si], al

Test1sect:
	mov al, 0F0h
	and al, bl		; ����㥬 ���稪 1 ᥪ��
	jz TestBH
	ror al, 4
	cmp al, LOW_LEVEL	; ��ᥪ��� ���㦭� �஢��
	jle TestBH
	mov ax, 1
	mov SensFlag, ax	; 䫠� �ࠡ��뢠��� ���稪��

	mov si, di
	add si, cx
	add si, 32

	; ��襬 ���ᨬ��쭮� ��������� ���稪�
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle TestBH
	mov BYTE PTR [si], al

TestBH:
	or bh, 0		; �᫨ ���稪� 2 � 3 ᥪ�� ����� ��
	jz ExitProc		; �� ��ࠡ��뢠�� � ��室��

	mov al, 0Fh
	and al, bh		; ����㥬 ���稪 2 ᥪ��
	jz Test3sect
	cmp al, LOW_LEVEL	; ��ᥪ��� ���㦭� �஢��
	jle Test3sect
	mov ax, 1
	mov SensFlag, ax	; 䫠� �ࠡ��뢠��� ���稪��

	mov si, di
	add si, cx
	add si, 64

	; ��襬 ���ᨬ��쭮� ��������� ���稪�
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle Test3sect
	mov BYTE PTR [si], al

Test3sect:
	mov al, 0F0h
	and al, bh		; ����㥬 ���稪 3 ᥪ��
	jz ExitProc
	ror al, 4
	cmp al, LOW_LEVEL	; ��ᥪ��� ���㦭� �஢��
	jle ExitProc
	mov ax, 1
	mov SensFlag, ax	; 䫠� �ࠡ��뢠��� ���稪��

	mov si, di
	add si, cx
	add si, 96

	; ��襬 ���ᨬ��쭮� ��������� ���稪�
	mov ah, BYTE PTR [si]
	cmp al, ah
	jle ExitProc
	mov BYTE PTR [si], al

ExitProc:
	ret

SensProc ENDP

END