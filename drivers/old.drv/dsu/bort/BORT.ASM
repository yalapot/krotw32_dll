; Лог работы с программой
; Небольшие доработки (взяты в #диезные# скобки)
; при удалении "диезных" фрагментов работает в первоначальном варианте
; (без динамической настройки на объем входной информации)
 DEBUG EQU True

; Структуры данных
;
; Датчик
;   db (1)  -   4 старших бита сигнатура (9)
;           4 младших бита протяженность (см) от 0(1) до 15(16)
;   db (1)  -   удаление конца в см от условного шва
;   db (1)  -   номер датчика (от 0 до 127)
;   db (1)  -   амплитуда датчика (от 1 до 15)
;
; Условный шов
;   db (1)  -   сигнатура (50h)
;   db (1)  -   ориентация (номер верхнего датчика)
;   dw (1)  -   зарезервировано (выравнивание на 32 бита)
;   dd (1)  -   дистанция в см от начала прогона
;   dd (1)  -   время прохождения
;
; Заголовок
;   dd (1)  -   сигнатура типа снаряда
;   dd (1)  -   серийный номер снаряда
;   dw (1)  -   дата начала прогона (год)
;   dw (1)  -   дата начала прогона (месяц, день)
;   dw (1)  -   время начала прогона (часы, минуты)
;   dw (1)  -   время начала прогона (секунды, сотые секунд)
;   dw (1)  -   дата синхронизации (год)
;   dw (1)  -   дата синхронизации (месяц, день)
;   dw (1)  -   время синхронизации (часы, минуты)
;   dw (1)  -   время синхронизации (секунды, сотые секунд)

include bort.inc

StackSG segment PARA STACK 'Stack'
    db 500h dup (?)
StackSG ends

code    segment para public 'Code'
        assume cs:code, ds:code, ss:StackSG
.386

;;; отладка ******************
IFDEF DEBUG

msgRestart      db 'Restart...', 0dh, 0ah, '$'
msgStart        db 'Begin writting...', 0dh, 0ah, '$'
msgWork         db '.', '$'
msgBarDown      db '!', '$'
msgBarDownCountOK   db 'Bar Down Count OK', 0dh, 0ah, '$'
msgEnd          db 'Finishing job...', 0dh, 0ah, '$'
msgOff1         db '<', '$'
msgOff2         db '>', '$'
CountMsg        db 5 dup (' '), ' - FreeBuff', 0dh, 0ah, '$'

ENDIF
;;; отладка ******************

    even

;##6##
durtion dw 01000h      ; длительность тонального сигнала
tone dw 256h        ; высота тонального сигнала
tempway db '150','$'    ; временные ячейки (ASCII второго параметра)
binval dw 0     ; двоичное значение длины пути (в км)
mult10 dw 1;            ; временные ячейки
mulconst dw 168         ; коэффициент для подсчета нормы объема данных
bytes_per_weld dd 0     ; норма объема входной информации
infvol dd 0     ; текущее значение объема информации в байтах
plusepsilon dd 0        ; infvol*(1+0.01*epsilon)
minusepsilon dd 0       ; infvol*(1-0.01*epsilon)
delta dw 0      ; bytes_per_weld*0.01*epsilon
;##6##
;**2
tubewidth db 0
;**2
BuffTbl dw 8 dup (0)    ; таблица адресов буферов
BuffIndx db 0   ; индекс текущего буфера
FreeBuff db 0FFh; битовая карта занятости буферов
BuffPtr dw 0    ; указатель в текущем буфере
Buffer dw 0     ; база(сегмент) текущего буфера

BarDownLoopCount dw 0   ; счетчик срабатываний реле давления
stopCount dw 0  ; проверяем на остановку ~ через 2 секунды
LastPos dd 0    ; предыдущее положение снаряда
StopFlag dw 0   ; флаг остановки может иметь следующие значения:
        ; 0 - остановки нет
        ; 1 - остановка, файл данных не сохранен
        ; 2 - остановка, данные (кроме последнего буфера) сброшены на диск)
StopLength dw 0 ; продолжительность остановки в секундах

IntoCount db 0  ; счетчик повторных сантиметровых прерываний,
            ; возникших при обработке текущего в dh
DfktDist db 255 ; счетчик показаний одометра, в см от
            ; последнего условного шва
cmCount dd -1   ; счетчик сантиметров от начала трассы
LostWeld dw 0   ; счетчик потерянных условных швов
TimeCount dd 0  ; счетчик времени

DiskSpace dw 0  ; количество свободных 64Kb блоков на диске
fHandle dw 0    ; дескриптор файла
wrtBuffer dw 0  ; база(сегмент) текущего записываемого буфера
wrtIndex db 7   ; индекс последнего записанного буфера
StopReason db 0 ; причина завершения работы
WRITE_LEVEL db 0 ; записываемый уровень
OdoNumber db 0 ; номер текущего одометра (0 или 01000b)

flash db 0
flashCount dw FLASH_INTERVAL

pauseSignal dw ACP_TIMEOUT

old08off dw ?
old08seg dw ?

    even

New08   proc    far
    push eax
    push dx

;     watchdoge strobe
    cmp cs: stopcount, WDSTROBE_INTERVAL1
    jz short inittimer
    cmp cs: stopcount, WDSTROBE_INTERVAL2
    jnz short inccount
inittimer:
    mov dx, WDSTROBE_PORT
    mov al, WD_STROBE
    out dx, al
    jmp short $+2
inccount:
    inc cs:stopCount
    cmp cs:stopCount, STOP_CHECK_INTERVAL
    jl n08_exit
    ; прошло STOP_CHECK_INTERVAL тиков таймера (~ 2 секунды)
    mov cs:stopCount, 0 ; восстановим счетчик тиков
    mov eax, cs:cmCount
    cmp eax, cs:LastPos
    jnz NotStop
    ; снаряд находится на том же месте что и ~ 2 секунды назад
    ; проверим не выставлен ли уже флаг остановки
    cmp cs:StopFlag, NOT_STOP
    jnz NotStop ; флаг уже выставлен
    mov cs:StopFlag, STOP_DATA_NOT_SAVED
    mov cs:StopLength, 0
NotStop:
    inc cs:StopLength
    mov cs:LastPos, eax
n08_exit:
    inc cs:TimeCount
    mov al, 20h
    out 20h, al

    pop dx
    pop eax
    iret
New08   endp

WriteLabel  proc    near
; подпрограмма записи метки начала/завершения работы
; вход ds - Buffer
; di - BuffPtr
; cs:StopReason - значение метки

    ; пишем первое 32 разрядное слово
    xor eax, eax ;
    mov ah, cs:DfktDist ; расстояние от последнего условного шва
    ;mov ah, cs:FreeBuff ; состояние буферов

    ; номер текущего одометра
    mov dx, DATA_READY_PORT
    in al, dx
    and al, ODO_MASK
    shr al, 3
    xchg ah, al
    mov ch, cs:stopreason
    cmp ch, WELD_SIGN
    jnz short notweld
    mov al,cs:tubewidth
notweld:
    ror eax, 16
    mov ah, cs:StopReason ; сигнатура причины завершения работы
    mov dx, ORIENTATION_PORT
    in al, dx ; читаем из 104h ориентацию снаряда
    jmp short $+2

    add al, 80h ; перевернутый датчик ориентации
    shr al, 1

;   shr al, 1
;   add al, 40h ; перевернутый датчик ориентации
;   and al, 01111111b

    xchg al, ah
    mov dword ptr [di], eax
    add di, 4 ; записали 4 байта
    jnc wl2Word ; если буфер полностью заполнен (di==0)
    call SwitchBuff

    ; пишем расстояние от начала трассы
wl2Word:
    mov eax, cs:cmCount
    mov dword ptr [di], eax
    add di, 4 ; записали 4 байта
    jnc wl3Word ; если буфер полностью заполнен (di==0)
    call SwitchBuff

    ; пишем время
wl3Word:
    mov eax, cs:TimeCount
    mov dword ptr [di], eax
    add di, 4 ; записали 4 байта
    jnc wl_exit ; если буфер полностью заполнен (di==0)
    call SwitchBuff
wl_exit:
    ret
WriteLabel  endp

FlushInterrupt proc near

;   mov eax, 0ffffh
;fiLoop:
;   dec eax
;   jnz fiLoop

    ; здесь сброс аппаратного прерывания
    ; **********************************
    mov al, 20h ; non-specific eoi в ведомый контроллер
    out 0A0h, al
    jmp short $+2

    mov al, 0Bh ; команда чтения ISR
    out 0A0h, al ; передать в ведомый
    jmp short $+2
    in al, 0A0h ; прочитать ISR ведомого

    test al, 0FFh   ; есть ли запрос дискового прерывания ?
            ; (все остальное кроме диска и одометра запрещено)
    jnz FI_exit ; да -> не сбрасываем ведущий контроллер
                ; пущай винт пишет

    ; запросов с ведомого нет
    mov al, 20h ; non-specific eoi в ведущий контроллер
    out 20h, al
    jmp short $+2

FI_exit:
    ret
FlushInterrupt  endp

New73   proc    far
; подпрограмма обработки прерывания от одометра, поступающего через
; каждый сантиметр пути
    cli
    pushad ; сохраняем регистры
    push ds

    mov ax, cs:Buffer ; устанавливаем сегменты и адреса буферов
    mov ds, ax
    mov di, cs:BuffPtr
    mov si, di
    inc cs:cmCount
;**3
    cmp cs:Dfktdist,0-Orient_delay
    jnz short Checkweld
    mov dx,diod_port
    in al,dx
    jmp short $+2
    rcr ax,6
    jc short t1
    mov cs: tubewidth,00h
    jmp short checkweld
t1: mov dx,Orientation_port ; читаем значение толщины
    in al,dx
    jmp short $+2

    mov cs:Tubewidth,al

    mov dx,diod_port
    in al,dx
    jmp short $+2
        and al,11011111b  ; устанавливаем diod_port[5] в 0, чтобы через
              ; Orient_delay прерываний одометра, т.е.
              ; на усл. шве, правильно считать ориентацию
    out dx,al
    jmp short $+2
;**3
Checkweld:
    inc cs:DfktDist
    jnz CheckStop

    ; простановка метки условного шва через каждые 256 тактов (см)
    ; срабатывания одометра
    cmp cs:FreeBuff, 0 ; есть ли еще свободные буфера ?
    jnz ms_Proccessed
    add si, 12 ; хватит ли в буфере места для записи условного шва ?
    jnc ms_Proccessed
    inc cs:LostWeld ; в последнем буфере осталось меньше 12 байт
    jmp BadExit

ms_Proccessed:
;##2
; изменяем на 1 текущий уровень (ecли не уложились в эпсилон окрестность)
    cmp cs:intocount,0
    jnz short endlev1
    mov eax,cs:infvol
    cmp eax,cs:minusepsilon
    jnc short loop3
    cmp cs:write_level,0
    jz short endlev
    dec cs: write_level
    jmp short endlev
loop3:  cmp eax,cs:plusepsilon
    jc short endlev
    cmp cs: write_level, 9
    jz short endlev
    inc cs:write_level
endlev: mov cs:infvol,0
;##2
    ; пишем метку условного шва
endlev1: mov cs:StopReason, WELD_SIGN
    call WriteLabel
;**1
; записываем на усл. шве данные о толщине
;    xor eax,eax
;        mov al, cs:Tubewidth
;   mov dword ptr [di],eax
;    add di,4
;    jnc short changekind
;    call Switchbuff;
; устанавливаем в diod_port[5] в 1, чтобы за Orient_delay
; прерываний до условного шва читать данные о толщине
;changekind:
    mov dx,diod_port
    in al,dx
    jmp short $+2
        or al,00100000b
    out dx,al
    jmp short $+2
;**1

CheckStop:
    ; проверяем на остановку
    cmp cs:StopFlag, NOT_STOP
    jz CheckReenter
    ; сейчас мы тронулись после остановки
    mov cs:StopFlag, NOT_STOP ; сбрасываем флаг остановки

    ; записываем признак остановки
    xor eax, eax
    mov ax, cs:StopLength
    ror eax, 16
    mov al, STOP_SIGN ; сигнатура остановки
    mov ah, cs:DfktDist
    mov dword ptr [di], eax
    add di, 4 ; записали 4 байта
    jnc CheckReenter
    call SwitchBuff

CheckReenter:
    ; проверяем, не не вошли ли мы в предыдущее прерывание одометра,
    ; которое еще не успело отработать
    cmp cs:IntoCount, 0
    jz AskACP ; если нет, то начинаем опрашивать измерители
    ; если да, то сбрасываем аппаратное прерывание и выходим.

BadExit:
    mov cs:BuffPtr, di ; сохраняем указатель буфера
    call FlushInterrupt
Int73Exit:
    pop ds ; восстанавливаем регистры
    popad
    iret

AskACP:
    mov cs:IntoCount, 1 ; установили флажок нахождения в прерывании одометра
    call FlushInterrupt ; сбросили аппаратное прерывание.

    mov cs:BuffPtr, di ; сохраняем указатель буфера

    cmp cs:FreeBuff, 0 ; есть ли еще свободные буфера ?
    jnz BeginAsc
    mov cs:IntoCount, 0
    jmp Int73Exit ; если остался последний буфер, пишем только у.швы

BeginAsc:

    sti ; теперь нас может прервать следущее прерывание одометра.

; мигаем лампочкой готовности
    mov ax, cs:flashCount
    dec ax
    jnz No_Flash
    mov dx, DIOD_PORT
    in al,dx
    jmp short $+2
    rcr al,6
    mov ah,0
    rcl ah,6
    mov al, cs:flash
    or al,ah
    mov cs:flashCount, FLASH_INTERVAL

    ; переключаем значение готовности
    mov ah, al
    xor ah, DIOD_WORK
    and ah, DIOD_WORK
    mov cs:flash, ah

    or al, DIOD_OK ; сохраняем горящей лампочку исправности
    or al, DIOD_READY ; сохраняем горящей лампочку работы
    xor al, 00011111b ; горящая лампочка - 0
    out dx, al
    jmp ExitFlash
No_Flash:
    mov cs:flashCount, ax
ExitFlash:
; end flash procedure

    mov cl, 31
    mov ax, cx
    ; запрашиваем чтение 4 секторов, номер датчика находиться в cx
    mov dx, REQUEST_DATA_PORT
    out dx, al
    jmp short $+2

WaitACPloop:

    dec cs:pauseSignal
    jz izmTimeOut
    mov dx, DATA_READY_PORT
    in al, dx
    and al, DATA_READY_BIT
    jnz WaitACPloop ; ждем готовности данных

izmTimeOut:
    mov cs:pauseSignal, ACP_TIMEOUT ; ~ 25 микросекунд
    ; дергаем бит синхронизации
    mov dx, REQUEST_DATA_PORT
    mov al, cl
    or al, 80h ; выставляем старший бит в 1
    out dx, al
    jmp short $+2

    ;запускаем АЦП на следующие 4 датчика
    dec cl
    mov al, cl
    mov dx, REQUEST_DATA_PORT
    out dx, al

    mov dx, PORT_2_3_SECTOR ; читаем из 101h датчики 2 и 3 сектора
    in al, dx
    jmp short $+2
    mov ah, al ; сохраняем 2 и 3 сектора
    mov dx, PORT_0_1_SECTOR ; читаем из 100h датчики 2 и 3 сектора
    in al, dx
    jmp short $+2
    xor ax, 0ffffh ; инвертируем показания датчиков
    mov bx, ax ; сохраняем показания датчиков
    mov al, cl
    ; номер датчика на 1 меньше его адреса
    ;inc al
    mov ah, cs:DfktDist
    call Prc4Dfk
    cmp cl, 0
    jnz WaitACPloop
WaitLastACPloop:

    dec cs:pauseSignal
    jz lastIzmTimeOut

    mov dx, DATA_READY_PORT
    in al, dx
    and al, DATA_READY_BIT
    jnz WaitLastACPloop ; ждем готовности данных

lastIzmTimeOut:
    mov cs:pauseSignal, ACP_TIMEOUT ; ~ 25 микросекунд

    ; дергаем бит синхронизации
    mov dx, REQUEST_DATA_PORT
    mov al, cl
    or al, 80h ; выставляем старший бит в 1
    out dx, al
    jmp short $+2

    mov dx, PORT_2_3_SECTOR ; читаем из 101h датчики 2 и 3 сектора
    in al, dx
    mov ah, al ; сохраняем 2 и 3 сектора
    mov dx, PORT_0_1_SECTOR ; читаем из 100h датчики 2 и 3 сектора
    in al, dx
    xor ax, 0ffffh ; инвертируем показания датчиков
    mov bx, ax ; сохраняем показания датчиков
    ; обход 0<->31 датчика
    mov al, 31
    mov ah, cs:DfktDist
    call Prc4Dfk

    mov cs:IntoCount, 0 ; сбросили флажок нахождения в прерывании одометра
    jmp Int73Exit

New73   endp

Prc4Dfk proc    near
; подпрограмма обработки и укладки значений 4 считанных датчиков.
; на входе:
; al : номер датчика в секторе
; ah : смещение датчика в см от условного шва
; bx : показания (амплитуды) датчиков
;        4 младших бита bl : датчик 0 сектора (al)
;        4 старших бита bl : датчик 1 сектора (al+32)
;        4 младших бита bh : датчик 2 сектора (al+64)
;        4 старших бита bh : датчик 3 сектора (al+96)
; разрушаемые регистры: ch
; возврат: нет

    or bx, 0        ; если все датчики пустые их
    jz p4d_ExitProc     ; не обрабатываем и выходим

    ; подготовка общих данных
    mov ch, al      ; номер датчике в ch
    mov al, SENS_SIGN - 1   ; сигнатура дефекта
    add al, cs:IntoCount    ; в ah реальная сигнатура дефекта 90h - 9Fh
    shl eax, 16     ; сигнатура и смещение датчика в старшем
                ; слове eax будет использовано для всех датчиков

    or bl, 0        ; если датчики 0 и 1 сектора пустые их не
    jz p4d_TestBH       ; обрабатываем а проверяем датчики 2 и 3 секторов

    mov ah, 0Fh
    and ah, bl      ; тестируем датчик 0 сектора
    jz p4d_Test1sect
    cmp ah, cs:WRITE_LEVEL  ; отсекаем ненужные уровни
    jle p4d_Test1sect
    mov al, ch

    ror eax, 16

    cli
    mov di, cs:BuffPtr
    mov dword ptr [di], eax
    ror eax, 16
    add cs:infvol, 4
        add di,4
    jnc p4d_sptr1
    call SwitchBuff
p4d_sptr1:

    mov cs:BuffPtr, di ; сохраняем указатель буфера
    sti

p4d_Test1sect:
    mov ah, 0F0h
    and ah, bl      ; тестируем датчик 1 сектора
    jz p4d_TestBH
    ror ah, 4
    cmp ah, cs:WRITE_LEVEL  ; отсекаем ненужные уровни
    jle p4d_TestBH
    mov al, ch
    add al, 32

    ror eax, 16

    cli
    mov di, cs:BuffPtr
    mov dword ptr [di], eax
    ror eax, 16
    add cs:infvol, 4
    add di, 4
    jnc p4d_sptr2
    call SwitchBuff
p4d_sptr2:

    mov cs:BuffPtr, di ; сохраняем указатель буфера
    sti

p4d_TestBH:

    or bh, 0        ; если датчики 2 и 3 сектора пустые их
    jz p4d_ExitProc     ; не обрабатываем и выходим

    mov ah, 0Fh
    and ah, bh      ; тестируем датчик 2 сектора
    jz p4d_Test3sect
    cmp ah, cs:WRITE_LEVEL  ; отсекаем ненужные уровни
    jle p4d_Test3sect
    mov al, ch
    add al, 64

    ror eax, 16

    cli
    mov di, cs:BuffPtr
    mov dword ptr [di], eax
    ror eax, 16
        add cs:infvol, 4
        add di, 4
    jnc p4d_sptr3
    call SwitchBuff
p4d_sptr3:

    mov cs:BuffPtr, di ; сохраняем указатель буфера
    sti

p4d_Test3sect:

    mov ah, 0F0h
    and ah, bh      ; тестируем датчик 3 сектора
    jz p4d_ExitProc
    ror ah, 4
    cmp ah, cs:WRITE_LEVEL  ; отсекаем ненужные уровни
    jle p4d_ExitProc
    mov al, ch
    add al, 96

    ror eax, 16

    cli
    mov di, cs:BuffPtr
    mov dword ptr [di], eax
    ror eax, 16
    add cs:infvol, 4
    add di, 4
    jnc p4d_sptr4
    call SwitchBuff
p4d_sptr4:

    mov cs:BuffPtr, di ; сохраняем указатель буфера
    sti

p4d_ExitProc:
    ret
Prc4Dfk endp

SwitchBuff  proc    near
; подпрограмма переключения буферов. Вызывается при нехватке места в буфере
; на входе:
;  BuffIndx: индекс текущего буфера
; на выходе:
;  ds и Buffer: сегментный адрес нового буффера
;  di и BuffPtr: 0
;  BuffIndx: индекс задействованного буфера
;  FreeBuffer: установлен бит соответствующего задействованного буфера
;
    push ax
    push cx
    sub cx, cx
    mov cl, cs:BuffIndx
    cmp cl, 7 ; индекс последнего буфера
    jz CircleLab ; последний буфер заполнен, переходим к первому (0)
    inc cl
    mov ax, 1
    rol ax, cl
    jmp short CheckOferflow
CircleLab:
    mov cl, 0
    mov ax, 1
CheckOferflow:
    ; в cl индекс нового буфера, а в al установлен соответствующий бит
    xor al, 0FFh ; делаем дырку на месте бита буффера
    mov ah, al
    mov al, cs:FreeBuff
    and al, ah ;сбрасываем бит нового буффера
    ; сохраняем значения
    mov cs:FreeBuff, al
    mov cs:BuffIndx, cl

    mov al, cl
    mov cl, 2
    mul cl ; смещение адреса нового буффера в таблице теперь в ax
    mov cx, offset cs:BuffTbl
    add ax, cx
    mov di, ax
    mov ax, word ptr cs:[di]
    mov cs:Buffer, ax
    mov ds, ax
    mov cs:BuffPtr, 0
    mov di, 0
    pop cx
    pop ax
    ret
SwitchBuff  endp

WriteBuffer proc    near

    push cx ; сохраним счетчик

    mov ah, cs:wrtIndex
    cmp ah, 7 ; если записан последний буфер переходим к первому
    jz CircleBuff
    inc ah ; иначе к следующему
    jmp short CompareWithCurrent
CircleBuff:
    mov ah, 0
CompareWithCurrent:

    ; если буфер который сейчас нужно писать является текущим
    ; для прерывания от одометра, то ждем пока он полностью не
    ; заполниться и int73h переключится на следующий буфер
    cli
    mov al, cs:BuffIndx
    sti
    cmp al, ah

    jz checkStop1 ; один текущий буфер, проверим а не стоим ли мы?

    ; сохраним индекс буфера который сейчас будем писать
    mov cs:wrtIndex, ah

    mov al, ah
    and ax, 0ffh
    mov cx, 2
    mul cx ; смещение адреса нового буффера в таблице теперь в ax
    mov cx, offset cs:BuffTbl
    add ax, cx
    mov di, ax
    mov ax, word ptr cs:[di]
    mov cs:wrtBuffer, ax

    ; записываем первую половину буфера
    mov bx, cs:fHandle
    mov ax, cs:wrtBuffer ; сегмент буфера
    mov ds, ax
    mov ah, 40h
    mov dx, 0 ; смещение первой половины буфера
    mov cx, 8000h ; первая половина буфера
    int 21h

    ; записываем вторую половину буфера
    mov bx, cs:fHandle
    mov ax, cs:wrtBuffer ; сегмент буфера
    mov ds, ax
    mov ah, 40h
    mov dx, 8000h ; смещение второй половины буфера
    mov cx, 8000h ; вторая половина буфера
    int 21h

    dec cs:DiskSpace ; уменьшим счетчик свободного дискового пространства

    ; отразим факт записи буфера (теперь он доступен для использования 73h)
    ; в байте статуса буферов
    mov al, 1
    mov cl, cs:wrtIndex
    shl al, cl
    cli
    mov ah, cs:FreeBuff
    or al, ah
    mov cs:FreeBuff, al
    sti

;;; отладка ******************
IFDEF DEBUG
    ; значение FreeBuff
    and ax, 0ffh
    mov di, offset CountMsg
    push cs
    pop es
;   call UpkAX
    mov ax, cs
    mov ds, ax
    mov dx, offset CountMsg
    mov ah, 09h
    int 21h
ENDIF
;;; отладка ******************

    jmp wb_Exit

checkStop1: cmp cs:StopFlag, STOP_DATA_NOT_SAVED
    jnz wb_Exit

    ; стоим и данные не сохранены
    cli ; при сохранении данных, буфера и StopFlag не должны меняться
    call SaveData
    mov cs:StopFlag, STOP_DATA_SAVED ; флажок записанных данных
    sti

wb_Exit:
    pop cx
    ret
WriteBuffer endp

SaveData    proc    near

    ; записываем последний буфер (который был текущим)
    mov ax, cs:Buffer
    mov ds, ax
    mov dx, 0 ; с начала
    mov cx, cs:BuffPtr ; до конца
    mov bx, cs:fHandle
    mov ah, 40h
    int 21h

    ; закрываем
    mov bx, cs:fHandle
    mov ah, 3eh
    int 21h

    ; открываем файл
    mov ax, cs
    mov ds, ax
    mov dx, offset cs:fName
    mov al, 1 ; для вывода
    mov ah, 3dh
    int 21h
    mov cs:fHandle, ax ; сохраняем хендл

    ; передвигаем указатель в конец файла
    mov bx, ax
    mov cx, 0
    mov dx, 0
    mov al, 2
    mov ah, 42h
    int 21h

    ; переключаем буфера
    mov cs:BuffIndx, 0ffh
    mov cs:FreeBuff, 11111111b
    call SwitchBuff
    mov cs:BuffPtr, 0
    mov cs:wrtIndex, 7

    ret

SaveData    endp

oldmask1 db 0 ; старая маска прерываний для 1 контроллера
oldmask2 db 0 ; старая маска прерываний для 2 контроллера

; старый обработчик 73h
old73seg DW 0
old73ofs DW 0

fName           db RecordName, 0
sName           db SinhroName, 0

even

Init    proc far

    cli

    ; сохраняем старые маски прерываний
    in al, 0A1h ; для 2 контроллера
    jmp short $+2
    mov cs:oldmask2, al
    in al, 021h ; для 1 контроллера
    jmp short $+2
    mov cs:oldmask1, al

    ; инициализируем контроллер прерываний в
    ; специальном режиме полной вложенности

    ; инициализируем ведущий контроллер
    mov al, 00010001b ; icw1
    out 020h, al
    jmp short $+2

    mov al, 00001000b ; icw2
    out 021h, al
    jmp short $+2

    mov al, 00000100b ; icw3
    out 021h, al
    jmp short $+2

    mov al, 00010001b ; icw4
    out 021h, al
    jmp short $+2

    mov al, 11111010b ; разрешаем таймер и ведомый контроллер
    out 021h, al
    jmp short $+2

    ; инициализируем ведомый контроллер
    mov al, 00010001b ; icw1
    out 0A0h, al
    jmp short $+2

    mov al, 01110000b ; icw2
    out 0A1h, al
    jmp short $+2

    mov al, 00000010b ; icw3
    out 0A1h, al
    jmp short $+2

    mov al, 00010001b ; icw4
    out 0A1h, al
    jmp short $+2

    mov al, IRQ_MASK ; разрешаем одометр и винчестер
    out 0A1h, al
    jmp short $+2

    ; сохраняем старый вектор 73h
    mov ah, 35h
    mov al, ODOMETR_INTERRUPT
    int 21h
    mov cs:old73seg, es
    mov cs:old73ofs, bx

    ; устанавливаем свой обработчик
    mov ax, cs
    mov ds, ax
    mov dx, offset New73
    mov ah, 25h
    mov al, ODOMETR_INTERRUPT
    int 21h

    ; переводим таймер на TIMER_INTERVAL_VAL тиков в секунду
    mov al, 00110110b
    out 43h, al
    jmp short $+2
    mov ax, TIMER_INTERVAL_REG
    out 40h, al
    jmp short $+2
    mov al, ah
    out 40h, al
    jmp short $+2

    ; сохраняем старый вектор 08h
    mov ah, 35h
    mov al, 08h
    int 21h
    mov cs:old08off, bx
    mov cs:old08seg, es

    ; устанавливаем свой обработчик 08h
    mov ax, cs
    mov ds, ax
    mov dx, offset New08
    mov ah, 25h
    mov al, 08h
    int 21h

;   ; включаем watchdoge
    mov dx, WDCONTROL_PORT
    mov al, WD_ENABLED
    out dx, al
    jmp short $+2
    sti
    ret
Init    endp

Restore proc far

    cli

    ; инициализируем контроллер прерываний в
    ; обычном режиме полной вложенности

    ; инициализируем ведущий контроллер
    mov al, 00010001b ; icw1
    out 020h, al
    jmp short $+2

    mov al, 00001000b ; icw2
    out 021h, al
    jmp short $+2

    mov al, 00000100b ; icw3
    out 021h, al
    jmp short $+2

    mov al, 00000001b ; icw4
    out 021h, al
    jmp short $+2

    ; восстанавливаем старые маски прерываний
    mov al, cs:oldmask1
    out 021h, al
    jmp short $+2

    ; инициализируем ведомый контроллер
    mov al, 00010001b ; icw1
    out 0A0h, al
    jmp short $+2

    mov al, 01110000b ; icw2
    out 0A1h, al
    jmp short $+2

    mov al, 00000010b ; icw3
    out 0A1h, al
    jmp short $+2

    mov al, 00000001b ; icw4
    out 0A1h, al
    jmp short $+2

    ; восстанавливаем старые маски прерываний
    mov al, cs:oldmask2
    out 0A1h, al
    jmp short $+2

    ; восстанавливаем старый обработчик 73h
    mov dx, cs:old73ofs
    mov ax, cs:old73seg
    mov ds, ax
    mov ah, 25h
    mov al, ODOMETR_INTERRUPT
    int 21h

    ; переводим таймер на обычное число тиков в секунду
    mov al, 00110110b
    out 43h, al
    jmp short $+2
    mov ax, 0
    out 40h, al
    jmp short $+2
    mov al, ah
    out 40h, al
    jmp short $+2

    ; восстанавливаем старый обработчик 08h
    mov ax, cs:old08seg
    mov ds, ax
    mov dx, cs:old08off
    mov ah, 25h
    mov al, 08h
    int 21h

    ; выключаем watchdoge
    mov dx, WDCONTROL_PORT
    mov al, WD_DISABLED
    out dx, al
    jmp short $+2
    sti
    ret

Restore endp

;;; отладка ******************
IFDEF DEBUG
UpkAX   proc far
    push ax
    push bx
    push cx
    push dx
    push di
    cld
    push ax
    push di
    mov cx, 5
    mov al, ' '
    rep stosb
    pop di
    pop ax
    sub cx, cx
    mov bx, 10
ULoop1:
    sub dx, dx
    div bx
    add dl, '0'
    push dx
    or ax, ax
    loopnz ULoop1
    neg cx
ULoop2:
    pop ax
    stosb
    loop ULoop2
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
UpkAX   endp
ENDIF
;;; отладка ******************

PreviosJob:
pjSign db ?
pjOrient db ?
pjDfktDist db ?
pjReserved db ?
pjcmCount dd ?
pjTime dd ?

DTA:
dtaReserved db 21 dup (0)
dtaAttrib db 0
dtaTime dw 0
dtaDate dw 0
dtaSize dd 0
dtaName db 14 dup (0)

fYear dw 0
fMonth dw 0
fDay dw 0
fHour dw 0
fMinutes dw 0

nYear dw 0
nMonth dw 0
nDay dw 0
nHour dw 0
nMinutes dw 0

_MulC   proc    near
    enter   16,0
    movzx   edx,al
    mov dword ptr [bp-4],edx

    movzx   edx,ah
    mov dword ptr [bp-8],edx
    mov dword ptr [bp-12],ecx
    mov dword ptr [bp-16],ebx

    mov eax,dword ptr [bp-4]
    sub eax,dword ptr [bp-8]
    imul    eax,dword ptr [bp-12]
    add eax,dword ptr [bp-16]
    mov dword ptr [bp-16],eax

    mov ebx,dword ptr [bp-16]
    leave
    ret
_MulC   endp

fOpen   proc

    ; подсчитываем количество 64Kb свободных блоков на диске
    xor eax, eax
    xor ecx, ecx
    xor ebx, ebx
    mov dl, 3 ; диск C
    mov ah, 36h
    int 21h
    mul cx
    ror eax, 16
    mov ax, dx
    ror eax, 16
    mul ebx
    ror eax, 16 ; искомое значение в ax

    sub ax, 8 ; запас в 8 блоков для слива всех буферов
    jc VeryVerySmallDiskSpace ; на диске нет места для 8 буферов Ж%0
    mov cs:DiskSpace, ax
    jmp CheckDataFile

VeryVerySmallDiskSpace:
    ; выключаем бортовую аппаратуру
    mov al, 1
    mov dx, CONTROL_PORT
    out dx, al
    jmp short $+2 ; здесь лепиздричество уже выключено Ж:)
    cli
    hlt
    mov cs:DiskSpace, 0
    ret

CheckDataFile:
    ; пытаемся открыть файл
    mov ax, cs
    mov ds, ax
    mov dx, offset cs:fName
    mov al, 2 ; для чтения/записи
    mov ah, 3dh
    int 21h
    jc notExist
    mov cs:fHandle, ax ; сохраняем хендл

    ; передвигаем указатель в конец файла
    mov bx, ax
    mov cx, 0
    mov dx, 0
    mov al, 2
    mov ah, 42h
    int 21h
    ; получаем положение в файле метки окончания работы (размер файла - 12 байт)
    ror eax, 16
    mov ax, dx
    ror eax, 16
    sub eax, 12
    ; передвигаем указатель на начало метки завершения работы
    mov dx, ax
    ror eax, 16
    mov cx, ax
    mov al, 0
    mov ah, 42h
    int 21h
    ; читаем метку окончания работы
    push cs
    pop ds
    mov dx, offset PreviosJob
    mov cx, 12
    mov ah, 3Fh
    int 21h
    ; передвигаем указатель в конец файла для правильной записи
    mov bx, ax
    mov cx, 0
    mov dx, 0
    mov al, 2
    mov ah, 42h
    int 21h

    mov bx, cs:fHandle
    mov cx, 0
    mov dx, 0
    mov al, 0
    mov ah, 42h
    int 21h ; переехали в начало файла записи

    mov ax, Buffer
    mov ds, ax
    mov dx, 0
    mov cx, offset DataStart
    mov ah, 3fh
    int 21h ; прочитали заголовок в Buffer

    ; сохраняем значения даты начала записи в полях синхронизации
    ; (она сейчас не нужна)
    assume ds:Buff

    mov ax, trace_year
    mov sinh_year, ax

    mov al, trace_month
    mov sinh_month, al

    mov al, trace_day
    mov sinh_day, al

    mov al, trace_hour
    mov sinh_hour, al

    mov al, trace_minutes
    mov sinh_minutes, al

    mov al, trace_second
    mov sinh_second, al

    mov al, trace_hsecond
    mov sinh_hsecond, al

    call GetDate    ; в trace_* текущее время

    xor ebx, ebx

    mov ah, sinh_hsecond
    mov al, trace_hsecond
    mov ecx, 1
    call _MulC

    mov ah, sinh_second
    mov al, trace_second
    mov ecx, 100
    call _MulC

    mov ah, sinh_minutes
    mov al, trace_minutes
    mov ecx, 6000
    call _MulC

    mov ah, sinh_hour
    mov al, trace_hour
    mov ecx, 360000
    call _MulC

    mov ah, sinh_day
    mov al, trace_day
    mov ecx, 8640000
    call _MulC

    ; сохраняем прошедшее время в счетчике
    mov cs:pjTime, ebx

    mov bx, cs:fHandle
    mov cx, 0
    mov dx, 0
    mov al, 2
    mov ah, 42h
    int 21h ; переехали в конец файла записи

    ; анализируем содержание метки
    cmp cs:pjSign, BarDownLabel
    jz setContinue
    mov cs:pjcmCount, 0
    mov cs:pjDfktDist, 0

    jmp setContinue

notExist:
    ; создаем файл
    mov ax, cs
    mov ds, ax
    mov dx, offset cs:fName
    mov cx, 0
    mov ah, 3ch
    int 21h
    mov cs:fHandle, ax ; сохраняем хендл
setNew:
    stc
    jmp l_exit
setContinue:
    clc
l_exit:
    ret
fOpen   endp

bcdByte proc

; на входе al - bcd значение
; на выходе al - двоичное значение
; разрушаемые регистры - ah, bl

    mov bl, al
    and al, 0F0h
    shr al, 4
    mov ah, 10
    mul ah
    mov ah, al
    mov al, bl
    and al, 0Fh
    add al, ah
    ret

bcdByte endp

; Записывает по адресу Buffer:trace_year текущую дату и время (8 байт)
GetDate proc

    push ds
    mov ax, Buffer ; адресация в заголовке
    mov ds, ax
    assume ds:Buff

    ; дата начала записи
    mov ah, 4
    int 1Ah
    ; век
    mov al, ch
    call bcdByte
    xor bx, bx
    mov bl, al
    mov ax, 100
    push dx
    mul bx
    pop dx
    push ax
    ; год
    mov al, cl
    call bcdByte
    and ax, 0FFh
    pop bx
    add ax, bx
    mov trace_year, ax
    ; месяц
    mov al, dh
    call bcdByte
    mov trace_month, al
    ; день
    mov al, dl
    call bcdByte
    mov trace_day, al

    ; время начала записи
    mov ah, 2
    int 1Ah
    ; часы
    mov al, ch
    call bcdByte
    mov trace_hour, al
    ; минуты
    mov al, cl
    call bcdByte
    mov trace_minutes, al
    ; секунды
    mov al, dh
    call bcdByte
    mov trace_second, al
    mov al, 0
    mov trace_hsecond, al

    pop ds
    ret

GetDate endp
;##7
errsound proc
;Выдаем серию тональных сигналов для привлечения внимания
;при неправильном вводе длины трассы
;На настоящий момент решили от этого отказаться
;но код оставил - вдруг пригодится
    in al,61h
    push ax
    cli
s1:     mov dx,cs:durtion
s2: and al,11111100b
    out 61h,al
    mov cx,cs:tone
s3: loop s3
        or al,00000010b
    out 61h,al
    mov cx, cs:tone
s4: loop s4
        dec dx
    jnz s2
    shl cs:durtion,1
    shr cs: tone,1
    jnz s1
    pop ax
    out 61h,al
    sti
    ret
errsound endp
;##7
main    proc

    ; читаем из командной строки уровень, которым надо писать и
    ; помещаем его в переменную WRITE_LEVEL
;   mov al, [ds:82h]
;   sub al, 30h
;   cmp al, 9 ; должно быть число от 0 до 9
;   jbe sendLevel
;   mov al, 0
sendLevel:
; ##1##   Преобразование входного параметра (длины трассы в км) ASCII -> BIN
;   mov dx, diod_port
;   mov al, diod_work
;   out dx,al
;   jmp short $+2
    mov cs:WRITE_LEVEL, 0
        lea si, ds: 82h
    push si
        mov bl,0ffh
read1:  mov al,[si]
        sub al,30h
    inc bx
    inc si
    cmp al,9
        jbe short read1
    pop si
    lea di,cs:tempway
readok: mov dx,3
    cmp bl,2
    jc short ignoreread
    cmp bl,3
    ja short ignoreread
    mov ch,0
    mov cl,bl
    mov dx,cx
;   mov ax,3
;   sub al,bl
;   mov bl,al
;   mov bh,0
readway: mov al,[si]
    mov cs:[di],al
    inc si
    inc di
    loop readway
ignoreread:
    push ds
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov cx,10
    lea si,tempway-1
    mov bx, dx
loop1:  mov al,[si+bx]
    and ax,000fh
    mul mult10
    add binval,ax
    mov ax,mult10
    mul cx
    mov mult10,ax
    dec bx
    jnz loop1
    mov ax,binval
    pop ds
; ##1##
Restart:

;;; отладка ******************
IFDEF DEBUG
    mov ax, cs
    mov ds, ax
    mov ah, 09
    mov dx, offset msgRestart
    int 21h
ENDIF
;;; отладка ******************
    ; инициализация таблицы адресов буферов
    mov word ptr [cs:BuffTbl +  0], Buff
    mov word ptr [cs:BuffTbl +  2], Buff+1000h
    mov word ptr [cs:BuffTbl +  4], Buff+2000h
    mov word ptr [cs:BuffTbl +  6], Buff+3000h
    mov word ptr [cs:BuffTbl +  8], Buff+4000h
    mov word ptr [cs:BuffTbl + 10], Buff+5000h
    mov word ptr [cs:BuffTbl + 12], Buff+6000h
    mov word ptr [cs:BuffTbl + 14], Buff+7000h

    mov cs:BarDownLoopCount, 0

    ; инициализация одометра на 1 см
    mov al, ODOMETR_1CM
    mov dx, CONTROL_PORT
    out dx, al

    mov cs:BuffIndx, 0ffh
    mov cs:FreeBuff, 11111111b
    call SwitchBuff
    call fOpen
    jnc ContinueRecord ; если сброшен флаг переноса то это продолжение записи

    ;mov ax, 1712
    mov cs:BuffPtr, offset DataStart ;+ ((4 * KROT_TIME_NUM + 1) * MAX_MARKER_NUM)
    ; читаем файл синхронизации
    push ds

    mov ax, cs
    mov ds, ax
    mov dx, offset cs:sName
    mov al, 0 ; для чтения
    mov ah, 3dh
    int 21h
    jc sinhNotExist

    mov bx, ax ; хендл
    mov ax, Buffer ; адресация в заголовке
    mov ds, ax
    mov dx, offset sinh_year
    mov cx, 8 ; размер файла синхронизации
    mov ah, 3fh
    int 21h
    ; вставить проверку на ошибку !!!!!!!!!!!!!!!!!!!!!

    ; закрываем файл синхронизации
    mov ah, 3eh
    int 21h

    ; удаляем файл синхронизации
    mov ax, cs
    mov ds, ax
    mov dx, offset cs:sName
    mov ah, 41h
    int 21h

sinhNotExist:
    pop ds
    ; записываем дату и время начала прогона в заголовок
    call GetDate
        assume cs:code, ds:code, ss:StackSG

    jmp setupInterrupt
ContinueRecord:
    ; восстанавливаем счетчики
    mov eax, cs:pjTime
    mov cs:TimeCount, eax
    mov eax, cs:pjcmCount
    mov cs:cmCount, eax
    mov al, cs:pjDfktDist
    mov cs:DfktDist, al
    mov cs:BuffPtr, 0

setupInterrupt:
; ##2##
    mov ax, cs: diskspace ; количество 64k блоков на винчестере
    sub ax,reserv_dspace ;
        xor dx,dx
;   mov cx,10
;   mul cx
    div cs: binval
    inc ax;
    mul cs: mulconst
;   mov cx,10
;   div cx
        ror eax,16
    mov ax,dx
    ror eax,16
    mov cs: bytes_per_weld, eax ; получили норму входного сигнала
    mov cs: infvol,eax
    mov cs:plusepsilon,eax
    mov cs:minusepsilon,eax
;   xor dx,dx
    mov cx,100
    div cx
    xor dx,dx
    mov cx,epsilon
    mul cx
    ror eax,16
    mov ax,dx
    ror eax,16
;   add cs:plusepsilon,eax   ;
    sub cs:minusepsilon,eax   ;
; ##2##
    call Init

    ; зажигаем лампочку готовности
    mov dx, DIOD_PORT
    mov al, DIOD_READY
    or al, DIOD_OK ; сохраняем горящей лампочку исправности
    or al, DIOD_WORK ; сохраняем горящей лампочку работы
    xor al, 00011111b ; горящая лампочка - 0
    out dx, al
    jmp short $+2

    ; записываем метку включения снаряда
    cli
    push ds
    mov cs:StopReason, POWERON_SIGN
    mov ax, cs:Buffer ; устанавливаем сегменты и адреса буферов
    mov ds, ax
    mov di, cs:BuffPtr
    mov si, di
    call WriteLabel
    mov cs:BuffPtr, di ; сохраняем указатель буфера
    pop ds
    sti

;;; отладка ******************
IFDEF DEBUG
    ; печатаем начальное сообщение
    mov ax, cs
    mov ds, ax
    mov ah, 09
    mov dx, offset msgStart
    int 21h
ENDIF
;;; отладка ******************

    mov cs:wrtIndex, 7

;   mov al, DIOD_READY
;   mov cs:flash, al

WorkLoop:

;;; отладка ******************
IFDEF DEBUG
    mov ax, cs
    mov ds, ax
    mov dx, offset msgWork
    mov ah, 09h
    int 21h
ENDIF
;;; отладка ******************


; HANG PC after 20 sec
;   cli
;   mov eax, cs:TimeCount
;   sti
;   cmp eax, 2000
;   jl NoHang
;   cli
;   hlt
;NoHang:

    ; проверяем есть ли давление в трубе
    mov dx, CONTROL_PORT
    mov al, ODOMETR_1CM     ; этим запросом не надо переключать
    or al, BAR_REQUEST_ON       ; одометр
    out dx, al
    jmp short $+2

    mov al, ODOMETR_1CM
    or al, BAR_REQUEST_OFF
    out dx, al
    jmp short $+2

    mov dx, STATUS_PORT
    in al, dx
    jmp short $+2
    and al, BAR_PRESENT
    jnz ProbablyBarDown
    mov cs:BarDownLoopCount, 0
    jmp short ContinueCheck

ProbablyBarDown:

;;; отладка ******************
IFDEF DEBUG
    mov ax, cs
    mov ds, ax
    mov ah, 09
    mov dx, offset msgBarDown
    int 21h
ENDIF
;;; отладка ******************

    mov ax, cs:BarDownLoopCount
    inc ax
    mov cs:BarDownLoopCount, ax
    cmp ax, BAR_DOWN_BORDER
    jne ContinueCheck

;;; отладка ******************
IFDEF DEBUG
    mov ax, cs
    mov ds, ax
    mov ah, 09
    mov dx, offset msgBarDownCountOK
    int 21h
ENDIF
;;; отладка ******************

    jmp short BarDown

ContinueCheck:
    ; проверяем заполненность диска
    cmp cs:DiskSpace, 0
    jz DiskFull

    ; проверяем состояние электропитания

    ; нету такой буквы в нашем слове :(

    call WriteBuffer
    hlt
    jmp short WorkLoop

DiskFull:
    mov cs:StopReason, DiskFullLabel
    jmp short ShutDown

BarDown:
    mov cs:StopReason, BarDownLabel
    jmp short ShutDown

ShutDown:

;;; отладка ******************
IFDEF DEBUG
    ; печатаем конечное сообщение
    mov ax, cs
    mov ds, ax
    mov ah, 09
    mov dx, offset msgEnd
    int 21h
ENDIF
;;; отладка ******************

    call Restore

    ; записываем метку окончания работы

    mov ax, cs:Buffer ; устанавливаем сегменты и адреса буферов
    mov ds, ax

    mov di, cs:BuffPtr

    call WriteLabel

saveBuffPTR:
    mov cs:BuffPtr, di ; сохраняем указатель буфера

    ; записываем все оставшиеся буфера, кроме последнего
    mov cx, 7
FlushAllBuffer:
    call WriteBuffer
    loop FlushAllBuffer

    ; записываем последний буфер (который был текущим)
    mov ax, cs:Buffer
    mov ds, ax
    mov dx, 0 ; с начала
    mov cx, cs:BuffPtr ; до конца
    mov bx, cs:fHandle
    mov ah, 40h
    int 21h

    ; закрываем
    mov bx, cs:fHandle
    mov ah, 3eh
    int 21h

    ; пауза для 'успокоения' всего оборудования
    mov cx, 8000h
PauseLoop:
    nop
    nop
    loop PauseLoop

    mov dx, DIOD_PORT
    mov al, DIOD_ALLDARK
    out dx, al
    jmp short $+2

BarDownLoop:

;;; отладка ******************
IFDEF DEBUG
    mov ax, cs
    mov ds, ax
    mov ah, 09
    mov dx, offset msgOff1
    int 21h
ENDIF
;;; отладка ******************

    ; еще раз проверяем есть ли давление в трубе
    mov dx, CONTROL_PORT
    mov al, ODOMETR_1CM     ; этим запросом не надо переключать
    or al, BAR_REQUEST_ON       ; одометр
    out dx, al
    jmp short $+2

    mov al, ODOMETR_1CM
    or al, BAR_REQUEST_OFF
    out dx, al
    jmp short $+2

    mov dx, STATUS_PORT
    in al, dx
    jmp short $+2
    and al, BAR_PRESENT
    jnz OffDevice
    jmp Restart

OffDevice:

;;; отладка ******************
IFDEF DEBUG
    mov ax, cs
    mov ds, ax
    mov ah, 09
    mov dx, offset msgOff2
    int 21h
ENDIF
;;; отладка ******************

    ; выключаем бортовую аппаратуру
    mov al, 1
    mov dx, CONTROL_PORT
    out dx, al
    jmp short $+2 ; здесь лепиздричество уже выключено Ж:)
    jmp BarDownLoop

    ;cli
    ;hlt
    ; выходим
    ;mov ax, 4c00h
    ;int 21h
main    endp

code    ends

.286
Buff    segment PARA public 'Data'

krtSign dd SSUD_SIGN
serialNo dd SERIAL_NUM

trace_year dw 0
trace_month db 0
trace_day db 0
trace_hour db 0
trace_minutes db 0
trace_second db 0
trace_hsecond db 0

sinh_year dw 0
sinh_month db 0
sinh_day db 0
sinh_hour db 0
sinh_minutes db 0
sinh_second db 0
sinh_hsecond db 0

traceMarkers db ((4 * KROT_TIME_NUM + 1) * MAX_MARKER_NUM) dup (0)
DataStart dw 0
Buff    ends
end main
