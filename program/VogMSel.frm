VERSION 5.00
Object = "{5E9E78A0-531B-11CF-91F6-C2863C385E30}#1.0#0"; "MSFLXGRD.OCX"
Begin VB.Form frmVogMatchSelect 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Выберите прогоны для совмещения"
   ClientHeight    =   3750
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   9315
   Icon            =   "VogMSel.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3750
   ScaleWidth      =   9315
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin MSFlexGridLib.MSFlexGrid grid 
      Height          =   2055
      Left            =   120
      TabIndex        =   6
      Top             =   960
      Width           =   9135
      _ExtentX        =   16113
      _ExtentY        =   3625
      _Version        =   393216
      Cols            =   9
      BackColor       =   16777215
      WordWrap        =   -1  'True
   End
   Begin VB.CommandButton btmAction 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   4800
      TabIndex        =   5
      Top             =   3120
      Width           =   1215
   End
   Begin VB.CommandButton btmAction 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   3240
      TabIndex        =   4
      Top             =   3120
      Width           =   1215
   End
   Begin VB.Frame FrameMode 
      Caption         =   "Режим совмещения"
      Height          =   615
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   9135
      Begin VB.CheckBox mMode 
         Caption         =   "преобразование поворота"
         Height          =   255
         Index           =   2
         Left            =   6240
         TabIndex        =   3
         Top             =   240
         Width           =   2775
      End
      Begin VB.CheckBox mMode 
         Caption         =   "преобразование растяжения / сжатия"
         Height          =   255
         Index           =   1
         Left            =   2640
         TabIndex        =   2
         Top             =   240
         Width           =   3495
      End
      Begin VB.CheckBox mMode 
         Caption         =   "преобразование сдвига"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   2415
      End
   End
   Begin VB.Label labPart 
      Caption         =   "участок с"
      Height          =   255
      Left            =   6120
      TabIndex        =   9
      Top             =   0
      Width           =   3135
   End
   Begin VB.Label labMaster 
      Caption         =   "Label2"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   1680
      TabIndex        =   8
      Top             =   0
      Width           =   4335
   End
   Begin VB.Label Label1 
      Caption         =   "Главная запись"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   7
      Top             =   0
      Width           =   1575
   End
End
Attribute VB_Name = "frmVogMatchSelect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private act As Boolean
Private m As frmTrace
Private hlp As New clsHelp

Private Sub setColumn( _
indx As Integer, _
width As Long, _
align As Long, _
capt As String _
)
grid.ColWidth(indx) = width
grid.Row = 0
grid.Col = indx
grid.Text = capt
End Sub

Public Function SelSlave(master As frmTrace) As Boolean
Dim f As Form, v As frmTrace, s As clsVogSlave

Load Me
act = False
Set m = master

labMaster.Caption = m.Caption
labPart.Caption = "участок с " & mm2txt(m.trc.mark.white) & " по " & mm2txt(m.trc.mark.black)

mMode(0).Value = IIf(m.vog.Slave.modeShift, 1, 0)
mMode(1).Value = IIf(m.vog.Slave.modeScale, 1, 0)
mMode(2).Value = IIf(m.vog.Slave.modeRotate, 1, 0)

grid.FormatString = "^|^|<|>|>|>|>|>|>"
grid.RowHeight(0) = 600
'установить ширину колонок
grid.Row = 0
setColumn 0, 200, 2, ""
setColumn 1, 200, 2, ""
setColumn 2, 2600, 0, "Запись"
setColumn 3, 1000, 1, "Текущее начало участка"
setColumn 4, 1000, 1, "Новое начало участка"
setColumn 5, 1000, 1, "Текущий конец участка"
setColumn 6, 1000, 1, "Новый конец участка"
setColumn 7, 1000, 1, "Текущая длина"
setColumn 8, 1000, 1, "Новая длина"

btmAction(0).enabled = False
For Each f In Forms
 If f.name = "frmTrace" Then
  If f.trc.vog.enable Then
   Set v = f
   If Not (v.trc.handle = m.trc.handle) Then
    grid.Row = grid.Rows - 1
    grid.RowData(grid.row) = v.trc.handle
    grid.Col = 2
    grid.Text = v.Caption
    grid.Col = 4
    grid.Text = mm2txt(v.trc.mark.white)
    grid.Col = 6
    grid.Text = mm2txt(v.trc.mark.black)
    grid.Col = 8
    grid.Text = mm2txt(v.trc.mark.black - v.trc.mark.white)
    If findSlave(m, v, s) Then
     grid.Col = 0
     grid.Text = "X"
     grid.Col = 1
     grid.CellBackColor = s.color
     grid.Col = 3
     grid.Text = mm2txt(s.mark1)
     grid.Col = 5
     grid.Text = mm2txt(s.mark2)
     grid.Col = 7
     grid.Text = mm2txt(s.mark2 - s.mark1)
     Else
     grid.Col = 1
     grid.CellBackColor = &HFF&
    End If
    grid.Rows = grid.Rows + 1
    btmAction(0).enabled = True
   End If
  End If
 End If
Next

If btmAction(0).enabled Then
 grid.Rows = grid.Rows - 1
 Me.Show 1
 SelSlave = act
 Else
 Unload Me
 ogdWin.Alert "Не найдено открытых записей VOG для совмещения"
 SelSlave = False
End If

End Function

Private Function findSlave( _
master As frmTrace, _
test As frmTrace, _
Slave As clsVogSlave _
) As Boolean

Dim h As Integer, s As clsVogSlave

findSlave = False
h = test.trc.handle
For Each s In master.vog.Slave.trace
 If h = s.traceHandle Then
  findSlave = True
  Set Slave = s
  Exit Function
 End If
Next
End Function

Private Function saveData() As Boolean
Dim i As Integer, h As Long, color As Long, txt As String
Dim vog As frmTrace, s As clsVogSlave

m.vog.Slave.modeShift = IIf(mMode(0).Value = 0, False, True)
m.vog.Slave.modeScale = IIf(mMode(1).Value = 0, False, True)
m.vog.Slave.modeRotate = IIf(mMode(2).Value = 0, False, True)
m.vog.matchMark1 = m.trc.mark.white
m.vog.matchMark2 = m.trc.mark.black

clearCollection m.vog.Slave.trace
For i = 1 To grid.Rows - 1
 If grid.TextMatrix(i, 0) = "X" Then
   h = grid.RowData(i)
   If findTrace(h, vog) Then
    Set s = New clsVogSlave
    grid.Row = i
    grid.Col = 1
    color = grid.CellBackColor
    txt = grid.TextMatrix(i, 2)
    s.Init vog.trc.handle, color, txt, vog.trc.mark.white, vog.trc.mark.black
    m.vog.Slave.trace.Add s
   End If
 End If
Next
saveData = True
End Function

Private Function findTrace(ByRef traceHandle As Long, vog As frmTrace) As Boolean
Dim f As Form

findTrace = False
For Each f In Forms
 If f.name = "frmTrace" Then
  If f.trcCtrl.isVog Then
   If traceHandle = f.trcCtrl.tHandle Then
    Set vog = f
    findTrace = True
    Exit Function
   End If
  End If
 End If
Next
End Function

Private Sub btmAction_Click(Index As Integer)
Select Case Index
 Case 0 'Да
  If saveData() Then
   act = True
   Unload Me
  End If
 Case 1 'Отказ
  Unload Me
End Select
End Sub

Private Sub Form_Load()
hlp.BindHelp Me, KRT_AnaVOGTurnMerge
End Sub

Private Sub grid_Click()
Select Case grid.Col
 Case 1 'цвет
  grid.CellBackColor = ogdWin.selColor(grid.CellBackColor)
 Case Else 'выбор
  grid.Col = 0
  If grid.Text = "" Then
   grid.Text = "X"
   Else
   grid.Text = ""
  End If
End Select
End Sub