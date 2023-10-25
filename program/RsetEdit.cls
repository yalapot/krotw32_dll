VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsRsetEdit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private r As Recordset
Private fld As String

Private Sub rsLog(msg As String)
Log cfg.obj.sqlLog, "Rset " & r.name & ": " & msg
End Sub

Public Function Init(rs As Recordset, keyFld As String)
Set r = rs
fld = keyFld
End Function

Public Sub AddNew()
rsLog "AddNew"
r.AddNew
End Sub

Public Sub Delete()
rsLog "Delete (" & fld & "=" & r(fld) & ")"
r.Delete
End Sub

Public Sub Edit()
rsLog "Edit (" & fld & "=" & r(fld) & ")"
r.Edit
End Sub

Public Function Update() As Boolean
Update = False
rsLog "Update (" & fld & "=" & r(fld) & ")"
On Error GoTo errHandle
r.Update
On Error GoTo 0
Update = True
Exit Function

errHandle:
End Function

Public Sub Change(fldEdit As String, vl As Variant)
rsLog fldEdit & "=" & vl
r(fldEdit) = vl
End Sub
