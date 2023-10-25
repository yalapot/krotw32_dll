VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsCorozSettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const SY_PALLETE = "Pallete"
Private Const SY_CRZ_ZOOM_SYNC = "ZoomSync"
Private Const SY_CRZ_ZOOM_NO_SHIF = "ZoomNoShift"
Private Const SY_CRZ_DRAG = "CorozDrag"
Private Const SY_CRZSLITWIDTH = "slitArrowWidth"
Private Const SY_CRZ_ZOOM_CHANNEL = "Channel"
Private Const SY_CRZ_OBJ_INS = "ObjIns"
Private Const SY_PCPERF = "PCPerfomance"
Private Const SY_SCALEX = "dfltScaleX"
Private Const SY_SCALEY = "dfltScaleY"
Private Const SY_SCALEXMNU = "ScaleX"
Private Const SY_SCALEYMNU = "ScaleY"

Private cfgFile As String
Private cfgSec As String

Public dfltPal As String
Public zoomSync As Boolean
Public zoomNoShift As Boolean
Public corozDrag As Boolean
Public channel As Boolean
Public objIns As Boolean

Public scaleXmnu As String
Public scaleXdflt As Integer
Public scaleYmnu As String
Public scaleYdflt As Integer

Public slitWidth As Integer
Public PCperf As Long

Public Sub Init(iniFile As String, iniSec As String)
cfgFile = iniFile
cfgSec = iniSec
dfltPal = getParam(SY_PALLETE, "")
zoomSync = getParamBool(SY_CRZ_ZOOM_SYNC, False)
zoomNoShift = getParamBool(SY_CRZ_ZOOM_NO_SHIF, False)
corozDrag = getParamBool(SY_CRZ_DRAG, False)
channel = getParamBool(SY_CRZ_ZOOM_CHANNEL, False)
objIns = getParamBool(SY_CRZ_OBJ_INS, False)

scaleXmnu = getParam(SY_SCALEXMNU, "0")
scaleXdflt = getParam(SY_SCALEX, "0")
scaleYmnu = getParam(SY_SCALEYMNU, "0")
scaleYdflt = getParam(SY_SCALEY, "0")

slitWidth = getParam(SY_CRZSLITWIDTH, "5")
PCperf = getParam(SY_PCPERF, "100")
End Sub

Public Sub Save()
setParam SY_PALLETE, dfltPal
setParamBool SY_CRZ_ZOOM_SYNC, zoomSync
setParamBool SY_CRZ_ZOOM_NO_SHIF, zoomNoShift
setParamBool SY_CRZ_DRAG, corozDrag
setParamBool SY_CRZ_ZOOM_CHANNEL, channel
setParamBool SY_CRZ_OBJ_INS, objIns

setParam SY_SCALEXMNU, scaleXmnu
setParam SY_SCALEX, scaleXdflt
setParam SY_SCALEYMNU, scaleYmnu
setParam SY_SCALEY, scaleYdflt

setParam SY_CRZSLITWIDTH, slitWidth
setParam SY_PCPERF, PCperf
End Sub

Public Function scaleText(ByVal scl As Integer) As String
Select Case scl
 Case -1, 0, 1
 scaleText = "1:1"
 Case Is < 0 'растяжение
 scaleText = Abs(scl) & ":1"
 Case Is > 0 'сжатие
 scaleText = "1:" & scl
End Select
End Function

Private Function getParam(ByVal par As String, ByVal dflt As String) As String
getParam = getIniItem(cfgFile, cfgSec, par, dflt)
End Function

Private Sub setParam(ByVal par As String, ByVal dflt As String)
setIniItem cfgFile, cfgSec, par, dflt
End Sub

Private Function getParamBool(ByVal par As String, ByVal dflt As Boolean) As String
Dim s As Integer
s = getIniItem(cfgFile, cfgSec, par, "0")
getParamBool = IIf((s > 0), True, False)
End Function

Private Sub setParamBool(ByVal par As String, ByVal itmval As Boolean)
setIniItem cfgFile, cfgSec, par, IIf(itmval, "1", "0")
End Sub
