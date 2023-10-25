VERSION 5.00
Begin VB.UserControl ctrlSlit 
   ClientHeight    =   405
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3525
   ScaleHeight     =   405
   ScaleWidth      =   3525
   Begin VB.CommandButton btmPick 
      Caption         =   "Выбор"
      Height          =   375
      Left            =   2520
      TabIndex        =   2
      ToolTipText     =   "Задать ориентацию шва указанием точки на корозионной развертке"
      Top             =   0
      Width           =   975
   End
   Begin VB.CheckBox chkPresent 
      Caption         =   "Первый"
      Height          =   255
      Left            =   0
      TabIndex        =   1
      ToolTipText     =   "Переключатель наличия / отсутствия продольного шва"
      Top             =   0
      Width           =   975
   End
   Begin krotw32.ctrlAnglUnit ornt 
      Height          =   330
      Left            =   1080
      TabIndex        =   0
      ToolTipText     =   "Ориентация продольного шва"
      Top             =   0
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   582
   End
End
Attribute VB_Name = "ctrlSlit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private orn As New clsAnglUnit
Private initFlag As Boolean

Public Event pickUp()
Public Event Change()

Property Get isPresent() As Boolean
isPresent = IIf(chkPresent.Value = 0, False, True)
End Property

Property Let isPresent(p As Boolean)
chkPresent.Value = IIf(p, 1, 0)
End Property

Property Get fullHour() As Double
fullHour = IIf(chkPresent.Value = 0, -1, orn.fullHour)
End Property

Property Let fullHour(f As Double)
If orn.fullHour = f Then Exit Property
orn.fullHour = f
ornt.setValue orn
End Property

Property Get Caption() As String
Caption = chkPresent.Caption
End Property

Property Let Caption(c As String)
chkPresent.Caption = c
End Property

Public Sub selectSlit()
If chkPresent.Value = 0 Then chkPresent.Value = 1
btmPick_Click
End Sub

Private Sub btmPick_Click()
If initFlag Then Exit Sub
RaiseEvent pickUp
End Sub

Private Sub chkPresent_Click()
If chkPresent.Value = 0 Then
 ornt.Visible = False
 btmPick.Visible = False
 Else
 ornt.Visible = True
 btmPick.Visible = True
 btmPick_Click
End If
RaiseEvent Change
End Sub

Private Sub ornt_Change(a As clsAnglUnit)
If Me.isPresent Then
  orn.fullHour = a.fullHour
  RaiseEvent Change
End If
End Sub

Private Sub UserControl_Resize()
UserControl.Height = 405
UserControl.width = 3525
End Sub

Private Sub UserControl_Show()
initFlag = True
chkPresent_Click
initFlag = False
End Sub
