VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsExtTime"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Enum errConst
 NO_ERROR
 NO_CONTROL_POINT
 DUP_TIME
 ONE_CONTROL_POINT
 NO_MARKERS
 CALC_DIST
 STOP_NEAR
End Enum

Private fname As String
Private d_cpNum As Long
Private d_msNum As Long

Private errCode As errConst
Private extError As String
Private marks As New Collection

Property Get FileName() As String
FileName = fname
End Property

Property Let FileName(f As String)
fname = f
End Property

Property Get errText() As String
Select Case errCode

 Case NO_ERROR
  errText = "��� ������"
 Case NO_CONTROL_POINT
  errText = "��� ����������� �����"
 Case DUP_TIME
  errText = "������������� ����� ������������ �������� ������� " & extError
 Case ONE_CONTROL_POINT
  errText = "������ ���� ����������� �����. �� ���� ���������� �������� ��������� �������." & extError
 Case NO_MARKERS
  errText = "��� ������� ��������"
 Case CALC_DIST
  errText = "������ ��� ���������� ��������� ��������� ������� �� �������� ������������ " & extError
 Case STOP_NEAR
  errText = "����������� ����� �� ������� " & extError & " ������ � ���� ���������." & vbNewLine & _
  "������ ����� ���������� ������������ ��� ��������."

 Case Else
  errText = "������ � ����� " & errCode
End Select
End Property

Public Sub Clear()
clearCollection marks
d_cpNum = 0
d_msNum = 0
End Sub

Public Function Load(trc As clsTrace) As Boolean
Dim cpNum As Long, cpTime As Long, cpDist As Long
Dim i As Long, firstFlag As Boolean
Dim tm As clsTimeMark, tmPrev As clsTimeMark, tmFirst As clsTimeMark
Dim kf As Double, cpCurr As clsTimeMark

Load = False
Clear

'��������� ���-�� ����������� �����
cpNum = paramCP("PointNum")
If cpNum < 1 Then
 errCode = NO_CONTROL_POINT
 Exit Function
End If

'��������� ����������� �����
For i = 1 To cpNum
 cpTime = paramCP("Point" & i & "Time")
 cpDist = paramCP("Point" & i & "Dist")
 If place2col(trc.handle, i, cpTime, trc.getDistReal(cpDist)) = False Then Exit Function
Next

'���������� ������, ���� �� ����.
'�������� � ���� ������ ������� ��������
If cpNum = 1 Then
 ogdWin.Alert "������ ���� ����������� �����!" & vbNewLine & _
   "�������� �� �������� ��������� � ���������� ������� ����� ���������!"
End If
d_cpNum = cpNum

'���������� �������� ��������� �������
firstFlag = True
For Each tm In marks
 If firstFlag Then
  Set tmFirst = tm
  firstFlag = False
  Else
 tmPrev.Link tm
 End If
 Set tmPrev = tm
Next
tmPrev.last = True

'��������� ���-�� ������� ��������
cpNum = paramMS("PointNum")
If cpNum < 1 Then
 errCode = NO_MARKERS
 Exit Function
End If
d_msNum = cpNum

'��������� ������� �������
For i = 1 To cpNum
 cpTime = paramMS("Point" & i & "Time")
 If place2col(trc.handle, i, cpTime) = False Then Exit Function
Next

'���������� ��������� ������� �������� �� ������
kf = tmFirst.koeff
i = 0
Set cpCurr = Nothing
For Each tm In marks
 tm.indx = i
 If tm.cp Then
  If Not tm.last Then kf = tm.koeff
  Set cpCurr = tm
  Else
  If tm.calcDist(trc, kf, cpCurr) = False Then
   errCode = CALC_DIST
   extError = "" & tm.timeExt
   Exit Function
  End If
 End If
 i = i + 1
Next
Load = True
End Function

Private Function stopNear(ByVal tHandle As Long, ByVal dst As Long) As Boolean
Dim datOne As T_NODEDATA, datTwo As T_NODEDATA
Dim d1 As Double, d2 As Double

stopNear = False

If dst < 0 Then Exit Function

If krotGetFirstNode(tHandle, datOne, dst, SENS_TIMER, -1, 0, 0) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If
If krotGetNextNode(tHandle, datTwo) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If

If datOne.prevPos = dst Then Exit Function

d1 = datTwo.prevPos - datOne.prevPos '����
d2 = datTwo.sensVal - datOne.sensVal '�����
d1 = d1 * 100 / d2 '�������� � ��/���
' ���� �������� ������ 0.1 �/�, �������, ��� ����� ���� ���������.
If d1 < 10 Then stopNear = True

End Function

Private Function place2col( _
ByVal tHandle As Long, _
ByVal indx As Long, _
ByVal vTime As Long, _
Optional ByVal vDist As Long = -1 _
) As Boolean

Dim tm As clsTimeMark, t As clsTimeMark, lastTime As Long

If stopNear(tHandle, vDist) Then
 extError = "" & vDist
 errCode = STOP_NEAR
 place2col = False
 Exit Function
End If

place2col = True

Set tm = New clsTimeMark
tm.Init tHandle, vTime, vDist

If marks.Count = 0 Then
 marks.Add tm, Str(vTime)
 Exit Function
End If

On Error GoTo dupKey

For Each t In marks
 If t.timeExt > vTime Then
  marks.Add tm, Str(vTime), Str(t.timeExt)
  Exit Function
 End If
 lastTime = t.timeExt
Next

marks.Add tm, Str(vTime), , Str(lastTime)
Exit Function

dupKey:
On Error GoTo 0
extError = "CP" & indx & " time " & vTime
errCode = DUP_TIME
place2col = False

End Function

Private Function paramCommon(sec As String, pName As String) As Long
Dim s As String

s = getIniItem(fname, sec, pName)
If s = "" Then
 paramCommon = 0
 Else
 paramCommon = CLng(s)
End If
End Function

Private Function paramCP(pName As String) As Long
paramCP = paramCommon("ControlPoints", pName)
End Function

Private Function paramMS(pName As String) As Long
paramMS = paramCommon("Markers", pName)
End Function

Property Get NumCP() As Long
NumCP = d_cpNum
End Property

Property Get NumMS() As Long
NumMS = d_msNum
End Property

Property Get itemCollection() As Collection
Set itemCollection = marks
End Property