VERSION 5.00
Begin VB.Form frmAutoScan 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   2955
   ClientLeft      =   5925
   ClientTop       =   7260
   ClientWidth     =   4545
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2955
   ScaleWidth      =   4545
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame1 
      Caption         =   "Поиск швов "
      Height          =   1095
      Left            =   120
      TabIndex        =   8
      Top             =   480
      Width           =   2775
      Begin VB.OptionButton weldScan 
         Caption         =   "алгоритм 2013"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   11
         Top             =   720
         Width           =   2415
      End
      Begin VB.OptionButton weldScan 
         Caption         =   "алгоритм 2006"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   10
         Top             =   480
         Width           =   2415
      End
      Begin VB.OptionButton weldScan 
         Caption         =   "Отключен"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   9
         Top             =   240
         Width           =   2415
      End
   End
   Begin VB.CommandButton btmTubeScan 
      Caption         =   "Настройки"
      Height          =   375
      Left            =   3000
      TabIndex        =   7
      Top             =   600
      Width           =   1455
   End
   Begin VB.CheckBox chkAngles 
      Caption         =   "Проставить изгибы труб и углы стыков"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1680
      Width           =   3975
   End
   Begin VB.CommandButton btmCancel 
      Caption         =   "Выход"
      Height          =   375
      Left            =   2400
      TabIndex        =   3
      Top             =   2520
      Width           =   1215
   End
   Begin VB.CommandButton btmRun 
      Caption         =   "Начать"
      Height          =   375
      Left            =   840
      TabIndex        =   2
      Top             =   2520
      Width           =   1215
   End
   Begin krotw32.ctrlNumBox txtStart 
      Height          =   255
      Left            =   2040
      TabIndex        =   0
      Top             =   120
      Width           =   975
      _extentx        =   1720
      _extenty        =   450
   End
   Begin krotw32.ctrlNumBox txtEnd 
      Height          =   255
      Left            =   3480
      TabIndex        =   1
      Top             =   120
      Width           =   975
      _extentx        =   1720
      _extenty        =   450
   End
   Begin VB.Label Label2 
      Caption         =   "по"
      Height          =   255
      Left            =   3120
      TabIndex        =   5
      Top             =   120
      Width           =   375
   End
   Begin VB.Label Label1 
      Caption         =   "Обработать данные с"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   1815
   End
End
Attribute VB_Name = "frmAutoScan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Const taskNum = 2
Private act As Boolean
Private trc As clsTrace
Private runFlag As Boolean
Private breakFlag As Boolean
Private hlp As New clsHelp

Public Function View(prnt As frmTrace) As Boolean

Set trc = prnt.trc
Me.Icon = prnt.Icon
hlp.BindHelp Me, KRT_ObjAuto
Me.Caption = "Автоматический анализ " & prnt.Caption
centerForm prnt, Me
txtStart.mm = trc.getDistKoef(0)
txtEnd.mm = trc.getDistKoef(trc.length)

Dim x As Boolean
x = trc.Coroz.num > 0
weldScan(0).Value = True
weldScan(0).enabled = x
weldScan(1).enabled = x
weldScan(2).enabled = x

chkAngles.enabled = trc.vog.enable

updateRunButton
act = False
runFlag = False
Me.Show 1, frmMain
View = act
End Function

Private Sub updateRunButton()
btmRun.enabled = (numTask() > 0)
End Sub

Private Function numTask() As Integer
Dim i  As Integer, cnt As Integer
cnt = 0
If weldScan(0).Value = False Then
 cnt = cnt + 1
 btmTubeScan.enabled = True
 Else
 btmTubeScan.enabled = False
End If
If chkAngles.Value = 1 Then cnt = cnt + 1
numTask = cnt
End Function

Private Sub btmCancel_Click()
If runFlag Then
 If ogdWin.AskAction("Прервать работу?", True) Then
  breakFlag = True
 End If
 Else
 Unload Me
End If
End Sub

Private Sub btmRun_Click()
Dim dStart As Long, dEnd As Long

setFormEnable False
setWait "Обработка данных"
dStart = trc.getDistReal(txtStart.mm)
dEnd = trc.getDistReal(txtEnd.mm)
act = True
runFlag = True
breakFlag = False

If weldScan(1).Value = True Then scanTubes trc, dStart, dEnd, False
If weldScan(2).Value = True Then scanTubes trc, dStart, dEnd, True
If chkAngles.Value = 1 Then calcTubeAngles dStart, dEnd

runFlag = False
setReady
setFormEnable True
trc.db.Refresh
ogdWin.Info "Обработка данных успешно завершена"
End Sub

Private Sub setFormEnable(ByVal isOn As Boolean)
Dim i  As Integer

btmRun.enabled = isOn
txtStart.enabled = isOn
txtEnd.enabled = isOn
btmTubeScan.enabled = isOn
If isOn Then updateRunButton
End Sub

Private Sub btmTubeScan_Click()
frmScanTube.Edit Me, trc, weldScan(2).Value = True
End Sub

Private Sub chkAngles_Click()
updateRunButton
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If runFlag = False Then Exit Sub
If UnloadMode = vbFormControlMenu Then
 Cancel = 1
 btmCancel_Click
End If
End Sub

Private Sub scanTubes(trc As clsTrace, ByVal dStart As Long, ByVal dEnd As Long, ByVal is2013 As Boolean)
Dim tmp As Double, partLen As Long, partStart As Long, foundDist As Long, uName As String
Dim wld1 As Double, wld2 As Double, fltStr As String, firstStep As Boolean, saveLen As Long

If ogdWin.AskAction("На заданном интервале будут удалены все существующие швы. Продолжить?") = False Then Exit Sub

fltStr = trc.db.filter
trc.db.filter = ""

partLen = dEnd - dStart
partStart = dStart

setWait "Удаление труб..."
If trc.db.deleteTubes(dStart, dEnd) = False Then Exit Sub

setWait "Поиск швов..."

foundDist = dStart
firstStep = True
uName = IIf(is2013, "scan2013", "scan2006")

With trc.tubeScan
While dStart + .lenMax < dEnd

 If .FindAt(dStart, is2013) Then
 
  If dStart > 0 Then
  
   If .foundWeld1 = -1 Then
    wld1 = -1
    Else
    wld1 = trc.Coroz.zone(.crzIndex).sens2hour(.foundWeld1)
   End If
   
   If .foundWeld2 = -1 Then
    wld2 = -1
    Else
    If .foundType = TUBE_DIRECT Then
     wld2 = wld1 + 6
     If wld2 >= 12 Then wld2 = wld2 - 12
     Else
     wld2 = trc.Coroz.zone(.crzIndex).sens2hour(.foundWeld2)
    End If
   End If
   
  End If
  
  If .foundDist > 0 Then
  
   'Debug.Print "Found at " & .foundDist
   If Not firstStep Then
    trc.db.addTube foundDist, .foundLen, .foundType, wld1, wld2, uName
   End If
   dStart = .foundDist
   foundDist = dStart
   
   Else
   dStart = dStart + .lenMax
   'Debug.Print "Not found. Move to " & dStart
  End If
  
  Else
  
  ogdWin.Alert "Ошибка при поиске швов:" & vbNewLine & .errText
  trc.db.filter = fltStr
  Exit Sub
  
 End If
 
 firstStep = False
 If breakFlag Then
  trc.db.filter = fltStr
  Exit Sub
 End If
 tmp = (dStart - partStart)
 tmp = (tmp / partLen) * 100#
 setWait "Поиск швов... " & Fix(tmp) & " %"
Wend

saveLen = .lenMax
.lenMax = dEnd - dStart
If .FindAt(dStart, is2013) Then

 If .foundWeld1 = -1 Then
  wld1 = -1
  Else
  wld1 = trc.Coroz.zone(.crzIndex).sens2hour(.foundWeld1)
 End If
   
 If .foundWeld2 = -1 Then
  wld2 = -1
  Else
  wld2 = trc.Coroz.zone(.crzIndex).sens2hour(.foundWeld2)
 End If
  
 If .foundDist > 0 Then
  trc.db.addTube foundDist, .foundLen, .foundType, wld1, wld2, uName
 End If
 
End If
 
.lenMax = saveLen
 
End With
trc.db.filter = fltStr
End Sub

Private Sub calcTubeAngles(ByVal dStart As Long, ByVal dEnd As Long)
Dim i As Long, cnt As Long, tdst As Long, tlen As Long
Dim t_curve As Double, t_angle As Double, t_complex As Boolean
Dim rs As Recordset, cmd() As String

setWait "Обработка углов труб"

ReDim cmd(1) As String

Set rs = trc.db.db.OpenRecordset( _
 "SELECT * FROM weld LEFT JOIN common ON weld.dist=common.dist ORDER BY common.dist", _
 dbOpenSnapshot)
 
cnt = rs.RecordCount
i = 1
rs.MoveFirst

While Not rs.EOF

 If IsNull(rs("common.dist")) Or IsNull(rs("len")) Then
   ogdWin.Alert "Таблица труб повреждена. Выполните экспорт таблицы труб, а затем импортируйте полученный файл обратно." & _
   vbNewLine & _
   vbNewLine & _
   "После этого запустите расчет изгибов и углов стыков повторно."
   Exit Sub
 End If
 
 tdst = rs("common.dist")
 tlen = rs("len")

 If (tdst >= dStart) And (tdst <= dEnd) Then

  trc.vog.tubeCurve tdst, tlen, t_curve, t_angle, t_complex
  cmd(1) = _
   "UPDATE weld SET " & _
   "curve = " & dblStr(t_curve) & ", " & _
   "angle = " & dblStr(t_angle) & ", " & _
   "isComplexCurve = " & boolStr(t_complex) & " " & _
   "WHERE dist=" & tdst

  If SQLexe(trc.db.db, cmd) = False Then
   ogdWin.Alert "Ошибка обновления таблицы weld:" & vbNewLine & lastSQLerror
  End If

 End If

 If breakFlag Then Exit Sub

 ogdPause 10
 setWait "Обработка углов труб " & i & "/" & cnt
 i = i + 1
 rs.MoveNext

Wend
rs.Close
End Sub

Private Sub weldScan_Click(Index As Integer)
updateRunButton
End Sub
