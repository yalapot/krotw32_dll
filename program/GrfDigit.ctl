VERSION 5.00
Begin VB.UserControl ctrlGrfDigit 
   ClientHeight    =   615
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   5700
   ScaleHeight     =   615
   ScaleWidth      =   5700
   ToolboxBitmap   =   "GrfDigit.ctx":0000
   Begin VB.Label valStart 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      Height          =   255
      Index           =   0
      Left            =   0
      TabIndex        =   1
      ToolTipText     =   "начало участка"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label valEnd 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      Height          =   255
      Index           =   0
      Left            =   4800
      TabIndex        =   3
      ToolTipText     =   "конец участка"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label valCurrent 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      Height          =   255
      Index           =   0
      Left            =   960
      TabIndex        =   2
      ToolTipText     =   "под курсором"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label labName 
      Caption         =   "Label1"
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   1455
   End
   Begin VB.Label markWhite 
      Alignment       =   1  'Right Justify
      BackColor       =   &H8000000E&
      Caption         =   "500000.00"
      Height          =   255
      Index           =   0
      Left            =   1920
      TabIndex        =   4
      ToolTipText     =   "на белом маркере"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label markDiff 
      Alignment       =   1  'Right Justify
      Caption         =   "500000.00"
      Height          =   255
      Index           =   0
      Left            =   2880
      TabIndex        =   5
      ToolTipText     =   "разница по маркерам"
      Top             =   240
      Width           =   855
   End
   Begin VB.Label markBlack 
      Alignment       =   1  'Right Justify
      BackColor       =   &H80000008&
      Caption         =   "500000.00"
      ForeColor       =   &H8000000E&
      Height          =   255
      Index           =   0
      Left            =   3840
      TabIndex        =   6
      ToolTipText     =   "на черном маркере"
      Top             =   240
      Width           =   855
   End
End
Attribute VB_Name = "ctrlGrfDigit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private trc As clsTrace
Private sens As clsSensor

Private resizeFlag As Boolean
Private pixRight As Integer

Public Function Init( _
trace As clsTrace, _
sensor As clsSensor _
) As Boolean

Dim i As Integer

Init = False

Set trc = trace
Set sens = sensor
labName.Caption = sens.name

For i = 1 To sens.num - 1
 Load valStart(i)
 Load valCurrent(i)
 Load valEnd(i)
 Load markWhite(i)
 Load markBlack(i)
 Load markDiff(i)
 valStart(i).ForeColor = color.clrIndx(i)
 valCurrent(i).ForeColor = color.clrIndx(i)
 valEnd(i).ForeColor = color.clrIndx(i)
Next i
Init = True
End Function

Private Sub UserControl_Initialize()
pixRight = 0
resizeFlag = False
markWhite(0).BackColor = color.markWhite
markBlack(0).BackColor = color.markBlack
End Sub

Private Sub UserControl_Resize()
Dim visCount As Integer, i As Integer, lastVal As Long

If resizeFlag Then Exit Sub
If trc Is Nothing Then Exit Sub
If trc.handle = -1 Then Exit Sub

resizeFlag = True

visCount = 0
lastVal = valStart(0).Top

For i = 0 To sens.num - 1
 If sens.line(i).visible Then
  valStart(i).Top = lastVal
  valCurrent(i).Top = lastVal
  valEnd(i).Top = lastVal
  markWhite(i).Top = lastVal
  markBlack(i).Top = lastVal
  markDiff(i).Top = lastVal

  valEnd(i).Left = UserControl.width - valEnd(i).width - pixRight * Screen.twipsPerPixelX

  valStart(i).visible = True
  valCurrent(i).visible = True
  valEnd(i).visible = True
  markBlack(i).visible = True
  markDiff(i).visible = True
  markWhite(i).visible = True
  lastVal = valStart(i).Top + valStart(0).Height
  visCount = visCount + 1
  Else
  valStart(i).visible = False
  valCurrent(i).visible = False
  valEnd(i).visible = False
 End If
Next i

UserControl.Height = valStart(0).Top + visCount * valStart(0).Height + 20
resizeFlag = False
End Sub

Public Sub Draw()
Dim i As Integer, w As Long, b As Long

For i = 0 To sens.num - 1
 valStart(i).Caption = getVal(trc.pageStart, i)
 valCurrent(i).Caption = getVal(trc.pageStart, i)
 valEnd(i).Caption = getVal(trc.pageStart + trc.pageLength, i)
 markWhite(i).Caption = getVal(trc.mark.white, i)
 markBlack(i).Caption = getVal(trc.mark.black, i)
 markDiff(i).Caption = dispVal((sens.getVal(trc.mark.black, i - 1) - sens.getVal(trc.mark.white, i - 1)))
Next i
End Sub

Public Sub mouseMove(ByVal x As Long)
Dim i As Integer

For i = 0 To sens.num - 1
 valCurrent(i).Caption = getVal(x, i)
Next i
End Sub

Private Function dispVal(ByVal x As Long) As String
dispVal = intDblStr(x, 3, 3)
End Function

Private Function getVal(ByVal x As Long, ByVal indx As Integer) As String
getVal = dispVal(sens.getVal(x, indx - 1))
End Function

Public Sub Resize()
UserControl_Resize
End Sub

Property Get pixelRight() As Integer
pixelRight = pixRight
End Property

Property Let pixelRight(p As Integer)
pixRight = p
UserControl_Resize
End Property

Property Get Height() As Single
Height = UserControl.Extender.Height
End Property

Property Get Top() As Single
Top = UserControl.Extender.Top
End Property

Property Let Top(t As Single)
UserControl.Extender.Top = t
End Property

Property Get Left() As Single
Left = UserControl.Extender.Left
End Property

Property Let Left(t As Single)
UserControl.Extender.Left = t
End Property

Property Get width() As Single
width = UserControl.Extender.width
End Property

Property Let width(t As Single)
UserControl.Extender.width = t
End Property

Property Get visible() As Boolean
visible = UserControl.Extender.visible
End Property

Property Let visible(t As Boolean)
UserControl.Extender.visible = t
End Property
