VERSION 5.00
Begin VB.UserControl rotateAngle 
   ClientHeight    =   1170
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1605
   ScaleHeight     =   1170
   ScaleWidth      =   1605
   ToolboxBitmap   =   "rotAngle.ctx":0000
   Begin VB.TextBox editBox 
      Height          =   285
      Left            =   480
      TabIndex        =   2
      Text            =   "Text1"
      Top             =   240
      Visible         =   0   'False
      Width           =   495
   End
   Begin VB.PictureBox picRotAngle 
      AutoRedraw      =   -1  'True
      Height          =   495
      Left            =   0
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   0
      Top             =   0
      Width           =   495
   End
   Begin VB.Label labRotAngle 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      Height          =   255
      Left            =   480
      TabIndex        =   1
      Top             =   0
      Width           =   495
   End
End
Attribute VB_Name = "rotateAngle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private t_angle As Double
Public Event Change(ByVal ang As Double)

Private Sub picRotAngle_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim cX As Single, cY As Single

'вычислить координаты центра и радиус
cX = picRotAngle.ScaleWidth / 2
cY = picRotAngle.ScaleHeight / 2
t_angle = getAngle(cX, cY, X, Y)
redraw
RaiseEvent Change(t_angle)
End Sub

Private Sub labRotAngle_DblClick()
editBox.Left = labRotAngle.Left
editBox.width = labRotAngle.width
editBox.Top = labRotAngle.Top
editBox.Height = labRotAngle.Height
editBox.Text = labRotAngle.Caption
editBox.Visible = True
editBox.SetFocus
editBox.SelStart = 0
editBox.SelLength = Len(editBox.Text)
End Sub

Private Sub editBox_KeyPress(KeyAscii As Integer)
Dim a As Integer, a1 As Double
Select Case KeyAscii
 Case 13
  a = Val(editBox.Text)
  a = a Mod 360
  a1 = a * PI / 180#
  t_angle = a1
  editBox.Visible = False
  redraw
  RaiseEvent Change(t_angle)
 Case 27
  editBox.Visible = False
End Select
End Sub

Property Get angle() As Double
angle = t_angle
End Property

Property Let angle(a As Double)
t_angle = a
redraw
RaiseEvent Change(t_angle)
End Property

Private Sub redraw()
Dim cX As Single, cY As Single, r As Single, angl As Double

'вычислить координаты центра и радиус
cX = picRotAngle.ScaleWidth / 2
cY = picRotAngle.ScaleHeight / 2
r = picRotAngle.ScaleHeight / 2

picRotAngle.Cls
'нарисовать круг
picRotAngle.ForeColor = 0
picRotAngle.DrawMode = 13
picRotAngle.DrawWidth = 3
picRotAngle.Circle (cX, cY), r - 20, 0
'нарисовать вертикальный радиус
picRotAngle.DrawWidth = 1
picRotAngle.Line (cX, cY)-(cX, cY - r), 0
'нарисовать радиус, показывающий текущий поворот
angl = -t_angle - (PI / 2)
picRotAngle.Line (cX, cY)-(cX + r * Cos(angl), cY + r * sIn(angl)), &HFF&

labRotAngle.Caption = Fix(t_angle * (180# / PI))
End Sub

Private Function getAngle( _
ByVal x0 As Single, _
ByVal y0 As Single, _
ByVal X As Single, _
ByVal Y As Single _
) As Double

Dim a As Double

X = X - x0
Y = y0 - Y

a = X / Sqr(X * X + Y * Y)
a = Atn(-a / Sqr(-a * a + 1)) + 2 * Atn(1)

Select Case GetQuadrant(X, Y)
 Case 3, 4
  a = 2 * PI - a
End Select

If (a >= 0) And (a <= (PI / 2)) Then
 a = a + 2 * PI
End If
    
getAngle = a - PI / 2
End Function

Private Function GetQuadrant( _
ByVal X As Single, _
ByVal Y As Single _
) As Integer

If (X >= 0) And (Y >= 0) Then
 GetQuadrant = 1
 Exit Function
End If

If (X < 0) And (Y >= 0) Then
 GetQuadrant = 2
 Exit Function
End If
    
If (X < 0) And (Y < 0) Then
 GetQuadrant = 3
 Exit Function
End If

GetQuadrant = 4

End Function

Public Sub setRotAngle()
labRotAngle_DblClick
End Sub

Private Sub UserControl_Initialize()
t_angle = 0
End Sub

Private Sub UserControl_Resize()
UserControl.Height = picRotAngle.Height
UserControl.width = labRotAngle.Left + labRotAngle.width
End Sub
