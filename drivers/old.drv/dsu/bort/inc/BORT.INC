;###
epsilon         equ 30 ; допуcтимое отклонение от нормы в %
reserv_dspace       equ 6400 ; резерв дискового пространства (в
                ; количестве 64К блоков)
;###
;**
orient_delay         equ 3   ; количество прерываний одометра,
                 ; через которое может измениться значение в
                 ; ORIENTATION_PORT
;**
SSUD_SIGN       equ 44555353h
SERIAL_NUM      equ 1

FLASH_INTERVAL      equ 250

; WatchDog
WDSTROBE_INTERVAL1        equ 50
WDSTROBE_INTERVAL2        equ 150
WDCONTROL_PORT          equ 380h
WDSTROBE_PORT           equ 388h
WD_ENABLED              equ 1
WD_DISABLED             equ 0
WD_STROBE               equ 1

; максимальная задержка сигнала готовности данных в циклах
ACP_TIMEOUT     equ 15

; количество срабатываний реле давления, после которого борт уходит в
; режим отключения (отработка 'дребезга' реле давления)
BAR_DOWN_BORDER     equ 10

TIMER_INTERVAL_REG  equ 11932
TIMER_INTERVAL_VAL  equ 100
; периодичность проверки на остановку (в тиках таймера)
STOP_CHECK_INTERVAL     equ (2 * TIMER_INTERVAL_VAL)
NOT_STOP        equ 0 ; остановки нет
STOP_DATA_NOT_SAVED     equ 1 ; стоим и буфера не сохранены
STOP_DATA_SAVED     equ 2 ; стоим и буфера сброшены на диск

;ORIENT_SHIFT       equ 80h ;перевернутый датчик ориентации 19.06.97
;ORIENT_SHIFT       equ 0

; сигнатуры элементов записи
SENS_SIGN       equ 90h ; дефект
WELD_SIGN       equ 50h ; условный шов
STOP_SIGN       equ 60h ; остановка
BarDownLabel        equ 70h ; сброс давления
PowerFailLabel      equ 71h ; израсходованы аккумуляторы
DiskFullLabel       equ 72h ; переполнение накопителя (винчестер)
POWERON_SIGN        equ 7fh ; включение снаряда

RecordName      equ 'trace.krt'
SinhroName      equ 'sinhro.krt'

;irq 11
ODOMETR_INTERRUPT   equ 73h
IRQ_MASK        equ 10110111b ; разрешаем одометр и винчестер

;irq 15
;ODOMETR_INTERRUPT  equ 77h
;IRQ_MASK       equ 00111111b ; разрешаем одометр и винчестер

; порты
ORIENTATION_PORT    equ 170h
REQUEST_DATA_PORT   equ 102h
PORT_2_3_SECTOR     equ 101h
PORT_0_1_SECTOR     equ 100h
STATUS_PORT     equ 106h
CONTROL_PORT        equ 105h
DATA_READY_PORT     equ 10Dh

ODOMETR_1CM     equ 0100b
ODOMETR_2CM     equ 0000b
ODO_MASK                equ 01000b

BAR_REQUEST_ON      equ 010b
BAR_REQUEST_OFF     equ 000b

BAR_PRESENT     equ 01b

MAX_MARKER_NUM      equ 100
KROT_TIME_NUM       equ 4

INIT1_PORT      equ 103h
INIT1_VALUE     equ 92h
INIT2_PORT      equ 107h
INIT2_VALUE     equ 89h
INIT4_PORT      equ 10Fh
INIT4_VALUE     equ 9Bh

DATA_READY_BIT      equ 10000000b

MODE_MASK       equ 00111110b

MODE_SINHRO     equ 00000010b
MODE_WORK       equ 00000100b
MODE_READ       equ 00001000b
MODE_REPORT     equ 00010000b
MODE_TEST       equ 00100000b

DIOD_PORT       equ 104h
DIOD_OK         equ 00000001b
DIOD_READY      equ 00000010b
DIOD_WORK       equ 00000100b
DIOD_READ       equ 00001000b
DIOD_FAIL       equ 00010000b
DIOD_ALLDARK        equ 00011111b
DIOD_WORK_KEEPD5    equ 00100100b

REAL_BAR        equ 01000000b