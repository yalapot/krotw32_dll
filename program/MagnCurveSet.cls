VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMagnCurveSet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_curve As New Collection
Private d_objProto As clsMagnCurve
Private d_explain As String

Private d_domain_x1 As Double
Private d_domain_y1 As Double
Private d_domain_x2 As Double
Private d_domain_y2 As Double

Public title As String

Property Get domain_x1() As Double
domain_x1 = d_domain_x1
End Property

Property Get domain_x2() As Double
domain_x2 = d_domain_x2
End Property

Property Get domain_y1() As Double
domain_y1 = d_domain_y1
End Property

Property Get domain_y2() As Double
domain_y2 = d_domain_y2
End Property

Property Get explain() As String
explain = d_explain
End Property

Public Sub Init(obj As clsMagnCurve)
Set d_objProto = obj
End Sub

Property Get newCurve() As clsMagnCurve
Dim c As clsMagnCurve

Set c = d_objProto.Clone
If Me.count = 0 Then
 c.keymm = 10
 Else
 c.keymm = Me.curve_by_index(Me.count).keymm + 10
End If

Set newCurve = c
End Property

Property Get count() As Integer
count = d_curve.count
End Property

Public Sub Clear()
clearCollection d_curve
End Sub

Property Get curve_by_index(ByVal indx As Integer) As clsMagnCurve
Set curve_by_index = d_curve(indx)
End Property

Public Function outOfDomain(ByVal x As Double, ByVal y As Double) As Boolean
Dim c As clsMagnCurve, i As Integer

d_domain_x1 = 1000000
d_domain_y1 = d_domain_x1
d_domain_x2 = -1000000
d_domain_y2 = d_domain_x2

For i = 1 To d_curve.count
 Set c = d_curve(i)
 If c.x(0) < d_domain_x1 Then d_domain_x1 = c.x(0)
 If c.x(c.count - 1) > d_domain_x2 Then d_domain_x2 = c.x(c.count - 1)
 If c.y(0) < d_domain_y1 Then d_domain_y1 = c.y(0)
 If c.y(c.count - 1) > d_domain_y2 Then d_domain_y2 = c.y(c.count - 1)
Next i

outOfDomain = Not ((x >= d_domain_x1) And (x <= d_domain_x2) And (y >= d_domain_y1) And (y <= d_domain_y2))
End Function

' функция возвращает кривую из набора, у которой на отметке X, значение по Y ближе всего к параметру y.
' параметр isGreater задает сторону, с которой идет приближение к значению y - если со стороны больших значений, то параметр равен True
Public Function curveByX(ByVal x As Double, ByVal y As Double, ByVal isGreater As Boolean) As clsMagnCurve
Dim c As clsMagnCurve, i As Integer, upIndex As Integer, dnIndex As Integer, upDelta As Double, dnDelta As Double, dlt As Double
Dim cur_y As Double, s As String

upDelta = 0
dnDelta = 0
upIndex = -1
dnIndex = -1

d_explain = "Кривых в наборе: " & d_curve.count
d_explain = d_explain & vbNewLine & "Определяем значения каждой кривой в точке X=" & dblStr(x, 2) & " и выбираем значение, ближайшее к Y=" & dblStr(y, 2) & " со стороны " & IIf(isGreater, "больших", "меньших") & " значений."

For i = 1 To d_curve.count
 Set c = d_curve(i)
 cur_y = c.getValue(x)
 dlt = cur_y - y
 d_explain = d_explain & vbNewLine & "кривая " & i & " диам: " & c.keymm & " y=" & dblStr(cur_y, 2) & " дельта " & dlt
 d_explain = d_explain & vbNewLine & c.explain
 
 If dlt = 0 Then
   d_explain = d_explain & vbNewLine & "Для кривой диам: " & c.keymm & " найдено точное совпадение, используем эту кривую."
   Set curveByX = c
   Exit Function
 End If
 
 If dlt > 0 Then
   If upIndex < 0 Then
     upDelta = dlt
     upIndex = i
   Else
     If dlt < upDelta Then
       upDelta = dlt
       upIndex = i
     End If
   End If
 Else
   If dnIndex < 0 Then
     dnDelta = dlt
     dnIndex = i
   Else
     If dlt > dnDelta Then
       dnDelta = dlt
       dnIndex = i
     End If
   End If
 End If

 s = "не определена"
 If upIndex >= 0 Then
   s = d_curve(upIndex).keymm & " дельта " & dblStr(upDelta, 2)
 End If
 d_explain = d_explain & vbNewLine & "Ближайшая верхняя кривая " & s
 
 s = "не определена"
 If dnIndex >= 0 Then
   s = d_curve(dnIndex).keymm & " дельта " & dblStr(dnDelta, 2)
 End If
 d_explain = d_explain & vbNewLine & "Ближайшая нижняя кривая " & s

Next i

If upIndex < 0 Then
 upIndex = dnIndex
End If
If dnIndex < 0 Then
 dnIndex = upIndex
End If

d_explain = d_explain & vbNewLine & "Конечный результат:"
d_explain = d_explain & vbNewLine & "Ближайшая верхняя кривая диам: " & d_curve(upIndex).keymm & " дельта " & dblStr(upDelta, 2)
d_explain = d_explain & vbNewLine & "Ближайшая нижняя кривая диам: " & d_curve(dnIndex).keymm & " дельта " & dblStr(dnDelta, 2)
d_explain = d_explain & vbNewLine & "Выбираем ближайшую " & IIf(isGreater, "верхнюю", "нижнюю") & " кривую."

'Debug.Print "Curve key " & d_curve(i).keymm & " for " & mm & " isGreater=" & isGreater
Set curveByX = d_curve(IIf(isGreater, upIndex, dnIndex))
End Function

' функция возвращает кривую из набора, значение ключа которой ближе всего к параметру mm
' параметр isGreater задает сторону, с которой идет приближение к значению mm - если со стороны больших значений, то параметр равен True
Public Function curveByMm(ByVal mm As Integer, ByVal isGreater As Boolean) As clsMagnCurve
Dim c As clsMagnCurve, i As Integer, keys() As Integer, outOfCurves As Boolean

outOfCurves = True

For i = 1 To d_curve.count
 Set c = d_curve(i)
 If c.keymm >= mm Then
   outOfCurves = False
   Exit For
 End If
Next i

If outOfCurves Then

  i = d_curve.count

  Else
  
  If isGreater = False Then
    If i > 1 Then
      If d_curve(i).keymm > mm Then
        i = i - 1
      End If
    End If
  End If

End If

'Debug.Print "Curve key " & d_curve(i).keymm & " for " & mm & " isGreater=" & isGreater
Set curveByMm = d_curve(i)
End Function

Public Function nearestCurve(ByVal x As Double, ByVal y As Double) As clsMagnCurve
Dim i As Integer, indx As Integer, dst As Double, minDist As Double

If Me.count = 0 Then
 d_explain = "Набор кривых пуст!"
 Err.Raise ERR_NODIAMCURVE, "clsMagnCurveSet", "Empty curve set"
 Exit Function
End If

'If Me.x(Me.count - 1) < x Then
' indx = Me.count - 1
' Exit Function
'Else

   d_explain = "Определяем расстояния от каждой кривой в наборе до точки с координатами X = " & dblStr(x, 2) & " мм2, Y = " & dblStr(y, 2) & " %"

   indx = 1
   minDist = Me.curve_by_index(indx).distTo(x, y)
   d_explain = d_explain & vbNewLine & Me.curve_by_index(indx).explain
   d_explain = d_explain & vbNewLine & "Расстояние до кривой " & indx & " = " & minDist

   For i = 2 To Me.count
    dst = Me.curve_by_index(i).distTo(x, y)
    d_explain = d_explain & vbNewLine & Me.curve_by_index(i).explain
    d_explain = d_explain & vbNewLine & "Расстояние до кривой " & i & " = " & dst
    
    If Abs(dst) < Abs(minDist) Then
     indx = i
     minDist = dst
    End If
   Next
'End If

d_explain = d_explain & vbNewLine & "Заданная точка ближе всего (" & minDist & ") к кривой " & indx
Set nearestCurve = Me.curve_by_index(indx)
End Function

Public Sub Sort()
Dim tmp As New Collection, c As clsMagnCurve

For Each c In d_curve
 tmp.Add c
Next
Me.Clear
For Each c In tmp
 Me.addCurve c
Next
End Sub

Public Function addCurve(crv As clsMagnCurve) As Boolean
Dim c As clsMagnCurve, i As Integer

addCurve = True

For i = 1 To d_curve.count
 Set c = d_curve(i)
 If c.keymm > crv.keymm Then
  d_curve.Add crv, CStr(crv.keymm), i
  Exit Function
 End If
Next i

On Error GoTo addCurveErr
d_curve.Add crv, CStr(crv.keymm)
Exit Function

addCurveErr:
ogdWin.Alert "Can't add magnet curve " & crv.keymm & " mm. Duplicate/wrong curve key?"
On Error GoTo 0
addCurve = False
End Function

Public Function delCurve(ByVal keymm As Integer) As Boolean
Dim i As Integer

delCurve = False
i = getCurveMmIndex(keymm)
If i >= 0 Then
 d_curve.Remove i
 delCurve = True
 Exit Function
End If
End Function

Private Function getCurveMmIndex(ByVal mm As Integer) As Integer
Dim c As clsMagnCurve, i As Integer, dlt As Integer, curr_dlt As Integer

dlt = Abs(mm - d_curve(1).keymm)
getCurveMmIndex = 1

For i = 2 To d_curve.count
 Set c = d_curve(i)
 curr_dlt = Abs(mm - d_curve(i).keymm)
 If curr_dlt < dlt Then
  dlt = curr_dlt
  getCurveMmIndex = i
 End If
Next i
End Function
