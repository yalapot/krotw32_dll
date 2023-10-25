
PIC_GET_PORT    EQU  580h
PIC_GET_SPECIAL EQU  588h

  ; Объявляем код запроса у PIC-процессора ориентации
GET_ORIENTATION_TERMO  EQU   50h

  ; Объявляем код запроса у PIC-процессора байтов пути
GET_TRACK   EQU    90h


Read_vibro PROC near ; без всякого запроса читаем 3 вибрации
       push cx
       push dx
       push ax
       push bx

       mov bx, offset Vibro_1_value

       ; читаем левое значение (запускаем опрос вибров)
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2

       mov cx, 3 ; читаем три вибрации
Read_vibro_data:
       push cx

        ; ждем бит готовности для чтения вибрации
       mov cx, 64000
Wait_ready_vibro:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_vibro
       LOOP Wait_ready_vibro

Compleate_Wait_ready_vibro:

       ; читаем значение
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:bx], al
       inc  bx

        ; ждем сброса бита готовности
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

  ; три вибрации
   Vibro_1_value      db 0
   Vibro_2_value      db 0
   Vibro_3_value      db 0

Read_vibro ENDP

Read_orient_termo PROC near  ; по коду 50h читаю 3 вибрации, ориентацию
       push cx               ; и температуру
       push dx
       push ax
       push bx

       ; делаем запрос вибраций, ориентации и температуры у PIC-процессора
;       mov  dx, PIC_GET_PORT
 ;      mov  al, GET_ORIENTATION_TERMO
  ;     out  dx, al
   ;    Jmp $+2

       mov bx, offset Vibro_1_value

       mov cx, 3 ; читаем три вибрации
Read_vibro_data_2:
       push cx

        ; ждем бит готовности для чтения вибрации
       mov cx, 49
Wait_ready_vibro_2:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_vibro_2
       LOOP Wait_ready_vibro_2

Compleate_Wait_ready_vibro_2:
       ; читаем значение
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:bx], al
       inc  bx

        ; ждем сброса бита готовности
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

        ; ждем бит готовности для чтения ориентации
       mov cx, 49
Wait_ready_orient:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_orient
       LOOP Wait_ready_orient

Compleate_Wait_ready_orient:
       ; читаем значение ориентации
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:Orientation_value], al

        ; ждем сброса бита готовности ориентации
       mov cx, 49
Wait_break_ready_orient:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jnz Compleate_Wait_break_ready_orient
       LOOP Wait_break_ready_orient

Compleate_Wait_break_ready_orient:
        ; ждем бит готовности для чтения температуры
       mov cx, 49
Wait_ready_termo:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_termo
       LOOP Wait_ready_termo

Compleate_Wait_ready_termo:
       ; читаем значение температуры
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:Termo_value], al

        ; ждем сброса бита готовности температуры
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

  ; Ориентация
   Orientation_value     db 0

  ; Температура
   Termo_value           db 0

Read_orient_termo ENDP

Read_track PROC near  ; по коду 90h читаем 12 байтов пути
       push cx
       push dx
       push ax
       push bx

       mov bx, offset Track_full_byte_1

       ; делаем запрос
       mov  dx, PIC_GET_PORT
       mov  al, GET_TRACK
       out  dx, al
       Jmp $+2

        ; ждем сброса бита готовности
       mov cx, 70
Wait_break_ready_pred_track:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jnz Compleate_Wait_break_ready_pred_track
       LOOP Wait_break_ready_pred_track

Compleate_Wait_break_ready_pred_track:

       mov cx, 12 ; читаем 12 байтов пути
Read_track_data:
       push cx

        ; ждем бит готовности для чтения
       mov cx, 70
Wait_ready_track:
       mov  dx, PIC_GET_SPECIAL
       in   al, dx
       Jmp $+2
       and al, 02h
       jz Compleate_Wait_ready_track
       LOOP Wait_ready_track

Compleate_Wait_ready_track:

       ; читаем значение
       mov  dx, PIC_GET_PORT
       in   al, dx
       Jmp  $+2
       mov  byte ptr [cs:bx], al
       inc  bx

        ; ждем сброса бита готовности
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

  ; четыре байта ОБЩЕГО пути
   Track_full_byte_1  db 0
   Track_full_byte_2  db 0
   Track_full_byte_3  db 0
   Track_full_byte_4  db 0

  ; четыре байта пути I одометра
   Track_I_Odom_byte_1  db 0
   Track_I_Odom_byte_2  db 0
   Track_I_Odom_byte_3  db 0
   Track_I_Odom_byte_4  db 0

  ; четыре байта пути II одометра
   Track_II_Odom_byte_1  db 0
   Track_II_Odom_byte_2  db 0
   Track_II_Odom_byte_3  db 0
   Track_II_Odom_byte_4  db 0

Read_track ENDP


    ; проверяем PIC на корректность работы, вроде как лажа
Check_PIC_Processor PROC near ; если жив ax=0, если умер ax>0
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

get_pos PROC near ; процедура чтения датчика ориентации
                  ; прочитанное значение помещает в  al
      mov al, byte ptr [cs:Orientation_value]
      ret

   old_pos db 0
get_pos ENDP  ; --------------------


get_termo_dat PROC near ; процедура чтения датчика температуры
                          ; прочитанное значение помещает в  al
      mov al, byte ptr [cs:Termo_value]
      ret

get_termo_dat ENDP  ; --------------------

get_vibro1 PROC near ; процедура чтения датчика вибрации #1
                     ; прочитанное значение помещает в  al
      mov al, byte ptr [cs:Vibro_1_value]
      ret

get_vibro1 ENDP  ; --------------------

get_vibro2 PROC near ; процедура чтения датчика вибрации #2
                     ; прочитанное значение помещает в  al
      mov al, byte ptr [cs:Vibro_2_value]
      ret

get_vibro2 ENDP  ; --------------------

get_vibro3 PROC near ; процедура чтения датчика вибрации #3
                     ; прочитанное значение помещает в  al
      mov al, byte ptr [cs:Vibro_3_value]
      ret

get_vibro3 ENDP  ; --------------------

get_wheel_number PROC near ; процедура чтения номера колеса (0 или 1)
                           ; прочитанное значение помещает в  al

    push dx
    mov  dx, PIC_GET_SPECIAL ;
    in   al, dx
    and  al, 08h ; получаем номер колеса
    shr  al, 3
;    add  al, '0'
    mov byte ptr [ds:bx], al
    pop  dx

    ret

get_wheel_number ENDP

Get_PIC_track PROC near    ; считанные с PIC-процессора пути
                           ; запишем в строку для вывода в log-файл.
      pushad               ; строка Pic_track объявлена в log_fale.asm

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

