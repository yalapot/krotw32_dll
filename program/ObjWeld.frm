VERSION 5.00
Begin VB.Form frmObjWeld 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   5625
   ClientLeft      =   1635
   ClientTop       =   1440
   ClientWidth     =   3900
   Icon            =   "ObjWeld.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5625
   ScaleWidth      =   3900
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox txtTubeNum 
      Height          =   285
      Left            =   1440
      TabIndex        =   18
      Text            =   "Text1"
      Top             =   1680
      Width           =   2415
   End
   Begin VB.Frame FrameAngle 
      Caption         =   "Углы"
      Height          =   1695
      Left            =   120
      TabIndex        =   10
      Top             =   3240
      Width           =   3735
      Begin VB.CheckBox chkAngle 
         Alignment       =   1  'Right Justify
         Caption         =   "стык, град."
         Height          =   255
         Left            =   120
         TabIndex        =   16
         Top             =   840
         Width           =   1815
      End
      Begin VB.CheckBox chkCurve 
         Alignment       =   1  'Right Justify
         Caption         =   "изгиб, град."
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   600
         Width           =   1815
      End
      Begin VB.CheckBox chkComplex 
         Alignment       =   1  'Right Justify
         Caption         =   "Комплексный"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   240
         Width           =   1815
      End
      Begin krotw32.ctrlAnglUnit angAngle 
         Height          =   330
         Left            =   2040
         TabIndex        =   14
         Top             =   840
         Visible         =   0   'False
         Width           =   1455
         _ExtentX        =   2566
         _ExtentY        =   582
      End
      Begin krotw32.ctrlAnglUnit angCurve 
         Height          =   330
         Left            =   2040
         TabIndex        =   13
         Top             =   480
         Visible         =   0   'False
         Width           =   1455
         _ExtentX        =   2566
         _ExtentY        =   582
      End
      Begin VB.CommandButton btmRecalc 
         Caption         =   "Пересчет"
         Height          =   375
         Left            =   120
         TabIndex        =   11
         Top             =   1200
         Width           =   1815
      End
   End
   Begin VB.Frame FrameSlit 
      Caption         =   "Продольные швы "
      Height          =   1215
      Left            =   120
      TabIndex        =   4
      Top             =   2040
      Width           =   3735
      Begin krotw32.ctrlSlit weld 
         Height          =   405
         Index           =   0
         Left            =   120
         TabIndex        =   5
         Top             =   240
         Width           =   3525
         _ExtentX        =   6218
         _ExtentY        =   714
      End
      Begin krotw32.ctrlSlit weld 
         Height          =   405
         Index           =   1
         Left            =   120
         TabIndex        =   6
         Top             =   720
         Width           =   3525
         _ExtentX        =   6218
         _ExtentY        =   714
      End
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   600
      TabIndex        =   0
      Top             =   5040
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   2160
      TabIndex        =   1
      Top             =   5040
      Width           =   1215
   End
   Begin VB.ComboBox tubeType 
      Height          =   315
      Left            =   120
      Style           =   2  'Dropdown List
      TabIndex        =   3
      ToolTipText     =   "Тип дефекта для записи в базу"
      Top             =   1320
      Width           =   3735
   End
   Begin krotw32.ctrlObjCommon common 
      Height          =   1050
      Left            =   120
      TabIndex        =   2
      Top             =   0
      Width           =   3780
      _ExtentX        =   6668
      _ExtentY        =   1852
   End
   Begin VB.Label Label1 
      Caption         =   "Номер трубы"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   17
      Top             =   1680
      Width           =   1215
   End
   Begin VB.Label labLength 
      Caption         =   "Label2"
      Height          =   255
      Left            =   2280
      TabIndex        =   9
      Top             =   1080
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Длина"
      Height          =   255
      Index           =   1
      Left            =   1320
      TabIndex        =   8
      Top             =   1080
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Тип трубы"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   7
      Top             =   1080
      Width           =   1215
   End
End
Attribute VB_Name = "frmObjWeld"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private cObjInfo As clsObjWeld
Private fTrace As frmTrace
Private WithEvents Coroz As ctrlCrzZones
Attribute Coroz.VB_VarHelpID = -1
Private pickUpIndex As Integer
Private initFlag As Boolean
Private objCurve As New clsAnglUnit
Private objAngle As New clsAnglUnit
Private hlp As New clsHelp

Public Sub Edit(prnt As Form, objInfo As clsObjWeld, frm As frmTrace, ByVal objDist As Long, Optional ByVal selectWeld As Boolean = False)
Dim typ As clsObjType

initFlag = True
Set cObjInfo = objInfo
Set fTrace = frm
Set Coroz = frm.Coroz
hlp.BindHelp Me, KRT_ObjTypeWeld
common.Init fTrace.trc, True
common.objectDist = objDist
pickUpIndex = 0

If Me.Visible Then
 Me.ZOrder
 setControls
 Exit Sub
End If

Load Me

With tubeType
For Each typ In frm.trc.db.objTypes
 If (typ.off = False) And (typ.tbl = OBJ_TBL_WELD) Then
  .addItem typ.name
  .ItemData(.ListCount - 1) = typ.id
 End If
Next
End With

setControls

If fTrace.objDlgLeft = -1 And fTrace.objDlgTop = -1 Then
 centerForm prnt, Me
 Else
 Me.Left = fTrace.objDlgLeft
 Me.Top = fTrace.objDlgTop
End If

initFlag = False
Me.Show 0, prnt

If selectWeld Then weld(0).selectSlit
End Sub

Private Sub setControls()

Me.Caption = cObjInfo.objCommon.objTyp.name
labLength.Caption = mm2txt(fTrace.trc.getLenKoef(cObjInfo.objCommon.objDist, cObjInfo.tubeLength)) & " м."

weld(0).isPresent = IIf(cObjInfo.weld1 < 0, False, True)
weld(0).fullHour = IIf(cObjInfo.weld1 < 0, 0, cObjInfo.weld1)

weld(1).isPresent = IIf(cObjInfo.weld2 < 0, False, True)
weld(1).fullHour = IIf(cObjInfo.weld2 < 0, 0, cObjInfo.weld2)

txtTubeNum.Text = cObjInfo.tube_number

setLst tubeType, cObjInfo.objCommon.objTyp.id
setAngle
End Sub

Private Sub setAngle()
If fTrace.trc.vog.enable Then
 objCurve.fullHour = cObjInfo.curve
 objAngle.fullHour = cObjInfo.angle

 chkCurve.Value = IIf(objCurve.fullHour = -1, 0, 1)
 chkCurve_Click
 chkAngle.Value = IIf(objAngle.fullHour = -1, 0, 1)
 chkAngle_Click
 chkComplex.Value = IIf(cObjInfo.curveComplex, 1, 0)
 'chkComplex_Click
 FrameAngle.Visible = True

 Else
 FrameAngle.Visible = False
End If
End Sub

Private Sub btmRecalc_Click()
cObjInfo.reCalcAngle fTrace.trc
setAngle
End Sub

Private Sub chkAngle_Click()
If (chkAngle.Value = 0) Then 'Or (objAngle.fullHour = -1) Then
 angAngle.Visible = False
 objAngle.fullHour = -1
 Else
 'If (objAngle.fullHour = -1) Then MsgBox "Будьте осторожны с изменением этого значения!", vbOKOnly, "Внимание!"
 angAngle.Visible = True
 angAngle.setValue objAngle
 chkComplex.Value = 0
End If
End Sub

Private Sub chkComplex_Click()
chkAngle.Value = IIf(chkComplex.Value = 0, 1, 0)
End Sub

Private Sub chkCurve_Click()
If (chkCurve.Value = 0) Then
 angCurve.Visible = False
 objCurve.fullHour = -1
 Else
 angCurve.Visible = True
 angCurve.setValue objCurve
End If
End Sub

Private Sub Coroz_pickUpWeld(ByVal fullHour As Double)
Dim i As Integer

weld(pickUpIndex).fullHour = fullHour
Coroz.pickUpWeld = False
Me.SetFocus
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
'Debug.Print "Form_KeyDown", " ", KeyCode, " ", Shift
' CapsLock
If KeyCode = 20 Then
  btmAct_Click 0
End If
End Sub

Private Sub Form_Load()
angCurve.typ = A_DEGREE
angAngle.typ = A_DEGREE
End Sub

Private Sub tubeType_Click()
With cObjInfo.objCommon
.objTyp.Init _
  tubeType.ItemData(tubeType.ListIndex), _
  tubeType.List(tubeType.ListIndex), _
  .objTyp.off, _
  .objTyp.tbl
.Init fTrace.trc, .objDist, .objLen, .comment, .isAttention, .objTyp

Select Case .objTyp.id
 Case OBJ_shov_b
  FrameSlit.Visible = False
 Case OBJ_shov_p
  FrameSlit.Visible = True
  weld_Change 0
 Case OBJ_shov_s
  FrameSlit.Visible = True
  weld(0).Caption = "Начало"
  weld(1).Caption = "Конец"
End Select

End With
common.ObjSet cObjInfo.objCommon
End Sub

Private Sub getControls()
Dim x1 As Integer, x2 As Integer

common.ObjGet cObjInfo.objCommon

If cObjInfo.objCommon.objTyp.id = OBJ_shov_p Then
 x1 = getFirstWeldIndex()
 If x1 < 0 Then x1 = 0
 x2 = IIf(x1 = 0, 1, 0)
Else
 x1 = 0
 x2 = 1
End If

cObjInfo.weld1 = weld(x1).fullHour
cObjInfo.weld2 = weld(x2).fullHour
cObjInfo.curveComplex = IIf(chkComplex.Value = 0, False, True)
cObjInfo.angle = objAngle.fullHour
cObjInfo.curve = objCurve.fullHour
cObjInfo.tube_number = txtTubeNum.Text
End Sub

Private Sub btmAct_Click(Index As Integer)
Dim s As String

Select Case Index
 Case 0 'сохранить
  getControls
  fTrace.setObjWeld cObjInfo, common.objectDist
  addToHistory fTrace.trc, common.comboComment
  fTrace.objDlgLeft = Me.Left
  fTrace.objDlgTop = Me.Top
 Case 1 'отказ
End Select
Unload Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
Coroz.pickUpWeld = False
End Sub

Private Sub weld_Change(Index As Integer)
Dim x1 As Integer, x2 As Integer
Dim fullHour As Double

If cObjInfo.objCommon.objTyp.id <> OBJ_shov_p Then Exit Sub

x1 = getFirstWeldIndex()
If x1 < 0 Then Exit Sub
x2 = IIf(x1 = 0, 1, 0)

fullHour = weld(x1).fullHour + 6
If fullHour >= 12 Then fullHour = fullHour - 12
weld(x2).fullHour = fullHour

weld(x1).Caption = "Первый"
weld(x2).Caption = "Второй"
End Sub

Private Function getFirstWeldIndex() As Integer
getFirstWeldIndex = -1
If weld(0).isPresent Then
 If weld(1).isPresent Then
  If weld(0).fullHour < weld(1).fullHour Then
   getFirstWeldIndex = 0
  Else
   getFirstWeldIndex = 1
  End If
 Else
  getFirstWeldIndex = 0
 End If
Else
 If weld(1).isPresent Then
  getFirstWeldIndex = 1
 End If
End If
End Function

Private Sub weld_pickUp(Index As Integer)
If initFlag Then Exit Sub
pickUpIndex = Index
Coroz.pickUpWeld = True
End Sub