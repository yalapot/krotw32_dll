VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorLineCurve"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements clsSensorLine

'структура дл€ данных изгиба
Private Type T_CURVE_DATA
 angle As Long         'изгиб в сотых дол€х градуса
 radius As Long        'радиус поворота в сотых дол€х диаметра
 pos As Long           'положение на трассе значени€ предыдущего пол€
End Type

Private ln As clsSensorLine
Private trc As clsTrace
Private ang As New clsAnglUnit

Private dataStart As Long
Private dataLength As Long
Private dataLengthMax As Long
Private dataArray() As T_CURVE_DATA
Private dataNodes As Long

Private dataMin As T_CURVE_DATA
Private dataMax As T_CURVE_DATA

Private d_markW As T_CURVE_DATA
Private d_markB As T_CURVE_DATA

Private Function transData(dat As T_CURVE_DATA) As Long
Dim v As Long
v = IIf(trc.isCurveGraphRadius, dat.radius, dat.angle)
transData = IIf(v > trc.curve.valMax, trc.curve.valMax, v)
End Function

Private Sub clsSensorLine_ClearData()
dataStart = -1
End Sub

Private Function clsSensorLine_Draw(pic As PictureBox, ByVal lineColor As Long, ByVal diskret As Boolean, ByVal cycledLevel As Long, ByVal reverse As Boolean, Optional forceReadData As Boolean = False) As Boolean
Dim i As Long, x1 As Long, y1 As Long, x2 As Long, y2 As Long
Dim dat As T_CURVE_DATA

If updateDataIfNeed() = False Then Exit Function

' переключаем дистанции области отрисовки на относительные,
' чтобы исключить искажени€ в последних знаках значени€ с плавающей точкой
' при больших дистанци€х отрисовываемых значений
Dim saveScaleLeft As Double
saveScaleLeft = pic.ScaleLeft
pic.ScaleLeft = 0

dat = dataArray(0)
x1 = dat.pos - saveScaleLeft
y1 = transData(dat)

For i = 1 To dataNodes - 1
 dat = dataArray(i)
 x2 = dat.pos - saveScaleLeft
 y2 = transData(dat)
 ln.drawNode pic, x1, y1, x2, y2, reverse, diskret, cycledLevel, lineColor
 x1 = x2
 y1 = y2
Next

' восстанавливаем координаты области отрисовки
pic.ScaleLeft = saveScaleLeft
End Function

Private Function getCurveType(ByVal indx As Integer) As Integer
Select Case indx
 Case 1
  getCurveType = TURN_GOR
 Case 2
  getCurveType = TURN_VER
 Case Else
  getCurveType = TURN_3D
End Select
End Function

'заполн€ет пол€ данных структуры dat на отметке dat.pos
Private Sub getCurve(dat As T_CURVE_DATA)
Dim dt As T_TURNDATA, typ As Integer
Dim buf As String, ret As Long, verr As String
Dim dstStart As Long, dstEnd As Long, hlen As Long

dat.angle = 0
dat.radius = 0
If trc.vog.curveLength = 0 Then
 ogdWin.Alert "Ќе могу вычислить изгиб поворота нулевой длины."
 Exit Sub
End If

typ = getCurveType(ln.Index)

hlen = trc.vog.curveLength / 2
If hlen = 0 Then hlen = 1

dstStart = dat.pos - hlen
If dstStart < 0 Then dstStart = 0

If GetCurveData(trc.handle, CLng(0), typ, dstStart, trc.vog.curveLength, trc.Diametr, 0, dt) = KRT_ERR Then
 buf = String(1024, Asc(" "))
 ret = vogError(buf)
 verr = Left$(buf, InStr(buf, Chr(0)) - 1)
 ogdWin.Alert _
  "ќшибка при вычислении изгиба." & _
  vbNewLine & verr
 Exit Sub
End If
 
ang.radian = dt.angle
dat.angle = ang.degree * 100

On Error GoTo labOvrflw
dat.radius = dt.radius * 100 / trc.Diametr
Exit Sub

labOvrflw:
dat.radius = trc.curve.valMax
End Sub

Private Function fillArray() As Boolean
Dim dat As T_CURVE_DATA, dataEnd As Long ', lastPos As Long

fillArray = False

dataEnd = dataStart + dataLength
dataNodes = 0

dat.pos = trc.pageStart
getCurve dat

dataMin = dat
dataMax = dat

Do While dat.pos < dataEnd
 dataArray(dataNodes) = dat
 dat.pos = dat.pos + 10
 getCurve dat
 dataNodes = dataNodes + 1
 dataArray(dataNodes) = dat
 If dat.angle < dataMin.angle Then dataMin.angle = dat.angle
 If dat.angle > dataMax.angle Then dataMax.angle = dat.angle
 If dat.radius < dataMin.radius Then dataMin.radius = dat.radius
 If dat.radius > dataMax.radius Then dataMax.radius = dat.radius
Loop
fillArray = True
End Function

Private Function updateDataIfNeed() As Boolean
updateDataIfNeed = True

If dataLength <> trc.pageLength Then
 dataLength = trc.pageLength
 clsSensorLine_ClearData
End If

If dataLengthMax < dataLength Then
 dataLengthMax = dataLength
 'предполагаетс€, что шага показаний меньше миллиметра нету и буфер дл€ данных выдел€етс€ с избытком
 ReDim dataArray(dataLengthMax) As T_CURVE_DATA
 clsSensorLine_ClearData
End If

If Not (dataStart = trc.pageStart) Then
 dataStart = trc.pageStart
 updateDataIfNeed = fillArray()
End If

End Function

Private Sub Class_Initialize()
Set ln = New clsSensorLine
dataStart = -1
dataLengthMax = -1
dataNodes = 0
End Sub

Public Sub Init(trace As clsTrace, ByVal indx As Integer)
Set trc = trace
ln.Init trc, SENS_CURVE, indx
End Sub

Private Property Get clsSensorLine_Caption() As String
Select Case ln.Index
 Case 0
  clsSensorLine_Caption = "»згиб 3D"
 Case 1
  clsSensorLine_Caption = "»згиб XY"
 Case 2
  clsSensorLine_Caption = "»згиб Z"
 Case Else
  clsSensorLine_Caption = "???"
End Select
End Property

Private Sub clsSensorLine_drawNode(pic As PictureBox, ByVal x1 As Long, ByVal y1 As Long, ByVal x2 As Long, ByVal y2 As Long, ByVal reverse As Boolean, ByVal diskret As Boolean, ByVal cycledLevel As Long, ByVal lineColor As Long)
ln.drawNode pic, x1, y1, x2, y2, reverse, diskret, cycledLevel, lineColor
End Sub

Private Property Get clsSensorLine_errText() As String
clsSensorLine_errText = ln.errText
End Property

Private Function clsSensorLine_getVal(ByVal x As Long) As Long
Dim dat As T_CURVE_DATA

dat.pos = x
getCurve dat
clsSensorLine_getVal = transData(dat)
End Function

Private Property Let clsSensorLine_Index(ByVal RHS As Integer)
Exit Property
End Property

Private Property Get clsSensorLine_Index() As Integer
clsSensorLine_Index = ln.Index
End Property

Private Sub clsSensorLine_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal indx As Integer)
Me.Init trace, indx
End Sub

Private Property Get clsSensorLine_markB() As Long
If d_markB.pos <> trc.mark.black Then
 d_markB.pos = trc.mark.black
 getCurve d_markB
End If
clsSensorLine_markB = transData(d_markB)
End Property

Private Property Get clsSensorLine_markW() As Long
If d_markW.pos <> trc.mark.white Then
 d_markW.pos = trc.mark.white
 getCurve d_markW
End If
clsSensorLine_markW = transData(d_markW)
End Property

Private Property Get clsSensorLine_maxPageVal() As Long
If updateDataIfNeed() Then
 clsSensorLine_maxPageVal = transData(dataMax)
 Else
 clsSensorLine_maxPageVal = -1
End If
End Property

Private Property Get clsSensorLine_minPageVal() As Long
If updateDataIfNeed() Then
 clsSensorLine_minPageVal = transData(dataMin)
 Else
 clsSensorLine_minPageVal = -1
End If
End Property

Private Property Get clsSensorLine_typ() As KRT_SENS
clsSensorLine_typ = SENS_CURVE
End Property

Private Property Let clsSensorLine_visible(ByVal RHS As Boolean)
ln.visible = RHS
End Property

Private Property Get clsSensorLine_visible() As Boolean
clsSensorLine_visible = ln.visible
End Property
