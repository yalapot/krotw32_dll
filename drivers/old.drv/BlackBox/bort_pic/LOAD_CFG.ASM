  ; ��稭��� �⥭�� 䠩�� ���䨣��樨
       push ds
       mov  ax, cs
       mov  ds, ax

       ; ���뢠�� 䠩� ���䨣��樨, �᫨ �� ����
       mov  ax, 3d00h        ; �㭪�� DOS ������ 䠩�� ��� �⥭��
       mov  dx, offset cs:file_cfg  ;
       int  21h
       jc   no_file
       mov  word ptr [cs:cfg_descriptor], ax

       mov  ah, 42h   ; �����頥� 㪠��⥫� �� ��砫� 䠩��
       mov  bx, word ptr [cs:cfg_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 0
       int  21h
       jc   no_file

       ; �⠥� �� 䠩�� �६�
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6
       mov  dx, offset cs:time
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

       ; �⠥� �� 䠩�� ��᫥���� ���祭�� ���������
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:old_pos
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; �⠥� �� 䠩�� �ன������ ����ﭨ�, ���-�� ���஢, ���-�� ������ � ����
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6+2+2
       mov  dx, offset cs:track
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; �⠥� �� 䠩�� 䫠�� ������� ���஢
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 20
       mov  dx, offset cs:beasy_buf
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; �⠥� �� 䠩�� ����� ���� �⥭��, ���稪� ������ � ����ᥩ
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2+2
       mov  dx, offset cs:read_buf
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; �⠥� �� 䠩�� �६� � ����ﭨ� �� ��᫥���� ����७��
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4+4
       mov  dx, offset cs:last_time
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

       ; �⠥� �� 䠩�� ��� ⥪�饣� 䠩�� � ����묨
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 16
       mov  dx, offset cs:file_data
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

      ; �⠥� �� 䠩�� ����� ���� ����� � ���稪 ����ᠭ��� ���஢
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2
       mov  dx, offset cs:write_buf
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

      ; �⠥� �� 䠩�� ॠ�쭮� ������⢮ ����ᥩ � ����
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:reserved
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; �⠥� �� 䠩�� ���祭�� �।��饣� ����ﭨ� �� ������� ������ 䠩��
       mov  ax, 3f00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4
       mov  dx, offset pred_track
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; �⠥� �� 䠩�� ��� ��᫥����� ࠡ�祣� ��᪠
       mov  ax, 3f00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset last_wrk_dsk
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; �⠥� �� 䠩� ��᫥���� ࠡ�稩 ��������� �����
       mov  ax, 3f00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 15
       mov  dx, offset cs:Block
       inc  dx
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; �⠥� �� 䠩�� ��᫥���� ࠡ�稩 ����
       push  ds
       mov  ax, 3F00h
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
       jc   no_file
       cmp cx, ax
       jne  no_file

       ; ����뢠�� 䠩� ���䨣��樨
       mov  ax, 3e00h
       mov  bx, word ptr [cs:cfg_descriptor]
       int  21h

       mov  word ptr [cs:serch_cfg_file], 0
       jmp  End_load_cfg

   ; �����稫� ���� 䠩� ���䨣��樨
no_file:
       mov  word ptr [cs:serch_cfg_file], 1

End_load_cfg:
       ; ����塞 䠩� ���䨣��樨, �᫨ �� ����
       mov  ax, 4100h        ; �㭪�� DOS 㤠����� 䠩��
       mov  dx, offset cs:file_cfg  ;
       int  21h

       pop  ds
