VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsHelp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private WithEvents frm As Form
Attribute frm.VB_VarHelpID = -1
Private topic As String
Private Const KEY_F1 = 112

Public Sub BindHelp(helpForm As Form, ByVal helpTopic As String)
Set frm = helpForm
topic = helpTopic
frm.KeyPreview = True
End Sub

Private Sub frm_KeyDown(KeyCode As Integer, Shift As Integer)
If KeyCode = KEY_F1 Then
 ShowHelp topic
End If
End Sub
