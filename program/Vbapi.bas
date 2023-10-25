Attribute VB_Name = "vbapi"
'Файл описания интерфейса между программой просмотра на Visual Basic и krotw32.dll на C.
'(C) Vitaly Bogomolov 2001-2005.

' типы изображения в линзе
Public Const ZOOM_NONE = -1
Public Const ZOOM_COMMON = 0
Public Const ZOOM_SMOOTH = 1
Public Const ZOOM_LINES = 2
Public Const ZOOM_3D = 3

'структура описания параметров окна отображения развертки в режиме цветовой карты
Public Type VB_PAINT_INFO
 orntOff As Long       'флаг отключения ориентации
 baseLine As Long      'положение базовой линии для выравнивания
 amplif As Long        'коэф-нт усиления
 intwin As Long        'длина окна интегрирования
End Type

'структура описания параметров фильтров развертки
Public Type VB_FILTER_INFO
 active As Long        'тип текущего фильтра (0 - фильтр отключен)
 unweldParam As Long   'параметр фильтра бесшовных труб
 rolledParam1 As Long  'параметр1 фильтра цельнотянутых труб
 rolledParam2 As Long  'параметр2 фильтра цельнотянутых труб
 rolledAmplifer As Long  'параметр усиления фильтра цельнотянутых труб
 tfiParam1 As Long     'параметр1 фильтра продольных трещин
 tfiParam2 As Long     'параметр2 фильтра продольных трещин
 tfiBase As Long       'применять ли "базовую линию" в фильтре TFI (0/1)
End Type

'структура описания параметров окна отображения развертки в режиме графиков
Public Type VB_GRAPH_INFO
 amplif As Long        ' коэф-нт усиления
 gap As Long           ' величина прореживания
 clrBackGround As Long ' цвет фона
 clrOdd As Long        ' цвет нечетных графиков
 clrEven As Long       ' цвет четных графиков
End Type

'структура описания драйвера
Public Type VB_DRV_INFO
 apiVer As Long        ' версия API драйвера
 isSpiral As Long      ' внешнетрубник?
 ' номер версии драйвера
 drvVerMax As Long     ' старший разряд
 drvVerMin As Long     ' младший разряд
End Type

'структура для передачи в VB информации об открытом прогоне
Public Type VB_TRACE_INFO
 onLine As Long        ' флаг возможности динамического обновления данных
 crzZoneNum As Long    ' количество поясов короз.датчиков
 extSensors As Long    ' кол-во вспомогательных датчиков
 vog As Long           ' функция VOG
 evnt As Long          ' поддержка событий
 odom As T_SENS        ' одометры (разница .max - .min это длина трассы)
 Tmr As T_SENS         ' таймеры (разница .max - .min это длительность прогона)
 shake As T_SENS       ' ускорение
 press As T_SENS       ' давление
 temp As T_SENS        ' температура
 angle As T_SENS       ' угловые скорости
 wall As T_SENS        ' толщина стенки трубы
 orient As T_SENS      ' ориентация
 speed As T_SENS       ' скорость в см/сек
End Type

'обьявления внешних функций krotw32.dll используемых из VB


Public Declare Function krotTopSens Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal topSens As Long _
) As Integer

Public Declare Function krotChangePic Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hwnd As Long _
) As Integer

Public Declare Function krotPageScale Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal scaleIndex As Long _
) As Integer

Public Declare Function krotScreenMode Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef buf As Long, _
 ByRef t_paint As VB_PAINT_INFO, _
 ByRef t_grphs As VB_GRAPH_INFO _
) As Integer

Public Declare Function krotScreenFilter Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef t_filter As VB_FILTER_INFO _
) As Integer

Public Declare Function krotError Lib "krotw32.dll" ( _
 ByVal lpReturnedString As String _
) As Long

Public Declare Function krotOpenTrace Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal FileName As String, _
 ByVal indxFolder As String, _
 ByVal driverFileName As String, _
 ByVal newDataRegistered As Long, _
 ByRef t_info As VB_TRACE_INFO _
) As Integer

Public Declare Function krotCloseTrace Lib "krotw32.dll" ( _
 ByVal handle As Long _
) As Integer

Public Declare Function krotPaint Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hwnd As Long, _
 ByVal start As Long, _
 ByVal forceReadData As Long, _
 ByVal drawMode As Long _
) As Integer

Public Declare Function checkVmode Lib "krotw32.dll" () As Integer

Public Declare Function krotExtSensorInfo Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal Index As Long, _
 ByRef sens As T_SENS, _
 ByVal lpReturnedString As String _
) As Integer

Public Declare Function krotExtCorozInfo Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndex As Long, _
 ByRef c_info As T_SENSGROUP _
) As Integer

Public Declare Function krotGetFirstNode Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATA, _
 ByVal pos As Long, _
 ByVal sensType As Long, _
 ByVal sensIndx As Long, _
 ByVal seqLength As Long, _
 ByVal controlPixelsNum As Long _
) As Integer

Public Declare Function krotGetNextNode Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATA _
) As Integer

Public Declare Function krotGetFirstNodeGroup Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATAGROUP, _
 ByVal pos As Long, _
 ByVal sensGroup As Long, _
 ByVal seqLength As Long, _
 ByVal controlPixelsNum As Long _
) As Integer

Public Declare Function krotGetNextNodeGroup Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATAGROUP _
) As Integer

Public Declare Function krotGetSingleSens Lib "krotw32.dll" ( _
  ByVal handle As Long, _
  ByVal crzIndx As Long, _
  ByVal sens As Long, _
  ByRef buf As Byte, _
  ByRef bufRow As Long _
) As Integer

Public Const KRT_ZOOM_FILTER = KRT_ERR + 1

Public Declare Function krotPaintZoom Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hWnd As Long, _
 ByVal xStart As Long, _
 ByVal xDataSize As Integer, _
 ByVal yStart As Integer, _
 ByVal yDataSize As Integer, _
 ByRef dllDat As Any, _
 ByRef dllRow As Any, _
 ByVal drawType As Long _
) As Integer

Public Declare Function krotGetVectSens Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal pos As Long, _
 ByRef buf As Byte, _
 ByRef bufRow As Long _
) As Integer

Public Declare Function krotSetClipboard Lib "krotw32.dll" ( _
  ByVal hWnd As Long _
) As Integer

Public Declare Function krotRegisterTrace Lib "krotw32.dll" ( _
  ByVal driverFileName As String, _
  ByVal primFile As String, _
  ByVal indxFolder As String, _
  ByVal trcFile As String, _
  ByVal informUser As Long _
) As Integer

Public Declare Function krotCheckDriver Lib "krotw32.dll" ( _
 ByVal driverFileName As String, _
 ByVal outDrvSign As String, _
 ByVal outDrvName As String, _
 ByVal outDrvCopyRt As String, _
 ByVal outFullDllPath As String, _
 ByRef d_info As VB_DRV_INFO _
) As Integer

Public Declare Function krotLockNodeSequence Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal lockActive As Long _
) As Integer

Public Declare Function krotEvent Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef evnt As T_EVENT _
) As Integer

Public Declare Function krotCorozDump Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal FileName As String, _
 ByVal isRow As Integer _
) As Integer

Public Declare Function krotZoomDump Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal FileName As String, _
 ByVal isRow As Long _
) As Integer

Public Declare Function krotZoomDumpEx Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal xStart As Long, _
 ByVal xDataSize As Integer, _
 ByVal FileName As String, _
 ByVal isRow As Long _
) As Integer

'структура описания параметров поиска шва
Public Type VB_TUBE_SCAN_IN
 scanStart As Long    'дистанция предыдущего шва
 lenMin As Long       'минимальная длина трубы
 lenMax As Long       'максимальная длина трубы

 maskSize As Long         'размер маски в показаниях датчиков
 listSize As Long         'ширина прокатного листа в показаниях датчиков
 signalLevel As Long      'уровень сигнала
 slitNum As Integer       'ожидаемое количество продольных швов

 weldSensitiv As Integer  'уровень чувствительности поперечных швов (от 1 до 100)
 slitSensitiv As Integer  'уровень чувствительности продольных швов (от 1 до 100)
                          'если 0, то продольные швы определять не надо.
 spirSensitiv As Integer  'то же для спиральных швов

 noDRC As Integer     'не может быть прямошовной
 noSPR As Integer     'не может быть спиралешовной
 noWTO As Integer     'не может быть бесшовной
 
 'параметры для алгоритма 2013
 Weld1_width As Integer
 Weld1_sens As Single
 Weld1_bord As Single
 Weld1_otst As Integer

 Weld2_width As Integer
 Weld2_sens As Single
 Weld2_bord As Single
 Weld2_second As Integer

 Spiral_width As Integer
 Spiral_sens As Single
 Spiral_bord As Single
 Spiral_area As Integer
End Type

'структура описания параметров найденного шва
Public Type VB_TUBE_SCAN_OUT
 wldDst As Long       'дистанция найденного шва
 wldTyp As Integer    'тип трубы (0-прямошовная, 1-спираль, 2-бесшовка)
 wld1 As Integer      'номер датчика 1 продольного шва (-1 если нет)
 wld2 As Integer      'номер датчика 2 продольного шва (-1 если нет)
 crzIndx As Integer   'пояс, по которому определены продольные швы
End Type

Public Declare Function krotScanWeld Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef prmIn As VB_TUBE_SCAN_IN, _
 ByRef prmOut As VB_TUBE_SCAN_OUT, _
 ByVal is2013 As Integer _
) As Integer

''''''''''' поддержка палитры
''''''''''''''''''''''''''''''''''''''''''''''''''''

Global Const PAL_SIZE = &H7FFFFFFF

'составляющие RGB цвета (возможные значения rgbItem)
Public Const RGB_RED = 0
Public Const RGB_GREEN = 1
Public Const RGB_BLUE = 2

Public Declare Function rgbColor Lib "krotw32.dll" ( _
 ByVal colorCode As Long, _
 ByVal rgbItem As Integer _
) As Integer

'Структура элемента палитры
Public Type VB_PAL_ITEM
 iPos As Long                   ' положение на векторе элементов
 iVal As Long                   ' значение полного кода цвета
End Type

'Структура палитры пользователя
Public Type VB_PAL
 ItemNum As Long                ' кол-во элементов в массиве по адресу item
 minItem As VB_PAL_ITEM         ' первый элемент палитры
 maxItem As VB_PAL_ITEM         ' последний элемент палитры
End Type

' Функция инициализирует палитру для редактора палитр.
Public Declare Sub krtPalInit Lib "krotw32.dll" ()
' Функция освобождает ресурсы из палитры для редактора палитр.
Public Declare Sub krtPalClose Lib "krotw32.dll" ()

' Функция устанавливает данные палитры для развертки crzIndx прогона Handle.
' Если Handle == -1, то данные устанавливаются для редактора палитр.
' аргумент item это указатель на массив элементов палитры между первым и последним.
' должны быть отсортированы по item->iPos по возрастанию.
' Возвращает KRT_OK при успехе, KRT_ERR при ошибке.
Public Declare Function krtPalSet Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal brdMin As Long, _
 ByVal brdMax As Long, _
 ByVal usrMin As Long, _
 ByVal usrMax As Long, _
 ByRef Pal As VB_PAL, _
 ByRef palItem As Long _
) As Integer

' Функция рисует палитру для развертки crzIndx прогона Handle в окне hwnd.
' Если Handle == -1, то рисуется палитра редактора палитр.
' Возвращает KRT_OK при успехе, KRT_ERR при ошибке.
Public Declare Function krtPalDraw Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hWnd As Long _
) As Integer

' Процедура задает тип прореживания точек при изменении масштаба изображения
' i = 0 - выбирается максимальное значение
' i = 1 - выбирается минимальное значение
' i = 2 - выбирается среднее значение
' i = 3 - выбирается первое попавшееся значение
Public Declare Sub SetScaleMode Lib "krotw32.dll" (ByVal i As Integer)

' Функция возвращает тип масштабирования точек, установленный для текущего открытого прогона
Public Declare Function GetScaleMode Lib "krotw32.dll" () As Integer
