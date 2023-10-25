VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsVog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'секция trc-файла [Trace]
Private Const TR_ITM_CURVELEN = "CurveLength"
'секция пользовательских настроек
Private Const CTL_VOG = "ctlVog"
Private Const VOG_ANGLE = "vogAngle"
Private Const VOG_KX = "vogKX"
Private Const VOG_KZ = "vogKZ"
Private Const VOG_VIEW_START = "vogViewStart"
Private Const VOG_VIEW_END = "vogViewEnd"
Private Const VOG_SHOW_WELD = "vogShowWeld"

Private d_enbl As Boolean
Private trc As clsTrace
Private d_vis As Boolean

Public angle As Double
Public yMult As Integer
Public zMult As Integer
Public saveStart As Long
Public saveEnd As Long
Public showWelds As Boolean

Public curveLength As Integer

Property Get visible() As Boolean
visible = IIf(Me.enable, d_vis, False)
End Property

Property Let visible(v As Boolean)
d_vis = IIf(Me.enable, v, False)
End Property

Property Get enable() As Boolean
enable = d_enbl
End Property

Public Sub disable()
d_enbl = False
End Sub

Public Sub Init(trace As clsTrace, ByVal isEnable As Boolean)

Set trc = trace
d_enbl = isEnable

curveLength = trc.secTrace.getInt(TR_ITM_CURVELEN, 100)
visible = trc.getUserBool(CTL_VOG, False)
angle = val(trc.getUser(VOG_ANGLE, cfg.vog.rotAngle))
yMult = trc.getUser(VOG_KX, cfg.vog.sldY.dflt)
zMult = trc.getUser(VOG_KZ, cfg.vog.sldZ.dflt)
saveStart = trc.getUser(VOG_VIEW_START, 0)
saveEnd = trc.getUser(VOG_VIEW_END, trc.length)
showWelds = trc.getUserBool(VOG_SHOW_WELD, True)

Dim d As T_VOGDRIVERDATA
d.IsProfil = Abs(trc.drv.IsProfil)
d.OdoAngle = trc.drv.OdoAngle
d.ProfilPigLength = trc.drv.profPigLength
vogInit d

End Sub

Public Sub Save()
trc.secTrace.setInt TR_ITM_CURVELEN, curveLength
trc.setUserBool CTL_VOG, visible
trc.setUser VOG_ANGLE, dblStr(angle)
trc.setUser VOG_KX, yMult
trc.setUser VOG_KZ, zMult
trc.setUser VOG_VIEW_START, saveStart
trc.setUser VOG_VIEW_END, saveEnd
trc.setUserBool VOG_SHOW_WELD, showWelds
End Sub

Public Sub getCoord(ByVal dst As Long, ByRef x As Long, ByRef y As Long, ByRef z As Long, _
Optional ByRef vogext1 As Single = 0, Optional ByRef vogext2 As Single = 0, Optional ByRef vogext3 As Single = 0)
Dim node As T_NODEDATAGROUP

x = 0
y = 0
z = 0

If Not Me.enable Then Exit Sub

If krotGetFirstNodeGroup(trc.handle, node, dst, SENS_VOG, 1, 1) = KRT_ERR Then
 ogdWin.Alert _
 "Ошибка драйвера при вызове krotGetFirstNodeGroup." & _
 vbNewLine & lastError()
 Exit Sub
End If

x = node.vogx
y = node.vogy
z = node.vogZ
vogext1 = node.vogext1
vogext2 = node.vogext2
vogext3 = node.vogext3

End Sub

Public Function calcAngle(ByVal dstStart As Long, ByVal dstEnd As Long) As Double
Dim dt As T_TURNDATA

calcAngle = 0
If dstEnd = dstStart Then
 ogdWin.Alert "Не могу вычислить угол поворота нулевой длины."
 Exit Function
End If

If GetCurveData(trc.handle, CLng(0), TURN_3D, dstStart, dstEnd - dstStart, trc.pigDiam, 0, dt) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка при вычислении угла поворота." & _
  vbNewLine & vogLastErr()
 Exit Function
End If
calcAngle = dt.angle
End Function

Public Sub tubeCurve( _
ByVal tubeStart As Long, _
ByVal tubeLen As Long, _
ByRef tCurve As Double, _
ByRef tAngle As Double, _
ByRef curveComplex As Boolean _
)

Dim pig As Long, pig1 As Long, pig2 As Long
Dim pt1 As Long, pt2 As Long, tubePrev As Long, tubeNext As Long
Dim a As New clsAnglUnit
Dim tube00 As Long, tube01 As Long, tube02 As Long

tCurve = -1
tAngle = -1
curveComplex = False

If trc.vog.enable = False Then Exit Sub

tube01 = trc.getLenKoef(tubeStart, tubeLen)

pig = trc.pigL0 + trc.pigL1
pig2 = pig * 2 + VOG_SHIFT01 * 2
pig1 = pig + VOG_SHIFT01 * 2

tubePrev = trc.db.nearTubLength(tubeStart, True)
tube00 = trc.getLenKoef(tubeStart - tubePrev, tubePrev)

If tube01 < pig2 Then
 If tube01 < pig1 Then
  tubeNext = trc.db.nearTubLength(tubeStart, False)
  tube02 = trc.getLenKoef(tubeStart + tubeLen, tubeNext)
  ' Вариант 2 Изгиб короткой трубы (меньше одной длины снаряда)
  If (tube00 >= pig1) And (tube02 >= pig1) Then
   curveComplex = True
   pt1 = tubeStart - trc.pigL0 - VOG_SHIFT01
   pt2 = tubeStart + tubeLen + trc.pigL1 + VOG_SHIFT01
   a.radian = calcAngle(pt1, pt2)
   tCurve = a.fullHour
  Else
   ' Вариант 4 Общий изгиб серии коротких труб
   tCurve = -1
  End If
  
 Else
  
  ' Вариант 3 Изгиб короткой трубы (больше одной длины снаряда, но меньше двух)
   curveComplex = True
   pt1 = tubeStart - trc.pigL0 - VOG_SHIFT01
   pt2 = tubeStart + tubeLen + trc.pigL1 + VOG_SHIFT01
   a.radian = calcAngle(pt1, pt2)
   tCurve = a.fullHour
  
 End If
 
Else
 ' Вариант 1 Изгиб длинной трубы
 pt1 = tubeStart + trc.pigL1 + VOG_SHIFT01
 pt2 = tubeStart + tubeLen - trc.pigL0 - VOG_SHIFT01
 a.radian = calcAngle(pt1, pt2)
 tCurve = a.fullHour
End If

If curveComplex Then
 tAngle = -1
 Else
 If (tube00 < pig + VOG_SHIFT01) Or (tube01 < pig + VOG_SHIFT01) Then
  tAngle = -1
  Else
  pt1 = tubeStart - trc.pigL0 - VOG_SHIFT01
  pt2 = tubeStart + trc.pigL1 + VOG_SHIFT01
  a.radian = calcAngle(pt1, pt2)
  tAngle = a.fullHour
 End If
End If

End Sub

Public Function vogLastErr() As String
Dim buf As String, ret As Long

buf = String(1024, Asc(" "))
ret = vogError(buf)
vogLastErr = Left$(buf, InStr(buf, Chr(0)) - 1)
End Function
