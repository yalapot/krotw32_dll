VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsExtApp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public appid As String
Public path As String
Public title As String
Public krot As String
Public isRO As Boolean
Public weburl As String
Public proxy As String

Public Sub Init(ByVal app_id As String, appset As clsExtAppSet)
Dim sec As String

Me.appid = app_id
sec = "App_" & Me.appid

Me.path = appset.getParam(sec, "Path", "")
Me.title = appset.getParam(sec, "Title", "")
Me.krot = appset.krot_path
Me.isRO = False

Me.weburl = appset.getParam(sec, "Weburl", "")
Me.proxy = appset.getParam(sec, "proxy", "")

If Len(appset.getParam(sec, "ReadOnly", "")) > 0 Then
  Me.isRO = True
End If
End Sub

Public Sub Run(ByVal data_file As String)
Dim cmd As String, winstyle As Integer

winstyle = vbNormalFocus
If Me.isRO Then
  Shell Me.path & " " & data_file, winstyle
Else
  cmd = Me.path & " " & data_file & " " & Me.krot
  If Len(Me.weburl) > 0 Then
    winstyle = vbHide
    cmd = cmd & " " & Me.weburl
    If Len(Me.proxy) > 0 Then
      cmd = cmd & " " & Me.proxy
    End If
  End If
  Shell cmd, winstyle
End If
End Sub
