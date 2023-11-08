unit KrotApi;

interface
Const
  KRT_APIVER = 1;         // ������� ������ API
  KRT_PALETTE_SIZE = 200;  // ������ �������
// ������ ������ �������� � ����� �������� �������
  DRIVER_DATA = 'DriverData';
// ������ ������ ��� �������� ���������������� �������
  EXT_SENS_NAME_LENGTH = 256;

// ���� �������� ��� ������� ��������
  KRT_ERR      =         1;
  KRT_OK       =         0;

// ���� �������������� ��������
 KRT_SENS_TIMER  =     1;    // ������
 KRT_SENS_ODO    =     2;    // �������
 KRT_SENS_ORIENT =     4;    // ����������
 KRT_SENS_SHAKE  =     8;    // ���������
 KRT_SENS_PRESS  =    16;    // ��������
 KRT_SENS_TEMP   =    32;    // �����������
 KRT_SENS_ANGLE  =    64;    // ������� ���������
 KRT_SENS_VOG    =    128;   // 3 ���� + 3 �������������
 KRT_SENS_EXT =134217728 ;   // ���������������

// ���� �������� ���������
 SENS_TYPE_HOLL   =    1 ;   // ����
 SENS_TYPE_FERR   =    2 ;   // ���������
 SENS_TYPE_INDK   =    3 ;   // ������������

// ������ ������ ��������
 SENS_ASK_TIME    =    1 ;   // �� �������
 SENS_ASK_DIST    =    2 ;   // �� ��������
// ������������ ������
 DIST_DISCRETE = 10;
 TIME_DISCRETE = 10;

{$Align off}
Type
  TKrtTraceHandle = Integer;  // ��� ������ ����������� �������
  TKrtData = Byte;       // ��� ������ ������� ������� ��������� ����� ���������

// ��������� � ������� ������� ���������� ��������� ������ �������
// ����� ������� krtDrvGetFirstNode
  PNode = ^TNode;
  TNode = Record
     Val: Integer;      // �������� �������
     Pos: Integer;      // ��������� �� ������ �������� ����������� ����
  End;

// ��������� � ������� ������� ���������� ��������� ��������� ������
// �������������� �������� ����� ������� krtDrvGetFirstNodeGroup
  PNodeGroup = ^TNodeGroup;
  TNodeGroup = Record

    TimerVal: Integer;      // �������� �������
    TimerPos: Integer;      // ��������� �� ������ ��������� �������

    OdoVal: Integer;        // �������� ��������
    OdoPos: Integer;        // ��������� �� ������ ��������� ��������

    OrientVal: Integer;     // �������� ������� ����������
    OrientPos: Integer;     // ��������� �� ������ ��������� ������� ����������

    ShakeVal: Integer;      // �������� ������� ���������
    ShakePos: Integer;      // ��������� �� ������ ��������� ������� ���������

    PressVal: Integer;      // �������� ������� ��������
    PressPos: Integer;      // ��������� �� ������ ��������� ������� ��������

    TempVal: Integer;       // �������� ������� �����������
    TempPos: Integer;       // ��������� �� ������ ��������� ������� �����������    

    AngleVal: Integer;      // �������� ������� ������� ���������
    AnglePos: Integer;      // ��������� �� ������ ��������� ������� ������� ���������

    VOGX: Integer;         // ���������� X,Y,Z
    VOGY: Integer;
    VOGZ: Integer;
    AccelX: Single;         // ���������� ������� ���������� ��������
    AccelY: Single;
    AccelZ: Single;

    VogPos: Integer;
  End;


// ��������� �������� ����� �������� ���������
  TSensGroup = Record
    Sensnum : Integer; // ���-�� �������� � �����
    Senstype: Integer; // ��� �������� (SENS_TYPE_*)
    MinValue: Integer; // ����������� �������� ��������� ������� (������� ���)
    MaxValue: Integer; // ������������ �������� ��������� ������� (������� ���)
{    AskMetod: Integer; // ����� ������ �������� (SENS_ASK_*)
    StepSize: Integer; // ������������ ������ �������� (��/������� - �� ������ ������)}
  End;
// ��������� �������� ���������������� �������
 TExtSens = Record
   MinValue: Integer; // ����������� �������� ��������� ������� (������� ���)
   MaxValue: Integer; // ������������ �������� ��������� ������� (������� ���)
{   AskMetod: Integer; // ����� ������ ������� (SENS_ASK_*)
   StepSize: Integer; // ������������ ������ ������� (��/������� - �� ������ ������)}
   Name: Array [0..EXT_SENS_NAME_LENGTH] of char; // �������� �������
  End;

// ��������� �������� ��������
  PDrvInfo = ^TDrvInfo;
  TDrvInfo = Record

    ApiVer: Integer;        // ������ API
    SensGroups: Integer;    // ���-�� ������ �������� ���������
    ExtSensors: Integer;    // ���-�� ��������������� ��������

    AskMetod: Integer; // ����� ������ �������� ( SENS_ASK_* )
    StepSize: Integer; // ������������ ������ �������� (��/������� - �� ������ ������)}

    Group: Pointer;     // ��������� �� ������ �������� �������� ������
                            // �������� ���������
                            // ������ ������� ����� ����� sensGroups

    ExtSens: Pointer;     // ��������� �� ������ �������� ��������
                            // ��������������� ��������
                            // ������ ������� ����� ����� extSensors


                            // VOG �������
    VOG: Integer;           // 1 ��� 0
 // ������� (����������� �������)
    TimerNum : Integer;      // ����������
    TimerStep: Integer ;     // ������������ ��������� (��������)

 // �������� (��������� ���������)
    OdoNum : Integer;        // ����������
    OdoStep: Integer;        // ������������ ��������� (��)

 // ������� ���������� (���� ������� ����.������� ��� �� 0 �� 360)
    OrientNum : Integer;     // ����������
    OrientStep: Integer;    // ������������ ��������� (��/������� - �� ������ ������)

 // ������� ��������� (������� ���)
    ShakeNum:  Integer;      // ����������
    ShakeMin:  Integer;      // ����������� �������� ��������� ������� (������� ���)

 // ������� �������� (���???)
    PressNum : Integer;     // ����������
    PressStep: Integer;     // ������������ ��������� (��/������� - �� ������ ������)

 // ������� ����������� (������� �������???)
    TempNum : Integer;      // ����������
    TempStep: Integer;      // ������������ ��������� (��/������� - �� ������ ������)

 // ������� ������� ��������� (������� ���)
    AngleNum : Integer;      // ����������
    AngleMin : Integer;      // ����������� �������� ��������� ������� (������� ���)

//////////////////////////////////////////////////////////////////////////
//Callback - �������
//////////////////////////////////////////////////////////////////////////
  krtDrvRegister: Pointer;
 (*int (KRTAPI *krtDrvRegister) (
 // ������� ����������� �������
 // ���� NULL, �� ��� ����������� ������� ������� ���� ������ ������
 // �������������� ������� �������.
 // ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
 // ��� ������� ������� ���������� ���� ��� ��� ��� �����������
 // (�������� inf-�����). ������� ����� ������������ ��� �������
 // ��� ���������������� ������� �����-���� ������ � ��������
 // ������������ ����� ��������� ������. � ini-����, ����������
 // ���������� infFile, � ������ DRIVER_DATA ������� ������ ��������
 // ���������� ����������� ��� ��� �������� �������.

  LPSTR infFile  // ����-������������ ������, ����������� ������ ���� � �����
                 // ����������� ������� (inf-����)
 );*)

  krtDrvError: Pointer;
(* const char *(KRTAPI *krtDrvError) (void);
 // ������� �������� ������ ����������� ��� ������ � ��������
 // ���� Null, ����������� �������� ������ ��������� �� ��������������.
 // ���������� ��������� �� ����-������������ ������, ����������� �������
 // ��������� ��������� �������� ��������.
 // �.�. ����������� �������������� ������� �������� ����������
 // ������ ��������� ������/�������, ��� �������� �����-����
 // �������� �������� �������� KRT_ERR, ������ ������� ���������
 // ��������� ��������� � �������� ��������� �������� ��������� ������.*)

  krtDrvGetFirstNode: Pointer;
 (*
 int (KRTAPI *krtDrvGetFirstNode) (
 // ������� ������ ��������� �������������� �������� ����������.
 // ���� ������ ���� ��������������� � NULL, �� ���� krtDrvGetNextNode
 // ����� ������ ���� ����������� � NULL � ��������� ���������� �
 // �������������� �������� �� ��������������.
 // ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
 // ������� ������ ��������� ������������ �������, ����������� ����� ��� ��
 // �������, �������� ���������� start � ��������� ����� �����������
 // ��������� T_NODE
 // ���� ������������� ������ ������� ��� �������������� ��� ������ �������
 // krtDriverInfo, �� ������� ������ ������� KRT_ERR.

  KRTHANDLE handle,      // ���������� �������

  T_NODE *node,          // ��������� �� ��������� T_NODE, ������� ���������� 
                         // ��������� ����������� � ���������� �������

  long start,            // ������� �� ������, �� ������� ������������� 
                         // ��������� �������. ������� ������ ������� ���������
                         // ������� ����� �� ������������� ������� ��� ����� ���.
                         // ���� � ������ �� ������������� ������� ��� ���������
                         // ��������� T_NODE ������ ���� ��������� ������.

  long sensType,         // ���������, ��������� ������ �� �������� �������������
                         // ������ �������� ����� ��������� �������� ����� ��
                         // �������� KRT_SENS_*

  long sensIndex,        // �������� �������� ����������� ���������. ������
                         // �������������� ������ ����� ���� ��������� ���
                         // ����������. ���� ������ �������� ����� �������� -1L,
                         // �� ������� ������ ������� ��������� �������� �������.
                         // ������ ��� ������ ���� ������� ��������� ���������
                         // ����� ��������� ��������� ����������� ��������, ����
                         // � ���� ��������� �������� ��������������� �����. �
                         // ���� ������ �������� ���������������� ��� ������
                         // ������� � ��������������� ������� �������� � �������
                         // ������ ������� ��������� ������ ����� �������.
                         // ���� �������� ��������� sensType ����� KRT_SENS_EXT
                         // �� ������ �������� �������� �������� � ������� 
                         // ��������������� ��������.
                         // ��� �������� �������, ������������������ �� ������
                         // ������� �� ������� �������� ������� ������ �������
                         // KRT_ERR.
                         // ��������, ��� ������ ������� krtDriverInfo ���� 
                         // �������� ��������� ���������� � ������������ ��������:
                         //    �������� ����������        - 3
                         //    ��������������� ��������   - 2
                         // ��� ������ ������� krtDrvGetFirstNode �� ����������
                         // ����������� ������� ������ ��������� ��������� 
                         // ��������:
                         //
                         //   sensType = KRT_SENS_ORIENT
                         //   sensIndex = -1L
                         // ��������� ��������� T_NODE �������� ����������� 
                         // ������� ���������� �� ����������� �������
                         //
                         //   sensType = KRT_SENS_ORIENT
                         //   sensIndex = 2
                         // ��������� ��������� T_NODE ����������� 
                         // �������� ������� ���������� (������ ������
                         // ����� ������ 0) �� ����������� �������
                         //
                         //   sensType = KRT_SENS_ORIENT
                         //   sensIndex = 4
                         // ������� KRT_ERR
                         // (������ ������� ���������� �� ����������)
                         //
                         //   sensType = KRT_SENS_EXT
                         //   sensIndex = 1
                         // ��������� ��������� T_NODE ����������� 
                         // ������� ���������������� �������
                         //
                         //   sensType = KRT_SENS_EXT
                         //   sensIndex = -1L
                         // ������� KRT_ERR 
                         // (�������� ������ � ������� ��������������� ��������)

  long length,           // ����� ������� ������� ����� ������������� ������������
                         // �������� GetNextNode*
                         // ���� �������� ���������� ��� �������, ����� �������
                         // ��� �������������� ���-�� ��������, ����������� ��
                         // ������� �������� ����������� � ��������, ��� ���
                         // ������ ����� ������������.

  long controlSize       // ������ ��������, ��� ����� �������������� ������
                         // � ��������.
                         // ����������� �� ���� ��������, ������� ����� ����������
                         // ��������� ���� �� ������� ��������� �������, �.�.
                         // ��� ��� ����� �� ����� ���������� � ������ ��������.
                         // ���� ����������� ���������� ���-�� ������� GetNextNode*

 );*)


  krtDrvGetNextNode: Pointer;
 (*
 int (KRTAPI *krtDrvGetNextNode) (
 // ������� ������ ��������� �������������� �������� ����������.
 // ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
 // ������ ������� ������������ � ���� � �������� krtDrvGetFirstNode
 // ��� ��������� ��������� T_NODE ����������� ������� ���������� � ������
 // ������� krtDrvGetFirstNode. ����������� ��������� ������� ������ ���������
 // � ������ ������� ������ �� ����������� ����� �������, ������� ����
 // ���������� �������� krtDrvGetFirstNode ��� ����������� �������� �������
 // krtDrvGetNextNode.
 // ����������� ������� ��������� �������, ����������� �������� �������
 // krtDrvGetNextNode ������ ���� ���������� ��������� � �������� �������
 // ����������� ������������ �������. ��� ������ ������������ ������� �������
 // ������� krtDrvGetNextNode ������ ���� ����������.
 // ��� ���������� �������� ������� krtDrvGetNextNode ����� ������ �������
 // ������ ���������� � ���� Val ��������� T_NODE �������� 0, � � ���� Pos
 // �������� ��������� ������.

  KRTHANDLE handle,      // ���������� �������

  T_NODE *node           // ��������� �� ��������� T_NODE, ������� ����������
                         // ��������� ����������� � ���������� �������
 );*)
  krtDrvGetFirstNodeGroup: Pointer;
(* int (KRTAPI *krtDrvGetFirstNodeGroup) (
 // ������� ���������� ������ ��������� �������������� ��������.
 // ���� ������ ���� ��������������� � NULL, �� ���� krtDrvGetNextNodeGroup
 // ����� ������ ���� ����������� � NULL � ���������� � ��������������
 // �������� �� �������������� ���������.
 // ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
 // ������� ������ ��������� ��������, �������� � ����������� ������,
 // ����������� ����� ��� �� �������, �������� ���������� start � ���������
 // ����� ����������� ��������� T_NODEGROUP
 // ����������� ������ ������� ��������� ������������� �������������
 // ������� krtDrvGetFirstNode, � ������� ������� ����� ������� ����� ������
 // ���������� � ���������� �������������� ��������. ������� krtDrvGetFirstNodeGroup
 // ������������ ��� ���������� ��������� �������� �� ������������� ������
 // ������� krtDrvGetFirstNode ��� �������������� ���������� �������.

  KRTHANDLE handle,      // ���������� �������

  T_NODEGROUP *node,     // ��������� �� ��������� T_NODEGROUP, �������
                         // ���������� ��������� ����������� � ����������
                         // ��������, �������� � ����������� ������.

  long start,            // ������� �� ������, �� ������� �������������
                         // ��������� ��������. ������� ������ ������� ���������
                         // ������� ����� �� ������������� ������� ��� ����� ���.
                         // ���� � ������ �� ������������� ������� ��� ���������
                         // ���� ������� �� �������� ��������� �� ������ �������
                         // � ��������� T_NODEGROUP ������ ���� ��������� ������.

  long sensGroup         // ������ ������ ��������, �������� ����������� �������
                         // ���������� ��������� ��������������� ���� ���������
                         // T_NODEGROUP.
                         // ������ �������� ������� ������, ���������� �������
                         // ��������� OR (���) �������� KRT_SENS_*
                         // ��������, �������� sensGroup ����� ��������
                         // (KRT_SENS_ORIENT || KRT_SENS_SHAKE).
                         // ������� ������ ��������� ����
                         // orientVal, orientPos, shakeVal, shakePos ���������
                         // T_NODEGROUP � �������� ������ ���� ��� ���������.
 );*)
   krtDrvGetNextNodeGroup: Pointer;
(* int (KRTAPI *krtDrvGetNextNodeGroup) (
 // ������� ���������� ������ ��������� �������������� ��������.
 // ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
 // ������ ������� ������������ � ���� � �������� krtDrvGetFirstNodeGroup
 // ��� ��������� ��������� T_NODEGROUP ����������� ��������, �������� �
 // ������, ��������� � ������ ������� krtDrvGetFirstNode.
 // ����������� ��������� �������� ������ ��������� � ������ ������� ������
 // ���� �� ������ ��� ������� �������, ��������� � ������.
 // ���� � ���������� ������� ������� ������� krtDrvGetFirstNodeGroup /
 // krtDrvGetNextNodeGroup ��� ������ �� �������� ��������� ����� ������
 // � ��������������� ���� �������� ����� ������� � ��������� T_NODEGROUP
 // ������  ������������ 0, � � ���� ��������� ����� ������� �� ������
 // �������� ��������� ������.
 // ����������� ������� ��������� ��������, ����������� �������� �������
 // krtDrvGetNextNodeGroup ������ ���� ���������� ��������� � �������� �������
 // ����������� ������������ �������. ��� ������ ������������ ������� �������
 // ������� krtDrvGetNextNodeGroup ������ ���� ����������.

  KRTHANDLE handle,      // ���������� �������

  T_NODEGROUP *node      // ��������� �� ��������� T_NODE, ������� ����������
                         // ��������� ����������� � ���������� �������
 );*)
  krtDrvFillData: Pointer;
(* int (KRTAPI *krtDrvFillData) (
 // ������� ������ ��������� �������� ���������.
 // ���� NULL, ���������� � ��������� �� ��������������.
 // ���������� KRT_OK ��� ������, KRT_ERR ��� ������.

  KRTHANDLE handle,      // ���������� �������

  int group,             // ������ ����� �������� ���������, �� �������� ����
                         // ������� ������.

  long start,            // ��������� ������� ������������ ��������� ���������
                         // �� ������. (��/������� - �� ������ ������)

  long length,           // ����� ������������ ������� ���������
                         // (��/������� - �� ������ ������)

  KRTDATA *screen        // ��������� �� ������, ������� ���������� ���������
                         // ����������� � �������� ���������.
                         // ������� ������� ����� ���� BYTE, ������� �����
                         // ��������� �������� �� 0 �� KRT_PALLETE_SIZE - 1
                         // ������� ������ ������������� ��������� ��������
                         // ������� � ��������� �������� �������� �����
                         // ���������� ������ � ���������� ��������
                         // ������������� ���������� ���� � � ����, ���
                         // �������� ��������� ������ �������� �������������
                         // ��������� ���������� ����, ���������� ��������.
                         // ���������� ��� ��������, ��� ��� ������ ������
                         // ��������� � ��������� ��������� �� ������ ���������
                         // ��������, ��������� � ���� ������ ������ ����������
                         // ���������� ���������. ��� ����� ��������� ������
                         // �� ������ ����������� ������ �������� ����������.
                         // ���������� ����� ������� ����� ��������
                         // ���� num ��������� T_SENSGROUP, �����������
                         // ��������������� ���� �������� ���������
                         // ���������� �������� ������� ����� ����� �������
                         // ��������� (�������� length) ��������� �� ��������
                         // ���� stepSize ��������� T_SENSGROUP
                         // ������ ��������� ������ ����������� ��������� �
                         // ������ ����������� �������� ������� �� ������ �������
 );*)

 End;

// ��������� �������� �������, ��������� ��� ������.
  PTraceInfo = ^TTraceInfo;
  TTraceInfo = Record
    Length  : Integer;          // ����� ������ � ��
    Time    : Integer;          // ����������������� ������� � ��������

    SpeedMin: Integer;          // �����������  �������� ������� �� ������ � ��/���
    SpeedMax: Integer;          // ������������ �������� ������� �� ������ � ��/���

    ShakeMin: Integer;          // �����������  �������� ������� ���������
    ShakeMax: Integer;          // ������������ �������� ������� ���������

    PressMin: Integer;          // �����������  �������� ������� ��������
    PressMax: Integer;          // ������������ �������� ������� ��������

    TempMin : Integer;          // �����������  �������� ������� �����������
    TempMax : Integer;          // ������������ �������� ������� �����������

    AngleMin: Integer;          // �����������  �������� ������� ������� ���������
    AngleMax: Integer;          // ������������ �������� ������� ������� ���������
  End;

{$Align on}
implementation
end.