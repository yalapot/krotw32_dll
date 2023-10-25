VERSION 5.00
Begin VB.UserControl ctrlObjCommon 
   ClientHeight    =   1050
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3780
   ScaleHeight     =   1050
   ScaleWidth      =   3780
   ToolboxBitmap   =   "ObjComn.ctx":0000
   Begin VB.CheckBox chkAttenshion 
      Caption         =   "внимание"
      Height          =   255
      Left            =   2160
      TabIndex        =   7
      Top             =   0
      Width           =   1095
   End
   Begin VB.TextBox txtLen 
      Height          =   285
      Left            =   2160
      TabIndex        =   6
      Text            =   "Text1"
      Top             =   360
      Width           =   975
   End
   Begin VB.ComboBox TxtComment 
      Height          =   315
      Left            =   0
      TabIndex        =   4
      Text            =   "Combo1"
      Top             =   720
      Width           =   3735
   End
   Begin VB.CommandButton btmDist 
      Caption         =   "Дистанция"
      Height          =   375
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   1095
   End
   Begin VB.PictureBox PicObj 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   495
      Left            =   3360
      ScaleHeight     =   495
      ScaleWidth      =   375
      TabIndex        =   1
      Top             =   0
      Width           =   375
   End
   Begin VB.Label labLen 
      Caption         =   "Длина, мм"
      Height          =   255
      Left            =   1200
      TabIndex        =   5
      Top             =   360
      Width           =   975
   End
   Begin VB.Label LabDist 
      Caption         =   "Label1"
      Height          =   255
      Left            =   1200
      TabIndex        =   3
      Top             =   20
      Width           =   855
   End
   Begin VB.Label LabComment 
      Caption         =   "Примечание"
      Height          =   255
      Left            =   0
      TabIndex        =   2
      Top             =   360
      Width           =   1095
   End
End
Attribute VB_Name = "ctrlObjCommon"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_dist As Long
Private d_obj_dist As Long
Private d_length As Long
Private changeFlag As Boolean

Private ctrlX As Single
Private ctrlY As Single
Private trc As clsTrace
Private ot As clsObjType
Private WithEvents cObj As clsDb
Attribute cObj.VB_VarHelpID = -1

Public Sub Init(t As clsTrace, Optional ByVal setHist As Boolean = False)
Set trc = t
Set cObj = trc.db
If setHist Then trc.commentHistory.setCombo TxtComment
End Sub

Public Sub ObjSet(objInfo As clsObjCommon)
changeFlag = False
Set ot = objInfo.objTyp
labLen.visible = ot.isLengthEditable
txtLen.visible = ot.isLengthEditable
d_length = objInfo.objLen
PicObj.Picture = LoadResPicture(objInfo.objTyp.Picture, vbResBitmap)
LabDist.Caption = mm2txt(objInfo.usrDist)
TxtComment.Text = objInfo.comment
txtLen.Text = objInfo.usrLen
chkAttenshion.Value = IIf(objInfo.isAttention, 1, 0)
End Sub

Public Sub ObjGet(objInfo As clsObjCommon)
If changeFlag Then
 Select Case objInfo.objTyp.id
  Case OBJ_TYPE.OBJ_prigruz
   d_length = val(txtLen.Text)
  Case Else
   d_length = trc.getLenReal(d_dist, Val(txtLen.Text))
 End Select
End If

objInfo.Init trc, d_dist, d_length, Trim$(TxtComment.Text), IIf(chkAttenshion.Value = 1, True, False), ot
End Sub

Private Sub btmDist_Click()
Dim d As Double

d = frmInterval.getDist(frmMain, "Дистанция обьекта", "Новая дистанция:", trc.getDistKoef(d_dist))
d_dist = trc.getDistReal(d)
LabDist.Caption = mm2txt(trc.getDistKoef(d_dist))
End Sub

Private Sub cObj_moveObject(ByVal src_dist As Long, ByVal target_dist As Long)
If src_dist <> d_dist Then Exit Sub
d_dist = target_dist
d_obj_dist = d_dist
LabDist.Caption = mm2txt(trc.getDistKoef(d_dist))
End Sub

Property Get objectDist() As Long
objectDist = d_obj_dist
End Property

Property Let objectDist(ByVal x As Long)
d_dist = x
d_obj_dist = d_dist
End Property

Private Sub TxtComment_Change()
Static intFlag As Boolean

If intFlag Then Exit Sub
intFlag = True
If Len(TxtComment.Text) > CMNT_LENGTH Then
 TxtComment.Text = Left(TxtComment.Text, CMNT_LENGTH)
 TxtComment.SelStart = CMNT_LENGTH
 TxtComment.SelLength = 0
End If
intFlag = False
End Sub

Private Sub txtLen_Change()
changeFlag = True
End Sub

Property Get comboComment() As ComboBox
Set comboComment = TxtComment
End Property

Private Sub UserControl_Initialize()
ctrlX = UserControl.width
ctrlY = UserControl.Height
End Sub

Private Sub UserControl_Resize()
Static resizeFlag As Boolean

If resizeFlag Then Exit Sub
resizeFlag = True
UserControl.width = ctrlX
UserControl.Height = ctrlY
resizeFlag = False
End Sub
