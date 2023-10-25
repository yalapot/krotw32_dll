VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDragMark"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private flg As Boolean
Private WithEvents pic As PictureBox
Attribute pic.VB_VarHelpID = -1

Private lastPoint As Single
Private dragColor As Long
Private bkmrk As Boolean
Private dragInvert As Boolean
Private d_noDraw As Boolean

Public Event Complete(ByVal mrkWhite As Boolean, ByVal newPos As Single)

Property Get noDraw() As Boolean
noDraw = d_noDraw
End Property

Property Let noDraw(i As Boolean)
d_noDraw = i
End Property

Property Get inProgress() As Boolean
inProgress = flg
End Property

Property Get drawColor() As Long
drawColor = dragColor
End Property

Property Let drawColor(c As Long)
dragColor = c
End Property

Property Get drawInvert() As Boolean
drawInvert = dragInvert
End Property

Property Let drawInvert(i As Boolean)
dragInvert = i
End Property

Public Sub Start(picField As PictureBox, ByVal X As Single, ByVal mrkWhite As Boolean)
Dim oldDrawMode As Long

flg = True
Set pic = picField
bkmrk = mrkWhite

If Me.noDraw = False Then
 oldDrawMode = pic.DrawMode
 If Me.drawInvert Then pic.DrawMode = 6
 pic.Line (X, pic.ScaleTop)-(X, pic.ScaleTop + pic.ScaleHeight), Me.drawColor
 pic.DrawMode = oldDrawMode
End If
lastPoint = X
End Sub

Private Sub pic_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim oldDrawMode As Long, cl1 As Long, cl2 As Long

If flg = False Then Exit Sub

If Me.noDraw = False Then
 oldDrawMode = pic.DrawMode
 If Me.drawInvert Then pic.DrawMode = 6
 cl1 = IIf(Me.drawInvert, Me.drawColor, pic.BackColor)
 cl2 = IIf(Me.drawInvert, Me.drawColor, Me.drawColor)
 pic.Line (lastPoint, pic.ScaleTop)-(lastPoint, pic.ScaleTop + pic.ScaleHeight), cl1
 pic.Line (X, pic.ScaleTop)-(X, pic.ScaleTop + pic.ScaleHeight), cl2
 pic.DrawMode = oldDrawMode
End If
lastPoint = X
End Sub

Private Sub pic_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
If flg = False Then Exit Sub
RaiseEvent Complete(bkmrk, X)
flg = False
End Sub
