include read_pic.asm

DIMENSION_SIZE EQU  134

BASE_PROTOTIP_ODOM equ 580h

TIMER_INT    EQU  08h    ; ���뢠��� ⠩���  (IRQ 0)
ODOMETR_INT  EQU  0Dh    ; ���뢠��� ������� (IRQ 5)
TIMER_CLOKC  EQU  11929  ; 11929 - 100 ��
                         ;
DELEY_CLOCK  EQU  1000  ; �६� ��।����饥 ��ﭪ� � ���� ᥪ㭤�

BASE_ADC_1  equ 520h
BASE_ADC_2  equ 530h
BASE_ADC_3  equ 560h
BASE_ADC_4  equ 570h

Timer PROC far
       cli
       push eax

       add dword ptr [cs:time], 0001h ; ��⠥� �६�
       adc word ptr [cs:time+4], 0000 ;

       mov al, 20h
       out 20h, al

       pop eax
       iret

time   DD    100  ; ���� ��� ᮡ�⢥��� ���稪 ⠩���
       DW      0  ; � �� �� ��砩 ��९�������

Base_Skip           dw  0
Odom_skip           dw  0 ; ���� �ய�᪠ ���� �������
pred_track_in_timer dd  0 ; ���祭�� ���稪� ������� �� �।. �室� � Timer
Timer ENDP


init_ADC  PROC near  ; ���樠������ ��p� ��� ��� 16 ��⭮� ��p����
                     ; ��p��  al � dx
      mov   al, 20h
      mov   dx, BASE_ADC_1 + 4
      out   dx, al
      mov   dx, BASE_ADC_2 + 4h
      out   dx, al
      mov   dx, BASE_ADC_3 + 4h
      out   dx, al
      mov   dx, BASE_ADC_4 + 4h
      out   dx, al

      mov   ax, 0E927h
      mov   dx, BASE_ADC_1 + 4h
      out   dx, ax
      mov   dx, BASE_ADC_2 + 4h
      out   dx, ax
      mov   dx, BASE_ADC_3 + 4h
      out   dx, ax
      mov   dx, BASE_ADC_4 + 4h
      out   dx, ax
      ret
init_ADC  ENDP   ; ---------------------

test_ADC  PROC near
      mov   al, 80h     ; ����� ���஢�� 0 ������ ��� ���
      mov   dx, BASE_ADC_1 + 2h    ; � ����প��
      out   dx, al
      mov   dx, BASE_ADC_2 + 2h
      out   dx, al

      mov  dx, BASE_ADC_1+4
      in   ax, dx

      mov  dx, BASE_ADC_1+4
      in   ax, dx

      mov  dx, BASE_ADC_1+4
      in   ax, dx

      mov  dx, BASE_ADC_1+4
      in   ax, dx

      mov  cx, 14  ; �஢��塞 14 ࠧ
      xor  ax, ax      ; �஢�ઠ ��⮢���� ��ࢮ� ���
      mov  dx, BASE_ADC_1+4
Ready_First:
      in   ax, dx
      and  ax, 0100h
      jnz  Read_data
      LOOP Ready_First

Read_data:

      mov  cx, 16    ; �����塞 16 ࠧ

Begin_read:
      ; ��ࢠ� ����
      mov  dx, BASE_ADC_1
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; ����頥� १���� �� [ds:bx]
      add  bx, 32

      mov  dx, BASE_ADC_1 + 2h
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; ����頥� १���� �� [ds:bx]
      add  bx, 32

      mov  al, 40h   ; ����� ���஢�� ᫥���饣� ������ ��� ����প�
      out  dx, al

      ; ���� ����
      mov  dx, BASE_ADC_2
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; ����頥� १���� �� [ds:bx]
      add  bx, 32

      mov  dx, BASE_ADC_2 + 2h
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; ����頥� १���� �� [ds:bx]
      add  bx, 32

      mov  al, 40h   ; ����� ���஢�� ᫥���饣� ������ ��� ����প�
      out  dx, al

      sub  bx, 126

;      LOOP Begin_read
      dec cx
      jnz Begin_read   ; �����稫�� 横� �⥭��

      add  bx, 96
      ret

test_ADC  ENDP   ; ---------------------


Odometr PROC far
    cli
    pushad

    mov al, 0DFh ; �⪫�砥� ��᪠��� ����஫��� ���뢠���
    out 21h, al  ; �.�. �⪫�砥� ���뢠��� SCSI (IDE)

    add dword ptr [cs:track], 0001h    ; 㢥��稢��� ���稪 �������
    adc word ptr [cs:track+4], 0000

    mov al, 20h    ; ࠧ�蠥� ����஫���� ���뢠���
    out 20h, al

    cmp byte ptr [cs:int_activ], 0 ; �஢��塞 �� ������ �室 �
    jne End_Proc                   ; Odometr, ���� ��室��

    mov bp, word ptr [cs:read_buf]
    cmp byte ptr [cs:beasy_buf + bp], 0  ; �஢��塞, �� �ॡ㥬�
    jne End_Proc                        ; ���� �� �����, ���� ��室��

     ; �஢�ਬ �� ᫥���騩 ����� ⮦� �� �����
     mov bp, word ptr [cs:read_buf]
     inc bp
     cmp bp, word ptr [cs:MAX_BUF]
     jne Check_next_buf  ; �஢�ਬ �� ��� �� ���몠�� ����� � ᯨ᪥ ���஢
     xor bp, bp
Check_next_buf:
    cmp byte ptr [cs:beasy_buf + bp], 0  ; �஢��塞, �� ᫥���騩
    jne End_Proc                        ; ���� �� �����, ���� ��室��

    cmp word ptr [cs:Curent_Odom_skip], 0 ; �஢��塞 �� �ॡ���� ��
    jne End_Proc                    ; ��।��� ����७��

    push ds
    push es

    mov eax, dword ptr [cs:track]      ; ��������� � eax ⨪� �������

    mov byte ptr [cs:int_activ], 1   ; �⠢�� 䫠� �� 㦥 ���� ࠧ ��諨
    sti                              ; � ��ࠡ��稪, ࠧ�蠥� ���뢠���

    sub eax, dword ptr [cs:last_track] ; ���᫨� ᪮�쪮 ⨪�� �������
    add dword ptr [cs:last_track], eax ; ��諮 � �।��饣� ����७��
    mov word ptr [cs:d_track], ax      ; ��ᥪ��� ���祭�� ���稪� �������

    add word ptr [cs:read_rec], ax    ; 㢥��稢��� ���稪 ����ᥩ � �����


    cmp word ptr [cs:read_rec], 201  ; �ࠢ��� � ��ମ� ����७�� � �����
    jb Dimension                     ; �᫨ �����, � ���室�� � ����७��
       mov eax, dword ptr [cs:time]
       sub eax, dword ptr [cs:abs_time]
       add dword ptr [cs:abs_time], eax  ; ��������� �६�

Begin_correct_read_rec:
       cmp word ptr [cs:read_rec], 200
       jb Complete_correct_read_rec
       add dword ptr [cs:abs_track], 200
       sub word ptr [cs:read_rec], 200
       jmp Begin_correct_read_rec
Complete_correct_read_rec:

       call get_termo_dat
       mov byte ptr [cs:reserved+5], al

       call get_pos  ; ��楤�� �⥭�� ���稪� �ਥ��樨
       mov byte ptr [cs:pos], al

       ; ��ନ஢��� "���������" ����� ⥯��� ᪮���㥬 ��� � ����
       mov  bp, word ptr [cs:read_buf]
       shl  bp, 2
       mov  bx, word ptr [cs:buff+bp+2]
       mov  ds, bx
       mov  bx, word ptr [cs:buff+bp]
       sub  bx, 16

       mov eax, dword ptr [cs:Block]   ; ���� 4 ����
       mov dword ptr [ds:bx], eax
       add bx, 4

       mov eax, dword ptr [cs:Block+4]  ; ���� 4 ����
       mov dword ptr [ds:bx], eax
       add bx, 4

       mov eax, dword ptr [cs:Block+8]  ; ���� 4 ����
       mov dword ptr [ds:bx], eax
       add bx, 4

       mov eax, dword ptr [cs:Block+12] ; �⢥��� 4 ����
       mov dword ptr [ds:bx], eax
       add bx, 4

         mov bp, word ptr [cs:read_buf]
         mov byte ptr [cs:beasy_buf + bp], 1 ; 䫠� ������� ����

         inc word ptr [cs:read_buf]
         mov ax, word ptr [cs:MAX_BUF]
         cmp word ptr [cs:read_buf], ax
         jne @1  ; �஢�ਬ �� ��� �� ���몠�� ����� � ᯨ᪥ ���஢
         mov word ptr [cs:read_buf], 0
 @1:
         ; ��४��稬 current �� ���� �����
         mov  bp, word ptr [cs:read_buf]
         shl  bp, 2
         add  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  word ptr [cs:current+2], ax
         sub  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  word ptr [cs:current], ax

         mov byte ptr [cs:reserved], 0

    ; ��࣠���� ������ �� �����୮� ����
       in  al, 0e5h
       mov ah, byte ptr [cs:read_buf]
       test ah, 01h
       jnz not_zero_led
       and al, 7fh
       jmp end_led_manipulate
not_zero_led:
       or al, 80h
end_led_manipulate:
       out 0e5h, al
    ; �஬�࣠���� ������ �� �����୮� ����

Dimension: ; ��砫� �⠭���⭮�� 横�� ����७��
    mov bx, word ptr [cs:current+2]  ; ����頥� ���祭�� current
    mov ds, bx                       ; � ds:bx
    mov bx, word ptr [cs:current]    ; (���� ��� ����� ������)

    mov ax, word ptr [cs:d_track]  ; �⬥砥� � ���� ᪮�쪮 ����⮢
    mov word ptr [ds:bx], ax       ; ��諮 �� �।��饣� ����७��
    add bx, 2

    inc byte ptr [cs:reserved]  ; 㢥��稢��� ���稪 ॠ�쭮 ����ᠭ���
                                ; ����७��
    call get_wheel_number
    mov byte ptr [ds:bx], al
    inc  bx

    call get_vibro1            ; ���稪 ����樨  # 1
    mov byte ptr [ds:bx], al
    inc bx

    call get_vibro2            ; ���稪 ����樨  # 2
    mov byte ptr [ds:bx], al
    inc bx

    call get_vibro3            ; ���稪 ����樨  # 3
    mov byte ptr [ds:bx], al
    inc bx

    call test_ADC

    mov word ptr [cs:current], bx  ; ��p��塞�� ����� ���祭�� current
    mov bx, ds                       ; �� ds:bx
    mov word ptr [cs:current+2], bx    ; (���� ��� ����� ������)

    mov eax, dword ptr [cs:time]         ; ��p��塞 �p��� ��᫥�����
    sub eax, dword ptr [cs:last_time]    ; ����p����
    add dword ptr [cs:last_time], eax    ; � ��ᥪ��� ࠧ����

    pop  es
    pop  ds

    cli
    mov byte ptr [cs:int_activ], 0

End_Proc:
    mov al, 0D8h ; ����砥� ��᪠��� ����஫��� ���뢠���
    out 21h, al

    cmp word ptr [cs:Curent_Odom_skip], 0
    je Init_Curent_Odom_skip

    dec word ptr [cs:Curent_Odom_skip]
    popad
    iret

Init_Curent_Odom_skip:
    mov ax, word ptr [cs:Odom_skip]
    mov word ptr [cs:Curent_Odom_skip], ax
    popad
    iret

int_activ  DB  0  ; 䫠� ��⨢���� ��ࠡ��稪�

track   DD     0  ; ���� ��� ���稪 �������
        DW     0  ; � �� �� ��砩 ��९�������

MAX_BUF       DW  12  ; ������⢮ ���஢ � ��⥬� (�� ����� 20)

buff        DD  20 DUP (0) ; ���� ��� 20 ������� ���ᮢ ���஢
beasy_buf   DB  20 DUP (0) ; ���� ��� 20 䫠��� ������� ���஢ (1)
length_buf  DW  20 DUP (0) ; ���� ��� 20 ����� ������������ ���஢

current     DD  0 ; ������ 㪠��⥫� �� ⥪�饥 ���� ����� (seg:ofs)
read_buf    DW  0 ; ����� ���� � ����� �⠥� ����� � ���稪��
read_rec    DW  0 ; ���稪 ���⠭��� ����७�� (� ������ ��. 袥)

; ������� "���������" 2-� ���஢��� ����� (tech_info)
Block      DB    0F7h  ; ᨣ�����
pos        DB    0     ; ��������� ᭠�鸞
abs_time   DD    0     ; ��襤襥 � ��砫� ��� �६�
abs_track  DD    0     ; �ன������ � ��砫� ��� ����ﭨ�
reserved   DB    0,"��01",0 ; ��१�ࢨ஢��� 6 ����
; ����� ���ᠭ�� "���������" �����

reserv_2   DB    0,0,"#0#"  ; ��१�ࢨ஢��� 5 ���� � ��������� �����
                                 ; ����७��, ���� ��� ��� �६� ��ﭪ�

last_time  DD    0  ; �६� �� �।��饬 ����७��
last_track DD    0  ; ����ﭨ� �� �।��饬 ����७��

d_track DD     0  ; ��諮 ⨪�� ������� � �।�. ����७��

Curent_Odom_skip  dw 0

Odometr ENDP


CHANGE_FILE PROC near
      push bp
      mov  bp, word ptr [cs:num_file_data]
      inc  byte ptr [cs:bp+4]
      cmp  byte ptr [cs:bp+4], 58
      jne  End_change
         mov  byte ptr [cs:bp+4], '0'
         inc  byte ptr [cs:bp+3]
         cmp  byte ptr [cs:bp+3], 58
         jne  End_change
            mov  byte ptr [cs:bp+3], '0'
            inc  byte ptr [cs:bp+2]
            cmp  byte ptr [cs:bp+2], 58
            jne  End_change
               mov  byte ptr [cs:bp+2], '0'
               inc  byte ptr [cs:bp+1]
               cmp  byte ptr [cs:bp+1], 58
               jne  End_change
                  mov  byte ptr [cs:bp+1], '0'
                  inc  byte ptr [cs:bp]
      ;  ;  ;  ; ---------------------------------------------
End_change:
      pop  bp
      ret

CHANGE_FILE ENDP


Next_file PROC near
       pusha
       push ds

       mov  ax, cs
       mov  ds, ax

      ; ����뢠�� 䠩� ������
       mov  ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h

       call CHANGE_FILE

Check_free_space:
       ; �஢�ਬ ᪮�쪮 ᢮������� ����
       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       cmp dl, 0
       je Crash1

       sub dl, 'a'  ;dl =  ����� �㦭��� ��᪠
       inc dl

       mov ah, 36h
       int 21h
       cmp ax, 0ffffh
       je Crash1
       xor edx, edx
       and eax, 0ffffh
       and ecx, 0ffffh
       and ebx, 0ffffh
       mul ecx
       mul ebx
       cmp eax, 2700000 ; 2.7 ��
       jae Not_change_disk

        ; �஢�ਬ ���� �� �� ��᪨ ��� �����
       dec word ptr [cs:work_disk_count]
       inc word ptr [cs:disk_count]
       cmp word ptr [cs:work_disk_count], 0
       je Crash1

       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       cmp dl, 0
       je Crash1

       sub dl, 'a'  ;dl =  ����� �㦭��� ��᪠

        ; ����稬 ᫥���騩 ��� �� ᯨ᪠
       mov ah, 0Eh
       int 21h
       jmp Check_free_space

Not_change_disk:
       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       mov byte ptr [cs:last_wrk_dsk], dl

       ; ���뢠�� 䠩� ��� ����� ������
       mov  ax, 3c00h        ; �㭪�� DOS ᮧ����� 䠩��
       mov  cx, 00         ; ����� 䠩�
       mov  dx, offset cs:file_data  ;
       int  21h
       jc   Crash1
       mov  word ptr [cs:data_descriptor], ax

       pop  ds
       popa
       ret

Crash1:
       pop  ds
       popa
      ; mov  al, 1  ; ��室 � �訡���
       ret
Next_file ENDP

Check_last_file proc near
       pushad

       ; ��࠭�� ��� 䠩�� �� ���饥
       mov bx, offset file_data
       mov di, offset BuckUp_file_name
       mov cx, 3
    Copy_file_name_to_BuckUp:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_file_name_to_BuckUp
       ; ��࠭��� ��� 䠩�� �� ���饥

       mov  ax, offset [cs:file_data]   ; ���⠢�� 㪠��⥫�
       add  ax, 2                       ; �� ����� 䠩��
       mov  word ptr [cs:num_file_data], ax

       mov ah, 4Eh
       mov cx, 00
       mov dx, cs
       mov ds, dx
       mov dx, offset file_mask
       int 21h
       cmp ax, 0
       jne Not_da_on_disk

       ; �� ��᪥ �� �� ���� ࠡ�稥 䠩��
       mov ah, 2Fh
       int 21h
       add bx, 30 ; es:bx -> ��� ��ࢮ�� ���������� 䠩��

       ; ᪮���㥬 ��� ���������� 䠩��
       mov di, offset file_data
       mov cx, 3
    Copy_file_name_to__:
       mov eax, dword ptr [es:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_file_name_to__

Serch_last_file:

       call CHANGE_FILE

       ; ���뢠�� 䠩� ������
       mov  ax, 3d02h
       mov  dx, offset cs:file_data
       int 21h
       jc Detected_last_file

       mov  word ptr [cs:data_descriptor], ax

      ; ����뢠�� 䠩� ������
       mov   ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h
       jmp Serch_last_file

Detected_last_file:

       ; ᪮���㥬 ��� ���������� 䠩��
       mov bx, offset file_data
       mov di, offset Last_serched_file
       mov cx, 3
    Copy_file_name_to_Last_serched:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_file_name_to_Last_serched

       ; ��୥� ��� 䠩�� ����
       mov bx, offset BuckUp_file_name
       mov di, offset file_data
       mov cx, 3
    Copy_BuckUp_to_file_name_1:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_BuckUp_to_file_name_1
       ; ��୥� ��� 䠩�� ����

       call CHANGE_FILE

       ; �ࠢ��� ����� 䠩��� ᫥���饣� �� ��᫥���� ��������
       ; � ᫥���饣� �� ������
       mov bx, (offset Last_serched_file) +3
       mov di, (offset file_data) + 3

       mov eax, dword ptr [cs:bx]
       cmp dword ptr [cs:di], eax
       jne Zayavl_not_correct
       jmp Not_da_on_disk

Zayavl_not_correct:

       ; ��୥� ��� 䠩�� ���� �� Last_serch
       mov bx, offset Last_serched_file
       mov di, offset file_data
       mov cx, 3
    Copy_Last_serch_to_file_name:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_Last_serch_to_file_name
       jmp End_Check_last_file

Not_da_on_disk:

       ; ��୥� ��� 䠩�� ���� �� BackUp
       mov bx, offset BuckUp_file_name
       mov di, offset file_data
       mov cx, 3
    Copy_BuckUp_to_file_name:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_BuckUp_to_file_name
       ; ��୥� ��� 䠩�� ����

End_Check_last_file:
       popad
       ret

 BuckUp_file_name db 32 dup (0)
 Last_serched_file db 32 dup (0)
 file_mask db '*.da',0,0
Check_last_file endp


InitProg PROC near
       push ds

       ; ����樠������ ���ᨢ� 㪠��⥫�� �� ����
       mov  ax, A_DATA_0
       mov  word ptr [cs:buff+2], ax
       mov  ax, offset buf0
       mov  word ptr [cs:buff], ax

       mov  ax, A_DATA_1
       mov  word ptr [cs:buff+6], ax
       mov  ax, offset buf1
       mov  word ptr [cs:buff+4], ax

       mov  ax, A_DATA_2
       mov  word ptr [cs:buff+10], ax
       mov  ax, offset buf2
       mov  word ptr [cs:buff+8], ax

       mov  ax, A_DATA_3
       mov  word ptr [cs:buff+14], ax
       mov  ax, offset buf3
       mov  word ptr [cs:buff+12], ax

       mov  ax, A_DATA_4
       mov  word ptr [cs:buff+18], ax
       mov  ax, offset buf4
       mov  word ptr [cs:buff+16], ax

       mov  ax, A_DATA_5
       mov  word ptr [cs:buff+22], ax
       mov  ax, offset buf5
       mov  word ptr [cs:buff+20], ax

       mov  ax, A_DATA_6
       mov  word ptr [cs:buff+26], ax
       mov  ax, offset buf6
       mov  word ptr [cs:buff+24], ax

       mov  ax, A_DATA_7
       mov  word ptr [cs:buff+30], ax
       mov  ax, offset buf7
       mov  word ptr [cs:buff+28], ax

       mov  ax, A_DATA_8
       mov  word ptr [cs:buff+34], ax
       mov  ax, offset buf8
       mov  word ptr [cs:buff+32], ax

       mov  ax, A_DATA_9
       mov  word ptr [cs:buff+38], ax
       mov  ax, offset buf9
       mov  word ptr [cs:buff+36], ax

       mov  ax, A_DATA_10
       mov  word ptr [cs:buff+42], ax
       mov  ax, offset buf10
       mov  word ptr [cs:buff+40], ax

       mov  ax, A_DATA_11
       mov  word ptr [cs:buff+46], ax
       mov  ax, offset buf11
       mov  word ptr [cs:buff+44], ax

       mov word ptr [cs:MAX_BUF], 12

       mov  ax, offset [cs:file_data]   ; ���⠢�� 㪠��⥫� �� �����
       add  ax, 2                       ; 䠩��
       mov  word ptr [cs:num_file_data], ax

       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov al, byte ptr [cs:bx]
       mov byte ptr [cs:last_wrk_dsk], al

       ; ���뢠�� 䠩� ���䨣��樨, �᫨ �� ����
       include load_cfg.asm

       mov  bp, word ptr [cs:read_buf] ; ����㧨� ���� ⥪�饩 �����
       shl  bp, 2                      ; ������ � ����
       mov  ax, word ptr [cs:buff+bp]
       mov  word ptr [cs:current], ax
       add  bp, 2
       mov  ax, word ptr [cs:buff+bp]
       mov  word ptr [cs:current+2], ax

       mov  ax, word ptr [cs:reserved]
       mov  bp, DIMENSION_SIZE
       mul  bp
       add  word ptr [cs:current], ax

        ; ����稬 ���� ��� �� ᯨ᪠
       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       sub dl, 'a'  ;dl =  ����� �㦭��� ��᪠

       mov ah, 0Eh
       int 21h

open_wrk_file:
       mov  ax, cs
       mov  ds, ax

       call Check_last_file

       ; ���뢠�� 䠩� ������
       mov  ax, 3d02h
       mov  dx, offset cs:file_data
       int 21h
       mov  word ptr [cs:data_descriptor], ax
       jnc Not_create_file

       mov  ax, 3c00h        ; �㭪�� DOS ᮧ����� 䠩��
       mov  cx, 00         ; ����� 䠩�
       mov  dx, offset cs:file_data  ;
       int  21h
       jc   error1
       mov  word ptr [cs:data_descriptor], ax
       jmp Not_mov_point_to_end

Not_create_file:
      ; ��६��⨬ 㪠��⥫� ����� �� �����
       mov  ax, 4202h
       mov  bx, word ptr [cs:data_descriptor]
       xor  cx, cx
       xor  dx, dx
       int  21h

Not_mov_point_to_end:
       mov  al, 0 ; ��ଠ��� ��室
       pop  ds
       ret

error1: ; ...
error2: ; ...
error3: ; ...
Crash:
       mov  al, 1  ; ��室 � �訡���
       pop  ds
       ret
InitProg ENDP


Write_flash PROC near  ; ds:dx = 㪠��⥫� �� �����뢠��� �����
       push cx
       push ds

       mov di, dx

       ; �஢�ਬ ���稪 ������ � 䠩��
       mov  eax, dword ptr [ds:di+6]
       cmp  eax, 0
       je   close_write_flash

       ; ��襬 � 䠩� ��������� �����
       mov  bx, word ptr [cs:data_descriptor]
       mov  cx, 16
       mov  dx, di
       mov  ax, 4000h
       int  21h
       jc   error22

       ; ��襬 � 䠩� ���� � ����묨
       push ds
       mov  bx, word ptr [cs:data_descriptor]
       xor  cx, cx
       mov  cl, byte ptr [ds:di+10]
       mov  ax, DIMENSION_SIZE
       mul  cx
       mov  cx, ax
       mov  dx, di
       add  dx, 16
       mov  ax, 4000h
       int  21h
       pop  ds
       jc   error22

close_write_flash:
       mov ax, 0
       pop ds
       pop  cx
       ret

error22: ; ...
error32: ; ...
Crash2:
       mov  ax, 1  ; ��室 � �訡���
       pop ds
       pop  cx
       ret

pred_track  dd 0
Write_flash ENDP


Write_data PROC near
       push cx

       mov  bp, word ptr [cs:write_buf]  ; �஢�ਬ ��⮢����� ����
       cmp  byte ptr [cs:beasy_buf+bp], 1
       jne  close_write  ; �᫨ ���� �� �� ��⮢, � ��室��

         ; ����㧨� 㪠��⥫� �� �����
         mov  bp, word ptr [cs:write_buf]
         shl  bp, 2
         add  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  ds, ax
         sub  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  dx, ax
         sub  dx, 16

       ; ��襬 �� flash
       call Write_flash  ; ds:dx = 㪠��⥫� �� �����뢠��� �����

Go_to_next_buf:
       mov  bp, word ptr [cs:write_buf]
       mov  byte ptr [cs:beasy_buf+bp], 0  ; ���� ᭮�� ���⮩

       inc word ptr [cs:write_buf]
       mov ax, word ptr [cs:MAX_BUF]
       cmp word ptr [cs:write_buf], ax
       jne num_buf_normal
       mov word ptr [cs:write_buf], 0

num_buf_normal:

close_write:
       pop  cx
       ret
Write_data ENDP



    ; ********************************************************
    ; *******  ��砫� �᭮���� �ணࠬ�� (�窠 �室�) *******
    ; ********************************************************
Scan proc far
       push ds
       xor ax, ax
       push ax

Begin:
       mov ax, cs
       mov ds, ax

       call InitProg
       cmp  al, 0
       jne   Exit

       call Create_log_file

Set_Timer:
       push es               ; ��࠭�� ���� ����� ���뢠���:
       mov  al, TIMER_INT
       mov  ah, 35h
       int  21h
       mov  [cs:timerSeg], es
       mov  [cs:timerOfs], bx
       pop  es

       push ds             ; �����塞 ���뢠��� �� ᢮�
       mov  al, TIMER_INT
       mov  ah, 25h
       push cs
       pop  ds
       mov  dx, offset Timer
       int  21h
       pop  ds

       cli
           ; 㢥��� ����� ࠡ��� ⠩��� � 18,2 �� 100 ��
       mov al, 3ch   ; �ࠢ���饥 ᫮��, �����饥 ०�� 2,
                     ; ������ ������, ������ ����訩/���訩 ����
       out 43h, al   ; � �ࠢ���騩 ॣ���� �����奬� 8253

       mov ax, TIMER_CLOKC
       out 40h, al   ; ����訩 ���� ���稪�
       mov al, ah
       out 40h, al    ; ���訩 ���� ���稪�
       sti
; �����稫� ����ன�� ⠩���

Set_Odometr:
       call  init_ADC

       push es               ; ��࠭�� ���� ����� ���뢠���:
       mov  al, ODOMETR_INT
       mov  ah, 35h
       int  21h
       mov  [cs:odometrSeg], es
       mov  [cs:odometrOfs], bx
       pop  es

       push ds             ; �����塞 ���뢠��� �� ᢮�
       mov  al, ODOMETR_INT
       mov  ah, 25h
       push cs
       pop  ds
       mov  dx, offset Odometr
       int  21h
       pop  ds
; �����稫� ����ன�� �������

; ���p�訬 IRQ5
       in  al, 21h
       and al, 0DFh
       out 21h, al

    ; �������� ���� �� �����୮� ����
       mov dx, 0e5h
       in  al, dx
       or al, 080h
       out dx, al

      ; �������� ᢥ⮤��� "��⮢�����" � ��⠢�塞 ����� "��ࠢ�����"
       mov al, 03
       mov dx, 0e0h
       out dx, al
      ; ������ ᢥ⮤��� "��⮢�����"

MAIN_CIKLE:   ; ��砫� ࠡ�祣� 横�� �ணࠬ�� Scan

       call keyboard_ready  ; �஢��塞 �� ����� �� ������ �� ���������
       jnz Exit

       pushad
       push ds

       mov  ax, cs
       mov  ds, ax

       ; �஢��塞 ᪮�쪮 㦥 �⮨�, �᫨ ����� 10 ᥪ ����. 䠩�
       cli
       mov eax, dword ptr [cs:time]         ; ᪮�쪮 �p����� ��諮
       sub eax, dword ptr [cs:last_time]    ; c ��᫥����� ����p���� ?
       sti
       cmp eax, 1000
       jb Not_stop_bort

      ; ����뢠�� 䠩� ������
       mov  ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h
      ; ����뫨 䠩� ������

      ; ᮧ����� 䠩�� ���䨣��樨
       include save_cfg.asm

       call Read_track

       call Get_PIC_track

       mov eax, dword ptr [cs:track] ;  ��������� ����ﭨ�
       mov dword ptr [cs:Stop_track], eax

       mov ah, 4      ; ��� ���� ��ﭪ�
       int 1Ah
       mov word ptr [cs:Beg_date_stop], cx
       mov word ptr [cs:Beg_date_stop+2], dx

       mov ah, 2      ; �६� ���� ��ﭪ�
       int 1Ah
       mov word ptr [cs:Beg_time_stop], cx
       mov word ptr [cs:Beg_time_stop+2], dx

       pop ds
       popad

       ; ���� � 横��, ����� ������
Wait_go_bort:
       mov eax, dword ptr [cs:time]         ; ᪮�쪮 �p����� ��諮
       sub eax, dword ptr [cs:last_time]    ; c ��᫥����� ����p���� ?
       cmp eax, 1000
       jb Go_go_go

       sub eax, 1000
       mov dword ptr [cs:Stop_time], eax

       jmp Wait_go_bort

    ;   jmp Exit

Go_go_go:
       pushad
       push ds

       mov  ax, cs
       mov  ds, ax

       ; ���뢠�� 䠩� � ���室�� � ��� �����
       mov  ax, 3d02h     ; �㭪�� DOS ������ 䠩��
       mov  dx, offset file_data
       int  21h
       mov  word ptr [cs:data_descriptor], ax

       ; ��६��⨬ 㪠��⥫� ����� �� �����
       mov  ax, 4202h
       mov  bx, word ptr [cs:data_descriptor]
       xor  cx, cx
       xor  dx, dx
       int  21h
       ; ���뫨 䠩� � ���諨 � ��� �����

       call Save_stop_spead

Not_stop_bort:
       pop ds
       popad

       call Write_data ; ������ ������

       jmp  MAIN_CIKLE   ; ����� ࠡ�祣� 横�� �ணࠬ��

Exit:
       ;cli
       ; ��୥� ������� �� ����
       push ds             ; �����塞 ���뢠��� �� ��஥
       mov  al, ODOMETR_INT
       mov  ah, 25h
       mov  dx, word ptr [cs:odometrSeg]
       mov  ds, dx
       mov  dx, word ptr [cs:odometrOfs]
       int  21h
       pop ds

       ; ��୥� ⠩��� �� ����
       push ds             ; �����塞 ���뢠��� �� ��஥
       mov  al, TIMER_INT
       mov  ah, 25h
       mov  dx, word ptr [cs:timerSeg]
       mov  ds, dx
       mov  dx, word ptr [cs:timerOfs]
       int  21h
       pop  ds

       cli
           ; ����� ࠡ��� ⠩��� �� 18,2 ��
       mov al, 3ch   ; �ࠢ���饥 ᫮��, �����饥 ०�� 2,
                     ; ������ ������, ������ ����訩/���訩 ����
       out 43h, al   ; � �ࠢ���騩 ॣ���� �����奬� 8253

       mov ax, 0ffffh;  ���ᯥ稢��� ࠡ��� ⠩��� 18,2 ��
       out 40h, al   ; ����訩 ���� ���稪�
       mov al, ah
       out 40h, al    ; ���訩 ���� ���稪�
       sti

      ; ����뢠�� 䠩� ������
       push ds

       mov  ax, cs
       mov  ds, ax

       mov  ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h
       pop ds
      ; ����뫨 䠩� ������

    ; ᮧ����� 䠩�� ���䨣��樨
       include save_cfg.asm

    ; ��襬 � log-䠩� �� ��� ��������
       call Save_not_pressure

       call keyboard_ready  ; �஢��塞 �� ����� �� ������ �� ���������
       jz Wait_pressure
       ret

Wait_pressure:
       xor bx, bx
       mov cx, 3
Detect_pressure1:
       mov  dx, BASE_PROTOTIP_ODOM+8h ; �஢�ઠ ���稪� ��������
       in   al, dx
       not  al
       and  al, 01h
       add  bl, al
       LOOP Detect_pressure1
       cmp  bl, 0
       je  Wait_pressure  ; �᫨ ��� ��������, � ����

       ; �᫨ �������� ������ � �த������ ����७��
       jmp Begin

   ; ������� ������
BLOCK_IN_FILE   DW    100   ; ������⢮ 2-� ���஢�� ������ � 䠩��

cfg_descriptor  DW    0
file_cfg        DB   'c:\scan.sav',0,0,0,0,0,0,0,0
serch_cfg_file  dw    0


data_descriptor DW    0
last_wrk_dsk    db    0
                db    ':'
file_data       DB   'tm00000.da',0,0,0,0,0,0,0,0
num_file_data   DW    0      ; 㪠��⥫� �� ����� 䠩�� � �����

log_descriptor  DW    0
file_log        DB   'c:\scan.log',0,0,0,0,0,0,0,0
end_line     DB    0Dh, 0Ah

write_buf       DW    0
write_count     DW    0
len_write       DW    0
len_read        DW    0

Pressure_flag    DB   1
Pressure_detect  DB   0
Pred_pres_detect DB   3

   ; १�ࢨ�㥬 ���� ��� ����� ��ࠬ��஢ ��⠭����
Stop_time     DD  0  ; �६� ��ﭪ�
Stop_track    DD  0  ; �ன���� � � ������� ��⠭����
Beg_date_stop DD  0  ; ��� ��砫� ��ﭨ
Beg_time_stop DD  0  ; �६� ��砫� ��ﭪ�


 timerOfs    DW   0  ; ��१�ࢨ஢��� ��� ����
 timerSeg    DW   0  ; ����� ⠩��୮�� ���뢠���

 odometrOfs  DW   0  ; ��१�ࢨ஢��� ��� ����
 odometrSeg  DW   0  ; ����� ���뢠��� �������

Scan ENDP


