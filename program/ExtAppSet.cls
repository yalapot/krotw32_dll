VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsExtAppSet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_inifile As String
Private ZoomIDs() As String

Public krot_path As String

Public Function getParam(sec As String, par As String, dflt As String) As String
getParam = getIniItem(d_inifile, sec, par, dflt)
End Function

Public Sub Init(ByVal iniFile As String)
d_inifile = iniFile
krot_path = getParam("Krot", "Path", "krotw32.exe")
ZoomIDs = Split(getParam("Zoom", "Apps", ""), ";")
End Sub

Property Get zoomCount() As Integer
zoomCount = UBound(ZoomIDs) + 1
End Property

Public Function zoomApp(ByVal indx As Integer) As clsExtApp
Dim s As String, ap As clsExtApp

If indx = 0 Then
  Set ap = New clsExtApp
  ap.appid = ""
  ap.isRO = True
  ap.path = "notepad.exe"
  ap.title = "Блокнот"
  Set zoomApp = ap
  Exit Function
End If

s = ZoomIDs(indx - 1)
Set ap = New clsExtApp
ap.Init s, Me
Set zoomApp = ap
End Function
