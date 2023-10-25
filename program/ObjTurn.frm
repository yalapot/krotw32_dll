VERSION 5.00
Begin VB.Form frmObjTurn 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   7080
   ClientLeft      =   3945
   ClientTop       =   4290
   ClientWidth     =   3960
   Icon            =   "ObjTurn.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7080
   ScaleWidth      =   3960
   ShowInTaskbar   =   0   'False
   Begin VB.ComboBox optType 
      Height          =   315
      Left            =   720
      Style           =   2  'Dropdown List
      TabIndex        =   25
      Top             =   1800
      Width           =   3135
   End
   Begin VB.Frame frameTyp 
      Caption         =   "Тип расчета"
      Height          =   855
      Index           =   1
      Left            =   120
      TabIndex        =   22
      Top             =   2400
      Width           =   3735
      Begin VB.OptionButton OptCalcType 
         Caption         =   "график 3D"
         Height          =   195
         Index           =   1
         Left            =   240
         TabIndex        =   24
         Top             =   480
         Width           =   2055
      End
      Begin VB.OptionButton OptCalcType 
         Caption         =   "привязка к швам"
         Height          =   195
         Index           =   0
         Left            =   240
         TabIndex        =   23
         Top             =   240
         Value           =   -1  'True
         Width           =   1695
      End
   End
   Begin VB.CheckBox chkTuneEnd 
      Caption         =   "поправка конца"
      Height          =   255
      Left            =   2040
      TabIndex        =   4
      Top             =   1320
      Value           =   1  'Checked
      Width           =   1815
   End
   Begin VB.CheckBox chkTuneStart 
      Caption         =   "поправка начала"
      Height          =   255
      Left            =   2040
      TabIndex        =   3
      Top             =   1080
      Value           =   1  'Checked
      Width           =   1815
   End
   Begin VB.CheckBox chkVert 
      Caption         =   "вертикальный"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1320
      Width           =   1815
   End
   Begin VB.CheckBox chkHorz 
      Caption         =   "горизонтальный"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1080
      Width           =   1815
   End
   Begin krotw32.ctrlObjCommon common 
      Height          =   1050
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   3780
      _ExtentX        =   6668
      _ExtentY        =   1852
   End
   Begin VB.CommandButton btmCalc 
      Caption         =   "Пересчет"
      Height          =   495
      Left            =   2040
      TabIndex        =   5
      Top             =   3360
      Width           =   1815
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   480
      TabIndex        =   6
      Top             =   6480
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   2040
      TabIndex        =   7
      Top             =   6480
      Width           =   1215
   End
   Begin VB.Label labangcom 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   30
      Top             =   5160
      Width           =   1815
   End
   Begin VB.Label labradcom 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   29
      Top             =   4920
      Width           =   1815
   End
   Begin VB.Label Label3 
      Caption         =   "Угол общий, гр"
      Height          =   255
      Left            =   120
      TabIndex        =   28
      Top             =   5160
      Width           =   1815
   End
   Begin VB.Label Label2 
      Caption         =   "Радиус общий, м"
      Height          =   255
      Left            =   120
      TabIndex        =   27
      Top             =   4920
      Width           =   1815
   End
   Begin VB.Label Label1 
      Caption         =   "Тип"
      Height          =   255
      Left            =   120
      TabIndex        =   26
      Top             =   1800
      Width           =   495
   End
   Begin VB.Label Lab6 
      Caption         =   "Отметка X, мм"
      Height          =   255
      Left            =   120
      TabIndex        =   21
      Top             =   5640
      Width           =   1815
   End
   Begin VB.Label labmarkx 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   20
      Top             =   5640
      Width           =   1815
   End
   Begin VB.Label Lab7 
      Caption         =   "Отметка Y, мм"
      Height          =   255
      Left            =   120
      TabIndex        =   19
      Top             =   5880
      Width           =   1815
   End
   Begin VB.Label labmarky 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   18
      Top             =   5880
      Width           =   1815
   End
   Begin VB.Label labmarkz 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   17
      Top             =   6120
      Width           =   1815
   End
   Begin VB.Label Lab5 
      Caption         =   "Отметка Z, мм"
      Height          =   255
      Left            =   120
      TabIndex        =   16
      Top             =   6120
      Width           =   1815
   End
   Begin VB.Label labangz 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   15
      Top             =   4680
      Width           =   1815
   End
   Begin VB.Label labradz 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   14
      Top             =   4440
      Width           =   1815
   End
   Begin VB.Label lab4 
      Caption         =   "Угол в Z, гр"
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   4680
      Width           =   1815
   End
   Begin VB.Label lab3 
      Caption         =   "Радиус в Z, м"
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   4440
      Width           =   1815
   End
   Begin VB.Label lab2 
      Caption         =   "Угол в XY, гр"
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   4200
      Width           =   1815
   End
   Begin VB.Label labAngXY 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   10
      Top             =   4200
      Width           =   1815
   End
   Begin VB.Label labRadXY 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   9
      Top             =   3960
      Width           =   1815
   End
   Begin VB.Label lab1 
      Caption         =   "Радиус в XY, м"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   3960
      Width           =   1815
   End
End
Attribute VB_Name = "frmObjTurn"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private cObjInfo As clsobjTurn
Private d_isvog As Boolean
Private d_vog As ctrlVOG
Private prntForm As frmTrace
Private hlp As New clsHelp

Public Sub Edit(prnt As Form, objInfo As clsobjTurn, tfrm As frmTrace, ByVal objDist As Long)
Set cObjInfo = objInfo
Set prntForm = tfrm
Set d_vog = prntForm.vog
hlp.BindHelp Me, KRT_ObjTypeTurn
d_isvog = prntForm.trc.vog.enable
common.Init prntForm.trc, True
common.objectDist = objDist

If Me.Visible Then
 Me.ZOrder
 setControls
 Exit Sub
End If

Load Me
setControls

If prntForm.objDlgLeft = -1 And prntForm.objDlgTop = -1 Then
 centerForm prnt, Me
 Else
 Me.Left = prntForm.objDlgLeft
 Me.Top = prntForm.objDlgTop
End If

Me.Show 0, prnt
End Sub

Private Sub setControls()
Me.Caption = cObjInfo.objCommon.objTyp.name
common.ObjSet cObjInfo.objCommon

chkHorz.Value = IIf(cObjInfo.dHorz, 1, 0)
chkVert.Value = IIf(cObjInfo.dVert, 1, 0)

optType.addItem TurnTypeName(T_TURN_TYPE.NonTech), T_TURN_TYPE.NonTech
optType.addItem TurnTypeName(T_TURN_TYPE.Tech), T_TURN_TYPE.Tech
optType.addItem TurnTypeName(T_TURN_TYPE.Defekt), T_TURN_TYPE.Defekt
optType.addItem TurnTypeName(T_TURN_TYPE.Holod_gnut), T_TURN_TYPE.Holod_gnut
optType.addItem TurnTypeName(T_TURN_TYPE.Krutoizogn), T_TURN_TYPE.Krutoizogn
optType.addItem TurnTypeName(T_TURN_TYPE.Segmentny), T_TURN_TYPE.Segmentny
optType.addItem TurnTypeName(T_TURN_TYPE.Uprugo_plast), T_TURN_TYPE.Uprugo_plast

On Error Resume Next
optType.ListIndex = cObjInfo.dTyp
On Error GoTo 0

chkTuneStart.Value = IIf(cObjInfo.dTuneStart, 1, 0)
chkTuneEnd.Value = IIf(cObjInfo.dTuneEnd, 1, 0)

'If prntForm.trc.drv.IsProfil Then
'   OptCalcType(0).enabled = True
'   OptCalcType(1).enabled = True
'Else
'   OptCalcType(0).Value = True
'   OptCalcType(0).enabled = False
'   OptCalcType(1).enabled = False
'End If

If d_isvog Then

 labRadXY.Caption = angle_label(cObjInfo.dRadXY, prntForm.trc.Diametr)
 labAngXY.Caption = rad2degree(cObjInfo.dAnglXY)
 labradz.Caption = angle_label(cObjInfo.dRadZ, prntForm.trc.Diametr)
 labangz.Caption = rad2degree(cObjInfo.dAnglZ)
 labMarkZ.Caption = cObjInfo.dMarkZ
 labMarkX.Caption = cObjInfo.dMarkX
 labMarkY.Caption = cObjInfo.dMarkY
 
 OptCalcType(cObjInfo.dCalctyp).Value = True
 labangcom.Caption = rad2degree(cObjInfo.dAngl3D)
 labradcom.Caption = angle_label(cObjInfo.dRad3D, prntForm.trc.Diametr)
 
 Else
 
 lab1.visible = False
 lab2.visible = False
 lab3.visible = False
 lab4.visible = False
 Lab5.visible = False
 Lab6.visible = False
 Lab7.visible = False
 Label2.visible = False
 Label3.visible = False
 labRadXY.visible = False
 labAngXY.visible = False
 labradz.visible = False
 labangz.visible = False
 labradcom.visible = False
 labangcom.visible = False
 labmarkx.visible = False
 labmarky.visible = False
 labmarkz.visible = False
 btmCalc.visible = False

End If
End Sub

Private Sub getControls()
common.ObjGet cObjInfo.objCommon
End Sub

Private Sub btmAct_Click(Index As Integer)
Dim s As String

Select Case Index
 Case 0 'сохранить
  getControls
  cObjInfo.dTyp = optType.ListIndex
  prntForm.trc.db.dfltTurnType = cObjInfo.dTyp
  prntForm.setObjTurn cObjInfo, common.objectDist
  prntForm.objDlgLeft = Me.Left
  prntForm.objDlgTop = Me.Top
  addToHistory prntForm.trc, common.comboComment
  Unload Me
 Case 1 'отказ
  Unload Me
End Select
End Sub

Private Sub btmCalc_Click()
getControls
cObjInfo.reCalc d_vog, cfg.vog.turnHor, cfg.vog.turnVer, IIf(OptCalcType(0).Value, 0, 1)
setControls
prntForm.setMarkGroup cObjInfo.objCommon.objDist, cObjInfo.objCommon.objDist + cObjInfo.dLength
End Sub

Private Sub chkHorz_Click()
cObjInfo.dHorz = IIf((chkHorz.Value = 1), True, False)
End Sub

Private Sub chkTuneEnd_Click()
cObjInfo.dTuneEnd = IIf((chkTuneEnd.Value = 1), True, False)
End Sub

Private Sub chkTuneStart_Click()
cObjInfo.dTuneStart = IIf((chkTuneStart.Value = 1), True, False)
End Sub

Private Sub chkVert_Click()
cObjInfo.dVert = IIf((chkVert.Value = 1), True, False)
End Sub