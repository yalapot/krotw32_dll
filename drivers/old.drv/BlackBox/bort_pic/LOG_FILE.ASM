itoa32  PROC near
      ; eax   - число для конвертации (интерпретируется как беззнаковое)
      ; ds:di - указатель на результирующую строку (обязательно
      ;         резервировать 10 символов, в них помешается результат с
      ;         выравниванием вправо)
      ; ebx   - база представления числа (10 - десятичная)

      push edx
      push eax
      push ebx
      push ecx
      push di

      mov cx, 10 ; заполняем приготовленную строку пробелами
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
      ja Convert_itoa ; если выше

itoa32_exit:
      pop di
      pop ecx
      pop ebx
      pop eax
      pop edx
      ret
itoa32  ENDP

itoa_16 PROC near ; ax=число; es:di = указатель на строку
      pusha

      xor bp, bp ; флаг незначащего нуля вначале
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
      ja Non_num_1  ; если выше
      add dl, '0'
      mov byte ptr [es:di], dl
      inc di
      jmp Second_num
Non_num_1: ; не цифра, т.е. буква (a, b, c, d, e или f)
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
      ja Non_num_2  ; если выше
      add dl, '0'
      mov byte ptr [es:di], dl
      inc di
      jmp Third_num
Non_num_2: ; не цифра, т.е. буква (a, b, c, d, e или f)
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
      ja Non_num_3  ; если выше
      add dl, '0'
      mov byte ptr [es:di], dl
      inc di
      jmp Fourth_num
Non_num_3: ; не цифра, т.е. буква (a, b, c, d, e или f)
      add dl, 'a'-0ah
      mov byte ptr [es:di], dl
      inc di

Fourth_num:
      mov dl, al
      and dl, 0Fh
      cmp dl, 9
      ja Non_num_4  ; усли выше
      add dl, '0'
      mov byte ptr [es:di], dl
      jmp Complete_itoa
Non_num_4: ; не цифра, т.е. буква (a, b, c, d, e или f)
      add dl, 'a'-0ah
      mov byte ptr [es:di], dl

Complete_itoa:

      popa
      ret
itoa_16 ENDP


get_date PROC near
     pusha
     ; читаем дату из часов реального времени
     mov ah, 4h
     int 1Ah
  ; пишем день месяца
     mov al, dl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string], al ; старшая цифра
     mov al, dl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+1], al ; младшая цифра
  ; пишем месяц
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+3], al ; старшая цифра
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+4], al ; младшая цифра
  ; пишем век
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+6], al ; старшая цифра
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+7], al ; младшая цифра
  ; пишем год
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+8], al ; старшая цифра
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+9], al ; младшая цифра

     mov  ax, 4000h
     mov  bx, word ptr [cs:log_descriptor]
     mov  cx, 12
     mov  dx, offset cs:date_string
     int  21h
     popa
     ret

date_string     DB    0,0,'/',0,0,'/',0,0,0,0,', '
save_date_message  DB  'дата ',0
get_date ENDP

get_time PROC near
     pusha
     ; читаем время из часов реального времени
     mov ah, 2h
     int 1Ah
  ; пишем часы
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string], al ; старшая цифра
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+1], al ; младшая цифра
  ; пишем минуты
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+3], al ; старшая цифра
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+4], al ; младшая цифра
  ; пишем секунды
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+6], al ; старшая цифра
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+7], al ; младшая цифра

     mov  ax, 4000h
     mov  bx, word ptr [cs:log_descriptor]
     mov  cx, 10
     mov  dx, offset cs:time_string
     int  21h

     popa
     ret

time_string     DB    0,0,':',0,0,':',0,0,'   '
save_time_message  DB  'время ',0
get_time ENDP

print_date_real PROC near       ; dl - день месяца
     pusha                 ; dh - месяц
  ; пишем день месяца      ; ch - век
     mov al, dl            ; cl - год
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string], al ; старшая цифра
     mov al, dl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+1], al ; младшая цифра
  ; пишем месяц
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+3], al ; старшая цифра
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+4], al ; младшая цифра
  ; пишем век
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+6], al ; старшая цифра
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+7], al ; младшая цифра
  ; пишем год
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:date_string+8], al ; старшая цифра
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:date_string+9], al ; младшая цифра

     mov  ax, 4000h
     mov  bx, word ptr [cs:log_descriptor]
     mov  cx, 12
     mov  dx, offset cs:date_string
     int  21h
     popa
     ret

print_date_real ENDP

print_time_real PROC near            ; ch - часы
     pusha                      ; cl - минуты
  ; пишем часы                  ; dh - секунды
     mov al, ch
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string], al ; старшая цифра
     mov al, ch
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+1], al ; младшая цифра
  ; пишем минуты
     mov al, cl
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+3], al ; старшая цифра
     mov al, cl
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+4], al ; младшая цифра
  ; пишем секунды
     mov al, dh
     shr al, 4
     add al, '0'
     mov byte ptr [cs:time_string+6], al ; старшая цифра
     mov al, dh
     and al, 0Fh
     add al, '0'
     mov byte ptr [cs:time_string+7], al ; младшая цифра

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

  ; открываем log-файл, если он уже существует
       mov  ax, cs  ; откроем существующий файл
       mov  ds, ax
       mov  ah, 3dh        ; функция DOS открытия файла
       mov  al, 02         ; обычный файл
       mov  dx, offset cs:file_log  ;
       int  21h
       jc   No_log_file
       mov  word ptr [cs:log_descriptor], ax

       ; переместим указатель записи на конец
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h

       jmp Write_about_begin

No_log_file:
  ;  создание log-файла
       mov  ax, 3c00h      ; функция DOS создания файла
       mov  cx, 00         ; обычный файл
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; пишем в файл заголовок созданного файла файла
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 53 ; 53 символов
       mov  dx, offset cs:Head_log
       int  21h

Write_about_begin:
       call get_date  ; пишем в log-файл текущую дату из часов реального времени
       call get_time  ; пишем в log-файл текущее время из часов реального времени

       ; пишем в log-файл сообщение о входе в программу
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 39  ; 39 символов
       mov  dx, offset cs:Begin_mesage
       int  21h

       ; закрываем log-файл
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; закончили создавать log-файл

Close_Create_log_file:

       popa
       pop  ds
       ret

Head_log       DB   '     Протокол движения по трассе снаряда КРОТ-700 '
               DB   CR, LF, CR, LF,0
Begin_mesage   DB   'Запуск бортовой программы КРОТ-700  '
               DB   CR, LF, CR, LF,0
Create_log_file ENDP

Print_track PROC near     ; eax <= длинна  в сантиметрах
       pushad
       push ds
       push eax

       mov ax, cs
       mov ds, ax

       ; пишем в файл сообщение о пройденном пути
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 10  ; 10 символов
       mov  dx, offset cs:Track_length_message
       int  21h

        ; конвертируем длинну сантиметров в строку
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

        ; конвертируем длинну метров в строку
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

        ; конвертируем длинну километров в строку
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
       mov  cx, 21  ; 21 символов
       mov  dx, offset cs:Track_length_km
       int  21h
       jmp  End_print_length

Print_m:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 14  ; 14 символов
       mov  dx, offset cs:Track_length_m
       int  21h
       jmp  End_print_length

Print_sm:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 7  ; 7 символов
       mov  dx, offset cs:Track_length_sm
       int  21h

End_print_length:

       ;  выведем в log-файл путь PIC-процессора.
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 63
       mov  dx, offset cs:Pic_track
       int  21h

       pop ds
       popad
       ret

 Pic_track  db  ' Общ:           ; I од.:           ; II од.:           .     ', CR, LF

Track_length_message  DB   ' Пройдено '
Track_length_km       db   '     км'
Track_length_m        db   '     м '
Track_length_sm       db   '   см'
                      DB   CR, LF, 0

tmp_str  db 60 dup (' ')
         db  CR, LF, '$'

Print_track ENDP

Print_time PROC near  ; eax=время в секундах
     pushad

        ; конвертируем секунды в строку
       xor edx, edx
       mov di, offset cs:tmp_str
       mov ebx, 10  ;
       mov ecx, 60
       div ecx
       xchg edx, eax
       call itoa32
       mov bx, word ptr [cs:tmp_str+9]
       mov word ptr [cs:Time_stop_sec], bx

        ; конвертируем минуты в строку
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

        ; конвертируем часы в строку
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
       mov  cx, 25  ; 27 символов
       mov  dx, offset cs:Time_stop_haur
       int  21h
       jmp  End_print_time

Print_min:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 16  ; 18 символов
       mov  dx, offset cs:Time_stop_min
       int  21h
       jmp  End_print_time

Print_sek:
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 9  ; 9 символов
       mov  dx, offset cs:Time_stop_sec
       int  21h

End_print_time:
       popad
       ret

Time_stop_haur      db   '     час '
Time_stop_min       db   '   мин '
Time_stop_sec       db   '   сек '
                    db   CR, LF,0
Print_time ENDP

Print_speed PROC near

        ; конвертируем скорость в строку
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
       mov  cx, 15  ; 15 символов
       mov  dx, offset cs:speed_metr_sec
       int  21h
       ret

speed_metr_sec     db   '    .    м/с '
                   db   CR, LF,0,0,0
Print_speed ENDP

Save_not_pressure PROC near
       push ds
       pusha

       cmp word ptr [cs:Call_Save_not_pressure_counter], 21
       jae Close_Create_log_file

       inc word ptr [cs:Call_Save_not_pressure_counter]

  ; открываем log-файл
       mov  ax, cs  ; откроем существующий файл
       mov  ds, ax
       mov  ax, 3d02h        ; функция DOS открытия файла
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; переместим указатель записи на конец
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h
;       jc   error11

       call get_date  ; пишем в log-файл текущую дату из часов реального времени
       call get_time  ; пишем в log-файл текущее время из часов реального времени

       ; пишем в файл сообщение об отключении давления
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 39 ; 39 символов
       mov  dx, offset cs:Not_pressure_message
       int  21h

       ; пишем в файл сообщение о времени движения
       push eax
       push edx
       push ecx
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 16  ; 16 символов
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
       ; закончили писать в файл сообщение о времени движения

       ; пишем в файл сообщение о средней скорости
       push eax
       push edx
       push ecx
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 19  ; 16 символов
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
       ; закончили писать в файл сообщение о средней скорости

       call Get_PIC_track
       mov eax, dword ptr [cs:track]
       call Print_track

       ; переход на новую строку
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 символа
       mov  dx, offset cs:New_Line
       int  21h

       ; закрываем log-файл
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; закончили писать в log-файл

Close_Save_not_pressure:
       popa
       pop  ds
       ret

Not_pressure_message  DB   'Сработал датчик отключения давления  '
                      DB   CR, LF,0,0,0
Time_go_message       DB   ' Время движения    '
Speed_go_message      DB   ' Средняя скорость    '
time_go_sec           DD   1

Call_Save_not_pressure_counter dw 0

Save_not_pressure ENDP

Save_yes_pressure PROC near
       push ds
       pusha

       cmp word ptr [cs:Call_Save_not_pressure_counter], 21
       jae Close_Save_Yes_pressure

  ; открываем log-файл
       mov  ax, cs  ; откроем существующий файл
       mov  ds, ax
       mov  ah, 3dh        ; функция DOS открытия файла
       mov  al, 02         ; обычный файл
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; переместим указатель записи на конец
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h
;       jc   error11

       call get_date  ; пишем в log-файл текущую дату из часов реального времени
       call get_time  ; пишем в log-файл текущее время из часов реального времени

       ; пишем в файл сообщение об отключении давления
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 39 ; 39 символов
       mov  dx, offset cs:Yes_pressure_message
       int  21h

       call Get_PIC_track
       mov eax, dword ptr [cs:track]
       call Print_track

       ; переход на новую строку
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 символа
       mov  dx, offset cs:New_Line
       int  21h

       ; закрываем log-файл
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; закончили писать в log-файл

Close_Save_Yes_pressure:
       popa
       pop  ds
       ret

Yes_pressure_message  DB   'Сработал датчик включения давления   '
                      DB   CR, LF,0,0,0

Save_yes_pressure ENDP

Save_stop_spead PROC near
       push ds
       pusha

  ; открываем log-файл
       mov  ax, cs  ; откроем существующий файл
       mov  ds, ax
       mov  ah, 3dh        ; функция DOS открытия файла
       mov  al, 02         ; обычный файл
       mov  dx, offset cs:file_log  ;
       int  21h
       mov  word ptr [cs:log_descriptor], ax

       ; переместим указатель записи на конец
       mov  ah, 42h
       mov  bx, word ptr [cs:log_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 2
       int  21h
;       jc   error11

       ; пишем в файл сообщение об остановке снаряда
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 21 ; 21 символов
       mov  dx, offset cs:Stop_spead_message
       int  21h

       ; пишем в файл сообщение о времени стоянки
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 15 ; 15 символов
       mov  dx, offset cs:Stoping_time_message
       int  21h

       mov eax, dword ptr[cs:Stop_time]
       xor edx, edx
       mov ebx, 100
       div ebx
       call Print_time

       ; пишем в файл сообщение о начале остановки снаряда
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 19  ; 19 символов
       mov  dx, offset cs:Time_stop_message
       int  21h

       mov cx, word ptr [cs:Beg_date_stop]
       mov dx, word ptr [cs:Beg_date_stop+2]
       call Print_date_real

       mov cx, word ptr [cs:Beg_time_stop]
       mov dx, word ptr [cs:Beg_time_stop+2]
       call Print_time_real

       ; переход на новую строку
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 символа
       mov  dx, offset cs:New_Line
       int  21h

       mov eax, dword ptr [cs:Stop_track]
       call Print_track

       ; переход на новую строку
       mov  ax, 4000h
       mov  bx, word ptr [cs:log_descriptor]
       mov  cx, 2  ; 2 символа
       mov  dx, offset cs:New_Line
       int  21h

       ; закрываем log-файл
       mov  ax, 3e00h
       mov  bx, word ptr [cs:log_descriptor]
       int  21h
   ; закончили писать в log-файл

Close_Save_stop_spead:
       popa
       pop  ds
       ret

Stop_spead_message  DB   'Остановка снаряда  '
                    DB   CR, LF,0,0,0
Stoping_time_message  DB  ' Время стоянки  '
                      DB   CR, LF,0,0,0
Time_stop_message   DB   ' Начало  стоянки    '
New_Line            DB   CR, LF,0,0,0
Save_stop_spead ENDP

