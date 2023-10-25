Attribute VB_Name = "VogMath"
'���� �������� ���������� ����� ���������� ��������� �� Visual Basic �
'vogmath.dll �� C.
'(C) Vitaly Bogomolov 2001.

Public Const TURN_GOR = 0  '������� � ������������ ��������
Public Const TURN_VER = 1  '������� � ���������� (������������) ��������
Public Const TURN_3D = 8  '����������� 3D �������
Public Const TURN_START = 2 '�������� �� ����� ������� � ������ ��������
Public Const TURN_END = 4  '�������� �� ����� ������� � ����� ��������

Public Const MATCH_MODE_SHIFT = 1    '�������������� ������
Public Const MATCH_MODE_SCALE = 2    '�������������� ����������/������
Public Const MATCH_MODE_ROTATE = 4   '�������������� ��������

Public Enum VOG_GRAPH
GRAPH_AZIMUTH = 1
GRAPH_TANGAZH = 2
End Enum

Public Type T_TURNDATA
 radius As Long    '������ �������� � ��.
 angle As Single   '���� �������� � ��������
End Type

Public Type T_VOGDRIVERDATA
 IsProfil As Long        ' ������� ����������� �������
 ProfilPigLength As Long ' ���������� ����� ���������
 OdoAngle As Long        ' ���� ����� ���������� ������ �������� � ������ ������
End Type

Public Const VOG_SHIFT01 = 100  '����� ��� ����� ������� ������� �� ���, ��
'Public Const VOG_SHIFT02 = 500  '����� ��� ����� ������ ������� �� ���, ��

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  �������������� �������
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'������� ��������� ��������� T_CURVEDATA
'������� � ���������� ��������,
'���������� KRT_OK ��� ������, KRT_ERR ��� ������.
'���������:
'calc_type   ��� �������
'            0 - "������������" �������, 1 - "����������"
'handle      ����� ��������� �������
'turnkind    ������� �����
'            ��� 0
'            ������ - ������� � ��������� ���������
'            ���������� - ������� � ������������ ���������
'            ��� 1
'            ���������� - ���������� �������� �� ����� ������� � ������ ��������
'            ��� 2
'            ���������� - ���������� �������� �� ����� ������� � ����� ��������
'            ��� 3
'            ���������� - ������� 3D ������� �� ������� �������� �� ��� 0
'start       ������ ��������
'length      ����� ��������
'diam        �������� ��������� "Diameter" ������ [Trace] trc �����
'pigLength   �������� ��������� "PigLength" ������ [Trace] trc �����
'turninf     ��������� �� ��������� T_TURNDATA, �������
'            ���������� ��������� ������� � ���������� ��������
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

'������� �������������� ��������� ���������� �������� ���� ��������,
'���������� ������������� ��������, ������� � ������ ��������.
'���� �������� handleSlave = -1, �� ��� ��������� �� ��� ���������
'����� ��������� controlSize ������������ � ���������� �������� ���
'handleMaster.
'� ������������� �� ����� matchMode, ��������� �� ��� ���� ���������
'������������ �������������� ��������� ��� ���������� ��������.
'� ���������� � ������� ������ ������� GetNextMatching �������� ���������
'�������� ������� ���������� �������� ������� � ������ ����������� ��������������
'���������:
'handleMaster   ����� �������� �������
'startMaster    ������ ������� ���������� �� ������� ������
'lengthMaster   ����� ������� ���������� �� ������� ������
'handleSlave    ����� �������� �������, ���� -1, �� �������� ���������� �������
'startSlave     ������ ������� ���������� �� ������� ������
'lengthSlave    ����� ������� ���������� �� ������� ������
'controlSize    ������ �������� ��� ����������� �����������
'               ���������� � �������� ��������
'matchMode      ������� �����, �������� ����� ���������� �������
'               ����� �� �������� MATCH_MODE_*
'rotAngle       ���� �������� ����������� �� 0 �� 2��
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

'������� �������� ���� vogx, vogy, vogz ��������� T_NODEGROUP
'������������ ������� ����� ���� �������� ������� � ������ ����������� �������
'��������������.
'���� vogext1, vogext2, vogext3 ��������������� ���������
'����������� ������ (�� ����� � ������ ���������)
'���������:
'node       ��������� �� ��������� ������� ����� ���������
'           ���������������� ������������ ������� ���������
'           ������������ handleSlave ��� ������ InitMatching
Public Declare Function vogGetNextMatching Lib "vogmath.dll" Alias "GetNextMatching" ( _
 ByRef node As T_NODEDATAGROUP _
) As Long

'������� ��������� ������ outString ��������� ��������� ������ ������������
'��� ������ � �������� ��������. ���������� ����� ������ ��������� �� ������.
Public Declare Function vogError Lib "vogmath.dll" Alias "krotError" ( _
 ByVal outString As String _
) As Long

' ������� �������������
Public Declare Function vogInit Lib "vogmath.dll" Alias "Init" ( _
 drvdata As T_VOGDRIVERDATA _
) As Long
