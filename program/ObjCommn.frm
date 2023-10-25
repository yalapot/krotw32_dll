VERSION 5.00
Begin VB.Form frmObjCommon 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   1785
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3945
   Icon            =   "ObjCommn.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1785
   ScaleWidth      =   3945
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin krotw32.ctrlObjCommon common 
      Height          =   1050
      Left            =   120
      TabIndex        =   2
      Top             =   0
      Width           =   3780
      _ExtentX        =   6668
      _ExtentY        =   1852
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   600
      TabIndex        =   0
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   2160
      TabIndex        =   1
      Top             =   1200
      Width           =   1215
   End
End
Attribute VB_Name = "frmObjCommon"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private cObjInfo As clsObjCommon
Private fTrace As frmTrace
Private hlp As New clsHelp

Public Sub Edit(prnt As Form, objInfo As clsObjCommon, frm As frmTrace, ByVal objDist As Long)
Set cObjInfo = objInfo
Set fTrace = frm
hlp.BindHelp Me, KRT_ObjTypeCommon

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
Me.Caption = cObjInfo.objTyp.name
common.ObjSet cObjInfo
End Sub

Private Sub btmAct_Click(Index As Integer)
Dim s As String

Select Case Index
 Case 0 'сохранить
  common.ObjGet cObjInfo
  fTrace.setObjCommon cObjInfo, common.objectDist
  If cObjInfo.objTyp.id = OBJ_prigruz Then
   fTrace.trc.db.prigruzLength = cObjInfo.objLen
  End If
  addToHistory fTrace.trc, common.comboComment
  fTrace.objDlgLeft = Me.Left
  fTrace.objDlgTop = Me.Top
  Unload Me
 Case 1 'отказ
  Unload Me
End Select
End Sub