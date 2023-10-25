VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsTubeScan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const TR_TSCAN_MIN = "scanTubeLenMin"
Private Const TR_TSCAN_MAX = "scanTubeLenMax"

Private Const TR_TSCAN_MASK_SIZE = "scanMaskSize"
Private Const TR_TSCAN_LIST_SIZE = "scanListSize"
Private Const TR_TSCAN_SIG_LEV = "scanSignalLevel"
Private Const TR_TSCAN_CRZ_INDEX = "scanCrzIndex"
Private Const TR_TSCAN_SLIT_NUM = "scanSlitNum"
Private Const TR_TSCAN_WSNS = "scanWeldSensitiv"
Private Const TR_TSCAN_LSNS = "scanSlitSensitiv"
Private Const TR_TSCAN_PSNS = "scanSpirSensitiv"

Private Const TR_TSCAN_CAN_DRC = "scanTubeCanDirect"
Private Const TR_TSCAN_CAN_SPR = "scanTubeCanSpiral"
Private Const TR_TSCAN_CAN_WTO = "scanTubeCanWithout"

Private Const TR_TSCAN_Weld1_width = "scanWeld1_width"
Private Const TR_TSCAN_Weld1_sens = "scanWeld1_sens"
Private Const TR_TSCAN_Weld1_bord = "scanWeld1_bord"
Private Const TR_TSCAN_Weld1_otst = "scanWeld1_otst"
Private Const TR_TSCAN_Weld2_width = "scanWeld2_width"
Private Const TR_TSCAN_Weld2_sens = "scanWeld2_sens"
Private Const TR_TSCAN_Weld2_bord = "scanWeld2_bord"
Private Const TR_TSCAN_Weld2_second = "scanWeld2_second"
Private Const TR_TSCAN_Spiral_width = "scanSpiral_width"
Private Const TR_TSCAN_Spiral_sens = "scanSpiral_sens"
Private Const TR_TSCAN_Spiral_bord = "scanSpiral_bord"
Private Const TR_TSCAN_Spiral_area = "scanSpiral_area"

Public Enum T_TUBE_TYPE
 TUBE_DIRECT = 0
 TUBE_SPIRAL = 1
 TUBE_WITHOUT = 2
End Enum

Public dfltTubeType As T_TUBE_TYPE

Private strErr As String
Private inp As VB_TUBE_SCAN_IN
Private out As VB_TUBE_SCAN_OUT
Private trc As clsTrace
Private crzIndx As Integer
Private crzSensType As KRT_SENS_TYPE

Property Get Weld1_sens() As Single
Weld1_sens = inp.Weld1_sens
End Property
Property Let Weld1_sens(l As Single)
If (l < 1#) Or (l > 10#) Then Err.Raise 11, Description:="Чувствительность поперечного шва должна быть от 1 до 10"
inp.Weld1_sens = l
End Property

Property Get Weld1_bord() As Single
Weld1_bord = inp.Weld1_bord
End Property
Property Let Weld1_bord(l As Single)
If (l < 1#) Or (l > 300#) Then Err.Raise 11, Description:="Порог фильтрации поперечного шва должен быть от 1 до 300"
inp.Weld1_bord = l
End Property

Property Get Weld1_width() As Integer
Weld1_width = inp.Weld1_width
End Property
Property Let Weld1_width(l As Integer)
If (l < 1) Or (l > 30) Then Err.Raise 11, Description:="Ширина поперечного шва должна быть от 1 до 30"
inp.Weld1_width = l
End Property

Property Get Weld1_otst() As Integer
Weld1_otst = inp.Weld1_otst
End Property
Property Let Weld1_otst(l As Integer)
If (l < 10) Or (l > 30) Then Err.Raise 11, Description:="Отступ поперечного шва должен быть от 10 до 30"
inp.Weld1_otst = l
End Property


Property Get Weld2_sens() As Single
Weld2_sens = inp.Weld2_sens
End Property
Property Let Weld2_sens(l As Single)
If (l < 1#) Or (l > 10#) Then Err.Raise 11, Description:="Чувствительность продольного шва должна быть от 1 до 10"
inp.Weld2_sens = l
End Property

Property Get Weld2_bord() As Single
Weld2_bord = inp.Weld2_bord
End Property
Property Let Weld2_bord(l As Single)
If (l < 1#) Or (l > 100#) Then Err.Raise 11, Description:="Порог фильтрации продольного шва должен быть от 1 до 100"
inp.Weld2_bord = l
End Property

Property Get Weld2_width() As Integer
Weld2_width = inp.Weld2_width
End Property
Property Let Weld2_width(l As Integer)
If (l < 1) Or (l > 30) Then Err.Raise 11, Description:="Ширина продольного шва должна быть от 1 до 30"
inp.Weld2_width = l
End Property

Property Get Weld2_second() As Integer
Weld2_second = inp.Weld2_second
End Property
Property Let Weld2_second(l As Integer)
If (l < 1) Or (l > 15) Then Err.Raise 11, Description:="Отступ продольного шва должен быть от 1 до 15"
inp.Weld2_second = l
End Property


Property Get Spiral_bord() As Single
Spiral_bord = inp.Spiral_bord
End Property
Property Let Spiral_bord(l As Single)
If (l < 1#) Or (l > 100#) Then Err.Raise 11, Description:="Порог фильтрации спирального шва должен быть от 1 до 100"
inp.Spiral_bord = l
End Property

Property Get Spiral_sens() As Single
Spiral_sens = inp.Spiral_sens
End Property
Property Let Spiral_sens(l As Single)
If (l < 1#) Or (l > 10#) Then Err.Raise 11, Description:="Чувствительность спирального шва должна быть от 1 до 10"
inp.Spiral_sens = l
End Property

Property Get Spiral_width() As Integer
Spiral_width = inp.Spiral_width
End Property
Property Let Spiral_width(l As Integer)
If (l < 1) Or (l > 30) Then Err.Raise 11, Description:="Ширина спирального шва должна быть от 1 до 30"
inp.Spiral_width = l
End Property

Property Get Spiral_area() As Integer
Spiral_area = inp.Spiral_area
End Property
Property Let Spiral_area(l As Integer)
If (l < 30) Or (l > Me.lenMax) Then Err.Raise 11, Description:="Ширина области спирального шва должен быть от 30 до максимальной ширины трубы"
inp.Spiral_area = l
End Property

Property Get crzIndex() As Integer
crzIndex = crzIndx
End Property

Property Let crzIndex(i As Integer)
crzIndx = i
End Property

Property Get lenMin() As Long
lenMin = inp.lenMin
End Property
Property Let lenMin(l As Long)
inp.lenMin = l
End Property

Property Get lenMax() As Long
lenMax = inp.lenMax
End Property
Property Let lenMax(l As Long)
inp.lenMax = l
End Property

Property Get spirSensitiv() As Integer
spirSensitiv = inp.spirSensitiv
End Property
Property Let spirSensitiv(i As Integer)
inp.spirSensitiv = i
End Property

Property Get slitSensitiv() As Integer
slitSensitiv = inp.slitSensitiv
End Property
Property Let slitSensitiv(i As Integer)
inp.slitSensitiv = i
End Property

Property Get weldSensitiv() As Integer
weldSensitiv = inp.weldSensitiv
End Property
Property Let weldSensitiv(i As Integer)
inp.weldSensitiv = i
End Property

Property Get slitNum() As Integer
slitNum = inp.slitNum
End Property
Property Let slitNum(i As Integer)
inp.slitNum = i
End Property

Property Get signalLevel() As Long
signalLevel = inp.signalLevel
End Property
Property Let signalLevel(i As Long)
inp.signalLevel = i
End Property

Property Get listSize() As Long
listSize = inp.listSize
End Property
Property Let listSize(i As Long)
inp.listSize = i
End Property

Property Get maskSize() As Long
maskSize = inp.maskSize
End Property
Property Let maskSize(i As Long)
inp.maskSize = i
End Property

Property Get canDirect() As Boolean
canDirect = IIf(inp.noDRC > 0, False, True)
End Property
Property Let canDirect(c As Boolean)
inp.noDRC = IIf(c, 0, 1)
End Property

Property Get canSpiral() As Boolean
canSpiral = IIf(inp.noSPR > 0, False, True)
End Property
Property Let canSpiral(c As Boolean)
inp.noSPR = IIf(c, 0, 1)
End Property

Property Get canWithout() As Boolean
canWithout = IIf(inp.noWTO > 0, False, True)
End Property
Property Let canWithout(c As Boolean)
inp.noWTO = IIf(c, 0, 1)
End Property

Property Get foundDist() As Long
foundDist = out.wldDst
End Property

Property Get foundLen() As Long
foundLen = out.wldDst - inp.scanStart
End Property

Property Get foundType() As T_TUBE_TYPE
foundType = out.wldTyp
End Property

Property Get foundWeld1() As Integer
foundWeld1 = out.wld1
End Property

Property Get foundWeld2() As Integer
foundWeld2 = out.wld2
End Property

Property Get sensorTypeString() As String
sensorTypeString = getCorozSensName(crzSensType)
End Property

Property Get sensorType() As KRT_SENS_TYPE
sensorType = crzSensType
End Property

Private Sub clearFound()
With out
.wldTyp = -1
.wldDst = -1
.wld1 = -1
.wld2 = -1
End With
End Sub

Property Get errText() As String
errText = strErr
End Property

Public Function FindAt(ByVal dstStart As Long, ByVal is2013 As Boolean) As Boolean
FindAt = False
clearFound
inp.scanStart = dstStart
If is2013 Then inp.maskSize = trc.Diametr

If krotScanWeld(trc.handle, Me.crzIndex, inp, out, IIf(is2013, 1, 0)) = KRT_ERR Then
 strErr = lastError()
 Exit Function
End If

If out.wldTyp = 2 Then out.wldTyp = dfltTubeType
If is2013 Then crzIndx = out.crzIndx

FindAt = True
End Function

Public Sub Init(trace As clsTrace)
Dim c_info As T_SENSGROUP

clearFound
Set trc = trace

If krotExtCorozInfo(trc.handle, 0, c_info) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка при вызове krotExtCorozInfo: " & vbNewLine & _
  "Handle = " & trc.handle & " zoneIndex = 0" & vbNewLine & _
  lastError()
End If

crzSensType = c_info.stype

Me.lenMin = trc.getUser(TR_TSCAN_MIN, "200")
Me.lenMax = trc.getUser(TR_TSCAN_MAX, "15000")

Me.maskSize = trc.getUser(TR_TSCAN_MASK_SIZE, "3")
Me.listSize = trc.getUser(TR_TSCAN_LIST_SIZE, "185")
Me.signalLevel = trc.getUser(TR_TSCAN_SIG_LEV, "4")
Me.crzIndex = trc.getUser(TR_TSCAN_CRZ_INDEX, "0")
Me.slitNum = trc.getUser(TR_TSCAN_SLIT_NUM, "1")
Me.weldSensitiv = trc.getUser(TR_TSCAN_WSNS, "50")
Me.slitSensitiv = trc.getUser(TR_TSCAN_LSNS, "80")
Me.spirSensitiv = trc.getUser(TR_TSCAN_PSNS, "80")

Me.canDirect = trc.getUserBool(TR_TSCAN_CAN_DRC, True)
Me.canSpiral = trc.getUserBool(TR_TSCAN_CAN_SPR, True)
Me.canWithout = trc.getUserBool(TR_TSCAN_CAN_WTO, False)


Me.Weld1_width = getLimWeld(TR_TSCAN_Weld1_width)
Me.Weld1_sens = getSKO(TR_TSCAN_Weld1_sens)
Me.Weld1_bord = trc.getUser(TR_TSCAN_Weld1_bord, "100")
Me.Weld1_otst = trc.getUser(TR_TSCAN_Weld1_otst, "20")

Me.Weld2_width = trc.getUser(TR_TSCAN_Weld2_width, "5")
Me.Weld2_sens = trc.getUser(TR_TSCAN_Weld2_sens, "3")
Me.Weld2_bord = trc.getUser(TR_TSCAN_Weld2_bord, "20")
Me.Weld2_second = trc.getUser(TR_TSCAN_Weld2_second, "10")

Me.Spiral_width = trc.getUser(TR_TSCAN_Spiral_width, "4")
Me.Spiral_sens = trc.getUser(TR_TSCAN_Spiral_sens, "3")
Me.Spiral_bord = trc.getUser(TR_TSCAN_Spiral_bord, "50")
Me.Spiral_area = trc.getUser(TR_TSCAN_Spiral_area, "100")
End Sub

Private Function getLimWeld(baseKey As String) As String
Dim pkey As String, pdflt As String

Select Case crzSensType
  Case KRT_SENS_TYPE.SENS_PROFIL
    pkey = "PRF"
    pdflt = "3"
  Case KRT_SENS_TYPE.SENS_INTROSCOPE
    pkey = "INTR"
    pdflt = "4"
  Case KRT_SENS_TYPE.SENS_TFI
    pkey = "TFI"
    pdflt = "4"
  Case Else
    pkey = "MFL"
    pdflt = "4"
End Select
getLimWeld = trc.getUser(baseKey & pkey, pdflt)
End Function

Private Function getSKO(baseKey As String) As String
Dim pkey As String, pdflt As String

Select Case crzSensType
  Case KRT_SENS_TYPE.SENS_PROFIL
    pkey = "PRF"
    pdflt = "4"
  Case KRT_SENS_TYPE.SENS_INTROSCOPE
    pkey = "INTR"
    pdflt = "4"
  Case KRT_SENS_TYPE.SENS_TFI
    pkey = "TFI"
    pdflt = "4"
  Case Else
    pkey = "MFL"
    pdflt = "3"
End Select
getSKO = trc.getUser(baseKey & pkey, pdflt)
End Function

Private Sub saveVal(baseKey As String, pvalue As String)
Dim pkey As String

Select Case crzSensType
  Case KRT_SENS_TYPE.SENS_PROFIL
    pkey = "PRF"
  Case KRT_SENS_TYPE.SENS_INTROSCOPE
    pkey = "INTR"
  Case KRT_SENS_TYPE.SENS_TFI
    pkey = "TFI"
  Case Else
    pkey = "MFL"
End Select
trc.setUser baseKey & pkey, pvalue
End Sub

Public Sub Save()
trc.setUser TR_TSCAN_MIN, Me.lenMin
trc.setUser TR_TSCAN_MAX, Me.lenMax

trc.setUser TR_TSCAN_MASK_SIZE, Me.maskSize
trc.setUser TR_TSCAN_LIST_SIZE, Me.listSize
trc.setUser TR_TSCAN_SIG_LEV, Me.signalLevel
trc.setUser TR_TSCAN_CRZ_INDEX, Me.crzIndex
trc.setUser TR_TSCAN_SLIT_NUM, Me.slitNum
trc.setUser TR_TSCAN_WSNS, Me.weldSensitiv
trc.setUser TR_TSCAN_LSNS, Me.slitSensitiv
trc.setUser TR_TSCAN_PSNS, Me.spirSensitiv

trc.setUserBool TR_TSCAN_CAN_DRC, Me.canDirect
trc.setUserBool TR_TSCAN_CAN_SPR, Me.canSpiral
trc.setUserBool TR_TSCAN_CAN_WTO, Me.canWithout

saveVal TR_TSCAN_Weld1_width, Me.Weld1_width
saveVal TR_TSCAN_Weld1_sens, Me.Weld1_sens
trc.setUser TR_TSCAN_Weld1_bord, Me.Weld1_bord
trc.setUser TR_TSCAN_Weld1_otst, Me.Weld1_otst
trc.setUser TR_TSCAN_Weld2_width, Me.Weld2_width
trc.setUser TR_TSCAN_Weld2_sens, Me.Weld2_sens
trc.setUser TR_TSCAN_Weld2_bord, Me.Weld2_bord
trc.setUser TR_TSCAN_Weld2_second, Me.Weld2_second
trc.setUser TR_TSCAN_Spiral_width, Me.Spiral_width
trc.setUser TR_TSCAN_Spiral_sens, Me.Spiral_sens
trc.setUser TR_TSCAN_Spiral_bord, Me.Spiral_bord
trc.setUser TR_TSCAN_Spiral_area, Me.Spiral_area
End Sub
