VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsIniSection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_file As String
Private d_sect As String

Public Sub Init(ByVal iniFile As String, ByVal iniSect As String)
d_file = iniFile
d_sect = iniSect
End Sub

Public Sub setStr(ByVal KeyName As String, ByVal KeyVal As String, Optional ByVal isShared As Boolean = False)
setIniItem d_file, d_sect, KeyName, KeyVal, isShared
End Sub

Public Function getStr(ByVal KeyName As String, ByVal dflt As String, Optional ByVal isShared As Boolean = False) As String
getStr = getIniItem(d_file, d_sect, KeyName, dflt, isShared)
End Function

Public Sub setBool(ByVal keyName As String, ByVal keyVal As Boolean)
Me.setStr keyName, IIf(keyVal, "1", "0")
End Sub

Public Function getBool(ByVal keyName As String, ByVal dflt As Boolean) As Boolean
Dim s As String

s = IIf(dflt, "1", "0")
s = Me.getStr(keyName, s)
getBool = IIf(s = "1", True, False)
End Function

Public Sub setInt(ByVal keyName As String, ByVal keyVal As Long)
Me.setStr keyName, "" & keyVal
End Sub

Public Function getInt(ByVal keyName As String, ByVal dflt As Long) As Long
Dim s As String

s = Me.getStr(keyName, "" & dflt)
getInt = val(s)
End Function

Public Sub setDbl(ByVal keyName As String, ByVal keyVal As Double)
Me.setStr keyName, dblStr(keyVal)
End Sub

Public Function getDbl(ByVal keyName As String, ByVal dflt As Double) As Double
Dim s As String

s = Me.getStr(keyName, dblStr(dflt))
getDbl = val(s)
End Function
