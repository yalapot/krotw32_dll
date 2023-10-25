VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsZoom"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private Const WINDOW_COLOR = &HFFFFFF

Private x1 As Single
Private y1 As Single
Private x2 As Single
Private y2 As Single
Private pic As PictureBox
Private flg As Boolean
Private oldMouse As Integer
Private oldDrawMode As Integer

Property Get inProgress() As Boolean
inProgress = flg
End Property

Public Sub Finish()
pic.Line (x1, y1)-(x2, y2), WINDOW_COLOR, B
flg = False
pic.MousePointer = oldMouse
pic.DrawMode = oldDrawMode
End Sub

Public Sub Start(picZoom As PictureBox, X As Single, Y As Single)
Set pic = picZoom
oldMouse = pic.MousePointer
oldDrawMode = pic.DrawMode
pic.DrawMode = 6 'Invert
flg = True
x1 = X
y1 = Y
x2 = X
y2 = Y
pic.Line (X, Y)-(X, Y), WINDOW_COLOR, B
pic.MousePointer = 2 'Cross
End Sub

Private Function Adjust_X(ByVal X As Single) As Single
If X < pic.ScaleLeft Then X = pic.ScaleLeft
If X > (pic.ScaleLeft + pic.ScaleWidth) Then X = pic.ScaleLeft + pic.ScaleWidth
Adjust_X = X
End Function

Private Function Adjust_Y(ByVal Y As Single) As Single
If pic.ScaleHeight > 0 Then
 If Y < pic.ScaleTop Then Y = pic.ScaleTop
 If Y > pic.ScaleTop + pic.ScaleHeight Then Y = pic.ScaleTop + pic.ScaleHeight - 1
 Else
 If Y > pic.ScaleTop Then Y = pic.ScaleTop
 If Y < pic.ScaleTop - Abs(pic.ScaleHeight) Then Y = pic.ScaleTop - Abs(pic.ScaleHeight) + 1
End If
Adjust_Y = Y
End Function

Public Sub Continue(X As Single, Y As Single)
Y = Adjust_Y(Y)
X = Adjust_X(X)
pic.Line (x1, y1)-(x2, y2), WINDOW_COLOR, B
pic.Line (x1, y1)-(X, Y), WINDOW_COLOR, B
x2 = X
y2 = Y
End Sub

Public Sub Coords(ByRef xBase As Single, ByRef yBase As Single, ByRef xZoom As Single, ByRef yZoom As Single)
If x1 > x2 Then
 xBase = x2
 xZoom = x1
 Else
 xBase = x1
 xZoom = x2
End If
If y1 > y2 Then
 yBase = y2
 yZoom = y1
 Else
 yBase = y1
 yZoom = y2
End If
End Sub

Property Get startX() As Single
startX = x1
End Property

Property Get startY() As Single
startY = y1
End Property
