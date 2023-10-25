VERSION 5.00
Begin VB.UserControl longScroll 
   Appearance      =   0  'Flat
   BackColor       =   &H80000009&
   ClientHeight    =   1080
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1950
   DrawWidth       =   2
   FillColor       =   &H80000012&
   MaskColor       =   &H80000012&
   ScaleHeight     =   1080
   ScaleWidth      =   1950
   ToolboxBitmap   =   "lScroll.ctx":0000
   Begin VB.Timer Tmr 
      Enabled         =   0   'False
      Left            =   240
      Top             =   600
   End
   Begin VB.CommandButton btmRight 
      Caption         =   ">"
      Height          =   255
      Left            =   1680
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   0
      Width           =   255
   End
   Begin VB.CommandButton btmLeft 
      Caption         =   "<"
      Height          =   255
      Left            =   0
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   0
      Width           =   255
   End
   Begin VB.CommandButton tmp 
      Height          =   255
      Left            =   0
      TabIndex        =   2
      Top             =   720
      Width           =   135
   End
   Begin VB.Shape btmWind 
      BackColor       =   &H80000004&
      BackStyle       =   1  'Opaque
      BorderColor     =   &H80000015&
      Height          =   255
      Left            =   240
      Top             =   0
      Width           =   1095
   End
End
Attribute VB_Name = "longScroll"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private trc As clsTrace

Private btmOffset As Single
Private shiftSide As Integer
Private largeScrollFlag As Boolean
Private dragFlag As Boolean
Private posOnDrag As Long
Private lastMouseDn As Single
Private pickPoint As Single

Public Event Change(ByVal pos As Long)

Public Sub Init(trace As clsTrace)
Set trc = trace
End Sub

Private Function insideBox(ByVal X As Single) As Integer
Select Case X
 Case Is < btmWind.Left
  insideBox = -1
 Case Is > btmWind.Left + btmWind.width
  insideBox = 1
 Case Else
  insideBox = 0
End Select
End Function

Private Sub SmallChange(ByVal sign As Integer)
anyChange trc.smallShift * sign
End Sub

Private Sub LargeChange(ByVal sign As Integer)
anyChange trc.pageLength * sign
End Sub

Private Sub anyChange(ByVal shiftVal As Long)
RaiseEvent Change(trc.pageStart + shiftVal)
End Sub

Private Sub btmLeft_MouseDown(Button As Integer, Shift As Integer, X As Single, y As Single)
shiftSide = -1
SmallChange shiftSide
largeScrollFlag = False
Tmr.enabled = True
End Sub

Private Sub btmLeft_MouseUp(Button As Integer, Shift As Integer, X As Single, y As Single)
stopScroll
End Sub

Private Sub btmRight_MouseDown(Button As Integer, Shift As Integer, X As Single, y As Single)
shiftSide = 1
SmallChange shiftSide
largeScrollFlag = False
Tmr.enabled = True
End Sub

Private Sub btmRight_MouseUp(Button As Integer, Shift As Integer, X As Single, y As Single)
stopScroll
End Sub

Private Sub stopScroll()
Tmr.enabled = False
shiftSide = 0
tmp.SetFocus
End Sub

Private Sub Tmr_Timer()
Static intFlag As Boolean

If intFlag Then Exit Sub

intFlag = True
If largeScrollFlag Then
 If insideBox(lastMouseDn) = 0 Then
  intFlag = False
  stopScroll
  Exit Sub
 End If
 LargeChange shiftSide
Else
 SmallChange shiftSide
End If
intFlag = False
End Sub

Private Sub UserControl_MouseDown(Button As Integer, Shift As Integer, X As Single, y As Single)
If Not Me.enable Then Exit Sub
lastMouseDn = X
If insideBox(lastMouseDn) = 0 Then
 dragFlag = True
 pickPoint = X - btmWind.Left
 posOnDrag = trc.pageStart
Else
 shiftSide = IIf(insideBox(lastMouseDn) < 0, -1, 1)
 LargeChange shiftSide
 largeScrollFlag = True
 Tmr.enabled = True
End If
End Sub

Private Sub UserControl_MouseUp(Button As Integer, Shift As Integer, X As Single, y As Single)
If dragFlag Then
 dragFlag = False
 If posOnDrag <> trc.pageStart Then RaiseEvent Change(posOnDrag)
 Else
 stopScroll
End If
End Sub

Private Sub setWind(ByVal pos As Long)
Select Case pos
 Case Is < 0
  btmWind.Left = 0
  posOnDrag = 0
 Case Is > trc.length - btmWind.width
  btmWind.Left = trc.length - btmWind.width
  If pos > (trc.length - trc.pageLength) Then
   posOnDrag = trc.length - trc.pageLength
   Else
   posOnDrag = pos
  End If
 Case Else
  btmWind.Left = pos
  posOnDrag = pos
End Select
End Sub

Private Sub UserControl_MouseMove(Button As Integer, Shift As Integer, X As Single, y As Single)
If Not Me.enable Then Exit Sub
If dragFlag Then setWind X - pickPoint
End Sub

Private Sub UserControl_Paint()
With UserControl
UserControl.Line (.ScaleLeft, .ScaleTop)-(.ScaleLeft + .ScaleWidth, .ScaleTop + .ScaleHeight), &H80000011, B
End With
End Sub

Property Get enable() As Boolean
enable = IIf(trc.length > trc.pageLength, True, False)
End Property

Public Sub Draw()
On Error GoTo err_handle

With UserControl

'вычислить величину сдвига, учитывающего кнопки прокрутки
.ScaleLeft = 0
.ScaleWidth = 10000
btmOffset = btmLeft.width * trc.length / (.ScaleWidth - btmLeft.width - btmRight.width)

.ScaleLeft = 0 - btmOffset
.ScaleWidth = trc.length + 2 * btmOffset
If trc.pageLength > (trc.length / 100) Then
 'If trc.pageLength > trc.length Then dLarge = Me.lscrlLength
 btmWind.width = trc.pageLength
 Else
 btmWind.width = trc.length / 100
End If
End With
posOnDrag = trc.pageStart
setWind posOnDrag
btmLeft.enabled = Me.enable
btmRight.enabled = Me.enable

Exit Sub
err_handle:
ogdWin.Alert "longScroll.Draw error: " & Err.Number & vbNewLine & Err.Description & vbNewLine & Err.Source
End Sub

Private Sub UserControl_Resize()
With UserControl
btmLeft.Left = .ScaleLeft
btmRight.Left = .ScaleLeft + .ScaleWidth - btmRight.width
btmLeft.Top = .ScaleTop
btmRight.Top = .ScaleTop
btmWind.Top = .ScaleTop
btmLeft.Height = .ScaleHeight
btmRight.Height = .ScaleHeight
btmWind.Height = .ScaleHeight
End With

If trc Is Nothing Then Exit Sub

Me.Draw
End Sub

Private Sub UserControl_Initialize()
Tmr.enabled = False
Tmr.Interval = 100
End Sub
