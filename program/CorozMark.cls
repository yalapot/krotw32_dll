VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsCorozMark"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Const MIN_RAD_PRCNT = 30

Private trc As clsTrace
Private crz As clsCoroz
Private d_isWhite As Boolean
Private lastPos As Long

Private dat() As Byte
Private row() As Long
Private datMin As Long
Private datMax As Long
Private rowMin As Long
Private rowMax As Long

Public Sub Init(trace As clsTrace, Coroz As clsCoroz, ByVal isWhiteFlag As Boolean)
Set trc = trace
Set crz = Coroz
d_isWhite = isWhiteFlag
lastPos = -1
ReDim dat(crz.num) As Byte
ReDim row(crz.num) As Long
End Sub

Private Function currentPos() As Long
currentPos = IIf(d_isWhite, trc.mark.white, trc.mark.black)
End Function

Private Sub calcMinMax()
Dim i As Long

datMin = crz.valMax
datMax = crz.valMin
rowMin = crz.valMaxRow
rowMax = crz.valMinRow

For i = 0 To crz.num - 1
 If datMin > dat(i) Then datMin = dat(i)
 If datMax < dat(i) Then datMax = dat(i)
 If rowMin > row(i) Then rowMin = row(i)
 If rowMax < row(i) Then rowMax = row(i)
Next
End Sub

Private Sub updateMrk()
If lastPos <> currentPos Then
 lastPos = currentPos
 If krotGetVectSens(trc.handle, crz.Index, lastPos, dat(0), row(0)) = KRT_ERR Then
  ogdWin.Alert lastError()
  Exit Sub
 End If
 calcMinMax
End If
End Sub

Property Get data(ByVal indx As Long) As Long
updateMrk
data = IIf(crz.isRow, row(indx), dat(indx))
End Property

Property Get dataMin() As Long
updateMrk
dataMin = IIf(crz.isRow, rowMin, datMin)
End Property

Property Get dataMax() As Long
updateMrk
dataMax = IIf(crz.isRow, rowMax, datMax)
End Property

Public Sub Draw(pic As PictureBox, ByVal clr As Long, ByVal isDiskret As Boolean)
Dim i As Long
Dim x1 As Long, y1 As Long
Dim x2 As Long, y2 As Long

updateMrk
x1 = pic.ScaleTop - crz.topSens
If x1 < 0 Then x1 = x1 + pic.ScaleHeight
x2 = x1
y1 = IIf(crz.isRow, row(0), dat(0))

For i = 1 To crz.num - 1
 x2 = x2 + 1
 'y2 = IIf(crz.isRow, row(i), dat(i))
 y2 = IIf(crz.isRow, row(i - 1), dat(i - 1))
 If x2 > pic.ScaleHeight Then
  x2 = x2 - pic.ScaleHeight
  Else
  
  If isDiskret Then
    pic.Line (y1, x1)-(y2, x1), clr
    pic.Line (y2, x1)-(y2, x2), clr
  Else
    pic.Line (y1, x1)-(y2, x2), clr
  End If
  
 End If
 x1 = x2
 y1 = y2
Next

x2 = x2 + 1

If isDiskret Then
  pic.Line (y1, x1)-(y2, x1), clr
  pic.Line (y2, x1)-(y2, x2), clr
Else
  pic.Line (y1, x1)-(y2, x2), clr
End If
End Sub

' profilZero
Public Function transRadius(ByVal v As Single, ByVal nominalRad As Single)
transRadius = nominalRad * (1 - (1 - MIN_RAD_PRCNT / 100) * (v - trc.profilZero) / (200 - trc.profilZero))
'Debug.Print "transRadius: " & v & " nominalRad: " & nominalRad & " ret: " & transRadius
End Function

Public Sub DrawCircle( _
pic As PictureBox, _
ByVal cntrX As Single, _
ByVal cntrY As Single, _
ByVal nominalRad As Single, _
ByVal clr As Long _
)
Dim i As Integer, saveStyle As Integer
Dim mult As Double, rad As Double, degreeInSens As Double, ang As Double
Dim x As Double, y As Double, x1 As Double, y1 As Double, x2 As Double, y2 As Double

updateMrk
mult = 1
degreeInSens = 2 * PI / crz.num

saveStyle = pic.DrawStyle
pic.DrawStyle = 0

'Debug.Print "Normal: " & trc.profilZero
'Debug.Print "Center: " & cntrX & ":" & cntrY

'rad = nominalRad + (dat(0) * nominalRad / trc.profilZero - nominalRad) * mult
'rad = nominalRad * (1 - (dat(0) - trc.profilZero) / 200)
rad = Me.transRadius(dat(0), nominalRad)
ang = krtAngle2VBangle(0)
x = cntrX + rad * Cos(ang)
y = cntrY - rad * sIn(ang)
x1 = x
y1 = y

'Debug.Print "0: " & dat(0) & " -> " & x1 & ":" & y1

For i = 1 To crz.num - 1
 'rad = nominalRad + (dat(i) * nominalRad / trc.profilZero - nominalRad) * mult
 'rad = nominalRad * (1 - (dat(i) - trc.profilZero) / 200)
 rad = Me.transRadius(dat(i), nominalRad)
 ang = krtAngle2VBangle(i * degreeInSens)
 x2 = cntrX + rad * Cos(ang)
 y2 = cntrY - rad * sIn(ang)
 
 'Debug.Print i & ": " & dat(i) & " -> " & x2 & ":" & y2
 
 pic.Line (x1, y1)-(x2, y2), clr
 x1 = x2
 y1 = y2
Next
pic.Line (x2, y2)-(x, y), clr
pic.DrawStyle = saveStyle
End Sub
