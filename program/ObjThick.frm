VERSION 5.00
Begin VB.Form frmObjThick 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   3120
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3975
   Icon            =   "ObjThick.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3120
   ScaleWidth      =   3975
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtPress 
      Height          =   285
      Left            =   2040
      TabIndex        =   9
      Text            =   "Text1"
      Top             =   1680
      Width           =   1815
   End
   Begin krotw32.ctrlObjCommon common 
      Height          =   1050
      Left            =   120
      TabIndex        =   8
      Top             =   0
      Width           =   3780
      _extentx        =   6668
      _extenty        =   1852
   End
   Begin VB.TextBox txtThick 
      Height          =   285
      Left            =   2040
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   1320
      Width           =   1815
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   2040
      TabIndex        =   2
      Top             =   2520
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   480
      TabIndex        =   1
      Top             =   2520
      Width           =   1215
   End
   Begin VB.Label labPress 
      Caption         =   "Рабочее давление"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   1680
      Width           =   1815
   End
   Begin VB.Label LabComment 
      Caption         =   "Следующая толщина"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   7
      Top             =   2040
      Width           =   1815
   End
   Begin VB.Label labNext 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   6
      Top             =   2040
      Width           =   1815
   End
   Begin VB.Label labPrev 
      Caption         =   "Label1"
      Height          =   255
      Left            =   2040
      TabIndex        =   5
      Top             =   1080
      Width           =   1815
   End
   Begin VB.Label LabComment 
      Caption         =   "Новая толщина"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   4
      Top             =   1320
      Width           =   1815
   End
   Begin VB.Label LabComment 
      Caption         =   "Предыдущая толщина"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   3
      Top             =   1080
      Width           =   1815
   End
End
Attribute VB_Name = "frmObjThick"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private cObjInfo As clsObjThick
Private fTrace As frmTrace
Private hlp As New clsHelp

Public Sub Edit(prnt As Form, objInfo As clsObjThick, frm As frmTrace, ByVal objDist As Long)
Set cObjInfo = objInfo
Set fTrace = frm
hlp.BindHelp Me, KRT_ObjTypeThick
common.Init fTrace.trc, True
common.objectDist = objDist

Select Case objInfo.objCommon.objTyp.id

 Case OBJ_TYPE.OBJ_category
   LabComment(1).Caption = "Предыдущая категория"
   LabComment(2).Caption = "Новая категория"
   LabComment(3).Caption = "Следующая категория"
   labPress.visible = True
   txtPress.visible = True
   
 'Case OBJ_TYPE.OBJ_thick
 Case Else
   LabComment(1).Caption = "Предыдущая толщина"
   LabComment(2).Caption = "Новая толщина"
   LabComment(3).Caption = "Следующая толщина"
   labPress.visible = False
   txtPress.visible = False
   
End Select

If Me.visible Then
 Me.ZOrder
 setControls
 Exit Sub
End If

Load Me
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
common.ObjSet cObjInfo.objCommon
labPrev.Caption = cObjInfo.dThickPrev
labNext.Caption = cObjInfo.dThickNext
txtThick.Text = cObjInfo.dThick
txtPress.Text = cObjInfo.dPress
End Sub

Private Sub getControls()
common.ObjGet cObjInfo.objCommon
cObjInfo.dThick = val(Trim$(txtThick.Text))
cObjInfo.dPress = val(Trim$(txtPress.Text))
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0 'сохранить
  getControls
  If cObjInfo.Valid = False Then
   ogdWin.Alert cObjInfo.errText
   Exit Sub
  End If
  fTrace.setObjThick cObjInfo, common.objectDist
  addToHistory fTrace.trc, common.comboComment
  fTrace.objDlgLeft = Me.Left
  fTrace.objDlgTop = Me.Top
  Unload Me
 Case 1 'отказ
  Unload Me
End Select
End Sub

Private Sub txtThick_GotFocus()
setSel txtThick
End Sub