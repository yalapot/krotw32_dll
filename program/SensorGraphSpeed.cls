VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorGraphSpeed"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements clsSensorGraph
Implements clsSensor

Private Const ampl = 100

Private graph As clsSensorGraph
Private trc As clsTrace

Private minPageVal As Long
Private maxPageVal As Long
Private dataStart As Long
Private dataLength As Long
Private dataLengthMax As Long
Private dataArray() As T_NODEDATA
Private dataNodes As Long

Private d_markW As Long
Private d_markB As Long
Private d_markWpos As Long
Private d_markBpos As Long

Public Sub Init( _
trace As clsTrace, _
ByVal iniKeyName As String, _
ByVal nam As String, _
ByVal vMin As Long, _
ByVal vMax As Long _
)

Set trc = trace
graph.Init trc, SENS_SPEED, iniKeyName, nam, IIf(trc.Timer.num > 0, 1, 0), vMin * ampl, vMax * ampl, False, True
End Sub

Private Function fillArray() As Boolean
Dim dat As T_NODEDATA, dataEnd As Long, lastPos As Long, i As Long
Dim y As Single

fillArray = False

If krotGetFirstNode(trc.handle, dat, dataStart, SENS_TIMER, -1, 0, 0) = KRT_ERR Then Exit Function
If krotLockNodeSequence(trc.handle, 1) = KRT_ERR Then
 ogdWin.Alert "Не могу включить режим блокировки" & vbNewLine & lastError()
 Exit Function
End If

dataEnd = dataStart + dataLength
dataNodes = 0
lastPos = -1

While (dat.prevPos <= dataEnd) And (lastPos <> dat.prevPos)
 dataArray(dataNodes).prevPos = dat.prevPos
 lastPos = dat.prevPos
 dataNodes = dataNodes + 1
 If krotGetNextNode(trc.handle, dat) = KRT_ERR Then Exit Function
Wend
dataArray(dataNodes).prevPos = dat.prevPos
dataNodes = dataNodes + 1
If krotLockNodeSequence(trc.handle, 0) = KRT_ERR Then
 ogdWin.Alert "Не могу выключить режим блокировки" & vbNewLine & lastError()
 Exit Function
End If

minPageVal = graph.valMax
maxPageVal = graph.valMin

For i = 0 To dataNodes - 1
 y = Me.atDist(dataArray(i).prevPos)
 'If Y >= 0 Then
  dataArray(i).sensVal = Y
  If Y < minPageVal Then minPageVal = Y
  If Y > maxPageVal Then maxPageVal = Y
  'Else
  'Exit Function
 'End If
Next

fillArray = True
End Function

Public Function atDist(ByVal dst As Long) As Long
Dim dat As T_NODEDATA, hlf As Long, x1 As Long, x2 As Long, y1 As Long, y2 As Long
Dim lastPos As Long, i As Long
Dim y As Single

atDist = 0
hlf = trc.speedVector * SV_AMPL / 2
x1 = dst - hlf
If x1 < 0 Then x1 = 0
If krotGetFirstNode(trc.handle, dat, x1, SENS_TIMER, -1, 0, 0) = KRT_ERR Then
 ogdWin.Alert "Ошибка вызова krotGetFirstNode SENS_TIMER на отметке " & x1 & vbNewLine & lastError()
 Exit Function
End If
x1 = dat.prevPos
y1 = dat.sensVal
 
x2 = dst + hlf
If x2 > trc.length Then x2 = trc.length
If krotGetFirstNode(trc.handle, dat, x2, SENS_TIMER, -1, 0, 0) = KRT_ERR Then
 ogdWin.Alert "Ошибка вызова krotGetFirstNode SENS_TIMER на отметке " & x2 & vbNewLine & lastError()
 Exit Function
End If
x2 = dat.prevPos
y2 = dat.sensVal

On Error GoTo handleOverflow
y = y2 - y1
On Error GoTo 0

If y <> 0 Then
 atDist = (x2 - x1) * ampl / y
 If atDist < 0 Then atDist = 0
End If

Exit Function

handleOverflow:
atDist = 0
End Function

Private Sub updateDataIfNeed()

If dataLength <> trc.pageLength Then
 dataLength = trc.pageLength
 clsSensor_ClearData
End If

If dataLengthMax < dataLength Then
 dataLengthMax = dataLength
 ReDim dataArray(dataLengthMax) As T_NODEDATA
 clsSensor_ClearData
End If

If Not (dataStart = trc.pageStart) Then
 dataStart = trc.pageStart
 fillArray
End If
End Sub

Private Sub Class_Initialize()
Set graph = New clsSensorGraph
dataStart = -1
dataLengthMax = -1
d_markWpos = -1
d_markBpos = -1
End Sub

Private Function clsSensor_canDraw(pic As PictureBox) As Boolean
clsSensor_canDraw = clsSensorGraph_canDraw(pic)
End Function

Private Sub clsSensor_ClearData()
dataStart = -1
End Sub

Private Function clsSensor_Draw(pic As PictureBox, ByVal diskret As Boolean, ByVal cycledLevel As Long, ByVal reverse As Boolean, Optional forceReadData As Boolean = False) As Boolean
clsSensor_Draw = clsSensorGraph_Draw(pic, forceReadData)
End Function

Private Function clsSensor_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
clsSensor_getVal = clsSensorGraph_getVal(x, lineIndex)
End Function

Private Sub clsSensor_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKey As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long)
Me.Init trace, iniKey, nam, vMin, vMax
End Sub

Private Property Get clsSensor_isCurrMarkWhite() As Boolean
clsSensor_isCurrMarkWhite = graph.isCurrMarkWhite
End Property

Private Property Get clsSensor_line(ByVal indx As Integer) As clsSensorLine
Set clsSensor_line = clsSensorGraph_line(indx)
End Property

Private Property Get clsSensor_markB(ByVal lineIndex As Long) As Long
clsSensor_markB = clsSensorGraph_markB(lineIndex)
End Property

Private Property Get clsSensor_markW(ByVal lineIndex As Long) As Long
clsSensor_markW = clsSensorGraph_markW(lineIndex)
End Property

Private Property Get clsSensor_maxPageVal() As Long
clsSensor_maxPageVal = maxPageVal
End Property

Private Property Get clsSensor_minPageVal() As Long
clsSensor_minPageVal = minPageVal
End Property

Private Property Get clsSensor_name() As String
clsSensor_name = clsSensorGraph_name()
End Property

Private Property Get clsSensor_num() As Long
clsSensor_num = clsSensorGraph_num()
End Property

Private Sub clsSensor_offAll()
clsSensorGraph_offAll
End Sub

Private Sub clsSensor_Save()
clsSensorGraph_Save
End Sub

Private Property Get clsSensor_typ() As KRT_SENS
clsSensor_typ = clsSensorGraph_typ()
End Property

Private Property Get clsSensor_valMax() As Long
clsSensor_valMax = clsSensorGraph_valMax
End Property

Private Property Get clsSensor_valMin() As Long
clsSensor_valMin = clsSensorGraph_valMin
End Property

Private Property Get clsSensor_visible() As Boolean
clsSensor_visible = clsSensorGraph_visible
End Property

Private Function clsSensorGraph_canDraw(pic As PictureBox) As Boolean
clsSensorGraph_canDraw = graph.canDraw(pic)
End Function

Private Sub clsSensorGraph_ClearData()
clsSensor_ClearData
End Sub

Private Function clsSensorGraph_Draw(pic As PictureBox, Optional forceReadData As Boolean = False) As Boolean
Dim i As Long, x1 As Long, y1 As Long, x2 As Long, y2 As Long
Dim l As clsSensorLine

If clsSensorGraph_canDraw(pic) = False Then Exit Function

Set l = graph.line(0)
updateDataIfNeed
clsSensorGraph_setBorders pic

' переключаем дистанции области отрисовки на относительные,
' чтобы исключить искажения в последних знаках значения с плавающей точкой
' при больших дистанциях отрисовываемых значений
Dim saveScaleLeft As Double
saveScaleLeft = pic.ScaleLeft
pic.ScaleLeft = 0

x1 = dataArray(0).prevPos - saveScaleLeft
y1 = dataArray(0).sensVal
For i = 1 To dataNodes - 1
 x2 = dataArray(i).prevPos - saveScaleLeft
 y2 = dataArray(i).sensVal
 l.drawNode pic, x1, y1, x2, y2, graph.reverse, graph.diskret, 0, color.clrIndx(0)
 x1 = x2
 y1 = y2
Next

' восстанавливаем координаты области отрисовки
pic.ScaleLeft = saveScaleLeft

clsSensorGraph_drawMarks pic
clsSensorGraph_drawRulers pic
End Function

Private Property Let clsSensorGraph_autoBrd(RHS As Boolean)
graph.autoBrd = RHS
End Property

Private Property Get clsSensorGraph_autoBrd() As Boolean
clsSensorGraph_autoBrd = graph.autoBrd
End Property

Private Property Let clsSensorGraph_brdMax(ByVal RHS As Double)
graph.brdMax = RHS
End Property

Private Property Get clsSensorGraph_brdMax() As Double
clsSensorGraph_brdMax = graph.brdMax
End Property

Private Property Let clsSensorGraph_brdMin(ByVal RHS As Double)
graph.brdMin = RHS
End Property

Private Property Get clsSensorGraph_brdMin() As Double
clsSensorGraph_brdMin = graph.brdMin
End Property

Private Property Let clsSensorGraph_cycledLevel(ByVal RHS As Long)
Exit Property
End Property

Private Property Get clsSensorGraph_cycledLevel() As Long
clsSensorGraph_cycledLevel = 0
End Property

Private Property Let clsSensorGraph_diskret(ByVal RHS As Boolean)
graph.diskret = RHS
End Property

Private Property Get clsSensorGraph_diskret() As Boolean
clsSensorGraph_diskret = graph.diskret
End Property

Private Function clsSensorGraph_dispVal(ByVal sensValue As Long) As String
Dim v As Double

v = sensValue
clsSensorGraph_dispVal = dblStr(v / ampl, 2)
End Function

Private Sub clsSensorGraph_drawMarks(p As PictureBox)
graph.drawMarks p
End Sub

Private Sub clsSensorGraph_drawRulers(p As PictureBox)
graph.drawRulers p
End Sub

Private Function clsSensorGraph_findMarker(pic As PictureBox, ByVal x As Single) As Integer
clsSensorGraph_findMarker = graph.findMarker(pic, x)
End Function

Private Function valFromCash(ByVal x As Long) As Long
Dim i As Long, l As Long, r As Long
Dim dltVal As Long, dltPos As Long

l = 0
r = dataNodes - 1
i = (r - l) / 2
While i > 0
 If dataArray(l + i).prevPos = x Then
 
  valFromCash = dataArray(l + i).sensVal
  Exit Function
  
  Else
  
  If dataArray(l + i).prevPos < x Then
   l = l + i
   Else
   r = l + i
  End If
  
 End If
 i = (r - l) / 2
Wend

dltVal = dataArray(r).sensVal - dataArray(l).sensVal
dltPos = dataArray(r).prevPos - dataArray(l).prevPos
x = x - dataArray(l).prevPos

valFromCash = dataArray(l).sensVal + dltVal * x / dltPos
End Function

Private Function clsSensorGraph_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
Dim dat As T_NODEDATA
Dim x1 As Long, y1 As Long, y As Single

clsSensorGraph_getVal = 0

If (x >= dataStart) And (x <= (dataStart + dataLength)) Then
 clsSensorGraph_getVal = valFromCash(x)
 Exit Function
End If

X = X - trc.speedVector * SV_AMPL / 2
If x < 0 Then x = 0

If krotGetFirstNode(trc.handle, dat, x, SENS_TIMER, -1, 1, 0) = KRT_ERR Then
 Exit Function
End If

y1 = dat.sensVal
x1 = dat.prevPos

X = X + trc.speedVector * SV_AMPL / 2
If x > trc.length Then x = trc.length

If krotGetFirstNode(trc.handle, dat, x, SENS_TIMER, -1, 1, 0) = KRT_ERR Then
 Exit Function
End If

y1 = dat.sensVal - y1
x1 = dat.prevPos - x1

y = y1 'convert long->single
'If x1 <= 0 Then Exit Function
'If y1 <= 0 Then Exit Function
clsSensorGraph_getVal = x1 * ampl / y
End Function

Private Property Let clsSensorGraph_hKoef(ByVal RHS As Integer)
graph.hKoef = RHS
End Property

Private Property Get clsSensorGraph_hKoef() As Integer
clsSensorGraph_hKoef = graph.hKoef
End Property

Private Sub clsSensorGraph_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKeyName As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long, ByVal cycled As Boolean, Optional ByVal notCalcAutoBorders As Boolean = False)
Me.Init trace, iniKeyName, nam, vMin, vMax
End Sub

Private Property Get clsSensorGraph_isCurrMarkWhite() As Boolean
clsSensorGraph_isCurrMarkWhite = graph.isCurrMarkWhite
End Property

Private Property Let clsSensorGraph_isVOG(ByVal RHS As Boolean)
Exit Property
End Property

Private Property Get clsSensorGraph_line(ByVal indx As Integer) As clsSensorLine
Set clsSensorGraph_line = graph.line(0)
End Property

Private Property Get clsSensorGraph_markB(ByVal lineIndex As Long) As Long
If d_markBpos <> trc.mark.black Then
 d_markBpos = trc.mark.black
 d_markB = clsSensorGraph_getVal(d_markBpos)
End If
clsSensorGraph_markB = d_markB
End Property

Private Property Get clsSensorGraph_markW(ByVal lineIndex As Long) As Long
If d_markWpos <> trc.mark.white Then
 d_markWpos = trc.mark.white
 d_markW = clsSensorGraph_getVal(d_markWpos)
End If
clsSensorGraph_markW = d_markW
End Property

Private Property Get clsSensorGraph_name() As String
clsSensorGraph_name = graph.name
End Property

Private Property Get clsSensorGraph_num() As Long
clsSensorGraph_num = graph.num
End Property

Private Sub clsSensorGraph_offAll()
graph.offAll
End Sub

Private Property Let clsSensorGraph_reverse(ByVal RHS As Boolean)
graph.reverse = RHS
End Property

Private Property Get clsSensorGraph_reverse() As Boolean
clsSensorGraph_reverse = graph.reverse
End Property

Private Sub clsSensorGraph_Save()
graph.Save
End Sub

Private Property Let clsSensorGraph_rul1enb(ByVal RHS As Boolean)
graph.rul1enb = RHS
End Property

Private Property Get clsSensorGraph_rul1enb() As Boolean
clsSensorGraph_rul1enb = graph.rul1enb
End Property

Private Property Let clsSensorGraph_rul2enb(ByVal RHS As Boolean)
graph.rul2enb = RHS
End Property

Private Property Get clsSensorGraph_rul2enb() As Boolean
clsSensorGraph_rul2enb = graph.rul2enb
End Property

Private Property Let clsSensorGraph_rul1clr(ByVal RHS As Long)
graph.rul1clr = RHS
End Property

Private Property Get clsSensorGraph_rul1clr() As Long
clsSensorGraph_rul1clr = graph.rul1clr
End Property

Private Property Let clsSensorGraph_rul1val(ByVal RHS As Double)
graph.rul1val = RHS
End Property

Private Property Get clsSensorGraph_rul1val() As Double
clsSensorGraph_rul1val = graph.rul1val
End Property

Private Property Let clsSensorGraph_rul2clr(ByVal RHS As Long)
graph.rul2clr = RHS
End Property

Private Property Get clsSensorGraph_rul2clr() As Long
clsSensorGraph_rul2clr = graph.rul2clr
End Property

Private Property Let clsSensorGraph_rul2val(ByVal RHS As Double)
graph.rul2val = RHS
End Property

Private Property Get clsSensorGraph_rul2val() As Double
clsSensorGraph_rul2val = graph.rul2val
End Property

Private Function clsSensorGraph_sensVal(ByVal dispVal As String) As Long
clsSensorGraph_sensVal = Fix(val(dispVal) * ampl)
End Function

Private Sub clsSensorGraph_setBorders(pic As PictureBox)
If graph.autoBrd Then
 updateDataIfNeed
 graph.brdMin = minPageVal
 graph.brdMax = maxPageVal
End If
graph.setBordersEx pic, graph.valMin, graph.valMax, graph.brdMin, graph.brdMax
End Sub

Private Sub clsSensorGraph_setBordersEx(pic As PictureBox, ByVal valMin As Long, ByVal valMax As Long, ByVal brdMin As Long, ByVal brdMax As Long)
graph.setBordersEx pic, valMin, valMax, brdMin, brdMax
End Sub

Private Property Get clsSensorGraph_typ() As KRT_SENS
clsSensorGraph_typ = SENS_SPEED
End Property

Private Property Get clsSensorGraph_valMax() As Long
clsSensorGraph_valMax = graph.valMax
End Property

Private Property Get clsSensorGraph_valMin() As Long
clsSensorGraph_valMin = graph.valMin
End Property

Private Property Get clsSensorGraph_visible() As Boolean
clsSensorGraph_visible = graph.visible
End Property

Private Property Get clsSensorGraph_isVOG() As Boolean
clsSensorGraph_isVOG = graph.isVOG
End Property

Private Property Get clsSensorGraph_TurnAngleTitle() As String
clsSensorGraph_TurnAngleTitle = graph.TurnAngleTitle
End Property

Private Property Get clsSensorGraph_TurnAngleValue() As String
clsSensorGraph_TurnAngleValue = graph.TurnAngleValue
End Property
