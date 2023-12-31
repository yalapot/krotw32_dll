itoa32  PROC near
      ; eax   - �᫮ ��� �������樨 (����������� ��� �����������)
      ; ds:di - 㪠��⥫� �� १��������� ��ப� (��易⥫쭮
      ;         १�ࢨ஢��� 10 ᨬ�����, � ��� ����蠥��� १���� �
      ;         ��ࠢ�������� ��ࠢ�)
      ; ebx   - ���� �।�⠢����� �᫠ (10 - �����筠�)

      push edx
      push eax
      push ebx
      push ecx
      push di

      mov cx, 10 ; ������塞 �ਣ�⮢������ ��ப� �஡�����
Put_space:
      mov byte ptr [ds:di], ' '
      inc di
      LOOP Put_space

Convert_itoa:
      xor edx, edx
      div ebx
      add dx, '0'
      mov byte ptr [ds:di], dl
      dec di
      cmp eax, 0
      ja Convert_itoa ; �᫨ ���

itoa32_exit:
      pop di
      pop ecx
      pop ebx
      pop eax
      pop edx
      ret
itoa32  ENDP

itoa_16 PROC near ; ax=�᫮; es:di = 㪠��⥫� �� ��ப�
      pusha

      xor bp, bp ; 䫠� ������饣� ��� ���砫�
      xor dx, dx

First_num:
      mov dl, ah
      shr dl, 4
      add bp, dx
      cmp bp, 0

      jne Non_zerro_1
      mov byte ptr [es:di], ' '
      inc di
      jmp Second_num
Non_zerro_1:
      cmp dl, 9
      ja Non_num_1  ; �᫨ ���
      add dl, '0'
      mov byte ptr [es:di], dl
      inc di
      jmp Second_num
Non_num_1: ; �� ���, �.�. �㪢� (a, b, c, d, e ��� f)
      add dl, 'a'-0ah
      mov byte ptr [es:di], dl
      inc di

Second_num:
      mov dl, ah
      and dl, 0Fh
      add bp, dx
      cmp bp, 0

      jne Non_zerro_2
      mov byte ptr [es:di], ' '
      inc di
      jmp Third_num
Non_zerro_2:
      cmp dl, 9
      ja Non_num_2  ; �᫨ ���
      add dl, '0'
      mov byte ptr [es:di], dl
      inc di
      jmp Third_num
Non_num_2: ; �� ���, �.�. �㪢� (a, b, c, d, e ��� f)
      add dl, 'a'-0ah
      mov byte ptr [es:di], dl
      inc di

Third_num:
      mov dl, al
      shr dl, 4
      add bp, dx
      cmp bp, 0

      jne Non_zerro_3
      mov byte ptr [es:di], ' '
      inc di
      jmp Fourth_num
Non_zerro_3:
      cmp dl, 9
      ja Non_num_3  ; �᫨ ���
      add dl, '0'
      mov byte ptr [es:di], dl
      inc di
      jmp Fourth_num
Non_num_3: ; �� ���, �.�. �㪢� (a, b, c, d, e ��� f)
      add dl, 'a'-0ah
      mov byte ptr [es:di], dl
      inc di

Fourth_num:
      mov dl, al
      and dl, 0Fh
      cmp dl, 9
      ja Non_num_4  ; �᫨ ���
      add dl, '0'
      mov byte ptr [es:di], dl
      jmp Complete_itoa
Non_num_4: ; �� ���, �.�. �㪢� (a, b, c, d, e ��� f)
      add dl, 'a'-0ah
      mov byte ptr [es:di], dl

Complete_itoa:

      popa
      ret
itoa_16 ENDP


get_date PROC near
     pusha
     ; �⠥� ���� �� �ᮢ ॠ�쭮�� �६���
     mov ah, 4h
     int 1Ah
  ; ��襬 ���� �����
     mov al, dl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string], al ; ����� ���
     mov al, dl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+1], al ; ������ ���
  ; ��襬 �����
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+3], al ; ����� ���
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+4], al ; ������ ���
  ; ��襬 ���
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+6], al ; ����� ���
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+7], al ; ������ ���
  ; ��襬 ���
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+8], al ; ����� ���
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+9], al ; ������ ���

     mov  ax, 4000h
     mov  bx, word ptr [cs:log_descriptor]
     mov  cx, 12
     mov  dx, offset cs:date_string
     int  21h
     popa
     ret

date_string     DB    0,0,'/',0,0,'/',0,0,0,0,', '
save_date_message  DB  '��� ',0
get_date ENDP

get_time PROC near
     pusha
     ; �⠥� �६� �� �ᮢ ॠ�쭮�� �६���
     mov ah, 2h
     int 1Ah
  ; ��襬 ���
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string], al ; ����� ���
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+1], al ; ������ ���
  ; ��襬 ������
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+3], al ; ����� ���
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+4], al ; ������ ���
  ; ��襬 ᥪ㭤�
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+6], al ; ����� ���
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+7], al ; ������ ���

     mov  ax, 4000h
     mov  bx, word ptr [cs:log_descriptor]
     mov  cx, 10
     mov  dx, offset cs:time_string
     int  21h

     popa
     ret

time_string     DB    0,0,':',0,0,':',0,0,'   '
save_time_message  DB  '�६� ',0
get_time ENDP

print_date_real PROC near       ; dl - ���� �����
     pusha                 ; dh - �����
  ; ��襬 ���� �����      ; ch - ���
     mov al, dl            ; cl - ���
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string], al ; ����� ���
     mov al, dl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+1], al ; ������ ���
  ; ��襬 �����
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+3], al ; ����� ���
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+4], al ; ������ ���
  ; ��襬 ���
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+6], al ; ����� ���
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+7], al ; ������ ���
  ; ��襬 ���
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+8], al ; ����� ���
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+9], al ; ������ ���

     mov  ax, 4000h
     mov  bx, word ptr [cs:log_descriptor]
     mov  cx, 12
     mov  dx, offset cs:date_string
     int  21h
     popa
     ret

print_date_real ENDP

print_time_real PROC near            ; ch - ���
     pusha                      ; cl - ������
  ; ��襬 ���                  ; dh - ᥪ㭤�
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string], al ; ����� ���
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+1], al ; ������ ���
  ; ��襬 ������
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+3], al ; ����� ���
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+4], al ; ������ ���
  ; ��襬 ᥪ㭤�
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+6], al ; ����� ���
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+7], al ; ������ ���

     mov  ax, 4000h
     mov  bx, word ptr [cs:log_descriptor]
     mov  cx, 10
     mov  dx, offset cs:time_string
     int  21h

     popa
     ret

print_time_real ENDP

Create_log_file PROC near
       push ds
       pusha

  ; ���뢠�� log-䠩�, �᫨ �� 㦥 �������
       mov  ax, cs  ; ��஥� �������騩 䠩�
       mov  ds, ax
       mov  ah, 3dh        ; �㭪�� DOS ������ 䠩��
       mov  al, 02         ; ����� 䠩�
       mov  dx, offset cs:file_log  ;
       int  21h
       jc   No_log_file
       mov  word ptr [cs:log_descriptor], ax

       ; ��६��⨬ 㪠��⥫� ����� �� �����
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h

       jmp Write_about_begin

No_log_file:
  ;  ᮧ����� log-䠩��
       mov  ax, 3c00h      ; �㭪�� DOS ᮧ����� 䠩��
       mov  cx, 00         ; ����� 䠩�
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; ��襬 � 䠩� ��������� ᮧ������� 䠩�� 䠩��
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 53 ; 53 ᨬ�����
       mov  dx, offset cs:Head_log
       int  21h

Write_about_begin:
       call get_date  ; ��襬 � log-䠩� ⥪���� ���� �� �ᮢ ॠ�쭮�� �६���
       call get_time  ; ��襬 � log-䠩� ⥪�饥 �६� �� �ᮢ ॠ�쭮�� �६���

       ; ��襬 � log-䠩� ᮮ�饭�� � �室� � �ணࠬ��
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 39  ; 39 ᨬ�����
       mov  dx, offset cs:Begin_mesage
       int  21h

       ; ����뢠�� log-䠩�
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; �����稫� ᮧ������ log-䠩�

Close_Create_log_file:

       popa
       pop  ds
       ret

Head_log       DB   '     ��⮪�� �������� �� ���� ᭠�鸞 ����-700 '
               DB   CR, LF, CR, LF,0
Begin_mesage   DB   '����� ���⮢�� �ணࠬ�� ����-700  '
               DB   CR, LF, CR, LF,0
Create_log_file ENDP

Print_track PROC near     ; eax <= ������  � ᠭ⨬����
       pushad
       push ds
       push eax

       mov ax, cs
       mov ds, ax

       ; ��襬 � 䠩� ᮮ�饭�� � �ன������ ���
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 10  ; 10 ᨬ�����
       mov  dx, offset cs:Track_length_message
       int  21h

        ; ��������㥬 ������ ᠭ⨬��஢ � ��ப�
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       pop eax
       xor edx, edx
       mov ecx, 100
       div ecx
       xchg edx, eax
       call itoa32
       mov bx, word ptr [cs:tmp_str+9]
       mov word ptr [cs:Track_length_sm], bx

        ; ��������㥬 ������ ���஢ � ��ப�
       xchg edx, eax
       xor edx, edx
       cmp eax, 0
       je Print_sm
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       mov ecx, 1000
       div ecx
       xchg edx, eax
       call itoa32
       mov ebx, dword ptr [cs:tmp_str+7]
       mov dword ptr [cs:Track_length_m], ebx

        ; ��������㥬 ������ �������஢ � ��ப�
       xchg edx, eax
       xor edx, edx
       cmp eax, 0
       je Print_m
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       call itoa32
       mov ebx, dword ptr [cs:tmp_str+7]
       mov dword ptr [cs:Track_length_km], ebx

       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 21  ; 21 ᨬ�����
       mov  dx, offset cs:Track_length_km
       int  21h
       jmp  End_print_length

Print_m:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 14  ; 14 ᨬ�����
       mov  dx, offset cs:Track_length_m
       int  21h
       jmp  End_print_length

Print_sm:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 7  ; 7 ᨬ�����
       mov  dx, offset cs:Track_length_sm
       int  21h

End_print_length:

       ;  �뢥��� � log-䠩� ���� PIC-������.
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 63
       mov  dx, offset cs:Pic_track
       int  21h

       pop ds
       popad
       ret

 Pic_track  db  ' ���:           ; I ��.:           ; II ��.:           .     ', CR, LF

Track_length_message  DB   ' �ன���� '
Track_length_km       db   '     ��'
Track_length_m        db   '     � '
Track_length_sm       db   '   �'
                      DB   CR, LF, 0

tmp_str  db 60 dup (' ')
         db  CR, LF, '$'

Print_track ENDP

Print_time PROC near  ; eax=�६� � ᥪ㭤��
     pushad

        ; ��������㥬 ᥪ㭤� � ��ப�
       xor edx, edx
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       mov ecx, 60
       div ecx
       xchg edx, eax
       call itoa32
       mov bx, word ptr [cs:tmp_str+9]
       mov word ptr [cs:Time_stop_sec], bx

        ; ��������㥬 ������ � ��ப�
       xchg edx, eax
       xor edx, edx
       cmp eax, 0
       je Print_sek
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       mov ecx, 60
       div ecx
       xchg edx, eax
       call itoa32
       mov bx, word ptr [cs:tmp_str+9]
       mov word ptr [cs:Time_stop_min], bx

        ; ��������㥬 ��� � ��ப�
       xchg edx, eax
       xor edx, edx
       cmp eax, 0
       je Print_min
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       call itoa32
       mov ebx, dword ptr [cs:tmp_str+7]
       mov dword ptr [cs:Time_stop_haur], ebx

       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 25  ; 27 ᨬ�����
       mov  dx, offset cs:Time_stop_haur
       int  21h
       jmp  End_print_time

Print_min:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 16  ; 18 ᨬ�����
       mov  dx, offset cs:Time_stop_min
       int  21h
       jmp  End_print_time

Print_sek:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 9  ; 9 ᨬ�����
       mov  dx, offset cs:Time_stop_sec
       int  21h

End_print_time:
       popad
       ret

Time_stop_haur      db   '     �� '
Time_stop_min       db   '   ��� '
Time_stop_sec       db   '   ᥪ '
                    db   CR, LF,0
Print_time ENDP

Print_speed PROC near

        ; ��������㥬 ᪮���� � ��ப�
       xor edx, edx
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       call itoa32
       mov bx, word ptr [cs:tmp_str+9]
       mov word ptr [cs:speed_metr_sec+5], bx
       mov ebx, dword ptr [cs:tmp_str+5]
       mov dword ptr [cs:speed_metr_sec], ebx

       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 15  ; 15 ᨬ�����
       mov  dx, offset cs:speed_metr_sec
       int  21h
       ret

speed_metr_sec     db   '    .    �/� '
                   db   CR, LF,0,0,0
Print_speed ENDP

Save_not_pressure PROC near
       push ds
       pusha

       cmp word ptr [cs:Call_Save_not_pressure_counter], 21
       jae Close_Create_log_file

       inc word ptr [cs:Call_Save_not_pressure_counter]

  ; ���뢠�� log-䠩�
       mov  ax, cs  ; ��஥� �������騩 䠩�
       mov  ds, ax
       mov  ax, 3d02h        ; �㭪�� DOS ������ 䠩��
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; ��६��⨬ 㪠��⥫� ����� �� �����
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h
;       jc   error11

       call get_date  ; ��襬 � log-䠩� ⥪���� ���� �� �ᮢ ॠ�쭮�� �६���
       call get_time  ; ��襬 � log-䠩� ⥪�饥 �६� �� �ᮢ ॠ�쭮�� �६���

       ; ��襬 � 䠩� ᮮ�饭�� �� �⪫�祭�� ��������
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 39 ; 39 ᨬ�����
       mov  dx, offset cs:Not_pressure_message
       int  21h

       ; ��襬 � 䠩� ᮮ�饭�� � �६��� ��������
       push eax
       push edx
       push ecx
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 16  ; 16 ᨬ�����
       mov  dx, offset cs:Time_go_message
       int  21h
       mov eax, dword ptr [cs:time]
       xor edx, edx
       mov ecx, 100
       inc ecx
       div ecx
       mov dword ptr [cs:Time_go_sec], eax
       call Print_time
       pop ecx
       pop edx
       pop eax
       ; �����稫� ����� � 䠩� ᮮ�饭�� � �६��� ��������

       ; ��襬 � 䠩� ᮮ�饭�� � �।��� ᪮���
       push eax
       push edx
       push ecx
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 19  ; 16 ᨬ�����
       mov  dx, offset cs:Speed_go_message
       int  21h
       mov eax, dword ptr [cs:track]
       xor edx, edx
       mov ecx, dword ptr [cs:Time_go_sec]
       inc ecx
       div ecx
       call Print_speed
       pop ecx
       pop edx
       pop eax
       ; �����稫� ����� � 䠩� ᮮ�饭�� � �।��� ᪮���

       call Get_PIC_track
       mov eax, dword ptr [cs:track]
       call Print_track

       ; ���室 �� ����� ��ப�
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 ᨬ����
       mov  dx, offset cs:New_Line
       int  21h

       ; ����뢠�� log-䠩�
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; �����稫� ����� � log-䠩�

Close_Save_not_pressure:
       popa
       pop  ds
       ret

Not_pressure_message  DB   '�ࠡ�⠫ ���稪 �⪫�祭�� ��������  '
                      DB   CR, LF,0,0,0
Time_go_message       DB   ' �६� ��������    '
Speed_go_message      DB   ' �।��� ᪮����    '
time_go_sec           DD   1

Call_Save_not_pressure_counter dw 0

Save_not_pressure ENDP

Save_yes_pressure PROC near
       push ds
       pusha

       cmp word ptr [cs:Call_Save_not_pressure_counter], 21
       jae Close_Save_Yes_pressure

  ; ���뢠�� log-䠩�
       mov  ax, cs  ; ��஥� �������騩 䠩�
       mov  ds, ax
       mov  ah, 3dh        ; �㭪�� DOS ������ 䠩��
       mov  al, 02         ; ����� 䠩�
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; ��६��⨬ 㪠��⥫� ����� �� �����
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h
;       jc   error11

       call get_date  ; ��襬 � log-䠩� ⥪���� ���� �� �ᮢ ॠ�쭮�� �६���
       call get_time  ; ��襬 � log-䠩� ⥪�饥 �६� �� �ᮢ ॠ�쭮�� �६���

       ; ��襬 � 䠩� ᮮ�饭�� �� �⪫�祭�� ��������
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 39 ; 39 ᨬ�����
       mov  dx, offset cs:Yes_pressure_message
       int  21h

       call Get_PIC_track
       mov eax, dword ptr [cs:track]
       call Print_track

       ; ���室 �� ����� ��ப�
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 ᨬ����
       mov  dx, offset cs:New_Line
       int  21h

       ; ����뢠�� log-䠩�
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; �����稫� ����� � log-䠩�

Close_Save_Yes_pressure:
       popa
       pop  ds
       ret

Yes_pressure_message  DB   '�ࠡ�⠫ ���稪 ����祭�� ��������   '
                      DB   CR, LF,0,0,0

Save_yes_pressure ENDP

Save_stop_spead PROC near
       push ds
       pusha

  ; ���뢠�� log-䠩�
       mov  ax, cs  ; ��஥� �������騩 䠩�
       mov  ds, ax
       mov  ah, 3dh        ; �㭪�� DOS ������ 䠩��
       mov  al, 02         ; ����� 䠩�
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; ��६��⨬ 㪠��⥫� ����� �� �����
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h
;       jc   error11

       ; ��襬 � 䠩� ᮮ�饭�� �� ��⠭���� ᭠�鸞
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 21 ; 21 ᨬ�����
       mov  dx, offset cs:Stop_spead_message
       int  21h

       ; ��襬 � 䠩� ᮮ�饭�� � �६��� ��ﭪ�
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 15 ; 15 ᨬ�����
       mov  dx, offset cs:Stoping_time_message
       int  21h

       mov eax, dword ptr[cs:Stop_time]
       xor edx, edx
       mov ebx, 100
       div ebx
       call Print_time

       ; ��襬 � 䠩� ᮮ�饭�� � ��砫� ��⠭���� ᭠�鸞
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 19  ; 19 ᨬ�����
       mov  dx, offset cs:Time_stop_message
       int  21h

       mov cx, word ptr [cs:Beg_date_stop]
       mov dx, word ptr [cs:Beg_date_stop+2]
       call Print_date_real

       mov cx, word ptr [cs:Beg_time_stop]
       mov dx, word ptr [cs:Beg_time_stop+2]
       call Print_time_real

       ; ���室 �� ����� ��ப�
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 ᨬ����
       mov  dx, offset cs:New_Line
       int  21h

       mov eax, dword ptr [cs:Stop_track]
       call Print_track

       ; ���室 �� ����� ��ப�
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 ᨬ����
       mov  dx, offset cs:New_Line
       int  21h

       ; ����뢠�� log-䠩�
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; �����稫� ����� � log-䠩�

Close_Save_stop_spead:
       popa
       pop  ds
       ret

Stop_spead_message  DB   '��⠭���� ᭠�鸞  '
                    DB   CR, LF,0,0,0
Stoping_time_message  DB  ' �६� ��ﭪ�  '
                      DB   CR, LF,0,0,0
Time_stop_message   DB   ' ��砫�  ��ﭪ�    '
New_Line            DB   CR, LF,0,0,0
Save_stop_spead ENDP

