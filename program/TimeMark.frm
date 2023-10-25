VERSION 5.00
Object = "{00028CDA-0000-0000-0000-000000000046}#6.0#0"; "TDBG6.OCX"
Begin VB.Form frmTimeMark 
   Caption         =   "Form1"
   ClientHeight    =   2580
   ClientLeft      =   1815
   ClientTop       =   1455
   ClientWidth     =   8655
   Icon            =   "TimeMark.frx":0000
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   2580
   ScaleWidth      =   8655
   Begin VB.CommandButton btmPrint 
      Caption         =   "Печать"
      Height          =   255
      Left            =   7200
      TabIndex        =   8
      ToolTipText     =   "Напечатать таблицу"
      Top             =   360
      Width           =   1095
   End
   Begin VB.CommandButton btmImport 
      Caption         =   "Импорт"
      Height          =   255
      Left            =   7200
      TabIndex        =   5
      ToolTipText     =   "Загрузить информацию из таблицы в полосу расшифровки записи"
      Top             =   0
      Width           =   1095
   End
   Begin TrueDBGrid60.TDBGrid grid 
      Height          =   1815
      Left            =   0
      OleObjectBlob   =   "TimeMark.frx":0442
      TabIndex        =   4
      Top             =   720
      Width           =   8535
   End
   Begin VB.CommandButton btmLoad 
      Caption         =   "Загрузить"
      Height          =   375
      Left            =   6000
      TabIndex        =   3
      ToolTipText     =   "Загрузить данные из файла таймерных маркеров в таблицу и рассчитать дистанции"
      Top             =   0
      Width           =   1095
   End
   Begin VB.CommandButton btmFile 
      Caption         =   "..."
      Height          =   255
      Left            =   960
      TabIndex        =   1
      ToolTipText     =   "Выбор файла таймерных маркеров"
      Top             =   0
      Width           =   615
   End
   Begin VB.TextBox txtFile 
      Height          =   285
      Left            =   1680
      TabIndex        =   0
      ToolTipText     =   "Имя файла таймерных маркеров"
      Top             =   0
      Width           =   4215
   End
   Begin VB.Label labMS 
      Height          =   255
      Left            =   3480
      TabIndex        =   7
      Top             =   360
      Width           =   3255
   End
   Begin VB.Label labCP 
      Height          =   255
      Left            =   0
      TabIndex        =   6
      Top             =   360
      Width           =   3255
   End
   Begin VB.Label Label1 
      Caption         =   "Файл"
      Height          =   255
      Index           =   2
      Left            =   0
      TabIndex        =   2
      Top             =   0
      Width           =   975
   End
End
Attribute VB_Name = "frmTimeMark"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private trc As clsTrace
Private tm As New clsExtTime
Private xarr As New XArrayDB
Private hlp As New clsHelp
Private frm As New clsFormProps

Public Sub Init(trace As clsTrace)
Set trc = trace
hlp.BindHelp Me, KRT_ObjTimeMark
frm.Init trc.secUser, "frmTimeMark"
frm.restoreFormTable Me, grid
Me.Caption = "Таймерные маркеры " & trc.FileName
End Sub

Public Sub Save()
frm.saveFormTable Me, grid
End Sub

Public Function Edit() As Boolean
Me.Visible = True
End Function

Private Sub btmFile_Click()
ogdWin.fileOpen _
 "Выберите файл таймерных маркеров", _
 txtFile.Text, _
 cfg.dir.trc, _
 "Файлы маркеров (*.ini)|*.ini", _
 Me.hWnd, _
 txtFile
End Sub

Private Sub btmImport_Click()
Dim m As clsTimeMark, oldtyp As Integer
Dim cmn As New clsObjCommon, mrk As New clsObjLine
Dim cpCount As Integer, msCount As Integer, s As String

If trc.db.enable = False Then
 ogdWin.Alert "Полоса расшифровки отключена." & vbNewLine & "Импорт маркеров невозможен."
 Exit Sub
End If

setWait "Импорт таймерных маркеров в полосу расшифровки..."

With trc.db
oldtyp = .dfltType
cpCount = 0
msCount = 0

.dfltType = OBJ_marktime
For Each m In tm.itemCollection

 If m.cp Then
  cpCount = cpCount + 1
  s = "CP" & cpCount
  Else
  msCount = msCount + 1
  s = "MS" & msCount
 End If

 If .addObj(m.dist) Then
  .objCommon m.dist, cmn
  .objLine cmn, mrk
  mrk.dMarker = True
  mrk.dMarkerText = s
  mrk.objCommon.comment = s & " - " & m.timeExt
  .objLineSet m.dist, mrk
 End If

Next

.dfltType = oldtyp
End With

setReady

ogdWin.Info "Таймерные маркера таблицы записаны в полосу расшифровки"
End Sub

Private Sub btmLoad_Click()
setWait "Расчет дистанций маркеров..."
timeMarkLoad txtFile.Text
setReady
End Sub

Private Sub btmPrint_Click()
With grid.PrintInfo
 .PreviewCaption = trc.FileName
 .PageHeader = "Таймерные маркера\t" & trc.FileName & "\t" & txtFile.Text
 .RepeatColumnHeaders = True
 .PageFooter = "\t" & "Страница:" & " \p"
 .PrintPreview
End With
End Sub

Private Sub Form_Load()
btmImport.enabled = False
btmPrint.enabled = False
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.Visible = False
End If
End Sub

Private Function timeMarkLoad(FileName As String) As Boolean
Dim i As Integer

timeMarkLoad = False

tm.Clear
tm.FileName = FileName
If tm.Load(trc) = False Then
 ogdWin.Alert tm.errText
 Exit Function
End If

labCP.Caption = "Контрольных точек " & tm.NumCP
labMS.Caption = "Обычных маркеров " & tm.NumMS
fillGrid

btmImport.enabled = True
btmPrint.enabled = True
timeMarkLoad = True
End Function

Private Sub Form_Resize()
If Me.WindowState <> 1 Then
 grid.width = Me.ScaleWidth - grid.Left
 grid.Height = Me.ScaleHeight - grid.Top
End If
End Sub

Private Sub fillGrid()
Dim mrk As Collection, m As clsTimeMark, i As Long, s As String
Dim cpCount As Integer, msCount As Integer

If tm.NumCP <= 0 Then Exit Sub
Set mrk = tm.itemCollection

With xarr
.ReDim 0, mrk.Count - 1, 0, 7
cpCount = 0
msCount = 0

For i = 0 To mrk.Count - 1
 Set m = mrk(i + 1)
 If m.cp Then
  cpCount = cpCount + 1
  s = "CP" & cpCount
  Else
  msCount = msCount + 1
  s = "MS" & msCount
 End If
 .Value(i, 0) = s
 .Value(i, 1) = m.timeExt
 .Value(i, 2) = mm2txt(trc.getDistKoef(m.dist))
 .Value(i, 3) = m.timeInt
 .Value(i, 4) = m.timeLeft
 .Value(i, 5) = m.timeRight
 .Value(i, 6) = m.timeDiff
 .Value(i, 7) = m.koeff
Next i

End With
grid.Array = xarr
grid.ReBind
End Sub