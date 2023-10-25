VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsFileHistory"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'секция для записи параметров главного окна
Private Const MDI_SEC = "FormMDI"
'сохраняемые параметры главного MDI окна
Private Const MDI_STATUS = "Status"
Private Const MDI_LEFT = "Left"
Private Const MDI_TOP = "Top"
Private Const MDI_WIDTH = "Width"
Private Const MDI_HEIGH = "Heigh"

'секция для записи имен файлов
Private Const HIST_SEC = "FilesTRC"

Private Const REGISTRY_SEC = "KrotW32"

Private fileHistory As New Collection

Public capacity As Long

Public Sub setItem(ByVal sec As String, ByVal key As String, ByVal val As String)
SaveSetting REGISTRY_SEC, sec, key, val
End Sub

Public Function getItem(ByVal sec As String, ByVal key As String, ByVal dflt As String)
getItem = GetSetting(REGISTRY_SEC, sec, key, dflt)
End Function

Private Sub setMDI(ByVal key As String, ByVal val As String)
setItem MDI_SEC, key, val
End Sub

Private Function getMDI(ByVal key As String, ByVal dflt As String)
getMDI = getItem(MDI_SEC, key, dflt)
End Function

Private Sub setHist(ByVal key As String, ByVal val As String)
setItem HIST_SEC, key, val
End Sub

Private Function getHist(ByVal key As String, ByVal dflt As String)
getHist = getItem(HIST_SEC, key, dflt)
End Function

Public Sub Init(ByVal maxNum As Long)
capacity = maxNum
End Sub

Public Sub saveForm(frm As Form)
With frm
 setMDI MDI_STATUS, .WindowState
 setMDI MDI_LEFT, .Left
 setMDI MDI_TOP, .Top
 setMDI MDI_WIDTH, .width
 setMDI MDI_HEIGH, .Height
End With
End Sub

Public Sub restoreForm(frm As Form, Optional isMDI As Boolean = False)
Dim l As Long, t As Long

'Debug.Print "Screen X: " & Screen.width & " Y: " & Screen.Height
With frm
 .WindowState = getMDI(MDI_STATUS, "" & .WindowState)
 If .WindowState = 0 Then
  
  l = getMDI(MDI_LEFT, "" & .Left)
  t = getMDI(MDI_TOP, "" & .Top)
  If isMDI Then
    If (l < 0) Or (l > Screen.width) Then
      l = 0
    End If
    If (t < 0) Or (t > Screen.Height) Then
      t = 0
    End If
  End If
  
  .Left = l
  .Top = t
  .width = getMDI(MDI_WIDTH, "" & .width)
  .Height = getMDI(MDI_HEIGH, "" & .Height)
  Else
  .Left = 0
  .Top = 0
  .width = getMDI(MDI_WIDTH, "" & .width)
  .Height = getMDI(MDI_HEIGH, "" & .Height)
 End If
End With
End Sub

Public Sub makeMenu(frm As Form)
Dim s As String, i As Integer

On Error Resume Next
For i = 0 To capacity - 1
 s = getHist("Item" & i, "")
 If s = "" Then Exit Sub
 Load frm.mnuHistory(i)
 frm.mnuHistory(i).enabled = True
 frm.mnuHistory(i).Caption = s
Next i
On Error GoTo 0
End Sub

Public Sub Add(FileName As String)
Dim s As String, i As Integer

clearCollection fileHistory
fileHistory.Add FileName
For i = 0 To capacity - 1
 s = getHist("Item" & i, "")
 If s = "" Then Exit For
 If Not (s = FileName) Then fileHistory.Add s
Next

For i = 1 To fileHistory.count
 setHist "Item" & i - 1, fileHistory.Item(i)
Next
End Sub
