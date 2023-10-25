Attribute VB_Name = "krtapi"
Option Explicit

'������ API ���������
Public Const KRT_API_V1 = 1
Public Const KRT_API_V2 = 2

'���� �������� krotw32.dll
Public Const KRT_OK = 0
Public Const KRT_ERR = 1

'������ ������ ��� ��� ���������������� �������
Public Const KRT_TEXT = 1024
Public Const KRT_MAX_EXTSEN_NAME = KRT_TEXT

'���� �������� ���������
Public Enum KRT_SENS_TYPE
SENS_TYPE_HOLL = 1      ' �������� ���� ����
SENS_TYPE_FERR = 2      ' ���������
SENS_TYPE_INDK = 3      ' ������������

' ��� ���� �������� �������� �������� ���������� � ����� ��������

SENS_RESIDUAL = 4       ' ���������� ���������������
SENS_PROFIL = 5         ' ���������� �������
SENS_TFI = 6            ' ���������� ��������������� (������)
SENS_MFL = 7            ' ���������� ��������������� (������������)
SENS_INTROSCOPE = 8     ' ���������
End Enum

'���� �������������� ��������
Public Enum KRT_SENS
SENS_TIMER = 1          ' ������
SENS_ODO = 2            ' �������
SENS_ORIENT = 4         ' ����������
SENS_SHAKE = 8          ' ���������
SENS_PRESS = 16         ' ��������
SENS_TEMP = 32          ' �����������
SENS_ANGLE = 64         ' ������� ���������
SENS_VOG = 128          ' VOG
SENS_THICK = 256        ' ������� ������
SENS_AZIMUTH = 512      ' ������
SENS_TANGAZH = 1024     ' ������

SENS_COROZ = 16777216   ' �����������
SENS_SPEED = 33554432   ' ��������
SENS_CURVE = 67108864   ' �����
SENS_EXT = 134217728    ' ���������������
End Enum

'��������� �������� �������
Public Type T_SENS
num As Long            ' ����������
stepSize As Long       ' ������������ ��������� (��/������� - �� ������ ������)
minVal As Long         ' ����������� �������� (����������� ���������� T_NODEGROUP)
maxVal As Long         ' ������������ �������� (����������� ���������� T_NODEGROUP)
End Type

'��������� �������� ����� �������� ���������
Public Type T_SENSGROUP
num As Long            ' ���-�� �������� � �����
stype As Long           ' ��� �������� (SENS_TYPE_*)
minVal As Long         ' ����������� �������� ��������� ������� (������� ���)
maxVal As Long         ' ������������ �������� ��������� ������� (������� ���)
isRow As Long          ' 1/0 ���� 0 ����� ������ �� ��������������
maxRowVal As Long      ' ������������ �������� ����� ������
minRowVal As Long      ' ����������� �������� ����� ������
End Type

'��������� �������� �������
Public Type T_EVENT
type As Long           ' ��� ������� (KRT_EVNT_*)
pos As Long            ' ��������� ������� �� ������ (��)
param1 As Long         ' ��������� �������
param2 As Long
End Type

'��������� ��� ��������� ���������� �������
Public Type T_NODEDATA
 sensVal As Long       '�������� �������
 prevPos As Long       '��������� �� ������ �������� ����������� ����
End Type

'��������� ��� ��������� ������ ��������
Public Type T_NODEDATAGROUP

 timerVal As Long      '�������� �������
 timerPos As Long      '��������� �� ������ ��������� �������

 odoVal As Long        '�������� ��������
 odoPos As Long        '��������� �� ������ ��������� ��������

 orientVal As Long     '�������� ������� ����������
 orientPos As Long     '��������� �� ������ ��������� ������� ����������

 shakeVal As Long      '�������� ������� ���������
 shakePos As Long      '��������� �� ������ ��������� ������� ���������

 pressVal As Long      '�������� ������� ��������
 pressPos As Long      '��������� �� ������ ��������� ������� ��������

 tempVal As Long       '�������� ������� �����������
 tempPos As Long       '��������� �� ������ ��������� ������� �����������

 angleVal As Long      '�������� ������� ������� ���������
 anglePos As Long      '��������� �� ������ ��������� ������� ������� ���������

 thickVal As Long      '�������� ������ ������� ������ �����
 thickPos As Long      '��������� �� ������ ��������� ������ ������� ������ �����
                        '������� VOG (�� VOG �����)
 vogx As Long           '��������, ��
 vogy As Long           '���������, ��
 vogZ As Long           '��������, ��
 vogext1 As Single      'Psi, ������, ���
 vogext2 As Single      'Teta, ������, ���
 vogext3 As Single      'Gamma, ����, ���
 vogPos As Long        '��������� �� ������ ������ ��������� �������� VOG

End Type

'��������� ��������� � ����������� ����� ������
Public Type T_ARRIVED_DATA
 d_start As Long       '������ ������� ����� ������
 d_length As Long      '����� ������� ����� ������
End Type

Public Function getCorozSensName(ByVal zoneType As KRT_SENS_TYPE) As String
Select Case zoneType
 Case KRT_SENS_TYPE.SENS_INTROSCOPE
  getCorozSensName = "���������"
 Case KRT_SENS_TYPE.SENS_PROFIL
  getCorozSensName = "����������"
 Case KRT_SENS_TYPE.SENS_RESIDUAL
  getCorozSensName = "����������"
 Case KRT_SENS_TYPE.SENS_MFL
  getCorozSensName = "����������"
 Case KRT_SENS_TYPE.SENS_TFI
  getCorozSensName = "����������"
 Case Else
  getCorozSensName = "�����������"
End Select
End Function
