VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDepth"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const MAX_PRCNT = 85

Private d_dltX As Long
Private d_dltY As Single
Private d_sensMin As Long
Private d_sensMax As Long
Private d_widthTop As Long
Private d_widthBottom As Long
Private d_thick As Long
Private d_mgn As clsMagnit
Private d_row As New clsDepthRow
Private d_explain As String
Private d_minPos1 As Long
Private d_minPos2 As Long

Public lastPrcntSlit As Long
Public dfktSize As New clsDefectSize

Property Get dltX() As Long
dltX = d_dltX
End Property

Property Let dltX(d As Long)
d_dltX = d
End Property

Property Get dltY() As Single
dltY = d_dltY
End Property

Property Let dltY(d As Single)
d_dltY = d
End Property

Property Get sensMin() As Long
sensMin = d_sensMin
End Property

Property Let sensMin(m As Long)
d_sensMin = m
End Property

Property Get sensMax() As Long
sensMax = d_sensMax
End Property

Property Let sensMax(m As Long)
d_sensMax = m
End Property

Property Get wallThick() As Long
wallThick = d_thick
End Property

Property Let wallThick(d As Long)
d_thick = d
End Property

Property Get magnit() As clsMagnit
Set magnit = d_mgn
End Property

Property Set magnit(d As clsMagnit)
Set d_mgn = d
End Property

Private Function alignPos(ByVal v As Long, ByVal strLen As Integer) As String
Dim sl As Integer, s As String

s = s & v
sl = Len(s)
While sl < strLen
 s = " " & s
 sl = sl + 1
Wend
alignPos = s
End Function

Private Function rowAmplitude( _
ByVal rowIndex As Long, _
sensArray() As Long, _
ByVal xSize As Long, _
ByVal h0 As Long _
) As Long
End Function

Property Get widthTop() As Long
widthTop = d_widthTop
End Property

Property Get widthBottom() As Long
widthBottom = d_widthBottom
End Property

Property Get explain() As String
explain = d_explain
End Property

Private Function CalcCommon( _
sensArray() As Long, _
ByVal xSize As Long, _
ByVal ysize As Long, _
ByVal h0 As Long, _
ByVal inside As Boolean, _
ByVal dfktLen As Long, _
ByVal yStart As Long, _
ByVal yEnd As Long, _
ByVal noWarn As Boolean, _
ByVal isTFI As Boolean, _
Optional SensType As KRT_SENS_TYPE = 0 _
) As Boolean

Dim i As Integer, amplMax As Long, lineIndex As Integer, border As Integer

CalcCommon = True

If yStart < 0 Then yStart = 0
If (yEnd < 0) Or (yEnd > (ysize - 1)) Then yEnd = ysize - 1

d_explain = "Общий размер массива " & xSize & " на " & ysize
d_explain = d_explain & vbNewLine & "Границы исследуемой области внутри массива: верхняя строка " & yStart & ", нижняя строка " & yEnd
d_explain = d_explain & vbNewLine & "Дефект " & IIf(inside, "внутренний", "внешний")
'Debug.Print "Data: " & xsize & " x " & ysize

d_explain = d_explain & vbNewLine & "Уровень h0 "
If h0 < 0 Then
 d_explain = d_explain & "определяется автоматически"
 Else
 d_explain = d_explain & "задан оператором и равен " & h0
End If

d_row.Init sensArray, xSize, -1

d_explain = d_explain & vbNewLine & "Определяем номер строки с максимальной амплитудой сигнала"
'определяем номер строки lineIndex с максимальной амплитудой сигнала
d_row.setIndex yStart, 0
amplMax = d_row.ampl
For i = yStart To yEnd
 d_row.setIndex i, 0
 d_explain = d_explain & vbNewLine & d_row.explain
 If amplMax < d_row.ampl Then
  d_explain = d_explain & vbNewLine & "Амплитуда этой строки имеет значение " & d_row.ampl & " и превышает предыдущую макс.амплитуду " & amplMax
  amplMax = d_row.ampl
  lineIndex = i
 End If
Next

border = 0
If isTFI Then
  border = 50
End If

If SensType = KRT_SENS_TYPE.SENS_TFI Then
  border = 50
End If

If SensType = KRT_SENS_TYPE.SENS_INTROSCOPE Then
  border = 10
End If

' строка с макс. амплитудой
d_row.Init sensArray, xSize, h0
d_row.setIndex lineIndex, border

d_explain = d_explain & vbNewLine & vbNewLine & "Строку " & lineIndex & " берем за расчетную строку" & vbNewLine
'd_explain = d_explain & vbNewLine & d_row.explain
'd_explain = d_explain & vbNewLine & d_row.explain_ext

'определение размеров дефекта
dfktSize.Init sensArray, xSize, ysize, Me.dltX, Me.dltY, Me.magnit

If dfktLen < 0 Then
 
 If dfktSize.Calculate(lineIndex, noWarn, border) = False Then
   CalcCommon = False
   Exit Function
 End If
 
 d_minPos1 = dfktSize.minPos1
 d_minPos2 = dfktSize.minPos2
 d_widthTop = dfktSize.widthTop
 d_widthBottom = dfktSize.widthBottom
 
 d_explain = d_explain & vbNewLine & dfktSize.get_explain()
 
 Else
 
 d_widthTop = yStart
 d_widthBottom = yEnd
 
 d_explain = d_explain & vbNewLine & "Длина дефекта задана оператором и составляет " & dfktLen & " мм"
 d_explain = d_explain & vbNewLine & "Ширина дефекта задана оператором с датчика " & Me.widthTop & " по датчик " & Me.widthBottom
 d_explain = d_explain & ": " & (Me.widthBottom - Me.widthTop) & " датчиков (" & CInt((Me.widthBottom - Me.widthTop) * Me.dltY) & " мм)"
 
End If

End Function

Public Function Calculate( _
sensArray() As Long, _
ByVal xSize As Long, _
ByVal ysize As Long, _
ByVal h0 As Long, _
ByVal inside As Boolean, _
ByVal dfktLen As Long, _
ByVal yStart As Long, _
ByVal yEnd As Long, _
ByVal noWarn As Boolean, _
ByVal isTFI As Boolean, _
Optional SensType As KRT_SENS_TYPE = 0 _
) As Integer

Dim k1 As Double, k2 As Double, prcnt As Integer
Dim kin As Double
If CalcCommon(sensArray, xSize, ysize, h0, inside, dfktLen, yStart, yEnd, noWarn, isTFI, SensType) = False Then
  Calculate = 0
  Exit Function
End If

'определяем глубину дефекта
h0 = d_row.h0 - Me.sensMin
k1 = d_row.ampl
If h0 = 0 Then
 k1 = 1
 Else
 k1 = k1 / h0
End If

If dfktLen < 0 Then
  dfktLen = dfktSize.dfkt_length
End If



d_explain = d_explain & vbNewLine & "Определяем глубину дефекта"
d_explain = d_explain & vbNewLine & "Отношение dH / h0 расчетной строки составляет " & d_row.ampl & " / " & h0 & " = " & dblStr(k1 * 100, 2) & " %"
''новый расчет
''для внутренних дефектов расчитываем коэффициент коррекции для отношения dH / h0
''из полинома,при длине дефекта более 50мм, К = 1
'If inside Then
'    kin = 1
'    If dfktLen <= 50 Then
'        kin = -3.36 * (10 ^ (-12)) * (dfktLen ^ 6) + 1.88 * (10 ^ (-9)) * (dfktLen ^ 5) - 4.15 * (10 ^ (-7)) * (dfktLen ^ 4) + 4.59 * (10 ^ (-5)) * (dfktLen ^ 3) - 2.65 * (10 ^ (-3)) * (dfktLen ^ 2) + 7.57 * (10 ^ (-2)) * dfktLen + 0.1313
'    End If
'    d_explain = d_explain & vbNewLine & _
'    "Дефект определен оператором как внутренний, поэтому найденныое тношение dH / h0 " & _
'    "корректируем коэффициентом преобразования К = " & dblStr(kin, 2)
'    d_explain = d_explain & vbNewLine & "(При длине дефекта более 50мм, К = 1)"
'    k1 = k1 * kin
'    d_explain = d_explain & vbNewLine & "Новое значение  dH / h0 * К составляет " & dblStr(k1 * 100, 2) & " %"
'End If

With Me
    k2 = .magnit.transPrcnt(.wallThick, dfktLen, (.widthBottom - .widthTop) * .dltY, k1 * 100)
    k1 = .magnit.lastPrcntSlit
    d_explain = d_explain & vbNewLine & .magnit.explain
End With


'старый расчет
Me.lastPrcntSlit = k1 * IIf(inside, 0.8, 1)
prcnt = k2 * IIf(inside, 0.8, 1)

If inside Then
 d_explain = d_explain & vbNewLine & _
 "Дефект определен оператором как внутренний, поэтому найденный процент глубины " & dblStr(k2, 2) & _
 " с понижающим коэф-том преобразуем в " & dblStr(prcnt, 2)
 d_explain = d_explain & vbNewLine & _
 "для канавки: " & dblStr(k1, 2) & " -> " & dblStr(Me.lastPrcntSlit, 2)
End If

''новый расчет т.к. пресчитываем - dH / h0 * kin
'Me.lastPrcntSlit = k1
'prcnt = k2
'
'If inside Then
' d_explain = d_explain & vbNewLine & _
' "Найденный процент глубины " & dblStr(prcnt, 2)
' d_explain = d_explain & vbNewLine & _
' "для канавки: & dblStr(Me.lastPrcntSlit, 2)"
'End If



If prcnt > MAX_PRCNT Then
 d_explain = d_explain & vbNewLine & _
 "Найденный процент глубины " & dblStr(prcnt, 2) & _
 " превышает макс.процент " & MAX_PRCNT & _
 ", поэтому в качестве окончательного берем макс.процент " & MAX_PRCNT
End If

Calculate = IIf(prcnt > MAX_PRCNT, MAX_PRCNT, prcnt)
End Function

Public Function CalcDent( _
sensArray() As Long, _
ByVal xSize As Long, _
ByVal ysize As Long, _
ByVal h0 As Long, _
ByVal dfktLen As Long, _
ByVal yStart As Long, _
ByVal yEnd As Long, _
ByVal noWarn As Boolean _
) As Integer

If CalcCommon(sensArray, xSize, ysize, h0, False, dfktLen, yStart, yEnd, noWarn, False) = False Then
  CalcDent = 0
  Exit Function
End If

CalcDent = d_row.ampl
End Function

Property Get minPos1() As Long
minPos1 = d_minPos1
End Property

Property Get minPos2() As Long
minPos2 = d_minPos2
End Property

Property Get dfktLen() As Long
dfktLen = Me.minPos2 - Me.minPos1
End Property

Property Get lineNumber() As Integer
lineNumber = d_row.indx
End Property

Property Get maxPos() As Long
maxPos = d_row.maxPos()
End Property

Property Get Amplitude() As Long
Amplitude = d_row.ampl
End Property

Property Get h0() As Long
h0 = d_row.h0
End Property
