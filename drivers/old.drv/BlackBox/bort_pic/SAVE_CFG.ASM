  ; ��稭��� ᮧ����� 䠩�� ���䨣��樨
       push ds
       mov  ax, cs
       mov  ds, ax

       ; ���뢠�� 䠩� ���䨣��樨
       mov  ax, 3c00h        ; �㭪�� DOS ᮧ����� 䠩��
       mov  cx, 00         ; ����� 䠩�
       mov  dx, offset cs:file_cfg  ;
       int  21h
;       jc   error11
       mov  word ptr [cs:cfg_descriptor], ax

       ; ��襬 � 䠩� �६�
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6
       mov  dx, offset cs:time
       int  21h
;       jc   error21
;       cmp  ax, 6h
;       jne  error31

       ; ��襬 � 䠩� ��᫥���� ���祭�� ���������
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:old_pos
       int  21h
;       jc   error21
;       cmp  ax, 1
;       jne  error31

 ; ��襬 � 䠩� �ன������ ����ﭨ�, ���-�� ���஢, ���-�� ������ � ����
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6+2+2
       mov  dx, offset cs:track
       int  21h
;       jc   error21
;       cmp  ax, 6+2+2
;       jne  error31

 ; ��襬 � 䠩� 䫠�� ������� ���஢
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 20
       mov  dx, offset cs:beasy_buf
       int  21h
 ;      jc   error21
  ;     cmp  ax, 20
   ;    jne  error31

 ; ��襬 � 䠩� ����� ���� �⥭��, ���稪� ������ � ����ᥩ
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2+2
       mov  dx, offset cs:read_buf
       int  21h
;       jc   error21
 ;      cmp  ax, 2+2+2
  ;     jne  error31

 ; ��襬 � 䠩� �६� � ����ﭨ� �� ��᫥���� ����७��
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4+4
       mov  dx, offset cs:last_time
       int  21h
;       jc   error21
 ;      cmp  ax, 4+4
  ;     jne  error31

       ; ��襬 � 䠩� ��� ⥪�饣� 䠩�� � ����묨
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 16
       mov  dx, offset cs:file_data
       int  21h
;       jc   error21
 ;      cmp  ax, 10h
  ;     jne  error31

 ; ��襬 � 䠩� ����� ���� ����� � ���稪 ����ᠭ��� ���஢
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2
       mov  dx, offset cs:write_buf
       int  21h
;       jc   error21
 ;      cmp  ax, 2+2
  ;     jne  error31

 ; ��襬 � 䠩� ॠ�쭮� ������⢮ ����ᥩ � ����
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:reserved
       int  21h
;       jc   error21
 ;      cmp  ax, 2+2
  ;     jne  error31

 ; ��襬 � 䠩� ���祭�� �।��饣� ����ﭨ� �� ������� ������ 䠩��
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4
       mov  dx, offset pred_track
       int  21h

 ; ��襬 � 䠩� ��� ��᫥����� ࠡ�祣� ��᪠
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset last_wrk_dsk
       int  21h

 ; ��襬 � 䠩� ��᫥���� ࠡ�稩 ��������� �����
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 15
       mov  dx, offset cs:Block
       inc  dx
       int  21h

 ; ��襬 � 䠩� ��᫥���� ࠡ�稩 ����
       push  ds
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 27000

       mov  bp, word ptr [cs:read_buf]
       shl  bp, 2
       add  bp, 2
       mov  dx, word ptr [cs:buff+bp]
       mov  ds, dx
       sub  bp, 2
       mov  dx, word ptr [cs:buff+bp]
       int  21h
       pop  ds
;       jc   error21
 ;      cmp  ax, 30000
  ;     jne  error31

       ; ����뢠�� 䠩� ���䨣��樨
       mov  ax, 3e00h
       mov  bx, word ptr [cs:cfg_descriptor]
       int  21h

       pop  ds
   ; �����稫� ᮧ������ 䠩� ���䨣��樨
