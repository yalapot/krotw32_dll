VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsVogMatch"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_matchMode As Long
Private d_masterHandle As Integer
Private d_traces As New Collection

Public Sub Init(ByVal masterHandle As Integer)
d_masterHandle = masterHandle
d_matchMode = 0
d_matchMode = bitOn(d_matchMode, MATCH_MODE_SHIFT)
d_matchMode = bitOn(d_matchMode, MATCH_MODE_SCALE)
d_matchMode = bitOn(d_matchMode, MATCH_MODE_ROTATE)
clearCollection d_traces
End Sub

Property Get trace() As Collection
Set trace = d_traces
End Property

Property Let modeShift(m As Boolean)
If m Then
 d_matchMode = bitOn(d_matchMode, MATCH_MODE_SHIFT)
 Else
 d_matchMode = bitOff(d_matchMode, MATCH_MODE_SHIFT)
End If
End Property

Property Let modeScale(m As Boolean)
If m Then
 d_matchMode = bitOn(d_matchMode, MATCH_MODE_SCALE)
 Else
 d_matchMode = bitOff(d_matchMode, MATCH_MODE_SCALE)
End If
End Property

Property Let modeRotate(m As Boolean)
If m Then
 d_matchMode = bitOn(d_matchMode, MATCH_MODE_ROTATE)
 Else
 d_matchMode = bitOff(d_matchMode, MATCH_MODE_ROTATE)
End If
End Property

Property Get modeShift() As Boolean
modeShift = IIf((d_matchMode And MATCH_MODE_SHIFT) = 0, False, True)
End Property

Property Get modeScale() As Boolean
modeScale = IIf((d_matchMode And MATCH_MODE_SCALE) = 0, False, True)
End Property

Property Get modeRotate() As Boolean
modeRotate = IIf((d_matchMode And MATCH_MODE_ROTATE) = 0, False, True)
End Property

Property Get modes() As Long
modes = d_matchMode
End Property
