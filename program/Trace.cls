VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsTrace"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'секция trc-файла [Files]
Private Const SEC_FILES = "Files"
Private Const FL_ITM_WORD_RPT = "WordReport"
Private Const FL_ITM_DATABASE = "Database"

'секция trc-файла [Trace]
Private Const SEC_TRACE = "Trace"
Private Const TR_ITM_DRIVER = "Driver"
Private Const TR_ITM_DIAMETR = "Diametr"
Private Const TR_ITM_ODO_DIAM = "OdoDiametr"
Private Const TR_ITM_ODO_DIAM1 = "OdoDiametr1"
Private Const TR_ITM_ODO_DIAM2 = "OdoDiametr2"
Private Const TR_ITM_PIGLENGTH = "PigLength"
Private Const TR_ITM_PIGL0 = "PigL0"
Private Const TR_ITM_PIGL1 = "PigL1"
Private Const TR_ITM_PIGL3 = "PigL3"
Private Const TR_ITM_NEWEDIT = "newObjEdit"
Private Const TR_SCRL_SPEED = "scrollSpeed"
Private Const TR_START = "dstStart"
Private Const TR_PAGE = "pageLength"
Private Const TR_SCALE = "pageScale"
Private Const TR_SPEED_VECTOR = "speedVector"
Private Const TR_PROF_ZERO = "profilZero"
Private Const TR_EXP_GRAPH_COLOR = "ExpGraphColor"
Private Const TR_ITM_DISABLE_MDB_EDIT = "DisableMdbEdit"

'секция описания магнитной системы
Private Const SEC_MAGN = "MagnetSystem"

'секция пользовательских настроек
Private Const SEC_USER = "UserSettings"

Private Const CTL_SPEED = "ctlSpeed"
Private Const CTL_ORIENT = "ctlOrient" '0 - n
Private Const CTL_TIME = "ctlTime" '0 - n
Private Const CTL_ODO = "ctlOdo" '0 - n
Private Const CTL_SHAKE = "ctlShake" '0 - n
Private Const CTL_THICK = "ctlThick" '0 - n
Private Const CTL_PRESS = "ctlPress" '0 - n
Private Const CTL_TEMP = "ctlTemp" '0 - n
Private Const CTL_ANGLE = "ctlAngle" '0 - n
Private Const CTL_CURVE = "ctlCurve" '0 - n
Private Const CTL_EXT = "ctlExt" '0 - n
Private Const CTL_OBJ = "obj" '0 - n

Private Enum T_ErrCode
 ALL_OK
 TRC_NOT_FOUND
 BAD_DRV
 OPEN_ERROR
 REG_TRC
 REG_PRIM
End Enum

Private errCode As T_ErrCode
Private errCodeText As String

Private d_handle As Long
Private t_info As VB_TRACE_INFO
Private extSens() As clsSensorGraphExt

Public Timer As New clsSensor
Public odo As New clsSensor
Public shake As New clsSensorGraph
Public press As New clsSensorGraph
Public temp As New clsSensorGraph
Public angle As New clsSensorGraph
Public thick As New clsSensorGraph

Public d_ornt As New clsSensorGraphOrient
Private d_speed As New clsSensorGraphSpeed
Private d_curve As New clsSensorGraphCurve
Private d_azimuth As New clsSensorGraphVog
Private d_tangazh As New clsSensorGraphVog
Private d_file As New clsFile

Public drv As New clsDriver
Public vog As New clsVog
Public Coroz As New clsCorozZones
Public db As New clsDb
Public commentHistory As New clsHistory
Public magnit As New clsMagnit
Public mark As New clsMark
Public secUser As New clsIniSection
Public secFiles As New clsIniSection
Public secTrace As New clsIniSection

Public Description As String
Public rptFile As String
Public Diametr As Long

Public pigDiam As Long
Public odoDiam As Long
Public odoDiam1 As Long
Public odoDiam2 As Long
Public pigL0 As Long
Public pigL1 As Long
Public pigL3 As Long
Public objNewEdit As Boolean
Public expGraphColor As Long
Public isMdbRO As Boolean

Public tubeScan As New clsTubeScan

Private d_ScaleX As Integer
Private d_CorozWidth As Long
Private d_pageX As Long
Private d_pageStart As Long
Private d_pageStartPrev As Long
Private d_speedVector As Integer

Public scrollSpeed As Integer
Public profilZero As Integer
Public isUserScale As Boolean
Public extZoomData As String

Property Get speedVector() As Integer
speedVector = d_speedVector
End Property

Property Let speedVector(v As Integer)
If v <> d_speedVector Then
 d_speedVector = v
 Me.speed.ClearData
End If
End Property

Property Get errText() As String
Select Case errCode
 Case ALL_OK
  errText = "Все в порядке"
 Case TRC_NOT_FOUND
  errText = "Файл не найден:" & vbNewLine & Me.FileName
 Case BAD_DRV
  errText = "Неизвестный драйвер '" & errCodeText & "'" & vbNewLine & _
  "у записи " & Me.FileName
 Case OPEN_ERROR
  errText = "Ошибка при открытии прогона: " & _
  vbNewLine & Me.FileName & vbNewLine & lastError()
 Case REG_TRC
  errText = "Не указано имя trc-файла"
 Case REG_PRIM
  errText = "Не указан источник первичных данных"

 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property

Public Function Register( _
ByVal trcFile As String, _
ByVal desc As String, _
ByVal Mdb As String, _
ByVal diam As Long, _
ByVal driver As clsDriver _
) As Boolean

Register = False
Init trcFile
Set drv = driver

If Len(trcFile) = 0 Then
 errCode = REG_TRC
 Exit Function
End If

If Len(makeNewMdb(Mdb, cfg.dir.dbTemplete)) > 0 Then
 Me.secFiles.setStr FL_ITM_DATABASE, Me.getPathPack(Mdb)
 db.Init Me, CTL_OBJ
 db.odoKoef = driver.odoKoef
 If db.isNeedRecalc Then db.calcKoefData
End If

Me.secTrace.setStr TR_ITM_NAME, desc
Me.secTrace.setStr TR_ITM_DRIVER, drv.id
Me.secTrace.setInt TR_ITM_DIAMETR, diam
Me.secTrace.setBool TR_ITM_DISABLE_MDB_EDIT, False

commentHistory.Init Me

Dim comment_items As New Collection
Dim s As String, i As Integer

For i = 1 To commentHistory.maxItems
 s = getIniItem(cfg.fName, "CommentHistory", "Item" & i)
 If Len(Trim(s)) > 0 Then commentHistory.addItem s
Next

commentHistory.Save

drv.Save2Trc Me.FileName
drv.magnit.saveTo Me.FileName, SEC_MAGN
Register = True
End Function

Public Sub Init(ByVal trcFile As String)
d_file.fullName = trcFile
Me.secUser.Init Me.FileName, SEC_USER
Me.secFiles.Init Me.FileName, SEC_FILES
Me.secTrace.Init Me.FileName, SEC_TRACE
Me.extZoomData = ""
End Sub

Public Function traceOpen(ByVal trcFile As String) As Boolean
Dim s As String, ret As Integer, i As Long
Dim senInf As EXT_SENS_INFO

traceOpen = False
Init trcFile
Me.extZoomData = ""

If ogdWin.fExist(Me.FileName) = False Then
 errCode = TRC_NOT_FOUND
 Exit Function
End If

d_handle = cfg.newHandle

s = getIniItem(Me.FileName, SEC_TRACE, TR_ITM_DRIVER, "")
If drv.Init(Me.FileName, s, -1, Nothing) = False Then 'пробуем загрузить драйвер из trc
 If drv.Init(cfg.fName, s, 0, Nothing) = False Then  'пробуем загрузить драйвер из krotw32.ini
   errCode = BAD_DRV
   Exit Function
 End If
End If

ret = krotOpenTrace(Me.handle, Me.FileName, "", drv.dll_path, AddressOf newDataCallBack, t_info)
If ret = KRT_ERR Then
 errCode = OPEN_ERROR
 Exit Function
End If

Description = Me.secTrace.getStr(TR_ITM_NAME, "Новая запись")
Diametr = Me.secTrace.getInt(TR_ITM_DIAMETR, 1000)
rptFile = Me.secFiles.getStr(FL_ITM_WORD_RPT, cfg.dir.ReportFile)

pigDiam = Me.secTrace.getInt(TR_ITM_DIAMETR, 1000)
odoDiam = Me.secTrace.getInt(TR_ITM_ODO_DIAM, DFLT_ODO_DIAM)
odoDiam1 = Me.secTrace.getInt(TR_ITM_ODO_DIAM1, DFLT_ODO_DIAM)
odoDiam2 = Me.secTrace.getInt(TR_ITM_ODO_DIAM2, DFLT_ODO_DIAM)

expGraphColor = Me.secTrace.getInt(TR_EXP_GRAPH_COLOR, RGB(255, 0, 0))
 
i = Me.secTrace.getInt(TR_ITM_PIGLENGTH, 0)
pigL0 = Me.secTrace.getInt(TR_ITM_PIGL0, i)
pigL1 = Me.secTrace.getInt(TR_ITM_PIGL1, i)
pigL3 = Me.secTrace.getInt(TR_ITM_PIGL3, i)

objNewEdit = Me.secTrace.getBool(TR_ITM_NEWEDIT, False)
isMdbRO = Me.secTrace.getBool(TR_ITM_DISABLE_MDB_EDIT, False)

scrollSpeed = getUser(TR_SCRL_SPEED, 1)
Me.pageStart = getUser(TR_START, 0)

vog.Init Me, IIf(t_info.vog > 0, True, False)
Coroz.Init Me, t_info.crzZoneNum

ReDim extSens(Me.numExt) As clsSensorGraphExt
For i = 1 To t_info.extSensors
 getExtSensorInfo i - 1, senInf
 Set extSens(i) = New clsSensorGraphExt
 extSens(i).Init Me, CTL_EXT, senInf.name, i - 1, senInf.minValue, senInf.maxValue
Next i

Timer.Init Me, SENS_TIMER, CTL_TIME, "Таймеры", calcNum(t_info.Tmr.num), t_info.Tmr.minVal, t_info.Tmr.maxVal
odo.Init Me, SENS_ODO, CTL_ODO, "Одометры", calcNum(t_info.odom.num), t_info.odom.minVal, t_info.odom.maxVal
d_ornt.Init Me, CTL_ORIENT, calcNum(t_info.orient.num), t_info.orient.minVal, t_info.orient.maxVal      '!!!!!!! ориентация должна быть в градусах
angle.Init Me, SENS_ORIENT, CTL_ANGLE, "Вращение, датчики", calcNum(t_info.orient.num), t_info.orient.minVal, t_info.orient.maxVal, True '!!!!!!! ориентация должна быть в градусах
shake.Init Me, SENS_SHAKE, CTL_SHAKE, "Вибрация, ед.АЦП", calcNum(t_info.shake.num), t_info.shake.minVal, t_info.shake.maxVal, False
press.Init Me, SENS_PRESS, CTL_PRESS, "Давление", calcNum(t_info.press.num), t_info.press.minVal, t_info.press.maxVal, False
temp.Init Me, SENS_TEMP, CTL_TEMP, "Температура, град", calcNum(t_info.temp.num), t_info.temp.minVal, t_info.temp.maxVal, False
thick.Init Me, SENS_THICK, CTL_THICK, "Толщина стенки, ед.АЦП", calcNum(t_info.wall.num), t_info.wall.minVal, t_info.wall.maxVal, False
d_speed.Init Me, CTL_SPEED, "Скорость, м/с", -1, 10 't_info.speed.minVal, t_info.speed.maxVal
d_curve.Init Me, CTL_CURVE
d_azimuth.Init Me, GRAPH_AZIMUTH
d_tangazh.Init Me, GRAPH_TANGAZH

db.Init Me, CTL_OBJ
commentHistory.Init Me
tubeScan.Init Me
mark.Init Me
If magnit.restoreFrom(Me.FileName, SEC_MAGN) = False Then magnit.copyFrom drv.magnit

If magnit.prcnt.count < 1 Then
  ogdWin.Alert "Магнитная система этой записи не имеет кривых расчета глубины (проверьте параметр CurveNum секции [MagnetSystem] в trc файле)." & vbNewLine & "Расчет глубин дефектов будет отключен."
End If

d_CorozWidth = 1000 'кол-во пикселов по ширине развертки по умолчанию
Me.pageScaleX = getUser(TR_SCALE, Me.drv.scaleDflt(True))
If Me.isUserScale Then Me.pageLength = getUser(TR_PAGE, Me.length)

Me.speedVector = getUser(TR_SPEED_VECTOR, Me.drv.speedVector)
Me.profilZero = getUser(TR_PROF_ZERO, Me.drv.profZero)

traceOpen = True
Exit Function

badDrvId:
 Set drv = cfg.Drivers.Add(s)
 If drv Is Nothing Then
  errCodeText = s
  errCode = BAD_DRV
  Exit Function
 Else
  Resume Next
 End If
End Function

Private Function calcNum(ByVal num As Long) As Long
calcNum = IIf(num > 1, num + 1, num)
End Function

Private Sub getExtSensorInfo(Index As Long, sensInf As EXT_SENS_INFO)
Dim buf As String, ret As Long, sensStruct As T_SENS

buf = String(KRT_MAX_EXTSEN_NAME, Asc(" "))

ret = krotExtSensorInfo(Me.handle, Index, sensStruct, buf)
If ret = KRT_OK Then
 sensInf.name = Left$(buf, InStr(buf, Chr(0)) - 1)
 sensInf.minValue = sensStruct.minVal
 sensInf.maxValue = sensStruct.maxVal
End If
End Sub

Public Function traceClose() As Boolean
traceClose = False

If krotCloseTrace(Me.handle) = KRT_ERR Then
 ogdWin.Alert "Ошибка при закрытии прогона: " & _
 vbNewLine & Me.FileName & vbNewLine & lastError()
 Exit Function
End If

If db.enable Then db.CloseDb
Me.extZoomData = ""

Class_Initialize
traceClose = True
End Function

Property Get FileName() As String
FileName = d_file.fullName
End Property

Property Get handle() As Long
handle = d_handle
End Property

Property Get Step() As Long
Step = t_info.odom.stepSize
End Property

Property Get length() As Long
length = t_info.odom.maxVal - t_info.odom.minVal
End Property

Property Get numExt() As Long
numExt = t_info.extSensors
End Property

Property Get sensExt(ByVal indx As Integer) As clsSensorGraph
If (indx < 0) Or (indx > Me.numExt) Then
 ogdWin.Alert "Bad index in extSens"
 Exit Property
End If
Set sensExt = extSens(indx + 1)
End Property

Property Get sensExtVis() As Boolean
Dim i As Integer

sensExtVis = True
For i = 0 To Me.numExt - 1
 If Me.sensExt(i).visible Then Exit Property
Next
sensExtVis = False
End Property

Public Function getUser(ByVal itm As String, ByVal dflt As String, Optional ByVal isShared As Boolean = False) As String
getUser = Me.secUser.getStr(itm, dflt, isShared)
End Function

Public Function getUserBool(ByVal itm As String, ByVal dflt As Boolean) As Boolean
getUserBool = Me.secUser.getBool(itm, dflt)
End Function

Public Sub setUserBool(ByVal itm As String, ByVal itmval As Boolean)
Me.secUser.setBool itm, itmval
End Sub

Public Sub setUser(ByVal itm As String, ByVal itmval As String, Optional ByVal isShared As Boolean = False)
Me.secUser.setStr itm, itmval, isShared
End Sub

Public Sub Save()
Dim i As Integer

Me.secTrace.setStr TR_ITM_NAME, Description
Me.secTrace.setInt TR_ITM_DIAMETR, Diametr
Me.secFiles.setStr FL_ITM_WORD_RPT, rptFile

Me.secTrace.setInt TR_ITM_DIAMETR, pigDiam
Me.secTrace.setInt TR_ITM_ODO_DIAM, odoDiam
Me.secTrace.setInt TR_ITM_ODO_DIAM1, odoDiam1
Me.secTrace.setInt TR_ITM_ODO_DIAM2, odoDiam2
Me.secTrace.setInt TR_ITM_PIGL0, pigL0
Me.secTrace.setInt TR_ITM_PIGL1, pigL1
Me.secTrace.setInt TR_ITM_PIGL3, pigL3
Me.secTrace.setInt TR_EXP_GRAPH_COLOR, expGraphColor

Me.secTrace.setBool TR_ITM_NEWEDIT, objNewEdit

setUser TR_SCRL_SPEED, scrollSpeed

For i = 0 To Me.numExt - 1
 Me.sensExt(i).Save
Next

db.Save
tubeScan.Save
Coroz.Save
vog.Save
Timer.Save
odo.Save
ornt.Save
shake.Save
press.Save
temp.Save
angle.Save
thick.Save
Me.speed.Save
Me.curve.Save
Me.azimuth.Save
Me.tangazh.Save
commentHistory.Save
mark.Save

setUser TR_START, Me.pageStart
setUser TR_SCALE, Me.pageScaleX
setUser TR_SPEED_VECTOR, Me.speedVector
setUser TR_PROF_ZERO, Me.profilZero

If Me.isUserScale Then setUser TR_PAGE, Me.pageLength

End Sub

Public Sub SaveLocalMagnet()
magnit.saveTo Me.FileName, SEC_MAGN
End Sub

'return speed value in cm/sec at point on dst
Public Function speedAt(ByVal dst As Long) As Long
speedAt = d_speed.atDist(dst)
End Function

Property Get speed() As clsSensorGraph
Set speed = d_speed
End Property

Property Get curve() As clsSensorGraph
Set curve = d_curve
End Property

Property Get azimuth() As clsSensorGraph
Set azimuth = d_azimuth
End Property

Property Get tangazh() As clsSensorGraph
Set tangazh = d_tangazh
End Property

Public Sub distSave()
setUser TR_START, Me.pageStart
End Sub

Private Sub Class_Initialize()
errCode = ALL_OK
d_handle = -1
End Sub

Public Function getLenKoef(ByVal strt As Long, ByVal ln As Long) As Long
Select Case Me.distMode
 Case 0 'коэф-нт одометра
  getLenKoef = ln * Me.odoKoef
 Case 1 'таблица поправок
  If Me.db.enable Then
   getLenKoef = Me.getDistKoef(strt + ln) - Me.getDistKoef(strt)
   Else
   getLenKoef = ln
  End If
End Select
End Function

Public Function getLenReal(ByVal strtReal As Long, ByVal ln As Long) As Long
Dim d As Double

Select Case Me.distMode
 Case 0 'коэф-нт одометра
  d = ln
  getLenReal = d / Me.odoKoef
 Case 1 'таблица поправок
  If Me.db.enable Then
   getLenReal = Me.getDistReal(Me.getDistKoef(strtReal) + ln) - strtReal
   Else
   getLenReal = ln
  End If
End Select
End Function

Public Function getDistKoef(ByVal dst As Long) As Long
Select Case Me.distMode
 Case 0 'коэф-нт одометра
  getDistKoef = dst * Me.odoKoef - Me.odoStart
 Case 1 'таблица поправок
  If Me.db.enable Then
   getDistKoef = db.getDistKoef(dst) - Me.odoStart
   Else
   getDistKoef = dst
  End If
End Select
End Function

Public Function getDistReal(ByVal dst As Long) As Long
Dim d As Double

Select Case Me.distMode
 Case 0 'коэф-нт одометра
  d = dst + Me.odoStart
  d = d / Me.odoKoef
  getDistReal = d
 Case 1 'таблица поправок
  If Me.db.enable Then
   getDistReal = db.getDistReal(dst + Me.odoStart)
   Else
   getDistReal = dst
  End If
End Select
End Function

Public Function ScaleNumber(ByVal scl As Integer, ByVal numberVal As Long) As Long
Select Case scl
 Case -1, 0, 1
 ScaleNumber = numberVal
 Case Is < 0 'растяжение
 ScaleNumber = Fix(numberVal / -scl)
 Case Is > 0 'сжатие
 ScaleNumber = numberVal * scl
End Select
End Function

Private Function changePage() As Boolean
d_pageX = Me.ScaleNumber(d_ScaleX, d_CorozWidth) * Me.Step
setStart
changePage = True
End Function

Property Get pagePicWidth() As Long
pagePicWidth = d_CorozWidth
End Property

Public Function picWidthChange(pic As PictureBox) As Boolean
Dim p As Long

p = pic.width - NON_CLIENT_AREA
If d_CorozWidth = p Then Exit Function
d_CorozWidth = p

If Me.isUserScale = False Then changePage
picWidthChange = True
End Function

Property Get pageScaleXLast() As Integer
pageScaleXLast = d_ScaleX
End Property

Property Get pageScaleX() As Integer
If isUserScale Then
 pageScaleX = USER_SCALE_X
 Else
 pageScaleX = d_ScaleX
End If
End Property

Property Let pageScaleX(i As Integer)
If i = USER_SCALE_X Then
 isUserScale = True
 Exit Property
End If

isUserScale = False
d_ScaleX = i

If krotPageScale(Me.handle, d_ScaleX) = KRT_ERR Then
 ogdWin.Alert "Error krotPageScale" & vbNewLine & lastError()
End If

changePage
setStart
End Property

Property Get smallShift() As Long
Dim x As Integer

If Me.isUserScale Then
 x = 1
 Else
 If d_ScaleX > 1 Then
  x = d_ScaleX
  Else
  x = 1
 End If
End If

smallShift = Me.Step * Me.scrollSpeed * 2 * x
End Property

Property Get pageLength() As Long
pageLength = d_pageX
End Property

Property Let pageLength(p As Long)
d_pageX = p
Me.pageScaleX = USER_SCALE_X
setStart
End Property

Property Get pageStart() As Long
pageStart = d_pageStart
End Property

Property Let pageStart(p As Long)
d_pageStartPrev = d_pageStart
d_pageStart = p
setStart
End Property

Private Sub setStart()
If (d_pageStart + d_pageX) > Me.length Then d_pageStart = Me.length - d_pageX
If d_pageStart < 0 Then d_pageStart = 0
End Sub

Property Get pageLastShift() As Long
pageLastShift = d_pageStart - d_pageStartPrev
End Property

Property Get isOnLine() As Boolean
isOnLine = IIf(t_info.onLine = 0, False, True)
End Property

Property Get odoKoef() As Double
If db.enable Then
 odoKoef = db.odoKoef
 Else
 odoKoef = 1
End If
End Property
Property Let odoKoef(d As Double)
db.odoKoef = d
End Property

Property Get distMode() As Integer
If db.enable Then
 distMode = db.distMode
 Else
 distMode = 0
End If
End Property
Property Let distMode(d As Integer)
db.distMode = d
End Property

Property Get odoStart() As Long
If db.enable Then
 odoStart = db.odoStart
 Else
 odoStart = 0
End If
End Property
Property Let odoStart(d As Long)
db.odoStart = d
End Property

Property Get isNeedRecalc() As Boolean
If db.enable Then
 isNeedRecalc = db.isNeedRecalc
 Else
 isNeedRecalc = False
End If
End Property

Public Function getPathFull(ByVal fPath As String) As String
With cFile
.fullName = fPath
If (Len(.path) = 0) And (Len(.drive) = 0) Then
 .drive = d_file.drive
 .path = d_file.path
End If
getPathFull = .fullName
End With
End Function

Public Function getPathPack(ByVal fPath As String) As String
With cFile
.fullName = fPath
If (UCase(.drive) = UCase(.drive)) And (UCase(.path) = UCase(.path)) Then
 getPathPack = .nameExt
 Else
 getPathPack = fPath
End If
End With
End Function

Public Function getTopSens(ByVal x As Long, ByVal indx As Integer, ByVal zoneNum As Integer) As Integer
Dim dat As T_NODEDATA

getTopSens = 0
If Me.angle.num = 0 Then Exit Function

If krotGetFirstNode(Me.handle, dat, x, SENS_ORIENT, (indx - 1), 0, 0) = KRT_ERR Then
 ogdWin.Alert "Error ctrlOrient.getTopSens.krotGetFirstNode" & vbNewLine & lastError()
 getTopSens = 0
 Exit Function
End If
getTopSens = dat.sensVal * Me.Coroz.Zone(0).num / Me.Coroz.Zone(zoneNum).num
End Function

Property Get isCurveGraphRadius() As Boolean
isCurveGraphRadius = d_curve.isRadius
End Property

Property Let isCurveGraphRadius(b As Boolean)
d_curve.isRadius = b
End Property

Property Get ornt() As clsSensor
Set ornt = d_ornt
End Property