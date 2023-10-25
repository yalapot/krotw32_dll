VERSION 5.00
Begin VB.UserControl ctrlCoroz 
   ClientHeight    =   2760
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   10590
   HasDC           =   0   'False
   ScaleHeight     =   184
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   706
   ToolboxBitmap   =   "Coroz.ctx":0000
   Begin krotw32.ctrlCrzCircle crzCircle 
      Height          =   2040
      Left            =   8040
      TabIndex        =   5
      Top             =   -240
      Visible         =   0   'False
      Width           =   1800
      _ExtentX        =   3175
      _ExtentY        =   3598
   End
   Begin VB.VScrollBar osNum 
      Height          =   1455
      Left            =   6600
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   240
      Width           =   135
   End
   Begin krotw32.ctrlGrfSpec oneSens 
      Height          =   735
      Left            =   0
      TabIndex        =   3
      Top             =   1680
      Width           =   6615
      _ExtentX        =   11668
      _ExtentY        =   1296
   End
   Begin VB.VScrollBar yScroll 
      Height          =   1455
      Left            =   0
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   240
      Width           =   255
   End
   Begin VB.PictureBox tubePic 
      BackColor       =   &H00000000&
      Height          =   1455
      Left            =   360
      ScaleHeight     =   93
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   413
      TabIndex        =   0
      Top             =   240
      Width           =   6255
   End
   Begin VB.Label labType 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Label1"
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   3240
      TabIndex        =   7
      Top             =   0
      Width           =   615
   End
   Begin VB.Label txtBaseLine 
      Alignment       =   1  'Right Justify
      Caption         =   "Выравнивание по отметке 999999.99 м."
      Height          =   255
      Left            =   3840
      TabIndex        =   6
      Top             =   0
      Width           =   2895
   End
   Begin VB.Label topSens 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Left            =   0
      TabIndex        =   2
      ToolTipText     =   "Номер верхнего датчика"
      Top             =   0
      Width           =   375
   End
   Begin VB.Menu menuCoroz 
      Caption         =   "Коррозионник"
      Begin VB.Menu mnuCoroz 
         Caption         =   "На белый маркер"
         Index           =   5
      End
      Begin VB.Menu mnuCoroz 
         Caption         =   "На черный маркер"
         Index           =   6
      End
      Begin VB.Menu mnuCoroz 
         Caption         =   "Изображение в буфер"
         Index           =   8
      End
      Begin VB.Menu mnuCoroz 
         Caption         =   "Дамп в файл (сырые)"
         Index           =   9
      End
      Begin VB.Menu mnuCoroz 
         Caption         =   "Дамп в файл (обработанные)"
         Index           =   10
      End
   End
End
Attribute VB_Name = "ctrlCoroz"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Implements clsMouseWeel

Private Const BL_BACK = 140

Private d_prevWndProc As Long
Private resizeFlag As Boolean
Private initFlag As Boolean
Private mainControlFlag As Boolean
Private leftShiftBorder As Single
Private zoomFlag As Boolean
Private currCursorDist As Long
Private aScrollOn  As Boolean
Private pixRight As Integer
Private pixRightMin As Integer
Private bmpCopy As Boolean
Private dragFlag As Boolean
Private dragStartX As Single
Private dragStartY As Single

Private xPixScl As Single
Private yPixScl As Single

Private cursY As New clsCursor
Private cursX As New clsCursor
Private Zoom As New clsZoom

Private trc As clsTrace
Private parentForm As frmTrace

Private WithEvents dragEntry As clsDragMark
Attribute dragEntry.VB_VarHelpID = -1
Private oldCursor As Integer
Private lastSensor As Integer

Private wVecDat() As Byte
Private wVecRow() As Long
Private bVecDat() As Byte
Private bVecRow() As Long

Private zoomX1 As Long
Private zoomX2 As Long
Private zoomY1 As Long
Private zoomY2 As Long

Public crz As clsCoroz
Public pickUpWeld As Boolean
Private isHooked As Boolean

Public Event redraw()
Public Event sizeChange()
Public Event mouseMove(ByVal y As Integer, ByVal x As Long)
Public Event goDist(ByVal dst As Long)
Public Event scaleX(ByVal sclx As Integer)
Public Event objIns(ByVal x As Long)
Public Event Zoom(crz As ctrlCoroz, ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Long, ByVal y2 As Long)
Public Event changeMark()
Public Event oneSensOff()
Public Event circleOff()
Public Event waitMessage(ByVal isWait As Boolean, ByVal msgText As String)
Public Event pixelRight(ByVal pix As Integer)
Public Event keyDown(ByVal KeyCode As Integer, ByVal Shift As Integer)
Public Event setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
Public Event setMarkGroup(ByVal posWhite As Long, ByVal posBlack As Long)
Public Event pickUpWeld(ByVal fullHour As Double)

Public Sub mouseMove(ByVal x As Single, ByVal y As Integer)
cursX.Draw x, 0
oneSens.mouseMove x
End Sub

Private Property Get clsMouseWeel_hwnd() As Long
clsMouseWeel_hwnd = UserControl.hwnd
End Property

Private Sub clsMouseWeel_MouseWeel(ByVal direction As Long)
If cfg.mouseWeelMode <> MW_VER Then Exit Sub

Dim i As Integer
i = Me.topSns + direction * trc.scrollSpeed
If i > yScroll.Max Then i = yScroll.Max
If i < yScroll.Min Then i = yScroll.Min
Me.topSns = i
End Sub

Private Property Let clsMouseWeel_prevWndProc(ByVal RHS As Long)
d_prevWndProc = RHS
End Property

Private Property Get clsMouseWeel_prevWndProc() As Long
clsMouseWeel_prevWndProc = d_prevWndProc
End Property

Private Sub crzCircle_keyDown(ByVal KeyCode As Integer, ByVal Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Private Sub crzCircle_mouseMove(ByVal y As Integer, ByVal x As Long)
cursY.Draw 0, y
corozMouseMove trc.pageStart, y
End Sub

Private Sub crzCircle_Off()
crz.circl.visible = False
UserControl_Resize
RaiseEvent pixelRight(pixRight)
RaiseEvent circleOff
End Sub

Private Sub crzCircle_shiftMark(ByVal onLeft As Boolean, ByVal wMark As Boolean, ByVal bMark As Boolean)
Dim x As Long, wx As Long, bx As Long

x = IIf(onLeft, -1, 1)
wx = trc.mark.white + IIf(wMark, trc.scrollSpeed * trc.Step * x, 0)
bx = trc.mark.black + IIf(bMark, trc.scrollSpeed * trc.Step * x, 0)
RaiseEvent setMarkGroup(wx, bx)
End Sub

Private Sub dragEntry_Complete(ByVal mrkWhite As Boolean, ByVal newPos As Single)
RaiseEvent setMark(mrkWhite, newPos)
End Sub

Private Sub oneSens_changeMark()
RaiseEvent changeMark
End Sub

Private Sub oneSens_keyDown(ByVal KeyCode As Integer, ByVal Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Private Sub oneSens_mouseMove(ByVal y As Integer, ByVal x As Long)
corozMouseMove x, 0
End Sub

Private Sub oneSens_Off()
RaiseEvent oneSensOff
oneSens_sizeChange
End Sub

Private Sub oneSens_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
RaiseEvent setMark(mrkWhite, newPos)
End Sub

Public Sub TrimHeight(ByVal pixels As Long)
Dim l As Long

l = tubePic.Height - pixels
If l < 1 Then l = 1
yScroll.Height = l
End Sub

Public Sub changePicHeight()
tubePic.Height = trc.ScaleNumber(-crz.scaleY, crz.num) + NON_CLIENT_AREA
tubePic.ScaleHeight = crz.num
yScroll.Height = tubePic.Height
UserControl_Resize

If initFlag Then Exit Sub
RaiseEvent pixelRight(pixRight)
End Sub

Private Sub oneSens_setMarkOsnap(ByVal mrkWhite As Boolean, ByVal newPos As Long)
RaiseEvent setMark(mrkWhite, crz.oneSens.calcLocalMax(newPos))
End Sub

Private Sub oneSens_sizeChange()
UserControl_Resize
RaiseEvent pixelRight(pixRight)
RaiseEvent sizeChange
End Sub

Private Sub osNum_Change()
crz.oneSens.Index = sensNumber(osNum.Value)
crzCircle.setCursorPos 0, crz.oneSens.Index
cursY.Draw 0, osNum.Value
If crz.oneSens.visible Then oneSens.Draw
End Sub

Private Sub tubePic_Click()
If zoomFlag Then zoomFlag = False
If Me.pickUpWeld Then RaiseEvent pickUpWeld(crz.sens2hour(lastSensor))
End Sub

Private Sub tubePic_DblClick()
RaiseEvent changeMark
End Sub

Private Sub tubePic_KeyDown(KeyCode As Integer, Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Private Sub tubePic_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim m As Boolean

If (Button And 1) = 1 Then
 If cfg.crz.zoomNoShift Then Shift = IIf(Shift = 0, 1, 0)
End If

Select Case Shift

 Case 1 'нажат shift - начало зуммирования
 If (Button And 1) = 1 Then
  Zoom.Start tubePic, x, y
 End If

 Case 0 'ничего не нажато
  If crz.isMarkDraw Then
   If Button = 1 Then
    Select Case crz.oneSens.findMarker(tubePic, x)
     Case 0 'нет маркера
      dragStart x, y
      Exit Sub
     Case 1 'белый
      dragEntry.drawColor = color.markWhite
      m = True
     Case 2 'черный
      dragEntry.drawColor = color.markBlack
      m = False
    End Select
    dragEntry.noDraw = True
    dragEntry.Start tubePic, x, m
   End If
   Else
   If Button = 1 Then
    dragStart x, y
    Exit Sub
   End If
  End If

End Select
End Sub

Private Sub tubePic_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
If bmpCopy Then Exit Sub

If cfg.crz.zoomNoShift Then Shift = 1
currCursorDist = x

'Dim lFileHandle As Long
'lFileHandle = FreeFile
'Open "E:\Temp\krot.txt" For Append As lFileHandle
'Print #lFileHandle, CStr(x)
'Close lFileHandle
'
If Zoom.inProgress Then
 If Shift = 1 Then
  Zoom.Continue x, y
  Else
  Zoom.Finish
 End If
 Else
 If Button = 1 Then
  dragDo x, y
 End If
End If
corozMouseMove x, y
End Sub

Private Function sensNumber(ByVal y As Single) As Integer
'вычислить реальный номер датчика с учетом вертикальной прокрутки
sensNumber = Fix(y + Me.topSns) Mod Fix(yScroll.Max + 1)
End Function

Private Function isImageMoving() As Boolean
isImageMoving = True
If Me.autoScrollOn Then Exit Function
If isHorArrowDown() Then Exit Function
isImageMoving = False
End Function

Private Sub corozMouseMove(ByVal x As Single, ByVal y As Single)
Dim s As Integer

If trc.isUserScale Then Exit Sub

s = sensNumber(y)
lastSensor = s
If (isImageMoving() = False) And (Me.pickUpWeld = False) Then cursX.Draw x, y
If Me.pickUpWeld Then cursY.Draw 0, y
RaiseEvent mouseMove(s, x)
End Sub

Private Sub tubePic_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim x1 As Single, x2 As Single, y1 As Single, y2 As Single

If Zoom.inProgress Then
 Zoom.Continue x, y
 Zoom.Finish
 Zoom.Coords x1, y1, x2, y2

 y1 = sensNumber(y1)
 y2 = sensNumber(y2)

 'защита от выбора, сведенного в точку
 If Not ((x1 = x2) Or (y1 = y2)) Then
  RaiseEvent Zoom(Me, x1, x2, y1, y2)
 End If
 zoomFlag = True
 Exit Sub
End If

If (Button And 1) = 1 Then
  Select Case Shift
   Case 0 'ничего не нажато
    If cfg.crz.objIns Then RaiseEvent objIns(x)
   Case 1 'shift
   Case 2 'ctrl
    If crz.isMarkDraw Then
     cursX.needErase = False
     RaiseEvent setMark(trc.mark.isCurrWhite, x)
    End If
   Case 3 'alt
  End Select
  If dragFlag Then
   dragStop
   Exit Sub
  End If
End If

If (Button And 2) = 2 Then
 UserControl.popUpMenu menuCoroz
End If

End Sub

Public Sub Draw(Optional forceReadData As Boolean = False)
picPaint "Draw", forceReadData
If crz.oneSens.visible Then
  cursY.Draw 0, osNum.Value
  oneSens.Draw forceReadData
End If
If crz.circl.visible Then crzCircle.Draw
If crz.baseLine < 0 Then
 txtBaseLine.Caption = ""
 Else
 txtBaseLine.Caption = "Выравнивание по отметке " & mm2txt(crz.baseLine) & " м."
End If
End Sub

Private Sub tubePic_Paint()
If resizeFlag Then Exit Sub
picPaint "tubePic_Paint"
RaiseEvent redraw
End Sub

Private Sub picPaint(errPoint As String, Optional forceReadData As Boolean = False)
If crz Is Nothing Then Exit Sub
cursX.needErase = False
cursY.needErase = False
crz.drawCoroz tubePic, forceReadData
drawBrd
End Sub

Private Sub UserControl_Initialize()
resizeFlag = False
initFlag = False
pixRight = 0
pixRightMin = pixRight
isHooked = False
'setHook tubePic.hwnd
End Sub

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Private Sub UserControl_Terminate()
If isHooked Then
 isHooked = False
 mouseWeelUnHook Me
End If
'UnHook
End Sub

Private Sub UserControl_Resize()
Dim ctrlHeight As Single
Dim i As Integer, pix As Integer

If trc Is Nothing Then Exit Sub
If resizeFlag Then Exit Sub
resizeFlag = True

RaiseEvent waitMessage(True, "Формирование изображения...")

pixRightMin = 0
labType.Caption = dataTypeName(crz.sensType)

If crz.circl.visible Then pixRightMin = pixRightMin + crzCircle.width  '+ 5

If crz.oneSens.visible Or crz.circl.visible Then pixRightMin = pixRightMin + osNum.width  '+ 5

pixRight = IIf(pixRight > pixRightMin, pixRight, pixRightMin)

tubePic.Left = leftShiftBorder / Screen.twipsPerPixelX
'размер окна развертки выравнивается на четное кол-во пикселов,
'чтобы обеспечить требование WINAPI о вырывнивании каждой
'скан-линии битмапа на WORD при вызове CreateBitmap
pix = (UserControl.ScaleWidth - tubePic.Left - pixRight) / 2
pix = pix * 2
tubePic.width = pix
ctrlHeight = (tubePic.Top + tubePic.Height) * Screen.twipsPerPixelY

txtBaseLine.Left = tubePic.width + tubePic.Left - txtBaseLine.width

If crz.oneSens.visible Then
 oneSens.pixelRight = pixRight
 oneSens.Top = tubePic.Top + tubePic.Height + 5
 oneSens.width = UserControl.ScaleWidth
 ctrlHeight = (oneSens.Top + oneSens.Height) * Screen.twipsPerPixelY
End If

If crz.circl.visible Then
 'crzCircle.Top = tubePic.Top
 crzCircle.Left = UserControl.ScaleWidth - crzCircle.width
 crzCircle.Resize
End If

If crz.oneSens.visible Or crz.circl.visible Then
 osNum.Left = UserControl.ScaleWidth - pixRight '+ 5
 osNum.Top = tubePic.Top
 osNum.Height = tubePic.Height
End If

crzCircle.visible = crz.circl.visible
oneSens.visible = crz.oneSens.visible
osNum.visible = crz.oneSens.visible

UserControl.Height = ctrlHeight

crz.picChange tubePic
RaiseEvent waitMessage(False, "")
resizeFlag = False
End Sub

Public Function Init( _
frm As frmTrace, _
corozObj As clsCoroz, _
ByVal mainControl As Boolean, _
ByVal leftShift As Single _
) As Boolean

Dim i As Integer

Init = False
initFlag = True
mouseWeelHook Me
isHooked = True

Set parentForm = frm
Set trc = frm.trc

Set crz = corozObj
Set dragEntry = New clsDragMark

cursY.Init tubePic, USR_HLINE
cursX.Init tubePic, USR_VLINE

ReDim wVecDat(crz.num) As Byte
ReDim wVecRow(crz.num) As Long
ReDim bVecDat(crz.num) As Byte
ReDim bVecRow(crz.num) As Long

mainControlFlag = mainControl
leftShiftBorder = leftShift
zoomFlag = False

yScroll.Min = 0
yScroll.Max = crz.num - 1
yScroll.SmallChange = 1
yScroll.LargeChange = yScroll.Max / 10
Me.topSns = crz.topSens
topSens.Caption = decorSensNum(Me.topSns)

tubePic.ScaleLeft = trc.pageStart

osNum.Min = 0
osNum.Max = yScroll.Max
'должно быть после установки верхнего датчика
osNum.Value = (crz.oneSens.Index - crz.topSens + crz.num) Mod crz.num
oneSens.Init parentForm, crz.oneSens, leftShiftBorder

crzCircle.Init crz.circl, Me
changePicHeight
Me.autoScrollOn = False

oldCursor = tubePic.MousePointer

initFlag = False
Init = True
End Function

Public Sub setCircleMarkers(ByVal white As Boolean, ByVal black As Boolean)
If crz.circl.visible Then crzCircle.setMarkersOnOff white, black
End Sub

Public Sub setOneSensIndex(ByVal indx As Integer)
If crz.oneSens.visible Then osNum.Value = indx
End Sub

Private Sub yScroll_Change()
crz.topSens = Me.topSns
topSens.Caption = decorSensNum(crz.topSens)

If initFlag Then Exit Sub

picPaint "yScroll_Change"
crzCircle.Draw
End Sub

Private Sub yScroll_Scroll()
yScroll_Change
End Sub

Property Get cursorDist() As Long
cursorDist = currCursorDist
End Property

Public Sub drawBorder(ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Long, ByVal y2 As Long, ByVal redrawBitmap As Boolean)
zoomX1 = x1
zoomX2 = x2
zoomY1 = y1
zoomY2 = y2
If redrawBitmap Then
 tubePic_Paint
 Else
 drawBrd
End If
End Sub

Private Sub drawBrd()
Dim x1 As Long, x2 As Long, y1 As Long, y2 As Long

If zoomX1 = 0 And zoomX2 = 0 And zoomY1 = 0 And zoomY2 = 0 Then Exit Sub
If trc Is Nothing Then Exit Sub
If trc.isUserScale Then Exit Sub

tubePic.ScaleLeft = trc.pageStart
tubePic.ScaleWidth = trc.pageLength

If (zoomX1 < tubePic.ScaleLeft) Or (zoomX1 > (tubePic.ScaleLeft + tubePic.ScaleWidth)) Then Exit Sub

x1 = zoomX1
x2 = zoomX2

y1 = zoomY1 - Me.topSns
If y1 < 0 Then y1 = y1 + yScroll.Max

y2 = zoomY2 - Me.topSns
If y2 < 0 Then y2 = y2 + yScroll.Max

If y1 > y2 Then
 tubePic.Line (x1, y1)-(x2, yScroll.Max), &HFFFFFF, B
 tubePic.Line (x1, y2)-(x2, yScroll.Min), &HFFFFFF, B
 Else
 tubePic.Line (x1, y1)-(x2, y2), &HFFFFFF, B
End If

End Sub

Property Get autoScrollOn() As Boolean
autoScrollOn = aScrollOn
End Property

Property Let autoScrollOn(v As Boolean)
aScrollOn = v
End Property

'функции обслуживания меню для корозионной развертки
Private Sub mnuCoroz_Click(Index As Integer)
Dim s As clsSensorLine

Select Case Index

 Case 5 'на белый маркер
  RaiseEvent goDist(trc.mark.white)
 Case 6 'на черный маркер
  RaiseEvent goDist(trc.mark.black)
 Case 8 'изображение в буфер
  bmpCopy = True
  picPaint "SetClipboard"
  If krotSetClipboard(Me.pic.hWnd) = KRT_ERR Then
   ogdWin.Alert "Ошибка при копировании в буфер обмена." & vbNewLine & lastError()
  End If
  bmpCopy = False
 Case 9 'дамп в файл (сырые)
  fileDump True
 Case 10 'дамп в файл (обработанные)
  fileDump False

End Select

End Sub

Private Sub fileDump(ByVal isRow As Boolean)
Dim fl As String

fl = ogdWin.fileSave( _
 "Выберите файл для записи дампа развертки." & IIf(isRow, " (сырые)", " (обработанные)"), _
 "", _
 cfg.dir.trc, _
 "Файлы дампа развертки (*.csv)|*.csv", _
 UserControl.hWnd)

If Len(fl) = 0 Then Exit Sub
If Right(fl, 4) <> ".csv" Then fl = fl & ".csv"

If krotCorozDump(trc.handle, crz.Index, fl, isRow) = KRT_ERR Then
 ogdWin.Alert "Ошибка при записи дампа:" & vbNewLine & lastError()
 Else
 ogdWin.Info "Данные успешно записаны в файл."
End If
End Sub

Property Get pixelRight() As Integer
pixelRight = pixRight
End Property

Property Let pixelRight(p As Integer)
pixRight = p
UserControl_Resize
End Property

Property Get pixelRightMin() As Integer
pixelRightMin = pixRightMin
End Property

Property Get pic() As PictureBox
Set pic = tubePic
End Property

Private Sub drawSlit(ByVal x As Long, ByVal h As Double, ByVal beforeFlag As Boolean)
Dim y As Integer, side As Integer

y = (h / 12# * yScroll.Max - Me.topSns + yScroll.Max) Mod yScroll.Max
side = IIf(beforeFlag, -1, 1)

tubePic.Line (x, y)-(x + side * 20 * xPixScl, y), &H8000000E
tubePic.Line (x, y)-(x + side * 5 * xPixScl, y - 5 * yPixScl), &H8000000E
tubePic.Line (x, y)-(x + side * 5 * xPixScl, y + 5 * yPixScl), &H8000000E
End Sub

Public Sub drawWeld( _
ByVal dst As Long, _
ByVal wldBefore1 As Double, _
ByVal wldBefore2 As Double, _
ByVal wldAfter1 As Double, _
ByVal wldAfter2 As Double)
Dim old As Integer

If trc.isUserScale Then Exit Sub

xPixScl = tubePic.ScaleWidth / tubePic.width
yPixScl = tubePic.ScaleHeight / tubePic.Height
old = tubePic.DrawWidth
tubePic.DrawWidth = cfg.crz.slitWidth

If crz.showObjWeld Then
 tubePic.Line (dst, tubePic.ScaleTop)-(dst, tubePic.ScaleTop + tubePic.ScaleHeight), &H8000000E
End If

If crz.showObjSlit Then
 If wldBefore1 >= 0 Then drawSlit dst, wldBefore1, True
 If wldBefore2 >= 0 Then drawSlit dst, wldBefore2, True
 If wldAfter1 >= 0 Then drawSlit dst, wldAfter1, False
 If wldAfter2 >= 0 Then drawSlit dst, wldAfter2, False
End If

tubePic.DrawWidth = old
End Sub

Property Get topSns() As Long
topSns = yScroll.Max - yScroll.Value
End Property

Property Let topSns(t As Long)
yScroll.Value = yScroll.Max - t
End Property

Private Sub dragStart(ByVal x As Single, ByVal y As Single)
If cfg.crz.corozDrag = False Then Exit Sub
dragFlag = True
dragStartX = x
dragStartY = y
tubePic.MouseIcon = LoadResPicture(HAND_CURSOR, vbResCursor)
tubePic.MousePointer = vbCustom
End Sub

Private Sub dragDo(ByVal x As Single, ByVal y As Single)
Static intFlag As Boolean
Static xShift As Long
Dim dltX As Long, dltY As Long

If cfg.crz.corozDrag = False Then Exit Sub
If intFlag Then Exit Sub
intFlag = True

dltX = Fix(dragStartX - x)
dltY = Fix(dragStartY - y)
dragStartX = x + dltX
dragStartY = y
dltY = (dltY + yScroll.Max) Mod yScroll.Max
Me.topSns = (Me.topSns + dltY) Mod yScroll.Max

xShift = xShift + dltX
If Abs(xShift) < trc.Step Then
 intFlag = False
 Exit Sub
End If

RaiseEvent goDist(trc.pageStart + trc.pageLength / 2 + xShift)
xShift = 0
intFlag = False
End Sub

Private Sub dragStop()
dragFlag = False
tubePic.MousePointer = 0
End Sub