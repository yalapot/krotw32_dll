;                                       /*****************/
; Par_tabl.asm                          /*        /|     */
; Copyright (C) by SDASoft 1999         /*  ____/  │     */
;                                       /*  \    !  \    */
;-------------------------------------  /*    \  ║ ___\  */
; Объявление таблицы параметров для     /*     │  /      */
; интерпретации из командной строки     /*     |/        */
;-------------------------------------  /*****************/

;LF             equ     10      ;Linefeed
;CR             equ     13      ;Carriage Return

MAX_PARAMETR_IN_TAB   equ 21

  ; Поле идентификации параметра
  ;  возможные типы переменных в параметрах :
PAR_TYPE_INTEGER   equ   'i'   ; - целое число
PAR_TYPE_CHAR      equ   'c'   ; - символ
PAR_TYPE_STRING    equ   's'   ; - строка
PAR_TYPE_BOOLEAN   equ   'b'   ; - логическая (Bulean равно 0 или не равно 0)
PAR_TYPE_FLOAT     equ   'f'   ; - действительное число (дробная часть отделяется точкой)

PARAM_TABLE_Init  MACRO
   atoi_32 PROC far ; ds:bx - указатель на строку; eax - результат
      push ds
      pusha

      mov dword ptr [cs:Res_atoi_32], 0

      mov cx, 0
   Count_number:
      cmp byte ptr [ds:bx], '0'
      jb Convert_atoi
      cmp byte ptr [ds:bx], '9'
      ja Convert_atoi
      inc cx
      inc bx
      jmp Count_number

   Convert_atoi:
      cmp cx, 0
      je Exit_atoi_32
      mov ebp, 0
      mov edi, 1

      cmp cx, 9
      jbe Next_number
      mov cx, 9
      ;  ???????

   Next_number:
      dec bx
      xor eax, eax
      mov al, byte ptr [ds:bx]
      sub al, '0'
      mul edi
      add ebp, eax
      mov eax, 10
      mul edi
      mov edi, eax
   LOOP Next_number
      mov dword ptr [cs:Res_atoi_32], ebp

   Exit_atoi_32:
      popa
      pop ds
      mov eax, dword ptr [cs:Res_atoi_32]
      ret

   Res_atoi_32 DD 0
   atoi_32 ENDP

   Char_to_Upper_Case PROC far  ; переводит символ находящийся в al
      cmp al, 'a'               ; в верхний регистр
      jb Complete_Upper_Case
      cmp al, 'z'
      ja Complete_Upper_Case
      sub al, ('a'-'A')

    Complete_Upper_Case:
      ret
   Char_to_Upper_Case ENDP

   Param_Str_Interpretation proc far
       push ds
       pusha

       ; вызов функции DOS, возвращающей в ES:BX указатель на переданную
       ; программе строку параметров
       mov  ah, 2Fh
       int 21h

       cmp byte ptr [es:bx], 1
       jbe Not_parametrs

       mov di, bx
       inc di ; указатель на начало строки параметров
       mov word ptr [cs:Begin_Cur_par_pointer], di
       mov si, offset Begin_real_param
   Count_param_str:
       ; ищем начало идентификатора параметра в переданной строке
       cmp byte ptr [es:di], '/'
       je Yes_begin
       inc di
       mov ax, di  ; проверим не закончилась ли строка параметров
       sub ax, word ptr [cs:Begin_Cur_par_pointer]
       cmp al, byte ptr [es:bx]
       jae Complet_Count_param
       jmp Count_Param_str

   Yes_begin:
       mov word ptr [cs:si], di
       add si, 2
        ; пересчитать количество символов в имени и записать на место
        ; символа '/'
        push bx
        mov bx, di
        inc bx
        push di
     Name_len_str:
        inc di
        mov al, byte ptr [es:di]
        call Char_to_Upper_Case
        mov byte ptr [es:di], al
        cmp byte ptr [es:di], 0Dh  ; Enter
        je Yes_delimmiter
        cmp byte ptr [es:di], ' '
        je Yes_delimmiter
        cmp byte ptr [es:di], '='
        jne Name_len_str
    Yes_delimmiter:
        sub di, bx
        mov ax, di
        pop di
        mov byte ptr [es:di], al
        inc di
        pop bx
        ; ---------- закончили пересчет длинны имени
       inc word ptr [cs:PARAM_REAL_COUNTER]
       cmp word ptr [cs:PARAM_REAL_COUNTER], MAX_PARAMETR_IN_TAB
       jae Complet_Count_param
       jmp Count_Param_str

   Complet_Count_param:

       mov bx, 0   ; номер пар. в таблице
       mov cx, word ptr [cs:PARAM_REAL_COUNTER] ; кол-во пар. в строке
   Set_param_value:
       mov ax, 2
       mov bp, cx
       dec bp
       mul bp
       mov bp, ax
       mov di, word ptr [cs:Begin_real_param+bp] ; параметр из строки

       mov ax, 2
       mul bx
       mov bp, ax
       mov si, word ptr [cs:Begin_define_param+bp] ; параметр из таблицы

    Compare_name:
       mov al, byte ptr [es:di]
       cmp al, byte ptr [cs:si]
       jne Test_End_Name
       inc di
       inc si
       jmp Compare_name

    Test_End_Name:
       mov al, byte ptr [cs:si]
       cmp al, 0
       jne Name_Not_ekvival
       mov al, byte ptr [es:di]
       cmp al, '='
       je Set_value
       cmp al, ' '
       je Name_ekvival
       cmp al, 0Dh ; Enter
       jne Name_Not_ekvival

     Name_ekvival:
       inc si
       cmp byte ptr [cs:si], PAR_TYPE_BOOLEAN
       jne Bad_Boolean
       push ds
       push bx
       add si, 5
       mov ax, word ptr [cs:si]
       mov ds, ax
       sub si, 2
       mov bx, word ptr [cs:si]
       mov byte ptr [ds:bx], 0FFh
       pop bx
       pop ds
       jmp Go_to_next_param

     Bad_Boolean:
        ; ... Вывести сообщение о несоответствии типа переменной (Boolean)
       jmp Go_to_next_param

     Set_value:
       inc si
       inc di
       cmp byte ptr [cs:si], PAR_TYPE_INTEGER
       je Set_Integer
       cmp byte ptr [cs:si], PAR_TYPE_CHAR
       je Set_Char
       cmp byte ptr [cs:si], PAR_TYPE_STRING
       je Set_String
       cmp byte ptr [cs:si], PAR_TYPE_BOOLEAN
       je Set_Boolean
       cmp byte ptr [cs:si], PAR_TYPE_FLOAT
       je Set_Float
        ; ... Вывести сообщение о несоответствии типа переменной

     Set_Integer:
       push ds
       push bx
       mov bx, es
       mov ds, bx
       mov bx, di
       call atoi_32  ;ds:bx - указатель на строку; eax - результат

       add si, 5
       mov bx, word ptr [cs:si]
       mov ds, bx
       sub si, 2
       mov bx, word ptr [cs:si]
       sub si, 2
       cmp word ptr [cs:si], 1
       jne int_2_bytes
       mov byte ptr [ds:bx], al
       pop bx
       pop ds
       jmp Go_to_next_param

     int_2_bytes:
       cmp word ptr [cs:si], 2
       jne int_4_bytes
       mov word ptr [ds:bx], ax
       pop bx
       pop ds
       jmp Go_to_next_param

     int_4_bytes:
       mov dword ptr [ds:bx], eax
       pop bx
       pop ds
       jmp Go_to_next_param

     Set_Char:
       push ds
       push bx
       add si, 5
       mov ax, word ptr [cs:si]
       mov ds, ax
       sub si, 2
       mov bx, word ptr [cs:si]
       mov al, byte ptr [es:di]
       mov byte ptr [ds:bx], al
       pop bx
       pop ds
       jmp Go_to_next_param

     Set_Boolean:
       push ds
       push bx
       add si, 5
       mov ax, word ptr [cs:si]
       mov ds, ax
       sub si, 2
       mov bx, word ptr [cs:si]
       mov byte ptr [ds:bx], 0FFh
       mov al, byte ptr [es:di+1]
       call Char_to_Upper_Case
       cmp  al, 'N'
       je Complete_set_boolean
       mov byte ptr [ds:bx], 0
Complete_set_boolean:
       pop bx
       pop ds
       jmp Go_to_next_param

     Set_String:
       push ds
       push bx
       push cx
       add si, 5
       mov ax, word ptr [cs:si]
       mov ds, ax
       sub si, 2
       mov bx, word ptr [cs:si]
       sub si, 2
       mov cx, word ptr [cs:si]
       inc di
 Copy_param_string:
       mov al, byte ptr [es:di]
       cmp al, 34 ; символ "
       je Complete_copy_param_string
       mov byte ptr [ds:bx], al
       inc di
       inc bx
       LOOP Copy_param_string

 Complete_copy_param_string:
       pop cx
       pop bx
       pop ds
       jmp Go_to_next_param

     Set_Float:
         ; ...
       jmp Go_to_next_param

     Name_Not_ekvival:
       inc  bx
       cmp  bx, word ptr [cs:PARAM_DEFINE_COUNTER]
       jb Set_param_value
     Go_to_next_param:
       mov bx, 0
;       LOOP Set_param_value
       dec cx
       cmp cx, 0
       jne Set_param_value

   Not_parametrs:
        popa
        pop ds
        ret

     Begin_real_param    dw  MAX_PARAMETR_IN_TAB dup (0)
     PARAM_REAL_COUNTER  dw  0
     Begin_Cur_par_pointer dw 0
   Param_Str_Interpretation ENDP

   Param_Table_verify   proc    far
        pusha
        ;  пересчитаем сколько параметров описано в таблице

        mov di, offset PARAM_DEFINE_COUNTER
        add di, 2
        mov si, di
        mov bx, offset Begin_define_param
     Begin_count_param:

       ; проверим сколько байтов просканировано, если больше 49 - выходим
        mov ax, si
        add ax, 49
        cmp di, ax
        ja Exit_Param_Table_verify

        ; serch "/BPF"
        cmp byte ptr [cs:di], '/'
        jne Not_BPF
        inc di
        cmp byte ptr [cs:di], 'B'
        jne Not_BPF
        inc di
        cmp byte ptr [cs:di], 'P'
        jne Not_BPF
        inc di
        cmp byte ptr [cs:di], 'F'
        jne Not_BPF
        mov si, di
        inc word ptr [cs:PARAM_DEFINE_COUNTER]
        mov word ptr [cs:bx], di
        add bx, 2
        ; пересчитать количество символов в имени и записать на место
        ; символа 'F'
        push bx
        mov bx, di
        inc bx
        push di

     Name_len:
        inc di
        mov al, byte ptr [cs:di]
        call Char_to_Upper_Case
        mov byte ptr [cs:di], al
        cmp al, 0
        jne Name_len

        sub di, bx
        mov bx, di
        pop di
        mov byte ptr [cs:di], bl
        inc di
        ; ---------- закончили пересчет
        pop bx
        mov ax, word ptr [cs:PARAM_DEFINE_COUNTER]
        cmp ax, MAX_PARAMETR_IN_TAB
        je Exit_Param_Table_verify

     Not_BPF:
        inc di
        jmp Begin_count_param

Exit_Param_Table_verify:
        popa
        ret

     Begin_define_param    dw  MAX_PARAMETR_IN_TAB dup (0)
     PARAM_DEFINE_COUNTER  dw  0;
   Param_Table_verify   endp

ENDM

PARAM_TABLE_Define  MACRO NAME, TYPE, SIZE, ADDR_LO, ADDR_HI
    LOCAL BEGIN_PAR_FIELD, _Name, End_name, _Type
    LOCAL _Size, _Addres_Lo, _Addres_Hi

   BEGIN_PAR_FIELD db    "/BPF"    ; метка начала описания параметра
   _Name           db    "&NAME&"    ; Идентификатор параметра
    End_name       db    0         ; Конец описания идентификатора параметра
   _Type           db    TYPE      ; Тип переменной (символьное обозначение)
   _Size           dw    SIZE      ; Размер переменной в байтах
   _Addres_Lo      dw    ADDR_LO   ; Адрес размещеня переменной младшее слово
   _Addres_Hi      dw    ADDR_HI   ; Адрес размещеня переменной старшее слово
ENDM
;---  Конец PAR_TABL.ASM  -----------------

