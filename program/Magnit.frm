VERSION 5.00
Begin VB.Form frmMagnit 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   7200
   ClientLeft      =   5715
   ClientTop       =   2700
   ClientWidth     =   9870
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7200
   ScaleWidth      =   9870
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame2 
      Caption         =   "Порог затухания по ширине"
      Height          =   975
      Left            =   5280
      TabIndex        =   17
      Top             =   1080
      Width           =   4455
      Begin VB.OptionButton optDfktWidth 
         Caption         =   "Уровень в единицах АЦП"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   20
         Top             =   600
         Width           =   2775
      End
      Begin VB.OptionButton optDfktWidth 
         Caption         =   "Процент от макс.всплеска"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   19
         Top             =   240
         Width           =   2535
      End
      Begin krotw32.multyNum lowDfktPrcnt 
         Height          =   255
         Left            =   2880
         TabIndex        =   18
         Top             =   240
         Width           =   1380
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin krotw32.multyNum lowDfktADC 
         Height          =   255
         Left            =   2880
         TabIndex        =   21
         Top             =   600
         Width           =   1380
         _ExtentX        =   2514
         _ExtentY        =   450
      End
   End
   Begin VB.TextBox txtID 
      Height          =   285
      Left            =   120
      TabIndex        =   16
      Text            =   "Text1"
      Top             =   240
      Width           =   4815
   End
   Begin VB.Frame Frame1 
      Caption         =   "Набор кривых"
      Height          =   615
      Left            =   120
      TabIndex        =   11
      Top             =   1320
      Width           =   4815
      Begin VB.OptionButton crv 
         Caption         =   "канавки"
         Height          =   255
         Index           =   2
         Left            =   2760
         TabIndex        =   22
         Top             =   200
         Width           =   1215
      End
      Begin VB.OptionButton crv 
         Caption         =   "диаметра"
         Height          =   255
         Index           =   1
         Left            =   1440
         TabIndex        =   13
         Top             =   200
         Width           =   1215
      End
      Begin VB.OptionButton crv 
         Caption         =   "глубины"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   12
         Top             =   200
         Width           =   1095
      End
   End
   Begin krotw32.ctrlMagnCurves curveView 
      Height          =   4335
      Index           =   0
      Left            =   120
      TabIndex        =   10
      Top             =   2160
      Width           =   9615
      _ExtentX        =   16960
      _ExtentY        =   7646
   End
   Begin krotw32.ctrlNumBox txtKF2 
      Height          =   255
      Left            =   8160
      TabIndex        =   9
      Top             =   360
      Width           =   1575
      _ExtentX        =   2778
      _ExtentY        =   450
   End
   Begin krotw32.ctrlNumBox txtKF1 
      Height          =   255
      Left            =   5880
      TabIndex        =   8
      Top             =   360
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   450
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Печать"
      Height          =   375
      Index           =   2
      Left            =   3720
      TabIndex        =   4
      ToolTipText     =   "Загрузить данные из файла таймерных маркеров в таблицу и рассчитать дистанции"
      Top             =   6720
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.TextBox txtDesc 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   840
      Width           =   4815
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Отказ"
      Height          =   375
      Index           =   1
      Left            =   2040
      TabIndex        =   3
      ToolTipText     =   "Загрузить данные из файла таймерных маркеров в таблицу и рассчитать дистанции"
      Top             =   6720
      Width           =   1095
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   375
      Index           =   0
      Left            =   360
      TabIndex        =   1
      ToolTipText     =   "Загрузить данные из файла таймерных маркеров в таблицу и рассчитать дистанции"
      Top             =   6720
      Width           =   1095
   End
   Begin krotw32.ctrlMagnCurves curveView 
      Height          =   4335
      Index           =   1
      Left            =   120
      TabIndex        =   14
      Top             =   2400
      Visible         =   0   'False
      Width           =   9615
      _ExtentX        =   16960
      _ExtentY        =   7646
   End
   Begin krotw32.ctrlMagnCurves curveView 
      Height          =   4335
      Index           =   2
      Left            =   120
      TabIndex        =   23
      Top             =   2400
      Visible         =   0   'False
      Width           =   9615
      _ExtentX        =   16960
      _ExtentY        =   7646
   End
   Begin VB.Label labID 
      Caption         =   "Идентификатор магнитной системы"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   15
      Top             =   0
      Width           =   4815
   End
   Begin VB.Label Label1 
      Caption         =   "Наименование магнитной системы"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   2
      Top             =   600
      Width           =   4815
   End
   Begin VB.Label Label2 
      Caption         =   "K2"
      Height          =   255
      Index           =   1
      Left            =   7680
      TabIndex        =   7
      Top             =   360
      Width           =   495
   End
   Begin VB.Label Label2 
      Caption         =   "K1"
      Height          =   255
      Index           =   0
      Left            =   5280
      TabIndex        =   6
      Top             =   360
      Width           =   495
   End
   Begin VB.Label Label1 
      Caption         =   "Коэф-нты пересчета единиц АЦП в миллитесла"
      Height          =   255
      Index           =   0
      Left            =   5280
      TabIndex        =   5
      Top             =   0
      Width           =   4455
   End
End
Attribute VB_Name = "frmMagnit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private mgn As New clsMagnit
Private magnitOriginal As clsMagnit
Private xarr As New XArrayDB
Private hlp As New clsHelp
Private parentForm As Form

Public Sub Edit( _
magnit As clsMagnit, _
capt As String, _
prnt As Form, _
isNew As Boolean _
)
Set magnitOriginal = magnit
mgn.copyFrom magnitOriginal
Load Me
hlp.BindHelp Me, KRT_CfgDriverMagnet
Me.Caption = capt
Me.Icon = prnt.Icon
Set parentForm = prnt
setControls isNew
centerForm prnt, Me
Me.Show 0, prnt
End Sub

Private Sub setControls(isNew As Boolean)
txtID.Text = mgn.id
txtID.enabled = isNew
txtDesc.Text = mgn.Description
txtKF1.dbl = mgn.teslaK1
txtKF2.dbl = mgn.teslaK2

lowDfktPrcnt.Value = mgn.lowDefektResponsePrcnt

lowDfktADC.Min = 0
lowDfktADC.Max = 3993
lowDfktADC.Value = mgn.dfktWidthADC

optDfktWidth(mgn.dfktWidthMode).Value = True

curveView(0).Bind _
 Me, _
 mgn.prcnt, _
 False, _
 "определение глубины для диаметра", _
 "Расчетный %", "Действительный %", _
 "Кривая расчета глубины дефекта", _
 "Расчетный %", _
 "Действительный %", _
 False

curveView(1).Bind _
 Me, _
 mgn.diam, _
 False, _
 "приведенный диаметр", _
 "Изменение поля, %%", "Размер, мм2", _
 "Кривая уточнения диаметра дефекта", _
 "Изменение поля, %%", _
 "Размер, мм2", _
 True

curveView(2).Bind _
 Me, _
 mgn.slit, _
 False, _
 "расчет канавок", _
 "Расчетный %", "Действительный %", _
 "Кривая расчета глубины канавки", _
 "Расчетный %", _
 "Действительный %", _
 False

crv(0).Value = True
End Sub

Private Function getControls() As Boolean
getControls = False
If txtID.enabled Then
 If Len(txtID.Text) = 0 Then
   ogdWin.Alert "Не указан ID магнитной системы"
   Exit Function
 End If
 mgn.setID txtID.Text
End If
mgn.Description = txtDesc.Text
mgn.teslaK1 = txtKF1.dbl
mgn.teslaK2 = txtKF2.dbl
mgn.lowDefektResponsePrcnt = lowDfktPrcnt.Value
mgn.dfktWidthADC = lowDfktADC.Value
mgn.dfktWidthMode = IIf(optDfktWidth(0).Value = True, 0, 1)

curveView(0).FixData
curveView(1).FixData
curveView(2).FixData
getControls = True
End Function

Private Sub btmAct_Click(Index As Integer)
Dim fz As frmZoom

Select Case Index

 Case 2 'печать
 Exit Sub
 
 Case 0
 If getControls() = False Then Exit Sub
 magnitOriginal.copyFrom mgn
 If TypeName(parentForm) = "frmZoom" Then
   Set fz = parentForm
   fz.SaveLocalMagnetSystem
   'Debug.Print "SaveLocalMagnetSystem"
 End If
 
 On Error Resume Next
 parentForm.magnetEdit_Callback
 On Error GoTo 0

End Select
Unload Me
End Sub

Private Sub crv_Click(Index As Integer)
Select Case Index

 Case 0
  curveView(0).visible = True
  curveView(1).visible = False
  curveView(2).visible = False
  
 Case 1
  curveView(0).visible = False
  curveView(1).visible = True
  curveView(2).visible = False
  
 Case Else
  curveView(0).visible = False
  curveView(1).visible = False
  curveView(2).visible = True

End Select
End Sub
