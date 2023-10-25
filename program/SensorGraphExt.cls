VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorGraphExt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements clsSensorGraph
Implements clsSensor

Private graph As clsSensorGraph
Private trc As clsTrace
Private d_index As Integer

Public Sub Init( _
trace As clsTrace, _
ByVal iniKeyName As String, _
ByVal nam As String, _
ByVal indx As Long, _
ByVal vMin As Long, _
ByVal vMax As Long _
)
Dim ln As clsSensorLine

Set trc = trace
d_index = indx
graph.Init trc, SENS_EXT, iniKeyName & indx, nam, 1, vMin, vMax, False

Set ln = graph.line(0)
ln.Index = indx + 1
End Sub

Property Get Index() As Integer
Index = d_index
End Property

Private Sub Class_Initialize()
Set graph = New clsSensorGraph
End Sub

Private Function clsSensor_canDraw(pic As PictureBox) As Boolean
clsSensor_canDraw = graph.canDraw(pic)
End Function

Private Sub clsSensor_ClearData()
graph.ClearData
End Sub

Private Function clsSensor_Draw(pic As PictureBox, ByVal diskret As Boolean, ByVal cycledLevel As Long, ByVal reverse As Boolean, Optional forceReadData As Boolean = False) As Boolean
clsSensor_Draw = clsSensorGraph_Draw(pic, forceReadData)
End Function

Private Function clsSensor_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
clsSensor_getVal = clsSensorGraph_getVal(x, 0)
End Function

Private Sub clsSensor_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKey As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long)
clsSensorGraph_Init trace, typ, iniKey, nam, num, vMin, vMax, (graph.cycledLevel > 0)
End Sub

Private Property Get clsSensor_isCurrMarkWhite() As Boolean
clsSensor_isCurrMarkWhite = graph.isCurrMarkWhite
End Property

Private Property Get clsSensor_line(ByVal indx As Integer) As clsSensorLine
Set clsSensor_line = clsSensorGraph_line(indx)
End Property

Private Property Get clsSensor_markB(ByVal lineIndex As Long) As Long
clsSensor_markB = graph.line(0).markB
End Property

Private Property Get clsSensor_markW(ByVal lineIndex As Long) As Long
clsSensor_markW = graph.line(0).markW
End Property

Private Property Get clsSensor_maxPageVal() As Long
clsSensor_maxPageVal = 0
End Property

Private Property Get clsSensor_minPageVal() As Long
clsSensor_minPageVal = 0
End Property

Private Property Get clsSensor_name() As String
clsSensor_name = clsSensorGraph_name
End Property

Private Property Get clsSensor_num() As Long
clsSensor_num = clsSensorGraph_num
End Property

Private Sub clsSensor_offAll()
clsSensorGraph_offAll
End Sub

Private Sub clsSensor_Save()
clsSensorGraph_Save
End Sub

Private Property Get clsSensor_typ() As KRT_SENS
clsSensor_typ = clsSensorGraph_typ
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

Private Function clsSensorGraph_canDraw(pic As PictureBox) As Boolean
clsSensorGraph_canDraw = clsSensor_canDraw(pic)
End Function

Private Sub clsSensorGraph_ClearData()
clsSensor_ClearData
End Sub

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
clsSensorGraph_dispVal = graph.dispVal(sensValue)
End Function

Private Function clsSensorGraph_Draw(pic As PictureBox, Optional forceReadData As Boolean = False) As Boolean
clsSensorGraph_Draw = graph.Draw(pic, forceReadData)
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
clsSensorGraph_getVal = graph.line(0).getVal(x)
End Function

Private Property Let clsSensorGraph_hKoef(ByVal RHS As Integer)
graph.hKoef = RHS
End Property

Private Property Get clsSensorGraph_hKoef() As Integer
clsSensorGraph_hKoef = graph.hKoef
End Property

Private Sub clsSensorGraph_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKeyName As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long, ByVal cycled As Boolean, Optional ByVal notCalcAutoBorders As Boolean = False)
Me.Init trace, iniKeyName, nam, Me.Index, vMin, vMax
End Sub

Private Property Get clsSensorGraph_isCurrMarkWhite() As Boolean
clsSensorGraph_isCurrMarkWhite = graph.isCurrMarkWhite
End Property

Private Property Let clsSensorGraph_isVOG(ByVal RHS As Boolean)
graph.isVOG = RHS
End Property

Private Property Get clsSensorGraph_isVOG() As Boolean
clsSensorGraph_isVOG = graph.isVOG
End Property

Private Property Get clsSensorGraph_line(ByVal indx As Integer) As clsSensorLine
Set clsSensorGraph_line = graph.line(0)
End Property

Private Property Get clsSensorGraph_markB(ByVal lineIndex As Long) As Long
clsSensorGraph_markB = clsSensor_markB(lineIndex)
End Property

Private Property Get clsSensorGraph_markW(ByVal lineIndex As Long) As Long
clsSensorGraph_markW = clsSensor_markW(lineIndex)
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

Private Property Let clsSensorGraph_rul1clr(ByVal RHS As Long)
graph.rul1clr = RHS
End Property

Private Property Get clsSensorGraph_rul1clr() As Long
clsSensorGraph_rul1clr = graph.rul1clr
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
graph.Save
End Sub

Private Function clsSensorGraph_sensVal(ByVal dispVal As String) As Long
clsSensorGraph_sensVal = graph.sensVal(dispVal)
End Function

Private Sub clsSensorGraph_setBorders(pic As PictureBox)
graph.setBorders pic
End Sub

Private Sub clsSensorGraph_setBordersEx(pic As PictureBox, ByVal valMin As Long, ByVal valMax As Long, ByVal brdMin As Long, ByVal brdMax As Long)
graph.setBordersEx pic, valMin, valMax, brdMin, brdMax
End Sub

Private Property Get clsSensorGraph_TurnAngleTitle() As String
clsSensorGraph_TurnAngleTitle = graph.TurnAngleTitle
End Property

Private Property Get clsSensorGraph_TurnAngleValue() As String
clsSensorGraph_TurnAngleValue = graph.TurnAngleValue
End Property

Private Property Get clsSensorGraph_typ() As KRT_SENS
clsSensorGraph_typ = SENS_EXT
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
