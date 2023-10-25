VERSION 5.00
Begin VB.Form frmCommentEdit 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Изменение примечаний"
   ClientHeight    =   2265
   ClientLeft      =   2670
   ClientTop       =   9330
   ClientWidth     =   5130
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2265
   ScaleWidth      =   5130
   ShowInTaskbar   =   0   'False
   Begin VB.CheckBox chhkInsideType 
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   1080
      Width           =   375
   End
   Begin VB.ComboBox lstInsideType 
      Height          =   315
      Left            =   600
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   1080
      Width           =   4455
   End
   Begin VB.CheckBox chkCmnt 
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   360
      Width           =   375
   End
   Begin VB.ComboBox txtCmnt 
      Height          =   315
      Left            =   600
      TabIndex        =   3
      Top             =   360
      Width           =   4455
   End
   Begin VB.CommandButton btmAction 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   375
      Index           =   1
      Left            =   2760
      TabIndex        =   1
      Top             =   1680
      Width           =   1215
   End
   Begin VB.CommandButton btmAction 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   375
      Index           =   0
      Left            =   1320
      TabIndex        =   0
      Top             =   1680
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Текст примечания"
      Height          =   255
      Left            =   600
      TabIndex        =   6
      Top             =   120
      Width           =   2895
   End
   Begin VB.Label Label3 
      Caption         =   "Тип дефекта"
      Height          =   255
      Left            =   600
      TabIndex        =   2
      Top             =   840
      Width           =   2895
   End
End
Attribute VB_Name = "frmCommentEdit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private cmnt As clsCommentEdit
Private act As Boolean
Private hlp As New clsHelp

Public Function Edit(cmntObj As clsCommentEdit) As Boolean
Set cmnt = cmntObj
Me.Icon = frmMain.Icon
hlp.BindHelp Me, KRT_ObjAction
centerForm frmMain, Me
setControls
act = False
Me.Show 1, frmMain
Edit = act
End Function

Private Sub setControls()
cmnt.trc.commentHistory.setCombo txtCmnt

txtCmnt.Text = cmnt.comment

chkCmnt.Value = IIf(cmnt.is_comment, 1, 0)
chhkInsideType.Value = IIf(cmnt.is_inside_type, 1, 0)

chhkInsideType_Click
chkCmnt_Click
End Sub

Private Sub btmAction_Click(Index As Integer)
Select Case Index

 Case 0 'да
  If Len(Trim(txtCmnt.Text)) > 0 Then
   cmnt.trc.commentHistory.addItem txtCmnt.Text
  End If
  cmnt.is_comment = IIf(chkCmnt.Value = 1, True, False)
  cmnt.comment = txtCmnt.Text
  cmnt.is_inside_type = IIf(chhkInsideType.Value = 1, True, False)
  cmnt.inside_type = lstInsideType.ItemData(lstInsideType.ListIndex)
  act = True

 Case 1 'отказ
End Select
Unload Me
End Sub

Private Sub chhkInsideType_Click()

If chhkInsideType.Value = 1 Then
lstInsideType.enabled = True
Else
lstInsideType.enabled = False
End If

End Sub

Private Sub chkCmnt_Click()

If chkCmnt.Value = 1 Then
txtCmnt.enabled = True
Else
txtCmnt.enabled = False
End If

End Sub

Private Sub Form_Load()

With lstInsideType
 .addItem "Внешний"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_EXT
 .addItem "Внутренний"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_INT
 .addItem "Внутристенный"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_MID
 .addItem "Не определено"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_NA
 
 .ListIndex = 0
 cmnt.inside_type = EN_INT_TYPE.IT_EXT
End With

End Sub
