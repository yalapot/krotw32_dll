;###
epsilon         equ 30 ; ����c����� ���������� �� ����� � %
reserv_dspace       equ 6400 ; ������ ��������� ������������ (�
                ; ���������� 64� ������)
;###
;**
orient_delay         equ 3   ; ���������� ���������� ��������,
                 ; ����� ������� ����� ���������� �������� �
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

; ������������ �������� ������� ���������� ������ � ������
ACP_TIMEOUT     equ 15

; ���������� ������������ ���� ��������, ����� �������� ���� ������ �
; ����� ���������� (��������� '��������' ���� ��������)
BAR_DOWN_BORDER     equ 10

TIMER_INTERVAL_REG  equ 11932
TIMER_INTERVAL_VAL  equ 100
; ������������� �������� �� ��������� (� ����� �������)
STOP_CHECK_INTERVAL     equ (2 * TIMER_INTERVAL_VAL)
NOT_STOP        equ 0 ; ��������� ���
STOP_DATA_NOT_SAVED     equ 1 ; ����� � ������ �� ���������
STOP_DATA_SAVED     equ 2 ; ����� � ������ �������� �� ����

;ORIENT_SHIFT       equ 80h ;������������ ������ ���������� 19.06.97
;ORIENT_SHIFT       equ 0

; ��������� ��������� ������
SENS_SIGN       equ 90h ; ������
WELD_SIGN       equ 50h ; �������� ���
STOP_SIGN       equ 60h ; ���������
BarDownLabel        equ 70h ; ����� ��������
PowerFailLabel      equ 71h ; ������������� ������������
DiskFullLabel       equ 72h ; ������������ ���������� (���������)
POWERON_SIGN        equ 7fh ; ��������� �������

RecordName      equ 'trace.krt'
SinhroName      equ 'sinhro.krt'

;irq 11
ODOMETR_INTERRUPT   equ 73h
IRQ_MASK        equ 10110111b ; ��������� ������� � ���������

;irq 15
;ODOMETR_INTERRUPT  equ 77h
;IRQ_MASK       equ 00111111b ; ��������� ������� � ���������

; �����
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