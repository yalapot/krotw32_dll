VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDefectSize"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_explain As String
Private d_x As Long
Private d_y As Long
Private d_xstep As Long
Private d_ystep As Single
Private d_row As New clsDepthRow
Private d_row_tfi_src As New clsDepthRow
Private d_magnit As clsMagnit

Public minPos1 As Long
Public minPos2 As Long

Public widthTop As Long
Public widthBottom As Long

Public posLeft As Integer
Public posRight As Integer

Public Sub Init( _
sensArray() As Long, _
ByVal xSize As Long, _
ByVal ysize As Long, _
ByVal xstep As Long, _
ByVal ystep As Single, _
magnit As clsMagnit _
)

Set d_magnit = magnit
d_x = xSize
d_y = ysize
d_xstep = xstep
d_ystep = ystep
d_row.Init sensArray, xSize, -1

d_explain = ""
minPos1 = -1
minPos2 = -1
widthTop = -1
widthBottom = -1
End Sub

Public Function max_pos() As Long
max_pos = d_row.maxPos()
End Function

Public Function get_explain() As String
get_explain = d_explain
End Function

Property Get dfkt_length() As Long
dfkt_length = minPos2 - minPos1
End Property

Private Function get_minPos1(ByVal border As Long) As Long
Dim v1 As Long, v2 As Long, dlt As Long

If d_row.posLeft = 0 Then
  get_minPos1 = 0
  Exit Function
End If

v2 = d_row.getSignal(d_row.posLeft)
v1 = d_row.getSignal(d_row.posLeft - 1)
If v2 <= v1 Then
  dlt = 0
Else
  dlt = d_xstep * (v2 - border) / (v2 - v1)
End If

If dlt > 0 Then
  d_explain = d_explain & "Начало дефекта смещено влево на " & dlt & " мм согласно конфигурации фронта сигнала." & vbNewLine
End If

get_minPos1 = d_row.posLeft * d_xstep - dlt
End Function

Private Function get_minPos2(ByVal border As Long) As Long
Dim v1 As Long, v2 As Long, dlt As Long

If d_row.posRight = d_row.xSize Then
  get_minPos2 = d_row.posRight * d_xstep
  Exit Function
End If

v1 = d_row.getSignal(d_row.posRight + 1)
v2 = d_row.getSignal(d_row.posRight)
If v2 <= v1 Then
  dlt = 0
Else
  dlt = d_xstep * (v2 - border) / (v2 - v1)
End If

If dlt > 0 Then
  d_explain = d_explain & "Конец дефекта смещен вправо на " & dlt & " мм согласно конфигурации фронта сигнала." & vbNewLine
End If

get_minPos2 = d_row.posRight * d_xstep + dlt
End Function

Private Function isLevelTooLow( _
ByVal amplMax As Long, _
ByVal amplPos As Long, _
ByVal lineIndex As Integer, _
magnit As clsMagnit _
) As Boolean
'isLevelTooLow = True
'Exit Function

d_row.setIndex lineIndex, 0
If d_magnit.dfktWidthMode = 0 Then
  isLevelTooLow = (d_row.amplAtPos(amplPos) * 100) < (d_magnit.lowDefektResponsePrcnt * amplMax)
  d_explain = d_explain & vbNewLine & "Для строки " & lineIndex & " на позиции " & amplPos & " амплитуда равна " & d_row.amplAtPos(amplPos)
Else
  isLevelTooLow = d_row.amplAtPos(amplPos) < d_magnit.dfktWidthADC
  d_explain = d_explain & vbNewLine & "Для строки " & lineIndex & " на позиции " & amplPos & " уровень всплеска сигнала " & d_row.amplAtPos(amplPos)
End If
End Function

Public Function Calculate(ByVal lineIndex As Long, ByVal noWarn As Boolean, ByVal border As Long) As Boolean
Dim i As Integer, amplMax As Long, amplPos As Long, s As String, brd As Long

Calculate = True
d_explain = "Определяем длину дефекта на строке " & lineIndex & " c процентом затухания " & border & vbNewLine

d_row.setIndex lineIndex, border, True
posLeft = d_row.posLeft
posRight = d_row.posRight

d_explain = d_explain & d_row.explain & vbNewLine
d_explain = d_explain & "Дефект находится между измерениями " & posLeft & " и " & posRight & " = " & posRight - posLeft & " измерений." & "Шаг измерения " & d_xstep & " мм." & vbNewLine

brd = d_row.h0
If border > 0 Then
  brd = d_row.h0 + d_row.ampl * border / 100
End If

minPos1 = get_minPos1(brd)
minPos2 = get_minPos2(brd)

d_explain = d_explain & "Длина дефекта " & Me.dfkt_length & " мм." & vbNewLine

'определяем ширину дефекта
amplMax = d_row.ampl 'амплитуда расчетной строки дефекта
amplPos = d_row.maxPos 'позиция максимума амплитуды в расчетной строке дефекта

'd_explain = d_explain & vbNewLine & vbNewLine & "----------------------"
'd_explain = d_explain & vbNewLine & "Номер столбца с максимумом сигнала " & amplPos
'd_explain = d_explain & vbNewLine & "Значения в этом столбце минус значения из первого столбца"
'For i = 0 To d_y - 1
'  d_row.setIndex i, border
'  d_explain = d_explain & vbNewLine & "Строка " & i & ": " & d_row.getSignal(amplPos) & " - " & d_row.h0 & " = " & (d_row.getSignal(amplPos) - d_row.h0)
'Next
'd_explain = d_explain & vbNewLine & "----------------------" & vbNewLine

d_explain = d_explain & vbNewLine & "Определяем ширину дефекта с центром в точке " & amplPos & ":" & lineIndex & " и макс.амплитудой " & amplMax
If d_magnit.dfktWidthMode = 0 Then
  d_explain = d_explain & vbNewLine & "При пороге затухания " & d_magnit.lowDefektResponsePrcnt & "%, пороговое значение амплитуды равно " & (amplMax / d_magnit.lowDefektResponsePrcnt)
Else
  d_explain = d_explain & vbNewLine & "Пороговое значение всплеска сигнала для области дефекта в единицах АЦП " & d_magnit.dfktWidthADC
End If
'Debug.Print "Dfkt x:" & amplPos & " y: " & lineIndex & " ampl: " & amplMax

d_explain = d_explain & vbNewLine & "Ищем верхнюю границу дефекта"
s = "Порог затухания не достигнут, за верхнюю границу дефекта принимаем верхнюю границу расчетной области (0)."
'идем от расчетной строки вверх, до нахождения верхней границы дефекта
For i = lineIndex To 0 Step -1
 'если амплитуда текущей строки на позиции максимума расчетной строки меньше порогового значения
 'считаем предыдущую строку верхней границей дефекта
 If isLevelTooLow(amplMax, amplPos, i, d_magnit) Then
  widthTop = i + 1
  s = "Достигнут порог затухания, верхняя граница дефекта строка " & widthTop
  Exit For
  Else
  widthTop = i
 End If
Next
d_explain = d_explain & vbNewLine & s

d_explain = d_explain & vbNewLine & "Ищем нижнюю границу дефекта"
s = "Порог затухания не достигнут, за нижнюю границу дефекта принимаем нижнюю границу расчетной области (" & (d_y - 1) & ")."
'идем от расчетной строки вниз, до нахождения нижней границы дефекта
For i = lineIndex To d_y - 1
 'если амплитуда текущей строки на позиции максимума расчетной строки меньше порогового значения
 'считаем предыдущую строку нижней границей дефекта
 If isLevelTooLow(amplMax, amplPos, i, d_magnit) Then
  widthBottom = i
  s = "Достигнут порог затухания, нижняя граница дефекта строка " & widthBottom
  Exit For
  Else
  widthBottom = i
 End If
Next
d_explain = d_explain & vbNewLine & s

'проверить на нулевую ширину
i = Me.widthBottom - Me.widthTop
If i <= 0 Then

 d_explain = d_explain & vbNewLine & _
 vbNewLine & "!!! ПРЕДУПРЕЖДЕНИЕ !!! ПОЛУЧЕНА НУЛЕВАЯ ШИРИНА ДЕФЕКТА" & vbNewLine & _
 "Глубина дефекта установлена в 0 %"
 
 If noWarn = False Then
   ogdWin.Alert "Порог затухания сигнала по ширине дефекта , установленный в настройках магнитной системы этой записи," & vbNewLine _
   & "либо значение h0 на этом участке записи," & vbNewLine _
   & "превышает максимальное значение амплитуды в этом дефекте." & vbNewLine _
   & "Ширина и глубина дефекта считаются нулевыми"
 End If
 
 Calculate = False
 Exit Function
End If

End Function
