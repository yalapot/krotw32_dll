VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_num As Long
Private d_min As Long
Private d_max As Long
Private d_name As String
Private d_Key As String
Private d_typ As KRT_SENS
Private trc As clsTrace
Private d_line() As clsSensorLine

Private dataMin As Long
Private dataMax As Long

Public Sub Init( _
trace As clsTrace, _
ByVal typ As KRT_SENS, _
ByVal iniKey As String, _
ByVal nam As String, _
ByVal num As Long, _
ByVal vMin As Long, _
ByVal vMax As Long _
)

Dim i As Integer

Set trc = trace
d_name = nam
d_num = num
d_max = vMax
d_min = vMin
d_typ = typ
d_Key = iniKey

ReDim d_line(d_num) As clsSensorLine
For i = 1 To d_num
 Set d_line(i) = New clsSensorLine
 d_line(i).Init trc, typ, i - 1
 d_line(i).visible = trc.getUserBool(d_Key & (i - 1), d_line(i).visible)
Next i
End Sub

Public Sub ClearData()
Dim i As Integer

For i = 1 To d_num
 d_line(i).ClearData
Next i
End Sub

Public Sub Save()
Dim i As Integer

For i = 1 To d_num
 trc.setUserBool d_Key & (i - 1), d_line(i).visible
Next i
End Sub

Property Get line(ByVal indx As Integer) As clsSensorLine
Set line = d_line(indx + 1)
End Property

Property Get name() As String
name = d_name
End Property

Property Get num() As Long
num = d_num
End Property

Property Get valMin() As Long
valMin = d_min
End Property

Property Get valMax() As Long
valMax = d_max
End Property

Public Sub offAll()
Dim i As Integer

For i = 1 To Me.num
 d_line(i).visible = False
Next
End Sub

Property Get visible() As Boolean
Dim i As Integer

visible = True
For i = 1 To Me.num
 If d_line(i).visible Then Exit Property
Next
visible = False
End Property

Property Get typ() As KRT_SENS
typ = d_typ
End Property

Private Function calcMinMax() As Boolean
Dim i As Integer

dataMin = Me.valMax
dataMax = Me.valMin

For i = 1 To Me.num
 If d_line(i).visible Then
  If d_line(i).minPageVal < dataMin Then dataMin = d_line(i).minPageVal
  If d_line(i).maxPageVal > dataMax Then dataMax = d_line(i).maxPageVal
 End If
Next
calcMinMax = True
End Function

Property Get minPageVal() As Long
If calcMinMax() Then
 minPageVal = dataMin
 Else
 minPageVal = -1
End If
End Property

Property Get maxPageVal() As Long
If calcMinMax() Then
 maxPageVal = dataMax
 Else
 maxPageVal = -1
End If
End Property

Public Function canDraw(pic As PictureBox) As Boolean
If trc.isUserScale Then
 pic.BackColor = color.noDataX
 canDraw = False
 Else
 pic.ScaleLeft = trc.pageStart
 pic.ScaleWidth = trc.pageLength
 canDraw = True
End If
pic.Cls
End Function

Public Function Draw( _
pic As PictureBox, _
ByVal diskret As Boolean, _
ByVal cycledLevel As Long, _
ByVal reverse As Boolean, _
Optional forceRead As Boolean = False _
) As Boolean

Dim i As Integer, cl As Long

If canDraw(pic) = False Then Exit Function

cl = 0
For i = 1 To Me.num
 If d_line(i).visible Then
  d_line(i).Draw pic, color.clrIndx(cl), diskret, cycledLevel, reverse, forceRead
  cl = cl + 1
 End If
Next
End Function

Public Function getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
getVal = Me.line(lineIndex + 1).getVal(x)
End Function

Property Get markW(ByVal lineIndex As Long) As Long
markW = Me.line(lineIndex + 1).markW
End Property

Property Get markB(ByVal lineIndex As Long) As Long
markB = Me.line(lineIndex + 1).markB
End Property

Property Get isCurrMarkWhite() As Boolean
isCurrMarkWhite = trc.mark.isCurrWhite
End Property
