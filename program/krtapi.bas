Attribute VB_Name = "krtapi"
Option Explicit

'версии API драйверов
Public Const KRT_API_V1 = 1
Public Const KRT_API_V2 = 2

'коды возврата krotw32.dll
Public Const KRT_OK = 0
Public Const KRT_ERR = 1

'размер буфера под имя вспомогательного датчика
Public Const KRT_TEXT = 1024
Public Const KRT_MAX_EXTSEN_NAME = KRT_TEXT

'типы датчиков развертки
Public Enum KRT_SENS_TYPE
SENS_TYPE_HOLL = 1      ' Основной пояс Холл
SENS_TYPE_FERR = 2      ' Феррозонд
SENS_TYPE_INDK = 3      ' Индукционный

' эти типы датчиков передают реальную информацию о поясе датчиков

SENS_RESIDUAL = 4       ' Остаточная намагниченность
SENS_PROFIL = 5         ' Профильные датчики
SENS_TFI = 6            ' продольная намагниченность (стресс)
SENS_MFL = 7            ' поперечная намагниченность (коррозионник)
SENS_INTROSCOPE = 8     ' интроскоп
End Enum

'типы дополнительных датчиков
Public Enum KRT_SENS
SENS_TIMER = 1          ' таймер
SENS_ODO = 2            ' одометр
SENS_ORIENT = 4         ' ориентация
SENS_SHAKE = 8          ' ускорение
SENS_PRESS = 16         ' давление
SENS_TEMP = 32          ' температура
SENS_ANGLE = 64         ' угловых скоростей
SENS_VOG = 128          ' VOG
SENS_THICK = 256        ' толщина стенки
SENS_AZIMUTH = 512      ' азимут
SENS_TANGAZH = 1024     ' тангаж

SENS_COROZ = 16777216   ' корозионный
SENS_SPEED = 33554432   ' скорость
SENS_CURVE = 67108864   ' изгиб
SENS_EXT = 134217728    ' вспомогательный
End Enum

'структура описания датчика
Public Type T_SENS
num As Long            ' количество
stepSize As Long       ' дискретность измерения (мм/милисек - от метода опроса)
minVal As Long         ' минимальное значение (размерность аналогично T_NODEGROUP)
maxVal As Long         ' максимальное значение (размерность аналогично T_NODEGROUP)
End Type

'структура описания пояса датчиков развертки
Public Type T_SENSGROUP
num As Long            ' кол-во датчиков в поясе
stype As Long           ' тип датчиков (SENS_TYPE_*)
minVal As Long         ' минимальное значение показаний датчика (единицы АЦП)
maxVal As Long         ' максимальное значение показаний датчика (единицы АЦП)
isRow As Long          ' 1/0 если 0 сырые данные не поддерживаются
maxRowVal As Long      ' максимальное значение сырых данных
minRowVal As Long      ' минимальное значение сырых данных
End Type

'структура описания события
Public Type T_EVENT
type As Long           ' тип события (KRT_EVNT_*)
pos As Long            ' положение события на трассе (мм)
param1 As Long         ' параметры события
param2 As Long
End Type

'структура для показаний одиночного датчика
Public Type T_NODEDATA
 sensVal As Long       'значение датчика
 prevPos As Long       'положение на трассе значения предыдущего поля
End Type

'структура для показаний группы датчиков
Public Type T_NODEDATAGROUP

 timerVal As Long      'значение таймера
 timerPos As Long      'положение на трассе показаний таймера

 odoVal As Long        'значение одометра
 odoPos As Long        'положение на трассе показаний одометра

 orientVal As Long     'значение датчика ориентации
 orientPos As Long     'положение на трассе показаний датчика ориентации

 shakeVal As Long      'значение датчика ускорения
 shakePos As Long      'положение на трассе показаний датчика ускорения

 pressVal As Long      'значение датчика давления
 pressPos As Long      'положение на трассе показаний датчика давления

 tempVal As Long       'значение датчика температуры
 tempPos As Long       'положение на трассе показаний датчика температуры

 angleVal As Long      'значение датчика угловых скоростей
 anglePos As Long      'положение на трассе показаний датчика угловых скоростей

 thickVal As Long      'значение канала толщины стенки трубы
 thickPos As Long      'положение на трассе показаний канала толщины стенки трубы
                        'датчики VOG (из VOG файла)
 vogx As Long           'ордината, см
 vogy As Long           'аппликата, см
 vogZ As Long           'абсцисса, см
 vogext1 As Single      'Psi, азимут, рад
 vogext2 As Single      'Teta, тангаж, рад
 vogext3 As Single      'Gamma, крен, рад
 vogPos As Long        'положение на трассе данных показаний датчиков VOG

End Type

'структура сообщения о поступлении новых данных
Public Type T_ARRIVED_DATA
 d_start As Long       'начало участка новых данных
 d_length As Long      'длина участка новых данных
End Type

Public Function getCorozSensName(ByVal zoneType As KRT_SENS_TYPE) As String
Select Case zoneType
 Case KRT_SENS_TYPE.SENS_INTROSCOPE
  getCorozSensName = "Интроскоп"
 Case KRT_SENS_TYPE.SENS_PROFIL
  getCorozSensName = "Профильный"
 Case KRT_SENS_TYPE.SENS_RESIDUAL
  getCorozSensName = "Остаточный"
 Case KRT_SENS_TYPE.SENS_MFL
  getCorozSensName = "Продольный"
 Case KRT_SENS_TYPE.SENS_TFI
  getCorozSensName = "Поперечный"
 Case Else
  getCorozSensName = "Неизвестный"
End Select
End Function
