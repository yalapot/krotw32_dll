Attribute VB_Name = "util"
Option Explicit

Global Const PI = 3.14159265359

Public Function dist( _
ByVal x1 As Double, _
ByVal y1 As Double, _
ByVal x2 As Double, _
ByVal y2 As Double _
) As Double
dist = Sqr((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
End Function

Public Function dist3d( _
ByVal x1 As Single, _
ByVal y1 As Single, _
ByVal z1 As Single, _
ByVal x2 As Single, _
ByVal y2 As Single, _
ByVal z2 As Single _
) As Single
dist3d = Sqr((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2)
End Function

Public Function rad2degree(ByVal a As Single) As String
Dim s As String

a = a * 180 / PI
's = Fix(a) & "°"
'a = (a - Fix(a)) * 60
's = s & " " & Abs(Fix(a)) & "'"
rad2degree = dblStr(a, 1)
End Function

Public Sub clearCollection(c As Collection)
Dim num As Integer
For num = 1 To c.count
    c.Remove 1
Next
End Sub

Public Function bitOn(mask As Long, bit As Long) As Long
bitOn = mask Or bit
End Function

Public Function bitOff(mask As Long, bit As Long) As Long
bitOff = mask And (-1 Xor bit)
End Function

Public Function boolStr(ByVal v As Boolean) As String
boolStr = IIf(v, "1", "0")
End Function

Public Function mm2txt(ByVal numVal As Long) As String
mm2txt = intDblStr(numVal, 3, 3)
End Function

Public Sub rotateMatrixClock(ByVal x As Long, ByVal y As Long, src() As Long, dst() As Long)
Dim i As Long, j As Long, b As Long

For i = 0 To y - 1
 b = i * x
 For j = 0 To x - 1
  dst(j * y + y - i - 1) = src(b + j)
 Next
Next
End Sub

Public Sub copyMatrix(ByVal x As Long, ByVal y As Long, src() As Integer, dst() As Long)
Dim i As Long, j As Long, b As Long

For i = 0 To y - 1
 b = i * x
 For j = 0 To x - 1
  dst(b + j) = src(b + j)
 Next
Next
End Sub

Public Sub copyMatrixInt(ByVal x As Long, ByVal y As Long, src() As Integer, dst() As Integer)
Dim i As Long, j As Long, b As Long

For i = 0 To y - 1
 b = i * x
 For j = 0 To x - 1
  dst(b + j) = src(b + j)
 Next
Next
End Sub

Public Sub copyMatrixLong(ByVal x As Long, ByVal y As Long, src() As Long, dst() As Long)
Dim i As Long, j As Long, b As Long

For i = 0 To y - 1
 b = i * x
 For j = 0 To x - 1
  dst(b + j) = src(b + j)
 Next
Next
End Sub

Public Sub printMatrix(ByVal x As Long, ByVal y As Long, m() As Long)
Dim i As Long, j As Long, b As Long, s As String

For i = 0 To y - 1
 b = i * x
 s = ""
 For j = 0 To x - 1
  s = s & m(b + j) & " "
 Next
 Debug.Print s
Next
End Sub

Public Function krtAngle2VBangle(ByVal krtAng As Single) As Single
Dim x As Single

x = 2 * PI - krtAng + PI / 2
If x > (2 * PI) Then x = x - 2 * PI
krtAngle2VBangle = x
End Function

Public Function GetInsideType(ByVal dfktTypId As Integer) As EN_INT_TYPE
 GetInsideType = -1
 Select Case dfktTypId
  Case 4, 15, 19, 209, 213
    GetInsideType = IT_EXT
  Case 18, 200, 207, 208
    GetInsideType = IT_NA
 End Select
End Function

Public Function clearNewLine(txt As String) As String
If InStr(txt, vbCrLf) > 0 Then
  txt = Trim$(Replace(txt, vbCrLf, ""))
End If
If InStr(txt, vbNewLine) > 0 Then
  txt = Trim$(Replace(txt, vbNewLine, ""))
End If
clearNewLine = txt
End Function

Public Function readIntFromString(ByVal txt As String) As Integer
Dim rslt As String, i As Integer, s As String

rslt = "0"
i = 1
While i <= Len(txt)
  s = Mid(txt, i, 1)
  If IsNumeric(s) Then
    rslt = rslt & s
  Else
    readIntFromString = CInt(rslt)
    Exit Function
  End If
  i = i + 1
Wend

readIntFromString = CInt(rslt)
End Function

Public Function getDistFromRs(rs As Recordset, ByVal border As Long) As Long
Dim dst As Long

getDistFromRs = border
On Error GoTo skip_deleted1
reread:
dst = rs("dist")
GoTo cont1
skip_deleted1:
rs.MoveNext
If rs.EOF Then
 Exit Function
End If
GoTo reread
cont1:
On Error GoTo 0
getDistFromRs = dst
End Function
