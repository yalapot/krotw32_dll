VERSION 5.00
Begin VB.Form frmObjDefekt 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   3960
   ClientLeft      =   5625
   ClientTop       =   2955
   ClientWidth     =   3960
   Icon            =   "ObjDfkt.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3960
   ScaleWidth      =   3960
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox txtValMin 
      Height          =   285
      Left            =   1560
      TabIndex        =   15
      Text            =   "Text1"
      ToolTipText     =   "Минимальный процент глубины дефекта"
      Top             =   2160
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.ComboBox lstInsType 
      Height          =   315
      Left            =   120
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   1560
      Width           =   1455
   End
   Begin krotw32.ctrlAnglUnit orntE 
      Height          =   330
      Left            =   2400
      TabIndex        =   9
      Top             =   2880
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   582
   End
   Begin krotw32.ctrlAnglUnit orntS 
      Height          =   330
      Left            =   2400
      TabIndex        =   10
      Top             =   2520
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   582
   End
   Begin VB.CommandButton btmDoc 
      Caption         =   "Бланк"
      Height          =   375
      Left            =   1680
      TabIndex        =   3
      ToolTipText     =   "Сформировать лист описания дефекта в MS Word"
      Top             =   1440
      Width           =   975
   End
   Begin VB.CommandButton btmZoom 
      Caption         =   "Линза"
      Height          =   375
      Left            =   2760
      TabIndex        =   4
      ToolTipText     =   "Восстановить вид линзы, из которой был создан дефект"
      Top             =   1440
      Width           =   1095
   End
   Begin VB.ComboBox dfktType 
      Height          =   315
      Left            =   120
      Style           =   2  'Dropdown List
      TabIndex        =   5
      ToolTipText     =   "Тип дефекта для записи в базу"
      Top             =   1080
      Width           =   3735
   End
   Begin krotw32.ctrlObjCommon common 
      Height          =   1050
      Left            =   120
      TabIndex        =   6
      Top             =   0
      Width           =   3780
      _ExtentX        =   6668
      _ExtentY        =   1852
   End
   Begin VB.TextBox txtValMax 
      Height          =   285
      Left            =   2760
      TabIndex        =   0
      Text            =   "Text1"
      ToolTipText     =   "Максимальный процент глубины дефекта"
      Top             =   2160
      Width           =   1095
   End
   Begin VB.TextBox txtWidth 
      Height          =   285
      Left            =   2760
      TabIndex        =   1
      Text            =   "Text1"
      Top             =   1920
      Width           =   1095
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   2160
      TabIndex        =   8
      Top             =   3360
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   600
      TabIndex        =   7
      Top             =   3360
      Width           =   1215
   End
   Begin VB.Label LabComment 
      Caption         =   "Глубина  (%)"
      Height          =   255
      Index           =   6
      Left            =   120
      TabIndex        =   14
      Top             =   2160
      Width           =   1455
   End
   Begin VB.Label LabComment 
      Caption         =   "Ориентация конечная"
      Height          =   255
      Index           =   4
      Left            =   120
      TabIndex        =   13
      Top             =   2880
      Width           =   1935
   End
   Begin VB.Label LabComment 
      Caption         =   "Ориентация начальная"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   12
      Top             =   2520
      Width           =   1935
   End
   Begin VB.Label LabComment 
      Caption         =   "Ширина (мм)"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   11
      Top             =   1920
      Width           =   2535
   End
End
Attribute VB_Name = "frmObjDefekt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private WithEvents cObjInfo As clsObjDefekt
Attribute cObjInfo.VB_VarHelpID = -1
Private or1 As New clsAnglUnit
Private or2 As New clsAnglUnit
Private fTrace As frmTrace
Private pointLink As New clsPointLink
Private hlp As New clsHelp

Public Sub Edit(prnt As Form, objInfo As clsObjDefekt, frm As frmTrace, ByVal objDist As Long)
Dim typ As clsObjType

Set pointLink.trc = frm.trc
Set cObjInfo = objInfo
Set fTrace = frm
hlp.BindHelp Me, KRT_ObjTypeDfkt

common.Init fTrace.trc, True
common.objectDist = objDist

If Me.Visible Then
 Me.ZOrder
 setControls
 Exit Sub
End If

Load Me

With lstInsType
 .addItem "Внешний"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_EXT
 .addItem "Внутренний"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_INT
 .addItem "Внутристенный"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_MID
 .addItem "Не определено"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_NA
 .ListIndex = 0
End With

With dfktType
For Each typ In frm.trc.db.objTypes
 If (typ.off = False) And (typ.tbl = OBJ_TBL_DFKT) Then
  .AddItem typ.name
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

Me.Show 0, prnt
End Sub

Private Sub setControls()

Me.Caption = cObjInfo.objCommon.objTyp.name
txtWidth.Text = Format$(cObjInfo.dWidth, "0")

or1.fullHour = cObjInfo.dOrients
or2.fullHour = cObjInfo.dOriente
orntS.setValue or1
orntE.setValue or2

txtValMin.Text = Format$(cObjInfo.dValMin, "0")
txtValMax.Text = Format$(cObjInfo.dValMax, "0")
lstInsType.ListIndex = cObjInfo.dInsideType

setLst dfktType, cObjInfo.objCommon.objTyp.id

If (cObjInfo.dEx1 = 0) Or (fTrace.Coroz.Visible = False) Then
 btmZoom.enabled = False
 Else
 btmZoom.enabled = True
End If
End Sub

Private Sub getControls()
common.ObjGet cObjInfo.objCommon

cObjInfo.dWidth = Val(txtWidth.Text)
cObjInfo.dOrients = or1.fullHour
cObjInfo.dOriente = or2.fullHour
cObjInfo.dValMin = val(txtValMin.Text)
cObjInfo.dValMax = Val(txtValMax.Text)
cObjInfo.dInsideType = lstInsType.ItemData(lstInsType.ListIndex)
End Sub

Private Sub btmAct_Click(Index As Integer)
Dim s As String

Select Case Index
 Case 0 'сохранить
  Me.enabled = False
  getControls
  fTrace.setObjDefekt cObjInfo, common.objectDist
  If cObjInfo Is Nothing Then Exit Sub 'защита от быстрых пользователей
  addToHistory fTrace.trc, common.comboComment
  fTrace.objDlgLeft = Me.Left
  fTrace.objDlgTop = Me.Top
  Unload Me
 Case 1 'отказ
  Unload Me
End Select
End Sub

Private Sub btmDoc_Click()
Dim tmp As String

tmp = fTrace.trc.rptFile
If ogdWin.fExist(tmp) = False Then
 ogdWin.Alert "Файл шаблона " & tmp & " не найден."
 Exit Sub
End If

getControls
pointLink.pointDist = cObjInfo.objCommon.objDist

If fTrace.trc.db.getPointLinks(pointLink) = False Then Exit Sub

rpt.wordTemplate = tmp
Rpt.wordReport cObjInfo, pointLink, fTrace.trc, ""
End Sub

Private Sub btmZoom_Click()
setWait "Переход к дефекту на развертке"
With cObjInfo
fTrace.showObj .objCommon.objDist
fTrace.ZoomDefekt cObjInfo
End With
setReady
End Sub

Private Sub cObjInfo_Changed(ByVal dst As Long)
common.ObjSet cObjInfo.objCommon
setControls
Me.ZOrder
End Sub

Private Sub dfktType_Click()
Dim cObjType As clsObjType

Set cObjType = New clsObjType

With cObjInfo.objCommon
cObjType.Init _
  dfktType.ItemData(dfktType.ListIndex), _
  dfktType.List(dfktType.ListIndex), _
  .objTyp.off, _
  .objTyp.tbl
.Init fTrace.trc, .objDist, .objLen, .comment, .isAttention, cObjType
End With
common.ObjSet cObjInfo.objCommon
End Sub

Private Sub Form_Unload(Cancel As Integer)
Set cObjInfo = Nothing
Set fTrace = Nothing
End Sub

Private Function findIndexForInsTypeValue(lst As ComboBox, ByVal v As Long) As Integer
Dim i As Integer, dlt As Long, mindlt As Long, closeIndex As Integer

mindlt = 999999999
If (v = -1) Then v = 1

For i = 0 To lst.ListCount - 1
 dlt = Abs(lst.ItemData(i) - v)
 If dlt < mindlt Then
   mindlt = dlt
   closeIndex = i
 End If
 If mindlt = 0 Then
  findIndexForInsTypeValue = closeIndex
  Exit Function
 End If
Next
findIndexForInsTypeValue = IIf(closeIndex < (lst.ListCount - 1), closeIndex + 1, closeIndex)
End Function
