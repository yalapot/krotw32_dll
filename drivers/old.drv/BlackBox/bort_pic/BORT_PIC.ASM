
 include par_tabl.asm

LF              equ     10      ;Linefeed
CR              equ     13      ;Carriage Return

  COM1  equ  3F8h
  COM2  equ  2F8h

  SER_BAUD_9600    equ 12
  SER_BAUD_19200   equ  6
  SER_BAUD_38400   equ  4
  SER_BAUD_115200  equ  1

  SER_STOP_1 equ 0  ; 1 стоп бит на символ
  SER_STOP_2 equ 4  ; 2 стоп бита на символ

  SER_BITS_5 equ 0  ; пятибитный символ
  SER_BITS_6 equ 1  ; шестибитный символ
  SER_BITS_7 equ 2  ; семибитный символ
  SER_BITS_8 equ 3  ; восьмибитный символ

  SER_PARITY_NONE equ  0 ; no parity
  SER_PARITY_ODD  equ  8 ; odd parity
  SER_PARITY_EVEN equ 24 ; even parity

  INT_SER_PORT_0  equ 0Ch ; port 0 interrupt com 1 & 3
  INT_SER_PORT_1  equ 0Bh ; port 0 interrupt com 2 & 4

  BUFFER_SIZE          equ  4096

A_DATA_0 SEGMENT
  head_area0  DB    16 DUP (0)
  buf0        DB    27000 DUP (0)
A_DATA_0 ENDS

A_DATA_1 SEGMENT
  head_area1  DB    16 DUP (0)
  buf1        DB    27000 DUP (0)
A_DATA_1 ENDS

A_DATA_2 SEGMENT
  head_area2  DB    16 DUP (0)
  buf2        DB    27000 DUP (0)
A_DATA_2 ENDS

A_DATA_3 SEGMENT
  head_area3  DB    16 DUP (0)
  buf3        DB    27000 DUP (0)
A_DATA_3 ENDS

A_DATA_4 SEGMENT
  head_area4  DB    16 DUP (0)
  buf4        DB    27000 DUP (0)
A_DATA_4 ENDS

A_DATA_5 SEGMENT
  head_area5  DB    16 DUP (0)
  buf5        DB    27000 DUP (0)
A_DATA_5 ENDS

A_DATA_6 SEGMENT
  head_area6  DB    16 DUP (0)
  buf6        DB    27000 DUP (0)
A_DATA_6 ENDS

A_DATA_7 SEGMENT
  head_area7  DB    16 DUP (0)
  buf7        DB    27000 DUP (0)
A_DATA_7 ENDS

A_DATA_8 SEGMENT
  head_area8  DB    16 DUP (0)
  buf8        DB    27000 DUP (0)
A_DATA_8 ENDS

A_DATA_9 SEGMENT
  head_area9  DB    16 DUP (0)
  buf9        DB    27000 DUP (0)
A_DATA_9 ENDS

A_DATA_10 SEGMENT
  head_area10  DB    16 DUP (0)
  buf10        DB    27000 DUP (0)
A_DATA_10 ENDS

A_DATA_11 SEGMENT
  head_area11  DB    16 DUP (0)
  buf11        DB    27000 DUP (0)
A_DATA_11 ENDS

STACKSEG SEGMENT para STACK 'Stack'
  DB     4096 dup (0)
STACKSEG ENDS

CODE SEGMENT para public 'Code'
        assume cs:CODE, ds:A_DATA_0, ss:STACKSEG, es:CODE

.386

 ; процедура проверяет есть ли нажатая клавиша (буффер клавиатуры)
keyboard_ready proc near
      mov ah, 1
      int 16h
      ret
keyboard_ready  endp

 ; процедура возвращает код нажатой клавиши (из буффера клавиатуры или ждет)
keyboard_read proc near
      xor ax, ax
      int 16h
      ret
keyboard_read  endp

outtext         proc    near
                pusha                   ; save all
                mov     ah,09h          ; Do DOS Function Print String
                int     21h             ; call interrupt routine
                popa                    ; restore all
                ret
outtext         endp

Serial_ISR PROC far
       cli
       push dx
       push bx
       push ax

       mov dx, word ptr [cs:Open_port]
       add dx, 5
       in  al, dx
       and al, 1
       cmp al, 0
       je Done_Interrupt

       mov dx, word ptr [cs:Open_port]
       in  al, dx

       sti
       mov bx, word ptr [cs:COM_PORT_BUF_End]
       mov byte ptr [cs:bx], al
       inc bx
       cmp bx, (offset COM_PORT_Buffer) + BUFFER_SIZE
       jb NORMAL_BUF_Pointer
         mov word ptr [cs:COM_PORT_BUF_End], offset COM_PORT_Buffer
         jmp Done_Interrupt

  NORMAL_BUF_Pointer:
          mov word ptr [cs:COM_PORT_BUF_End], bx

Done_Interrupt:
       mov al, 20h
       out 20h, al

       pop ax
       pop bx
       pop dx
       iret

 COM_PORT_BUF_Begin   DW   offset COM_PORT_Buffer
 COM_PORT_BUF_End     DW   offset COM_PORT_Buffer
 COM_PORT_Buffer      DB   BUFFER_SIZE dup (0)
Serial_ISR ENDP

Read_Serial PROC near   ; возвращает в al байт из COM-порта
       push bx          ; если ah = 0, значит нет данных

       xor ax, ax
       mov bx, word ptr [cs:COM_PORT_BUF_End]
       cmp bx, word ptr [cs:COM_PORT_BUF_Begin]
       je NOT_DATA_in_Serial
          mov bx, word ptr [cs:COM_PORT_BUF_Begin]
          mov ah, 0FFh
          mov al, byte ptr [cs:bx]
          inc bx
          cmp bx, (offset COM_PORT_Buffer) + BUFFER_SIZE
          jne NORMAL_BUF_Begin
             mov word ptr [cs:COM_PORT_BUF_Begin], offset COM_PORT_Buffer
             jmp NOT_DATA_in_Serial

  NORMAL_BUF_Begin:
          mov word ptr [cs:COM_PORT_BUF_Begin], bx

NOT_DATA_in_Serial:
       sti
       pop bx
       ret
Read_Serial ENDP

Write_Serial PROC near ; посылает байт из AH в com-порт
       push dx

        ; ждем готовности буфера порта для приема данных
Wait_buf_write:
       mov dx, word ptr [cs:Open_port]
       add dx, 5
       in  al, dx
       and al, 20h
       cmp al, 0
       je Wait_buf_write

       cli

       ; посылаем байт в порт
       mov dx, word ptr [cs:Open_port]
       mov al, ah
       out dx, al

       sti

       pop dx
       ret
Write_Serial ENDP

Open_Serial PROC near
       pusha

       cli

       mov word ptr [cs:COM_PORT_BUF_Begin], offset COM_PORT_Buffer
       mov word ptr [cs:COM_PORT_BUF_End], offset COM_PORT_Buffer

       mov dx, word ptr [cs:Open_port]
       add dx, 3
       mov al, 128
       out dx, al

       mov dx, word ptr [cs:Open_port]
       mov al, SER_BAUD_115200 ;115200
       out dx, al

       inc dx
       xor al, al
       out dx, al

         ; configuration
       mov dx, word ptr [cs:Open_port]
       add dx, 3
       mov al, SER_PARITY_NONE
       or  al, SER_BITS_8
       or  al, SER_STOP_1
       out dx, al

       ; enable the interrupt
       mov dx, word ptr [cs:Open_port]
       add dx, 4
       mov al, 0Bh
       out dx, al

       mov dx, word ptr [cs:Open_port]
       add dx, 1
       mov al, 1
       out dx, al

       mov al, INT_SER_PORT_0
       lea     dx, OPEN_COM_PORT_1
       mov bx, word ptr [cs:Open_port]
       cmp bx, COM1
       je Configurate_INT_SER
       mov al, INT_SER_PORT_1
       lea     dx, OPEN_COM_PORT_2

Configurate_INT_SER:
       call    outtext

       push es               ; сохраним старые вектора прерывания:
;       mov  al, INT_SER_PORT_?
       mov  ah, 35h
       int  21h
       mov  word ptr [cs:COM_PORT_INT_Seg], es
       mov  word ptr [cs:COM_PORT_INT_Ofs], bx
       pop  es

       push ds             ; поменяем прерывание на свое
;       mov  al, INT_SER_PORT_?
       mov  ah, 25h
       push cs
       pop  ds
       mov  dx, offset Serial_ISR
       int  21h
       pop  ds

       in  al, 21h
       mov byte ptr [cs:Old_int_mask], al

       mov bx, word ptr [cs:Open_port]
       cmp bx, COM1
       je INT_COM1
       and al, 0F7h
       jmp END_CONFIG_INT

INT_COM1:
       and al, 0EFh

END_CONFIG_INT:
       out 21h, al

       sti
       popa
       ret
Open_Serial ENDP

Close_Serial PROC near
       pusha
       cli

       ; disable the interrupt
       mov dx, word ptr [cs:Open_port]
       add dx, 4
       mov al, 0
       out dx, al

       mov dx, word ptr [cs:Open_port]
       add dx, 1
       mov al, 0
       out dx, al

       mov al, byte ptr [cs:Old_int_mask]
       out 21h, al

       mov al, INT_SER_PORT_0
       lea     dx, CLOSE_COM_PORT_1
       mov bx, word ptr [cs:Open_port]
       cmp bx, COM1
       je CLOSE_INT_SER
       mov al, INT_SER_PORT_1
       lea     dx, CLOSE_COM_PORT_2

CLOSE_INT_SER:
       call    outtext

       push ds             ; поменяем прерывание на старое
;       mov  al, INT_SER_PORT_?
       mov  ah, 25h
       push word ptr [cs:COM_PORT_INT_Seg]
       pop  ds
       mov  dx, word ptr [cs:COM_PORT_INT_Ofs]
       int  21h
       pop  ds

       sti
       popa
       ret
Close_Serial ENDP

Remember_time PROC near ; Запомним начальное значение счетчика таймера
       push eax
       push ds

       xor  ax, ax
       mov  ds, ax
       mov  eax, dword ptr [ds:046Ch]
       shr  eax, 4
       mov  dword ptr [cs:Stat_wait_time], eax

       pop  ds
       pop eax
       ret
Remember_time ENDP

Time_out PROC near ; проверим время ожидания ответа
       push eax
       push ds

       xor  ax, ax
       mov  ds, ax
       mov  eax, dword ptr [ds:046Ch]
       shr  eax, 4
       sub  eax, dword ptr [cs:Stat_wait_time]
       cmp  ax, word ptr [cs:Wait_time]

       pop  ds
       pop eax
       ret
Time_out ENDP


Wait_few_second proc near ; ax=количество 0,8 долей секунды
       push  word ptr [cs:Wait_time]

       mov word ptr [cs:Wait_time], ax
       call Remember_time
  Wait_few_time:  ; ждем ~1 сек
       call Time_out
       jb  Wait_few_time

       pop  word ptr [cs:Wait_time]
       ret

Wait_few_second ENDP


Timer_key_f proc far
       cli
       pusha

       mov ax, 500h
       mov cx, 2166h
       int 16h

       mov al, 20h
       out 20h, al

       popa
       iret

Timer_key_f endp


Serch_work_disk proc
       pusha
       push ds

       mov  ax, cs
       mov  ds, ax
       mov word ptr [cs:disk_count], 0
       mov word ptr [cs:work_disk_count], 0
       mov word ptr [cs:full_disk_count], 0
       mov byte ptr [cs:work_disk_label], 'c'

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
       mov  dx, offset Timer_key_f
       int  21h
       pop  ds

       mov cx, 24
Calkulate_work_disks:
       push cx

       ; Открываем файл-метку рабочего диска, если он есть
       mov  ax, 3d00h     ; функция DOS открытия файла для чтения
       mov  dx, offset cs:work_disk_label
       int  21h
       jc   not_work_disk

       mov bx, offset erase_disks
       add bx, word ptr [cs:work_disk_count]
       mov al, byte ptr [cs:work_disk_label]
       mov byte ptr [cs:bx], al ; заносим очередной диск в список

       ; закрываем файл конфигурации
       mov  bx, ax
       mov  ax, 3e00h
       int  21h

       inc word ptr [cs:work_disk_count] ;увеличиваем счетчик рабочих дисков
       inc word ptr [cs:full_disk_count] ;увеличиваем счетчик полных дисков

       ; проверим сколько свободного места
       mov dl, byte ptr [cs:work_disk_label]
       sub dl, 'a'  ;dl =  номер нужного диска
       inc dl
       mov ah, 36h
       int 21h

       cmp ax, 0ffffh
       je not_work_disk
       xor edx, edx
       and eax, 0ffffh
       and ecx, 0ffffh
       and ebx, 0ffffh
       mul ecx
       mul ebx
       cmp eax, 2500000 ; ~2.5 Мб
       jb not_work_disk
       ; проверили сколько свободного места

       mov bx, offset work_disks
       add bx, word ptr [cs:work_disk_count]
       sub bx, word ptr [cs:full_disk_count]
       mov al, byte ptr [cs:work_disk_label]
       mov byte ptr [cs:bx], al ; заносим очередной диск в список

       dec word ptr [cs:full_disk_count] ;уменьшаем счетчик полных дисков

not_work_disk:
       inc byte ptr [cs:work_disk_label]
       pop cx
       dec cx
       jnz Calkulate_work_disks

       mov ax, word ptr [cs:work_disk_count]
       add ax, '0'
       mov byte ptr [cs:msg_work_disk+9], al
       mov  dx, offset msg_work_disk
       call outtext

       ; вернем таймер на место
       push ds             ; поменяем прерывание на старое
       mov  al, TIMER_INT
       mov  ah, 25h
       mov  dx, word ptr [cs:timerSeg]
       mov  ds, dx
       mov  dx, word ptr [cs:timerOfs]
       int  21h
       pop  ds

Clear_kbd_buf:
       call keyboard_ready
       jz Exit_Serch_work_disk
       call keyboard_read
       jmp Clear_kbd_buf

Exit_Serch_work_disk:

       pop ds
       popa
       ret

  work_disk_count   dw   0  ; счетчик найденных рабочих дисков
  full_disk_count   dw   0  ; счетчик переполненных рабочих дисков

  work_disk_label   db   "c:\flash.dat\flash.dat",0,0

  msg_work_disk db "Найдены    диска:  "
  work_disks   db  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               db  CR, LF,'$'
  erase_disks  db  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               db  CR, LF,'$'

  disk_count  dw  0  ; текущий рабочий диск

Serch_work_disk endp

include log_file.asm
include scan.asm
include diagbort.asm

    ; ********************************************************
    ; *******  Начало основной программы (точка входа) *******
    ; ********************************************************
Start proc far
       push ds
       xor ax, ax
       push ax

       mov ax, cs
       mov ds, ax

      ; зажигаем светодиод "Исправность"
       mov al, 01
       mov dx, 0e0h
       out dx, al
      ; зажгли светодиод "Исправность"

       call Param_Table_verify
       call Param_Str_Interpretation

       ; проверка корректности введенных параметров:
       ; Open_port
       cmp word ptr [cs:Open_port], 1
       je correct_Open_port
       cmp word ptr [cs:Open_port], 2
       je correct_Open_port
       mov word ptr [cs:Open_port], 2
correct_Open_port:
       mov ax, word ptr [cs:Open_port]
       shl ax, 8
       mov cx, 4f8h
       sub cx, ax
       mov word ptr [cs:Open_port], cx

       lea     dx, Start_mesage        ; Display start message
       call    outtext

       mov word ptr [cs:Wait_time], 14

       cmp byte ptr [cs:print_help], 0
       je Reset_link
       ret

Reset_link:
       call Serch_work_disk ; считаем сколько рабочих дисков в наличии

       ; моргаемем диодом на процессорной плате в соответствие
       ; с количеством найденных рабочих дисков
       mov cx, word ptr [cs:work_disk_count]
       cmp cx, 0
       je Not_blink_led
Blink_led:
        ; ждем ~1 сек
        mov ax, 1
        call Wait_few_second ; ax=количество 0,8 долей секунды

        ; Зажигаем светодиод
        in  al, 0e5h
        or al, 80h
        out 0e5h, al

        ; ждем ~1 сек
        mov ax, 1
        call Wait_few_second ; ax=количество 0,8 долей секунды

        ; Гасим светодиод
        in  al, 0e5h
        and al, 7fh
        out 0e5h, al

        LOOP Blink_led
Not_blink_led:
       ; проморгались диодом на процессорной плате

       call Open_Serial

       call Remember_time

 Wait_read:  ; ждем сигнала с COM-порта
       call Read_Serial
       cmp  ah, 0
       jne  Normal_link

        ; проверим время ожидания ответа
       call Time_out
       jb  Wait_read

       jmp Work_mode

Normal_link:
       cmp al, 'f'
       jne Not_first_char_of_message
       mov byte ptr [Send_count], 0

       xor bx, bx
       mov bl, byte ptr [cs:Send_count]
       add bx, offset Send_mesage
       mov ah, byte ptr [cs:bx]
       call Write_Serial
       inc byte ptr [cs:Send_count]
       jmp Wait_read

Not_first_char_of_message:
       cmp al, 'n'
       jne Not_next_char_of_mesage
       xor bx, bx
       mov bl, byte ptr [cs:Send_count]
       add bx, offset Send_mesage
       mov ah, byte ptr [cs:bx]
       call Write_Serial
       inc byte ptr [cs:Send_count]
       jmp Wait_read

Not_next_char_of_mesage:
       cmp al, 'e'
       jne Not_Request_Error

       mov ah, byte ptr [cs:work_disk_count]
       shl ah, 4
       add ah, byte ptr [cs:full_disk_count]
       call Write_Serial
       jmp Wait_read

Not_Request_Error:
       cmp al, 'm'
       jne Wait_read

 read_tail: ; дочитываем остатки (хвост)
       call Read_Serial
       cmp  ah, 0
       jne read_tail

       mov word ptr [cs:Wait_time], 0FFFFh

Main_cikl:
       call Read_Serial ; ждем команды
       cmp  ah, 0
       je  Main_cikl

       cmp al, '1'
       jne Compare_2
Work_mode:
       call Close_Serial
       mov bx, word ptr [cs:full_disk_count]
       sub word ptr [cs:work_disk_count], bx
       cmp word ptr [cs:work_disk_count], 0
       je  Start_watchdog_timer
       mov byte ptr [cs:Pressure_flag], 0 ; 0-без контроля давления;
                                          ; 1-с выключением по давлению
       call Scan         ; Работа в трубе
       ret

Compare_2:
       cmp al, '2'  ; выход в DOS
       je Exit_prog

       cmp al, '3' ; Диагностика
       jne Compare_4
       call Diagnostika_bort
       jmp Reset_link

Compare_4:
       cmp al, '4' ; Перегрузить борт
       jne Compare_5

       call Close_Serial

Start_watchdog_timer:
       ; запускаем "watchdog timer" и ждем когда он перегрузит компутер
       in  al, 0e5h
       or  al, 1
       out 0e5h, al

       ret

Compare_5:
       cmp al, '5'        ; пересчитаем рабочие диски
       jne Compare_6
       call Close_Serial
       jmp Reset_link

Compare_6:
       cmp al, '6' ; Стирание данных
       jne Compare_7
       call Close_Serial

debug_label:
       ; стираем файлы scan.log и scan.sav
       push ds
       mov ax, cs
       mov ds, ax

       mov ah, 41h
       mov dx, offset file_cfg
       int 21h

       mov ah, 41h
       mov dx, offset file_log
       int 21h

       ; очистка рабочих дисков:
       mov bx, offset file_data
       mov di, offset delete_data
       mov cx, 7
Copy_data_disk_name_to_delete_disk:
       mov ax, word ptr [cs:bx]
       mov word ptr [cs:di], ax
       add bx, 2
       add di, 2
       LOOP Copy_data_disk_name_to_delete_disk

       mov  ax, offset [cs:file_data]   ; выставим указатель на номер
       add  ax, 2                       ; файла
       mov  word ptr [cs:num_file_data], ax

       mov word ptr [cs:disk_count], 0

       mov cx, word ptr [cs:work_disk_count]
       cmp cx, 0
       jz Not_delete_more

delete_next_data:
       push cx

        ; включим следующий диск из списка
       mov bx, offset erase_disks
       add bx, word ptr [cs:disk_count]
       mov dl, byte ptr [cs:bx]
       sub dl, 'a'  ;dl =  номер нужного диска
       mov ah, 0Eh
       int 21h

       mov cx, 2000

Delete_dat_files:
       mov ah, 41h ; удаляем
       mov dx, offset file_data
       int 21h

       call CHANGE_FILE

       LOOP Delete_dat_files

       inc word ptr [cs:disk_count]

       ; восстанавливаем имя рабочих дисков
       mov bx, offset file_data
       mov di, offset delete_data
       mov cx, 7
Copy_delete_disk_name_to_data_disk:
       mov ax, word ptr [cs:di]
       mov word ptr [cs:bx], ax
       add bx, 2
       add di, 2
       LOOP Copy_delete_disk_name_to_data_disk

       pop cx
       LOOP delete_next_data

Not_delete_more:

       pop ds
       mov word ptr [cs:disk_count], 0

       mov dl, 'h'-'a'  ; возвращаемся на системный диск
       mov ah, 0Eh
       int 21h

       jmp Reset_link

Compare_7:
       cmp al, '7' ; Работа без контроля давления
       jne Main_cikl
       call Close_Serial
       mov bx, word ptr [cs:full_disk_count]
       sub word ptr [cs:work_disk_count], bx
       cmp word ptr [cs:work_disk_count], 0
       je Start_Watchdog_Timer
       mov byte ptr [cs:Pressure_flag], 0 ; 0 - работа без контроля давления
       call Scan         ; Работа в трубе
       ret

       jmp Reset_link

Exit_prog:
       call Close_Serial
       ret

Start ENDP

Open_port          DW   COM2 ; порт с которым работаем
Old_int_mask       DB   0    ; старая маска прерывания
Wait_time          DW   14    ; время ожиданя связи ~ в 0.88 секунды
Stat_wait_time     DD   0    ; стартовое время счетчика таймера

COM_PORT_INT_Ofs   DW   ?   ;
COM_PORT_INT_Seg   DW   ?   ;

OPEN_COM_PORT_1  db  CR,LF,"Opening Communications Channel Com Port #1...",CR,LF,'$'
OPEN_COM_PORT_2  db  CR,LF,"Opening Communications Channel Com Port #2...",CR,LF,'$'

CLOSE_COM_PORT_1 db  CR,LF,"Closing Communications Channel Com Port #1...",CR,LF,'$'
CLOSE_COM_PORT_2 db  CR,LF,"Closing Communications Channel Com Port #2...",CR,LF,'$'

Message_str        db 'Пришел байт:              ', CR, LF, '$'
Message_Wait_link  db 'Ждем символ с бамбука', CR, LF, '$'

Send_mesage   db  'Bort', 0
Send_count    db  0

delete_data db 32 dup (0)


print_help      DB    0
Start_mesage    DB  " Бортовая программа для блока ZIATECH.",CR,LF
                DB  " 7 февраля 2003 года. ""ГАЗПРИБОРАВТОМАТИКАСЕРВИС"".",CR,LF
                DB  " При запуске программы возможно использование параметров:" ,CR,LF
;                DB  "   /Del_bit=x (1)  количество обрезаемых при архивации битов (1..7),",CR,LF
;                DB  "     /Del_bit=0 - полностью отключается режим архивирования;",CR,LF
                DB  "   /COM=x (2) номер СОМ порта для связи (1 или 2);",CR,LF
                DB  "   /BaseSkip=x (0)  базовое прореживание одометра;",CR,LF
;                DB  "   /Dat64 - записывать только 64 датчика из 128 (через 1); ",CR,LF
                DB  "   /h - вывести на экран текст напечатанный выше.         ",CR,LF
                DB  CR,LF,'$'


 PARAM_TABLE_Init  ; Начало объявления таблицы параметров
                ;  имя      ; тип         ;длинна ;Метка      ; Имя
                ;в строке   ; переменной  ;  в    ;переменной ;сегмента
                ;параметров ;             ;байтах ;в тексте   ;перемеенной

 PARAM_TABLE_Define COM,     PAR_TYPE_INTEGER, 2, Open_port  , CODE
           ; /COM=x номер СОМ порта для связи (1 или 2)

 PARAM_TABLE_Define BaseSkip,PAR_TYPE_INTEGER, 2, Odom_skip  , CODE
           ; /BaseSkip=x прореживание измерений

 PARAM_TABLE_Define H, PAR_TYPE_BOOLEAN, 1, print_help  , CODE
           ; /h - вывести на экран текст напечатанный выше.

CODE ENDS

END Start

