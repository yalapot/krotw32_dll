VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDepthRow"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Enum errConst
 NO_ERROR
End Enum

Private errCode As errConst
Private extError As String

Private d_h0 As Long
Private d_h0Calced As Long
Private d_xsize As Long
Private d_sensArray() As Long
Private d_reverseSignal As Boolean

Private d_indx As Long
Private d_ampl As Long
Private d_maxPos As Long
Private d_posLeft As Long
Private d_posRight As Long
Private d_explain As String
Private d_explain_ext As String

Property Get errText() As String
Select Case errCode

 Case NO_ERROR
  errText = "Все хорошо"

 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property

Public Sub Init( _
sensArray() As Long, _
ByVal xsize As Long, _
ByVal h0 As Long, _
Optional ByVal reverseSignal As Boolean = False _
)
d_h0 = h0
d_xsize = xsize
d_sensArray = sensArray
d_reverseSignal = reverseSignal

d_indx = -1
d_ampl = -1
d_maxPos = -1
d_posLeft = -1
d_posRight = -1
End Sub

Property Get explain() As String
explain = d_explain
End Property

Property Get explain_ext() As String
explain_ext = d_explain_ext
End Property

Private Function getAmpl(ByVal h0 As Long, ByVal signal As Long) As Long
 If d_reverseSignal Then
  getAmpl = h0 - signal
 Else
  getAmpl = signal - h0
 End If
End Function

Public Sub setIndex(ByVal indx As Long, ByVal border_percent As Integer, Optional debug_print As Boolean = False)
Dim h1 As Long, h2 As Long, baseIndex As Long, i As Long, ampl As Long, a1 As Long
Dim r_str As String, border As Long

d_indx = indx
d_explain = "Строка " & d_indx
'индекс начала строки в массиве
baseIndex = d_indx * d_xsize

If baseIndex > (UBound(d_sensArray) - d_xsize) Then
  baseIndex = UBound(d_sensArray) - d_xsize
End If

If baseIndex < 0 Then
  baseIndex = 0
End If

On Error GoTo errHandler

' если h0 не задано, рассчитать его как среднее из значений на границах строки
d_explain = d_explain & " h0 "
If d_h0 < 0 Then
 h1 = d_sensArray(baseIndex)
 d_h0Calced = h1
 d_explain = d_explain & "= " & d_h0Calced
 'h2 = d_sensArray(baseIndex + d_xsize - 1)
 'd_h0Calced = (h1 + h2) / 2     'h1
 'd_explain = d_explain & "= (" & h1 & " + " & h2 & ") / 2 = " & d_h0Calced
 Else
 d_h0Calced = d_h0
 d_explain = d_explain & "фиксировано и равно " & d_h0Calced
End If

'найти максимальную амплитуду
r_str = ""
d_ampl = 0
For i = 0 To d_xsize - 1
 ampl = getAmpl(d_h0Calced, d_sensArray(baseIndex + i))
 r_str = r_str & i & " -> " & d_sensArray(baseIndex + i) & " (" & ampl & ")" & vbNewLine
 If ampl > d_ampl Then
  d_ampl = ampl
  d_maxPos = i
 End If
Next
 
If d_maxPos < 0 Then d_maxPos = d_xsize / 2
d_explain = d_explain & " макс.всплеск " & d_ampl & " на измерении " & d_maxPos

'определить границы дефекта по длине
If border_percent > 0 Then
  d_explain = d_explain & " TFI "
  border = d_ampl * border_percent / 100
Else
  border = 0
End If

If debug_print Then d_explain = d_explain & vbNewLine & "Значения в этой строке (амплитуды)" & vbNewLine & r_str
If debug_print Then d_explain = d_explain & vbNewLine & "Процент затухания по длине " & border_percent & " значение от расчетной амплитуды " & border & vbNewLine

'начало дефекта (до максимума)
If debug_print Then d_explain = d_explain & vbNewLine & "Поиск начала дефекта" & vbNewLine

d_posLeft = 0
For i = d_maxPos - 1 To 0 Step -1
 a1 = getAmpl(d_h0Calced, d_sensArray(baseIndex + i))
 ampl = a1 - border
 If debug_print Then d_explain = d_explain & "измерение " & i & " => " & d_sensArray(baseIndex + i) & " амплитуда " & a1 & " - " & border & " = " & ampl & vbNewLine
 
 If ampl < 0 Then
  d_posLeft = i + 1
  Exit For
 End If
Next

If debug_print Then d_explain = d_explain & vbNewLine & "начало на измерении " & d_posLeft & vbNewLine

'конец дефекта (после максимума)
If debug_print Then d_explain = d_explain & vbNewLine & "Поиск конца дефекта" & vbNewLine

d_posRight = d_xsize - 1
For i = d_maxPos + 1 To d_xsize - 1
 a1 = getAmpl(d_h0Calced, d_sensArray(baseIndex + i))
 ampl = a1 - border
 If debug_print Then d_explain = d_explain & "измерение " & i & " => " & d_sensArray(baseIndex + i) & " амплитуда " & a1 & " - " & border & " = " & ampl & vbNewLine
 
 If ampl < 0 Then
  d_posRight = i - 1
  Exit For
 End If
Next

If debug_print Then d_explain = d_explain & vbNewLine & "конец на измерении " & d_posRight & vbNewLine

Exit Sub
errHandler:

On Error GoTo 0
ogdWin.Alert "error: clsDepthRow.SetIndex" & vbNewLine & _
"indx: " & indx & vbNewLine & _
"d_sensArray x_size: " & d_xsize & vbNewLine & _
"d_sensArray size: " & UBound(d_sensArray)

End Sub

Public Function amplAtPos(ByVal pos As Long) As Long
amplAtPos = getAmpl(d_h0Calced, Me.getSignal(pos))
End Function

Public Function getSignal(pos As Long) As Long
On Error GoTo errHandler
getSignal = d_sensArray(Me.indx * d_xsize + pos)
On Error GoTo 0
Exit Function

errHandler:
'ogdWin.Alert "getSignal: Me.indx " & Me.indx & " d_xsize " & d_xsize & " pos " & pos & vbNewLine & "UBound(d_sensArray): " & UBound(d_sensArray)
' !!!! to log
getSignal = d_sensArray(UBound(d_sensArray) - 1)
End Function

Property Get h0() As Long
h0 = d_h0Calced
End Property

Property Get indx() As Long
indx = d_indx
End Property

Property Get ampl() As Long
ampl = d_ampl
End Property

Property Get maxPos() As Long
maxPos = d_maxPos
End Property

Property Get posRight() As Long
posRight = d_posRight
End Property

Property Get posLeft() As Long
posLeft = d_posLeft
End Property

Property Get dfktLen() As Long
dfktLen = Me.posRight - Me.posLeft
End Property

Property Get xSize() As Long
xSize = d_xsize
End Property
