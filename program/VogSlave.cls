VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsVogSlave"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_traceHandle As Integer
Private d_color As Long
Private d_traceName As String
Private d_mark1 As Long
Private d_mark2 As Long

Public Sub Init( _
ByVal traceHandle As Integer, _
ByVal color As Long, _
ByVal traceName As String, _
ByVal mark1 As Long, _
ByVal mark2 As Long _
)

d_traceHandle = traceHandle
d_color = color
d_traceName = traceName
d_mark1 = mark1
d_mark2 = mark2

End Sub

Property Get mark1() As Long
mark1 = d_mark1
End Property

Property Get mark2() As Long
mark2 = d_mark2
End Property

Property Get traceName() As String
traceName = d_traceName
End Property

Property Get traceHandle() As Integer
traceHandle = d_traceHandle
End Property

Property Get color() As Long
color = d_color
End Property
