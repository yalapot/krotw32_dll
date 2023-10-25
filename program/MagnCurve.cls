VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMagnCurve"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const SIZE_DELIM = "|"
Private Const DELIM_NODE = ";"
Private Const DELIM_VAL = ":"

Private Type T_curve_node
x As Double
y As Double
End Type

Private pars As New clsCommandLine
Private pars1 As New clsCommandLine
Private curveData() As T_curve_node
Private d_explain As String

Public keymm As Integer

Private Function distToLine(ByVal lineIndex As Integer, ByVal x As Double, ByVal y As Double) As Double
Dim x1 As Double, y1 As Double, x2 As Double, y2 As Double
Dim a As Double, b As Double, c As Double, cosc As Double

'координаты концов сегмента
x1 = Me.x(lineIndex - 1)
y1 = Me.y(lineIndex - 1)
x2 = Me.x(lineIndex)
y2 = Me.y(lineIndex)

'длины сторон треугольника образуемого сегментом и заданной точкой
a = dist(x1, y1, x, y)
b = dist(x1, y1, x2, y2)
c = dist(x2, y2, x, y)

If b = 0 Then 'если сегмент - точка
 distToLine = a
 Exit Function
End If

'косинус угла между сегментом и линией из начала сегмента в заданную точку
cosc = (a ^ 2 + b ^ 2 - c ^ 2) / (2 * a * b)

'если угол тупой, то ближайшее расстояние до сегмента - одна из сторон
'треугольника с вершиной в заданной точке
If cosc <= 0 Then
 distToLine = IIf(a > c, c, a)
 Exit Function
End If
'иначе - длина перпендикуляра из заданной точки к сегменту
distToLine = Sqr(a ^ 2 - (a * cosc) ^ 2)
End Function

Property Get explain() As String
explain = d_explain
End Property

Public Function distTo(ByVal x As Double, ByVal y As Double) As Double
Dim i As Integer, minDst As Double, dst As Double

d_explain = "Определяем расстояние от точки X = " & dblStr(x, 2) & " Y = " & dblStr(y, 2) & " до кривой " & Me.keymm & " мм"
If Me.count <= 0 Then
 d_explain = "Кривая пуста!"
 Err.Raise ERR_EMPTDIAMCURVE, "clsMagnCurve", "Empty curve"
 Exit Function
End If

If Me.count = 1 Then
 distTo = dist(x, y, Me.x(0), Me.y(0))
 d_explain = d_explain & vbNewLine & "Кривая состоит из одной точки. Расстояние до нее = " & dblStr(distTo, 2)
 Exit Function
End If

minDst = distToLine(1, x, y)
d_explain = d_explain & vbNewLine & "Расстояние до сегмента 1 = " & minDst
For i = 2 To Me.count - 1
 dst = distToLine(i, x, y)
 d_explain = d_explain & vbNewLine & "Расстояние до сегмента " & i & " = " & dst
 If dst < minDst Then minDst = dst
Next
d_explain = d_explain & vbNewLine & "Минимальное расстояние до кривой = " & minDst
distTo = minDst
End Function

Property Get dataString() As String
Dim i As Integer, s As String

s = ""
For i = 0 To Me.count - 1
 If Len(s) > 0 Then s = s & DELIM_NODE
 s = s & curveData(i).x & DELIM_VAL & dblStr(curveData(i).y, 1)
Next
dataString = Me.keymm & SIZE_DELIM & s
End Property

Property Let dataString(s As String)
Dim i As Integer

i = InStr(s, SIZE_DELIM)
If i > 0 Then
 Me.keymm = val(Left(s, i - 1))
 s = Right(s, Len(s) - i)
 Else
 Me.keymm = 0
End If

pars1.Delim = DELIM_NODE
pars1.TestString = pars1.Delim & s
pars1.Parse
ReDim curveData(pars1.count) As T_curve_node

For i = 1 To pars1.count
 pars.Delim = DELIM_VAL
 pars.TestString = pars.Delim & pars1.Item(i)
 pars.Parse
 curveData(i - 1).x = val(pars.Item(1))
 curveData(i - 1).y = val(pars.Item(2))
Next
End Property

Property Get Clone() As clsMagnCurve
Set Clone = New clsMagnCurve
End Property

Property Get count() As Integer
count = UBound(curveData)
End Property

Property Let count(c As Integer)
ReDim Preserve curveData(c) As T_curve_node
End Property

Property Get x(ByVal indx As Integer) As Double
x = curveData(indx).x
End Property

Property Let x(ByVal indx As Integer, r As Double)
curveData(indx).x = r
End Property

Property Get y(ByVal indx As Integer) As Double
y = curveData(indx).y
End Property

Property Let y(ByVal indx As Integer, r As Double)
curveData(indx).y = r
End Property

Private Sub Class_Initialize()
keymm = 0
ReDim curveData(0) As T_curve_node
End Sub

Public Function getValue(ByVal prcnt As Double) As Double
Dim indx As Integer, pStr As String
Dim vMin As Double, vMax As Double, rMin As Double, rMax As Double

pStr = dblStr(prcnt, 2)
d_explain = d_explain & vbNewLine & "Ищем сегмент кривой для диаметра " & Me.keymm & " мм, соответствующий значению отношения dltH/h0 = " & pStr

indx = -1
Do
 indx = indx + 1
 
 If indx > Me.count Then Exit Do
 d_explain = d_explain & vbNewLine & "Точка " & indx & " имеет значение " & dblStr(Me.x(indx), 2) & " %"
 
Loop While prcnt > Me.x(indx)

d_explain = d_explain & vbNewLine & "Переданное отношение dltH/h0 = " & pStr & " находится "

Select Case indx

 Case Is <= 0
  d_explain = d_explain & " левее первого сегмента кривой."
  d_explain = d_explain & vbNewLine & "Используем значение крайней левой точки кривой X = " & dblStr(Me.x(indx), 2) & ", Y = " & dblStr(Me.y(indx), 2)
  getValue = Me.y(indx)

 Case Is > Me.count
  d_explain = d_explain & " правее последнего сегмента кривой."
  d_explain = d_explain & vbNewLine & "Используем значение крайней правой точки кривой X = " & dblStr(Me.x(Me.count - 1), 2) & ", Y = " & dblStr(Me.y(Me.count - 1), 2)
  getValue = Me.y(Me.count - 1)

 Case Else
  vMax = Me.y(indx)
  rMax = Me.x(indx)
  vMin = Me.y(indx - 1)
  rMin = Me.x(indx - 1)
  d_explain = d_explain & " на сегменте кривой между точками " & (indx - 1) & " и " & indx
  d_explain = d_explain & vbNewLine & "Значения этих точек: X1 = " & rMin & " Y1 = " & vMin & ", X2 = " & rMax & " Y2 = " & vMax
  If ((rMax - rMin) + vMin) = 0 Then
    getValue = 0
    d_explain = d_explain & vbNewLine & "В пропорции знаменатель == 0, берем значение равное 0%"
  Else
    getValue = (prcnt - rMin) * (vMax - vMin) / (rMax - rMin) + vMin
    d_explain = d_explain & vbNewLine & "Искомое значение находим пропорцией, оно равно " & dblStr(getValue, 2)
  End If
End Select

End Function
