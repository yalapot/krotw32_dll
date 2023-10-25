VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.1#0"; "MSCOMCTL.OCX"
Begin VB.UserControl CtrlCrzFiltr 
   ClientHeight    =   1785
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   2610
   ScaleHeight     =   1785
   ScaleWidth      =   2610
   Begin VB.CheckBox chkFIlterTFI 
      Height          =   255
      Left            =   2400
      TabIndex        =   11
      ToolTipText     =   "������� �����"
      Top             =   1440
      Width           =   255
   End
   Begin VB.ComboBox lstFilter 
      Height          =   315
      ItemData        =   "CrzFiltr.ctx":0000
      Left            =   120
      List            =   "CrzFiltr.ctx":0002
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   240
      Width           =   2415
   End
   Begin MSComctlLib.Slider sldFilterParam 
      Height          =   255
      Left            =   1200
      TabIndex        =   0
      Top             =   720
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   450
      _Version        =   393216
      Min             =   1
      Max             =   30
      SelStart        =   1
      TickFrequency   =   5
      Value           =   1
   End
   Begin VB.Label labFIlterTFI1 
      Caption         =   "������"
      Height          =   255
      Left            =   120
      TabIndex        =   15
      Top             =   1440
      Width           =   615
   End
   Begin VB.Label labFIlterTFI2 
      Caption         =   "��������"
      Height          =   255
      Left            =   1080
      TabIndex        =   14
      Top             =   1440
      Width           =   735
   End
   Begin VB.Label labFIlterValTFI2 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "0"
      Height          =   255
      Left            =   1920
      TabIndex        =   13
      ToolTipText     =   "�������� �������"
      Top             =   1440
      Width           =   375
   End
   Begin VB.Label labFIlterValTFI1 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "0"
      Height          =   255
      Left            =   720
      TabIndex        =   12
      ToolTipText     =   "������ ���� ������� � �������� ��������"
      Top             =   1440
      Width           =   375
   End
   Begin VB.Label labFilter 
      Caption         =   "������"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   10
      Top             =   0
      Width           =   735
   End
   Begin VB.Label labFIlterParam 
      Caption         =   "��������"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   720
      Width           =   855
   End
   Begin VB.Label labFilterParamValue 
      Caption         =   "0"
      Height          =   255
      Left            =   960
      TabIndex        =   8
      Top             =   720
      Width           =   375
   End
   Begin VB.Label labFIlterValRolled2 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "0"
      Height          =   255
      Left            =   1200
      TabIndex        =   7
      ToolTipText     =   "�������� ������ ���� �������-�������"
      Top             =   1080
      Width           =   495
   End
   Begin VB.Label labFIlterValRolled1 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "0"
      Height          =   255
      Left            =   360
      TabIndex        =   6
      ToolTipText     =   "��������� ������ ���� �������-�������"
      Top             =   1080
      Width           =   500
   End
   Begin VB.Label labFIlterRolled2 
      Caption         =   "x2"
      Height          =   255
      Left            =   960
      TabIndex        =   5
      Top             =   1080
      Width           =   255
   End
   Begin VB.Label labFIlterRolled1 
      Caption         =   "x1"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   1080
      Width           =   255
   End
   Begin VB.Label labFIlterAmplifer 
      Caption         =   "z"
      Height          =   255
      Left            =   1800
      TabIndex        =   3
      Top             =   1080
      Width           =   255
   End
   Begin VB.Label labFIlterValAmplifer 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "0"
      Height          =   255
      Left            =   2040
      TabIndex        =   2
      ToolTipText     =   "����������� �������� �������-�������"
      Top             =   1080
      Width           =   495
   End
End
Attribute VB_Name = "CtrlCrzFiltr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'������� �������� ������������ ���������
Option Explicit

Private crz As clsCorozZones
Private trc As clsTrace
Private initFlag As Boolean
Private Index As Integer
Public Event Changed()

Public Property Get ZoneIndex() As Integer
    ZoneIndex = Index
End Property
Public Property Let ZoneIndex(i As Integer)
   Index = i
   setupZone i
End Property



Public Sub Init(trace As clsTrace)
Dim i As Integer
Dim tp As Long
initFlag = True

Set trc = trace
Set crz = trc.Coroz

'setupZone 0

lstFilter.addItem "��������"
lstFilter.addItem "�����"
lstFilter.addItem "�������������"
lstFilter.addItem "��������"
lstFilter.addItem "���������� �������"
lstFilter.addItem "��� ���������� Ctrl+M"
lstFilter.addItem "������ 2021"
lstFilter.addItem "������ 2019"
lstFilter.addItem "������� ���������"
lstFilter.addItem "������� ��������"
lstFilter.addItem "������� �����������"
lstFilter.addItem "������ ��"

tp = labFIlterParam.top
labFIlterRolled1.top = tp
labFIlterValRolled1.top = tp
labFIlterRolled2.top = tp
labFIlterValRolled2.top = tp
labFIlterAmplifer.top = tp
labFIlterValAmplifer.top = tp

labFIlterTFI1.top = tp
labFIlterValTFI1.top = tp
labFIlterTFI2.top = tp
labFIlterValTFI2.top = tp
chkFIlterTFI.top = tp

initFlag = False
End Sub
Public Property Let setFlt(ByVal flt_idx As Integer)
    lstFilter.ListIndex = flt_idx
End Property

Private Sub setupZone(ByVal indx As Integer)
Dim czone As clsCoroz, i As Integer, itm As Integer

Set czone = crz.zone(indx)


lstFilter.ListIndex = czone.filterType

sldFilterParam.LargeChange = 5
sldFilterParam.Max = 30
sldFilterParam.Min = 1
sldFilterParam.TickFrequency = 5
sldFilterParam.Value = czone.filterUnweldParam
labFIlterValRolled1.Caption = czone.filterRolled1Param
labFIlterValRolled2.Caption = czone.filterRolled2Param
labFIlterValAmplifer.Caption = czone.filterRolledAmplifer
labFIlterValTFI1.Caption = czone.filterTFI1Param
labFIlterValTFI2.Caption = czone.filterTFI2Param
chkFIlterTFI.Value = czone.filterTFIbase

'sldFilterParam_Change
End Sub


Private Sub filterUnweldOn(isOn As Boolean)
Select Case lstFilter.ListIndex
 ' �����
 Case 1
   labFIlterParam.Caption = "��������"
   sldFilterParam.Min = 1
   sldFilterParam.Max = 30
 ' �������
 Case 6
   labFIlterParam.Caption = "��������"
   sldFilterParam.Min = 0
   sldFilterParam.Max = 64
 ' ������ 2019
 Case 7
   labFIlterParam.Caption = "��������"
   sldFilterParam.Min = 0
   sldFilterParam.Max = 64
 ' ������� 1
 Case 8
   labFIlterParam.Caption = "��������"
   sldFilterParam.Min = 0
   sldFilterParam.Max = 64
 Case 9
   labFIlterParam.Caption = "��������"
   sldFilterParam.Min = 0
   sldFilterParam.Max = 64
 Case 10
   labFIlterParam.Caption = "��������"
   sldFilterParam.Min = 0
   sldFilterParam.Max = 64
End Select

sldFilterParam.visible = isOn
labFIlterParam.visible = isOn
labFilterParamValue.visible = isOn
End Sub

Private Sub filterRollOn(isOn As Boolean)
labFIlterRolled1.visible = isOn
labFIlterValRolled1.visible = isOn
labFIlterRolled2.visible = isOn
labFIlterValRolled2.visible = isOn
labFIlterValAmplifer.visible = isOn
labFIlterAmplifer.visible = isOn
End Sub

Private Sub filterTFIOn(isOn As Boolean)
labFIlterTFI1.visible = isOn
labFIlterValTFI1.visible = isOn
labFIlterTFI2.visible = isOn
labFIlterValTFI2.visible = isOn
chkFIlterTFI.visible = isOn
End Sub

Private Sub labFIlterValAmplifer_Click()
Dim s As String, v As Long

s = InputBox("������� �������� ��������� �������� �������", "�������� ���������", crz.zone(Index).filterRolledAmplifer)
If Len(s) = 0 Then Exit Sub

v = CLng(s)

labFIlterValAmplifer.Caption = CStr(v)
crz.zone(Index).filterRolledAmplifer = v

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
setReady
End Sub

Private Sub chkFIlterTFI_Click()
crz.zone(Index).filterTFIbase = chkFIlterTFI.Value

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
setReady
End Sub

Private Sub labFIlterValTFI1_Click()
Dim s As String, v As Long

s = InputBox("������� �������� ������ ���� ������� � �������� ��������", "�������� ���������", crz.zone(Index).filterTFI1Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v > 500 Then
 ogdWin.Alert "�������� ������ ���� ������� �� ������ ��������� 500"
 Exit Sub
End If
If v < 1 Then
 ogdWin.Alert "�������� ������ ���� ������� �� ������ ���� ������ 1"
 Exit Sub
End If

labFIlterValTFI1.Caption = CStr(v)
crz.zone(Index).filterTFI1Param = v

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
setReady
End Sub

Private Sub labFIlterValTFI2_Click()
Dim s As String, v As Long

s = InputBox("������� �������� �������� �������", "�������� ���������", crz.zone(Index).filterTFI2Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v > 30 Then
 ogdWin.Alert "�������� �������� ������� �� ������ ��������� 30"
 Exit Sub
End If
If v < 1 Then
 ogdWin.Alert "�������� �������� ������� �� ������ ���� ������ 1"
 Exit Sub
End If

labFIlterValTFI2.Caption = CStr(v)
crz.zone(Index).filterTFI2Param = v

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
setReady
End Sub

Private Sub labFIlterValRolled1_Click()
Dim s As String, v As Long

s = InputBox("������� �������� ��������� �������", "�������� ���������", crz.zone(Index).filterRolled1Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v > crz.zone(Index).filterRolled2Param Then
 ogdWin.Alert "�������� ���������1 �� ������ ��������� �������� ���������2"
 Exit Sub
End If
If v < 1 Then
 ogdWin.Alert "�������� ���������1 �� ������ ���� ������ 1"
 Exit Sub
End If

labFIlterValRolled1.Caption = CStr(v)
crz.zone(Index).filterRolled1Param = v

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
setReady
End Sub

Private Sub labFIlterValRolled2_Click()
Dim s As String, v As Long

s = InputBox("������� �������� ��������� �������", "�������� ���������", crz.zone(Index).filterRolled2Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v < crz.zone(Index).filterRolled1Param Then
 ogdWin.Alert "�������� ���������2 �� ������ ���� ������ �������� ���������1"
 Exit Sub
End If
If lstFilter.ListIndex <> 11 Then
    If v > 15 Then
     ogdWin.Alert "�������� ���������2 �� ������ ���� ������ 15"
     Exit Sub
    End If
Else
    If v > 4000 Then
     ogdWin.Alert "�������� ���������2 �� ������ ���� ������ 4000"
     Exit Sub
    End If
End If
labFIlterValRolled2.Caption = CStr(v)
crz.zone(Index).filterRolled2Param = v

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
setReady
End Sub

Private Sub labFilterParamValue_Click()
Dim s As String

s = InputBox("������� �������� ��������� �������", "�������� ���������", sldFilterParam.Value)
If Len(s) > 0 Then
  sldFilterParam.Value = val(s)
End If
End Sub

Private Sub lstFilter_Click()

Select Case lstFilter.ListIndex

 ' ��������
 Case 0
  filterUnweldOn False
  filterRollOn False
  filterTFIOn False
  
 ' �����
 Case 1
  filterUnweldOn True
  filterRollOn False
  filterTFIOn False
  sldFilterParam.Value = crz.zone(Index).filterUnweldParam
  
 ' �������������
 Case 2
  filterUnweldOn False
  filterRollOn True
  filterTFIOn False
  
 ' ��������
 Case 3
  filterUnweldOn False
  filterRollOn False
  filterTFIOn False
  
 ' ���������� �������
 Case 4
  filterUnweldOn False
  filterRollOn False
  filterTFIOn True
  
 ' ��� ����������
 Case 5
  filterUnweldOn False
  filterRollOn False
  filterTFIOn False
  
 ' �������
 Case 6
  filterUnweldOn True
  filterRollOn False
  filterTFIOn False
  sldFilterParam.Value = crz.zone(Index).filterVolosokParam

 ' ������ 2019
 Case 7
  filterUnweldOn True
  filterRollOn False
  filterTFIOn False
  sldFilterParam.Value = crz.zone(Index).filterFilter2019Param
  
 ' ������� 1
 Case 8
  filterUnweldOn True
  filterRollOn False
  filterTFIOn False
  sldFilterParam.Value = crz.zone(Index).filterConvolution1Param
  
 ' ������� 2
 Case 9
  filterUnweldOn True
  filterRollOn False
  filterTFIOn False
  sldFilterParam.Value = crz.zone(Index).filterConvolution2Param

' ������� 3
 Case 10
  filterUnweldOn True
  filterRollOn False
  filterTFIOn False
  sldFilterParam.Value = crz.zone(Index).filterConvolution3Param
  
 ' ��
 Case 11
  filterUnweldOn False
  filterRollOn True
  filterTFIOn False
End Select
crz.zone(Index).filterType = lstFilter.ListIndex

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
'frmZoom.drawPic


setReady
End Sub
Private Sub sldFilterParam_Change()
labFilterParamValue.Caption = sldFilterParam.Value

Select Case lstFilter.ListIndex
 ' �����
 Case 1
   crz.zone(Index).filterUnweldParam = sldFilterParam.Value
 ' �������
 Case 6
   crz.zone(Index).filterVolosokParam = sldFilterParam.Value
 ' ������ 2019
 Case 7
   crz.zone(Index).filterFilter2019Param = sldFilterParam.Value
 ' ������� 1
 Case 8
   crz.zone(Index).filterConvolution1Param = sldFilterParam.Value
' ������� 2
 Case 9
   crz.zone(Index).filterConvolution2Param = sldFilterParam.Value
' ������� 3
 Case 10
   crz.zone(Index).filterConvolution3Param = sldFilterParam.Value
End Select

If initFlag Then Exit Sub
'RaiseEvent changeZone(Index)
RaiseEvent Changed
'frmZoom.drawPic
setReady
End Sub

