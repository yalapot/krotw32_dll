  ; начинаем чтение файла конфигурации
       push ds
       mov  ax, cs
       mov  ds, ax

       ; Открываем файл конфигурации, если он есть
       mov  ax, 3d00h        ; функция DOS открытия файла для чтения
       mov  dx, offset cs:file_cfg  ;
       int  21h
       jc   no_file
       mov  word ptr [cs:cfg_descriptor], ax

       mov  ah, 42h   ; возвращаем указатель на начало файла
       mov  bx, word ptr [cs:cfg_descriptor]
       xor  cx, cx
       xor  dx, dx
       mov  al, 0
       int  21h
       jc   no_file

       ; читаем из файла время
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6
       mov  dx, offset cs:time
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

       ; читаем из файла последнее значение положения
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:old_pos
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; читаем из файла пройденное расстояние, кол-во буферов, кол-во блоков в буфере
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6+2+2
       mov  dx, offset cs:track
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; читаем из файла флаги занятости буферов
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 20
       mov  dx, offset cs:beasy_buf
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; читаем из файла номер буфера чтения, счетчики блоков и записей
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2+2
       mov  dx, offset cs:read_buf
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

 ; читаем из файла время и расстояние на последнем измерении
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4+4
       mov  dx, offset cs:last_time
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

       ; читаем из файла имя текущего файла с данными
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 16
       mov  dx, offset cs:file_data
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

      ; читаем из файла номер буфера записи и счетчик записанных буферов
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2
       mov  dx, offset cs:write_buf
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

      ; читаем из файла реальное количество записей в буфере
       mov  ax, 3F00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:reserved
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; читаем из файла значение предыдущего расстояния при анализе открытия файла
       mov  ax, 3f00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4
       mov  dx, offset pred_track
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; читаем из файла имя последнего рабочего диска
       mov  ax, 3f00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset last_wrk_dsk
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; читаем из файл последний рабочий заголовок блока
       mov  ax, 3f00h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 15
       mov  dx, offset cs:Block
       inc  dx
       int  21h
       jc   no_file
       cmp cx, ax
       jne  no_file

     ; читаем из файла последний рабочий буфер
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

       ; закрываем файл конфигурации
       mov  ax, 3e00h
       mov  bx, word ptr [cs:cfg_descriptor]
       int  21h

       mov  word ptr [cs:serch_cfg_file], 0
       jmp  End_load_cfg

   ; закончили читать файл конфигурации
no_file:
       mov  word ptr [cs:serch_cfg_file], 1

End_load_cfg:
       ; Удаляем файл конфигурации, если он есть
       mov  ax, 4100h        ; функция DOS удаления файла
       mov  dx, offset cs:file_cfg  ;
       int  21h

       pop  ds
