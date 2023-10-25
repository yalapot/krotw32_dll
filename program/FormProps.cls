VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsFormProps"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const KEY_STATE = "State"
Private Const KEY_LEFT = "Left"
Private Const KEY_TOP = "Top"
Private Const KEY_WIDTH = "Width"
Private Const KEY_HEIGH = "Height"
Private Const KEY_COLUMN = "TableCol"

Private d_keyPrefix As String
Private Ini As clsIniSection

Public Sub Init(iniSec As clsIniSection, ByVal keyPrf As String)
Set Ini = iniSec
d_keyPrefix = keyPrf
End Sub

Public Function fullKey(ByVal key As String) As String
fullKey = d_keyPrefix & key
End Function

Private Function key(ByVal keyName As String) As String
key = d_keyPrefix & keyName
End Function

Public Sub saveDialog(frm As Form)
Ini.setInt key(KEY_STATE), frm.WindowState
Ini.setDbl key(KEY_LEFT), frm.Left
Ini.setDbl key(KEY_TOP), frm.Top
End Sub

Public Function restoreDialog(frm As Form) As Boolean
restoreDialog = False
With frm

.WindowState = Ini.getInt(key(KEY_STATE), .WindowState)
If .WindowState = 0 Then
 .Left = Ini.getInt(key(KEY_LEFT), .Left)
 .Top = Ini.getInt(key(KEY_TOP), .Top)
 restoreDialog = True
End If

End With
End Function

Public Sub saveForm(frm As Form)
Me.saveDialog frm
Ini.setDbl key(KEY_WIDTH), frm.width
Ini.setDbl key(KEY_HEIGH), frm.Height
End Sub

Public Sub restoreForm(frm As Form)
With frm

If Me.restoreDialog(frm) Then
 .width = Ini.getInt(key(KEY_WIDTH), .width)
 .Height = Ini.getInt(key(KEY_HEIGH), .Height)
End If

End With
End Sub

Public Sub saveFormTable(frm As Form, grid As TDBGrid)
Dim i As Integer, c As Column

Me.saveForm frm
i = 0
For Each c In grid.Columns
 Ini.setDbl d_keyPrefix & KEY_COLUMN & i, IIf(c.visible, c.width, 0)
 i = i + 1
Next
End Sub

Public Sub restoreFormTable(frm As Form, grid As TDBGrid)
Dim i As Integer, c As Column, w As Double

Me.restoreForm frm
i = 0
For Each c In grid.Columns
 w = Ini.getDbl(d_keyPrefix & KEY_COLUMN & i, c.width)
 If w = 0 Then
  c.visible = False
  Else
  c.width = w
 End If
 i = i + 1
Next
End Sub
