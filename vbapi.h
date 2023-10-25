#ifndef _VBAPI_H_
#define _VBAPI_H_
/*
���� �������� ����������, ���������������� ����� ��������� ��������� krotw32.dll 
(C) Vitaly Bogomolov 2001-2007.

������ ���������� ������������ ����� ����� ������� (� ���������� ����), ��� ������ ������� ����� ����������� ������
� ��������� �������, �������������� ��������� krtapi ������ 1 � 2, � ���������� ��� ������ � ����� win32 GUI.
����� ����� � ���������� ������� ����� ��������������� ��������� �������.

��� ������� ���� ���������� ���� �� ���� ��������: 
KRT_OK � ������ ��������� ���������� ������ � KRT_ERR � ������, ���� ��������� ������.
��� ��� ��������� ���������� � ����� krtapi.h.
��������� �������� ��������� ��������� ������ ����� ��������, � ������ outString ������ KRT_TEXT (krtapi.h) 
������ ������� 

long EXPORT KRTAPI krotError (LPSTR outString);

�� ������ ������ � ������� ����� ��������������� ����� ���������� ���������:

krotCheckDriver - ���������, �������� �� dll, ��������� � ��������� driverFileName ���������� ��������� krtapi �
��������� ����������� �� ���� �������� ��������� ���������.

krotRegisterTrace - �������� ������� ����������� ��������� ������ ������ primFile ��� ������ �������� driverFileName.
� �������� ����������� ��������� trc ����, ������� � ���������� ����� ������������ ��� ������.

������� ������� ������ � ������� ����� ������� ��������� �������:

�������� �� ������������ ��� trc ����� fileName, �� �������� ����� ������������� ������.
������������ � ����� ��������� ���������� ���������� ������ Handle. 
��� ����� ����, ��������, ����� 1.
�������� �� ini-����� fileName (������ [Trace], ���� Index) 
��� �������� indxFolder � ���������� ������� ������.

�������� ��� ��������� ������ (outDrvSign, outDrvName, outDrvCopyRt) ������ KRT_TEXT (krtapi.h)
������� ��������� ��������� VB_TRACE_INFO (vbapi.h)
������� ������� 

short EXPORT KRTAPI krotOpenTrace (
 KRTHANDLE Handle, 
 LPSTR fileName, 
 LPSTR indxFolder, 
 LPSTR driverFileName, 
 LPSTR outDrvSign,     // ��������� ��������
 LPSTR outDrvName,     // �������� ��������
 LPSTR outDrvCopyRt,   // ������ ���������
 VB_TRACE_INFO *inf);

����� ��������� ������ krotOpenTrace ���� inf->crzZoneNum �������� ���������� ������ ��������
����������� ���������. ������ ���� (������ 0) �������� �������� ������, ��������� ����������������.
���������� ������� ����� ����� crzIndex (�� 0 �� inf->crzZoneNum - 1), 
��� �������� ����� ������������� ������.
������� ��������� ��������� T_SENSGROUP (krtapi.h) � ������� ������� krotExtCorozInfo.
����� ��������� ������ krotExtCorozInfo ���� cinf->crz.num �������� ���������� �������� � �����, 
� ���� cinf->crz.step �������� ������ ���� ������ �� X � ��.

���� � ������ ������� ���.�������, �� ����� ������ krotOpenTrace ���� inf->extSensors ����� ��������� 
�� ����������. �������� ���������� � ��� ����� ��� ������ ������� krotExtSensorInfo, ��������� �� 
������ ����� ���.�������.

���� ����� ������������ ������ ������ ������������ ��������� � ����� win32 GUI, ��������� �������� ������.
������� ������ � ��������� ����� �������� ������� ���� � ���� �����. ������ ������ ��������� ������ ������� 
� ��������������� ������� ����������� ������������ ��������� '���� ��� Win32'. 

������ ��� �������� ���������� ������ ���.��������� � ����, ����� ���������, ��� ������� ���������� �������
�������������� �����. ��� ����� ������� ��� ������ ������� checkVmode.

���������� ����� �������, ������� ��������� ������� ����������� ������ ���.���������. 
������ �������� ���� ������� ������ ���������� �������� ������, ������ - ����� ����� ���.��������� (������� � 0).
��� ������� �������� � ����:

krotTopSens - ������ �������� ������������� ������������ ������ ����� ���������.

krotChangePic - ������ ������������ � �������������� ������ ���� ����������� ���.������ �� ������ ���������������� ����.

krotPageScale - ������ �������������� ������� ������/���������� ������ ��� �����������.

krotScreenMode - ������ ���.��������� ����������� � ������ �������� ����� (��������� ������� �����) � 
������ �������� (������������, ��������, ����� ��������).

���������� ����� ���.������ � ��������� start � ���� �������������� �������� krotPaint.
��������� ������ � ���� ����� � ����������� �������������� ��������� ����������� ����������� ��� ������
������� krotPaintZoom.

��������� ������ ������� ������������ ��� ������� ������ �������� �������� �� ������:

krotGetFirstNode � krotGetNextNode ��� ��������� ������ ������ �������.
krotGetFirstNodeGroup � krotGetNextNodeGroup  ��� ��������� ��������� ������ ��������.
������� krotLockNodeSequence ������������ ��� ������������ ������ ���������� ������� krotGetFirstNode* 
��� ���������� �������� ������� krotGetNextNode*.
krotGetSingleSens ��� ��������� ������� ��������� ���.������� � ������� ������������ �������� ������.
krotGetVectSens ��� ��������� ������� ��������� ���.�������� �� �������� ��������� (���� ��������).

��������� ������ ������� ������������ ��� ������� ������ � �������������� � �������� �����������:

krotSetClipboard - �������� ���������� ��������� ���� � ���� ������ � ��������� ����� ������.
krotCorozDump - ���������� � ��������� ���� ��������� �������� ���.���������, ������������ � ���� � ������� ������.
krotScanWeld - ���� ���������� � ���������� ��� �� �������� ������� ������.
krotDai - �������� �� ������� dai.dll �������� ������ ��� ������ � ������� ��������.
krotCorozData - �������� � ��������� ����� �������� �������� ���.������.

�� ���������� ������ ������ ������ ���������� ������� �������� krotCloseTrace.

*/

// ������ ��������
#define SMODE_NORMAL      0
#define SMODE_FILTER      1
#define SMODE_DELETE      2

// ���� ����������� � �����
#define ZOOM_NONE  -1
#define ZOOM_COMMON 0
#define ZOOM_SMOOTH 1
#define ZOOM_LINES  2
#define ZOOM_3D     3

// ��������� �������� ���������� ���� ����������� ��������� � ������ �������� �����
typedef struct {
 long orntOff;         // ���� ���������� ����������
 long baseLine;        // ��������� ������� ����� ��� ������������
 long amplif;          // ����-�� ��������
 long intwin;          // ����� ���� ��������������
} VB_PAINT_INFO;
/*
Public Type VB_PAINT_INFO
 orntOff As Long       '���� ���������� ����������
 baseLine As Long      '��������� ������� ����� ��� ������������
 amplif As Long        '����-�� ��������
 intwin As Long        '����� ���� ��������������
End Type
*/

// ��������� �������� ���������� ���� ����������� ��������� � ������ �������� �����
typedef struct {
 long active;          // ��� �������� ������� (0 - ������ ��������)
 long unweldParam;     // �������� ������� ��������� ����           
 long rolledParam1;    // ��������1 ������� ������������� ����
 long rolledParam2;    // ��������2 ������� ������������� ����
 long rolledAmplifer;  // �������� �������� ������� ������������� ����
 long tfiParam1;       // ��������1 ������� ���������� ������
 long tfiParam2;       // ��������2 ������� ���������� ������
 long tfiBase;         // ��������� �� "������� �����" � ������� TFI (0/1)
} VB_FILTER_INFO;
/*
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
*/

// ��������� �������� ���������� ���� ����������� ��������� � ������ ��������
typedef struct {
 long amplif;          // ����-�� ��������
 long gap;             // �������� ������������
 long clrBackGround;   // ���� ����
 long clrOdd;          // ���� �������� ��������
 long clrEven;         // ���� ������ ��������
} VB_GRAPH_INFO;
/*
Public Type VB_GRAPH_INFO
 amplif As Long        ' ����-�� ��������
 gap As Long           ' �������� ������������
 clrBackGround As Long ' ���� ����
 clrOdd As Long        ' ���� �������� ��������
 clrEven As Long       ' ���� ������ ��������
End Type
*/

// ��������� ��� �������� �� VB ���������� � ��������������� ���� ��� DAI
typedef struct {
 long orntStart;       // ��������� ������ ������ ������� ������ �� ���������� ����� � �������� (1-360)
 long orntLen;         // ������ ������� �� ���������� ����� � �������� (1-360) ���������� ������������� ����������
 long itemX;           // ������������� �������� ������� ������ ����� ����� � ��. (��� ������ �������)
 long itemY;           // ������������� �������� ������� ������ �� ���������� ����� � ��. (���������� ����� ���������)
} VB_DAI_INFO;
/* 
Public Type VB_DAI_INFO
 orntStart As Long     '��������� ������ ������ ������� ������ �� ���������� ����� � �������� (1-360)               
 orntLen As Long       '������ ������� �� ���������� ����� � �������� (1-360) ���������� ������������� ����������   
 itemX As Long         '������������� �������� ������� ������ ����� ����� � ��. (��� ������ �������)                
 itemY As Long         '������������� �������� ������� ������ �� ���������� ����� � ��. (���������� ����� ���������)
End Type
*/

// ��������� �������� ��������
typedef struct {
 long apiVer;          // ������ API ��������
 long isSpiral;        // �������������?
 long drvVerMax;       // ����� ������ ��������, ������� ������
 long drvVerMin;       // ����� ������ ��������, ������� ������
} VB_DRV_INFO;

/*
Public Type DRV_INFO 
 apiVer As Long        ' ������ API ��������
 isSpiral As Long      ' �������������?
 ' ����� ������ ��������
 drvVerMax As Long     ' ������� ������
 drvVerMin As Long     ' ������� ������
End Type
*/

// ��������� ��� �������� � VB ���������� �� �������� �������
typedef struct {

 long onLine;          // ���� ���������������� ������������� ���������� ������

 long crzZoneNum;      // ���������� ������ �����.��������
 long extSensors;      // ���-�� ��������������� ��������
 long VOG;             // ������� VOG
 long evnt;            // ��������� �������

 T_SENS odom;          // �������� (������� .max - .min ��� ����� ������)
 T_SENS timer;         // ������� (������� .max - .min ��� ������������ �������)

 T_SENS shake;         // ���������
 T_SENS press;         // ��������
 T_SENS temp;          // �����������
 T_SENS angle;         // ������� ��������
 T_SENS wall;          // ������� ������ �����

 T_SENS orient;        // ����������
 T_SENS speed;         // �������� � ��/���

} VB_TRACE_INFO;
/*
Public Type VB_TRACE_INFO

 onLine As Long        ' ���� ����������� ������������� ���������� ������

 crzZoneNum As Long    ' ���������� ������ �����.��������
 extSensors As Long    ' ���-�� ��������������� ��������
 VOG As Long           ' ������� VOG
 evnt As Long          ' ��������� �������

 odom As T_SENS        ' �������� (������� .max - .min ��� ����� ������)
 tmr As T_SENS         ' ������� (������� .max - .min ��� ������������ �������)

 shake As T_SENS       ' ���������
 press As T_SENS       ' ��������
 temp As T_SENS        ' �����������
 angle As T_SENS       ' ������� ��������
 wall As T_SENS        ' ������� ������ �����

 orient As T_SENS      ' ����������
 speed As T_SENS       ' �������� � ��/���

End Type
*/

/**************************************************************************/
/* ���������� ������� ������� krotw32.dll ������������ �� VB              */
/**************************************************************************/

short EXPORT KRTAPI krotTopSens (
 KRTHANDLE Handle,
 long crzIndx,
 long topSens
);
/*
Public Declare Function krotTopSens Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal topSens As Long _
) As Integer
*/

short EXPORT KRTAPI CS_krotChangePic (
 KRTHANDLE Handle,
 long crzIndx,

 long pixelX,
 long pixelY
);


short EXPORT KRTAPI krotChangePic (
 KRTHANDLE Handle,
 long crzIndx,
 HWND hWnd
);
/*
Public Declare Function krotChangePic Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hwnd As Long _
) As Integer
*/

short EXPORT KRTAPI krotPageScale (
 KRTHANDLE Handle,
 long scale
);
/*
Public Declare Function krotPageScale Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal scale As Long _
) As Integer
*/

short EXPORT KRTAPI krotScreenFilter (
 KRTHANDLE Handle, 
 long crzIndx, 
 VB_FILTER_INFO *vbFilter
);
/*
Public Declare Function krotScreenFilter Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef t_filter As VB_FILTER_INFO _
) As Integer
*/

short EXPORT KRTAPI krotScreenMode (
 KRTHANDLE Handle, 
 long crzIndx, 
 long *sens,         
 VB_PAINT_INFO *vbScreen,
 VB_GRAPH_INFO *vbGraphs
);
/*
Public Declare Function krotScreenMode Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef buf As Long, _
 ByRef t_paint As VB_PAINT_INFO, _
 ByRef t_grphs As VB_GRAPH_INFO _
) As Integer
*/

short EXPORT KRTAPI CS_krotPaint (
 KRTHANDLE Handle,
 long crzIndx,
 long start,

 long pixelX,
 long pixelY,
// LPSTR fileName,
 char * bmp_buf

);

short EXPORT KRTAPI krotPaint (
 KRTHANDLE Handle, 
 long crzIndx, 
 HWND hWnd,
 long start, 
 long forceReadData,
 long drawMode
);
/*
Public Declare Function krotPaint Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hwnd As Long, _
 ByVal start As Long, _
 ByVal forceReadData As Long, _
 ByVal drawMode As Long _
) As Integer
*/

long EXPORT KRTAPI krotError (LPSTR outString);
/*
Public Declare Function krotError Lib "krotw32.dll" ( _
 ByVal lpReturnedString As String _
) As Long
*/

short EXPORT KRTAPI krotOpenTrace (
 KRTHANDLE Handle, 
 LPSTR fileName, 
 LPSTR indxFolder, 
 LPSTR driverFileName, 
 long (KRTAPI *newDataRegistered) (T_ArrivedData *newData),
 VB_TRACE_INFO *inf);
/*
Public Declare Function krotOpenTrace Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal FileName As String, _
 ByVal indxFolder As String, _
 ByVal driverFileName As String, _
 ByVal newDataRegistered As Long, _
 ByRef t_info As VB_TRACE_INFO _
) As Integer
*/

short EXPORT KRTAPI krotCloseTrace (KRTHANDLE Handle);
/*
Public Declare Function krotCloseTrace Lib "krotw32.dll" ( _
 ByVal handle As Long _
) As Integer
*/

short EXPORT KRTAPI checkVmode (void);
/*
Public Declare Function checkVmode Lib "krotw32.dll" () As Integer
*/

short EXPORT KRTAPI krotExtSensorInfo (
 KRTHANDLE Handle, 
 long index, 
 T_SENS *sens, 
 char *lpReturnedString
);
/*
Public Declare Function krotExtSensorInfo Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal index As Long, _
 ByRef sens As T_SENS, _
 ByVal lpReturnedString As String _
) As Integer
*/

short EXPORT KRTAPI krotExtCorozInfo (
 KRTHANDLE Handle, 
 long crzIndex, 
 T_SENSGROUP *inf
);
/*
Public Declare Function krotExtCorozInfo Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndex As Long, _
 ByRef c_info As T_SENSGROUP _
) As Integer
*/

short EXPORT KRTAPI krotGetFirstNode (
 KRTHANDLE handle,      // ���������� �������
 T_NODE *node,          // ��������� �� ��������� T_NODE
 long start,            // ������� �� ������
 long sensType,         // ��� �������
 long sensIndex,        // ������ ������� (-1L - �������)
 long length,           // ����� ������� ��� ��������� ������� krotGetNextNode
 long controlSize       // ������ �������� �������� � ��������.
);
/*
Public Declare Function krotGetFirstNode Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATA, _
 ByVal pos As Long, _
 ByVal sensType As Long, _
 ByVal sensIndx As Long, _
 ByVal seqLength As Long, _
 ByVal controlPixelsNum As Long _
) As Integer
*/

short EXPORT KRTAPI krotGetNextNode (
 KRTHANDLE handle,      // ���������� �������
 T_NODE *node           // ��������� �� ��������� T_NODE
);
/*
Public Declare Function krotGetNextNode Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATA _
) As Integer
*/

short EXPORT KRTAPI krotGetFirstNodeGroup (
 KRTHANDLE handle,      // ���������� �������
 T_NODEGROUP *node,     // ��������� �� ��������� T_NODEGROUP
 long start,            // ������� �� ������
 long sensGroup,        // ����� ������ ��������
 long length,           // ����� ������� ��� ����������� ������� GetNextNodeGroup
 long controlSize       // ������ �������� � ��������.
);
/*
Public Declare Function krotGetFirstNodeGroup Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATAGROUP, _
 ByVal pos As Long, _
 ByVal sensGroup As Long, _
 ByVal seqLength As Long, _
 ByVal controlPixelsNum As Long _
) As Integer
*/

short EXPORT KRTAPI krotGetNextNodeGroup (
 KRTHANDLE handle,      // ���������� �������
 T_NODEGROUP *node      // ��������� �� ��������� T_NODE
);
/*
Public Declare Function krotGetNextNodeGroup Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef t_node As T_NODEDATAGROUP _
) As Integer
*/

short EXPORT KRTAPI krotGetSingleSens (
 KRTHANDLE Handle,     // ���������� �������
 long      crzIndx, 
 long      sens,       // ����� �������
 KRTDATA  *bufDat,     // ��������� �� �����
 KRTROW   *bufRow      // ��������� �� ����� ����� ������
);
/*
Public Declare Function krotGetSingleSens Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal sens As Long, _
 ByRef buf As Byte, _
 ByRef bufRow As Long _
) As Integer
*/

short EXPORT KRTAPI krotPaintZoom (
 KRTHANDLE Handle, 
 long crzIndx, 
 HWND hwnd,
 long xStart,
 short xDataSize,
 short yStart,
 short yDataSize, 
 short *dataBuff, 
 KRTROW  *rowBuff, 
 long drawType
);
/*
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
*/

short EXPORT KRTAPI krotGetVectSens (
 KRTHANDLE Handle,      // ���������� �������
 long crzIndx, 
 long      pos,         // ������� � ��.
 KRTDATA  *buf,         // ��������� �� ����� ������������ ������
 KRTROW   *row          // ��������� �� ����� ����� ������
);
/*
Public Declare Function krotGetVectSens Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal pos As Long, _
 ByRef buf As Byte, _
 ByRef bufRow As Long _
) As Integer
*/

short EXPORT KRTAPI krotSetClipboard (
  HWND      src          // hwnd ��������� ������
);
/*
Public Declare Function krotSetClipboard Lib "krotw32.dll" ( _
  ByVal hwnd As Long _
) As Integer
*/

short EXPORT KRTAPI krotRegisterTrace (
  LPSTR driverFileName, 
  LPSTR primFile, 
  LPSTR indxFolder,           
  LPSTR trcFile, 
  long (KRTAPI *informUser) (short percentDone, const char *msg)
);
/*
Public Declare Function krotRegisterTrace Lib "krotw32.dll" ( _
  ByVal driverFileName As String, _
  ByVal primFile As String, _
  ByVal indxFolder As String, _
  ByVal trcFile As String, _
  ByVal informUser As Long _
) As Integer
*/

short EXPORT KRTAPI krotCheckDriver (
 LPSTR driverFileName, 
 LPSTR outDrvSign,     // ��������� ��������
 LPSTR outDrvName,     // �������� ��������
 LPSTR outDrvCopyRt,   // ������ ���������
 LPSTR outFullDllPath, // ������ ���� �� ����������� dll ��������
 VB_DRV_INFO *drvInfo
);
/*
Public Declare Function krotCheckDriver Lib "krotw32.dll" ( _
 ByVal driverFileName As String, _
 ByVal outDrvSign As String, _
 ByVal outDrvName As String, _
 ByVal outDrvCopyRt As String, _
 ByRef d_info As VB_DRV_INFO _
) As Integer
*/

short EXPORT KRTAPI krotLockNodeSequence (
 KRTHANDLE Handle, 
 long lockActive
);
/*
Public Declare Function krotLockNodeSequence Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal lockActive As Long _
) As Integer
*/

short EXPORT KRTAPI krotEvent (
 KRTHANDLE Handle,
 T_EVENT *event
);
/*
Public Declare Function krotEvent Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByRef evnt As T_EVENT _
) As Integer
*/

short EXPORT KRTAPI krotCorozDump (
 KRTHANDLE Handle, 
 long crzIndx, 
 LPSTR outFileName, 
 long isRow
);
/*
Public Declare Function krotCorozDump Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal FileName As String, _
 ByVal isRow As Integer _
) As Integer
*/

short EXPORT KRTAPI krotZoomDump (
 KRTHANDLE Handle, 
 long crzIndx, 
 LPSTR outFileName, 
 long isRow
);
/*
Public Declare Function krotZoomDump Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal FileName As String, _
 ByVal isRow As Long _
) As Integer
*/

// ��������� �������� ���������� ������ ���
typedef struct {
 long scanStart;      // ��������� ����������� ���
 long lenMin;         // ����������� ����� �����
 long lenMax;         // ������������ ����� �����

 long maskSize;       // ������ ����� � ���������� ��������
 long listSize;       // ������ ���������� ����� � ���������� ��������
 long signalLevel;    // ������� �������
 short slitNum;       // ��������� ���������� ���������� ����

 short weldSensitiv;  // ������� ���������������� ���������� ���� (�� 1 �� 100)
 short slitSensitiv;  // ������� ���������������� ���������� ���� (�� 1 �� 100) 
                      // ���� 0, �� ���������� ��� ���������� �� ����.
 short spirSensitiv;  // �� �� ��� ���������� ����

 short noDRC;         // �� ����� ���� �����������
 short noSPR;         // �� ����� ���� �������������
 short noWTO;         // �� ����� ���� ���������

 // ��������� ��� ��������� 2013

 short Weld1_width;   // 1 - 30
 float Weld1_sens;    // 1 - 10
 float Weld1_bord;    // 1 - 100
 short Weld1_otst;    // 10 - 30

 short Weld2_width;   // 1 - 30
 float Weld2_sens;    // 1 - 10
 float Weld2_bord;    // 1 - 100
 short Weld2_second;  // 1 - 15

 short Spiral_width;  // 1 - 30
 float Spiral_sens;   // 1 - 10
 float Spiral_bord;   // 1 - 100
 short Spiral_area;   // 30 - .lenMin

} VB_TUBE_SCAN_IN;
/*
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
*/

// ��������� �������� ���������� ���������� ���
typedef struct {
 long wldDst;         // ��������� ���������� ���
 short wldTyp;        // ��� ����� (0-�����������, 1-�������, 2-��������)
 short wld1;          // ����� ������� 1 ����������� ��� (-1 ���� ���)
 short wld2;          // ����� ������� 2 ����������� ��� (-1 ���� ���)
 short crzIndex;      // ����� ����� �� �������� ���������� ���������� ���
} VB_TUBE_SCAN_OUT;
/*
Public Type VB_TUBE_SCAN_OUT
 wldDst As Long       '��������� ���������� ���
 wldTyp As Integer    '��� ����� (0-�����������, 1-�������, 2-��������)
 wld1 As Integer      '����� ������� 1 ����������� ��� (-1 ���� ���)
 wld2 As Integer      '����� ������� 2 ����������� ��� (-1 ���� ���)
 crzIndx As Integer   '����, �� �������� ���������� ���������� ���
End Type
*/

short EXPORT KRTAPI krotScanWeld (
 KRTHANDLE Handle, 
 long crzIndx, 
 VB_TUBE_SCAN_IN *inpData, 
 VB_TUBE_SCAN_OUT *outData, 
 long is2013
);
/*
Public Declare Function krotScanWeld Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef prmIn As VB_TUBE_SCAN_IN, _
 ByRef prmOut As VB_TUBE_SCAN_OUT, _
 ByVal is2013 As Integer _
) As Integer
*/

short EXPORT KRTAPI krotDai (
 KRTHANDLE Handle, 
 long crzIndx, 
 T_USERDAI *udai, 
 VB_DAI_INFO *daiInfo, 
 LPSTR outString, 
 long (KRTAPI *informUser) (short percentDone)
);

/*
Public Const DAI_EXPLAIN_TEXT_MAX_LENGTH = 4096
Public Const DAI_QUEST_ERROR = -1

Public Type DAI_INFO
 internal As Long      ' 0 - �������� ������ ��� 1 - ����������
 wallThickness As Long ' ������� ������ ����� � ��
 x1 As Long            ' ����� ������� ������ �������� ���� �������
 y1 As Long            ' ����� ������ ������ �������� ���� �������
 x2 As Long            ' ����� ������� ������� ������� ���� �������
 y2 As Long            ' ����� ������ ������� ������� ���� �������
End Type

Public Declare Function krotDai Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef udai As DAI_INFO, _
 ByRef daiInfo As VB_DAI_INFO, _
 ByVal lpReturnedString As String, _
 ByVal informUser As Long _
) As Integer
*/


/* 
������� ������������� ��� ������� ����������, ������� ���������� �������� ������ 
� ���������� ����������� �������� ������. 

������� ������ ���������:

���������� ������������ ����� vbapi.h � krtapi.h, � ������� ���������� �����������
��������� � ��������� ������.
��������� krotw32.dll ��� ������� ���������� �� ���� ����������.
�������� �� ������������ ��� trc ����� fileName, �� �������� ����� ������������� ������.
������������ � ����� ��������� ���������� ���������� ������ Handle. 
��� ����� ����, ��������, ����� 1.
�������� �� ini-����� fileName (������ [Trace], ���� Index) 
��� �������� indxFolder � ���������� ������� ������.

�������� ��� ��������� ������ (outDrvSign, outDrvName, outDrvCopyRt) ������ KRT_TEXT (krtapi.h)
������� ��������� ��������� VB_TRACE_INFO (vbapi.h)
������� ������� 

short EXPORT KRTAPI krotOpenTrace (
 KRTHANDLE Handle, 
 LPSTR fileName, 
 LPSTR indxFolder, 
 LPSTR driverFileName, 
 LPSTR outDrvSign,     // ��������� ��������
 LPSTR outDrvName,     // �������� ��������
 LPSTR outDrvCopyRt,   // ������ ���������
 VB_TRACE_INFO *inf);

� ������ ��������� ������ ��� ������ �������� KRT_OK. (krtapi.h) 
���� ������ KRT_ERR (krtapi.h), �� ������ ������� �� �������. 

�������� ������ ����� �������� � ������ outString ������ KRT_TEXT (krtapi.h) ������ ������� 

long EXPORT KRTAPI krotError (LPSTR outString);

����� ��������� ������ krotOpenTrace ���� inf->crzZoneNum �������� ���������� ������ ��������
����������� ���������. ������ ���� (������ 0) �������� �������� ������, ��������� ����������������.
���������� ������� ����� ����� crzIndex (�� 0 �� inf->crzZoneNum - 1), 
��� �������� ����� ������������� ������.
������� ��������� ��������� T_SENSGROUP (krtapi.h) � ������� ������� 

short EXPORT KRTAPI krotExtCorozInfo (
 KRTHANDLE Handle, 
 long crzIndx, 
 T_SENSGROUP *cinf
);

� ������ ��������� ������ ��� ������ �������� KRT_OK. (krtapi.h) ��������� ������ ��. ����
����� ��������� ������ krotExtCorozInfo ���� cinf->crz.num �������� ���������� �������� � �����, 
� ���� cinf->crz.step �������� ������ ���� ������ �� X � ��.

��������� ������ ������, ������������ ��� ������ ������ � ��������� ��������� ������ xLength ��.
cinf->crz.num * (xLength / cinf->crz.step) * sizeof(long)
�������� ����� datBuff ������ ������� � ������� ������� 

short EXPORT KRTAPI krotCorozData (
 KRTHANDLE Handle, 
 long crzIndx, 
 long xStart,     // ������ ���������, ��
 long xLength,    // ����� ���������, ��
 KRTDATA *datBuff,
 KRTROW *rowBuff
);

� ������ ��������� ������ ��� ������ �������� KRT_OK. (krtapi.h) ��������� ������ ��. ����
����� ��������� ������ krotCorozData � datBuff ���������� ������ 32-������ ��������� ��������.

��� ���������� ������ ���������� ������� ������� �������� ������ 

short EXPORT KRTAPI krotCloseTrace (KRTHANDLE Handle);

*/
short EXPORT KRTAPI krotCorozData (
 KRTHANDLE Handle, 
 long crzIndx, 
 long xStart,     // ��
 long xLength,    // ��
 KRTDATA *datBuff,
 KRTROW *rowBuff
);

/*********************************************************
 ������� ��������� �������� � ��������
**********************************************************/

// ������������ ������� ���� �����
#define RGB_RED      0  // ������� 
#define RGB_GREEN    1  // �������
#define RGB_BLUE     2  // �����

/*
 ������� ���������� ���� �� ���� ������������ ����� colorCode.
 ����� ������������ ������� ������ �������� rgbItem, ������� �����
 ��������� ���� �� ���� �������� RGB_* (��. ����)
*/
short EXPORT KRTAPI rgbColor (long colorCode, short rgbItem);
/*
'������������ RGB ����� (��������� �������� rgbItem)
Public Const RGB_RED = 0
Public Const RGB_GREEN = 1
Public Const RGB_BLUE = 2

Public Declare Function rgbColor Lib "krotw32.dll" ( _
 ByVal colorCode As Long, _
 ByVal rgbItem As Integer _
) As Integer
*/

/*
 ��������� �������� �������
*/
typedef struct {
 long iPos;                  // ��������� �� ������� ���������
 long iVal;                     // �������� ������� ���� �����
} VB_PAL_ITEM;

/*
 ��������� ������� ������������
*/
typedef struct {
 long         itemNum;          // ���-�� ��������� � ������� item[]
 VB_PAL_ITEM  minItem;          // ������ ������� �������
 VB_PAL_ITEM  maxItem;          // ��������� ������� �������
} VB_PAL;

// ������� �������������� ������� ��� ��������� ������.
short EXPORT KRTAPI krtPalInit (void);
// ������� ����������� ������� �� ������� ��� ��������� ������.
void EXPORT KRTAPI krtPalClose (void);

/*
 ������� ������������� ������ ������� ��� ��������� crzIndx ������� Handle.
 ���� Handle == -1, �� ������ ��������������� ��� ��������� ������.
 �������� item ��� ��������� �� ������ ��������� ������� ����� ������ � ���������.
 ������ ���� ������������� �� item->iPos �� �����������.
 ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
*/
short EXPORT KRTAPI krtPalSet (
 KRTHANDLE Handle, 
 long crzIndx, 
 long brdMin,
 long brdMax,
 long usrMin,
 long usrMax,
 VB_PAL *pal, 
 VB_PAL_ITEM *item
);

/*
 ������� ������ ������� ��������� crzIndx ������� Handle � ���� hwnd. 
 ���� Handle == -1, �� �������� ������� ��������� ������.
 ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
*/
short EXPORT KRTAPI krtPalDraw (
 KRTHANDLE Handle, 
 long crzIndx, 
 HWND    hwnd
);

/*
'��������� �������� �������
Public Type VB_PAL_ITEM
 iPos As Long                   ' ��������� �� ������� ���������
 iVal As Long                   ' �������� ������� ���� �����   
End Type

'��������� ������� ������������
Public Type VB_PAL
 itemNum As Long                ' ���-�� ��������� � ������� �� ������ item
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
 ByRef pal As VB_PAL, _
 ByRef palItem As Long _
) As Integer

' ������� ������ ������� ��� ��������� crzIndx ������� Handle � ���� hwnd. 
' ���� Handle == -1, �� �������� ������� ��������� ������.
' ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
Public Declare Function krtPalDraw Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByVal hwnd As Long _
) As Integer

*/

/*
' ������� ������ ��� ������������ ����� ��� ��������� �������� �����������
' i = 0 - ���������� ������������ ��������
' i = 1 - ���������� ����������� ��������
' i = 2 - ���������� ������� ��������
' i = 3 - ���������� ������ ���������� ��������
Public Declare Sub SetScaleMode Lib "krotw32.dll" (ByVal i As Integer)

*/
void EXPORT KRTAPI SetScaleMode (short i);

/*
������� ���������� ��� ������������� ���������������
*/
short EXPORT KRTAPI GetScaleMode ();

#endif
