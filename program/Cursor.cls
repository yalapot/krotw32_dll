VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsCursor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum CURS_TYPE
CURS_USER
CURS_USER_NORMAL
CURS_NORMAL
CURS_WINCROSS
CURS_SELWHITE
CURS_SELBLACK
End Enum

Public Enum CURS_UTYPE
USR_BIGCROSS
USR_VLINE
USR_HLINE
End Enum

'Private Const CURS_COLOR = &H8000000E было так
Private Const CURS_COLOR = &H80000011

Private oldX As Single
Private oldY As Single
Private eraseFlag As Boolean
Private cType As CURS_TYPE
Private pic As PictureBox

Private oldUType As CURS_UTYPE
Public uType As CURS_UTYPE

Public Sub Init(p As PictureBox, u As CURS_UTYPE)
Set pic = p
uType = u
End Sub

Property Get cursType() As CURS_TYPE
cursType = cType
End Property

Property Let cursType(c As CURS_TYPE)
If c = cType Then Exit Property
If (cType = CURS_USER) And (c <> CURS_USER) Then Me.needErase = True
Select Case c
 Case CURS_USER
  pic.MouseIcon = LoadResPicture(EMPTY_CURSOR, vbResCursor)
  pic.MousePointer = vbCustom
 Case CURS_USER_NORMAL
  pic.MousePointer = vbDefault
 Case CURS_WINCROSS
  pic.MousePointer = vbCrosshair
 Case CURS_NORMAL
  pic.MousePointer = vbDefault
 Case CURS_SELWHITE
  pic.MouseIcon = LoadResPicture(WHITE_CURSOR, vbResCursor)
  pic.MousePointer = vbCustom
 Case CURS_SELBLACK
  pic.MouseIcon = LoadResPicture(BLACK_CURSOR, vbResCursor)
  pic.MousePointer = vbCustom
End Select
cType = c
End Property

Property Get needErase() As Boolean
needErase = eraseFlag
End Property

Property Let needErase(f As Boolean)
eraseFlag = f
End Property

Public Sub Draw(ByVal X As Single, ByVal Y As Single)
If Me.needErase Then
 drawUserCursor oldX, oldY, oldUType
 Me.needErase = False
End If

Select Case cType
 Case CURS_USER, CURS_USER_NORMAL
  drawUserCursor X, Y, uType
  Me.needErase = True
End Select

oldUType = uType
oldX = X
oldY = Y
End Sub

Private Sub drawUserCursor(ByVal X As Single, ByVal Y As Single, ByVal userType As CURS_UTYPE)
Dim oldMode As Integer

oldMode = pic.DrawMode
pic.drawMode = vbXorPen
On Error Resume Next
If userType = USR_HLINE Then
    pic.Line (pic.ScaleLeft, Y)-(pic.ScaleLeft + pic.ScaleWidth, Y), CURS_COLOR
Else
    pic.Line (X, pic.ScaleTop)-(X, pic.ScaleTop + pic.ScaleHeight), CURS_COLOR
End If
If userType = USR_BIGCROSS Then
 pic.Line (pic.ScaleLeft, Y)-(pic.ScaleLeft + pic.ScaleWidth, Y), CURS_COLOR
End If
pic.DrawMode = oldMode
End Sub
