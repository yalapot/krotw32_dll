VERSION 5.00
Begin VB.Form frmInterval 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Задайте интервал просмотра"
   ClientHeight    =   2115
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4110
   Icon            =   "interval.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2115
   ScaleWidth      =   4110
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin krotw32.ctrlNumBox valEnd 
      Height          =   255
      Left            =   2160
      TabIndex        =   1
      Top             =   480
      Width           =   1815
      _extentx        =   3201
      _extenty        =   450
   End
   Begin krotw32.ctrlNumBox valStart 
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   480
      Width           =   1815
      _extentx        =   3201
      _extenty        =   450
   End
   Begin VB.CommandButton btmNo 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Left            =   2160
      TabIndex        =   3
      Top             =   1560
      Width           =   1335
   End
   Begin VB.CommandButton btmYes 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Left            =   600
      TabIndex        =   2
      Top             =   1560
      Width           =   1335
   End
   Begin krotw32.ctrlNumBox valStep 
      Height          =   255
      Left            =   1080
      TabIndex        =   6
      Top             =   1080
      Visible         =   0   'False
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   450
   End
   Begin VB.Label odoStep 
      Alignment       =   1  'Right Justify
      Caption         =   "Label1"
      Height          =   255
      Left            =   1080
      TabIndex        =   7
      Top             =   840
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Label odoEnd 
      Alignment       =   1  'Right Justify
      Caption         =   "Label1"
      Height          =   255
      Left            =   2160
      TabIndex        =   5
      Top             =   120
      Width           =   1815
   End
   Begin VB.Label odoStart 
      Alignment       =   1  'Right Justify
      Caption         =   "Label1"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   1815
   End
End
Attribute VB_Name = "frmInterval"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Enum INTERVAL_MODE
 IMODE_MM
 IMODE_INT
End Enum

Private mode As INTERVAL_MODE
Private retCode As Boolean
Private val1 As Long
Private val2 As Long
Private val3 As Long
Private hlp As New clsHelp

Public Function setMarkers( _
prntForm As Form, _
ByRef mWhite As Long, _
ByRef mBlack As Long, _
trc As clsTrace _
) As Boolean

val1 = trc.getDistKoef(mWhite)
val2 = trc.getDistKoef(mBlack)
mode = IMODE_MM
Load Me
Me.Icon = prntForm.Icon
centerForm prntForm, Me
Me.Caption = "Задайте положение маркеров"
Me.odoStart.Caption = "Белый"
Me.odoEnd.Caption = "Черный"
valStart.mm = val1
valEnd.mm = val2
retCode = False
Me.Show 1
mWhite = trc.getDistReal(val1)
mBlack = trc.getDistReal(val2)
setMarkers = retCode
End Function

Public Function getShift( _
prntForm As Form, _
ByRef vStart As Long, _
ByRef vLength As Long _
) As Boolean

mode = IMODE_MM
Load Me
Me.Icon = prntForm.Icon
Me.Caption = "Сдвиг обьектов"
centerForm prntForm, Me
Me.odoStart.Caption = "Начало сдвига, м"
Me.odoEnd.Caption = "Величина сдвига, м"
valStart.mm = vStart
valEnd.mm = vLength
retCode = False
Me.Show 1
vStart = val1
vLength = val2
getShift = retCode
End Function

Public Function IntervalCommon( _
prntForm As Form, _
ByVal tStart As Long, _
ByVal tEnd As Long, _
ByRef vStart As Long, _
ByRef vEnd As Long, _
Optional ByVal capt As String = "Задайте интервал просмотра" _
) As Boolean

mode = IMODE_INT
Load Me
Me.Icon = prntForm.Icon
Me.Caption = capt
centerForm prntForm, Me
Me.odoStart.Caption = tStart
Me.odoEnd.Caption = tEnd
valStart.intgr = vStart
valEnd.intgr = vEnd
retCode = False
Me.Show 1
vStart = val1
vEnd = val2
IntervalCommon = retCode
End Function

Public Function getDist( _
prntForm As Form, _
ByVal capt As String, _
ByVal msg As String, _
ByVal dflt As Long _
) As Long

mode = IMODE_MM
Me.Caption = capt
odoStart.Caption = msg
odoEnd.visible = False
valEnd.visible = False
odoStart.width = odoEnd.Left + odoEnd.width
valStart.width = valEnd.Left + valEnd.width
valStart.mm = dflt

Load Me
Me.Icon = prntForm.Icon
centerForm prntForm, Me
retCode = False

Me.Show 1

getDist = IIf(retCode, val1, dflt)
End Function

Public Function Interval( _
prntForm As Form, _
ByVal tStart As Long, _
ByVal tEnd As Long, _
ByRef vStart As Long, _
ByRef vEnd As Long, _
trc As clsTrace _
) As Boolean

mode = IMODE_MM
val1 = trc.getDistKoef(vStart)
val2 = trc.getDistKoef(vEnd)
Load Me
Me.Icon = prntForm.Icon
centerForm prntForm, Me
Me.odoStart.Caption = mm2txt(trc.getDistKoef(tStart))
Me.odoEnd.Caption = mm2txt(trc.getDistKoef(tEnd))
valStart.mm = val1
valEnd.mm = val2
retCode = False
Me.Show 1
vStart = trc.getDistReal(val1)
vEnd = trc.getDistReal(val2)
Interval = retCode
End Function

Public Function IntervalVOG( _
ByVal tStart As Long, _
ByVal tEnd As Long, _
ByRef vStart As Long, _
ByRef vEnd As Long, _
ByRef vStep As Long, _
trc As clsTrace _
) As Boolean

mode = IMODE_MM
Me.Caption = "Экспорт данных VOG с учетом таблицы поправок"
val1 = trc.getDistKoef(vStart)
val2 = trc.getDistKoef(vEnd)
val3 = vStep
Load Me
Me.odoStart.Caption = mm2txt(trc.getDistKoef(tStart))
Me.odoEnd.Caption = mm2txt(trc.getDistKoef(tEnd))
valStart.mm = val1
valEnd.mm = val2
valStep.mm = val3
odoStep.Caption = "шаг в метрах"
odoStep.visible = True
valStep.visible = True
retCode = False
Me.Show 1
vStart = trc.getDistReal(val1)
vEnd = trc.getDistReal(val2)
vStep = val3
IntervalVOG = retCode
End Function

Private Sub btmNo_Click()
Unload Me
End Sub

Private Sub btmYes_Click()

On Error GoTo BAD1
Select Case mode
 Case IMODE_MM
  val1 = valStart.mm
 Case IMODE_INT
  val1 = valStart.intgr
End Select

On Error GoTo BAD2
Select Case mode
 Case IMODE_MM
  val2 = valEnd.mm
 Case IMODE_INT
  val2 = valEnd.intgr
End Select

On Error GoTo BAD3
Select Case mode
 Case IMODE_MM
  val3 = valStep.mm
 Case IMODE_INT
  val3 = valStep.intgr
End Select

On Error GoTo 0
retCode = True
Unload Me
Exit Sub

BAD1:
 ogdWin.Alert "Неверное значение первого параметра"
 On Error GoTo 0
 valStart.SetFocus
 Exit Sub
BAD2:
 ogdWin.Alert "Неверное значение второго параметра"
 On Error GoTo 0
 valEnd.SetFocus
 Exit Sub
BAD3:
 ogdWin.Alert "Неверное значение третьего параметра"
 On Error GoTo 0
 valStep.SetFocus
 Exit Sub
End Sub

Private Sub Form_Load()
hlp.BindHelp Me, KRT_AnaVOGView
End Sub

Private Sub valStart_GotFocus()
valStart.selText
End Sub

Private Sub valEnd_GotFocus()
valEnd.selText
End Sub