VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsObjSettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const SY_SQLLOG = "sqlLog"
Private Const SY_TUBECHECK = "tubeLengthCheck"
Private Const SY_OBJWELDDIST = "MinWeldDist"
Private Const SY_MAXOBJ = "MaxObjects"
Private Const SY_UPDTOBJ = "UpdateObjects"
Private Const SY_DSTTBLCOMMA = "DistTableComma"
Private Const SY_OBJLINE = "ObjectsLine"

Private cfgFile As String
Private cfgSec As String

Public sqlLog As String
Public distTblComma As String

Public tubeCheck As Integer
Public weldDist As Integer
Public updt As Integer
Public maxNum As Integer
Public dbLine As Boolean

Public Sub Init(iniFile As String, iniSec As String)
Dim s As String

cfgFile = iniFile
cfgSec = iniSec

sqlLog = getParam(SY_SQLLOG, "")
distTblComma = getParam(SY_DSTTBLCOMMA, ",")

s = getParam(SY_OBJLINE, "")
If UCase(s) = "YES" Then
 dbLine = True
 Else
 dbLine = False
End If

tubeCheck = getParam(SY_TUBECHECK, "0")
If tubeCheck < 0 Then tubeCheck = 0
If tubeCheck > 2 Then tubeCheck = 2
weldDist = getParam(SY_OBJWELDDIST, "2")
updt = getParam(SY_UPDTOBJ, "0")
maxNum = getParam(SY_MAXOBJ, "10")
End Sub

Public Sub Save()
setParam SY_SQLLOG, sqlLog
setParam SY_DSTTBLCOMMA, distTblComma

setParam SY_OBJLINE, IIf(dbLine, "YES", "")

setParam SY_TUBECHECK, tubeCheck
setParam SY_OBJWELDDIST, weldDist
setParam SY_UPDTOBJ, updt
setParam SY_MAXOBJ, maxNum
End Sub

Private Function getParam(ByVal par As String, ByVal dflt As String) As String
getParam = getIniItem(cfgFile, cfgSec, par, dflt)
End Function

Private Sub setParam(ByVal par As String, ByVal dflt As String)
setIniItem cfgFile, cfgSec, par, dflt
End Sub
