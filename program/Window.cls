VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsWindow"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private dlg As New clsCommonDialog
Private d_lastFileError As String

Private Type BrowseInfo
    hwndOwner As Long
    pIDLRoot As Long
    pszDisplayName As Long
    lpszTitle As Long
    ulFlags As Long
    lpfnCallback As Long
    lParam As Long
    iImage As Long
End Type

Const BIF_RETURNONLYFSDIRS = 1
Const MAX_PATH = 260

Private Declare Sub CoTaskMemFree Lib "ole32.dll" _
                        (ByVal hMem As Long)

Private Declare Function lstrcat Lib "kernel32" _
                        Alias "lstrcatA" _
                        (ByVal lpString1 As String, _
                        ByVal lpString2 As String) As Long

Private Declare Function SHBrowseForFolder Lib "shell32" _
                        (lpbi As BrowseInfo) As Long

Private Declare Function SHGetPathFromIDList Lib "shell32" _
                        (ByVal pidList As Long, _
                        ByVal lpBuffer As String) As Long

Public Enum T_FILE_SEL
OPEN_FILE
SAVE_FILE
SEL_FOLDER
End Enum

Public Function fileOpen( _
ByVal capt As String, _
ByVal dflt As String, _
ByVal InitDir As String, _
ByVal fltrString As String, _
ByVal hWndParent As Long, _
Optional txtBox As TextBox = Null, _
Optional multiSelect As Boolean = False _
) As String
Dim s As String

fileOpen = ""

If Len(fltrString) > 0 Then fltrString = fltrString & "|"
dlg.hWnd = hWndParent
dlg.FileName = dflt
dlg.InitDir = InitDir
dlg.DialogTitle = capt
dlg.Filter = fltrString & "Все файлы (*.*)|*.*"
dlg.Flags = _
cdlOFNFileMustExist Or _
cdlOFNHideReadOnly Or _
cdlOFNLongNames Or _
cdlOFNPathMustExist

If multiSelect Then
 dlg.Flags = dlg.Flags Or cdlOFNAllowMultiselect
End If

dlg.CancelError = True

On Error GoTo errHandl
dlg.ShowOpen
On Error GoTo 0

s = dlg.fileName

If s = "" Then Exit Function
If Not (txtBox Is Nothing) Then txtBox.Text = s
fileOpen = s
Exit Function

errHandl:
On Error GoTo 0
fileOpen = ""

End Function

Public Function fileFolder( _
ByVal hwnd As Long, _
capt As String, _
Optional txtBox As TextBox = Null _
)

Dim iNull As Integer, lpIDList As Long, lResult As Long
Dim sPath As String, udtBI As BrowseInfo

fileFolder = ""

With udtBI
 .hwndOwner = hwnd
 .lpszTitle = lstrcat(capt, "")
 .ulFlags = BIF_RETURNONLYFSDIRS
End With

'Выводим на экран стандартный диалог 'Выбор папки'
lpIDList = SHBrowseForFolder(udtBI)
If lpIDList Then
 sPath = String$(MAX_PATH, 0)
 'Получаем путь из IDList
 SHGetPathFromIDList lpIDList, sPath
 'Освобождаем блок памяти
 CoTaskMemFree lpIDList
 iNull = InStr(sPath, vbNullChar)
 If iNull Then
  sPath = Left$(sPath, iNull - 1)
 End If
End If

If sPath = "" Then Exit Function
If Not (txtBox Is Nothing) Then txtBox.Text = sPath
fileFolder = sPath
End Function

Public Sub Alert(msg As String)
MsgBox msg, vbExclamation + vbApplicationModal, "Крот"
End Sub

Public Sub Info(msg As String)
MsgBox msg, vbInformation + vbApplicationModal, "Крот"
End Sub

Public Function AskYNC(txt As String) As Integer
AskYNC = MsgBox(txt, vbYesNoCancel + vbQuestion, "Крот")
End Function

Public Function AskAction(txt As String, Optional esc As Boolean = False) As Boolean
Dim i As Integer, flag As Integer

flag = vbOKCancel + vbQuestion
If esc Then flag = flag + vbDefaultButton2

i = MsgBox(txt, flag, "Крот")
If i = vbOK Then
 AskAction = True
 Else
 AskAction = False
End If
End Function

Public Function selColor( _
dflt As Long, _
Optional pic As PictureBox = Null _
) As Long

dlg.DialogTitle = "Выберите цвет"
dlg.Flags = cdlCCRGBInit Or cdlCCFullOpen
dlg.color = dflt
dlg.CancelError = True

On Error GoTo errHandl
dlg.ShowColor
On Error GoTo 0

If Not (pic Is Nothing) Then pic.BackColor = dlg.color
selColor = dlg.color
Exit Function

errHandl:
On Error GoTo 0
selColor = -1
End Function

Public Function fileSave( _
ByVal capt As String, _
ByVal dflt As String, _
ByVal InitDir As String, _
ByVal fltrString As String, _
ByVal hWndParent As Long, _
Optional txtBox As TextBox = Null _
) As String
Dim s As String

fileSave = ""

If Len(fltrString) > 0 Then fltrString = fltrString & "|"
dlg.fileName = dflt
dlg.hWnd = hWndParent
dlg.InitDir = InitDir
dlg.DialogTitle = capt
dlg.Filter = fltrString & "Все файлы (*.*)|*.*"
dlg.Flags = _
cdlOFNHideReadOnly Or _
cdlOFNLongNames Or _
cdlOFNPathMustExist

dlg.CancelError = True

On Error GoTo errHandl
dlg.ShowSave
On Error GoTo 0

s = dlg.fileName

If s = "" Then Exit Function
If Not (txtBox Is Nothing) Then txtBox.Text = s
fileSave = s
Exit Function

errHandl:
On Error GoTo 0
fileSave = ""
End Function

Public Function fExist(FileName As String) As Boolean
fExist = False
If FileName = "" Then Exit Function
On Error GoTo fileErr
If Dir$(FileName, 16) = "" Then Exit Function
fExist = True
Exit Function
fileErr:
d_lastFileError = Err.Description
Exit Function
End Function

Property Get lastFileError() As String
lastFileError = d_lastFileError
End Property