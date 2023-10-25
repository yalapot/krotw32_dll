VERSION 5.00
Begin VB.Form frmObjLine 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   2745
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3960
   Icon            =   "ObjLine.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2745
   ScaleWidth      =   3960
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin krotw32.ctrlObjCommon common 
      Height          =   1050
      Left            =   120
      TabIndex        =   7
      Top             =   0
      Width           =   3780
      _ExtentX        =   6668
      _ExtentY        =   1852
   End
   Begin VB.CheckBox boolMarker 
      Caption         =   "Маркер"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   1080
      Width           =   3735
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   480
      TabIndex        =   3
      Top             =   2160
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   2040
      TabIndex        =   4
      Top             =   2160
      Width           =   1215
   End
   Begin VB.TextBox txtMark 
      Height          =   285
      Left            =   2040
      MaxLength       =   10
      TabIndex        =   1
      Text            =   "Text1"
      Top             =   1440
      Width           =   1815
   End
   Begin VB.TextBox txtDist 
      Height          =   285
      Left            =   2040
      MaxLength       =   50
      TabIndex        =   2
      Text            =   "Text1"
      Top             =   1680
      Width           =   1815
   End
   Begin VB.Label LabComment 
      Caption         =   "Имя маркера"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   6
      Top             =   1440
      Width           =   1815
   End
   Begin VB.Label LabComment 
      Caption         =   "Отметка по трассе"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   5
      Top             =   1680
      Width           =   1815
   End
End
Attribute VB_Name = "frmObjLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private cObjInfo As clsObjLine
Private fTrace As frmTrace
Private hlp As New clsHelp

Public Sub Edit(prnt As Form, objInfo As clsObjLine, frm As frmTrace, ByVal objDist As Long)
Set cObjInfo = objInfo
Set fTrace = frm
hlp.BindHelp Me, KRT_ObjTypeLine
common.Init fTrace.trc, True
common.objectDist = objDist

If Me.Visible Then
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
boolMarker.Value = IIf(cObjInfo.dMarker, 1, 0)
txtMark.Text = cObjInfo.dMarkerText
txtDist.Text = cObjInfo.dTraceDist
End Sub

Private Sub getControls()
common.ObjGet cObjInfo.objCommon
cObjInfo.dMarker = IIf(boolMarker.Value = 0, False, True)
cObjInfo.dMarkerText = Trim$(txtMark.Text)
cObjInfo.dTraceDist = Trim$(txtDist.Text)
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0 'сохранить
  getControls
  fTrace.setObjLine cObjInfo, common.objectDist
  addToHistory fTrace.trc, common.comboComment
  fTrace.objDlgLeft = Me.Left
  fTrace.objDlgTop = Me.Top
  Unload Me
 Case 1 'отказ
  Unload Me
End Select
End Sub