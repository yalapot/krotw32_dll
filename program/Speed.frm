VERSION 5.00
Object = "{C643EB3F-235C-4181-9B55-36A268833718}#7.0#0"; "olch2x7.ocx"
Begin VB.Form frmSpeed 
   Caption         =   "Form1"
   ClientHeight    =   3225
   ClientLeft      =   1905
   ClientTop       =   1995
   ClientWidth     =   7320
   Icon            =   "Speed.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   3225
   ScaleWidth      =   7320
   Begin C1Chart2D7.Chart2D speed 
      Height          =   2175
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   7095
      _Version        =   458752
      _Revision       =   4
      _ExtentX        =   12515
      _ExtentY        =   3836
      _StockProps     =   0
      ControlProperties=   "Speed.frx":0442
   End
   Begin VB.Label labCurVal 
      Height          =   255
      Left            =   4920
      TabIndex        =   4
      Top             =   0
      Width           =   1095
   End
   Begin VB.Label labCurDist 
      Height          =   255
      Left            =   2880
      TabIndex        =   3
      Top             =   0
      Width           =   1095
   End
   Begin VB.Label Label1 
      Caption         =   "значение"
      Height          =   255
      Index           =   5
      Left            =   4080
      TabIndex        =   2
      Top             =   0
      Width           =   735
   End
   Begin VB.Label Label1 
      Caption         =   "Текущая отметка (м)"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   1
      Top             =   0
      Width           =   2775
   End
   Begin VB.Menu context_menu 
      Caption         =   "Контекст"
      Visible         =   0   'False
      Begin VB.Menu context_mnu 
         Caption         =   "Настройки"
         Index           =   0
      End
      Begin VB.Menu context_mnu 
         Caption         =   "Напечатать"
         Index           =   1
      End
      Begin VB.Menu context_mnu 
         Caption         =   "Изображение в буфер обмена"
         Index           =   2
      End
      Begin VB.Menu context_mnu 
         Caption         =   "График на всю запись"
         Index           =   3
      End
   End
End
Attribute VB_Name = "frmSpeed"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private config As frmExpressSettings
Private hlp As New clsHelp
Private popupMenuItem As Integer
Private popupMenuFlag As Boolean
Private lastMouseDownX As Double
Private lastMouseDownY As Double
Private minWidth As Single
Private minHeight As Single

Public initFlag As Boolean

Public Event goDist(ByVal dst As Long)

Public Sub Init(trace As clsTrace)
hlp.BindHelp Me, KRT_AnaFullGraph
Set config = New frmExpressSettings
config.Init Me, trace
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
Dim fwd As Boolean

Select Case KeyCode
 Case VK_PGDN
  fwd = True
 Case VK_PGUP
  fwd = False
 Case Else
  Exit Sub
End Select

config.pageShift fwd
End Sub

Private Sub Form_Load()
minWidth = 7425 'Me.width
minHeight = 4230 'Me.Height
Me.width = minWidth
Me.Height = minHeight
initFlag = True
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.visible = False
 Else
 Unload config
End If
End Sub

Private Sub Form_Resize()
Static intFlag As Boolean

If intFlag Then Exit Sub
intFlag = True
If Me.WindowState = vbMinimized Then Exit Sub

If Me.width < minWidth Then Me.width = minWidth
If Me.Height < minHeight Then Me.Height = minHeight

speed.width = Me.ScaleWidth - speed.Left - 100
speed.Height = Me.ScaleHeight - speed.Top - 100

intFlag = False
End Sub

Private Sub speed_DblClick()
Dim dataX As Double, dataY As Double, x As Long, y As Long

x = lastMouseDownX / Screen.twipsPerPixelX
y = lastMouseDownY / Screen.twipsPerPixelY
speed.ChartGroups(1).CoordToDataCoord x, y, dataX, dataY

If dataX < config.traceStart Or _
   dataX > config.traceEnd Then Exit Sub

dataX = config.trc.getDistReal(dataX)
RaiseEvent goDist(dataX)
End Sub

Private Sub speed_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
Select Case Button

 Case 1 'левая клавиша мыши
   lastMouseDownX = x
   lastMouseDownY = y

 Case 2 'щелкнули правой кнопкой мыши
   popContextMenu
  
End Select
End Sub

Private Sub popContextMenu()
popupMenuFlag = True
popupMenuItem = -1

Me.popUpMenu Context_menu
popupMenuFlag = False
If popupMenuItem >= 0 Then
 context_mnu_Click popupMenuItem
 popupMenuItem = -1
End If
End Sub

Private Sub context_mnu_Click(Index As Integer)
If popupMenuFlag Then
 popupMenuItem = Index
 Exit Sub
End If

If Me.speed.visible = False Then Exit Sub

Select Case Index

  Case 0 'настройки
    config.Show 0, frmMain

  Case 1 'печать
    speed.PrintChart oc2dFormatEnhMetafile, oc2dScaleToMax, 0, 0, 0, 0

  Case 2 'буфер
    speed.CopyToClipboard oc2dFormatEnhMetafile

  Case 3 'полный
    config.full_graph
    
End Select

End Sub

Private Sub speed_mouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim pixwidth As Long, pixheight As Long
Dim dataX As Double, dataY As Double

x = x / Screen.twipsPerPixelX
y = y / Screen.twipsPerPixelY
speed.ChartGroups(1).CoordToDataCoord x, y, dataX, dataY

If dataX > config.trc.length Then dataX = config.trc.length
If dataX < 0 Then dataX = 0

labCurDist.Caption = mm2txt(dataX)
If dataY < config.grf.valMin Then dataY = config.grf.valMin
labCurVal.Caption = Format$(dataY * config.multKoef / 100#, "0.00")
End Sub

Private Sub speed_PlotAreaModify(ByVal IsReset As Boolean, Left As Long, Right As Long, Top As Long, Bottom As Long, IsOK As Boolean)
'запретить перемещение графика
IsOK = False
End Sub

Private Sub speed_ZoomAxisModify(XAxisMin As Double, XAxisMax As Double, YAxisMin As Double, YAxisMax As Double, Y2AxisMin As Double, Y2AxisMax As Double, IsOK As Boolean)
config.grf.Xmin = XAxisMin
config.grf.Xmax = XAxisMax
config.setXtexts
YAxisMin = config.grf.Ymin
YAxisMax = config.grf.Ymax
End Sub

Public Sub changeSettings()
config.changeSettings
End Sub

Public Sub showGraph()
config.showGraph
If initFlag Then
  config.Show 0, frmMain
End If
End Sub

Public Sub mouseMove(ByVal dst As Long)
Dim dataX As Double

dataX = config.trc.getDistKoef(dst)
speed.ChartArea.Markers("X").Value.x = dataX
End Sub

