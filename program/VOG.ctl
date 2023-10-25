VERSION 5.00
Begin VB.UserControl ctrlVOG 
   ClientHeight    =   2355
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   5685
   ScaleHeight     =   2355
   ScaleWidth      =   5685
   ToolboxBitmap   =   "VOG.ctx":0000
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   3360
      Top             =   1200
   End
   Begin krotw32.rotateAngle rotAngle 
      Height          =   495
      Left            =   1680
      TabIndex        =   8
      Top             =   0
      Width           =   975
      _ExtentX        =   1720
      _ExtentY        =   873
   End
   Begin VB.PictureBox vogXY 
      AutoRedraw      =   -1  'True
      Height          =   495
      Left            =   0
      ScaleHeight     =   435
      ScaleWidth      =   1635
      TabIndex        =   7
      Top             =   720
      Width           =   1695
   End
   Begin VB.PictureBox vogZ 
      AutoRedraw      =   -1  'True
      Height          =   495
      Left            =   1800
      ScaleHeight     =   435
      ScaleWidth      =   1275
      TabIndex        =   6
      Top             =   720
      Width           =   1335
   End
   Begin krotw32.multyNum zMulty 
      Height          =   255
      Left            =   3840
      TabIndex        =   1
      Top             =   480
      Width           =   1335
      _ExtentX        =   2434
      _ExtentY        =   450
   End
   Begin krotw32.multyNum yMulty 
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   480
      Width           =   1335
      _ExtentX        =   2434
      _ExtentY        =   450
   End
   Begin VB.CheckBox chkWelds 
      Caption         =   "Швы"
      Height          =   255
      Left            =   2160
      TabIndex        =   16
      Top             =   480
      Width           =   855
   End
   Begin VB.Label savStart 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "600000.00"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2640
      TabIndex        =   13
      ToolTipText     =   "Начало сохраненного диапазона"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label savEnd 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "600000.00"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2640
      TabIndex        =   12
      ToolTipText     =   "Конец сохраненного диапазона"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label p1p2distVogY 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      Height          =   255
      Left            =   840
      TabIndex        =   15
      ToolTipText     =   "Расстояние между маркерами по показаниям датчиков VOG в плоскости Y"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label p1p2distVogXY 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      Height          =   255
      Left            =   3840
      TabIndex        =   14
      ToolTipText     =   "Расстояние между маркерами по показаниям датчиков VOG в плоскости XY"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label coordZ 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "600000.00"
      Height          =   255
      Left            =   4680
      TabIndex        =   11
      ToolTipText     =   "Текущие координаты курсора по показаниям датчиков VOG в плоскости XY"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label coordY 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "600000.00"
      Height          =   255
      Left            =   840
      TabIndex        =   10
      ToolTipText     =   "Текущие координаты курсора по показаниям датчиков VOG в плоскости XY"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label LabNodeCount 
      Caption         =   "Label1"
      Height          =   255
      Left            =   1440
      TabIndex        =   9
      ToolTipText     =   "Кол-во отрисованных узлов"
      Top             =   480
      Width           =   615
   End
   Begin VB.Label coordX 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "600000.00"
      Height          =   255
      Left            =   0
      TabIndex        =   5
      ToolTipText     =   "Текущие координаты курсора по показаниям датчиков VOG в плоскости XY"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label coordL 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "600000.00"
      Height          =   255
      Left            =   3840
      TabIndex        =   4
      ToolTipText     =   "Текущие координаты курсора по показаниям датчиков VOG в плоскости Z"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label p1p2distVogX 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      Height          =   255
      Left            =   0
      TabIndex        =   3
      ToolTipText     =   "Расстояние между маркерами по показаниям датчиков VOG в плоскости X"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label p1p2distVogZ 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      Height          =   255
      Left            =   4680
      TabIndex        =   2
      ToolTipText     =   "Расстояние между маркерами по показаниям датчиков VOG в плоскости Z"
      Top             =   240
      Width           =   855
   End
End
Attribute VB_Name = "ctrlVOG"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const NODERADIUS = 100

Private Type T_VOG_POINT
 X As Single
 Y As Single
 xy As Single
 Z As Single
 odo As Long
End Type

Public Enum VOG_AREA
AREA_XY
AREA_Z
End Enum

Private trc As clsTrace
Private minControlWidth As Single
Private mainControlFlag As Boolean
Private d_vis As Boolean

Private resizeFlag As Boolean
Private d_x1min As Long
Private d_x1max As Long
Private d_y1min As Long
Private d_y1max As Long
Private d_x2min As Long
Private d_x2max As Long
Private d_y2min As Long
Private d_y2max As Long
Private d_tppXY_X As Single
Private d_tppXY_Y As Single
Private d_tppZ_X As Single
Private d_tppZ_Y As Single
Private lastPoint As Long
Private currPoint As Long
Private matchPoint1 As Long
Private matchPoint2 As Long
Private loggedMode As Boolean
Private logFile As String
Private nodeCount As String
Private initFlag As Boolean

Private node As T_NODEDATAGROUP
Private point1 As T_VOG_POINT
Private point2 As T_VOG_POINT

Private d_slave As New clsVogMatch
Private Zoom As New clsZoom
Private cursX As New clsCursor
Private cursY As New clsCursor
Private vogTimer As New clsTimer

Public Event popUpMenu(ByVal hitArea As VOG_AREA)
Public Event visualPartChange(ByVal visStart As Long, ByVal visLength As Long)
Public Event mouseMove(ByVal X As Long)
Public Event setMark(ByVal X As Long)
Public Event Redraw()
Public Event changeMark()

Public Function Init( _
trace As clsTrace, _
ByVal mainControl As Boolean, _
ByVal leftShift As Single _
) As Boolean

Init = False
initFlag = True

Set trc = trace
mainControlFlag = mainControl

d_slave.Init trc.handle
logFile = cfg.vog.logFile
If logFile = "" Then
 loggedMode = False
 Else
 loggedMode = True
End If

If setInterval(0, trc.length, False) = False Then
  trc.vog.disable
  Exit Function
End If
If mainControlFlag Then RaiseEvent visualPartChange(trc.pageStart, trc.pageLength)

trc.vog.saveStart = trc.pageStart
trc.vog.saveEnd = trc.pageStart + trc.pageLength

zMulty.Min = cfg.vog.sldZ.Min
zMulty.Max = cfg.vog.sldZ.Max
zMulty.LargeChange = cfg.vog.sldZ.page
zMulty.SmallChange = cfg.vog.sldZ.Shift
zMulty.Value = trc.vog.zMult

yMulty.Min = cfg.vog.sldY.Min
yMulty.Max = cfg.vog.sldY.Max
yMulty.LargeChange = cfg.vog.sldY.page
yMulty.SmallChange = cfg.vog.sldY.Shift
yMulty.Value = trc.vog.yMult

rotAngle.angle = trc.vog.angle

cursX.Init vogXY, USR_BIGCROSS
cursY.Init vogZ, USR_BIGCROSS

chkWelds.Value = IIf(trc.vog.showWelds, 1, 0)

initFlag = False
Init = True
End Function

Private Sub chkWelds_Click()
If initFlag Then Exit Sub
trc.vog.showWelds = IIf(chkWelds.Value = 1, True, False)
Me.Draw
RaiseEvent redraw
End Sub

Private Sub rotAngle_Change(ByVal ang As Double)
trc.vog.angle = rotAngle.angle
initFlag = True
setInterval trc.pageStart, trc.pageStart + trc.pageLength, True
initFlag = False
DrawVOG
RaiseEvent Redraw
End Sub

Private Sub UserControl_Initialize()
minControlWidth = coordZ.Left + coordZ.width
resizeFlag = False
End Sub

Private Sub UserControl_Resize()
If resizeFlag Then Exit Sub
resizeFlag = True

If UserControl.width < minControlWidth Then
 UserControl.width = minControlWidth
End If
vogXY.width = UserControl.width / 2 - 20
vogZ.width = UserControl.width / 2 - 20
vogZ.Top = vogXY.Top
vogZ.Left = vogXY.Left + vogXY.width + 20

vogXY.Height = vogXY.width
vogZ.Height = vogZ.width
UserControl.Height = vogXY.Top + vogXY.Height + 100

coordX.Left = vogXY.Left
coordY.Left = coordX.Left + coordX.width
p1p2distVogX.Left = coordX.Left
yMulty.Left = coordX.Left

rotAngle.Left = coordY.Left + coordY.width + 50

coordZ.Left = UserControl.width - coordZ.width - 50
p1p2distVogXY.Left = coordZ.Left
coordL.Left = coordZ.Left - coordL.width
p1p2distVogZ.Left = coordL.Left
zMulty.Left = coordL.Left

coordX.Caption = "0"
coordY.Caption = "0"
coordZ.Caption = "0"
coordL.Caption = "0"

'DrawVOG
resizeFlag = False
End Sub

Private Sub vogMouseDown(xy As Boolean, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
Dim pos As Long

Select Case Shift
 Case 1 'нажат shift - начало зуммирования
 Zoom.Start IIf(xy, vogXY, vogZ), X, Y
 Case 2 'нажат ctrl - установка маркера
 pos = findPoint(X, Y, xy)
 If pos > 0 Then RaiseEvent setMark(pos)
End Select

End Sub

Private Sub vogXY_DblClick()
RaiseEvent changeMark
End Sub

Private Sub vogXY_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = 2 Then
 RaiseEvent popUpMenu(AREA_XY)
 Else
 vogMouseDown True, Shift, X, Y
End If
End Sub

Private Sub vogXY_Paint()
DrawVOG
End Sub

Private Sub vogZ_DblClick()
RaiseEvent changeMark
End Sub

Private Sub vogZ_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
If Button = 2 Then
 RaiseEvent popUpMenu(AREA_Z)
 Else
 vogMouseDown False, Shift, X, Y
End If
End Sub

Private Function findPoint( _
ByVal X As Single, _
ByVal Y As Single, _
ByVal XYflag As Boolean _
) As Long

Dim odoStart As Long, odoEnd As Long
Dim deltaX As Single, deltaY As Single
Dim pnt As T_VOG_POINT

findPoint = -1
If XYflag Then
 deltaX = d_tppXY_X
 deltaY = d_tppXY_Y
 Else
 deltaX = d_tppZ_X
 deltaY = d_tppZ_Y
End If
deltaX = VOG_APERTURE / 2 * deltaX
deltaY = VOG_APERTURE / 2 * deltaY

'попытаться найти точки пересечения графика с прямоугольником прицела
If findBorder( _
   odoStart, _
   odoEnd, _
   X - deltaX, _
   Y - deltaY, _
   X + deltaX, _
   Y + deltaY, _
   XYflag _
   ) Then
   'если пересечение найдено,

   'стереть старые метки !!!!!!!!!!!!!!!!
   'drawMark True, X, Y, True
   'drawMark False, l, Z * d_zMulty, True

   'найти ближайшую к центру прицела точку
   'на участке графика внутри прицела
   findPoint = nearestPoint(X, Y, odoStart, odoEnd, XYflag, pnt)
End If

End Function

Private Function nearestPoint( _
ByVal pntX As Single, _
ByVal pntY As Single, _
ByVal odoStart As Long, _
ByVal odoEnd As Long, _
ByVal XYflag As Boolean, _
pnt As T_VOG_POINT _
) As Long

Dim X As Long, Y As Long, Z As Long, dst As Long, minDist As Single
'Dim pnt As T_VOG_POINT

dst = odoStart

If vogInitMatching(rotAngle.angle, trc.handle, dst, odoEnd - odoStart, -1, 0, 0, vogXY.width / Screen.twipsPerPixelX, 0) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при поиске ближайшей точки графика." & _
  vbNewLine & trc.vog.vogLastErr()
  Exit Function
End If
lastPoint = odoEnd
getNextVogPoint dst, X, Y, Z

pnt.odo = dst
pnt.X = X
pnt.Y = IIf(XYflag, Y * yMulty.Value, Z * zMulty.Value)
minDist = dist(pntX, pntY, X, Y)

While getNextVogPoint(dst, X, Y, Z)
 Y = IIf(XYflag, Y * yMulty.Value, Z * zMulty.Value)
 If dist(pntX, pntY, X, Y) < minDist Then
  pnt.odo = dst
  pnt.X = X
  pnt.Y = Y
  pnt.Z = Z
 End If
Wend
nearestPoint = pnt.odo
End Function

Private Function findBorder( _
ByRef odoStart As Long, _
ByRef odoEnd As Long, _
ByVal Xmin As Long, _
ByVal Ymin As Long, _
ByVal Xmax As Long, _
ByVal Ymax As Long, _
ByVal XYflag As Boolean _
) As Boolean

Dim X As Long, Y As Long, Z As Long, dst As Long, l As Double, xy As Double, l1 As Long
Dim x1 As Long, y1 As Long, z1 As Long, startZpoint As Long
Dim firstFlag As Boolean, cross As Boolean
Dim xLast As Long, yLast As Long, zLast As Long, lLast As Long
Dim firstX As Long, firstY As Long, firstZ As Long, firstXY As Long

findBorder = False
dst = trc.pageStart
l1 = trc.pageLength

' поиск начальной точки отсчета в Z-окне
If cfg.vog.calcXZ = False Then
 startZpoint = 0
 Else
 ' calcPath вызывает цикл запроса вога, поэтому должен быть
 ' ДО вызова vogInitMatching !!!
 startZpoint = calcPath(0, trc.pageStart)
End If

If vogInitMatching(rotAngle.angle, trc.handle, dst, l1, -1, 0, 0, vogXY.width / Screen.twipsPerPixelX, 0) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при поиске выбранного участка." & _
  vbNewLine & trc.vog.vogLastErr()
  Exit Function
End If
lastPoint = trc.pageStart + trc.pageLength
getNextVogPoint dst, X, Y, Z

l = startZpoint

firstX = X
firstY = Y
firstZ = Z
firstXY = l

firstFlag = False

While getNextVogPoint(dst, x1, y1, z1)
 xy = Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)

 If XYflag Then
  cross = isCross(X, Y * yMulty.Value, x1, y1 * yMulty.Value, Xmin, Ymin, Xmax, Ymax)
  Else
  cross = isCross(l, Z * zMulty.Value, l + xy, z1 * zMulty.Value, Xmin, Ymin, Xmax, Ymax)
 End If
 If cross Then
  If firstFlag = False Then
   findBorder = True
   odoStart = dst
   odoEnd = odoStart
   firstFlag = True
   Else
   odoEnd = dst
   xLast = X
   yLast = Y
   zLast = Z
   lLast = l
  End If
 End If
 X = x1
 Y = y1
 Z = z1
 l = l + xy
Wend

'случай выбора конца или начала трассы
If firstFlag = True Then
 If odoEnd = odoStart Then

  If XYflag Then

   If isInside(firstX, firstY * yMulty.Value, Xmin, Ymin, Xmax, Ymax) Then
    odoStart = trc.pageStart
    Exit Function
   End If
   If isInside(X, Y, Xmin, Ymin, Xmax, Ymax) Then
    odoEnd = trc.pageStart + trc.pageLength
    Exit Function
   End If

   Else

   If isInside(firstXY, firstZ * zMulty.Value, Xmin, Ymin, Xmax, Ymax) Then
    odoStart = trc.pageStart
    Exit Function
   End If
   If isInside(l, Z, Xmin, Ymin, Xmax, Ymax) Then
    odoEnd = trc.pageStart + trc.pageLength
    Exit Function
   End If

  End If

 End If
End If

End Function

Private Function isInside( _
ByVal X As Single, _
ByVal Y As Single, _
ByVal Xmin As Single, _
ByVal Ymin As Single, _
ByVal Xmax As Single, _
ByVal Ymax As Single _
) As Boolean
isInside = IIf(X > Xmin And X < Xmax And Y > Ymin And Y < Ymax, True, False)
End Function

'функция определяет пересекает ли вектор с координатами X1,Y1,X2,Y2
'прямоугольник с координатами углов Xmin...Ymax в *_одном_* месте
'пересечение прямоугольника "насквозь", т.е. две точки пересечения
'не определяется
Private Function isCross( _
ByVal x1 As Single, _
ByVal y1 As Single, _
ByVal x2 As Single, _
ByVal y2 As Single, _
ByVal Xmin As Single, _
ByVal Ymin As Single, _
ByVal Xmax As Single, _
ByVal Ymax As Single _
) As Boolean
Dim p1Inside As Boolean, p2Inside As Boolean
p1Inside = isInside(x1, y1, Xmin, Ymin, Xmax, Ymax)
p2Inside = isInside(x2, y2, Xmin, Ymin, Xmax, Ymax)
isCross = p1Inside Xor p2Inside
End Function

Private Function getFirstPoint( _
ByRef odoDist As Long, _
ByVal odoLen As Long, _
ByRef X As Long, _
ByRef Y As Long, _
ByRef Z As Long _
) As Boolean
Dim ctrlSize As Long

getFirstPoint = False
lastPoint = odoDist + odoLen
ctrlSize = vogXY.width / Screen.twipsPerPixelX

If krotGetFirstNodeGroup(trc.handle, node, odoDist, SENS_VOG, odoLen, ctrlSize) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при вызове krotGetFirstNodeGroup." & _
  vbNewLine & lastError()
 Exit Function
End If

X = node.vogZ
Y = node.vogx
Z = node.vogy

odoDist = node.vogPos
getFirstPoint = True
End Function

Private Function getNextPoint( _
ByRef odoDist As Long, _
ByRef X As Long, _
ByRef Y As Long, _
ByRef Z As Long _
) As Boolean

If krotGetNextNodeGroup(trc.handle, node) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при вызове krotGetNextNodeGroup." & _
  vbNewLine & lastError()
 Exit Function
End If

X = node.vogZ
Y = node.vogx
Z = node.vogy

odoDist = node.vogPos
If odoDist >= lastPoint Then
 getNextPoint = False
 Else
 getNextPoint = True
End If
End Function

Private Function getNextVogPoint( _
ByRef odoDist As Long, _
ByRef X As Long, _
ByRef Y As Long, _
ByRef Z As Long _
) As Boolean

If vogGetNextMatching(node) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при вызове vogGetNextMatching." & _
  vbNewLine & trc.vog.vogLastErr()
 Exit Function
End If

X = node.vogZ
Y = node.vogx
Z = node.vogy

odoDist = node.vogPos
If (odoDist > lastPoint) Or (odoDist = trc.length) Then
 getNextVogPoint = False
 Else
 getNextVogPoint = True
End If
End Function

Private Sub vogMouseMove(v As clsCursor, Button As Integer, Shift As Integer, X As Single, Y As Single)
If Zoom.inProgress Then
 If Shift = 1 Then
  Zoom.Continue X, Y
  Else
  Zoom.Finish
 End If
 Else
 Select Case Shift
  Case 0 'не нажата ни одна клавиша - обычный курсор
   v.cursType = CURS_USER
  Case 1 'нажат shift - зуммирование
   v.cursType = CURS_WINCROSS
  Case 2 'нажат ctrl - выбор маркера
   v.cursType = IIf(trc.mark.isCurrWhite, CURS_SELWHITE, CURS_SELBLACK)
 End Select
 v.Draw X, Y
End If
End Sub

Private Function vogMouseUp( _
v As PictureBox, _
Button As Integer, _
Shift As Integer, _
X As Single, _
Y As Single, _
ByRef x1 As Single, _
ByRef x2 As Single, _
ByRef y1 As Single, _
ByRef y2 As Single) As Boolean

vogMouseUp = False
If Zoom.inProgress Then
 Zoom.Continue X, Y
 Zoom.Finish
 Zoom.Coords x1, y1, x2, y2
 'ogdWin.Info Fix(X1) & "," & Fix(Y1) & "  " & Fix(X2) & "," & Fix(Y2)
 vogMouseUp = True
End If
End Function

Private Sub vogXY_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
coordX.Caption = txtCoord(x)
coordY.Caption = txtCoord(Y / yMulty.Value)
vogMouseMove cursX, Button, Shift, X, Y
End Sub

Private Sub vogXY_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim Xmax As Single, Ymax As Single, Xmin As Single, Ymin As Single

If vogMouseUp(vogXY, Button, Shift, X, Y, Xmin, Xmax, Ymin, Ymax) Then
 vogZoom Xmin, Ymin, Xmax, Ymax, True
End If
End Sub

Private Sub vogZ_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
coordL.Caption = txtCoord(x)
coordZ.Caption = txtCoord(Y / zMulty.Value)
vogMouseMove cursY, Button, Shift, X, Y
End Sub

Private Sub vogZ_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim Xmax As Single, Ymax As Single, Xmin As Single, Ymin As Single

If vogMouseUp(vogZ, Button, Shift, X, Y, Xmin, Xmax, Ymin, Ymax) Then
 vogZoom Xmin, Ymin, Xmax, Ymax, False
End If
End Sub

Private Sub vogZoom( _
ByVal Xmin As Long, _
ByVal Ymin As Long, _
ByVal Xmax As Long, _
ByVal Ymax As Long, _
ByVal XYflag As Boolean)

Dim odoStart As Long, odoEnd As Long

setWait "Расчет навигационной трассы..."

If findBorder(odoStart, odoEnd, Xmin, Ymin, Xmax, Ymax, XYflag) Then
 setInterval odoStart, odoEnd, False
 'DrawVOG
 RaiseEvent visualPartChange(odoStart, odoEnd - odoStart)
End If

setReady
End Sub

Public Sub setPage(Optional ByVal setTrcPageFlag As Boolean = True)
If Not setTrcPageFlag Then initFlag = True
setInterval trc.pageStart, trc.pageStart + trc.pageLength, True
If Not setTrcPageFlag Then initFlag = False
End Sub

Private Function setInterval(ByVal odoStart As Long, ByVal odoEnd As Long, ByVal force As Boolean) As Boolean
Dim x As Long, y As Long, z As Long, dst As Long, l As Long, prev_dst As Long
Dim x1 As Long, y1 As Long, z1 As Long
Dim Count As Double

If trc Is Nothing Then Exit Function

setInterval = False
If trc Is Nothing Then Exit Function

If odoStart < 0 Then Exit Function
If odoEnd > trc.length Then Exit Function
If odoStart >= odoEnd Then Exit Function

'блокирование открытия всей трассы в текущем окне
'If (trc.pageStart = odoStart) And (trc.pageStart + trc.pageLength = odoEnd) And (force = False) Then Exit Function

' поиск начальной точки отсчета в Z-окне
If cfg.vog.calcXZ = False Then
 d_x2min = 0
 Else
 d_x2min = calcPath(0, odoStart)
End If

If Not initFlag Then
 trc.pageStart = odoStart
 trc.pageLength = odoEnd - odoStart
End If

dst = trc.pageStart
l = trc.pageLength

If vogInitMatching(rotAngle.angle, trc.handle, dst, l, -1, 0, 0, vogXY.width / Screen.twipsPerPixelX, 0) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при вызове vogInitMatching." & _
  vbNewLine & trc.vog.vogLastErr()
  Exit Function
End If
lastPoint = trc.pageStart + trc.pageLength
getNextVogPoint dst, X, Y, Z

d_x1min = X
d_x1max = X
d_y1min = Y
d_y1max = Y
d_x2max = d_x2min
d_y2min = Z
d_y2max = Z

Count = d_x2max

prev_dst = dst
While getNextVogPoint(dst, x1, y1, z1)

 If prev_dst = dst Then
   ogdWin.Alert "Ошибка инициализации данных VOG. Данные VOG повреждены."
   Exit Function
 End If
 prev_dst = dst
 
 Count = Count + Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)
 X = x1
 Y = y1
 Z = z1
 If X > d_x1max Then d_x1max = X
 If X < d_x1min Then d_x1min = X
 If Y > d_y1max Then d_y1max = Y
 If Y < d_y1min Then d_y1min = Y
 If Z > d_y2max Then d_y2max = Z
 If Z < d_y2min Then d_y2min = Z
Wend

d_x2max = Count

setInterval = True
End Function

Private Function calcPath(ByVal startPoint As Long, ByVal endPoint As Long) As Long
Dim X As Long, Y As Long, Z As Long, dst As Long
Dim x1 As Long, y1 As Long, z1 As Long
Dim Count As Double

dst = startPoint
getFirstPoint dst, endPoint, X, Y, Z
Count = startPoint

While getNextPoint(dst, x1, y1, z1)
 Count = Count + Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)
 X = x1
 Y = y1
 Z = z1
Wend
calcPath = Count
End Function

Private Sub setScale( _
ByRef twipsPerPixelX As Single, _
ByRef twipsPerPixelY As Single, _
ByVal Xmax As Double, _
ByVal Xmin As Double, _
ByVal Ymax As Double, _
ByVal Ymin As Double, _
fld As PictureBox, _
zMul As Integer)
Dim deltaX As Long, deltaY As Long, fSize As Long


fSize = fld.ScaleMode
fld.ScaleMode = vbPixels
twipsPerPixelX = fld.ScaleWidth
twipsPerPixelY = Abs(fld.ScaleHeight)
fld.ScaleMode = fSize

Ymin = Ymin * zMul
Ymax = Ymax * zMul

deltaX = Xmax - Xmin
deltaY = Ymax - Ymin
If deltaX < deltaY Then
 fSize = deltaY
 Else
 fSize = deltaX
End If

If deltaX = fSize Then
 fld.ScaleLeft = Xmin
 Else
 fld.ScaleLeft = Xmin - fSize / 2 + deltaX / 2
End If
fld.ScaleWidth = IIf(fSize = 0, 1, fSize)

If deltaY = fSize Then
 fld.ScaleTop = Ymax
 Else
 'fld.ScaleTop = Ymax
 fld.ScaleTop = Ymax + fSize / 2 - deltaY / 2
End If
fld.ScaleHeight = IIf(fSize = 0, -1, -fSize)
'fld.ScaleTop = -fld.ScaleTop

twipsPerPixelX = fld.ScaleWidth / twipsPerPixelX
twipsPerPixelY = Abs(fld.ScaleHeight) / twipsPerPixelY

End Sub

Private Function DrawVOG() As Boolean
Dim X As Long, Y As Long, Z As Long, dst As Long, l1 As Long, xy As Double, l As Double
Dim x1 As Long, y1 As Long, z1 As Long, d_end As Long
Dim c As clsVogSlave
Dim p1dist As Long, p2dist As Long, p1Flag As Boolean, p2Flag As Boolean
Dim p3dist As Long, p3Flag As Boolean
Dim matchStart As Long, matchLength As Long, matchZstart As Long
Dim oldColor1 As Long, oldType1 As Long, oldColor2 As Long, oldType2 As Long
Dim xx1 As Double, xx2 As Double, yy1 As Double, yy2 As Double

DrawVOG = False

If trc Is Nothing Then Exit Function
If initFlag Then Exit Function

d_end = trc.pageStart + trc.pageLength
point1.odo = trc.mark.white
point2.odo = trc.mark.black

savStart.Caption = mm2txt(trc.vog.saveStart)
savEnd.Caption = mm2txt(trc.vog.saveEnd)

vogXY.Cls
vogZ.Cls

setScale d_tppXY_X, d_tppXY_Y, d_x1max, d_x1min, d_y1max, d_y1min, vogXY, yMulty.Value
setScale d_tppZ_X, d_tppZ_Y, d_x2max, d_x2min, d_y2max, d_y2min, vogZ, zMulty.Value

If matchPoint1 < matchPoint2 Then
 matchStart = matchPoint1
 matchLength = matchPoint2 - matchPoint1
 Else
 matchStart = matchPoint2
 matchLength = matchPoint1 - matchPoint2
End If

dst = trc.pageStart
l1 = trc.pageLength

If vogInitMatching(rotAngle.angle, trc.handle, dst, l1, -1, 0, 0, vogXY.width / Screen.twipsPerPixelX, 0) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при отрисовке графика (vogInitMatching)." & _
  vbNewLine & trc.vog.vogLastErr()
  Exit Function
End If
lastPoint = trc.pageStart + trc.pageLength
getNextVogPoint dst, X, Y, Z

nodeCount = 1
l = d_x2min
p1dist = Abs(point1.odo - dst)
p2dist = Abs(point2.odo - dst)
p3dist = Abs(matchStart - dst)
p1Flag = IIf((point1.odo < trc.pageStart) Or (point1.odo > d_end), True, False)
p2Flag = IIf((point2.odo < trc.pageStart) Or (point2.odo > d_end), True, False)
p3Flag = False

If loggedMode Then
 Log logFile, "Draw handle " & trc.handle
 Log logFile, "Start " & trc.pageStart & " End " & d_end
 Log logFile, "Match start " & matchPoint1 & " match end " & matchPoint2
End If

oldColor1 = vogXY.ForeColor
oldType1 = vogXY.DrawWidth
oldColor2 = vogZ.ForeColor
oldType2 = vogZ.DrawWidth

'включить межмаркерное выделение, если первый маркер установлен до
'начала участка, а второй после начала
If ((point1.odo < trc.pageStart) And (point2.odo > trc.pageStart)) Then
 vogXY.ForeColor = cfg.vog.markColor
 vogXY.DrawWidth = cfg.vog.markWidth
 vogZ.ForeColor = cfg.vog.markColor
 vogZ.DrawWidth = cfg.vog.markWidth
End If

While getNextVogPoint(dst, x1, y1, z1)
 nodeCount = nodeCount + 1
 xy = Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)

 If loggedMode Then
  Log logFile, _
   "Odo: " & dst & _
   " XY: (" & X & " , " & Y & ")-(" & x1 & " , " & y1 & ")" & _
   " Z: (" & l & " , " & Z & ")-(" & l + xy & " , " & z1 & ")"
 End If

 'отрисовка маркеров
 If p1Flag = False Then
  If Abs(point1.odo - dst) <= p1dist Then
   p1dist = Abs(point1.odo - dst)
   Else
   p1Flag = True

   yy1 = Y
   yy1 = yy1 * yMulty.Value
   drawMark True, X, yy1, True
   yy1 = Z
   yy1 = yy1 * zMulty.Value
   drawMark False, l, yy1, True

   vogXY.ForeColor = cfg.vog.markColor
   vogXY.DrawWidth = cfg.vog.markWidth
   vogZ.ForeColor = cfg.vog.markColor
   vogZ.DrawWidth = cfg.vog.markWidth

   point1.X = X
   point1.Y = Y
   point1.xy = l
   point1.Z = Z
  End If
 End If
 If p2Flag = False Then
  If Abs(point2.odo - dst) <= p2dist Then
   p2dist = Abs(point2.odo - dst)
   Else
   p2Flag = True

   vogXY.ForeColor = oldColor1
   vogXY.DrawWidth = oldType1
   vogZ.ForeColor = oldColor2
   vogZ.DrawWidth = oldType2

   yy1 = Y
   yy1 = yy1 * yMulty.Value
   drawMark True, X, yy1, False
   yy1 = Z
   yy1 = yy1 * zMulty.Value
   drawMark False, l, yy1, False

   point2.X = X
   point2.Y = Y
   point2.xy = l
   point2.Z = Z
  End If
 End If
 'поиск точки отсчета для отрисовки совмещенной Z-составляющей
 If p3Flag = False Then
  If Abs(matchStart - dst) <= p3dist Then
   p3dist = Abs(matchStart - dst)
   Else
   p3Flag = True
   matchZstart = l
  End If
 End If

 xx1 = X
 yy1 = Y
 yy1 = yy1 * yMulty.Value
 xx2 = x1
 yy2 = y1
 yy2 = yy2 * yMulty.Value
 DrawLine vogXY, xx1, yy1, xx2, yy2

 xx1 = l
 yy1 = Z
 yy1 = yy1 * zMulty.Value
 xx2 = l + xy
 yy2 = z1
 yy2 = yy2 * zMulty.Value
 DrawLine vogZ, xx1, yy1, xx2, yy2

 X = x1
 Y = y1
 Z = z1
 l = l + xy

Wend

vogXY.ForeColor = oldColor1
vogXY.DrawWidth = oldType1
vogZ.ForeColor = oldColor2
vogZ.DrawWidth = oldType2

LabNodeCount.Caption = nodeCount

'визуализация узлов, если их мало
If nodeCount <= cfg.vog.maxNode Then
 dst = trc.pageStart
 l1 = trc.pageLength
 If vogInitMatching(rotAngle.angle, trc.handle, dst, l1, -1, 0, 0, vogXY.width / Screen.twipsPerPixelX, 0) = KRT_ERR Then
  ogdWin.Alert _
   "Ошибка драйвера при отрисовке графика(узлы) (vogInitMatching)." & _
   vbNewLine & trc.vog.vogLastErr()
   Exit Function
 End If
 l = d_x2min
 getNextVogPoint dst, X, Y, Z
 vogXY.Circle (X, Y * yMulty.Value), Abs(vogXY.ScaleHeight / NODERADIUS)
 vogZ.Circle (l, Z * zMulty.Value), Abs(vogZ.ScaleHeight / NODERADIUS)

 While getNextVogPoint(dst, x1, y1, z1)
  xy = Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)
  vogXY.Circle (x1, y1 * yMulty.Value), Abs(vogXY.ScaleHeight / NODERADIUS)
  vogZ.Circle (l + xy, z1 * zMulty.Value), Abs(vogZ.ScaleHeight / NODERADIUS)
  l = l + xy
  X = x1
  Y = y1
  Z = z1
 Wend
End If

'отрисовка связанных участков
For Each c In d_slave.trace

 If c.mark1 < c.mark2 Then
  X = c.mark1
  Y = c.mark2 - c.mark1
  lastPoint = c.mark2
  Else
  X = c.mark2
  Y = c.mark1 - c.mark2
  lastPoint = c.mark1
 End If

 If vogInitMatching( _
  rotAngle.angle, _
  trc.handle, _
  matchStart, _
  matchLength, _
  c.traceHandle, _
  X, _
  Y, _
  vogXY.width / Screen.twipsPerPixelX, _
  d_slave.modes _
  ) = KRT_OK Then


   If loggedMode Then
    Log logFile, "Draw slave handle " & c.traceHandle
    Log logFile, "Slave start " & c.mark1 & " Slave end " & c.mark2
   End If

   l = matchZstart
   getNextVogPoint dst, X, Y, Z
   While getNextVogPoint(dst, x1, y1, z1)
    xy = Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)
    DrawLine vogXY, X, Y * yMulty.Value, x1, y1 * yMulty.Value, c.color
    DrawLine vogZ, l, Z * zMulty.Value, l + xy, z1 * zMulty.Value, c.color

    If loggedMode Then
     Log logFile, _
      "Odo: " & dst & _
      " XY: (" & X & " , " & Y & ")-(" & x1 & " , " & y1 & ")" & _
      " Z: (" & l & " , " & Z & ")-(" & l + xy & " , " & z1 & ")"
    End If

    X = x1
    Y = y1
    Z = z1
    l = l + xy
   Wend

   If loggedMode Then
    Log logFile, "Done slave handle " & c.traceHandle
   End If

 End If
Next

If loggedMode Then
 Log logFile, "Done handle " & trc.handle
 Log logFile, ""
End If

'отрисовка разниц между отметками маркеров
'l = dist(point1.X, point1.Y, point2.X, point2.Y)
p1p2distVogX.Caption = txtCoord(point1.z - point2.x)
p1p2distVogY.Caption = txtCoord(point1.Y - point2.Y)
p1p2distVogXY.Caption = txtCoord(point1.xy - point2.xy)
p1p2distVogZ.Caption = txtCoord(point1.z - point2.z)

cursX.needErase = False
cursY.needErase = False
DrawVOG = True
End Function

Private Sub drawMark( _
ByVal XYflag As Boolean, _
ByVal X As Double, _
ByVal Y As Double, _
firstPoint As Boolean)

Dim deltaX As Single, deltaY As Single, clr As Long, v As PictureBox

If XYflag Then
 Set v = vogXY
 deltaX = d_tppXY_X
 deltaY = d_tppXY_Y
 Else
 Set v = vogZ
 deltaX = d_tppZ_X
 deltaY = d_tppZ_Y
End If
deltaX = VOG_APERTURE / 2 * deltaX
deltaY = VOG_APERTURE / 2 * deltaY

clr = IIf(firstPoint, &HFFFFFF, &H0&)
DrawLine v, X - deltaX, Y - deltaY, X + deltaX, Y + deltaY, clr
DrawLine v, X - deltaX, Y + deltaY, X + deltaX, Y - deltaY, clr
End Sub

Private Sub yMulty_Change(m As Integer)
trc.vog.yMult = yMulty.Value
DrawVOG
RaiseEvent Redraw
End Sub

Private Sub zMulty_Change(m As Integer)
trc.vog.zMult = zMulty.Value
DrawVOG
RaiseEvent Redraw
End Sub

Public Sub Draw()
DrawVOG
End Sub

Public Function turnInfo( _
ByVal Start As Long, _
ByVal length As Long, _
ByVal tuneMode As Long, _
ByRef radiusXY As Long, _
ByRef angleXY As Single, _
ByRef radiusZ As Long, _
ByRef angleZ As Single, _
ByRef Xmark As Long, _
ByRef Ymark As Long, _
ByRef Zmark As Long, _
ByRef angle3D As Single, _
ByVal user_length As Long, _
Optional calc_type As Long = 0 _
) As Boolean

Dim dt As T_TURNDATA
Dim x As Long, y As Long, z As Long, dst As Long, correct As Long, ln As Long, piglen As Long

turnInfo = False
piglen = trc.pigL0 + trc.pigL1

If length = 0 Then
 ogdWin.Alert "Не могу вычислить параметры поворота нулевой длины."
 Exit Function
End If

correct = (tuneMode And TURN_START) Or (tuneMode And TURN_END)

If correct > 0 Then
 ln = piglen
 Else
 ln = 0
End If

If GetCurveData(trc.handle, calc_type, correct, Start, length, trc.pigDiam, ln, dt) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка при вычислении параметров поворота в горизонтальной плоскости." & _
  vbNewLine & trc.vog.vogLastErr()
 Exit Function
End If
radiusXY = dt.radius
angleXY = dt.angle

If calc_type = 1 Then
 If user_length < piglen Then
  radiusXY = 0
 Else
  If dt.angle = 0 Then
    radiusXY = 0
  Else
    radiusXY = Abs((user_length - piglen) / dt.angle)
  End If
 End If
End If

dst = correct Or TURN_VER
If GetCurveData(trc.handle, calc_type, dst, Start, length, trc.pigDiam, ln, dt) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка при вычислении параметров поворота в вертикальной плоскости." & _
  vbNewLine & trc.vog.vogLastErr()
 Exit Function
End If
radiusZ = dt.radius
angleZ = dt.angle

If calc_type = 1 Then
 If user_length < piglen Then
  radiusZ = 0
 Else
  If dt.angle = 0 Then
    radiusZ = 0
  Else
    radiusZ = Abs((user_length - piglen) / dt.angle)
  End If
 End If
End If

dst = correct Or TURN_3D
If GetCurveData(trc.handle, calc_type, dst, Start, length, trc.pigDiam, ln, dt) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка при вычислении параметров 3D поворота." & _
  vbNewLine & trc.vog.vogLastErr()
 Exit Function
End If
angle3D = dt.angle

getFirstPoint Start, Start + length, X, Y, Z
Xmark = X
Ymark = Y
Zmark = Z

turnInfo = True
End Function

Property Get Slave() As clsVogMatch
Set Slave = d_slave
End Property

Property Get matchMark1() As Long
matchMark1 = matchPoint1
End Property

Property Let matchMark1(m As Long)
matchPoint1 = m
End Property

Property Get matchMark2() As Long
matchMark2 = matchPoint2
End Property

Property Let matchMark2(m As Long)
matchPoint2 = m
End Property

Public Sub copyClipboard(ByVal area As VOG_AREA)
Me.Draw
Select Case area
 Case AREA_XY
  Clipboard.Clear
  Clipboard.SetData vogXY.Image
 Case AREA_Z
  Clipboard.Clear
  Clipboard.SetData vogZ.Image
End Select
End Sub

Public Sub setRotAngle()
rotAngle.setRotAngle
End Sub

Public Sub drawObj(ByVal objDist As Long, objPic As PictureBox, ByVal flash As Boolean)
Dim X As Long, Y As Long, Z As Long, dst As Long, l1 As Long, xy As Double, l As Double
Dim x1 As Long, y1 As Long, z1 As Long
Dim p1dist As Long
Dim dFlag As Boolean

If trc Is Nothing Then Exit Sub

dFlag = False
dst = trc.pageStart
l1 = trc.pageLength
If vogInitMatching(rotAngle.angle, trc.handle, dst, l1, -1, 0, 0, vogXY.width / Screen.twipsPerPixelX, 0) = KRT_ERR Then
 ogdWin.Alert _
  "Ошибка драйвера при отрисовке обьекта трассы (vogInitMatching)." & _
  vbNewLine & trc.vog.vogLastErr()
  Exit Sub
End If
l = d_x2min
getNextVogPoint dst, X, Y, Z
p1dist = Abs(objDist - dst)

While getNextVogPoint(dst, x1, y1, z1)
 xy = Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)
 If Abs(objDist - dst) <= p1dist Then
  p1dist = Abs(objDist - dst)
  Else
  dFlag = True
  If flash Then
   flashObjImage vogXY, X, Y * yMulty.Value, vogZ, l, Z * zMulty.Value, objPic
  End If
  drawObjImage vogXY, X, Y * yMulty.Value, objPic
  drawObjImage vogZ, l, Z * zMulty.Value, objPic
  Exit Sub
 End If
 l = l + xy
 X = x1
 Y = y1
 Z = z1
Wend

'если обьект попал на последний узел на интервале, то его тАки надо нарисовать
If dFlag = False Then
 If flash Then
  flashObjImage vogXY, X, Y * yMulty.Value, vogZ, l, Z * zMulty.Value, objPic
 End If
 drawObjImage vogXY, X, Y * yMulty.Value, objPic
 drawObjImage vogZ, l, Z * zMulty.Value, objPic
End If

End Sub

Private Sub flashObjImage( _
px As PictureBox, _
ByVal Xx As Single, _
ByVal Yx As Single, _
pz As PictureBox, _
ByVal Xz As Single, _
ByVal Yz As Single, _
objPic As PictureBox)

Dim dxx As Single, dyx As Single, i As Integer
Dim dxz As Single, dyz As Single, msec As Integer

msec = 100
dxx = px.ScaleWidth * objPic.width / px.width
dyx = px.ScaleHeight * objPic.Height / px.Height
dxz = pz.ScaleWidth * objPic.width / pz.width
dyz = pz.ScaleHeight * objPic.Height / pz.Height

For i = 0 To 3
 px.PaintPicture objPic.Picture, Xx - (dxx / 2), Yx - (dyx / 2), , , , , , , vbNotSrcCopy
 pz.PaintPicture objPic.Picture, Xz - (dxz / 2), Yz - (dyz / 2), , , , , , , vbNotSrcCopy
 vogTimer.sleep Timer1, msec
 px.PaintPicture objPic.Picture, Xx - (dxx / 2), Yx - (dyx / 2)
 pz.PaintPicture objPic.Picture, Xz - (dxz / 2), Yz - (dyz / 2)
 vogTimer.sleep Timer1, msec
Next

End Sub


Private Sub drawObjImage(p As PictureBox, ByVal X As Single, ByVal Y As Single, objPic As PictureBox)
Dim dx As Single, dy As Single, i As Integer

dx = p.ScaleWidth * objPic.width / p.width
dy = p.ScaleHeight * objPic.Height / p.Height

p.PaintPicture objPic.Picture, X - (dx / 2), Y - (dy / 2)
End Sub

Private Sub drawLine( _
p As PictureBox, _
ByVal x1 As Double, _
ByVal y1 As Double, _
ByVal x2 As Double, _
ByVal y2 As Double, _
Optional ByVal color As Long = -1)

If color = -1 Then color = p.ForeColor
'p.Line (X1, Y1 + p.ScaleHeight)-(X2, Y2 + p.ScaleHeight), color
p.Line (x1, y1)-(x2, y2), color

End Sub

Public Function exportZ(fileName As String) As Boolean
ExportZvalue trc.pageStart, trc.pageStart + trc.pageLength, FileName
exportZ = True
End Function

Private Sub ExportZvalue(ByVal odoStart As Long, ByVal odoEnd As Long, fileName As String)
Dim out As Integer
Dim X As Long, Y As Long, Z As Long, dst As Long
Dim x1 As Long, y1 As Long, z1 As Long, xy As Double, dlt As Double

out = FreeFile
dst = odoStart
xy = calcPath(0, odoStart)
Open fileName For Output As out

getFirstPoint dst, odoEnd, X, Y, Z
Print #out, "Таблица значений Z-координат VOG с " & _
 mm2txt(odoStart) & _
 " по " & _
 mm2txt(odoEnd)
Print #out, "XY,Z,ODO,X1,Y1,X2,Y2,DELTA"

Print #out, Fix(xy) & "," & Z & "," & dst

While getNextPoint(dst, x1, y1, z1)
 dlt = Sqr((x1 - X) ^ 2 + (y1 - Y) ^ 2)
 xy = xy + dlt
 Print #out, xy & "," & z1 & "," & dst & "," & X & "," & Y & "," & x1 & "," & y1 & "," & dlt
 X = x1
 Y = y1
 Z = z1
Wend
Close out
End Sub

Public Sub visRestore()
setInterval trc.vog.saveStart, trc.vog.saveEnd, False
RaiseEvent visualPartChange(trc.vog.saveStart, trc.vog.saveEnd - trc.vog.saveStart)
End Sub

Property Get isVis() As Boolean
isVis = d_vis
End Property

Property Let isVis(v As Boolean)
d_vis = v
End Property

Private Function txtCoord(ByVal x As Double) As String
txtCoord = Format$(x / 1000#, "0.00")
End Function