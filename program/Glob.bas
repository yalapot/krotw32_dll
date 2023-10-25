Attribute VB_Name = "krtGlob"
Option Explicit

Global Const DFLT_ODO_DIAM = 10186

'коды ошибок, генерируемых программой
Global Const ERR_FREEPICT = vbObjectError + 1
Global Const ERR_NODIAMCURVE = vbObjectError + 2
Global Const ERR_EMPTDIAMCURVE = vbObjectError + 3

'поддерживаемые языки документов экспресс-анализа
Global Const EXP_LNG_RUS = "RUS"
Global Const EXP_LNG_ENG = "ENG"

'цветовые константы
Global Const CLR_RED = &HFF&
Global Const CLR_GREEN_L = &HFF00& '&H00FF0000&
Global Const CLR_GREEN_D = &H8000&
Global Const CLR_BLUE_L = &HFF0000

Global Const NON_CLIENT_AREA = 4
Global Const HorientCursor = PI / 256#  ' половина ширины курсора ориентации
Global Const USER_SCALE_X = 666
Global Const CMNT_LENGTH = 250 ' длина поля комментария в базе

'секция trc-файла [Trace]
Global Const SEC_TRACE = "Trace"
Global Const TR_ITM_NAME = "Name"
Global Const TR_ITM_PALETTE = "Pallete"

Global Const OBJ_TBL_NONE = ""
Global Const OBJ_TBL_DFKT = "defect"
Global Const OBJ_TBL_LINE = "lin_obj"
Global Const OBJ_TBL_THICK = "thick"
Global Const OBJ_TBL_TURN = "turn"
Global Const OBJ_TBL_WELD = "weld"

Global Const VK_SHIFT = &H10
Global Const VK_CONTROL = &H11
Global Const VK_PGDN = 34
Global Const VK_PGUP = 33
Global Const VK_UP = 38
Global Const VK_DN = 40
Global Const VK_LEFT = 37
Global Const VK_RIGHT = 39
Global Const VK_SPACE = 32
Global Const VK_S = 83
Global Const VK_P = 80
Global Const VK_B = 66
Global Const VK_A = 65
Global Const VK_D = 68
Global Const VK_V = 86
Global Const VK_M = 77
Global Const VK_NUM2 = 50
Global Const VK_F4 = 115

'коэффициент к параметру окна подсчета скорости снаряда speedVector
Global Const SV_AMPL = 10
Global Const SV_MIN = 1
Global Const SV_MAX = 1000

'структура описания вспомогательного датчика
Public Type EXT_SENS_INFO
 minValue As Long  ' минимальное значение показаний датчика (единицы АЦП)
 maxValue As Long  ' максимальное значение показаний датчика (единицы АЦП)
 askMetod As Long  ' метод опроса датчика (SENS_ASK_*)
 stepSize As Long  ' дискретность опроса датчика (мм/милисек - от метода опроса)
 name As String    ' описание датчика
End Type

Declare Function GetAsyncKeyState Lib "USER32" (ByVal vKey As Long) As Integer
Declare Sub sleep Lib "kernel32" Alias "Sleep" (ByVal dwMilliseconds As Long)

'декларации WINAPI для работы с ini
Private Declare Function GetPrivateProfileString _
Lib "kernel32" Alias "GetPrivateProfileStringA" ( _
ByVal lpApplicationName As String, _
ByVal lpKeyName As Any, _
ByVal lpDefault As String, _
ByVal lpReturnedString As String, _
ByVal nSize As Long, _
ByVal lpFileName As String _
) As Long

Private Declare Function WritePrivateProfileString _
Lib "kernel32" Alias "WritePrivateProfileStringA" ( _
ByVal lpApplicationName As String, _
ByVal lpKeyName As Any, _
ByVal lpString As Any, _
ByVal lpFileName As String _
) As Long

Private Declare Function GetShortPathName Lib "kernel32" Alias "GetShortPathNameA" ( _
 ByVal lpszLongPath As String, _
 ByVal lpszShortPath As String, _
 ByVal cchBuffer As Long _
) As Long

Private Declare Function GetTempPath Lib "kernel32" Alias "GetTempPathA" (ByVal nBufferLength As Long, ByVal lpBuffer As String) As Long
Private Declare Function GetTempFileName Lib "kernel32" Alias "GetTempFileNameA" (ByVal lpszPath As String, ByVal lpPrefixString As String, ByVal wUnique As Long, ByVal lpTempFileName As String) As Long

Global cFile As New clsFile
Global cfg As New clsConfig
Global dbg As New clsDebugLog
Global ogdWin As New clsWindow
Global color As New clsSensColors
Global lastSQLerror As String
Global noTransActionFlag As Boolean
Global Rpt As New clsDfctRpt

Private Declare Function GetComputerName Lib "kernel32.dll" Alias "GetComputerNameA" (ByVal lpBuffer As String, nSize As Long) As Boolean
Private Declare Function GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long

Private Function CurrentComputerName() As String
Dim lpBuffer As String * 255
Dim lRet As Long, lBuf As Long

lBuf = 255
lRet = GetComputerName(lpBuffer, lBuf)
CurrentComputerName = Left$(lpBuffer, lBuf)
End Function

Public Function GetShortName(ByVal sLongFileName As String) As String
Dim lRetVal As Long, sShortPathName As String, iLen As Integer

'Set up buffer area for API function call return
sShortPathName = Space(255)
iLen = Len(sShortPathName)

'Call the function
lRetVal = GetShortPathName(sLongFileName, sShortPathName, iLen)
'Strip away unwanted characters.
GetShortName = Left(sShortPathName, lRetVal)
End Function
   
Public Function CurrentUserName() As String
Dim lpBuffer As String * 255
Dim lRet As Long, lBuf As Long

lBuf = 255
lRet = GetUserName(lpBuffer, lBuf)
CurrentUserName = Left$(lpBuffer, lBuf - 1)
End Function

Public Sub openTrace(inf As String)
Dim trace As frmTrace, trc As clsTrace

setWait "Загрузка '" & inf & "' ...", vbHourglass, True

Set trc = New clsTrace
If trc.traceOpen(inf) = False Then
 setReady
 ogdWin.Alert trc.errText
 Exit Sub
End If

Set trace = New frmTrace
trace.View trc
cfg.fileHist.Add inf
setReady
End Sub

Public Function getIniItem(ByVal Ini As String, ByVal sec As String, ByVal Item As String, Optional ByVal dflt As String = "", Optional ByVal isShared As Boolean = False) As String
Dim buf As String, s As String, ret As Long

buf = String(10000, Asc(" "))
ret = GetPrivateProfileString(sec, Item, "", buf, Len(buf) - 1, Ini)
s = Left$(buf, InStr(buf, Chr(0)) - 1)
If s = "" Then
 getIniItem = dflt
 Else
 getIniItem = s
End If

If sec = "UserSettings" Then
 If Not isShared Then
   ret = GetPrivateProfileString("User_" & CurrentUserName(), Item, "", buf, Len(buf) - 1, Ini)
   s = Left$(buf, InStr(buf, Chr(0)) - 1)
   If Len(s) > 0 Then
     getIniItem = s
   End If
 End If
End If
End Function

Public Sub setIniItem(ByVal Ini As String, ByVal sec As String, ByVal Item As String, ByVal itmval As String, Optional ByVal isShared As Boolean = False)
If sec = "UserSettings" Then
 If Not isShared Then
   sec = "User_" & CurrentUserName()
 End If
End If
WritePrivateProfileString sec, Item, itmval, Ini
End Sub

Public Sub ogdPause(i As Integer)
Dim j As Integer
For j = 0 To i
 DoEvents
Next
End Sub

Public Sub registerTrace()
Dim s As String

s = frmRegister.View
If Len(s) > 0 Then openTrace s
updateHistory
End Sub

Public Function lastError() As String
Dim buf As String, ret As Long

buf = String(1024, Asc(" "))
ret = krotError(buf)
lastError = Left$(buf, InStr(buf, Chr(0)) - 1)
End Function

Public Sub setWait(msg As String, Optional ByVal mp = vbHourglass, Optional ByVal noForm As Boolean)
Dim frm As Form

Set frm = IIf(noForm, Nothing, Screen.ActiveForm)
If Not (frm Is Nothing) Then
 frm.MousePointer = mp
 On Error Resume Next
 frm.Refresh
 On Error GoTo 0
End If
frmMain.MousePointer = mp
frmMain.sbar.Panels(1).Text = msg
ogdPause 20
End Sub

Public Sub setReady(Optional msg As String = "Готов")
Dim frm As Form

Set frm = Screen.ActiveForm
If Not (frm Is Nothing) Then
 frm.MousePointer = vbDefault
End If
frmMain.MousePointer = vbDefault
frmMain.sbar.Panels(1).Text = msg
End Sub

Public Sub AppendFileContent(ByVal fl As Integer, ByVal fName As String, ByVal rowPrefix As String, ByVal rowSuffix As String)
Dim inp As Integer, s As String, itms As Variant, itm As Variant, prf As String, prf1 As String

inp = FreeFile
Open fName For Input Access Read As #inp
prf1 = ""

Do While Not EOF(inp)
 Line Input #inp, s
 'Debug.Print s
 itms = Split(s, ",")
 prf = ""
 s = ""
 For Each itm In itms
   s = s & prf & CInt(itm)
   prf = ", "
 Next
 Print #fl, prf1 & rowPrefix & s & rowSuffix
 prf1 = ","
Loop

Close #inp

End Sub

Public Sub Log(logName As String, msg As String)
Dim fl As Integer, logmsg As String

If logName = "" Then Exit Sub
logmsg = "+ " & Now & " " & msg
fl = FreeFile

On Error GoTo errOpen
Open logName For Append As fl
On Error GoTo errOut
Print #fl, logmsg
On Error GoTo errClose
Close fl

ExitSub:
On Error GoTo 0
Exit Sub

errOpen:
ogdWin.Alert "Не могу открыть файл протокола " & logName & " для записи" & vbNewLine & _
"Возможно диск защищен от записи. Описание ошибки системой:" & vbNewLine & _
Err.Description
GoTo ExitSub

errOut:
ogdWin.Alert "Не могу записать в файл протокола " & logName & vbNewLine & _
"Описание ошибки системой:" & vbNewLine & _
Err.Description
GoTo ExitSub

errClose:
ogdWin.Alert "Не могу закрыть файл протокола " & logName & vbNewLine & _
"Описание ошибки системой:" & vbNewLine & _
Err.Description
GoTo ExitSub

End Sub

Public Sub centerForm(prnt As Form, frm As Form)
frm.Left = prnt.Left + prnt.width / 2 - frm.width / 2
frm.Top = prnt.Top + prnt.Height / 2 - frm.Height / 2
If frm.Top < prnt.Top Then frm.Top = prnt.Top
End Sub

Public Function SQLexe(db As Database, cmd() As String) As Boolean
Dim i As Integer, msg As String

lastSQLerror = ""
SQLexe = False
On Error GoTo errHand
If Not noTransActionFlag Then BeginTrans
For i = LBound(cmd) To UBound(cmd)
 If Not (cmd(i) = "") Then
  Log cfg.obj.sqlLog, cmd(i)
  db.Execute cmd(i), dbFailOnError
  Log cfg.obj.sqlLog, "RecordsAffected: " & db.RecordsAffected & vbNewLine
 End If
Next
On Error GoTo errHand1
If Not noTransActionFlag Then CommitTrans
SQLexe = True
Exit Function

errHand:
lastSQLerror = "SQL: " & cmd(i) & vbNewLine
errHand1:
lastSQLerror = Err.Description & lastSQLerror
Log cfg.obj.sqlLog, lastSQLerror
Rollback
End Function

Public Function presentInString(ByVal searchString As String, ByVal searchItem As String, ByVal comma As String) As Boolean
Dim parser As New clsCommandLine, i As Integer

presentInString = False
parser.TestString = comma & searchString
parser.Delim = comma
parser.Parse
For i = 1 To parser.count
 If searchItem = parser.Item(i) Then
  presentInString = True
  Exit Function
 End If
Next

End Function

Public Function isShiftDown() As Boolean
isShiftDown = IIf((GetAsyncKeyState(VK_SHIFT) And &H8000) = 0, False, True)
End Function

Public Function isControlDown() As Boolean
isControlDown = IIf((GetAsyncKeyState(VK_CONTROL) And &H8000) = 0, False, True)
End Function

Public Function isHorArrowDown() As Boolean
isHorArrowDown = _
IIf((GetAsyncKeyState(VK_LEFT) And &H8000) = 0, False, True) Or _
IIf((GetAsyncKeyState(VK_RIGHT) And &H8000) = 0, False, True)
End Function

Public Function IsKeyPressed(KeyCode As Long) As Boolean
 IsKeyPressed = IIf((GetAsyncKeyState(KeyCode) And &H8000) = &H8000, True, False)
End Function

Public Sub updateHistory()
Dim f As Form

cfg.fileHist.makeMenu frmMain
For Each f In Forms
 If f.name = "frmTrace" Then cfg.fileHist.makeMenu f
Next
End Sub

Public Function registerCallBack(ByVal percentDone As Integer, ByVal ansiMsg As String) As Long
registerCallBack = frmRegister.informUser(percentDone, StrConv(ansiMsg, vbUnicode))
End Function

Public Function daiCallBack(ByVal percentDone As Integer) As Long
setWait "Анализ данных..." & percentDone & "%", vbArrowHourglass
ogdPause 50
If frmZoomDAI.daiBreak Then
 daiCallBack = 1
 Else
 daiCallBack = 0
End If
End Function

Public Function makeNewMdb(newMdb As String, templateMdb As String) As String
Dim e As String

makeNewMdb = ""
If Not ogdWin.fExist(templateMdb) Then
 ogdWin.Alert "Не найден файл прототипа базы обьектов: " & templateMdb
 Exit Function
End If
'newMdb = Left(trcFile, Len(trcFile) - 3) & "mdb"

On Error GoTo errHandle
FileCopy templateMdb, newMdb
On Error GoTo 0

makeNewMdb = newMdb
Exit Function

errHandle:
e = Err.Description
Err.Clear
On Error GoTo 0
ogdWin.Alert "Ошибка при создании базы обьектов:" & vbNewLine & e

End Function

Public Sub setSel(txt As TextBox)
On Error Resume Next
txt.SelStart = 0
txt.SelLength = Len(txt.Text)
txt.SetFocus
On Error GoTo 0
End Sub

Public Function decorSensNum(ByVal sensNum As Integer) As Integer
Dim dlt As Integer

If cfg.crz.channel Then
 decorSensNum = sensNum
 Exit Function
End If

dlt = IIf((sensNum And 1) > 0, 1, 0)
decorSensNum = sensNum * 2 - dlt
End Function

Public Sub setLst(lst As ComboBox, dflt As Variant)
Dim i As Long

For i = 0 To lst.ListCount - 1
 If lst.ItemData(i) = dflt Then
  lst.ListIndex = i
  Exit Sub
 End If
Next
End Sub

Public Function dbInt32(rs As Recordset, fld As String) As Long
dbInt32 = IIf(IsNull(rs(fld)), 0, rs(fld))
End Function

Public Function dbDbl(rs As Recordset, fld As String) As Double
dbDbl = IIf(IsNull(rs(fld)), 0, rs(fld))
End Function

Public Function GetTempFile() As String
  Dim sTempFile As String, sTempPath As String
  Dim rc As Long
  
  sTempPath = Space$(260)
  sTempFile = Space$(260)
  
  'Call the API to get the temp path
  rc = GetTempPath(Len(sTempPath), sTempPath)
  sTempPath = Trim$(Left$(sTempPath, InStr(sTempPath, Chr$(0)) - 1))
  
  'Call the API to Get the File Name
  rc = GetTempFileName(sTempPath, App.EXEName, 0&, sTempFile)
  
  'If API failed
  If rc = 0 Then
    MsgBox "Unable to create temporary file to save information!.", vbOKOnly + vbCritical, "Save Sound"
    GetTempFile = ""
  Else
    'Trim$ any remaining spaces after the null character and return value
    GetTempFile = Trim$(Left$(sTempFile, InStr(sTempFile, Chr$(0)) - 1))
  End If
  'Kill GetTempFile
End Function

Public Function GetOLEObject(obj As String) As Object
Dim o As Object

On Error GoTo Create_Object
    Set o = GetObject(, obj)
    GoTo Create_Doc
Create_Object:
          Set o = CreateObject(obj)
    Resume Create_Doc
Create_Doc:
    On Error GoTo 0
Set GetOLEObject = o
End Function

Public Function isSensAvail(trc As clsTrace, sens As KRT_SENS) As Boolean
Dim dat As T_NODEDATA

If krotGetFirstNode(trc.handle, dat, 0, sens, 0, 0, 0) = KRT_ERR Then
 isSensAvail = False
 Exit Function
End If
isSensAvail = True
End Function

Public Sub addToHistory(trc As clsTrace, txtCmnt As ComboBox, Optional ByVal clearComment As Boolean = True)
If Len(Trim(txtCmnt.Text)) > 0 Then
 trc.commentHistory.addItem txtCmnt.Text
 trc.commentHistory.setCombo txtCmnt, clearComment
End If
End Sub


Public Function sprintf(frmt As String, ParamArray args() As Variant) As String
Dim i As Integer, s As String

s = ""
For i = 0 To UBound(args)
    s = s & args(i)
Next i
sprintf = s
End Function

Public Function read2string(ByVal file_name As String) As String
Dim fl As Integer, s As String, s1 As String

s1 = ""
fl = FreeFile
Open file_name For Input As #fl

Do
 Line Input #fl, s
 s1 = s1 & s
Loop While Not EOF(fl)

Close #fl

s = Replace(s1, vbNewLine, "")
s1 = s
s = Replace(s1, vbTab, "")
s1 = Replace(s, vbCrLf, "")
s = Replace(s1, vbLf, "")
s1 = Replace(s, vbCr, "")

read2string = s1
End Function

Public Function dataTypeName(ByVal sensType As KRT_SENS_TYPE) As String
dataTypeName = "???"

Select Case sensType
  Case KRT_SENS_TYPE.SENS_TYPE_HOLL
    dataTypeName = "HOLL"
  Case KRT_SENS_TYPE.SENS_TYPE_FERR
    dataTypeName = "FERR"
  Case KRT_SENS_TYPE.SENS_TYPE_INDK
    dataTypeName = "INDK"
  Case KRT_SENS_TYPE.SENS_RESIDUAL
    dataTypeName = "RES"
  Case KRT_SENS_TYPE.SENS_PROFIL
    dataTypeName = "PRF"
  Case KRT_SENS_TYPE.SENS_TFI
    dataTypeName = "TFI"
  Case KRT_SENS_TYPE.SENS_INTROSCOPE
    dataTypeName = "INTR"
  Case KRT_SENS_TYPE.SENS_MFL
    dataTypeName = "MFL"
End Select
End Function
