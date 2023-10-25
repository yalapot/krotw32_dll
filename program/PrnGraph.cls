VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsPrnGraph"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const MAX_NODES = 200000
Private Const CURVE_STEP = 10

Private trc As clsTrace
Private frm As frmSpeed

Private d_typ As KRT_SENS
Private d_arrX() As Long
Private d_arrY() As Long
Private d_nodesCount As Long
Private d_minVal As Long
Private d_maxVal As Long
Private d_labMax As String
Private d_labMin As String
Private d_xMin As Long
Private d_xMax As Long
Private d_yMin As Long
Private d_yMax As Long
Private d_index As Long
Private d_units As Integer

Private d_title As String
Private d_titleY As String
Private d_titleX As String
Private d_cycled As Boolean
Private d_cycleBorder As Long

Private d_curveMeasureInNode As Long
Private ang As New clsAnglUnit

Private d_breakFlag As Boolean
Private d_warnFlag As Boolean

Private Function getY( _
ByVal xPrev As Long, _
ByVal xCurr As Long, _
ByVal yPrev As Long, _
ByVal yCurr As Long _
) As Long

Dim dltX As Long, dltY As Long

Select Case Me.typ

 Case SENS_TIMER
  getY = trc.speedAt(xCurr)

 Case SENS_ORIENT
  getY = 36000 * yCurr / trc.Coroz.zone(0).num

 Case SENS_TEMP, SENS_SHAKE, SENS_PRESS, SENS_ANGLE, SENS_EXT, KRT_SENS.SENS_AZIMUTH, KRT_SENS.SENS_TANGAZH
  getY = yCurr * 100
 
 Case SENS_THICK
 
  Select Case d_units
    Case 0
      getY = yCurr * 100
    Case 1
      getY = trc.magnit.getTesla(yCurr) * 100
  End Select
  
 Case SENS_CURVE
  getY = yCurr

End Select

End Function

Private Function getCurve(ByVal x As Long) As Single
Dim dt As T_TURNDATA
Dim buf As String, ret As Long, verr As String
Dim dstStart As Long, dstEnd As Long, hlen As Long

getCurve = 0
If trc.vog.curveLength = 0 Then
 ogdWin.Alert "Не могу вычислить изгиб поворота нулевой длины."
 Exit Function
End If

hlen = trc.vog.curveLength / 2
If hlen = 0 Then hlen = 1

dstStart = x - hlen
If dstStart < 0 Then dstStart = 0

If GetCurveData(trc.handle, CLng(0), TURN_3D, dstStart, trc.vog.curveLength, trc.Diametr, 0, dt) = KRT_ERR Then
 buf = String(1024, Asc(" "))
 ret = vogError(buf)
 verr = Left$(buf, InStr(buf, Chr(0)) - 1)
 ogdWin.Alert _
  "Ошибка при вычислении изгиба." & _
  vbNewLine & verr
 getCurve = 0
 Exit Function
End If

On Error GoTo labOvrflw

If trc.isCurveGraphRadius Then
 getCurve = dt.radius * 100 / trc.Diametr
 Else
 ang.radian = dt.angle
 getCurve = ang.degree * 100
End If

Exit Function

labOvrflw:
getCurve = trc.curve.valMax
End Function

Private Function getFirst(ByRef dat As T_NODEDATA, ByVal dStart As Long, ByVal dLength As Long) As Boolean
getFirst = False

Select Case Me.typ

 Case SENS_CURVE
  d_curveMeasureInNode = dLength / (CURVE_STEP * MAX_NODES) + 1
  dat.prevPos = dStart
  dat.sensVal = getCurve(dStart)

 Case SENS_TIMER
  If krotGetFirstNode(trc.handle, dat, dStart, Me.typ, d_index, 0, 0) = KRT_ERR Then
   ogdWin.Alert "Ошибка при формировании графика (krotGetFirstNode)" & vbNewLine & lastError()
   Exit Function
  End If

 Case Else
  If krotGetFirstNode(trc.handle, dat, dStart, Me.typ, d_index, dLength, MAX_NODES - (MAX_NODES / 10)) = KRT_ERR Then
   ogdWin.Alert "Ошибка при формировании графика (krotGetFirstNode)" & vbNewLine & lastError()
   Exit Function
  End If
  If krotLockNodeSequence(trc.handle, 1) = KRT_ERR Then
   ogdWin.Alert "Не могу включить режим блокировки" & vbNewLine & lastError()
   Exit Function
  End If

End Select

getFirst = True
End Function

Private Function getNext(ByRef dat As T_NODEDATA) As Boolean
Dim i As Integer, x As Long, v As Long

Select Case Me.typ

 Case SENS_TIMER
  x = trc.speedVector
  x = dat.prevPos + x * SV_AMPL
  If krotGetFirstNode(trc.handle, dat, x, Me.typ, d_index, 0, 0) = KRT_ERR Then
   getNext = False
   Exit Function
  End If

 Case SENS_CURVE
  dat.sensVal = 0
  For i = 1 To d_curveMeasureInNode
   x = dat.prevPos + i * CURVE_STEP
   v = getCurve(x)
   If v > dat.sensVal Then dat.sensVal = v
  Next
  dat.prevPos = x

 Case Else
  If krotGetNextNode(trc.handle, dat) = KRT_ERR Then
   getNext = False
   Exit Function
  End If
 
End Select

getNext = True
End Function

Public Function readData() As Boolean
Dim dat As T_NODEDATA, x As Long, y As Long
Dim dstStart As Long, dstEnd As Long, s As String, curX As Long, lastX As Long
Dim lastY As Long, currY As Long, dispY As Long

readData = False
ReDim d_arrX(0 To MAX_NODES) As Long
ReDim d_arrY(0 To MAX_NODES) As Long

dstStart = 0
dstEnd = trc.length
d_breakFlag = False
d_warnFlag = False

If getFirst(dat, dstStart, dstEnd - dstStart) = KRT_ERR Then Exit Function

y = dat.sensVal
x = dat.prevPos
lastX = 0
lastY = 0

d_arrY(0) = 0
d_arrX(0) = 0
d_nodesCount = 1

d_yMin = d_minVal
d_yMax = d_yMin

s = frm.Caption
While x < dstEnd

 If getNext(dat) = False Then
  x = dstEnd
  'ogdWin.Alert "Ошибка при чтении таймера (krotGetNextNode)" & vbNewLine & lastError()
  'Exit Sub
 Else

  currY = getY(x, dat.prevPos, y, dat.sensVal)
  If d_yMin > currY Then d_yMin = currY
  If d_yMax < currY Then d_yMax = currY
  
  If d_cycled Then
   dispY = IIf(Abs(currY - lastY) > d_cycleBorder, Me.holeValue, currY)
   Else
   dispY = currY
  End If
  lastY = currY

  d_arrY(d_nodesCount) = dispY
  d_arrX(d_nodesCount) = trc.getDistKoef(dat.prevPos)  'мм
  d_nodesCount = d_nodesCount + 1
  y = dat.sensVal
  x = dat.prevPos
  curX = Fix(x / 1000000)
  If curX > lastX Then
   lastX = curX
   frm.Caption = "Формирую график. " & lastX & " / " & Fix(dstEnd / 1000000) & " км"
  End If
 End If

 If d_nodesCount = MAX_NODES - 1 Then
  ogdWin.Alert "Слишком много узлов в графике!!!"
  x = dstEnd
 End If

 If d_breakFlag Then
  'ogdWin.Alert "Расчет графика прерван"
  d_breakFlag = False
  d_nodesCount = 0
  frm.Caption = s
  krotLockNodeSequence trc.handle, 0
  Exit Function
 End If

 ogdPause 10

Wend

krotLockNodeSequence trc.handle, 0

ReDim Preserve d_arrX(0 To d_nodesCount - 1) As Long
ReDim Preserve d_arrY(0 To d_nodesCount - 1) As Long
frm.Caption = s
readData = True
End Function

Public Sub setLang()
Dim tit As EXP_MSG, titY As EXP_MSG

Select Case Me.typ
 Case KRT_SENS.SENS_TIMER
  tit = expSpeedTitle
  titY = expSpeedY
 Case KRT_SENS.SENS_TEMP
  tit = expTempTitle
  titY = expTempY
 Case KRT_SENS.SENS_ORIENT
  tit = expOrientTitle
  titY = expOrientY
 Case KRT_SENS.SENS_SHAKE
  tit = expShakeTitle
  titY = expShakeY
 Case KRT_SENS.SENS_PRESS
  tit = expPressTitle
  titY = expPressY
 Case KRT_SENS.SENS_ANGLE
  tit = expAngleTitle
  titY = expAngleY
 Case KRT_SENS.SENS_CURVE
  tit = expCurveTitle
  titY = expCurveY
 Case KRT_SENS.SENS_THICK
  tit = expThickTitle
  titY = expThickY
 Case KRT_SENS.SENS_AZIMUTH
  tit = expAzimuthTitle
  titY = expAzimuthY
 Case KRT_SENS.SENS_TANGAZH
  tit = expTangazhTitle
  titY = expTangazhY

 Case KRT_SENS.SENS_EXT
  d_title = trc.sensExt(d_index).name
  d_titleY = ""
  d_titleX = cfg.lngExpress.msg(expX)
  Exit Sub

 Case Else
 Exit Sub
End Select

d_title = cfg.lngExpress.msg(tit)
d_titleY = cfg.lngExpress.msg(titY)
d_titleX = cfg.lngExpress.msg(expX)
End Sub

Property Get Index() As Long
Index = d_index
End Property

Property Let Index(i As Long)
If d_typ = SENS_EXT Then
 d_index = i
End If
End Property

Public Function Init( _
sens As clsSensor, _
trace As clsTrace, _
fSpeed As frmSpeed, _
Optional indx As Integer = -1 _
) As Boolean

Init = False
d_typ = sens.typ
d_index = indx
d_units = 0
Set trc = trace
Set frm = fSpeed

d_nodesCount = 0
d_cycled = False
setLang

Select Case Me.typ

 Case KRT_SENS.SENS_TIMER
  d_minVal = trc.speed.valMin
  d_maxVal = trc.speed.valMax
  d_labMax = "Макс.скорость"
  d_labMin = "Мин.скорость"

 Case KRT_SENS.SENS_TEMP
  d_minVal = trc.temp.valMin * 100
  d_maxVal = trc.temp.valMax * 100
  d_labMax = "Макс.температура, град C"
  d_labMin = "Мин.температура, град C"

 Case KRT_SENS.SENS_ORIENT
  d_minVal = 0
  d_maxVal = 36000
  d_labMax = "Верхняя граница, град"
  d_labMin = "Нижняя граница, град"

 Case KRT_SENS.SENS_SHAKE
  d_minVal = trc.shake.valMin * 100
  d_maxVal = trc.shake.valMax * 100
  d_labMax = "Макс.вибрация, ед.АЦП"
  d_labMin = "Мин.вибрация, ед.АЦП"

 Case KRT_SENS.SENS_PRESS
  d_minVal = trc.press.valMin * 100
  d_maxVal = trc.press.valMax * 100
  d_labMax = "Макс.давление, ед.АЦП"
  d_labMin = "Мин.давление, ед.АЦП"

 Case KRT_SENS.SENS_THICK
  d_minVal = trc.thick.valMin * 100
  d_maxVal = trc.thick.valMax * 100
  d_labMax = "Макс.толщина"
  d_labMin = "Мин.толщина"

 Case KRT_SENS.SENS_AZIMUTH
  d_minVal = trc.azimuth.valMin * 100
  d_maxVal = trc.azimuth.valMax * 100
  d_labMax = "Макс.азимут, сотые градуса"
  d_labMin = "Мин.азимут, сотые градуса"

 Case KRT_SENS.SENS_TANGAZH
  d_minVal = trc.tangazh.valMin * 100
  d_maxVal = trc.tangazh.valMax * 100
  d_labMax = "Макс.тангаж, сотые градуса"
  d_labMin = "Мин.тангаж, сотые градуса"

 Case KRT_SENS.SENS_CURVE
  d_minVal = trc.curve.valMin / 100
  d_maxVal = trc.curve.valMax / 100
  d_labMax = "Макс.изгиб"
  d_labMin = "Мин.изгиб"

 Case KRT_SENS.SENS_EXT
  d_minVal = trc.sensExt(d_index).valMin * 100
  d_maxVal = trc.sensExt(d_index).valMax * 100
  d_labMax = "Максимум"
  d_labMin = "Минимум"

 Case Else
  ogdWin.Alert "Неизвестный код типа датчиков " & Me.typ
  Exit Function

End Select

d_yMin = d_minVal
d_yMax = d_maxVal

d_cycleBorder = (d_maxVal - d_minVal) * 0.9

d_xMin = trc.getDistKoef(0)
d_xMax = trc.getDistKoef(trc.length)

Init = True
End Function

Property Get typ() As KRT_SENS
typ = d_typ
End Property

Property Get title() As String
title = d_title
End Property

Property Get titleY() As String
titleY = d_titleY
End Property

Property Get titleX() As String
titleX = d_titleX
End Property

Property Get Ymin() As Long
Ymin = d_yMin
End Property

Property Let Ymin(y As Long)
d_yMin = y
End Property

Property Get Ymax() As Long
Ymax = d_yMax
End Property

Property Let Ymax(y As Long)
d_yMax = y
End Property

Property Get arrX() As Variant
arrX = d_arrX
End Property

Property Get arrY() As Variant
arrY = d_arrY
End Property

Public Sub clearData()
d_nodesCount = 0
End Sub

Property Get nodesCount() As Long
nodesCount = d_nodesCount
End Property

Property Get labMax() As String
labMax = d_labMax
End Property

Property Get labMin() As String
labMin = d_labMin
End Property

Property Get breakFlag() As Boolean
breakFlag = d_breakFlag
End Property

Property Let breakFlag(b As Boolean)
d_breakFlag = b
End Property

Property Get Xmax() As Long
Xmax = d_xMax
End Property

Property Let Xmax(x As Long)
d_xMax = x
End Property

Property Get Xmin() As Long
Xmin = d_xMin
End Property

Property Let Xmin(x As Long)
d_xMin = x
End Property

Property Get valMax() As Long
valMax = d_maxVal
End Property

Property Get valMin() As Long
valMin = d_minVal
End Property

Property Get cycled() As Boolean
cycled = d_cycled
End Property

Property Let cycled(c As Boolean)
d_cycled = c
End Property

Property Get holeValue() As Long
holeValue = 0
End Property

Public Sub setUnits(ByVal units As Integer)
If d_units = units Then Exit Sub

d_units = units
Me.ClearData
End Sub
