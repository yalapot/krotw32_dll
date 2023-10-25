VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDirs"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'секция [Files] конфигурационного файла
Private Const FL_PRIMDIR = "PrimDir"
Private Const FL_PALDIR = "PalDir"
Private Const FL_TRCDIR = "InfDir"
Private Const FL_WORD_REPORT = "WordReport"
Private Const FL_WORD_RPT_DIR = "WordRptDir"
Private Const FL_OBJTEMPLETE = "TrcObj"

Public Rpt As String
Public Prim As String
Public Pal As String
Public Trc As String
Public ReportFile As String
Public dbTemplete As String

Private cfgFile As String
Private cfgSec As String

Public Sub Init(iniFile As String, iniSec As String)
cfgFile = iniFile
cfgSec = iniSec
Trc = getParam(FL_TRCDIR, "")
Rpt = getParam(FL_WORD_RPT_DIR, "")
Prim = getParam(FL_PRIMDIR, "")
Pal = getParam(FL_PALDIR, "")
ReportFile = getParam(FL_WORD_REPORT, "rus.dot")
dbTemplete = getParam(FL_OBJTEMPLETE, "")
End Sub

Private Function getParam(ByVal par As String, ByVal dflt As String) As String
getParam = getIniItem(cfgFile, cfgSec, par, dflt)
End Function

Private Sub setParam(ByVal par As String, ByVal dflt As String)
setIniItem cfgFile, cfgSec, par, dflt
End Sub

Public Sub Save()
setParam FL_TRCDIR, Trc
setParam FL_WORD_RPT_DIR, Rpt
setParam FL_PRIMDIR, Prim
setParam FL_PALDIR, Pal
setParam FL_WORD_REPORT, ReportFile
setParam FL_OBJTEMPLETE, dbTemplete
End Sub
