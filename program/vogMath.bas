Attribute VB_Name = "VogMath"
'Файл описания интерфейса между программой просмотра на Visual Basic и
'vogmath.dll на C.
'(C) Vitaly Bogomolov 2001.

Public Const TURN_GOR = 0  'поворот в азимутальной плокости
Public Const TURN_VER = 1  'поворот в нормальной (вертикальной) плокости
Public Const TURN_3D = 8  'комплексный 3D поворот
Public Const TURN_START = 2 'поправка на длину снаряда в начале поворота
Public Const TURN_END = 4  'поправка на длину снаряда в конце поворота

Public Const MATCH_MODE_SHIFT = 1    'преобразование сдвига
Public Const MATCH_MODE_SCALE = 2    'преобразование растяжения/сжатия
Public Const MATCH_MODE_ROTATE = 4   'преобразование поворота

Public Enum VOG_GRAPH
GRAPH_AZIMUTH = 1
GRAPH_TANGAZH = 2
End Enum

Public Type T_TURNDATA
 radius As Long    'радиус кривизны в мм.
 angle As Single   'угол поворота в радианах
End Type

Public Type T_VOGDRIVERDATA
 IsProfil As Long        ' признак профильного снаряда
 ProfilPigLength As Long ' расстояние между манжетами
 OdoAngle As Long        ' угол между плоскостью колеса одометра и первой ластой
End Type

Public Const VOG_SHIFT01 = 100  'сдвиг для учета подхода снаряда ко шву, мм
'Public Const VOG_SHIFT02 = 500  'сдвиг для учета выхода снаряда со шва, мм

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Экспортируемые функции
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'функция заполняет структуру T_CURVEDATA
'данными о параметрах поворота,
'возвращает KRT_OK при успехе, KRT_ERR при ошибке.
'Аргументы:
'calc_type   тип расчета
'            0 - "классический" вариант, 1 - "профильный"
'handle      хэндл открытого прогона
'turnkind    битовая маска
'            бит 0
'            сбошен - поворот в плоскости горизонта
'            установлен - поворот в вертикальной плоскости
'            бит 1
'            установлен - необходима поправка на длину снаряда в начале поворота
'            бит 2
'            установлен - необходима поправка на длину снаряда в конце поворота
'            бит 3
'            установлен - считать 3D поворот не обращая внимание на бит 0
'start       начало поворота
'length      длина поворота
'diam        значение параметра "Diameter" секции [Trace] trc файла
'pigLength   значение параметра "PigLength" секции [Trace] trc файла
'turninf     указатель на структуру T_TURNDATA, которую
'            необходимо заполнить данными о параметрах поворота
Public Declare Function GetCurveData Lib "vogmath.dll" ( _
 ByVal handle As Long, _
 ByVal calc_type As Long, _
 ByVal turnkind As Long, _
 ByVal Start As Long, _
 ByVal length As Long, _
 ByVal diam As Long, _
 ByVal pigLength As Long, _
 ByRef turninf As T_TURNDATA _
) As Long

'Функция инициализирует процедуру совмещения участков двух прогонов,
'задаваемых дескрипторами прогонов, началом и концом участков.
'Если аргумент handleSlave = -1, то все следующие за ним аргументы
'кроме аргумента controlSize игнорируются и координаты выдаются для
'handleMaster.
'В зависимомости от маски matchMode, находятся те или иные параметры
'необходимого преобразования координат для совмещения участков.
'В дальнейшем с помощью вызова функции GetNextMatching основная программа
'получает текущие координаты ведомого прогона с учетом необходимых преобразований
'Аргументы:
'handleMaster   хэндл ведущего прогона
'startMaster    начало участка совмещения на ведущей записи
'lengthMaster   длина участка совмещения на ведущей записи
'handleSlave    хэндл ведомого прогона, если -1, то выдается координаты мастера
'startSlave     начало участка совмещения на ведомой записи
'lengthSlave    длина участка совмещения на ведомой записи
'controlSize    размер контрола для отображения результатов
'               совмещения в экранных пикселах
'matchMode      битовая маска, задающая режим совмещения записей
'               набор из констант MATCH_MODE_*
'rotAngle       угол поворота изображения от 0 до 2пи
Public Declare Function vogInitMatching Lib "vogmath.dll" Alias "InitMatching" ( _
 ByVal rotAngle As Double, _
 ByVal handleMaster As Long, _
 ByVal startMaster As Long, _
 ByVal lengthMaster As Long, _
 ByVal handleSlave As Long, _
 ByVal startSlave As Long, _
 ByVal lengthSlave As Long, _
 ByVal controlSize As Long, _
 ByVal matchMode As Long _
) As Long

'Функция запоняет поля vogx, vogy, vogz структуры T_NODEGROUP
'координатами текущей точки пути ведомого прогона с учетом необходимых афинных
'преобразований.
'Поля vogext1, vogext2, vogext3 соответствующей структуры
'заполняются нулями (не нужны в данном контексте)
'Аргументы:
'node       указатель на структуру которую нужно заполнить
'           преобразованными координатами прогона заданного
'           дескриптором handleSlave при вызове InitMatching
Public Declare Function vogGetNextMatching Lib "vogmath.dll" Alias "GetNextMatching" ( _
 ByRef node As T_NODEDATAGROUP _
) As Long

'Функция заполняет строку outString описанием последней ошибки произошедшей
'при работе с записями прогонов. Возвращает длину строки сообщения об ошибке.
Public Declare Function vogError Lib "vogmath.dll" Alias "krotError" ( _
 ByVal outString As String _
) As Long

' функция инициализации
Public Declare Function vogInit Lib "vogmath.dll" Alias "Init" ( _
 drvdata As T_VOGDRIVERDATA _
) As Long
