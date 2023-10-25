  ; начинаем создание файла конфигурации
       push ds
       mov  ax, cs
       mov  ds, ax

       ; Открываем файл конфигурации
       mov  ax, 3c00h        ; функция DOS создания файла
       mov  cx, 00         ; обычный файл
       mov  dx, offset cs:file_cfg  ;
       int  21h
;       jc   error11
       mov  word ptr [cs:cfg_descriptor], ax

       ; пишем в файл время
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6
       mov  dx, offset cs:time
       int  21h
;       jc   error21
;       cmp  ax, 6h
;       jne  error31

       ; пишем в файл последнее значение положения
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:old_pos
       int  21h
;       jc   error21
;       cmp  ax, 1
;       jne  error31

 ; пишем в файл пройденное расстояние, кол-во буферов, кол-во блоков в буфере
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 6+2+2
       mov  dx, offset cs:track
       int  21h
;       jc   error21
;       cmp  ax, 6+2+2
;       jne  error31

 ; пишем в файл флаги занятости буферов
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 20
       mov  dx, offset cs:beasy_buf
       int  21h
 ;      jc   error21
  ;     cmp  ax, 20
   ;    jne  error31

 ; пишем в файл номер буфера чтения, счетчики блоков и записей
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2+2
       mov  dx, offset cs:read_buf
       int  21h
;       jc   error21
 ;      cmp  ax, 2+2+2
  ;     jne  error31

 ; пишем в файл время и расстояние на последнем измерении
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4+4
       mov  dx, offset cs:last_time
       int  21h
;       jc   error21
 ;      cmp  ax, 4+4
  ;     jne  error31

       ; пишем в файл имя текущего файла с данными
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 16
       mov  dx, offset cs:file_data
       int  21h
;       jc   error21
 ;      cmp  ax, 10h
  ;     jne  error31

 ; пишем в файл номер буфера записи и счетчик записанных буферов
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 2+2
       mov  dx, offset cs:write_buf
       int  21h
;       jc   error21
 ;      cmp  ax, 2+2
  ;     jne  error31

 ; пишем в файл реальное количество записей в буфере
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset cs:reserved
       int  21h
;       jc   error21
 ;      cmp  ax, 2+2
  ;     jne  error31

 ; пишем в файл значение предыдущего расстояния при анализе открытия файла
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 4
       mov  dx, offset pred_track
       int  21h

 ; пишем в файл имя последнего рабочего диска
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 1
       mov  dx, offset last_wrk_dsk
       int  21h

 ; пишем в файл последний рабочий заголовок блока
       mov  ax, 4000h
       mov  bx, word ptr [cs:cfg_descriptor]
       mov  cx, 15
       mov  dx, offset cs:Block
       inc  dx
       int  21h

 ; пишем в файл последний рабочий буфер
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

       ; закрываем файл конфигурации
       mov  ax, 3e00h
       mov  bx, word ptr [cs:cfg_descriptor]
       int  21h

       pop  ds
   ; закончили создавать файл конфигурации
