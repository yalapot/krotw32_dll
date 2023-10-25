VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Begin VB.UserControl ctrlAnglUnit 
   ClientHeight    =   1335
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3045
   ScaleHeight     =   1335
   ScaleWidth      =   3045
   Begin ComctlLib.Slider sldHour 
      Height          =   135
      Left            =   0
      TabIndex        =   4
      Top             =   200
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   238
      _Version        =   327682
      LargeChange     =   2
      Max             =   11
      TickStyle       =   3
   End
   Begin ComctlLib.Slider sldMinute 
      Height          =   135
      Left            =   720
      TabIndex        =   5
      Top             =   200
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   238
      _Version        =   327682
      LargeChange     =   10
      Max             =   59
      TickStyle       =   3
   End
   Begin VB.Label labMinuteUnit 
      Caption         =   "мин"
      Height          =   255
      Left            =   1080
      TabIndex        =   3
      Top             =   0
      Width           =   375
   End
   Begin VB.Label labHourUnit 
      Caption         =   "час"
      Height          =   255
      Left            =   360
      TabIndex        =   2
      Top             =   0
      Width           =   255
   End
   Begin VB.Label labMinute 
      Caption         =   "00"
      Height          =   255
      Left            =   720
      TabIndex        =   1
      Top             =   0
      Width           =   255
   End
   Begin VB.Label labHour 
      Caption         =   "00"
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   255
   End
End
Attribute VB_Name = "ctrlAnglUnit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum T_ANGLE_UNIT
 A_HOUR
 A_DEGREE
End Enum

Private d_typ As T_ANGLE_UNIT
Private angl As clsAnglUnit
Private initFlag As Boolean

Public Event Change(a As clsAnglUnit)

Property Get typ() As T_ANGLE_UNIT
typ = d_typ
End Property

Property Let typ(t As T_ANGLE_UNIT)
d_typ = t
Select Case d_typ
 Case A_HOUR
  labHourUnit.Caption = "час"
  labMinuteUnit.Caption = "мин"
  sldHour.Min = 0
  sldHour.Max = 11
 Case A_DEGREE
  labHourUnit.Caption = "гр"
  labMinuteUnit.Caption = "мин"
  sldHour.Min = 0
  sldHour.Max = 89
End Select
sldMinute.Min = 0
sldMinute.Max = 59
End Property

Private Sub sldHour_Change()
Dim h As Integer

Select Case d_typ

 Case A_HOUR
  If Not initFlag Then angl.dHour = sldHour.Value
  h = angl.dHour
  If h = 0 Then h = 12
  labHour.Caption = h

 Case A_DEGREE
  If Not initFlag Then angl.degreeInt = sldHour.Value
  labHour.Caption = angl.degreeInt

End Select
RaiseEvent Change(angl)
End Sub

Private Sub sldHour_Scroll()
sldHour_Change
End Sub

Private Sub sldMinute_Change()

Select Case d_typ

 Case A_HOUR
  If Not initFlag Then angl.dMinute = sldMinute.Value
  labMinute.Caption = Format$(angl.dMinute, "00")

 Case A_DEGREE
  If Not initFlag Then angl.degreeMinute = sldMinute.Value
  labMinute.Caption = Format$(angl.degreeMinute, "00")

End Select
RaiseEvent Change(angl)
End Sub

Private Sub sldMinute_Scroll()
sldMinute_Change
End Sub

Private Sub UserControl_Initialize()
Set angl = New clsAnglUnit
angl.fullHour = 12
Me.typ = A_HOUR
initFlag = False
End Sub

Private Sub UserControl_Resize()
Static intFlag As Boolean

If intFlag Then Exit Sub
intFlag = True

UserControl.width = sldMinute.Left + sldMinute.width
UserControl.Height = sldMinute.Top + sldMinute.Height

intFlag = False
End Sub

Public Sub setValue(a As clsAnglUnit)
Set angl = a
initFlag = True
With angl

Select Case d_typ

 Case A_HOUR
  sldHour.Value = .dHour
  sldMinute.Value = .dMinute

 Case A_DEGREE
  sldHour.Value = .degreeInt
  sldMinute.Value = .degreeMinute

End Select

End With
initFlag = False
End Sub
