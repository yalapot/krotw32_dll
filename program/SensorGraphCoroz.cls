VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorGraphCoroz"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements clsSensorGraph
Implements clsSensor

Private Const INI_SENS_INDEX = "OneSensNum"

Private graph As clsSensorGraph
Private trc As clsTrace
Private crz As clsCoroz

Private d_index As Integer
Private iniKey As String
Private minPageVal As Long
Private maxPageVal As Long
Private minPageRow As Long
Private maxPageRow As Long

Private localMaxDist As Long

Private brdMinRow As Long
Private brdMaxRow As Long
Private brdMinDat As Long
Private brdMaxDat As Long
Private dataStart As Long
Private dataLength As Long
Private dataLengthMax As Long

Private datByte() As Byte
Private datLong() As Long

Private vecByte() As Byte
Private vecLong() As Long

Private Sub Class_Initialize()
Set graph = New clsSensorGraph
d_index = -1
dataStart = -1
dataLengthMax = -1
End Sub

Public Sub Init( _
trace As clsTrace, _
Coroz As clsCoroz, _
ByVal iniKeyName As String _
)

Set trc = trace
Set crz = Coroz
iniKey = iniKeyName

brdMinRow = crz.valMinRow
brdMaxRow = crz.valMaxRow
brdMinDat = crz.valMin
brdMaxDat = crz.valMax

graph.Init trace, SENS_COROZ, iniKey, "Корозионный", 1, 0, 0, False, True
d_index = trc.getUser(iniKey & INI_SENS_INDEX, "0")
ReDim vecByte(crz.num) As Byte
ReDim vecLong(crz.num) As Long
End Sub

Public Sub Save()
graph.Save
trc.setUser iniKey & INI_SENS_INDEX, Me.Index
End Sub

Property Get visible() As Boolean
visible = graph.visible
End Property

Property Let visible(v As Boolean)
Dim ln As clsSensorLine
Set ln = graph.line(0)
ln.visible = v
End Property

Property Get Index() As Integer
Index = d_index
End Property

Property Let Index(i As Integer)
If d_index <> i Then
 d_index = i
 dataStart = -1
 updateDataIfNeed
End If
End Property

Private Sub calcPageMinMax()
Dim i As Long

minPageVal = crz.valMax
maxPageVal = crz.valMin
minPageRow = crz.valMaxRow
maxPageRow = crz.valMinRow

For i = 0 To dataLength - 1
 If datByte(i) > maxPageVal Then maxPageVal = datByte(i)
 If datByte(i) < minPageVal Then minPageVal = datByte(i)
 If datLong(i) < minPageRow Then minPageRow = datLong(i)
 If datLong(i) > maxPageRow Then maxPageRow = datLong(i)
Next
End Sub

Public Function calcLocalMax(x As Long) As Long
Dim i As Long, j As Long
Dim c As Boolean

j = Round((x - trc.pageStart) / trc.Step)

i = j + 1
c = True
While (i < dataLength) And (c = True)
   If datByte(i) > datByte(j) Then
    j = i
   Else
    c = False
   End If
   i = i + 1
Wend

i = j - 1
c = True
While (i >= 0) And (c = True)
   If datByte(i) > datByte(j) Then
        j = i
   Else
        c = False
   End If
   i = i - 1
Wend

calcLocalMax = trc.pageStart + j * trc.Step
End Function

Private Sub fillArray()
If krotGetSingleSens(trc.handle, crz.Index, Me.Index, datByte(0), datLong(0)) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Sub
End If
calcPageMinMax
End Sub

Private Sub updateDataIfNeed(Optional forceReadData As Boolean = False)

If dataLength <> (trc.pageLength / trc.Step) Then
 dataLength = trc.pageLength / trc.Step
 clsSensor_ClearData
End If

If dataLengthMax < dataLength Then
 dataLengthMax = dataLength
 ReDim datByte(dataLengthMax) As Byte
 ReDim datLong(dataLengthMax) As Long
 clsSensor_ClearData
End If

If forceReadData Or (dataStart <> trc.pageStart) Then
 dataStart = trc.pageStart
 fillArray
End If
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
clsSensorGraph_Init trace, typ, iniKey, nam, num, vMin, vMax, False
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
clsSensor_valMax = clsSensorGraph_valMax()
End Property

Private Property Get clsSensor_valMin() As Long
clsSensor_valMin = clsSensorGraph_valMin()
End Property

Private Property Get clsSensor_visible() As Boolean
clsSensor_visible = clsSensorGraph_visible()
End Property

Private Function clsSensorGraph_canDraw(pic As PictureBox) As Boolean
clsSensorGraph_canDraw = graph.canDraw(pic)
End Function

Private Sub clsSensorGraph_ClearData()
clsSensor_ClearData
End Sub

'''------------------------------------------------
Private Function clsSensorGraph_dispVal(ByVal sensValue As Long) As String
If trc.Coroz.tesla And crz.isRow Then
 clsSensorGraph_dispVal = dblStr(trc.magnit.getTesla(sensValue), 1)
 Else
 clsSensorGraph_dispVal = graph.dispVal(sensValue)
End If
End Function

Private Function clsSensorGraph_Draw(pic As PictureBox, Optional forceReadData As Boolean = False) As Boolean
Dim i As Long, x1 As Long, y1 As Long, x2 As Long, y2 As Long
Dim l As clsSensorLine

If clsSensorGraph_canDraw(pic) = False Then Exit Function

Set l = graph.line(0)
updateDataIfNeed forceReadData
clsSensorGraph_setBorders pic

' переключаем дистанции области отрисовки на относительные,
' чтобы исключить искажения в последних знаках значения с плавающей точкой
' при больших дистанциях отрисовываемых значений
x1 = 0 'trc.pageStart
Dim saveScaleLeft As Double
saveScaleLeft = pic.ScaleLeft
pic.ScaleLeft = 0

y1 = IIf(crz.isRow, datLong(0), datByte(0))
For i = 1 To dataLength - 1
 x2 = x1 + trc.Step
 y2 = IIf(crz.isRow, datLong(i), datByte(i))
 l.drawNode pic, x1, y1, x2, y2, graph.reverse, graph.diskret, 0, color.clrIndx(0)
 x1 = x2
 y1 = y2
Next

' восстанавливаем координаты области отрисовки
pic.ScaleLeft = saveScaleLeft

clsSensorGraph_drawMarks pic
clsSensorGraph_drawRulers pic
End Function

Public Function findMarker(pic As PictureBox, ByVal x As Single) As Integer
findMarker = graph.findMarker(pic, x)
End Function

Public Sub drawMarks(p As PictureBox)
clsSensorGraph_drawMarks p
End Sub

Private Sub clsSensorGraph_drawMarks(p As PictureBox)
graph.drawMarks p
End Sub

Private Sub clsSensorGraph_drawRulers(p As PictureBox)
graph.drawRulers p
End Sub

Private Function clsSensorGraph_findMarker(pic As PictureBox, ByVal x As Single) As Integer
clsSensorGraph_findMarker = graph.findMarker(pic, x)
End Function

Private Function clsSensorGraph_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
clsSensorGraph_getVal = 0
If krotGetVectSens(trc.handle, crz.Index, x, vecByte(0), vecLong(0)) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If
clsSensorGraph_getVal = IIf(crz.isRow, vecLong(Me.Index), vecByte(Me.Index))
End Function

Private Sub clsSensorGraph_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKeyName As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long, ByVal cycled As Boolean, Optional ByVal notCalcAutoBorders As Boolean = False)
Me.Init trace, crz, iniKeyName
End Sub

Private Property Get clsSensorGraph_isCurrMarkWhite() As Boolean
clsSensorGraph_isCurrMarkWhite = graph.isCurrMarkWhite
End Property

Private Property Let clsSensorGraph_isVOG(ByVal RHS As Boolean)
Exit Property
End Property

Private Property Get clsSensorGraph_markB(ByVal lineIndex As Long) As Long
clsSensorGraph_markB = crz.markB(Me.Index)
End Property

Private Property Get clsSensorGraph_markW(ByVal lineIndex As Long) As Long
clsSensorGraph_markW = crz.markW(Me.Index)
End Property

Private Sub setPageMinMax()
brdMinRow = minPageRow
brdMaxRow = maxPageRow
brdMinDat = minPageVal
brdMaxDat = maxPageVal
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
If trc.Coroz.tesla And crz.isRow Then
 clsSensorGraph_sensVal = trc.magnit.getADCunit(Val(dispVal))
 Else
 clsSensorGraph_sensVal = graph.sensVal(dispVal)
End If
End Function

Private Sub clsSensorGraph_setBorders(pic As PictureBox)
If graph.autoBrd Then setPageMinMax
graph.setBordersEx _
 pic, _
 clsSensorGraph_valMin, _
 clsSensorGraph_valMax, _
 clsSensorGraph_brdMin, _
 clsSensorGraph_brdMax
End Sub

Private Sub clsSensorGraph_setBordersEx(pic As PictureBox, ByVal valMin As Long, ByVal valMax As Long, ByVal brdMin As Long, ByVal brdMax As Long)
clsSensorGraph_setBorders pic
End Sub

Private Property Let clsSensorGraph_autoBrd(RHS As Boolean)
graph.autoBrd = RHS
If graph.autoBrd Then
 updateDataIfNeed
 calcPageMinMax
 setPageMinMax
End If
End Property

Private Property Get clsSensorGraph_autoBrd() As Boolean
clsSensorGraph_autoBrd = graph.autoBrd
End Property

Private Property Let clsSensorGraph_brdMax(ByVal RHS As Double)
If crz.isRow Then
 brdMaxRow = RHS
 Else
 brdMaxDat = RHS
End If
End Property

Private Property Get clsSensorGraph_brdMax() As Double
clsSensorGraph_brdMax = IIf(crz.isRow, brdMaxRow, brdMaxDat)
End Property

Private Property Let clsSensorGraph_brdMin(ByVal RHS As Double)
If crz.isRow Then
 brdMinRow = RHS
 Else
 brdMinDat = RHS
End If
End Property

Private Property Get clsSensorGraph_brdMin() As Double
clsSensorGraph_brdMin = IIf(crz.isRow, brdMinRow, brdMinDat)
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

Private Property Let clsSensorGraph_hKoef(ByVal RHS As Integer)
graph.hKoef = RHS
End Property

Private Property Get clsSensorGraph_hKoef() As Integer
clsSensorGraph_hKoef = graph.hKoef
End Property

Private Property Get clsSensorGraph_line(ByVal indx As Integer) As clsSensorLine
Set clsSensorGraph_line = graph.line(0)
End Property

Private Property Get clsSensorGraph_name() As String
clsSensorGraph_name = graph.name & " №" & Me.Index & ", " & IIf(trc.Coroz.tesla And crz.isRow, "млТесла", "ед. АЦП")
End Property

Private Property Get clsSensorGraph_num() As Long
clsSensorGraph_num = 1
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
Me.Save
End Sub

Private Property Get clsSensorGraph_isVOG() As Boolean
clsSensorGraph_isVOG = graph.isVOG
End Property

Private Property Get clsSensorGraph_TurnAngleTitle() As String
clsSensorGraph_TurnAngleTitle = graph.TurnAngleTitle
End Property

Private Property Get clsSensorGraph_TurnAngleValue() As String
clsSensorGraph_TurnAngleValue = graph.TurnAngleValue
End Property

Private Property Get clsSensorGraph_typ() As KRT_SENS
clsSensorGraph_typ = SENS_COROZ
End Property

Private Property Get clsSensorGraph_valMax() As Long
clsSensorGraph_valMax = IIf(crz.isRow, crz.valMaxRow, crz.valMax)
End Property

Private Property Get clsSensorGraph_valMin() As Long
clsSensorGraph_valMin = IIf(crz.isRow, crz.valMinRow, crz.valMin)
End Property

Private Property Get clsSensorGraph_visible() As Boolean
clsSensorGraph_visible = Me.visible
End Property
