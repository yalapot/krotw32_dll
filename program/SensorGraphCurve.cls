VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorGraphCurve"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements clsSensorGraph
Implements clsSensor

Private Const ampl = 100
Private Const LINES_NUM = 3
Private Const INI_LINE = "Line"
Private Const IS_RADIUS = "IsRadius"

Private graph As clsSensorGraph
Private trc As clsTrace
Private d_line() As clsSensorLineCurve
Private iniKey As String
Public isRadius As Boolean

Private minPageVal As Long
Private maxPageVal As Long

Public Sub Init( _
trace As clsTrace, _
ByVal iniKeyName As String _
)

Set trc = trace
If Not trc.vog.enable Then Exit Sub

iniKey = iniKeyName
graph.Init trc, SENS_CURVE, iniKey, "", IIf(trc.vog.enable, LINES_NUM, 0), 0, 0, False, True
graph.isVOG = True

ReDim d_line(LINES_NUM) As clsSensorLineCurve
Dim i As Integer
For i = 1 To LINES_NUM
 Set d_line(i) = New clsSensorLineCurve
 d_line(i).Init trc, i - 1
 clsSensorGraph_line(i - 1).visible = trc.getUserBool(iniKey & INI_LINE & (i - 1), False)
Next i
isRadius = trc.getUserBool(iniKey & IS_RADIUS, False)
End Sub

Public Sub Save()
clsSensorGraph_Save
End Sub

Private Sub Class_Initialize()
Set graph = New clsSensorGraph
End Sub

Private Function clsSensor_canDraw(pic As PictureBox) As Boolean
clsSensor_canDraw = clsSensorGraph_canDraw(pic)
End Function

Private Sub clsSensor_ClearData()
Dim i As Integer

If Not trc.vog.enable Then Exit Sub

For i = 1 To LINES_NUM
 clsSensorGraph_line(i - 1).ClearData
Next i
End Sub

Private Function clsSensor_Draw(pic As PictureBox, ByVal diskret As Boolean, ByVal cycledLevel As Long, ByVal reverse As Boolean, Optional forceReadData As Boolean = False) As Boolean
clsSensor_Draw = clsSensorGraph_Draw(pic)
End Function

Private Function clsSensor_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
clsSensor_getVal = clsSensorGraph_getVal(x, lineIndex)
End Function

Private Sub clsSensor_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKey As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long)
clsSensorGraph_Init trace, typ, iniKey, nam, num, vMin, vMax, True
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
clsSensor_visible = clsSensorGraph_visible
End Property

Private Function clsSensorGraph_canDraw(pic As PictureBox) As Boolean
clsSensorGraph_canDraw = graph.canDraw(pic)
End Function

Private Sub clsSensorGraph_ClearData()
clsSensor_ClearData
End Sub

Private Function clsSensorGraph_Draw(pic As PictureBox, Optional forceReadData As Boolean = False) As Boolean
Dim i As Integer, ret As Boolean, tmp As Boolean

If clsSensorGraph_canDraw(pic) = False Then Exit Function

ret = True
clsSensorGraph_setBorders pic

For i = 0 To LINES_NUM - 1
 If clsSensorGraph_line(i).visible Then
  tmp = clsSensorGraph_line(i).Draw(pic, color.clrIndx(i), graph.diskret, 0, graph.reverse, forceReadData)
  ret = ret And tmp
 End If
Next i

clsSensorGraph_drawMarks pic
clsSensorGraph_drawRulers pic

clsSensorGraph_Draw = ret
End Function

Private Sub calcMinMax()
Dim i As Integer

minPageVal = graph.valMax
maxPageVal = graph.valMin

For i = 0 To LINES_NUM - 1
 If clsSensorGraph_line(i).visible Then
  If minPageVal > clsSensorGraph_line(i).minPageVal Then minPageVal = clsSensorGraph_line(i).minPageVal
  If maxPageVal < clsSensorGraph_line(i).maxPageVal Then maxPageVal = clsSensorGraph_line(i).maxPageVal
 End If
Next
End Sub

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

Private Function clsSensorGraph_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
clsSensorGraph_getVal = clsSensorGraph_line(lineIndex).getVal(x)
End Function

Private Property Let clsSensorGraph_hKoef(ByVal RHS As Integer)
graph.hKoef = RHS
End Property

Private Property Get clsSensorGraph_hKoef() As Integer
clsSensorGraph_hKoef = graph.hKoef
End Property

Private Sub clsSensorGraph_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKeyName As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long, ByVal cycled As Boolean, Optional ByVal notCalcAutoBorders As Boolean = False)
Me.Init trace, iniKeyName
End Sub

Private Property Get clsSensorGraph_isCurrMarkWhite() As Boolean
clsSensorGraph_isCurrMarkWhite = graph.isCurrMarkWhite
End Property

Private Property Let clsSensorGraph_isVOG(ByVal RHS As Boolean)
Exit Property
End Property

Private Property Get clsSensorGraph_isVOG() As Boolean
clsSensorGraph_isVOG = True
End Property

Private Property Get clsSensorGraph_line(ByVal indx As Integer) As clsSensorLine
Set clsSensorGraph_line = d_line(indx + 1)
End Property

Private Property Get clsSensorGraph_markB(ByVal lineIndex As Long) As Long
clsSensorGraph_markB = clsSensorGraph_line(lineIndex).markB
End Property

Private Property Get clsSensorGraph_markW(ByVal lineIndex As Long) As Long
clsSensorGraph_markW = clsSensorGraph_line(lineIndex).markW
End Property

Private Property Get clsSensorGraph_name() As String
clsSensorGraph_name = IIf(isRadius, "Радиус поворота, D", "Изгиб, 1/метр")
End Property

Private Property Get clsSensorGraph_num() As Long
clsSensorGraph_num = graph.num
End Property

Private Sub clsSensorGraph_offAll()
Dim i As Integer

If Not trc.vog.enable Then Exit Sub
For i = 1 To LINES_NUM
 clsSensorGraph_line(i - 1).visible = False
Next
End Sub

Private Property Let clsSensorGraph_reverse(ByVal RHS As Boolean)
graph.reverse = RHS
End Property

Private Property Get clsSensorGraph_reverse() As Boolean
clsSensorGraph_reverse = graph.reverse
End Property

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

Private Sub clsSensorGraph_Save()
Dim i As Integer

If Not trc.vog.enable Then Exit Sub
graph.Save
trc.setUserBool iniKey & IS_RADIUS, isRadius

For i = 1 To LINES_NUM
 trc.setUserBool iniKey & INI_LINE & (i - 1), clsSensorGraph_line(i - 1).visible
Next i
End Sub

Private Function clsSensorGraph_sensVal(ByVal dispVal As String) As Long
clsSensorGraph_sensVal = Fix(Val(dispVal) * ampl)
End Function

Private Sub clsSensorGraph_setBorders(pic As PictureBox)
If graph.autoBrd Then
 calcMinMax
 graph.brdMin = minPageVal
 graph.brdMax = maxPageVal
End If
graph.setBordersEx pic, graph.valMin, graph.valMax, graph.brdMin, graph.brdMax
End Sub

Private Sub clsSensorGraph_setBordersEx(pic As PictureBox, ByVal valMin As Long, ByVal valMax As Long, ByVal brdMin As Long, ByVal brdMax As Long)
graph.setBordersEx pic, valMin, valMax, brdMin, brdMax
End Sub

Private Property Get clsSensorGraph_TurnAngleTitle() As String
clsSensorGraph_TurnAngleTitle = ""
End Property

Private Property Get clsSensorGraph_TurnAngleValue() As String
clsSensorGraph_TurnAngleValue = ""
End Property

Private Property Get clsSensorGraph_typ() As KRT_SENS
clsSensorGraph_typ = SENS_CURVE
End Property

Private Property Get clsSensorGraph_valMax() As Long
Dim v As Long

v = ampl
If isRadius Then
 v = v * 2500
 Else
 v = v * 90
End If
clsSensorGraph_valMax = v
' facking VB! overflow! ->
'clsSensorGraph_valMax = IIf(isRadius, 2500 * ampl, 90 * ampl)
End Property

Private Property Get clsSensorGraph_valMin() As Long
clsSensorGraph_valMin = 0
End Property

Private Property Get clsSensorGraph_visible() As Boolean
Dim i As Integer

clsSensorGraph_visible = False
If Not trc.vog.enable Then Exit Property

clsSensorGraph_visible = True
For i = 1 To LINES_NUM
 If clsSensorGraph_line(i - 1).visible Then Exit Property
Next
clsSensorGraph_visible = False
End Property

