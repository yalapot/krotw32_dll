VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Begin VB.Form frmUtilMinute 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Установка ориентации дефектов по данным линзы"
   ClientHeight    =   2160
   ClientLeft      =   2160
   ClientTop       =   6870
   ClientWidth     =   6180
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2160
   ScaleWidth      =   6180
   ShowInTaskbar   =   0   'False
   Begin ComctlLib.ProgressBar prg 
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   1320
      Visible         =   0   'False
      Width           =   6015
      _ExtentX        =   10610
      _ExtentY        =   450
      _Version        =   327682
      Appearance      =   1
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Выход"
      Height          =   375
      Index           =   1
      Left            =   3240
      TabIndex        =   2
      Top             =   1680
      Width           =   1335
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Запуск"
      Height          =   375
      Index           =   0
      Left            =   1440
      TabIndex        =   1
      Top             =   1680
      Width           =   1335
   End
   Begin VB.Label labTxt 
      Caption         =   "Label1"
      Height          =   975
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   5895
   End
End
Attribute VB_Name = "frmUtilMinute"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private trc As clsTrace
Private db As Database
Private totalNum As Long
Private distMin As Long
Private distMax As Long

Public Sub setMinutes(trace As clsTrace)
Dim rs As Recordset, cmd As String
Dim mdbName As String

setWait "Читаю содержимое базы..."

Set trc = trace
mdbName = trc.db.Mdb

On Error Resume Next
db.Close

On Error GoTo dbOpen
Set db = OpenDatabase(mdbName)
On Error GoTo 0

On Error GoTo dbRead

cmd = "SELECT count(*) AS recNum FROM defect " & _
"WHERE iy1>0 AND iy2>0"
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
totalNum = rs("recNum")
rs.Close

cmd = "SELECT min(dist) AS minDist FROM defect"
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
distMin = rs("minDist")
rs.Close

cmd = "SELECT max(dist) AS maxDist FROM defect"
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
distMax = rs("maxDist")
rs.Close

On Error GoTo 0

Me.Icon = frmMain.Icon
If totalNum > 0 Then
 labTxt.Caption = _
 "В файле базы данных " & mdbName & _
 " с дистанции " & mm2txt(trc.getDistKoef(distMin)) & _
 " по дистанцию " & mm2txt(trc.getDistKoef(distMax)) & _
 " найдено " & totalNum & _
 " дефектов у которых присутствуют данные линзы, " & _
 "по которым можно установить ориентацию этих дефектов " & _
 "в формате часы:минуты"
 btmAct(0).enabled = True
 Else
 labTxt.Caption = _
 "В файле базы данных " & mdbName & _
 " с дистанции " & mm2txt(trc.getDistKoef(distMin)) & _
 " по дистанцию " & mm2txt(trc.getDistKoef(distMax)) & _
 " не найдено дефектов с данными линзы"
 btmAct(0).enabled = False
End If
setReady
centerForm frmMain, Me
Me.Show 1, frmMain
Exit Sub

dbOpen:
setReady
ogdWin.Alert "Ошибка при открытии " & mdbName & _
vbNewLine & Err.Description
Exit Sub

dbRead:
setReady
ogdWin.Alert "Ошибка при чтении " & mdbName & _
vbNewLine & Err.Description
Exit Sub

End Sub

Private Sub procBase()
Dim rs As Recordset, cmd As String, i As Long

cmd = "SELECT * FROM defect " & _
"WHERE iy1>0 AND iy2>0"
Set rs = db.OpenRecordset(cmd, dbOpenDynaset)

rs.MoveFirst
i = 0
While Not rs.EOF
 If prg.Visible = False Then
  rs.Close
  Exit Sub
 End If
 rs.Edit
 rs("orient_s") = trc.Coroz.Zone(0).sens2hour(rs("iy1"))
 rs("orient_e") = trc.Coroz.Zone(0).sens2hour(rs("iy2"))
 rs.Update
 i = i + 1
 If i < prg.Max Then prg.Value = i
 ogdPause 10
 rs.MoveNext
Wend
rs.Close
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0 'запуск
  If prg.Visible Then
   prg.Visible = False
   Else
   prg.Min = 0
   prg.Max = totalNum
   prg.Value = 0
   setWait "Обработка...", vbArrowHourglass
   btmAct(0).Caption = "Стоп"
   btmAct(1).enabled = False
   prg.Visible = True
   procBase
   prg.Visible = False
   btmAct(0).Caption = "Запуск"
   btmAct(1).enabled = True
   setReady
   Unload Me
  End If
 Case 1 'выход
  Unload Me
End Select
End Sub

Private Sub Form_Unload(Cancel As Integer)
On Error Resume Next
db.Close
End Sub