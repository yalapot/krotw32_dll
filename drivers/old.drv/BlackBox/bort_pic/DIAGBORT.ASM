;                                       /*****************/
; diagbort.asm                          /*        /|     */
; Copyright (C) by LAPOT' 2000          /*  ____/  �     */
;                                       /*  \    !  \    */
;-------------------------------------  /*    \  � ___\  */
; �뤠� ���������᪮� ���ଠ樨     /*     �  /      */
; � ���� �� COM-�����                  /*     |/        */
;-------------------------------------  /*****************/

Track_counter PROC far
       cli
       pusha

       add byte ptr [cs:Odom_tiks], 0001h

       ; ������ ����� ����権, �ਥ��樨 � ⥬������� � PIC-������
       mov  dx, PIC_GET_PORT
       mov  al, GET_ORIENTATION_TERMO
       out  dx, al
       Jmp $+2

        ; ���� ��� ��⮢���� ��� �⥭��
       mov cx, 255
Wait_ready_:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_
       LOOP Wait_ready_

Compleate_Wait_ready_:

       call Read_orient_termo

       mov al, 20h
       out 20h, al

       popa
       iret

   Odom_tiks      DW 0
Track_counter  ENDP

Diagnostika_bort PROC near
     pusha
     push ds

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
       mov  dx, offset Track_counter
       int  21h
       pop  ds
; �����稫� ����ன�� �������

; ���p�訬 IRQ6
     in  al, 21h
     and al, 0BFh
     out 21h, al

     call  init_ADC

     mov bx, cs
     mov ds, bx

Diagnostika_cikl:
      mov bx, offset Buffer
      mov al, byte ptr [cs:Odom_tiks]
      mov byte ptr [cs:bx], al
      inc bx

    ; ��࣠���� ������ �� �����୮� ����
       pusha
       in  al, 0e5h
       mov ah, byte ptr [cs:Odom_tiks]
       test ah, 01h
       jnz not_zero_led1
       and al, 7fh
       jmp end_led_manipulate1
not_zero_led1:
       or al, 80h
end_led_manipulate1:
       out 0e5h, al
       popa
    ; �஬�࣠���� ������ �� �����୮� ����

      call get_pos
      mov byte ptr [cs:bx], al
      inc bx

      push dx
      mov  dx, BASE_PROTOTIP_ODOM+8h ; �஢�ઠ ���稪� ��������
      in   al, dx
      and  al, 08h ; ����砥� ����� �����
      shr  al, 3
      add  al, '0'
      pop dx
      mov byte ptr [cs:bx], al
      inc bx

      push dx
      mov  dx, BASE_PROTOTIP_ODOM+8h ; �஢�ઠ ���稪� ��������
      in   al, dx
      not  al
      and  al, 1 ; ���ﭨ� ���稪� ��������
      add  al, '0'
      pop dx
      mov byte ptr [cs:bx], al
      inc bx

      call get_vibro1
      mov byte ptr [cs:bx], al
      inc bx

      call get_vibro2
      mov byte ptr [cs:bx], al
      inc bx

      call get_vibro3
      mov byte ptr [cs:bx], al
      inc bx

      call get_termo_dat
      mov byte ptr [cs:bx], al
      inc bx

      call test_ADC
      mov bx, offset Buffer

Begin_save_data:
      call Read_Serial ; ���� �������
      cmp  ah, 0
      je  Begin_save_data

       ; ��諠 ������� ��室�
      cmp al, 'e'
      je Exit_diagnostika_bort

      cmp al, ' '
      jne Compare_3
      mov byte ptr [cs:Odom_tiks], 0
      jmp Begin_save_data

Compare_3:
      cmp al, '3'
      je Diagnostika_cikl

      cmp al, 'd'
      jne Begin_save_data

      cli
      mov cx, 137
Write_133b:

; call Write_Serial ----------------------------------
        ; ���� ��⮢���� ���� ���� ��� �ਥ�� ������
Wait_ready_serial:
       mov dx, word ptr [cs:Open_port]
       add dx, 5
       in  al, dx
       test al, 20h
       je Wait_ready_serial

       ; ���뫠�� ���� � ����
       mov dx, word ptr [cs:Open_port]
       mov al, byte ptr [cs:bx]
       out dx, al
;-------------------------
       inc bx
       LOOP Write_133b
      sti

      jmp Diagnostika_cikl

Exit_diagnostika_bort:

       cli
       ; ����⨬ IRQ6
       in  al, 21h
       or  al, 040h
       out 21h, al
       sti

       ; ��୥� ������� �� ����
       push ds             ; �����塞 ���뢠��� �� ��஥
       mov  al, ODOMETR_INT
       mov  ah, 25h
       mov  dx, word ptr [cs:odometrSeg]
       mov  ds, dx
       mov  dx, word ptr [cs:odometrOfs]
       int  21h
       pop ds
       sti

     pop ds
     popa
     ret

   Buffer  db 144 dup (0)
   PG_ADC_Flag  db 0

Diagnostika_bort ENDP

