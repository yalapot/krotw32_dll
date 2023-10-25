VERSION 5.00
Begin VB.UserControl ctrlGrfSimple 
   ClientHeight    =   1515
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3015
   ScaleHeight     =   1515
   ScaleWidth      =   3015
   ToolboxBitmap   =   "GrfSimpl.ctx":0000
   Begin krotw32.ctrlGrfSpec ctrlExt 
      Height          =   735
      Index           =   0
      Left            =   0
      TabIndex        =   1
      Top             =   240
      Width           =   975
      _ExtentX        =   1720
      _ExtentY        =   1296
   End
   Begin VB.Label Label1 
      Caption         =   "Вспомогательные датчики"
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   2175
   End
End
Attribute VB_Name = "ctrlGrfSimple"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private trc As clsTrace
Private resizeFlag As Boolean
Private leftShiftBorder As Single
Private loadedControls As Long
Private parentForm As frmTrace

Public Event mouseMove(ByVal Y As Integer, ByVal X As Long)
Public Event setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
Public Event sizeChange()
Public Event changeMark()

Public Function Init( _
ByVal leftShift As Single, _
frm As frmTrace _
) As Boolean
Dim i As Integer

Init = False

Set parentForm = frm
Set trc = frm.trc

leftShiftBorder = leftShift
ctrlExt(0).Init parentForm, trc.sensExt(0), leftShiftBorder

For i = 1 To trc.numExt - 1
 Load ctrlExt(i)
 ctrlExt(i).Init parentForm, trc.sensExt(i), leftShiftBorder
Next i

loadedControls = i
Init = True
End Function

Private Sub ctrlExt_changeMark(Index As Integer)
RaiseEvent changeMark
End Sub

Private Sub ctrlExt_mouseMove(Index As Integer, ByVal Y As Integer, ByVal X As Long)
RaiseEvent mouseMove(0, X)
End Sub

Private Sub ctrlExt_Off(Index As Integer)
UserControl_Resize
RaiseEvent sizeChange
End Sub

Private Sub ctrlExt_setMark(Index As Integer, ByVal mrkWhite As Boolean, ByVal newPos As Long)
RaiseEvent setMark(mrkWhite, newPos)
End Sub

Private Sub ctrlExt_sizeChange(Index As Integer)
UserControl_Resize
RaiseEvent sizeChange
End Sub

Private Sub UserControl_Initialize()
loadedControls = 0
resizeFlag = False
End Sub

Private Sub UserControl_Resize()
Dim i As Integer, lastTop As Long

If trc Is Nothing Then Exit Sub
If trc.handle = -1 Then Exit Sub
If resizeFlag Then Exit Sub

resizeFlag = True
lastTop = ctrlExt(0).Top
For i = 0 To trc.numExt - 1
 If trc.sensExt(i).visible Then
  ctrlExt(i).Top = lastTop
  ctrlExt(i).width = UserControl.width - ctrlExt(i).Left
  ctrlExt(i).Visible = True
  lastTop = lastTop + ctrlExt(i).Height + 20
  Else
  ctrlExt(i).Visible = False
 End If
Next i

UserControl.Height = lastTop + 20
resizeFlag = False
End Sub

Public Sub Resize()
UserControl_Resize
End Sub

Property Get pixelRight() As Integer
pixelRight = ctrlExt(0).pixelRight
End Property

Property Let pixelRight(p As Integer)
Dim i As Integer

If trc Is Nothing Then Exit Property
If trc.handle = -1 Then Exit Property

For i = 0 To trc.numExt - 1
 ctrlExt(i).pixelRight = p
Next i
End Property

Property Get extSens(ByVal Index As Integer) As ctrlGrfSpec
Set extSens = ctrlExt(Index)
End Property

Public Sub Draw()
Dim i As Integer

If trc Is Nothing Then Exit Sub
If trc.handle = -1 Then Exit Sub

For i = 0 To trc.numExt - 1
 If trc.sensExt(i).visible Then ctrlExt(i).Draw
Next i
End Sub

Public Sub mouseMove(ByVal x As Single)
Dim i As Integer

If trc Is Nothing Then Exit Sub
If trc.handle = -1 Then Exit Sub

For i = 0 To trc.numExt - 1
 ctrlExt(i).mouseMove x
Next i
End Sub