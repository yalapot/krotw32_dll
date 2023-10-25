VERSION 5.00
Object = "{00028CDA-0000-0000-0000-000000000046}#6.0#0"; "TDBG6.OCX"
Begin VB.Form frmPalette 
   Caption         =   "Редактор палитр"
   ClientHeight    =   2730
   ClientLeft      =   1815
   ClientTop       =   1815
   ClientWidth     =   6240
   Icon            =   "Palette.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   2730
   ScaleWidth      =   6240
   Begin VB.CheckBox chkApply 
      Caption         =   "Перерисовывать развертку"
      Height          =   255
      Left            =   3120
      TabIndex        =   4
      Top             =   480
      Width           =   3015
   End
   Begin VB.PictureBox picPal 
      Appearance      =   0  'Flat
      BackColor       =   &H80000008&
      BorderStyle     =   0  'None
      DrawWidth       =   2
      ForeColor       =   &H80000008&
      Height          =   240
      Left            =   120
      ScaleHeight     =   16
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   400
      TabIndex        =   2
      Top             =   0
      Width           =   6000
   End
   Begin VB.PictureBox picPointPos 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      DrawWidth       =   2
      ForeColor       =   &H80000008&
      Height          =   240
      Left            =   120
      ScaleHeight     =   16
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   400
      TabIndex        =   0
      Top             =   240
      Width           =   6000
   End
   Begin TrueDBGrid60.TDBGrid grid 
      Height          =   1815
      Left            =   120
      OleObjectBlob   =   "Palette.frx":0442
      TabIndex        =   1
      Top             =   720
      Width           =   6015
   End
   Begin VB.Label labDiap 
      Caption         =   "Диапазон: 2222222-0"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   480
      Width           =   3015
   End
   Begin VB.Menu menuFile 
      Caption         =   "Файл"
      Begin VB.Menu mnuFile 
         Caption         =   "Открыть"
         Index           =   0
         Shortcut        =   ^O
      End
      Begin VB.Menu mnuFile 
         Caption         =   "Сохранить"
         Index           =   1
         Shortcut        =   ^S
      End
      Begin VB.Menu mnuFile 
         Caption         =   "Выход"
         Index           =   2
         Shortcut        =   ^Q
      End
   End
   Begin VB.Menu menuPal 
      Caption         =   "Палитра"
      Begin VB.Menu mnuPal 
         Caption         =   "Размер палитры..."
         Index           =   0
      End
   End
   Begin VB.Menu menuItem 
      Caption         =   "Элемент"
      Begin VB.Menu mnuItem 
         Caption         =   "Добавить"
         Index           =   0
         Shortcut        =   {F7}
      End
      Begin VB.Menu mnuItem 
         Caption         =   "Изменить"
         Index           =   1
         Shortcut        =   {F4}
      End
      Begin VB.Menu mnuItem 
         Caption         =   "Удалить"
         Index           =   2
         Shortcut        =   {F8}
      End
   End
End
Attribute VB_Name = "frmPalette"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'размер прицела для захвата линии для D&D в пикселах
Private Const DRAG_APERTURE = 2

Private xarr As New XArrayDB
Private actionFlag As Boolean
Private currPos As Long
Private WithEvents dragEntry As clsDragMark
Attribute dragEntry.VB_VarHelpID = -1
Private picWidthInPixels  As Long
Private Pal As clsPalette
Private srcPal As clsPalette
Private hlp As New clsHelp

Private popupMenuItem As Integer
Private popupMenuFlag As Boolean

Public Event Change()

Private Sub palChange()
actionFlag = True
reBindGrid
drawPal
If chkApply.visible Then
 Pal.getUserPal xarr
 srcPal.setUserPal xarr
 If chkApply.Value = 1 Then RaiseEvent Change
End If
End Sub

Private Sub initForm()
Set dragEntry = New clsDragMark
Pal.getUserPal xarr
grid.Array = xarr
grid.ReBind
setTitle
reBindGrid
drawPal
End Sub

Public Function EditCurrent(prntFrm As Form, Coroz As clsCoroz) As Boolean
actionFlag = False
Set srcPal = Coroz.palette
Set Pal = cfg.pallette

Pal.datMin = srcPal.datMin
Pal.datMax = srcPal.datMax
Pal.usrMin = Pal.datMin
Pal.usrMax = Pal.datMax

srcPal.getUserPal xarr
Pal.setUserPal xarr

initForm
centerForm prntFrm, Me
Me.Show 1, prntFrm
EditCurrent = actionFlag
End Function

Public Function Edit(prntFrm As Form, pFile As String) As Boolean
actionFlag = False

Set Pal = cfg.pallette

Set dragEntry = New clsDragMark
If Len(pFile) > 0 Then
 If Pal.loadFromFile(pFile) = False Then ogdWin.Alert Pal.errText
End If

initForm
chkApply.visible = False
centerForm prntFrm, Me
Me.Show 1, frmMain
Edit = actionFlag
End Function

Private Sub setTitle()
Me.caption = "Редактор палитр " & IIf(Pal.file = "", "Новая палитра", Pal.file)
End Sub

Private Sub reBindGrid()
labDiap.caption = "Диапазон: " & Pal.minVal & " : " & Pal.maxVal
Pal.setUserPal xarr
grid.Array = xarr
grid.ReBind
End Sub

Private Sub chkApply_Click()
palChange
End Sub

Private Sub dragEntry_Complete(ByVal mrkWhite As Boolean, ByVal newPos As Single)
Dim pos As Long

pos = newPos
xarr.Value(currPos, 0) = pos
xarr.QuickSort 0, xarr.count(1) - 1, 0, XORDER_ASCEND, XTYPE_LONG
grid.Bookmark = xarr.Find(0, 0, pos)
palChange
End Sub

Private Sub Form_Load()
hlp.BindHelp Me, KRT_PalEdit
End Sub

Private Sub Form_Resize()
If Me.WindowState <> 1 Then
 On Error Resume Next
 grid.width = Me.ScaleWidth - grid.Left - 100
 picPointPos.width = grid.width
 picPal.width = picPointPos.width
 picPointPos.ScaleMode = 3
 picWidthInPixels = picPointPos.ScaleWidth
 grid.Height = Me.ScaleHeight - grid.Top
 If Me.visible Then drawPal
 On Error GoTo 0
End If
End Sub

Private Sub grid_FetchCellStyle(ByVal Condition As Integer, ByVal Split As Integer, Bookmark As Variant, ByVal Col As Integer, ByVal CellStyle As TrueDBGrid60.StyleDisp)
Select Case Col
 Case 1
  CellStyle.BackColor = grid.Columns(1).CellValue(Bookmark)
End Select
End Sub

Private Sub grid_FormatText(ByVal ColIndex As Integer, Value As Variant, Bookmark As Variant)
Select Case ColIndex
 Case 1
  Value = ""
 Case 2 'red
  Value = rgbColor(grid.Columns(1).CellValue(Bookmark), RGB_RED)
 Case 3 'green
  Value = rgbColor(grid.Columns(1).CellValue(Bookmark), RGB_GREEN)
 Case 4 'blue
  Value = rgbColor(grid.Columns(1).CellValue(Bookmark), RGB_BLUE)
End Select
End Sub

Private Sub grid_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
currPos = grid.Columns(0).CellValue(grid.Bookmark)
Select Case currPos
 Case Pal.datMin, Pal.datMax
  mnuItem(2).enabled = False
 Case Else
  mnuItem(2).enabled = True
End Select
End Sub

Private Sub mnuFile_Click(Index As Integer)
Select Case Index
 Case 0 'открыть
  loadPal
 Case 1 'сохранить
  savePal
 Case 2 'выход
  Unload Me
End Select
End Sub

Private Sub loadPal()
Dim f As String

f = ogdWin.fileOpen( _
 "Загрузка палитры", _
 Pal.file, _
 cfg.dir.Pal, _
 "Krot palette (*.kpl)|*.kpl|Pview palette (*.npl)|*.npl", _
 Me.hWnd)
If f = "" Then Exit Sub

If Pal.loadFromFile(f) Then
 Pal.getUserPal xarr
 setTitle
 palChange
 Else
 ogdWin.Alert Pal.errText
End If
End Sub

Private Sub savePal()
Dim f As String

f = ogdWin.fileSave("Сохранение палитры", Pal.file, cfg.dir.Pal, "Файлы палитр (*.kpl)|*.kpl", Me.hWnd)
If f = "" Then Exit Sub

If Not (LCase(Right(f, 4)) = ".kpl") Then f = f & ".kpl"
Pal.saveToFile f
setTitle
End Sub

Private Sub grid_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = 2 Then
  popupMenuFlag = True
  Me.popUpMenu menuItem
  popupMenuFlag = False
  If popupMenuItem >= 0 Then
   mnuItem_Click popupMenuItem
   popupMenuItem = -1
  End If
End If
End Sub

Private Sub mnuItem_Click(Index As Integer)
If popupMenuFlag Then
 popupMenuItem = Index
 Exit Sub
End If

Select Case Index
 Case 0 'добавить
  addEntry grid.Bookmark
 Case 1 'изменить
  editEntry grid.Bookmark
 Case 2 'удалить
  delEntry grid.Bookmark
End Select
End Sub

Private Sub delEntry(rowBookmark As Variant)
xarr.DeleteRows rowBookmark
palChange
grid.Bookmark = rowBookmark
End Sub

Private Sub addEntry(rowBookmark As Variant)
Dim pos As Long, entColor As Long, prevRow As Variant
Dim r As Integer, g As Integer, b As Integer
Dim c1 As Long, c2 As Long

'если это первая строка (верхняя граница палитры), то использовать
'для расчета значений по умолчанию следующую строку
If grid.Columns(0).CellValue(rowBookmark) = Pal.datMin Then
 rowBookmark = grid.GetBookmark(1)
 grid.Bookmark = rowBookmark
End If

'указатель на предыдущую строку
prevRow = grid.GetBookmark(-1)

'положение новой точки в палитре
pos = grid.Columns(0).CellValue(prevRow)
pos = pos + (grid.Columns(0).CellValue(rowBookmark) - pos) / 2

'цвета, между которыми нужно вставить новый цвет
c2 = grid.Columns(1).CellValue(rowBookmark)
c1 = grid.Columns(1).CellValue(prevRow)
'расчет нового цвета
r = Abs(rgbColor(c2, RGB_RED) - rgbColor(c1, RGB_RED)) / 2
g = Abs(rgbColor(c2, RGB_GREEN) - rgbColor(c1, RGB_GREEN)) / 2
b = Abs(rgbColor(c2, RGB_BLUE) - rgbColor(c1, RGB_BLUE)) / 2
entColor = RGB(r, g, b)

If frmPalItem.Edit(Me, pos, entColor, Pal.datMin, Pal.datMax) = False Then Exit Sub

xarr.InsertRows rowBookmark
xarr.Value(rowBookmark, 0) = pos
xarr.Value(rowBookmark, 1) = entColor

xarr.QuickSort 0, xarr.count(1) - 1, 0, XORDER_ASCEND, XTYPE_LONG
grid.Bookmark = xarr.Find(0, 0, pos)

palChange
End Sub

Private Sub editEntry(rowBookmark As Variant)
Dim pos As Long, entColor As Long

pos = grid.Columns(0).CellValue(rowBookmark)
entColor = grid.Columns(1).CellValue(rowBookmark)
If frmPalItem.Edit(Me, pos, entColor, Pal.datMin, Pal.datMax) Then
 xarr.Value(rowBookmark, 0) = pos
 xarr.Value(rowBookmark, 1) = entColor
 xarr.QuickSort 0, xarr.count(1) - 1, 0, XORDER_ASCEND, XTYPE_LONG
 grid.Bookmark = xarr.Find(0, 0, pos)
 palChange
End If

End Sub

Private Sub drawPal()
Dim pos As Long, entColor As Long
Dim i As Integer

With picPointPos

.ScaleLeft = Pal.minVal
' когда форму сильно сжимают по горизонтали происходит ошибка в следующей строке и
' переполнение в методе .Line
' поэтому пропускаем отрисовку меток.
On Error GoTo skipLines
.ScaleWidth = Pal.maxVal - Pal.minVal
.Cls

For i = 0 To xarr.count(1) - 1
 pos = xarr.Value(i, 0)
 entColor = xarr.Value(i, 1)
 picPointPos.Line (pos, .ScaleTop)-(pos, .ScaleTop + .ScaleHeight), entColor
Next

End With

skipLines:

If Pal.Draw(picPal.hWnd) = False Then
 ogdWin.Alert "Ошибка при отрисовке палитры" & vbNewLine & Pal.errText
End If
End Sub

Private Sub mnuPal_Click(Index As Integer)
Dim x1 As Long, s As String

Select Case Index
 Case 0 'диапазон палитры
  s = InputBox("Задайте диапазон значений палитры" & vbNewLine & "(0 - " & PAL_SIZE & ") :", "Размер палитры", Pal.maxVal)
  If s = "" Then Exit Sub
  x1 = Val(s)
  If x1 > PAL_SIZE Then x1 = PAL_SIZE
  If x1 < 1 Then x1 = 1
  redimPal x1
End Select
End Sub

Private Sub redimPal(ByVal x2 As Long)
Dim i As Integer, xx1 As Long, xx2 As Long, x As Long, x1 As Long, tmp As Double

With xarr

xx1 = .Value(0, 0)
x1 = 0

xx2 = .Value(.count(1) - 1, 0)
.Value(.count(1) - 1, 0) = x2

For i = 1 To .count(1) - 2
 x = .Value(i, 0)
 tmp = (x - xx1)
 tmp = (x2 - x1) * tmp
 x = tmp / (xx2 - xx1) + x1
 .Value(i, 0) = x
Next

End With

Pal.setUserPal xarr
palChange
End Sub

Private Sub picPal_Paint()
drawPal
End Sub

Private Sub picPointPos_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim entryPos As Long, entryClr As Long

If Button = 1 Then
 currPos = getNearEntry(X, entryPos, entryClr)
 If currPos > 0 Then
  dragEntry.drawColor = entryClr
  dragEntry.drawInvert = False
  dragEntry.Start picPointPos, entryPos, True
 End If
End If
End Sub

Private Function getNearEntry(X As Single, ByRef epos As Long, ByRef eclr As Long) As Long
Dim unitInPix As Single, minVal As Long, maxVal As Long
Dim i As Integer, pos As Long

getNearEntry = -1
 
unitInPix = picPointPos.ScaleWidth / picWidthInPixels
minVal = X - unitInPix * DRAG_APERTURE
maxVal = X + unitInPix * DRAG_APERTURE

For i = 1 To xarr.count(1) - 2
 pos = xarr.Value(i, 0)
 If pos >= minVal And pos <= maxVal Then
  epos = pos
  eclr = xarr.Value(i, 1)
  getNearEntry = i
  Exit Function
 End If
Next

End Function

Private Sub picPointPos_Paint()
drawPal
End Sub