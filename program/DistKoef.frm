VERSION 5.00
Object = "{00028CDA-0000-0000-0000-000000000046}#6.0#0"; "TDBG6.OCX"
Begin VB.Form frmDistKoef 
   Caption         =   "Таблица поправок по дистанции"
   ClientHeight    =   5070
   ClientLeft      =   6255
   ClientTop       =   2265
   ClientWidth     =   3600
   LinkTopic       =   "Form1"
   ScaleHeight     =   5070
   ScaleWidth      =   3600
   Begin TrueDBGrid60.TDBGrid grid 
      Height          =   1815
      Left            =   0
      OleObjectBlob   =   "DistKoef.frx":0000
      TabIndex        =   0
      Top             =   480
      Width           =   3255
   End
   Begin VB.Label labEnd 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label2"
      Height          =   255
      Left            =   1560
      TabIndex        =   4
      Top             =   240
      Width           =   1575
   End
   Begin VB.Label labStart 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label2"
      Height          =   255
      Left            =   1560
      TabIndex        =   3
      Top             =   0
      Width           =   1575
   End
   Begin VB.Label Label1 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Конец"
      Height          =   255
      Index           =   1
      Left            =   0
      TabIndex        =   2
      Top             =   240
      Width           =   1575
   End
   Begin VB.Label Label1 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Начало"
      Height          =   255
      Index           =   0
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   1575
   End
   Begin VB.Menu menuSet 
      Caption         =   "Таблица"
      Begin VB.Menu mnuSet 
         Caption         =   "Загрузить"
         Index           =   0
         Shortcut        =   ^L
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Сохранить"
         Index           =   1
         Shortcut        =   ^S
      End
      Begin VB.Menu mnuSet 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Выход"
         Index           =   3
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu menuAct 
      Caption         =   "Действия"
      Begin VB.Menu mnuAct 
         Caption         =   "Добавить"
         Index           =   0
         Shortcut        =   {F7}
      End
      Begin VB.Menu mnuAct 
         Caption         =   "Удалить"
         Index           =   1
         Shortcut        =   {F8}
      End
   End
End
Attribute VB_Name = "frmDistKoef"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private xarr As New XArrayDB
Private trc As clsTrace
Private hlp As New clsHelp

Private Sub setActMenu()
mnuAct(1).enabled = (Not (grid.row = -1)) And (Not trc.db.isRO)
End Sub

Public Sub Edit(prnt As Form, trace As clsTrace)
Set trc = trace

Me.Icon = prnt.Icon
labStart.caption = 0
labEnd.caption = trc.length
centerForm prnt, Me

xarr.Clear
xarr.ReDim 0, 0, 0, 1
trc.db.dstTblLoad xarr

Set grid.Array = xarr
grid.ReBind

mnuAct(0).enabled = Not trc.db.isRO
mnuSet(0).enabled = Not trc.db.isRO
mnuSet(1).enabled = Not trc.db.isRO

setActMenu
Me.Show 1, prnt
End Sub

Private Sub Form_Load()
hlp.BindHelp Me, KRT_ObjCorrectTable
End Sub

Private Sub Form_Resize()
If Me.WindowState <> 1 Then
 grid.width = Me.ScaleWidth - grid.Left
 grid.Height = Me.ScaleHeight - grid.Top
End If
End Sub

Private Sub saveData()
setWait ("Сохранение данных...")
If grid.DataChanged Then grid.Update
trc.db.dstTblSave xarr
setReady
End Sub

Private Sub loadData()
Dim fName As String, fl As Integer, s As String, itm As Variant, cm As String
Dim firstLine As Boolean

fName = ogdWin.fileOpen( _
 "Выберите файл поправок", _
 "", _
 cfg.dir.trc, _
 "Файлы поправок (*.csv)|*.csv", _
 Me.hWnd)

If fName = "" Then Exit Sub

setWait ("Загрузка данных...")
cm = cfg.obj.distTblComma
xarr.Clear
xarr.ReDim 0, 0, 0, 1
fl = FreeFile
firstLine = True
Open fName For Input Access Read As #fl
' skip first line with mode info
Line Input #fl, s

Do While Not EOF(fl)
 Line Input #fl, s
 itm = Split(s, cm)
 If (UBound(itm) - LBound(itm)) = 1 Then
  If Not firstLine Then xarr.AppendRows
  xarr.Value(xarr.Count(1) - 1, 0) = itm(0)
  xarr.Value(xarr.Count(1) - 1, 1) = itm(1)
  firstLine = False
 End If
Loop

Close #fl
Set grid.Array = xarr
grid.ReBind
setActMenu
setReady
End Sub

Private Sub grid_BeforeColUpdate(ByVal ColIndex As Integer, OldValue As Variant, Cancel As Integer)

If ColIndex > 0 Then Exit Sub

If Val(grid.Columns(ColIndex).Text) < 0 Then
 Cancel = False
 grid.Columns(ColIndex).Value = str$(0)
End If

If Val(grid.Columns(ColIndex).Text) > trc.length Then
 Cancel = False
 grid.Columns(ColIndex).Value = str$(trc.length)
End If

End Sub

Private Sub mnuAct_Click(Index As Integer)
Dim b As Variant

b = grid.Bookmark
If IsNull(b) Then b = 0
Select Case Index
 Case 0 'добавить
  If grid.DataChanged Then grid.Update
  xarr.InsertRows b
 Case 1 'удалить
  xarr.DeleteRows b
End Select
grid.ReOpen b
setActMenu
grid.SetFocus
End Sub

Private Sub mnuSet_Click(Index As Integer)
Select Case Index
 Case 0 'загрузить
  loadData
 Case 1 'сохранить
  saveData
 Case 3 'выход
  Unload Me
End Select
End Sub