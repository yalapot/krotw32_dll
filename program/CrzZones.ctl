VERSION 5.00
Begin VB.UserControl ctrlCrzZones 
   ClientHeight    =   3600
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   9840
   ScaleHeight     =   3600
   ScaleWidth      =   9840
   Begin krotw32.ctrlCrzZonesSettings settings 
      Height          =   225
      Left            =   480
      TabIndex        =   1
      Top             =   0
      Width           =   2655
      _ExtentX        =   4683
      _ExtentY        =   397
   End
   Begin krotw32.ctrlCoroz crzZone 
      Height          =   1935
      Index           =   0
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   9735
      _ExtentX        =   17171
      _ExtentY        =   3413
   End
End
Attribute VB_Name = "ctrlCrzZones"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private resizeFlag As Boolean
Private pickUpWeldFlag As Boolean
Private trc As clsTrace
Private parentForm As frmTrace

Public Event redraw()
Public Event goDist(ByVal dst As Long)
Public Event sizeChange()
Public Event mouseMove(ByVal y As Integer, ByVal x As Long, ByVal zoneNum As Long)
Public Event objIns(ByVal x As Long)
Public Event changeMark()
Public Event oneSensOff(ByVal indx As Integer)
Public Event circleOff(ByVal indx As Integer)
Public Event Zoom(crz As ctrlCoroz, ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Long, ByVal y2 As Long)
Public Event pixelRight(ByVal pix As Integer)
Public Event keyDown(ByVal KeyCode As Integer, ByVal Shift As Integer)
Public Event pickUpWeld(ByVal fullHour As Double)
Public Event onTool(ByVal isOn As Boolean)
Public Event waitMessage(ByVal isWait As Boolean, ByVal msgText As String)
Public Event setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
Public Event setMarkGroup(ByVal posWhite As Long, ByVal posBlack As Long)

Public Function Init( _
trace As clsTrace, _
frm As frmTrace, _
ByVal mainControl As Boolean, _
ByVal leftShift As Single _
) As Boolean

Dim i As Integer

Set parentForm = frm
Set trc = frm.trc

crzZone(0).Init parentForm, trc.Coroz.zone(0), mainControl, leftShift

For i = 1 To trc.Coroz.num - 1
 Load crzZone(i)
 crzZone(i).Init parentForm, trc.Coroz.zone(i), False, leftShift
Next

Me.pickUpWeld = False
crzZone_pixelRight 0, 0
End Function

Private Sub crzZone_circleOff(Index As Integer)
RaiseEvent circleOff(Index)
End Sub

Private Sub crzZone_oneSensOff(Index As Integer)
RaiseEvent oneSensOff(Index)
End Sub

Private Sub crzZone_pickUpWeld(Index As Integer, ByVal fullHour As Double)
Me.pickUpWeld = False
RaiseEvent pickUpWeld(fullHour)
End Sub

Property Get pickUpWeld() As Boolean
pickUpWeld = pickUpWeldFlag
End Property

Property Let pickUpWeld(p As Boolean)
Dim i As Integer

pickUpWeldFlag = p
For i = 0 To trc.Coroz.num - 1
 crzZone(i).pickUpWeld = pickUpWeldFlag
Next
End Property

Public Sub TrimHeight(frm As frmTrace, ByVal pixels As Long)
Dim i As Integer

For i = 0 To trc.Coroz.num - 1
 If trc.Coroz.zone(i).visible Then
  If (crzZone(i).Top + crzZone(i).Height) > frm.Height Then
   crzZone(i).TrimHeight pixels
  End If
 End If
Next
End Sub

Public Sub Draw(Optional forceReadData As Boolean = False)
Dim i As Integer

For i = 0 To trc.Coroz.num - 1
 If trc.Coroz.zone(i).visible Then crzZone(i).Draw forceReadData
Next
End Sub

Property Get autoScrollOn() As Boolean
autoScrollOn = crzZone(0).autoScrollOn
End Property

Property Let autoScrollOn(v As Boolean)
Dim i As Integer

For i = 0 To trc.Coroz.num - 1
 crzZone(i).autoScrollOn = v
Next
End Property

Public Sub mouseMove(ByVal X As Single, ByVal y As Integer)
Dim i As Integer

For i = 0 To trc.Coroz.num - 1
 crzZone(i).mouseMove X, y
Next
End Sub

Public Function zone(ByVal indx As Integer) As ctrlCoroz
Set zone = crzZone(indx)
End Function

Property Get zoneNum() As Long
zoneNum = trc.Coroz.num
End Property

Private Sub crzZone_changeMark(Index As Integer)
RaiseEvent changeMark
End Sub

Private Sub crzZone_goDist(Index As Integer, ByVal dst As Long)
RaiseEvent goDist(dst)
End Sub

Private Sub crzZone_keyDown(Index As Integer, ByVal KeyCode As Integer, ByVal Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Private Sub crzZone_mouseMove(Index As Integer, ByVal y As Integer, ByVal x As Long)
Dim i As Integer, calcedY As Long

settings.sensOnCurs = decorSensNum(y)

If Index > 0 Then
 calcedY = y * trc.Coroz.zone(0).num / trc.Coroz.zone(Index).num
End If

If Not Me.autoScrollOn Then
 For i = 0 To trc.Coroz.num - 1
  If i <> Index Then crzZone(i).mouseMove x, calcedY
 Next
End If
RaiseEvent mouseMove(y, x, Index)
End Sub

Private Sub crzZone_objIns(Index As Integer, ByVal X As Long)
RaiseEvent objIns(X)
End Sub

Private Sub crzZone_pixelRight(Index As Integer, ByVal pix As Integer)
Dim i As Integer, maxPix As Integer, curPix As Integer

'выяснить максимальный необходимый правый отступ
maxPix = 0

If trc.Coroz.isAlignVert = False Then
 For i = 0 To trc.Coroz.num - 1
  curPix = crzZone(i).pixelRightMin
  If curPix > maxPix Then maxPix = curPix
 Next
End If

'установить его для всех разветок
For i = 0 To trc.Coroz.num - 1
  crzZone(i).pixelRight = maxPix
Next
RaiseEvent pixelRight(maxPix)
End Sub

Private Sub crzZone_redraw(Index As Integer)
RaiseEvent redraw
End Sub

Private Sub crzZone_setMark(Index As Integer, ByVal mrkWhite As Boolean, ByVal newPos As Long)
RaiseEvent setMark(mrkWhite, newPos)
End Sub

Private Sub crzZone_setMarkGroup(Index As Integer, ByVal posWhite As Long, ByVal posBlack As Long)
RaiseEvent setMarkGroup(posWhite, posBlack)
End Sub

Private Sub crzZone_sizeChange(Index As Integer)
UserControl_Resize
RaiseEvent sizeChange
End Sub

Public Sub changePicHeight()
Dim i As Integer

For i = 0 To trc.Coroz.num - 1
 crzZone(i).changePicHeight
Next
UserControl_Resize
End Sub

Private Sub crzZone_waitMessage(Index As Integer, ByVal isWait As Boolean, ByVal msgText As String)
RaiseEvent waitMessage(isWait, msgText)
End Sub

'Private Sub crzZone_visualPartChange(Index As Integer, ByVal visStart As Long, ByVal visLength As Long)
'RaiseEvent visualPartChange(visStart, visLength)
'End Sub

Private Sub crzZone_Zoom(Index As Integer, crz As ctrlCoroz, ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Long, ByVal y2 As Long)
RaiseEvent Zoom(crz, x1, x2, y1, y2)
End Sub

Public Sub Refresh()
UserControl_Resize
RaiseEvent sizeChange
End Sub

Private Sub UserControl_Initialize()
resizeFlag = False
End Sub

Private Function alignZonesVer() As Single
Dim ctrlHeight As Single, h As Single
Dim i As Integer, parts As Integer

'посчитать кол-во включенных поясов, чтобы пропорционально разбить форму на части.
parts = 1
For i = 1 To trc.Coroz.num - 1
 If trc.Coroz.zone(i).visible Then parts = parts + 1
Next

crzZone(0).width = UserControl.width / parts
ctrlHeight = crzZone(0).Top + crzZone(0).Height

For i = 1 To trc.Coroz.num - 1
 If trc.Coroz.zone(i).visible Then
  crzZone(i).Left = crzZone(0).Left + i * crzZone(0).width
  crzZone(i).width = crzZone(0).width
  crzZone(i).Top = crzZone(0).Top
  h = crzZone(i).Top + crzZone(i).Height
  If h > ctrlHeight Then ctrlHeight = h
  crzZone(i).visible = True
  Else
  crzZone(i).visible = False
 End If
Next

alignZonesVer = ctrlHeight
End Function

Private Function alignZonesHor() As Single
Dim ctrlHeight As Single
Dim i As Integer

crzZone(0).width = UserControl.width
ctrlHeight = crzZone(0).Top + crzZone(0).Height

For i = 1 To trc.Coroz.num - 1
 If trc.Coroz.zone(i).visible Then
  crzZone(i).Left = crzZone(0).Left
  crzZone(i).width = crzZone(0).width
  crzZone(i).Top = ctrlHeight
  ctrlHeight = crzZone(i).Top + crzZone(i).Height
  crzZone(i).visible = True
  Else
  crzZone(i).visible = False
 End If
Next
alignZonesHor = ctrlHeight
End Function

Private Sub UserControl_Resize()
Dim ctrlHeight As Single

If trc Is Nothing Then Exit Sub

If resizeFlag Then Exit Sub
resizeFlag = True

If trc.Coroz.isAlignVert Then
 ctrlHeight = alignZonesVer()
 Else
 ctrlHeight = alignZonesHor()
End If

UserControl.Height = ctrlHeight
resizeFlag = False
End Sub

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Public Sub drawWeld(ByVal dst As Long, ByVal wldBefore1 As Double, ByVal wldBefore2 As Double, ByVal wldAfter1 As Double, ByVal wldAfter2 As Double)
Dim i As Integer

For i = 0 To trc.Coroz.num - 1
 If crzZone(i).visible Then
  crzZone(i).drawWeld dst, wldBefore1, wldBefore2, wldAfter1, wldAfter2
 End If
Next
End Sub

Public Sub drawRect(ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Long, ByVal y2 As Long)
If crzZone(0).visible Then
  crzZone(0).drawBorder x1, x2, y1, y2, False
End If
End Sub

Private Sub settings_onTool(ByVal isOn As Boolean)
RaiseEvent onTool(isOn)
End Sub

Property Get isToolVisible() As Boolean
isToolVisible = settings.isToolVisible
End Property

Property Let isToolVisible(i As Boolean)
settings.isToolVisible = i
End Property