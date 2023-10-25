VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsPalette"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const SEC_PALLETE = "Palette"

Private Const PAL_FILE = "PalFile"
Private Const PAL_MIN = "PalMin"
Private Const PAL_MAX = "PalMax"

Private Const PAL_VERSION_1 = "1"
Private Const PAL_ITM_DELIM = ":"
Private Const SEC_ITEMS = "Items"

Private Const PAL_VERSION = "Version"
Private Const PAL_ENTRY = "EntryNum"
Private Const PALBRD_MIN = "BorderMin"
Private Const PALBRD_MAX = "BorderMax"

Private Const ITM_ENTRY = "Item"
Private Const ITM_MIN = "ItemMin"
Private Const ITM_MAX = "ItemMax"

Private Enum errConst
 NO_ERROR
 BAD_EXT
 BAD_FORMAT
 BAD_MIN
 BAD_MAX
 BAD_ITM
 PAL_DRAW
 PAL_SET
 USR_MAX
 USR_MIN
 BAD_NPL
End Enum

Private trc As clsTrace
Private crz As clsCoroz
Private iniKey As String
Private d_file As String

Private errCode As errConst
Private extError As String
Private vbPal As VB_PAL
Private palEnt() As Long

Public usrMin As Long
Public usrMax As Long
Public datMin As Long
Public datMax As Long

Property Get errText() As String
Select Case errCode

 Case NO_ERROR
  errText = "Все хорошо"
 Case BAD_FORMAT
  errText = "Неверный формат файла палитры"
 Case BAD_MIN
  errText = "Неверное значение нижней границы палитры"
 Case BAD_MAX
  errText = "Неверное значение верхней границы палитры"
 Case BAD_ITM
  errText = "Неверное значение элемента палитры " & extError
 Case PAL_DRAW
  errText = "Ошибка при отрисовке палитры" & vbNewLine & extError
 Case PAL_SET
  errText = "Ошибка при установке палитры" & vbNewLine & extError
 Case USR_MAX
  errText = "Ошибка при установке пользовательской верхней границы цвета"
 Case USR_MIN
  errText = "Ошибка при установке пользовательской нижней границы цвета"
 Case BAD_NPL
  errText = "Неверное значение параметра NumSteps секции [COLORSCALE] палитры Pview"
 Case BAD_EXT
  errText = "Неизвестное расширение файла палитры: " & extError

 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property

Public Sub Init(trace As clsTrace, Coroz As clsCoroz, ByVal iniKeyName As String)
Set trc = trace
Set crz = Coroz
iniKey = iniKeyName

Me.datMin = crz.valMin
Me.datMax = crz.valMax
usrMin = Me.datMin
usrMax = Me.datMax

Me.loadFromFile trc.getUser(iniKey & PAL_FILE, trc.drv.pallete)
usrMin = trc.getUser(iniKey & PAL_MIN, usrMin)
usrMax = trc.getUser(iniKey & PAL_MAX, usrMax)
If usrMin < Me.datMin Then usrMin = Me.datMin
If usrMax > Me.datMax Then usrMax = Me.datMax
End Sub

Public Sub Save()
trc.setUser iniKey & PAL_FILE, Me.file
trc.setUser iniKey & PAL_MIN, usrMin
trc.setUser iniKey & PAL_MAX, usrMax
End Sub

Property Get minVal() As Long
minVal = vbPal.minItem.iPos
End Property

Property Get maxVal() As Long
maxVal = vbPal.maxItem.iPos
End Property

Property Get file() As String
file = d_file
End Property

Public Function saveToFile(fName As String) As Boolean
Dim i As Integer

saveToFile = False
d_file = fName

With vbPal
setPal PAL_VERSION, PAL_VERSION_1
setPal PAL_ENTRY, "" & .ItemNum
setItm ITM_MIN, .minItem.iPos & PAL_ITM_DELIM & .minItem.iVal
setItm ITM_MAX, .maxItem.iPos & PAL_ITM_DELIM & .maxItem.iVal
For i = 0 To .ItemNum - 1
 setItm ITM_ENTRY & (i + 1), palEnt(i * 2) & PAL_ITM_DELIM & palEnt(i * 2 + 1)
Next
End With
saveToFile = True
End Function

Public Function loadFromFile(ByVal FileName As String) As Boolean
Dim s As String

loadFromFile = False
d_file = FileName
cFile.fullName = Me.file
s = UCase(cFile.ext)

If ogdWin.fExist(cFile.fullName) Then

  Select Case s
   Case "KPL"
  loadFromFile = LoadPaletteKpl()
   Case "NPL"
  loadFromFile = LoadPaletteNpl()
   Case Else
    errCode = BAD_EXT
    extError = s
  End Select

Else

  s = Me.file
  cFile.fullName = trc.FileName
  d_file = cFile.basePath & "palette.kpl"
  LoadFromFile = LoadPaletteKpl()
  d_file = s
  
End If

If LoadFromFile Then LoadFromFile = Me.setData()
End Function

Private Function LoadPaletteNpl() As Boolean
Dim i As Integer, indx As Integer
Dim sec As String

LoadPaletteNpl = False
sec = "COLORSCALE"

vbPal.ItemNum = getIniItem(Me.file, sec, "NumSteps", "0") - 2
If vbPal.ItemNum < 0 Then
 errCode = BAD_NPL
 Exit Function
End If

ReDim palEnt(vbPal.ItemNum * 2) As Long

vbPal.minItem.iPos = 0
vbPal.minItem.iVal = CLng(getIniItem(Me.file, sec, "Clr" & vbPal.minItem.iPos, "0")) 'черный
vbPal.maxItem.iPos = vbPal.ItemNum + 1
vbPal.maxItem.iVal = CLng(getIniItem(Me.file, sec, "Clr" & vbPal.maxItem.iPos, "255")) ' красный

On Error Resume Next
For i = 0 To vbPal.ItemNum - 1
 palEnt(i * 2) = i + 1
 palEnt(i * 2 + 1) = CLng(getIniItem(Me.file, sec, "Clr" & i, "0"))
Next i
LoadPaletteNpl = True
End Function

Private Function LoadPaletteKpl_0() As Boolean
Dim i As Integer

LoadPaletteKpl_0 = False
vbPal.ItemNum = 200 - 2
ReDim palEnt(vbPal.ItemNum * 2) As Long

vbPal.minItem.iPos = 0
vbPal.minItem.iVal = CLng(getIniItem(Me.file, SEC_PALLETE, "0", "0")) 'черный
vbPal.maxItem.iPos = vbPal.ItemNum + 1
vbPal.maxItem.iVal = CLng(getIniItem(Me.file, SEC_PALLETE, "199", "255")) ' красный

For i = 0 To vbPal.ItemNum - 1
 palEnt(i * 2) = i + 1
 palEnt(i * 2 + 1) = CLng(getIniItem(Me.file, SEC_PALLETE, CStr(i + 1), "0"))
Next i
LoadPaletteKpl_0 = True
End Function

Private Function LoadPaletteKpl_1() As Boolean
Dim i As Integer, s As String

LoadPaletteKpl_1 = False

usrMin = getPal(PALBRD_MIN, usrMin)
usrMax = getPal(PALBRD_MAX, usrMax)

s = getPal(PAL_ENTRY, "")
vbPal.ItemNum = Val(s)
ReDim palEnt(vbPal.ItemNum * 2) As Long

cfg.parser.Delim = PAL_ITM_DELIM

s = getItm(ITM_MIN, "")
If s = "" Then
 errCode = BAD_MIN
 Exit Function
End If
cfg.parser.TestString = PAL_ITM_DELIM & s
cfg.parser.Parse
vbPal.minItem.iPos = Val(cfg.parser.Item(1))
vbPal.minItem.iVal = Val(cfg.parser.Item(2))

s = getItm(ITM_MAX, "")
If s = "" Then
 errCode = BAD_MAX
 Exit Function
End If
cfg.parser.TestString = PAL_ITM_DELIM & s
cfg.parser.Parse
vbPal.maxItem.iPos = Val(cfg.parser.Item(1))
vbPal.maxItem.iVal = Val(cfg.parser.Item(2))

For i = 0 To vbPal.ItemNum - 1
 s = getItm(ITM_ENTRY & (i + 1), "")
 If s = "" Then
  errCode = BAD_ITM
  extError = ITM_ENTRY & i
  Exit Function
 End If
 cfg.parser.TestString = PAL_ITM_DELIM & s
 cfg.parser.Parse
 palEnt(i * 2) = Val(cfg.parser.Item(1))
 palEnt(i * 2 + 1) = Val(cfg.parser.Item(2))
Next
LoadPaletteKpl_1 = True
End Function

Private Function LoadPaletteKpl() As Boolean
If getPal(PAL_VERSION, "") = PAL_VERSION_1 Then
 LoadPaletteKpl = LoadPaletteKpl_1()
 Else
 LoadPaletteKpl = LoadPaletteKpl_0()
End If
End Function

Public Function setData() As Boolean
Dim hTrc As Long, hCrz As Long

setData = False

If trc Is Nothing Then
 hTrc = -1
 hCrz = 0
 Else
 hTrc = trc.handle
 hCrz = crz.Index
End If

If krtPalSet(hTrc, hCrz, datMin, datMax, usrMin, usrMax, vbPal, palEnt(0)) = KRT_ERR Then
 errCode = PAL_SET
 extError = lastError()
 Exit Function
End If
setData = True
End Function

Public Function Draw(ByVal hWnd As Long) As Boolean
Dim hTrc As Long, hCrz As Long

Draw = False

If trc Is Nothing Then
 hTrc = -1
 hCrz = 0
 Else
 hTrc = trc.handle
 hCrz = crz.Index
End If

If krtPalDraw(hTrc, hCrz, hWnd) = KRT_ERR Then
 errCode = PAL_DRAW
 extError = lastError()
 Exit Function
End If
Draw = True
End Function

Private Function getPal(ByVal itmKey As String, ByVal dflt As String) As String
Dim s As String
s = getIniItem(Me.file, SEC_PALLETE, itmKey)
getPal = IIf(s = "", dflt, s)
End Function

Private Function getItm(itmKey As String, dflt As String) As String
Dim s As String
s = getIniItem(Me.file, SEC_ITEMS, itmKey)
getItm = IIf(s = "", dflt, s)
End Function

Private Sub setPal(itmKey As String, itmval As String)
setIniItem Me.file, SEC_PALLETE, itmKey, itmval
End Sub

Private Sub setItm(itmKey As String, itmval As String)
setIniItem Me.file, SEC_ITEMS, itmKey, itmval
End Sub

Public Sub getUserPal(xarr As XArrayDB)
Dim i As Integer

With xarr
.Clear
.ReDim 0, 1 + vbPal.ItemNum, 0, 1
.Value(0, 0) = vbPal.minItem.iPos
.Value(0, 1) = vbPal.minItem.iVal
.Value(1 + vbPal.ItemNum, 0) = vbPal.maxItem.iPos
.Value(1 + vbPal.ItemNum, 1) = vbPal.maxItem.iVal
For i = 0 To vbPal.ItemNum - 1
 .Value(i + 1, 0) = palEnt(i * 2)
 .Value(i + 1, 1) = palEnt(i * 2 + 1)
Next
End With
End Sub

Public Function setUserPal(xarr As XArrayDB) As Boolean
Dim i As Integer

setUserPal = False
With xarr

vbPal.ItemNum = .count(1) - 2
ReDim palEnt(vbPal.ItemNum * 2) As Long

vbPal.minItem.iPos = .Value(0, 0)
vbPal.minItem.iVal = .Value(0, 1)

vbPal.maxItem.iPos = .Value(vbPal.ItemNum + 1, 0)
vbPal.maxItem.iVal = .Value(vbPal.ItemNum + 1, 1)

For i = 0 To vbPal.ItemNum - 1
 palEnt(i * 2) = .Value(i + 1, 0)
 palEnt(i * 2 + 1) = .Value(i + 1, 1)
Next
End With

setUserPal = Me.setData()
End Function

Private Sub Class_Initialize()
Dim i As Integer

vbPal.ItemNum = 0
ReDim palEnt(vbPal.ItemNum * 2) As Long

vbPal.minItem.iPos = 0
vbPal.minItem.iVal = 0 'черный
vbPal.maxItem.iPos = PAL_SIZE
vbPal.maxItem.iVal = 255 ' красный

datMin = vbPal.minItem.iPos
datMax = vbPal.maxItem.iPos
usrMin = datMin
usrMax = datMax

End Sub
