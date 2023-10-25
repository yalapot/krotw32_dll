VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsConfig"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'режимы сохранения настроек при закрытии прогона
Public Enum ExitModeCode
EM_NO_SAVE
EM_ASK_USER
EM_AUTO_SAVE
End Enum

'режимы использования колеса мыши
Public Enum MouseWeelModeCode
MW_NOTUSE
MW_HOR
MW_VER
MW_WIN
End Enum

'режимы вызова контекстного меню в линзе
Public Enum ZoomInsertModeCode
ZIM_MIDDLE_MOUSE
ZIM_RIGHT_MOUSE
End Enum

'секция [Files] конфигурационного файла
Private Const SEC_FILE = "Files"
Private Const FL_MAX_HISTORY = "MaxHistory"
Private Const FL_MAGNETS = "Magnets"
Private Const FL_DRIVER_DIR = "Drivers"
Private Const FL_DRIVER_INI = "DriverIni"
Private Const FL_PALDIR = "PalDir"
Private Const FL_EXTAPP = "ExternalApps"

Private Const USER_SETTINGS = "UserSettings"

'секция [System] конфигурационного файла
Private Const SEC_SYSTEM = "System"
Private Const SY_EXIT_MODE = "ExitMode"
Private Const SY_EXPRESS_OPEN = "ExpressOnOpen"
Private Const SY_ONLINE_OFF = "OnlineOff"
Private Const SY_MWEEL_MODE = "MouseWeelMode"
Private Const SY_ZIM_MODE = "ZoomInsertMode"
Private Const SY_EXPR_LANG = "ExpressLang"
Private Const SY_COLOR_MARK1 = "ColorMark1"
Private Const SY_COLOR_MARK2 = "ColorMark2"
Private Const SY_SYNC_JUMP = "SynhroJump"
Private Const SY_ZOOM_TYPE = "ZoomTypeSave"

'секция [LIST] файла drivers.ini
Private Const SEC_LIST = "List"
Private Const LS_DRIVERS = "Drivers"

'коды ошибок
Private Const ERR_OK = 0
Private Const ERR_CFG_NOT_FOUND = 1

Private cfgFile As String
Private errCode As Integer
Private extErr As String
Private currentHandle As Integer

Public isOnLine As Boolean
Public expressOnOpen As Boolean
Public exitMode As ExitModeCode
Public mouseWeelMode As MouseWeelModeCode
Public zoomInsertMode As ZoomInsertModeCode
Public syncJump As Boolean
Public zoomTypeSave As Boolean

Public Drivers As New clsDriverSet
Public Magnets As New clsMagnetSet
Public ExternalApps As New clsExtAppSet
Public parser As New clsCommandLine
Public lngExpress As New clsLangExp
Attribute lngExpress.VB_VarHelpID = -1
Public dir As New clsDirs
Public fileHist As New clsFileHistory
Public vog As New clsVogSettings
Public crz As New clsCorozSettings
Public obj As New clsObjSettings
Public pallette As New clsPalette
Public driverFolder As String
Public palleteFolder As String

Property Get newHandle() As Integer
currentHandle = currentHandle + 1
newHandle = currentHandle
End Property

Property Get errText() As String
Select Case errCode
 Case ERR_OK
  errText = "Все в порядке"
 Case ERR_CFG_NOT_FOUND
  errText = "Файл конфигурации не найден: " & _
  vbNewLine & extErr

 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property

Public Sub initMagnets()
If magnets.count = 0 Then
  magnets.Init getParam(SEC_FILE, FL_MAGNETS, "magnets.ini")
End If
End Sub

Public Sub initDrivers()
If Drivers.count = 0 Then
  Drivers.Init Magnets
End If
End Sub

Public Function Init(ByVal cfg As String) As Boolean
Dim s As String

Init = False

If ogdWin.fExist(cfg) = False Then
 errCode = ERR_CFG_NOT_FOUND
 extErr = cfg
 Exit Function
End If

cfgFile = cfg
vog.Init cfgFile
dir.Init cfgFile, SEC_FILE
crz.Init cfgFile, SEC_SYSTEM
obj.Init cfgFile, SEC_SYSTEM

driverFolder = getParam(SEC_FILE, FL_DRIVER_DIR, "")
palleteFolder = getParam(SEC_FILE, FL_PALDIR, "")
Me.ExternalApps.Init getParam(SEC_FILE, FL_EXTAPP, "")
syncJump = fileHist.getItem(USER_SETTINGS, SY_SYNC_JUMP, 1)
zoomTypeSave = fileHist.getItem(USER_SETTINGS, SY_ZOOM_TYPE, 0)
mouseWeelMode = fileHist.getItem(USER_SETTINGS, SY_MWEEL_MODE, "0")
zoomInsertMode = fileHist.getItem(USER_SETTINGS, SY_ZIM_MODE, "0")

s = getParam(SEC_SYSTEM, SY_EXIT_MODE, "0")
exitMode = EM_NO_SAVE
Select Case s
 Case "1"
 exitMode = EM_ASK_USER
 Case "2"
 exitMode = EM_AUTO_SAVE
End Select

expressOnOpen = getParamBool(SEC_SYSTEM, SY_EXPRESS_OPEN, True)
isOnLine = getParamBool(SEC_SYSTEM, SY_ONLINE_OFF, True)

fileHist.Init getParam(SEC_FILE, FL_MAX_HISTORY, "10")
lngExpress.langID = getParam(SEC_SYSTEM, SY_EXPR_LANG, lngExpress.langID)

color.markWhite = fileHist.getItem(SEC_SYSTEM, SY_COLOR_MARK1, color.markWhite)
color.markBlack = fileHist.getItem(SEC_SYSTEM, SY_COLOR_MARK2, color.markBlack)

Init = True
End Function

Private Function getParamBool(sec As String, ByVal itm As String, ByVal dflt As Boolean) As Boolean
Dim s As String

s = IIf(dflt, "1", "0")
s = getIniItem(cfgFile, sec, itm, s)
getParamBool = IIf(s = "1", True, False)
End Function

Private Sub setParamBool(sec As String, ByVal itm As String, ByVal itmval As Boolean)
setIniItem cfgFile, sec, itm, IIf(itmval, "1", "0")
End Sub

Private Sub setParam(sec As String, par As String, itmval As String)
setIniItem cfgFile, sec, par, itmval
End Sub

Private Function getParam(sec As String, par As String, dflt As String) As String
getParam = getIniItem(cfgFile, sec, par, dflt)
End Function

Property Get drvList() As String
drvList = getIniItem(Me.drvIni, SEC_LIST, LS_DRIVERS, "")
End Property

Public Sub saveDrvList(drvString As String)
setIniItem Me.drvIni, SEC_LIST, LS_DRIVERS, drvString
End Sub

Property Get drvIni() As String
drvIni = getParam(SEC_FILE, FL_DRIVER_INI, "drivers.ini")
End Property

Property Get fName() As String
fName = cfgFile
End Property

Property Get TimerInterval() As Long
Dim l As Long
On Error GoTo eh

l = 50
l = Abs(Me.crz.PCperf)
If l > 0 Then l = 1000 / l
eh:
TimerInterval = l
End Property

Public Sub Save(frm As frmMain)
dir.Save
vog.Save
crz.Save
obj.Save
fileHist.saveForm frm
setParam SEC_FILE, FL_MAX_HISTORY, fileHist.capacity

fileHist.setItem USER_SETTINGS, SY_MWEEL_MODE, mouseWeelMode
fileHist.setItem USER_SETTINGS, SY_ZIM_MODE, zoomInsertMode
fileHist.setItem USER_SETTINGS, SY_SYNC_JUMP, syncJump
fileHist.setItem USER_SETTINGS, SY_ZOOM_TYPE, zoomTypeSave

setParamBool SEC_SYSTEM, SY_EXPRESS_OPEN, expressOnOpen
setParamBool SEC_SYSTEM, SY_ONLINE_OFF, isOnLine
setParam SEC_SYSTEM, SY_EXIT_MODE, str$(exitMode)
setParam SEC_SYSTEM, SY_EXPR_LANG, lngExpress.langID

fileHist.setItem SEC_SYSTEM, SY_COLOR_MARK1, str$(color.markWhite)
fileHist.setItem SEC_SYSTEM, SY_COLOR_MARK2, str$(color.markBlack)
End Sub

Private Sub Class_Initialize()
krtPalInit
End Sub

Private Sub Class_Terminate()
krtPalClose
End Sub
