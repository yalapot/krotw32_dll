Attribute VB_Name = "vbapi"
'���� �������� ���������� ����� ���������� ��������� �� Visual Basic � krotw32.dll �� C.
'(C) Vitaly Bogomolov 2001-2005.

' ���� ����������� � �����
Public Const ZOOM_NONE = -1
Public Const ZOOM_COMMON = 0
Public Const ZOOM_SMOOTH = 1
Public Const ZOOM_LINES = 2
Public Const ZOOM_3D = 3

'��������� �������� ���������� ���� ����������� ��������� � ������ �������� �����
Public Type VB_PAINT_INFO
 orntOff As Long       '���� ���������� ����������
 baseLine As Long      '��������� ������� ����� ��� ������������
 amplif As Long        '����-�� ��������
 intwin As Long        '����� ���� ��������������
End Type

'��������� �������� ���������� �������� ���������
Public Type VB_FILTER_INFO
 active As Long        '��� �������� ������� (0 - ������ ��������)
 unweldParam As Long   '�������� ������� ��������� ����
 rolledParam1 As Long  '��������1 ������� ������������� ����
 rolledParam2 As Long  '��������2 ������� ������������� ����
 rolledAmplifer As Long  '�������� �������� ������� ������������� ����
 tfiParam1 As Long     '��������1 ������� ���������� ������
 tfiParam2 As Long     '��������2 ������� ���������� ������
 tfiBase As Long       '��������� �� "������� �����" � ������� TFI (0/1)
End Type

'��������� �������� ���������� ���� ����������� ��������� � ������ ��������
Public Type VB_GRAPH_INFO
 amplif As Long        ' ����-�� ��������
 gap As Long           ' �������� ������������
 clrBackGround As Long ' ���� ����
 clrOdd As Long        ' ���� �������� ��������
 clrEven As Long       ' ���� ������ ��������
End Type

'��������� �������� ��������
Public Type VB_DRV_INFO
 apiVer As Long        ' ������ API ��������
 isSpiral As Long      ' �������������?
 ' ����� ������ ��������
 drvVerMax As Long     ' ������� ������
 drvVerMin As Long     ' ������� ������
End Type

'��������� ��� �������� � VB ���������� �� �������� �������
Public Type VB_TRACE_INFO
 onLine As Long        ' ���� ����������� ������������� ���������� ������
 crzZoneNum As Long    ' ���������� ������ �����.��������
 extSensors As Long    ' ���-�� ��������������� ��������
 vog As Long           ' ������� VOG
 evnt As Long          ' ��������� �������
 odom As T_SENS        ' �������� (������� .max - .min ��� ����� ������)
 Tmr As T_SENS         ' ������� (������� .max - .min ��� ������������ �������)
 shake As T_SENS       ' ���������
 press As T_SENS       ' ��������
 temp As T_SENS        ' �����������
 angle As T_SENS       ' ������� ��������
 wall As T_SENS        ' ������� ������ �����
 orient As T_SENS      ' ����������
 speed As T_SENS       ' �������� � ��/���
End Type

'���������� ������� ������� krotw32.dll ������������ �� VB


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

'��������� �������� ���������� ������ ���
Public Type VB_TUBE_SCAN_IN
 scanStart As Long    '��������� ����������� ���
 lenMin As Long       '����������� ����� �����
 lenMax As Long       '������������ ����� �����

 maskSize As Long         '������ ����� � ���������� ��������
 listSize As Long         '������ ���������� ����� � ���������� ��������
 signalLevel As Long      '������� �������
 slitNum As Integer       '��������� ���������� ���������� ����

 weldSensitiv As Integer  '������� ���������������� ���������� ���� (�� 1 �� 100)
 slitSensitiv As Integer  '������� ���������������� ���������� ���� (�� 1 �� 100)
                          '���� 0, �� ���������� ��� ���������� �� ����.
 spirSensitiv As Integer  '�� �� ��� ���������� ����

 noDRC As Integer     '�� ����� ���� �����������
 noSPR As Integer     '�� ����� ���� �������������
 noWTO As Integer     '�� ����� ���� ���������
 
 '��������� ��� ��������� 2013
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

'��������� �������� ���������� ���������� ���
Public Type VB_TUBE_SCAN_OUT
 wldDst As Long       '��������� ���������� ���
 wldTyp As Integer    '��� ����� (0-�����������, 1-�������, 2-��������)
 wld1 As Integer      '����� ������� 1 ����������� ��� (-1 ���� ���)
 wld2 As Integer      '����� ������� 2 ����������� ��� (-1 ���� ���)
 crzIndx As Integer   '����, �� �������� ���������� ���������� ���
End Type

Public Declare Function krotScanWeld Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef prmIn As VB_TUBE_SCAN_IN, _
 ByRef prmOut As VB_TUBE_SCAN_OUT, _
 ByVal is2013 As Integer _
) As Integer

''''''''''' ��������� �������
''''''''''''''''''''''''''''''''''''''''''''''''''''

Global Const PAL_SIZE = &H7FFFFFFF

'������������ RGB ����� (��������� �������� rgbItem)
Public Const RGB_RED = 0
Public Const RGB_GREEN = 1
Public Const RGB_BLUE = 2

Public Declare Function rgbColor Lib "krotw32.dll" ( _
 ByVal colorCode As Long, _
 ByVal rgbItem As Integer _
) As Integer

'��������� �������� �������
Public Type VB_PAL_ITEM
 iPos As Long                   ' ��������� �� ������� ���������
 iVal As Long                   ' �������� ������� ���� �����
End Type

'��������� ������� ������������
Public Type VB_PAL
 ItemNum As Long                ' ���-�� ��������� � ������� �� ������ item
 minItem As VB_PAL_ITEM         ' ������ ������� �������
 maxItem As VB_PAL_ITEM         ' ��������� ������� �������
End Type

' ������� �������������� ������� ��� ��������� ������.
Public Declare Sub krtPalInit Lib "krotw32.dll" ()
' ������� ����������� ������� �� ������� ��� ��������� ������.
Public Declare Sub krtPalClose Lib "krotw32.dll" ()

' ������� ������������� ������ ������� ��� ��������� crzIndx ������� Handle.
' ���� Handle == -1, �� ������ ��������������� ��� ��������� ������.
' �������� item ��� ��������� �� ������ ��������� ������� ����� ������ � ���������.
' ������ ���� ������������� �� item->iPos �� �����������.
' ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
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

' ������� ������ ������� ��� ��������� crzIndx ������� Handle � ���� hwnd.
' ���� Handle == -1, �� �������� ������� ��������� ������.
' ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
Public Declare Function krtPalDraw Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hWnd As Long _
) As Integer

' ��������� ������ ��� ������������ ����� ��� ��������� �������� �����������
' i = 0 - ���������� ������������ ��������
' i = 1 - ���������� ����������� ��������
' i = 2 - ���������� ������� ��������
' i = 3 - ���������� ������ ���������� ��������
Public Declare Sub SetScaleMode Lib "krotw32.dll" (ByVal i As Integer)

' ������� ���������� ��� ��������������� �����, ������������� ��� �������� ��������� �������
Public Declare Function GetScaleMode Lib "krotw32.dll" () As Integer
