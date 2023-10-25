include read_pic.asm

DIMENSION_SIZE EQU  134

BASE_PROTOTIP_ODOM equ 580h

TIMER_INT    EQU  08h    ; прерывание таймера  (IRQ 0)
ODOMETR_INT  EQU  0Dh    ; прерывание одометра (IRQ 5)
TIMER_CLOKC  EQU  11929  ; 11929 - 100 Гц
                         ;
DELEY_CLOCK  EQU  1000  ; время определяющее стоянку в сотых секунды

BASE_ADC_1  equ 520h
BASE_ADC_2  equ 530h
BASE_ADC_3  equ 560h
BASE_ADC_4  equ 570h

Timer PROC far
       cli
       push eax

       add dword ptr [cs:time], 0001h ; считаем время
       adc word ptr [cs:time+4], 0000 ;

       mov al, 20h
       out 20h, al

       pop eax
       iret

time   DD    100  ; место под собственный счетчик таймера
       DW      0  ; а это на случай переполнения

Base_Skip           dw  0
Odom_skip           dw  0 ; частота пропуска опроса одометра
pred_track_in_timer dd  0 ; значение счетчика одометра на пред. входе в Timer
Timer ENDP


init_ADC  PROC near  ; инициализация каpт АЦП для 16 битной пеpедачи
                     ; поpтит  al и dx
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
      mov   al, 80h     ; запуск оцифровки 0 канала всех АЦП
      mov   dx, BASE_ADC_1 + 2h    ; с задержкой
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

      mov  cx, 14  ; проверяем 14 раз
      xor  ax, ax      ; проверка готовности первой АЦП
      mov  dx, BASE_ADC_1+4
Ready_First:
      in   ax, dx
      and  ax, 0100h
      jnz  Read_data
      LOOP Ready_First

Read_data:

      mov  cx, 16    ; повторяем 16 раз

Begin_read:
      ; первая карта
      mov  dx, BASE_ADC_1
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; помещаем результат по [ds:bx]
      add  bx, 32

      mov  dx, BASE_ADC_1 + 2h
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; помещаем результат по [ds:bx]
      add  bx, 32

      mov  al, 40h   ; запуск оцифровки следующего канала без задержки
      out  dx, al

      ; вторая карта
      mov  dx, BASE_ADC_2
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; помещаем результат по [ds:bx]
      add  bx, 32

      mov  dx, BASE_ADC_2 + 2h
      in   ax, dx
      and  ax, 0fff0h
      shr  ax, 4
      mov  word ptr [ds:bx], ax ; помещаем результат по [ds:bx]
      add  bx, 32

      mov  al, 40h   ; запуск оцифровки следующего канала без задержки
      out  dx, al

      sub  bx, 126

;      LOOP Begin_read
      dec cx
      jnz Begin_read   ; закончился цикл чтения

      add  bx, 96
      ret

test_ADC  ENDP   ; ---------------------


Odometr PROC far
    cli
    pushad

    mov al, 0DFh ; отключаем каскадный контроллер прерываний
    out 21h, al  ; т.е. отключаем прерывание SCSI (IDE)

    add dword ptr [cs:track], 0001h    ; увеличиваем счетчик одометра
    adc word ptr [cs:track+4], 0000

    mov al, 20h    ; разрешаем контроллеру прерывания
    out 20h, al

    cmp byte ptr [cs:int_activ], 0 ; проверяем на повторный вход в
    jne End_Proc                   ; Odometr, иначе выходим

    mov bp, word ptr [cs:read_buf]
    cmp byte ptr [cs:beasy_buf + bp], 0  ; проверяем, что требуемый
    jne End_Proc                        ; буфер не занят, иначе выходим

     ; проверим что следующий буффер тоже не занят
     mov bp, word ptr [cs:read_buf]
     inc bp
     cmp bp, word ptr [cs:MAX_BUF]
     jne Check_next_buf  ; проверим не пора ли замыкать кольцо в списке буферов
     xor bp, bp
Check_next_buf:
    cmp byte ptr [cs:beasy_buf + bp], 0  ; проверяем, что следующий
    jne End_Proc                        ; буфер не занят, иначе выходим

    cmp word ptr [cs:Curent_Odom_skip], 0 ; проверяем не требуется ли
    jne End_Proc                    ; проредить измерения

    push ds
    push es

    mov eax, dword ptr [cs:track]      ; запомнили в eax тики одометра

    mov byte ptr [cs:int_activ], 1   ; ставим флаг что уже один раз вошли
    sti                              ; в обработчик, разрешаем прерывания

    sub eax, dword ptr [cs:last_track] ; вычислим сколько тиков одометра
    add dword ptr [cs:last_track], eax ; прошло с предыдущего измерения
    mov word ptr [cs:d_track], ax      ; засекаем значение счетчика одометра

    add word ptr [cs:read_rec], ax    ; увеличиваем счетчик записей в блоке


    cmp word ptr [cs:read_rec], 201  ; сравним с нормой измерений в блоке
    jb Dimension                     ; если меньше, то переходим к измерению
       mov eax, dword ptr [cs:time]
       sub eax, dword ptr [cs:abs_time]
       add dword ptr [cs:abs_time], eax  ; запомнили время

Begin_correct_read_rec:
       cmp word ptr [cs:read_rec], 200
       jb Complete_correct_read_rec
       add dword ptr [cs:abs_track], 200
       sub word ptr [cs:read_rec], 200
       jmp Begin_correct_read_rec
Complete_correct_read_rec:

       call get_termo_dat
       mov byte ptr [cs:reserved+5], al

       call get_pos  ; процедура чтения датчика ориентации
       mov byte ptr [cs:pos], al

       ; сформировали "заголовок" блока теперь скопируем его в буфер
       mov  bp, word ptr [cs:read_buf]
       shl  bp, 2
       mov  bx, word ptr [cs:buff+bp+2]
       mov  ds, bx
       mov  bx, word ptr [cs:buff+bp]
       sub  bx, 16

       mov eax, dword ptr [cs:Block]   ; первые 4 байта
       mov dword ptr [ds:bx], eax
       add bx, 4

       mov eax, dword ptr [cs:Block+4]  ; вторые 4 байта
       mov dword ptr [ds:bx], eax
       add bx, 4

       mov eax, dword ptr [cs:Block+8]  ; третьи 4 байта
       mov dword ptr [ds:bx], eax
       add bx, 4

       mov eax, dword ptr [cs:Block+12] ; четвертые 4 байта
       mov dword ptr [ds:bx], eax
       add bx, 4

         mov bp, word ptr [cs:read_buf]
         mov byte ptr [cs:beasy_buf + bp], 1 ; флаг занятости буфера

         inc word ptr [cs:read_buf]
         mov ax, word ptr [cs:MAX_BUF]
         cmp word ptr [cs:read_buf], ax
         jne @1  ; проверим не пора ли замыкать кольцо в списке буферов
         mov word ptr [cs:read_buf], 0
 @1:
         ; переключим current на новый буффер
         mov  bp, word ptr [cs:read_buf]
         shl  bp, 2
         add  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  word ptr [cs:current+2], ax
         sub  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  word ptr [cs:current], ax

         mov byte ptr [cs:reserved], 0

    ; моргаемем диодом на процессорной плате
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
    ; проморгались диодом на процессорной плате

Dimension: ; начало стандартного цикла измерения
    mov bx, word ptr [cs:current+2]  ; помещаем значение current
    mov ds, bx                       ; в ds:bx
    mov bx, word ptr [cs:current]    ; (место для записи данных)

    mov ax, word ptr [cs:d_track]  ; отмечаем в буфере сколько отсчетов
    mov word ptr [ds:bx], ax       ; прошло от предыдущего измерения
    add bx, 2

    inc byte ptr [cs:reserved]  ; увеличиваем счетчик реально записанных
                                ; измерений
    call get_wheel_number
    mov byte ptr [ds:bx], al
    inc  bx

    call get_vibro1            ; датчик вибрации  # 1
    mov byte ptr [ds:bx], al
    inc bx

    call get_vibro2            ; датчик вибрации  # 2
    mov byte ptr [ds:bx], al
    inc bx

    call get_vibro3            ; датчик вибрации  # 3
    mov byte ptr [ds:bx], al
    inc bx

    call test_ADC

    mov word ptr [cs:current], bx  ; сохpаняемем новое значение current
    mov bx, ds                       ; из ds:bx
    mov word ptr [cs:current+2], bx    ; (место для записи данных)

    mov eax, dword ptr [cs:time]         ; сохpаняем вpемя последнего
    sub eax, dword ptr [cs:last_time]    ; измеpения
    add dword ptr [cs:last_time], eax    ; и засекаем разницу

    pop  es
    pop  ds

    cli
    mov byte ptr [cs:int_activ], 0

End_Proc:
    mov al, 0D8h ; включаем каскадный контроллер прерываний
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

int_activ  DB  0  ; флаг активности обработчика

track   DD     0  ; место под счетчик одометра
        DW     0  ; а это на случай переполнения

MAX_BUF       DW  12  ; количество буферов в системе (не больше 20)

buff        DD  20 DUP (0) ; место под 20 длинных адресов буферов
beasy_buf   DB  20 DUP (0) ; место под 20 флагов занятости буферов (1)
length_buf  DW  20 DUP (0) ; место под 20 длинн заполненности буферов

current     DD  0 ; длинный указатель на текущее место записи (seg:ofs)
read_buf    DW  0 ; номер буфера в который читаем данные с датчиков
read_rec    DW  0 ; счетчик прочитанных измерений (в данном усл. шве)

; структура "заголовка" 2-х метрового блока (tech_info)
Block      DB    0F7h  ; сигнатура
pos        DB    0     ; положение снаряда
abs_time   DD    0     ; прошедшее с начала пути время
abs_track  DD    0     ; пройденное с начала пути расстояние
reserved   DB    0,"Бл01",0 ; зарезервировано 6 байт
; конец описания "заголовка" блока

reserv_2   DB    0,0,"#0#"  ; зарезервировано 5 байт в заголовке записи
                                 ; измерения, первые два под время стоянки

last_time  DD    0  ; время на предыдущем измерении
last_track DD    0  ; расстояние на предыдущем измерении

d_track DD     0  ; прошло тиков одометра с предыд. измерения

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

      ; закрываем файл данных
       mov  ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h

       call CHANGE_FILE

Check_free_space:
       ; проверим сколько свободного места
       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       cmp dl, 0
       je Crash1

       sub dl, 'a'  ;dl =  номер нужного диска
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
       cmp eax, 2700000 ; 2.7 Мб
       jae Not_change_disk

        ; проверим есть ли еще диски для записи
       dec word ptr [cs:work_disk_count]
       inc word ptr [cs:disk_count]
       cmp word ptr [cs:work_disk_count], 0
       je Crash1

       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       cmp dl, 0
       je Crash1

       sub dl, 'a'  ;dl =  номер нужного диска

        ; включим следующий диск из списка
       mov ah, 0Eh
       int 21h
       jmp Check_free_space

Not_change_disk:
       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       mov byte ptr [cs:last_wrk_dsk], dl

       ; Открываем файл для записи данных
       mov  ax, 3c00h        ; функция DOS создания файла
       mov  cx, 00         ; обычный файл
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
      ; mov  al, 1  ; выход с ошибкой
       ret
Next_file ENDP

Check_last_file proc near
       pushad

       ; сохраним имя файла на будущее
       mov bx, offset file_data
       mov di, offset BuckUp_file_name
       mov cx, 3
    Copy_file_name_to_BuckUp:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_file_name_to_BuckUp
       ; сохранили имя файла на будущее

       mov  ax, offset [cs:file_data]   ; выставим указатель
       add  ax, 2                       ; на номер файла
       mov  word ptr [cs:num_file_data], ax

       mov ah, 4Eh
       mov cx, 00
       mov dx, cs
       mov ds, dx
       mov dx, offset file_mask
       int 21h
       cmp ax, 0
       jne Not_da_on_disk

       ; на диске все же есть рабочие файлы
       mov ah, 2Fh
       int 21h
       add bx, 30 ; es:bx -> имя первого найденного файла

       ; скопируем имя найденного файла
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

       ; Открываем файл данных
       mov  ax, 3d02h
       mov  dx, offset cs:file_data
       int 21h
       jc Detected_last_file

       mov  word ptr [cs:data_descriptor], ax

      ; закрываем файл данных
       mov   ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h
       jmp Serch_last_file

Detected_last_file:

       ; скопируем имя найденного файла
       mov bx, offset file_data
       mov di, offset Last_serched_file
       mov cx, 3
    Copy_file_name_to_Last_serched:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_file_name_to_Last_serched

       ; вернем имя файла взад
       mov bx, offset BuckUp_file_name
       mov di, offset file_data
       mov cx, 3
    Copy_BuckUp_to_file_name_1:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_BuckUp_to_file_name_1
       ; вернем имя файла взад

       call CHANGE_FILE

       ; сравним номера файлов следующего за последним найденным
       ; и следующего за заявленным
       mov bx, (offset Last_serched_file) +3
       mov di, (offset file_data) + 3

       mov eax, dword ptr [cs:bx]
       cmp dword ptr [cs:di], eax
       jne Zayavl_not_correct
       jmp Not_da_on_disk

Zayavl_not_correct:

       ; вернем имя файла взад из Last_serch
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

       ; вернем имя файла взад из BackUp
       mov bx, offset BuckUp_file_name
       mov di, offset file_data
       mov cx, 3
    Copy_BuckUp_to_file_name:
       mov eax, dword ptr [cs:bx]
       mov dword ptr [cs:di], eax
       add bx, 4
       add di, 4
       LOOP Copy_BuckUp_to_file_name
       ; вернем имя файла взад

End_Check_last_file:
       popad
       ret

 BuckUp_file_name db 32 dup (0)
 Last_serched_file db 32 dup (0)
 file_mask db '*.da',0,0
Check_last_file endp


InitProg PROC near
       push ds

       ; иннициализация массива указателей на буфера
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

       mov  ax, offset [cs:file_data]   ; выставим указатель на номер
       add  ax, 2                       ; файла
       mov  word ptr [cs:num_file_data], ax

       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov al, byte ptr [cs:bx]
       mov byte ptr [cs:last_wrk_dsk], al

       ; Открываем файл конфигурации, если он есть
       include load_cfg.asm

       mov  bp, word ptr [cs:read_buf] ; загрузим место текущей записи
       shl  bp, 2                      ; данных в буфер
       mov  ax, word ptr [cs:buff+bp]
       mov  word ptr [cs:current], ax
       add  bp, 2
       mov  ax, word ptr [cs:buff+bp]
       mov  word ptr [cs:current+2], ax

       mov  ax, word ptr [cs:reserved]
       mov  bp, DIMENSION_SIZE
       mul  bp
       add  word ptr [cs:current], ax

        ; включим первый диск из списка
       mov bx, offset work_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       sub dl, 'a'  ;dl =  номер нужного диска

       mov ah, 0Eh
       int 21h

open_wrk_file:
       mov  ax, cs
       mov  ds, ax

       call Check_last_file

       ; Открываем файл данных
       mov  ax, 3d02h
       mov  dx, offset cs:file_data
       int 21h
       mov  word ptr [cs:data_descriptor], ax
       jnc Not_create_file

       mov  ax, 3c00h        ; функция DOS создания файла
       mov  cx, 00         ; обычный файл
       mov  dx, offset cs:file_data  ;
       int  21h
       jc   error1
       mov  word ptr [cs:data_descriptor], ax
       jmp Not_mov_point_to_end

Not_create_file:
      ; переместим указатель записи на конец
       mov  ax, 4202h
       mov  bx, word ptr [cs:data_descriptor]
       xor  cx, cx
       xor  dx, dx
       int  21h

Not_mov_point_to_end:
       mov  al, 0 ; нормальный выход
       pop  ds
       ret

error1: ; ...
error2: ; ...
error3: ; ...
Crash:
       mov  al, 1  ; выход с ошибкой
       pop  ds
       ret
InitProg ENDP


Write_flash PROC near  ; ds:dx = указатель на записываемый буффер
       push cx
       push ds

       mov di, dx

       ; проверим счетчик блоков в файле
       mov  eax, dword ptr [ds:di+6]
       cmp  eax, 0
       je   close_write_flash

       ; пишем в файл заголовок блока
       mov  bx, word ptr [cs:data_descriptor]
       mov  cx, 16
       mov  dx, di
       mov  ax, 4000h
       int  21h
       jc   error22

       ; пишем в файл буфер с данными
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
       mov  ax, 1  ; выход с ошибкой
       pop ds
       pop  cx
       ret

pred_track  dd 0
Write_flash ENDP


Write_data PROC near
       push cx

       mov  bp, word ptr [cs:write_buf]  ; проверим готовность буфера
       cmp  byte ptr [cs:beasy_buf+bp], 1
       jne  close_write  ; если буфер еще не готов, то выходим

         ; загрузим указатель на буффер
         mov  bp, word ptr [cs:write_buf]
         shl  bp, 2
         add  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  ds, ax
         sub  bp, 2
         mov  ax, word ptr [cs:buff+bp]
         mov  dx, ax
         sub  dx, 16

       ; пишем на flash
       call Write_flash  ; ds:dx = указатель на записываемый буффер

Go_to_next_buf:
       mov  bp, word ptr [cs:write_buf]
       mov  byte ptr [cs:beasy_buf+bp], 0  ; буфер снова пустой

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
    ; *******  Начало основной программы (точка входа) *******
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
       push es               ; сохраним старые вектора прерывания:
       mov  al, TIMER_INT
       mov  ah, 35h
       int  21h
       mov  [cs:timerSeg], es
       mov  [cs:timerOfs], bx
       pop  es

       push ds             ; поменяем прерывание на свое
       mov  al, TIMER_INT
       mov  ah, 25h
       push cs
       pop  ds
       mov  dx, offset Timer
       int  21h
       pop  ds

       cli
           ; увеличи частоту работы таймера с 18,2 до 100 Гц
       mov al, 3ch   ; управляющее слово, задающее режим 2,
                     ; двоичный подсчет, запись младший/старший байт
       out 43h, al   ; в управляющий регистр микросхемы 8253

       mov ax, TIMER_CLOKC
       out 40h, al   ; младший байт счетчика
       mov al, ah
       out 40h, al    ; старший байт счетчика
       sti
; закончили настройку таймера

Set_Odometr:
       call  init_ADC

       push es               ; сохраним старые вектора прерывания:
       mov  al, ODOMETR_INT
       mov  ah, 35h
       int  21h
       mov  [cs:odometrSeg], es
       mov  [cs:odometrOfs], bx
       pop  es

       push ds             ; поменяем прерывание на свое
       mov  al, ODOMETR_INT
       mov  ah, 25h
       push cs
       pop  ds
       mov  dx, offset Odometr
       int  21h
       pop  ds
; закончили настройку одометра

; Разpешим IRQ5
       in  al, 21h
       and al, 0DFh
       out 21h, al

    ; зажигаем диод на процессорной плате
       mov dx, 0e5h
       in  al, dx
       or al, 080h
       out dx, al

      ; зажигаем светодиод "Готовность" и оставляем гореть "Исправность"
       mov al, 03
       mov dx, 0e0h
       out dx, al
      ; зажгли светодиод "Готовность"

MAIN_CIKLE:   ; начало рабочего цикла программы Scan

       call keyboard_ready  ; проверяем не нажата ли клавиша на клавиатуре
       jnz Exit

       pushad
       push ds

       mov  ax, cs
       mov  ds, ax

       ; проверяем сколько уже стоим, если больше 10 сек закр. файл
       cli
       mov eax, dword ptr [cs:time]         ; сколько вpемени прошло
       sub eax, dword ptr [cs:last_time]    ; c последнего измеpения ?
       sti
       cmp eax, 1000
       jb Not_stop_bort

      ; закрываем файл данных
       mov  ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h
      ; закрыли файл данных

      ; создание файла конфигурации
       include save_cfg.asm

       call Read_track

       call Get_PIC_track

       mov eax, dword ptr [cs:track] ;  запомнили расстояние
       mov dword ptr [cs:Stop_track], eax

       mov ah, 4      ; дата конца стоянки
       int 1Ah
       mov word ptr [cs:Beg_date_stop], cx
       mov word ptr [cs:Beg_date_stop+2], dx

       mov ah, 2      ; время конца стоянки
       int 1Ah
       mov word ptr [cs:Beg_time_stop], cx
       mov word ptr [cs:Beg_time_stop+2], dx

       pop ds
       popad

       ; ждем в цикле, когда поедем
Wait_go_bort:
       mov eax, dword ptr [cs:time]         ; сколько вpемени прошло
       sub eax, dword ptr [cs:last_time]    ; c последнего измеpения ?
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

       ; открываем файл и переходим в его конец
       mov  ax, 3d02h     ; функция DOS открытия файла
       mov  dx, offset file_data
       int  21h
       mov  word ptr [cs:data_descriptor], ax

       ; переместим указатель записи на конец
       mov  ax, 4202h
       mov  bx, word ptr [cs:data_descriptor]
       xor  cx, cx
       xor  dx, dx
       int  21h
       ; открыли файл и перешли в его конец

       call Save_stop_spead

Not_stop_bort:
       pop ds
       popad

       call Write_data ; запись данных

       jmp  MAIN_CIKLE   ; конец рабочего цикла программы

Exit:
       ;cli
       ; вернем одометр на место
       push ds             ; поменяем прерывание на старое
       mov  al, ODOMETR_INT
       mov  ah, 25h
       mov  dx, word ptr [cs:odometrSeg]
       mov  ds, dx
       mov  dx, word ptr [cs:odometrOfs]
       int  21h
       pop ds

       ; вернем таймер на место
       push ds             ; поменяем прерывание на старое
       mov  al, TIMER_INT
       mov  ah, 25h
       mov  dx, word ptr [cs:timerSeg]
       mov  ds, dx
       mov  dx, word ptr [cs:timerOfs]
       int  21h
       pop  ds

       cli
           ; частоту работы таймера на 18,2 Гц
       mov al, 3ch   ; управляющее слово, задающее режим 2,
                     ; двоичный подсчет, запись младший/старший байт
       out 43h, al   ; в управляющий регистр микросхемы 8253

       mov ax, 0ffffh;  обеспечивает работу таймера 18,2 Гц
       out 40h, al   ; младший байт счетчика
       mov al, ah
       out 40h, al    ; старший байт счетчика
       sti

      ; закрываем файл данных
       push ds

       mov  ax, cs
       mov  ds, ax

       mov  ax, 3e00h
       mov  bx, word ptr [cs:data_descriptor]
       int  21h
       pop ds
      ; закрыли файл данных

    ; создание файла конфигурации
       include save_cfg.asm

    ; Пишем в log-файл что нет давления
       call Save_not_pressure

       call keyboard_ready  ; проверяем не нажата ли клавиша на клавиатуре
       jz Wait_pressure
       ret

Wait_pressure:
       xor bx, bx
       mov cx, 3
Detect_pressure1:
       mov  dx, BASE_PROTOTIP_ODOM+8h ; проверка датчика давления
       in   al, dx
       not  al
       and  al, 01h
       add  bl, al
       LOOP Detect_pressure1
       cmp  bl, 0
       je  Wait_pressure  ; если нет давления, то ждем

       ; если давление появилось то продолжаем измерение
       jmp Begin

   ; объявление данных
BLOCK_IN_FILE   DW    100   ; количество 2-х метровых блоков в файле

cfg_descriptor  DW    0
file_cfg        DB   'c:\scan.sav',0,0,0,0,0,0,0,0
serch_cfg_file  dw    0


data_descriptor DW    0
last_wrk_dsk    db    0
                db    ':'
file_data       DB   'tm00000.da',0,0,0,0,0,0,0,0
num_file_data   DW    0      ; указатель на номер файла в имени

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

   ; резервируем поля для записи параметров остановки
Stop_time     DD  0  ; Время стоянки
Stop_track    DD  0  ; Пройдено см к моменту остановки
Beg_date_stop DD  0  ; Дата начала стояни
Beg_time_stop DD  0  ; Время начала стоянки


 timerOfs    DW   0  ; зарезервировано под старый
 timerSeg    DW   0  ; вектор таймерного прерывания

 odometrOfs  DW   0  ; зарезервировано под старый
 odometrSeg  DW   0  ; вектор прерывания одометра

Scan ENDP


