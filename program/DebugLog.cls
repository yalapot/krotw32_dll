VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDebugLog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private lFile As String
Private logged As Boolean

Property Get active() As Boolean
active = logged
End Property

Property Let active(a As Boolean)
logged = a
End Property

Property Get logFile() As String
logFile = lFile
End Property

Property Let logFile(l As String)
lFile = l
Me.active = IIf(Len(lFile) > 0, True, False)
End Property

Private Sub Class_Initialize()
lFile = "krotw32.log"
logged = True
End Sub

Public Sub Log(msg As String)
Dim out As Integer

If logged = False Then Exit Sub

out = FreeFile
Open lFile For Append As out
Print #out, "VB " & Format(Now, "Hh:Nn:Ss") & " " & msg
Close out
End Sub
