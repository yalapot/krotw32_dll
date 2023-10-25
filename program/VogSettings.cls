VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsVogSettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'секция [VOG] конфигурационного файла
Private Const SEC_VOG = "VOG"

Private Const VG_LOG = "Log"
Private Const VG_CALCZX = "calcZX"
Private Const VG_TUNE_START = "tuneStart"
Private Const VG_TUNE_END = "tuneEnd"
Private Const VG_MAXNODE = "NodeVisible"
Private Const VG_MARK_WIDTH = "MarkLineWidth"
Private Const VG_MARK_COLOR = "MarkLineColor"
Private Const VG_ROTATE_ANG = "rotateAngleXY"
Private Const VG_TURN_HOR = "turnHor"
Private Const VG_TURN_VER = "turnVer"
Private Const VG_SLDTYP_Z = "z"
Private Const VG_SLDTYP_Y = "y"

Private cfgFile As String

Public sldY As New clsVogSlideSetting
Public sldZ As New clsVogSlideSetting
Public logFile As String
Public turnHor As Double
Public turnVer As Double
Public rotAngle As Double
Public markWidth As Long
Public markColor As Long
Public maxNode As Integer
Public tuneStart As Boolean
Public tuneEnd As Boolean
Public calcXZ As Boolean

Public Sub Init(iniFile As String)
cfgFile = iniFile
sldY.Init cfgFile, SEC_VOG, VG_SLDTYP_Y
sldZ.Init cfgFile, SEC_VOG, VG_SLDTYP_Z
logFile = getParam(VG_LOG, "")
turnHor = getParam(VG_TURN_HOR, "2")
turnVer = getParam(VG_TURN_VER, "2")
rotAngle = getParam(VG_ROTATE_ANG, "0")
markWidth = getParam(VG_MARK_WIDTH, "3")
markColor = getParam(VG_MARK_COLOR, "" & CLR_GREEN_D)
maxNode = getParam(VG_MAXNODE, "10")
tuneStart = getParamBool(VG_TUNE_START, False)
tuneEnd = getParamBool(VG_TUNE_END, False)
calcXZ = getParamBool(VG_CALCZX, False)
End Sub

Public Sub Save()
setParam VG_LOG, logFile
setParam VG_TURN_HOR, turnHor
setParam VG_TURN_VER, turnVer
setParam VG_ROTATE_ANG, rotAngle
setParam VG_MARK_WIDTH, markWidth
setParam VG_MARK_COLOR, markColor
setParam VG_MAXNODE, maxNode
setParamBool VG_TUNE_START, tuneStart
setParamBool VG_TUNE_END, tuneEnd
setParamBool VG_CALCZX, calcXZ
sldY.Save
sldZ.Save
End Sub

Private Function getParamBool(ByVal par As String, ByVal dflt As Boolean) As String
Dim s As Integer
s = getIniItem(cfgFile, SEC_VOG, par, "0")
getParamBool = IIf((s > 0), True, False)
End Function

Private Sub setParamBool(ByVal par As String, ByVal itmval As Boolean)
setIniItem cfgFile, SEC_VOG, par, IIf(itmval, "1", "0")
End Sub

Private Function getParam(ByVal par As String, ByVal dflt As String) As String
getParam = getIniItem(cfgFile, SEC_VOG, par, dflt)
End Function

Private Sub setParam(ByVal par As String, ByVal itmval As String)
setIniItem cfgFile, SEC_VOG, par, itmval
End Sub
