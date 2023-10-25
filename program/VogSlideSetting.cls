VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsVogSlideSetting"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const VG_SLD_MIN = "MultyMin"
Private Const VG_SLD_MAX = "MultyMax"
Private Const VG_SLD_SHIFT = "MultySmallStep"
Private Const VG_SLD_PAGE = "MultyPageStep"
Private Const VG_SLD_DFLT = "MultyDflt"

Public min As Long
Public max As Long
Public shift As Long
Public page As Long
Public dflt As Long

Private typ As String
Private cfgFile As String
Private cfgSec As String

Public Sub Init(iniFile As String, iniSec As String, sldType As String)
cfgFile = iniFile
cfgSec = iniSec
typ = sldType
min = getParam(VG_SLD_MIN, "1")
max = getParam(VG_SLD_MAX, "100")
shift = getParam(VG_SLD_SHIFT, "1")
page = getParam(VG_SLD_PAGE, "10")
dflt = getParam(VG_SLD_DFLT, "1")
End Sub

Private Function getParam(ByVal par As String, ByVal dflt As String) As String
getParam = getIniItem(cfgFile, cfgSec, typ & par, dflt)
End Function

Private Sub setParam(ByVal par As String, ByVal dflt As String)
setIniItem cfgFile, cfgSec, typ & par, dflt
End Sub

Public Sub Save()
setParam VG_SLD_MIN, min
setParam VG_SLD_MAX, max
setParam VG_SLD_SHIFT, shift
setParam VG_SLD_PAGE, page
setParam VG_SLD_DFLT, dflt
End Sub
