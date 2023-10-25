Attribute VB_Name = "utilmain"
Option Explicit

Public lastSQLerror As String
Public mdb As New clsMdbUtil

Sub Main()
mdb.Proccess Command()
End Sub

Public Function Log(logName As String, cmd As Variant) As Boolean
Dim fl As Integer, msg As String

If logName = "" Then Exit Function

msg = "+ " & Now & " " & cmd
fl = FreeFile
Open logName For Append As fl
Print #fl, msg
Close fl
End Function

Public Function makeFlag(fname As String) As Boolean
Dim fl As Integer

fl = FreeFile
On Error GoTo fail
Open fname For Output As fl
On Error GoTo 0

Close fl
makeFlag = True
Exit Function

fail:
makeFlag = False
End Function

Public Function SQLexeEx(db As Database, ParamArray cmd()) As Integer
Dim i As Integer

lastSQLerror = ""
On Error GoTo errHand
BeginTrans
For i = LBound(cmd) To UBound(cmd)
 If Not (cmd(i) = "") Then
  execSql db, cmd(i), dbFailOnError
 End If
Next
CommitTrans
SQLexeEx = 0
Exit Function

errHand:
SQLexeEx = Err.Number
lastSQLerror = Err.Description
End Function

Public Sub execSql(db As Database, cmd As Variant, Optional opt As Integer = 0)
Log mdb.logName, cmd
db.Execute cmd, opt
Log mdb.logName, "RecordsAffected: " & db.RecordsAffected & vbNewLine
End Sub

