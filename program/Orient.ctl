VERSION 5.00
Begin VB.UserControl ctrlOrient 
   ClientHeight    =   1500
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1515
   ScaleHeight     =   1500
   ScaleWidth      =   1515
   ToolboxBitmap   =   "Orient.ctx":0000
   Begin VB.PictureBox orientPic 
      FillColor       =   &H8000000F&
      ForeColor       =   &H00000000&
      Height          =   1455
      Left            =   0
      ScaleHeight     =   1395
      ScaleWidth      =   1395
      TabIndex        =   0
      ToolTipText     =   "Ориентация снаряда на отметке курсора"
      Top             =   0
      Width           =   1455
      Begin VB.Label sNum 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         Caption         =   "99999"
         Height          =   195
         Left            =   435
         TabIndex        =   1
         ToolTipText     =   "Номер физического датчика под курсором"
         Top             =   600
         Width           =   465
      End
   End
End
Attribute VB_Name = "ctrlOrient"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private cColor As clsSensColors
Private trc As clsTrace
Private sens As clsSensor

Private zoomFlag As Boolean
Private zoomY1 As Long
Private zoomY2 As Long
Private zoomNum As Integer

Private resizeFlag As Boolean

Public Sub Init( _
trace As clsTrace, _
ByVal controlSize As Single, _
controlsColor As clsSensColors _
)
Set trc = trace
Set sens = trc.ornt
Set cColor = controlsColor
zoomFlag = False

orientPic.width = controlSize
orientPic.Height = orientPic.width
UserControl_Resize
End Sub

Private Sub orientPic_Paint()
orientPic.ForeColor = 0
orientPic.DrawMode = 13
orientPic.DrawWidth = 3
orientPic.Circle (orientPic.ScaleWidth / 2, orientPic.ScaleHeight / 2), orientPic.ScaleHeight / 2 - 100, 0
If zoomFlag Then drawZoom zoomY1, zoomY2, zoomNum
End Sub

Private Sub UserControl_Initialize()
orientPic.Height = orientPic.width
resizeFlag = False
End Sub

Private Sub UserControl_Resize()
If resizeFlag Then Exit Sub
resizeFlag = True
UserControl.width = orientPic.width
UserControl.Height = orientPic.Height

sNum.Left = orientPic.ScaleWidth / 2 - sNum.width / 2
sNum.Top = orientPic.ScaleHeight / 2 - sNum.Height / 2
sNum.Caption = "0"

resizeFlag = False
End Sub

Public Sub Draw(ByVal y As Integer, ByVal x As Long, ByVal zoneNum As Integer)
If trc Is Nothing Then Exit Sub
If trc.handle = -1 Then Exit Sub
drawOrientLines x, zoneNum
DrawOrientCursor trc.handle, y, True, zoneNum
'If zoneNum = 0 Then
    sNum.Caption = str((trc.getTopSens(x, 0, zoneNum) + y) Mod trc.Coroz.zone(zoneNum).num)
'    Else
'    sNum.Caption = str(Round((trc.getTopSens(x, 0, zoneNum) + y) * trc.Coroz.zone(0).num / trc.Coroz.zone(zoneNum).num) Mod trc.Coroz.zone(0).num)
'End If
sNum.Refresh
End Sub

Public Sub zoomClear()
zoomFlag = False
orientPic.Cls
orientPic_Paint
End Sub

Public Sub zoomDraw(ByVal yStart As Integer, ByVal yEnd As Integer, ByVal zoneNum As Integer)
If trc Is Nothing Then Exit Sub
If trc.handle < 0 Then Exit Sub
zoomFlag = True
zoomY1 = yStart
zoomY2 = yEnd
zoomNum = zoneNum
drawZoom zoomY1, zoomY2, zoneNum
End Sub

Private Sub drawZoom(ByVal yStart As Integer, ByVal yEnd As Integer, ByVal zoneNum As Integer)
Dim y1 As Single, y2 As Single, degreeInSens As Single

degreeInSens = 2 * PI / trc.Coroz.zone(zoneNum).num
If yEnd = yStart Then Exit Sub
y1 = krtAngle2VBangle(yEnd * degreeInSens)
y2 = krtAngle2VBangle(yStart * degreeInSens)

orientPic.Circle (orientPic.ScaleWidth / 2, orientPic.ScaleHeight / 2), orientPic.ScaleHeight / 2 - 150, &HFF, y1, y2
End Sub

Private Sub DrawOrientCursor( _
ByVal indx As Integer, _
ByVal curs As Single, _
ByVal drw As Boolean, _
ByVal zoneNum As Integer)

Dim pos As Single
Dim poss As Single
Dim pose As Single
Dim cl As Long
Dim degreeInSens As Single

degreeInSens = 2 * PI / trc.Coroz.zone(zoneNum).num
cl = IIf(drw = True, &HFFFFFF, 0)
pos = krtAngle2VBangle(curs * degreeInSens)
poss = pos - HorientCursor
pose = pos + HorientCursor

If poss < 0 Then poss = 2 * PI + poss
If pose > 2 * PI Then pose = 2 * PI - pose

orientPic.Circle (orientPic.ScaleWidth / 2, orientPic.ScaleHeight / 2), orientPic.ScaleHeight / 2 - 100, cl, poss, pose
End Sub

Private Sub drawOrientLines(x As Long, ByVal zoneNum As Integer)
Dim i As Integer

clearOrientLines
For i = 0 To sens.num - 1
 If sens.line(i).visible Then drawOrientLine x, i, zoneNum
Next i
End Sub

Private Sub drawOrientLine(x As Long, indx As Integer, ByVal zoneNum As Integer)
Dim dist As Single, angl As Single, x1 As Single, y1 As Single, x2 As Single, y2 As Single
Dim degreeInSens As Single

degreeInSens = 2 * PI / trc.Coroz.zone(zoneNum).num
angl = (sens.num - trc.getTopSens(x, indx, zoneNum)) * degreeInSens
x1 = orientPic.ScaleWidth / 2
y1 = orientPic.ScaleHeight / 2

calcPoint2 y1, angl, x1, y1, x2, y2
orientPic.Line (x1, y1)-(x2, y2), cColor.clrIndx(indx)
End Sub

Private Sub calcPoint2(dist As Single, angl As Single, x1 As Single, y1 As Single, x2 As Single, y2 As Single)
x2 = x1 + dist * sIn(angl)
y2 = y1 - dist * sIn(PI / 2 + angl)
End Sub

Private Sub clearOrientLines()
orientPic.Cls
orientPic_Paint
End Sub