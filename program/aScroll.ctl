VERSION 5.00
Begin VB.UserControl autoScroll 
   ClientHeight    =   255
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1215
   ScaleHeight     =   255
   ScaleWidth      =   1215
   ToolboxBitmap   =   "aScroll.ctx":0000
   Begin VB.TextBox txtSpeed 
      Height          =   285
      Left            =   0
      TabIndex        =   6
      Text            =   "99"
      Top             =   0
      Width           =   263
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   195
      Left            =   1920
      TabIndex        =   0
      Top             =   0
      Width           =   495
   End
   Begin VB.CommandButton btmUp 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   960
      Picture         =   "aScroll.ctx":0312
      Style           =   1  'Graphical
      TabIndex        =   5
      TabStop         =   0   'False
      ToolTipText     =   "Увеличить скорость прокрутки"
      Top             =   0
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.CommandButton btmDn 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   240
      Picture         =   "aScroll.ctx":0414
      Style           =   1  'Graphical
      TabIndex        =   2
      TabStop         =   0   'False
      ToolTipText     =   "Уменьшить скорость прокрутки"
      Top             =   0
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.CommandButton btmLeft 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   480
      Picture         =   "aScroll.ctx":0516
      Style           =   1  'Graphical
      TabIndex        =   3
      TabStop         =   0   'False
      ToolTipText     =   "Прокрутка назад"
      Top             =   0
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.CommandButton btmStop 
      Height          =   255
      Left            =   1440
      Picture         =   "aScroll.ctx":0618
      Style           =   1  'Graphical
      TabIndex        =   1
      TabStop         =   0   'False
      ToolTipText     =   "Стоп"
      Top             =   0
      UseMaskColor    =   -1  'True
      Visible         =   0   'False
      Width           =   495
   End
   Begin VB.CommandButton btmRight 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   720
      Picture         =   "aScroll.ctx":079A
      Style           =   1  'Graphical
      TabIndex        =   4
      TabStop         =   0   'False
      ToolTipText     =   "Прокрутка вперед"
      Top             =   0
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.Timer Timer 
      Enabled         =   0   'False
      Interval        =   10
      Left            =   2400
      Top             =   0
   End
End
Attribute VB_Name = "autoScroll"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private ctlWidth As Single, ctlHeight As Single
Private lastLeft As Boolean
Private speedValue As Integer
Private speedMax As Integer

Public Event asStartLeft()
Public Event asStartRight()
Public Event asStop()
Public Event asScroll(ByVal speed As Integer)
Public Event asSpeed(ByVal speed As Integer)

Private Sub btmDn_Click()
SpeedChange False
End Sub

Private Sub btmUp_Click()
SpeedChange True
End Sub

Private Sub txtSpeed_Change()
ReadTxtSpeed
End Sub

Private Sub UserControl_Initialize()
ctlWidth = UserControl.width
ctlHeight = UserControl.Height
speedValue = 1
speedMax = 99
txtSpeed.Text = speedValue
End Sub

Private Sub UserControl_Resize()
UserControl.width = ctlWidth
UserControl.Height = ctlHeight
End Sub

Private Sub startScroll()
btmLeft.Visible = False
btmRight.Visible = False
btmStop.Left = btmLeft.Left
btmStop.Visible = True
Timer.enabled = True
End Sub

Private Sub btmStop_Click()
asStop
End Sub

Private Sub btmLeft_Click()
lastLeft = True
startScroll
RaiseEvent asStartLeft
End Sub

Private Sub btmRight_Click()
lastLeft = False
startScroll
RaiseEvent asStartRight
End Sub

Private Sub Timer_Timer()
RaiseEvent asScroll(speedValue)
End Sub

Private Sub SpeedChange(ByVal Up As Boolean)
If Up Then
 If speedValue >= speedMax Then Exit Sub
 speedValue = speedValue + 1
 Else
 If speedValue <= 1 Then Exit Sub
 speedValue = speedValue - 1
End If
txtSpeed.Text = speedValue
RaiseEvent asSpeed(speedValue)
End Sub

Property Get asMaxSpeed() As Integer
asMaxSpeed = speedMax
End Property

Property Let asMaxSpeed(m As Integer)
speedMax = m
End Property

Property Get asCurSpeed() As Integer
asCurSpeed = speedValue
End Property

Property Let asCurSpeed(s As Integer)
speedValue = s
txtSpeed.Text = speedValue
End Property

Public Sub asStop()
If UserControl.Extender.Visible = False Then Exit Sub
btmLeft.Visible = True
btmRight.Visible = True
btmStop.Visible = False
Timer.enabled = False

If lastLeft Then
  btmLeft.SetFocus
Else
  btmRight.SetFocus
End If

RaiseEvent asStop
End Sub

Property Get TimerInterval() As Long
TimerInterval = Timer.Interval
End Property

Property Let TimerInterval(t As Long)
Timer.Interval = t
End Property

Public Sub switchScroll()
If btmStop.Visible Then
 asStop
 Else
 If lastLeft Then
  btmLeft_Click
  Else
  btmRight_Click
 End If
End If
End Sub

Private Sub ReadTxtSpeed()
 If txtSpeed.Text = "" Then Exit Sub
 On Error GoTo badSpeed
 speedValue = Int(txtSpeed.Text)
 On Error GoTo 0
 If speedValue >= speedMax Then speedValue = speedMax
 If speedValue <= 1 Then speedValue = 1
 
 RaiseEvent asSpeed(speedValue)
 Exit Sub
 
badSpeed:
End Sub
