
PIC_GET_PORT    EQU  580h
PIC_GET_SPECIAL EQU  588h

  ; ���塞 ��� ����� � PIC-������ �ਥ��樨
GET_ORIENTATION_TERMO  EQU   50h

  ; ���塞 ��� ����� � PIC-������ ���⮢ ���
GET_TRACK   EQU    90h


Read_vibro PROC near ; ��� ��类�� ����� �⠥� 3 ����樨
       push cx
       push dx
       push ax
       push bx

       mov bx, offset Vibro_1_value

       ; �⠥� ����� ���祭�� (����᪠�� ���� ���஢)
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2

       mov cx, 3 ; �⠥� �� ����樨
Read_vibro_data:
       push cx

        ; ���� ��� ��⮢���� ��� �⥭�� ����樨
       mov cx, 64000
Wait_ready_vibro:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_vibro
       LOOP Wait_ready_vibro

Compleate_Wait_ready_vibro:

       ; �⠥� ���祭��
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:bx], al
       inc  bx

        ; ���� ��� ��� ��⮢����
       mov cx, 64000
Wait_break_ready_vibro:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jnz Compleate_Wait_break_ready_vibro
       LOOP Wait_break_ready_vibro

Compleate_Wait_break_ready_vibro:
       pop cx
       LOOP Read_vibro_data

       pop bx
       pop ax
       pop dx
       pop cx

       ret

  ; �� ����樨
   Vibro_1_value      db 0
   Vibro_2_value      db 0
   Vibro_3_value      db 0

Read_vibro ENDP

Read_orient_termo PROC near  ; �� ���� 50h ��� 3 ����樨, �ਥ����
       push cx               ; � ⥬�������
       push dx
       push ax
       push bx

       ; ������ ����� ����権, �ਥ��樨 � ⥬������� � PIC-������
;       mov  dx, PIC_GET_PORT
 ;      mov  al, GET_ORIENTATION_TERMO
  ;     out  dx, al
   ;    Jmp $+2

       mov bx, offset Vibro_1_value

       mov cx, 3 ; �⠥� �� ����樨
Read_vibro_data_2:
       push cx

        ; ���� ��� ��⮢���� ��� �⥭�� ����樨
       mov cx, 49
Wait_ready_vibro_2:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_vibro_2
       LOOP Wait_ready_vibro_2

Compleate_Wait_ready_vibro_2:
       ; �⠥� ���祭��
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:bx], al
       inc  bx

        ; ���� ��� ��� ��⮢����
       mov cx, 49
Wait_break_ready_vibro_2:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jnz Compleate_Wait_break_ready_vibro_2
       LOOP Wait_break_ready_vibro_2

Compleate_Wait_break_ready_vibro_2:
       pop cx
       LOOP Read_vibro_data_2

        ; ���� ��� ��⮢���� ��� �⥭�� �ਥ��樨
       mov cx, 49
Wait_ready_orient:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_orient
       LOOP Wait_ready_orient

Compleate_Wait_ready_orient:
       ; �⠥� ���祭�� �ਥ��樨
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:Orientation_value], al

        ; ���� ��� ��� ��⮢���� �ਥ��樨
       mov cx, 49
Wait_break_ready_orient:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jnz Compleate_Wait_break_ready_orient
       LOOP Wait_break_ready_orient

Compleate_Wait_break_ready_orient:
        ; ���� ��� ��⮢���� ��� �⥭�� ⥬�������
       mov cx, 49
Wait_ready_termo:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_termo
       LOOP Wait_ready_termo

Compleate_Wait_ready_termo:
       ; �⠥� ���祭�� ⥬�������
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:Termo_value], al

        ; ���� ��� ��� ��⮢���� ⥬�������
;       mov cx, 64000
Wait_break_ready_termo:
 ;      mov  dx, PIC_GET_SPECIAL
  ;     in   al, dx
   ;    Jmp $+2
    ;   and al, 02h
     ;  jnz Compleate_Wait_break_ready_termo
      ; LOOP Wait_break_ready_termo

Compleate_Wait_break_ready_termo:
       pop bx
       pop ax
       pop dx
       pop cx

       ret

  ; �ਥ����
   Orientation_value     db 0

  ; ���������
   Termo_value           db 0

Read_orient_termo ENDP

Read_track PROC near  ; �� ���� 90h �⠥� 12 ���⮢ ���
       push cx
       push dx
       push ax
       push bx

       mov bx, offset Track_full_byte_1

       ; ������ �����
       mov  dx, PIC_GET_PORT
       mov  al, GET_TRACK
       out  dx, al
       Jmp $+2

        ; ���� ��� ��� ��⮢����
       mov cx, 70
Wait_break_ready_pred_track:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jnz Compleate_Wait_break_ready_pred_track
       LOOP Wait_break_ready_pred_track

Compleate_Wait_break_ready_pred_track:

       mov cx, 12 ; �⠥� 12 ���⮢ ���
Read_track_data:
       push cx

        ; ���� ��� ��⮢���� ��� �⥭��
       mov cx, 70
Wait_ready_track:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_track
       LOOP Wait_ready_track

Compleate_Wait_ready_track:

       ; �⠥� ���祭��
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:bx], al
       inc  bx

        ; ���� ��� ��� ��⮢����
       mov cx, 70
Wait_break_ready_track:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jnz Compleate_Wait_break_ready_track
       LOOP Wait_break_ready_track

Compleate_Wait_break_ready_track:
       pop cx
       LOOP Read_track_data

       pop bx
       pop ax
       pop dx
       pop cx

       ret

  ; ���� ���� ������ ���
   Track_full_byte_1  db 0
   Track_full_byte_2  db 0
   Track_full_byte_3  db 0
   Track_full_byte_4  db 0

  ; ���� ���� ��� I �������
   Track_I_Odom_byte_1  db 0
   Track_I_Odom_byte_2  db 0
   Track_I_Odom_byte_3  db 0
   Track_I_Odom_byte_4  db 0

  ; ���� ���� ��� II �������
   Track_II_Odom_byte_1  db 0
   Track_II_Odom_byte_2  db 0
   Track_II_Odom_byte_3  db 0
   Track_II_Odom_byte_4  db 0

Read_track ENDP


    ; �஢��塞 PIC �� ���४⭮��� ࠡ���, �த� ��� ����
Check_PIC_Processor PROC near ; �᫨ ��� ax=0, �᫨ 㬥� ax>0
      pushad

;      call Read_PIC_Processor

      xor ax, ax

      mov dl, byte ptr [cs:Vibro_1_value]
      mov bx, (offset Vibro_1_value) + 1
      mov cx, 15
Compare_readed_data:
      cmp dl, byte ptr [cs:bx]
      jne Volume_not_ecvivalent
      inc ax
Volume_not_ecvivalent:
      LOOP Compare_readed_data

      mov word ptr [cs:PIC_Status], ax

      popad
      mov ax, word ptr [cs:PIC_Status]
      ret

 PIC_Status dw 0

Check_PIC_Processor ENDP

get_pos PROC near ; ��楤�� �⥭�� ���稪� �ਥ��樨
                  ; ���⠭��� ���祭�� ����頥� �  al
      mov al, byte ptr [cs:Orientation_value]
      ret

   old_pos db 0
get_pos ENDP  ; --------------------


get_termo_dat PROC near ; ��楤�� �⥭�� ���稪� ⥬�������
                          ; ���⠭��� ���祭�� ����頥� �  al
      mov al, byte ptr [cs:Termo_value]
      ret

get_termo_dat ENDP  ; --------------------

get_vibro1 PROC near ; ��楤�� �⥭�� ���稪� ����樨 #1
                     ; ���⠭��� ���祭�� ����頥� �  al
      mov al, byte ptr [cs:Vibro_1_value]
      ret

get_vibro1 ENDP  ; --------------------

get_vibro2 PROC near ; ��楤�� �⥭�� ���稪� ����樨 #2
                     ; ���⠭��� ���祭�� ����頥� �  al
      mov al, byte ptr [cs:Vibro_2_value]
      ret

get_vibro2 ENDP  ; --------------------

get_vibro3 PROC near ; ��楤�� �⥭�� ���稪� ����樨 #3
                     ; ���⠭��� ���祭�� ����頥� �  al
      mov al, byte ptr [cs:Vibro_3_value]
      ret

get_vibro3 ENDP  ; --------------------

get_wheel_number PROC near ; ��楤�� �⥭�� ����� ����� (0 ��� 1)
                           ; ���⠭��� ���祭�� ����頥� �  al

    push dx
    mov  dx, PIC_GET_SPECIAL ;
    in   al, dx
    and  al, 08h ; ����砥� ����� �����
    shr  al, 3
;    add  al, '0'
    mov byte ptr [ds:bx], al
    pop  dx

    ret

get_wheel_number ENDP

Get_PIC_track PROC near    ; ��⠭�� � PIC-������ ���
                           ; ����襬 � ��ப� ��� �뢮�� � log-䠩�.
      pushad               ; ��ப� Pic_track ������ � log_fale.asm

       mov eax, dword ptr [cs:Track_full_byte_1]
       mov di, (offset cs:Pic_track)+5
       mov ebx, 10
       call itoa32

       mov eax, dword ptr [cs:Track_I_Odom_byte_1]
       mov di, (offset cs:Pic_track)+24
       mov ebx, 10
       call itoa32

       mov eax, dword ptr [cs:Track_II_Odom_byte_1]
       mov di, (offset cs:Pic_track)+44
       mov ebx, 10
       call itoa32

      popad
      ret

Get_PIC_track ENDP

