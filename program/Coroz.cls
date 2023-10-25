VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsCoroz"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum T_SENSMODE
SN_NORMAL = 0
SN_FILTER = 1
SN_DELETE = 2
End Enum

Private Const S_DELIM = ";"

Private Const CRZ_ONE_SENS = "OneSens"
Private Const CRZ_VIS = "Vis"
Private Const CRZ_TOPSENS = "TopSens"
Private Const CRZ_SCALEY = "ScaleY"
Private Const CRZ_ROW = "Row"
Private Const CRZ_GRAPH = "GraphMode"
Private Const CRZ_GRAPHSENS = "GraphModeSens"
Private Const CRZ_GRAPHMUL = "GraphModeMul"
Private Const CRZ_MRK = "MarkDraw"
Private Const CRZ_BASELINE = "BaseLine"
Private Const CRZ_CIRC = "Circle"
Private Const CRZ_PAL = "Pal"
Private Const CRZ_PROFIL = "ProfilShow"
Private Const CRZ_OBJ_SLIT = "ShowObjSlit"
Private Const CRZ_OBJ_WELD = "ShowObjWeld"

Private Const CRZ_FILTER_ACTIVE = "FilterActive"
Private Const CRZ_FILTER_FILTER2019 = "Filter2019"
Private Const CRZ_FILTER_CONVOLUTION1 = "FilterConvolution1"
Private Const CRZ_FILTER_CONVOLUTION2 = "FilterConvolution2"
Private Const CRZ_FILTER_CONVOLUTION3 = "FilterConvolution3"
Private Const CRZ_FILTER_VOLOSOK = "FilterVolosok"
Private Const CRZ_FILTER_UNWELD = "FilterUnweld"
Private Const CRZ_FILTER_ROLL1 = "FilterRoll1"
Private Const CRZ_FILTER_ROLL2 = "FilterRoll2"
Private Const CRZ_FILTER_ROLL_AMPL = "FilterRollAmplifer"
Private Const CRZ_FILTER_TFI1 = "FilterTFI1"
Private Const CRZ_FILTER_TFI2 = "FilterTFI2"
Private Const CRZ_FILTER_TFI_BASE = "FilterTFI_BASE"

Private sens As clsSensor
Private trc As clsTrace
Private iniKey As String
Private d_indx As Integer
Private c_info As T_SENSGROUP
Private d_mmPerSensor As Single
Private snArr() As Long
Private mWhite As New clsCorozMark
Private mBlack As New clsCorozMark
Private d_topSens As Integer
Private d_isGraph As Boolean

Public isTubeProfVisible As Boolean
Public visible As Boolean
Public scaleY As Integer
Public isRow As Boolean
Public isMarkDraw As Boolean
Public grKoefSnsMin As Integer
Public grKoefMulMin As Integer
Public grKoefSnsMax As Integer
Public grKoefMulMax As Integer
Public showObjSlit As Boolean
Public showObjWeld As Boolean

Public d_oneSens As clsSensorGraphCoroz
Public circl As clsSensCircle
Public palette As clsPalette

Private t_paint As VB_PAINT_INFO
Private t_filter As VB_FILTER_INFO
Private t_graphs As VB_GRAPH_INFO

Private t_unweld As Long
Private t_volosok As Long
Private t_convolution1 As Long
Private t_Filter2019 As Long
Private t_convolution2 As Long
Private t_convolution3 As Long

Property Get grKoefSns() As Integer
grKoefSns = t_graphs.gap
End Property

Property Get grKoefMul() As Integer
grKoefMul = t_graphs.amplif
End Property

Property Get isGraph() As Boolean
isGraph = d_isGraph
End Property

Public Sub setGraphsMode(ByVal gap As Integer, ByVal amplif As Integer, ByVal isOn As Boolean)
t_graphs.gap = gap
t_graphs.amplif = amplif
d_isGraph = isOn
Me.baseLine = t_paint.baseLine
End Sub

Public Sub picChange(pic As PictureBox)
If Me.visible = False Then Exit Sub

trc.picWidthChange pic
If krotChangePic(trc.handle, Me.Index, pic.hWnd) = KRT_ERR Then
 ogdWin.Alert "krotChangePic crzIndex:" & Me.Index & vbNewLine & lastError()
 Exit Sub
End If
End Sub

Property Get topSens() As Integer
topSens = d_topSens
End Property

Property Let topSens(t As Integer)
If krotTopSens(trc.handle, Me.Index, t) = KRT_ERR Then
 ogdWin.Alert "krotTopSens " & Me.Index
 Exit Property
End If
d_topSens = t
End Property

Property Get filterRolledAmplifer() As Long
filterRolledAmplifer = t_filter.rolledAmplifer
End Property

Property Let filterRolledAmplifer(b As Long)
t_filter.rolledAmplifer = b
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterTFIbase() As Long
filterTFIbase = t_filter.tfiBase
End Property

Property Let filterTFIbase(b As Long)
t_filter.tfiBase = b
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterTFI1Param() As Long
filterTFI1Param = t_filter.tfiParam1
End Property

Property Let filterTFI1Param(b As Long)
t_filter.tfiParam1 = b
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterTFI2Param() As Long
filterTFI2Param = t_filter.tfiParam2
End Property

Property Let filterTFI2Param(b As Long)
t_filter.tfiParam2 = b
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterRolled1Param() As Long
filterRolled1Param = t_filter.rolledParam1
End Property

Property Let filterRolled1Param(b As Long)
t_filter.rolledParam1 = b
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterRolled2Param() As Long
filterRolled2Param = t_filter.rolledParam2
End Property

Property Let filterRolled2Param(b As Long)
t_filter.rolledParam2 = b
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterUnweldParam() As Long
filterUnweldParam = t_unweld
End Property

Property Let filterUnweldParam(b As Long)
t_unweld = b
t_filter.unweldParam = t_unweld
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterVolosokParam() As Long
filterVolosokParam = t_volosok
End Property

Property Let filterVolosokParam(b As Long)
t_volosok = b
t_filter.unweldParam = t_volosok
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterFilter2019Param() As Long
filterConvolution1Param = t_Filter2019
End Property

Property Let filterFilter2019Param(b As Long)
t_Filter2019 = b
t_filter.unweldParam = t_Filter2019
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterConvolution1Param() As Long
filterConvolution1Param = t_convolution1
End Property

Property Let filterConvolution1Param(b As Long)
t_convolution1 = b
t_filter.unweldParam = t_convolution1
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterConvolution2Param() As Long
filterConvolution2Param = t_convolution2
End Property

Property Let filterConvolution2Param(b As Long)
t_convolution2 = b
t_filter.unweldParam = t_convolution2
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get filterConvolution3Param() As Long
filterConvolution3Param = t_convolution3
End Property

Property Let filterConvolution3Param(b As Long)
t_convolution3 = b
t_filter.unweldParam = t_convolution3
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property


Property Get filterType() As Long
filterType = t_filter.active
End Property

Property Let filterType(b As Long)
t_filter.active = b
If krotScreenFilter(trc.handle, Me.Index, t_filter) = KRT_ERR Then
 ogdWin.Alert "krotScreenFilter " & Me.Index
End If
End Property

Property Get baseLine() As Long
baseLine = t_paint.baseLine
End Property

Property Let baseLine(b As Long)
t_paint.baseLine = b
If krotScreenMode(trc.handle, Me.Index, snArr(0), t_paint, t_graphs) = KRT_ERR Then
 ogdWin.Alert "krotScreenMode " & Me.Index
End If
End Property

Private Function getNumber(ByVal indx As Integer) As String
getNumber = " " & IIf(indx = 0, "основной", "доп. N " & indx)
End Function

Private Function getName(ByVal zoneType As KRT_SENS_TYPE, ByVal indx As Integer) As String
getName = getCorozSensName(zoneType) & getNumber(indx)
End Function

Public Sub Init(trace As clsTrace, ByVal indx As Integer, ByVal iniKeyName As String)
Dim i As Long

Set trc = trace
iniKey = iniKeyName
d_indx = indx
t_paint.orntOff = 1

If krotExtCorozInfo(trc.handle, indx, c_info) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка при вызове krotExtCorozInfo: " & vbNewLine & _
  "Handle = " & trc.handle & " zoneIndex = " & indx & vbNewLine & _
  lastError()
End If

sens.Init trc, SENS_COROZ, iniKey, getName(c_info.stype, indx), c_info.num, _
 IIf(c_info.isRow, c_info.minRowVal, c_info.minVal), _
 IIf(c_info.isRow, c_info.maxRowVal, c_info.maxVal)

Set d_oneSens = New clsSensorGraphCoroz
d_oneSens.Init trc, Me, iniKey & CRZ_ONE_SENS

Set circl = New clsSensCircle
circl.Init trc, Me, iniKey & CRZ_CIRC

Set palette = New clsPalette
palette.Init trc, Me, iniKey & CRZ_PAL

visible = trc.getUserBool(iniKey & CRZ_VIS, True)
topSens = trc.getUser(iniKey & CRZ_TOPSENS, "0")
isTubeProfVisible = trc.getUserBool(iniKey & CRZ_PROFIL, False)

scaleY = trc.getUser(iniKey & CRZ_SCALEY, trc.drv.scaleDflt(False))
isRow = trc.getUserBool(iniKey & CRZ_ROW, False)
d_isGraph = trc.getUserBool(iniKey & CRZ_GRAPH, False)

showObjSlit = trc.getUserBool(iniKey & CRZ_OBJ_SLIT, True)
showObjWeld = trc.getUserBool(iniKey & CRZ_OBJ_WELD, False)

grKoefSnsMin = 1
grKoefMulMin = 1
grKoefSnsMax = sens.num / 4
grKoefMulMax = sens.num / 4

t_graphs.gap = trc.getUser(iniKey & CRZ_GRAPHSENS, (grKoefSnsMin + 1))
t_graphs.amplif = trc.getUser(iniKey & CRZ_GRAPHMUL, (grKoefMulMin + 1))
t_graphs.clrBackGround = color.normalColor
t_graphs.clrEven = &HFF0000
t_graphs.clrOdd = &HFF0000

isMarkDraw = trc.getUserBool(iniKey & CRZ_MRK, False)

d_mmPerSensor = PI * trc.Diametr / Me.num
If d_mmPerSensor = 0 Then d_mmPerSensor = 1

ReDim snArr(Me.num) As Long
For i = 0 To Me.num - 1
 snArr(i) = SN_NORMAL
Next
Me.baseLine = trc.getUser(iniKey & CRZ_BASELINE, "-1")
Me.filterType = trc.getUser(iniKey & CRZ_FILTER_ACTIVE, "0")
Me.filterUnweldParam = trc.getUser(iniKey & CRZ_FILTER_UNWELD, "15")
Me.filterFilter2019Param = trc.getUser(iniKey & CRZ_FILTER_FILTER2019, "1")
Me.filterConvolution1Param = trc.getUser(iniKey & CRZ_FILTER_CONVOLUTION1, "1")
Me.filterConvolution2Param = trc.getUser(iniKey & CRZ_FILTER_CONVOLUTION2, "1")
Me.filterConvolution3Param = trc.getUser(iniKey & CRZ_FILTER_CONVOLUTION3, "1")
Me.filterVolosokParam = trc.getUser(iniKey & CRZ_FILTER_VOLOSOK, "1")
Me.filterRolled1Param = trc.getUser(iniKey & CRZ_FILTER_ROLL1, "2")
Me.filterRolled2Param = trc.getUser(iniKey & CRZ_FILTER_ROLL2, "5")
Me.filterRolledAmplifer = trc.getUser(iniKey & CRZ_FILTER_ROLL_AMPL, "10")
Me.filterTFI1Param = trc.getUser(iniKey & CRZ_FILTER_TFI1, "30")
Me.filterTFI2Param = trc.getUser(iniKey & CRZ_FILTER_TFI2, "2")
Me.filterTFIbase = trc.getUser(iniKey & CRZ_FILTER_TFI_BASE, "0")

mWhite.Init trc, Me, True
mBlack.Init trc, Me, False
End Sub

Public Sub Save()
Me.oneSens.Save
circl.Save
palette.Save
trc.setUserBool iniKey & CRZ_VIS, visible
trc.setUserBool iniKey & CRZ_PROFIL, isTubeProfVisible
trc.setUser iniKey & CRZ_TOPSENS, topSens
trc.setUser iniKey & CRZ_SCALEY, scaleY
trc.setUserBool iniKey & CRZ_ROW, isRow
trc.setUserBool iniKey & CRZ_GRAPH, isGraph

trc.setUserBool iniKey & CRZ_OBJ_SLIT, showObjSlit
trc.setUserBool iniKey & CRZ_OBJ_WELD, showObjWeld

trc.setUser iniKey & CRZ_GRAPHSENS, grKoefSns
trc.setUser iniKey & CRZ_GRAPHMUL, grKoefMul
trc.setUserBool iniKey & CRZ_MRK, isMarkDraw
trc.setUser iniKey & CRZ_BASELINE, baseLine
trc.setUser iniKey & CRZ_FILTER_ACTIVE, Me.filterType

trc.setUser iniKey & CRZ_FILTER_FILTER2019, Me.filterFilter2019Param
trc.setUser iniKey & CRZ_FILTER_CONVOLUTION1, Me.filterConvolution1Param
trc.setUser iniKey & CRZ_FILTER_CONVOLUTION2, Me.filterConvolution2Param
trc.setUser iniKey & CRZ_FILTER_CONVOLUTION3, Me.filterConvolution3Param
trc.setUser iniKey & CRZ_FILTER_VOLOSOK, Me.filterVolosokParam
trc.setUser iniKey & CRZ_FILTER_UNWELD, Me.filterUnweldParam
trc.setUser iniKey & CRZ_FILTER_ROLL1, Me.filterRolled1Param
trc.setUser iniKey & CRZ_FILTER_ROLL2, Me.filterRolled2Param
trc.setUser iniKey & CRZ_FILTER_ROLL_AMPL, Me.filterRolledAmplifer
trc.setUser iniKey & CRZ_FILTER_TFI1, Me.filterTFI1Param
trc.setUser iniKey & CRZ_FILTER_TFI2, Me.filterTFI2Param
trc.setUser iniKey & CRZ_FILTER_TFI_BASE, Me.filterTFIbase
End Sub

Private Sub Class_Initialize()
Set sens = New clsSensor
End Sub

Property Get line(ByVal indx As Integer) As clsSensorLine
Set line = sens.line(indx)
End Property

Property Get name() As String
name = sens.name
End Property

Property Get num() As Long
num = sens.num
End Property

Property Get sensType() As KRT_SENS_TYPE
sensType = c_info.stype
End Property

Property Get valMax() As Long
valMax = c_info.maxVal
End Property

Property Get valMin() As Long
valMin = c_info.minVal
End Property

Property Get Index() As Integer
Index = d_indx
End Property

Property Get valMinRow() As Long
valMinRow = c_info.minRowVal
End Property

Property Get valMaxRow() As Long
valMaxRow = c_info.maxRowVal
End Property

Property Get isRowPresent() As Boolean
isRowPresent = IIf(c_info.isRow > 0, True, False)
End Property

Property Get mmPerSensor() As Single
mmPerSensor = d_mmPerSensor
End Property

Public Function sens2hour(ByVal sensNum As Long) As Double
sens2hour = translateSens(sensNum, 12)
End Function

Public Function sens2degree(ByVal sensNum As Long) As Integer
sens2degree = translateSens(sensNum, 360)
End Function

Private Function translateSens(ByVal sensNum As Long, ByVal unitNum As Long) As Double
Dim i As Double

i = sensNum
i = i * unitNum
i = i / Me.num

If i > unitNum Then i = i - unitNum
If i < 0 Then i = i + unitNum
If i = 0 Then i = unitNum
translateSens = i
End Function

Property Get oneSens() As clsSensorGraphCoroz
Set oneSens = d_oneSens
End Property

Property Get markB(ByVal lineIndex As Long) As Long
markB = mBlack.data(lineIndex)
End Property

Property Get markW(ByVal lineIndex As Long) As Long
markW = mWhite.data(lineIndex)
End Property

Private Sub setCircleBorders()
Dim w1 As Long, b1 As Long, w2 As Long, b2 As Long

With circl

If .mwEnable Then

 w1 = mWhite.dataMin
 w2 = mWhite.dataMax
 If .mbEnable Then
  b1 = mBlack.dataMin
  b2 = mBlack.dataMax
  .brdMin = IIf(b1 < w1, b1, w1)
  .brdMax = IIf(b2 > w2, b2, w2)
  Else
  .brdMin = w1
  .brdMax = w2
 End If
 
 Else
 
 If .mbEnable Then
  b1 = mBlack.dataMin
  b2 = mBlack.dataMax
  .brdMin = b1
  .brdMax = b2
 End If

End If

End With
End Sub

Public Sub DrawCircle(pic As PictureBox)
Dim ScaleWidth As Long
If circl.autoBorders Then setCircleBorders

pic.Cls
pic.ScaleLeft = circl.brdMin

ScaleWidth = circl.brdMax - circl.brdMin
If ScaleWidth = 0 Then ScaleWidth = 200
'MsgBox CStr(circl.brdMax - circl.brdMin)

pic.ScaleWidth = ScaleWidth
pic.ScaleTop = 0
pic.ScaleHeight = Me.num

If circl.mwEnable Then mWhite.Draw pic, color.markWhite, circl.diskret
If circl.mbEnable Then mBlack.Draw pic, color.markBlack, circl.diskret
End Sub

Public Function drawCoroz(pic As PictureBox, ByVal forceReadData As Boolean) As Boolean

drawCoroz = False

If trc.isUserScale Then
 pic.ScaleLeft = 0
 pic.ScaleWidth = 1
 pic.BackColor = color.noData
 pic.Cls
 drawCoroz = True
 Exit Function
End If

If krotPaint(trc.handle, Me.Index, pic.hWnd, trc.pageStart, IIf(forceReadData, 1, 0), IIf(Me.isGraph, ZOOM_LINES, ZOOM_COMMON)) = KRT_ERR Then
 ogdWin.Alert "Error krotPaint:" & vbNewLine & lastError()
 Exit Function
End If

pic.ScaleLeft = trc.pageStart
pic.ScaleWidth = trc.pageLength

If Me.isMarkDraw Then Me.oneSens.drawMarks pic
drawCoroz = True
End Function

Property Get markerWhite() As clsCorozMark
Set markerWhite = mWhite
End Property

Property Get markerBlack() As clsCorozMark
Set markerBlack = mBlack
End Property