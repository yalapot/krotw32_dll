VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorGraphVog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements clsSensorGraph
Implements clsSensor

Private graph As clsSensorGraph
Private trc As clsTrace
Private d_turn_angle_title As String
Private d_turnkind As Long

Public Sub Init(trace As clsTrace, ByVal typ As VOG_GRAPH)
Dim iniKeyName As String, nam As String, sensType As KRT_SENS
Dim valMin As Long, valMax As Long
Set trc = trace

Select Case typ
 Case VOG_GRAPH.GRAPH_AZIMUTH
   sensType = KRT_SENS.SENS_AZIMUTH
   iniKeyName = "GraphAzimuth"
   nam = "Азимут, сотые градуса"
   d_turn_angle_title = "радиус XY, м: "
   d_turnkind = 0
   valMin = -500000 '!!!!!!!!!!!
   valMax = 500000
   
 Case VOG_GRAPH.GRAPH_TANGAZH
   sensType = KRT_SENS.SENS_TANGAZH
   iniKeyName = "GraphTangazh"
   nam = "Тангаж, сотые градуса"
   d_turn_angle_title = "радиус Z, м: "
   d_turnkind = 1
   valMin = -90 * 100
   valMax = 90 * 100

End Select

graph.Init trc, sensType, iniKeyName, nam, IIf(trc.vog.enable, 1, 0), valMin, valMax, False, True
graph.isVOG = True
End Sub

Private Sub Class_Initialize()
Set graph = New clsSensorGraph
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

Private Property Let clsSensorGraph_isVOG(ByVal RHS As Boolean)
Exit Property
End Property

Private Property Get clsSensorGraph_isVOG() As Boolean
clsSensorGraph_isVOG = True
End Property

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

Private Sub clsSensorGraph_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKeyName As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long, ByVal cycled As Boolean, Optional ByVal notCalcAutoBorders As Boolean = False)
Exit Sub
End Sub

Private Property Get clsSensorGraph_isCurrMarkWhite() As Boolean
clsSensorGraph_isCurrMarkWhite = graph.isCurrMarkWhite
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

Private Function clsSensorGraph_sensVal(ByVal dispVal As String) As Long
clsSensorGraph_sensVal = graph.sensVal(dispVal)
End Function

Private Sub clsSensorGraph_setBorders(pic As PictureBox)
graph.setBorders pic
End Sub

Private Sub clsSensorGraph_setBordersEx(pic As PictureBox, ByVal valMin As Long, ByVal valMax As Long, ByVal brdMin As Long, ByVal brdMax As Long)
graph.setBordersEx pic, valMin, valMax, brdMin, brdMax
End Sub

Private Function clsSensorGraph_Draw(pic As PictureBox, Optional forceReadData As Boolean = False) As Boolean
clsSensorGraph_Draw = graph.Draw(pic, forceReadData)
End Function

Private Sub clsSensorGraph_Save()
graph.Save
End Sub

Private Property Get clsSensorGraph_TurnAngleTitle() As String
clsSensorGraph_TurnAngleTitle = d_turn_angle_title
End Property

Private Property Get clsSensorGraph_TurnAngleValue() As String
Dim mrkBlack As Long, mrkWhite As Long, turnStart As Long, turnLength As Long, radius3D As Long
Dim angle_xy As Single, angle_z As Single
Dim radius_xy As Long, radius_z As Long
Dim dt As T_TURNDATA

mrkBlack = trc.mark.black
mrkWhite = trc.mark.white
clsSensorGraph_TurnAngleValue = "n/a"

If mrkBlack = mrkWhite Then
  Exit Property
End If

turnStart = IIf(mrkWhite < mrkBlack, mrkWhite, mrkBlack)
turnLength = Abs(mrkWhite - mrkBlack)
user_length = trc.getLenKoef(turnStart, turnLength)

If GetCurveData(trc.handle, CLng(0), 0, turnStart, turnLength, trc.Diametr, 0, dt) = KRT_ERR Then
  ogdWin.Alert "Ошибка вызова GetCurveData"
  Exit Property
End If
radius_xy = dt.radius
angle_xy = dt.angle

If GetCurveData(trc.handle, CLng(0), 1, turnStart, turnLength, trc.Diametr, 0, dt) = KRT_ERR Then
  ogdWin.Alert "Ошибка вызова GetCurveData"
  Exit Property
End If
radius_z = dt.radius
angle_z = dt.angle

radius = radius_xy
If d_turnkind = 1 Then
  radius = radius_z
End If

radius3D = user_length / calck_angle_common(angle_z, angle_xy)
clsSensorGraph_TurnAngleValue = angle_label(radius, trc.Diametr) & " [" & dblStr((radius3D / trc.Diametr), 1) & " 3D]"
End Property

Private Property Get clsSensorGraph_typ() As KRT_SENS
clsSensorGraph_typ = graph.typ
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

Property Let visible(a As Boolean)
Dim l As clsSensorLine

l = graph.line(0)
l.visible = a
End Property

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
Exit Sub
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
