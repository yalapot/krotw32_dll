VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsKrtCmdLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private cfgFile As String
Private trcFile As New Collection
Private errFlag As Boolean
Private errorMessage As String
Private trcPath As String

Public Function Init(cline As String) As Boolean
Dim i As Integer

cfgFile = ""
For i = 1 To trcFile.Count
 trcFile.Remove 1
Next
errorMessage = ""
errFlag = False

With cfg.parser
.Delim = " "
.TestString = .Delim & cline
.Parse
i = 1
Do While i <= .Count
 If Len(.Item(i)) > 0 Then
  If Asc(.Item(i)) = Asc("-") Then
   procOption .Item(i)
   Else
    If Asc(.Item(i)) = Asc("""") Then
      
      If InStr(.Item(i), """") <> InStrRev(.Item(i), """") Then
        trcPath = Mid(.Item(i), 2, Len(.Item(i)) - 2)
       Else
        trcPath = Mid(.Item(i), 2, Len(.Item(i)))
        i = i + 1
        Do
         trcPath = trcPath + " " + .Item(i)
         i = i + 1
        Loop Until InStr(.Item(i), """") > 1
        trcPath = trcPath + " " + Mid(.Item(i), 1, InStr(.Item(i), """") - 1)
      End If
      trcFile.Add trcPath
     Else
      trcFile.Add .Item(i)
    End If
  End If
 End If
i = i + 1
Loop
End With

Init = Not errFlag
End Function

Private Sub procOption(opt As String)
Dim optName As String, optVal As String

optName = Mid(opt, 2, 1)
optVal = Mid(opt, 3)
Select Case optName
 
Case "c", "C"
 cfgFile = optVal

Case Else
 errFlag = True
 errorMessage = errorMessage & "Неизвестная опция -" & optName & vbNewLine

End Select
End Sub

Property Get errText() As String
errText = errorMessage
End Property

Property Get config() As String
config = cfgFile
End Property

Property Get traceNum() As Integer
traceNum = trcFile.Count
End Property

Property Get traceFile(ByVal indx As Integer) As String
traceFile = trcFile(indx)
End Property
