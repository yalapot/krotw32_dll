Attribute VB_Name = "help"
Option Explicit

Public Const KRT_INTRO = "Introduction"
Public Const KRT_ANALNAVIGATE = "AnaNavigate"
Public Const KRT_ObjAuto = "ObjAuto"
Public Const KRT_ObjAction = "ObjAction"
Public Const KRT_AnaCorozTube = "AnaCorozTube"
Public Const KRT_ObjCorrectTable = "ObjCorrectTable"
Public Const KRT_CfgDriver = "CfgDriver"
Public Const KRT_AnaVOGView = "AnaVOGView"
Public Const KRT_AnaCorozZoomGeom = "AnaCorozZoomGeom"
Public Const KRT_CfgDriverMagnet = "CfgDriverMagnet"
Public Const KRT_ObjTypeCommon = "ObjTypeCommon"
Public Const KRT_ObjTypeDfkt = "ObjTypeDfkt"
Public Const KRT_ObjFilter = "ObjFilter"
Public Const KRT_ObjTypeLine = "ObjTypeLine"
Public Const KRT_ObjTypeThick = "ObjTypeThick"
Public Const KRT_ObjTypeTurn = "ObjTypeTurn"
Public Const KRT_ObjTypeWeld = "ObjTypeWeld"
Public Const KRT_PalEdit = "PalEdit"
Public Const KRT_PalEditWork = "PalEditWork"
Public Const KRT_Cfg = "Cfg"
Public Const KRT_Reg = "Reg"
Public Const KRT_CfgCoroz = "CfgCoroz"
Public Const KRT_AnaGraph = "AnaGraph"
Public Const KRT_AnaControls = "AnaControls"
Public Const KRT_AnaFullGraph = "AnaFullGraph"
Public Const KRT_ObjTable = "ObjTable"
Public Const KRT_ObjTableColumn = "ObjTableColumn"
Public Const KRT_ObjTimeMark = "ObjTimeMark"
Public Const KRT_ObjTubeLength = "ObjTubeLength"
Public Const KRT_AnaVOGTurnMerge = "AnaVOGTurnMerge"
Public Const KRT_AnaCorozZoom = "AnaCorozZoom"
Public Const KRT_Ruler = "GraphRuler"

Private Const HH_DISPLAY_TOPIC = &H0
Private Const HH_HELP_CONTEXT = &HF

Private Declare Function HtmlHelp Lib "hhctrl.ocx" Alias "HtmlHelpA" ( _
  ByVal hwndCaller As Long, _
  ByVal pszFile As String, _
  ByVal uCommand As Long, _
  ByVal dwData As Long _
) As Long

Const SW_SHOWNORMAL = 1
Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
 ByVal hwnd As Long, _
 ByVal lpOperation As String, _
 ByVal lpFile As String, _
 ByVal lpParameters As String, _
 ByVal lpDirectory As String, _
 ByVal nShowCmd As Long _
) As Long

Private Declare Function GetDesktopWindow Lib "user32" () As Long

Public Sub ShowHelp(ByVal topic As String, Optional WindowPane As String = "")
Dim strFile As String, hRet As Long

strFile = App.path & "\krotw32.chm::/krotw32.htm#" & topic
If Len(WindowPane) > 0 Then
 strFile = Trim(strFile) & ">" & Trim(WindowPane)
End If
hRet = HtmlHelp(frmMain.hwnd, strFile, HH_DISPLAY_TOPIC, ByVal 0&)
End Sub

Public Function StartURL(URL As String) As Long
StartURL = ShellExecute(0, "Open", URL, vbNullString, "C:\", SW_SHOWNORMAL)
End Function