Attribute VB_Name = "dai"
Option Explicit

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

'��������� ��� �������� �� VB ���������� � ��������������� ���� ��� DAI
Public Type VB_DAI_INFO
 orntStart As Long     '��������� ������ ������ ������� ������ �� ���������� ����� � �������� (1-360)
 orntLen As Long       '������ ������� �� ���������� ����� � �������� (1-360) ���������� ������������� ����������
 itemX As Long         '������������� �������� ������� ������ ����� ����� � ��. (��� ������ �������)
 itemY As Long         '������������� �������� ������� ������ �� ���������� ����� � ��. (���������� ����� ���������)
End Type

Public Declare Function krotDai Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef udai As DAI_INFO, _
 ByRef daiInfo As VB_DAI_INFO, _
 ByVal lpReturnedString As String, _
 ByVal informUser As Long _
) As Integer

Global frmZoomDAI As frmZoom
