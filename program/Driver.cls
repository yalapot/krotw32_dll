VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDriver"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const DFLT_THICK = 10
Private Const DFLT_DIAM = 1000
Private Const DFLT_SPEED_VECTOR = 200
Private Const DFLT_ODO = 1
Private Const DFLT_PROF_ZERO = 65
Private Const DFLT_PROF_PIG_LENGTH = 925
Private Const DFLT_IS_PROFIL = False
Private Const DFLT_ODO_ANGLE = 0

Private Const SEC_DRIVER = "Driver_"
Private Const SEC_DRIVER_TRC = "Driver"
Private Const ITM_EXTEND = "Extend"
Private Const ITM_DESC = "Description"
Private Const ITM_EXT = "primeExt"
Private Const ITM_DIAM = "diamDflt"
Private Const ITM_DLL = "Path"
Private Const ITM_DFLTSCLX = "dfltScaleX"
Private Const ITM_DFLTSCLY = "dfltScaleY"
Private Const ITM_SCLX = "ScaleX"
Private Const ITM_SCLY = "ScaleY"
Private Const ITM_PALLETE = "Pallete"
Private Const ITM_THICK = "WallThick"
Private Const ITM_SPEED_VECTOR = "SpeedVector"
Private Const ITM_ODO_DFLT = "OdoKoefDflt"
Private Const ITM_PROF_ZERO = "ProfilZero"
Private Const ITM_PROF_PIG_LENGTH = "ProfilPigLength"
Private Const ITM_IS_PROFIL = "IsProfil"
Private Const ITM_ODO_ANGLE = "OdoAngle"
Private Const ITM_MAGNET = "MagnetID"

Private Enum T_ErrCode
 ALL_OK
 NO_DLL
 NO_DRV
End Enum

Private errCode As T_ErrCode
Private errCodeText As String

Private versionInfo As VB_DRV_INFO

Public dID As String
Private dDesc As String
Private dDll As String
Private dFileExt As String
Public dDiam As Integer
Private dPallete As String
Private dSclDfltX As Integer
Private dSclDfltY As Integer
Private dSclX As String
Private dSclY As String
Private dNumID As Long
Private dThick As Single
Private cfgFile As String
Private dSpeedVector As Long
Private dOdoDflt As Double
Private dProfZero As Integer
Private dProfPigLength As Integer
Private dIsProfil As Boolean
Private dOdoAngle As Integer

Public d_magnID As String
Public magnit As clsMagnit

Public outDrvSign As String
Public outDrvName As String
Public outDrvCopyRt As String
Public outFullDllPath As String

Property Get errText() As String
Select Case errCode
 Case ALL_OK
  errText = "Все в порядке"
 Case NO_DLL
  errText = "Не указано имя файла драйвера"
 Case NO_DRV
  errText = "Некорректный драйвер." & vbNewLine & errCodeText

 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property

Public Function Init(ByVal iniFile As String, drvSign As String, ByVal numId As Long, magnetSet As clsMagnetSet) As Boolean
Dim base_id As String, base_drv As clsDriver

cfgFile = iniFile

dID = drvSign
dNumID = numId

Set base_drv = New clsDriver
base_id = Trim$(getParam(ITM_EXTEND, ""))
If Len(base_id) > 0 Then
  base_drv.Init cfgFile, base_id, numId, magnetSet
End If

dDesc = getParam(ITM_DESC, base_drv.descripion)
dDll = getParam(ITM_DLL, base_drv.dll)
dDiam = getParam(ITM_DIAM, base_drv.diamDflt)
dFileExt = getParam(ITM_EXT, base_drv.fileExt)
dPallete = getParam(ITM_PALLETE, base_drv.pallete)
dSclDfltX = getParam(ITM_DFLTSCLX, base_drv.scaleDflt(True))
dSclDfltY = getParam(ITM_DFLTSCLY, base_drv.scaleDflt(False))
dSclX = getParam(ITM_SCLX, base_drv.scales(True))
dSclY = getParam(ITM_SCLY, base_drv.scales(False))
dThick = val(getParam(ITM_THICK, str$(base_drv.wallThick)))

d_magnID = getParam(ITM_MAGNET, base_drv.d_magnID)

If (magnetSet Is Nothing) = False Then
 Set magnit = magnetSet.Item(d_magnID)
End If

dSpeedVector = val(getParam(ITM_SPEED_VECTOR, str$(base_drv.speedVector)))
dOdoDflt = val(getParam(ITM_ODO_DFLT, str$(base_drv.odoKoef)))
dProfZero = val(getParam(ITM_PROF_ZERO, str$(base_drv.profZero)))
dProfPigLength = val(getParam(ITM_PROF_PIG_LENGTH, str$(base_drv.profPigLength)))
dIsProfil = CBool(getParam(ITM_IS_PROFIL, str$(base_drv.IsProfil)))
dOdoAngle = val(getParam(ITM_ODO_ANGLE, str$(base_drv.OdoAngle)))

Init = Me.LoadFromFile(Me.dll_path)
End Function

Public Function LoadFromFile(ByVal dllFile As String) As Boolean
Dim ret As Integer, buf1 As String, buf2 As String, buf3 As String, buf4 As String

LoadFromFile = False

If Len(dllFile) = 0 Then
 errCode = NO_DLL
 Exit Function
End If

buf1 = String(KRT_TEXT, Asc(" "))
buf2 = String(KRT_TEXT, Asc(" "))
buf3 = String(KRT_TEXT, Asc(" "))
buf4 = String(KRT_TEXT, Asc(" "))

ret = krotCheckDriver(dllFile, buf1, buf2, buf3, buf4, versionInfo)
If ret = KRT_ERR Then
 errCode = NO_DRV
 errCodeText = lastError()
 Exit Function
End If

Me.outDrvSign = Left$(buf1, InStr(buf1, Chr(0)) - 1)
Me.outDrvName = Left$(buf2, InStr(buf2, Chr(0)) - 1)
Me.outDrvCopyRt = Left$(buf3, InStr(buf3, Chr(0)) - 1)
Me.outFullDllPath = Left$(buf4, InStr(buf4, Chr(0)) - 1)

LoadFromFile = True
End Function

Private Function getParam(itm As String, dflt As String) As String
Dim s As String, beg As String, need_prefix As Boolean

If dNumID = -1 Then
 s = SEC_DRIVER_TRC
 Else
 need_prefix = False
 If Len(dID) > Len(SEC_DRIVER) Then
   beg = Mid$(dID, 1, Len(SEC_DRIVER))
   If beg <> SEC_DRIVER Then
     need_prefix = True
   End If
 Else
   need_prefix = True
 End If
 
 If need_prefix Then
   s = SEC_DRIVER & dID
 Else
   s = dID
 End If
End If
getParam = getIniItem(cfgFile, s, itm, dflt)
End Function

Private Sub setParam(itm As String, dflt As String)
Dim s As String

If dNumID = -1 Then
 s = SEC_DRIVER_TRC
 Else
 s = SEC_DRIVER & dID
End If

setIniItem cfgFile, s, itm, dflt
End Sub

Public Sub Save2Trc(ByVal trcFile As String)
Dim old_config As String, old_numid As Integer
Dim name As String, ext As String

old_numid = dNumID
old_config = cfgFile
dNumID = -1
cfgFile = trcFile
dPallete = cfg.palleteFolder & "\" & dPallete
Me.Save

cFile.fullName = Me.dll
setParam ITM_DLL, cFile.nameExt

name = cFile.name
ext = cFile.ext
cFile.fullName = trcFile
cFile.name = name
cFile.ext = ext

Me.loadFromFile Me.dll
On Error Resume Next
FileCopy Me.outFullDllPath, cFile.fullName
FileCopy dPallete, cFile.basePath & "palette.kpl"
On Error GoTo 0

dNumID = old_numid
cfgFile = old_config
End Sub

Public Sub Save()
setParam ITM_DESC, dDesc
setParam ITM_DLL, dDll
setParam ITM_DIAM, "" & dDiam
setParam ITM_EXT, dFileExt
setParam ITM_PALLETE, dPallete
setParam ITM_DFLTSCLX, "" & dSclDfltX
setParam ITM_DFLTSCLY, "" & dSclDfltY
setParam ITM_SCLX, "" & dSclX
setParam ITM_SCLY, "" & dSclY
setParam ITM_THICK, dblStr(dThick)

setParam ITM_SPEED_VECTOR, "" & dSpeedVector
setParam ITM_ODO_DFLT, dblStr(dOdoDflt)
setParam ITM_PROF_ZERO, "" & dProfZero
setParam ITM_PROF_PIG_LENGTH, "" & dProfPigLength
setParam ITM_IS_PROFIL, "" & Abs(dIsProfil)
setParam ITM_ODO_ANGLE, "" & dOdoAngle

setParam ITM_MAGNET, magnit.id
End Sub

Property Get profZero() As Integer
profZero = dProfZero
End Property

Property Let profZero(d As Integer)
dProfZero = d
End Property

Property Get profPigLength() As Integer
profPigLength = dProfPigLength
End Property

Property Let profPigLength(d As Integer)
dProfPigLength = d
End Property

Property Get IsProfil() As Boolean
IsProfil = dIsProfil
End Property

Property Let IsProfil(d As Boolean)
dIsProfil = d
End Property

Property Get OdoAngle() As Integer
OdoAngle = dOdoAngle
End Property

Property Let OdoAngle(d As Integer)
dOdoAngle = d
End Property

Property Get odoKoef() As Double
odoKoef = dOdoDflt
End Property

Property Let odoKoef(d As Double)
dOdoDflt = d
End Property

Property Get speedVector() As Long
speedVector = dSpeedVector
End Property

Property Let speedVector(l As Long)

If l < SV_MIN Then
 dSpeedVector = SV_MIN
 Exit Property
End If

If l > SV_MAX Then
 dSpeedVector = SV_MAX
 Exit Property
End If

dSpeedVector = l
End Property

Property Get id() As String
id = dID
End Property

Property Get idNum() As Long
idNum = dNumID
End Property

Property Get descripion() As String
descripion = dDesc
End Property

Property Get name() As String
name = "[" & Me.apiVer & "] " & Me.descripion
End Property

Property Let descripion(s As String)
dDesc = s
End Property

Property Get dll_path() As String
Dim name As String, ext As String

If dNumID = -1 Then
 cFile.fullName = Me.dll
 name = cFile.name
 ext = cFile.ext
 cFile.fullName = cfgFile
 cFile.name = name
 cFile.ext = ext
 dll_path = cFile.fullName
 Else
 dll_path = cfg.driverFolder & "\" & Me.dll
End If
End Property

Property Get dll() As String
dll = dDll
End Property

Property Let dll(s As String)
dDll = s
End Property

Property Get diamDflt() As Integer
diamDflt = dDiam
End Property

Property Let diamDflt(d As Integer)
dDiam = d
End Property

Property Get fileExt() As String
fileExt = dFileExt
End Property

Property Let fileExt(s As String)
dFileExt = s
End Property

Public Function scales(ByVal X As Boolean) As String
scales = IIf(X, dSclX, dSclY)
End Function

Public Sub scalesSet(ByVal X As Boolean, s As String)
If X Then
 dSclX = s
 Else
 dSclY = s
End If
End Sub

Public Function scaleDflt(ByVal X As Boolean) As Integer
scaleDflt = IIf(X, dSclDfltX, dSclDfltY)
End Function

Public Sub scaleDfltSet(ByVal X As Boolean, i As Integer)
If X Then
 dSclDfltX = i
 Else
 dSclDfltY = i
End If
End Sub

Property Get pallete() As String
pallete = dPallete
End Property

Property Let pallete(s As String)
dPallete = s
End Property

Property Get wallThick() As Single
wallThick = dThick
End Property

Property Let wallThick(t As Single)
dThick = t
End Property

Property Get apiVer() As Long
apiVer = versionInfo.apiVer
End Property

Property Get verMax() As Long
verMax = versionInfo.drvVerMax
End Property

Property Get verMin() As Long
verMin = versionInfo.drvVerMin
End Property

Property Get isSpiral() As Boolean
isSpiral = IIf(versionInfo.isSpiral = 0, False, True)
End Property

Private Sub Class_Initialize()
dID = ""
dDesc = "Драйвер "
dDll = ""
dDiam = DFLT_DIAM
dFileExt = "da"
dPallete = cfg.crz.dfltPal
dSclDfltX = cfg.crz.scaleXdflt
dSclDfltY = cfg.crz.scaleYdflt
dSclX = cfg.crz.scaleXmnu
dSclY = cfg.crz.scaleYmnu
dThick = DFLT_THICK
dSpeedVector = DFLT_SPEED_VECTOR
dOdoDflt = DFLT_ODO
dProfZero = DFLT_PROF_ZERO
dProfPigLength = DFLT_PROF_PIG_LENGTH
dIsProfil = DFLT_IS_PROFIL
dOdoAngle = DFLT_ODO_ANGLE
d_magnID = ""
End Sub