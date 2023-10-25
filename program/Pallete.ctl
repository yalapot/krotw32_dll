VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.UserControl ctrlPallete 
   ClientHeight    =   750
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3675
   ScaleHeight     =   750
   ScaleWidth      =   3675
   Begin VB.PictureBox pic 
      Appearance      =   0  'Flat
      BackColor       =   &H00FF0000&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   135
      Left            =   600
      ScaleHeight     =   135
      ScaleWidth      =   2445
      TabIndex        =   0
      Top             =   120
      Width           =   2445
   End
   Begin MSComctlLib.Slider sldUpBorder 
      Height          =   255
      Left            =   480
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   0
      Width           =   2685
      _ExtentX        =   4736
      _ExtentY        =   450
      _Version        =   393216
      TickStyle       =   3
   End
   Begin MSComctlLib.Slider sldDnBorder 
      Height          =   255
      Left            =   480
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   240
      Width           =   2685
      _ExtentX        =   4736
      _ExtentY        =   450
      _Version        =   393216
      TickStyle       =   3
   End
   Begin VB.Label labPalDn 
      Caption         =   "Label1"
      Height          =   255
      Left            =   3240
      TabIndex        =   6
      ToolTipText     =   "Минимальный уровень сигнала"
      Top             =   240
      Width           =   495
   End
   Begin VB.Label labPalUp 
      Caption         =   "Label1"
      Height          =   255
      Left            =   3240
      TabIndex        =   5
      ToolTipText     =   "Максимальный уровень сигнала"
      Top             =   0
      Width           =   495
   End
   Begin VB.Label labDnBorder 
      Caption         =   "200"
      Height          =   255
      Left            =   0
      TabIndex        =   4
      ToolTipText     =   "Нижняя граница палитры"
      Top             =   240
      Width           =   495
   End
   Begin VB.Label labUpBorder 
      Caption         =   "Label1"
      Height          =   255
      Left            =   0
      TabIndex        =   3
      ToolTipText     =   "Верхняя граница палитры"
      Top             =   0
      Width           =   495
   End
End
Attribute VB_Name = "ctrlPallete"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const BRD_COLOR = &H8000000E

Private trc As clsTrace
Private crz As clsCoroz

Private w_delta As Single
Private scrollFlag As Boolean

Public Event Change()

Public Sub Init(trace As clsTrace, Coroz As clsCoroz)
Set trc = trace
Set crz = Coroz

scrollFlag = False
pic.DrawMode = vbInvert

With crz.palette

sldUpBorder.Min = .datMin
sldUpBorder.Max = .datMax
sldUpBorder.LargeChange = (.datMax - .datMin) / 10 + 1
sldUpBorder.SmallChange = 1
sldUpBorder.Value = .usrMax

sldDnBorder.Min = .datMin
sldDnBorder.Max = .datMax
sldDnBorder.LargeChange = (.datMax - .datMin) / 10 + 1
sldDnBorder.SmallChange = 1
sldDnBorder.Value = .datMin
sldDnBorder.Value = .usrMin

End With

UserControl_Resize
setPosition
End Sub

Public Sub Draw()
If trc Is Nothing Then Exit Sub
If UserControl.Extender.visible = False Then Exit Sub

With crz.palette

If .Draw(pic.hWnd) = False Then
 ogdWin.Alert "Ошибка отрисовки палитры." & vbNewLine & .errText
End If

pic.Line (.usrMin, pic.ScaleTop)-(.usrMin, pic.ScaleTop + pic.ScaleHeight), BRD_COLOR
pic.Line (.usrMax, pic.ScaleTop)-(.usrMax, pic.ScaleTop + pic.ScaleHeight), BRD_COLOR

labPalUp.caption = .datMax
labPalDn.caption = .datMin
labUpBorder.caption = .usrMax
labDnBorder.caption = .usrMin

pic.ToolTipText = "Используемая палитра " & .file

End With

End Sub

Private Sub setPosition()
crz.palette.usrMax = sldUpBorder.Value
crz.palette.usrMin = sldDnBorder.Value
If crz.palette.setData() = False Then
 ogdWin.Alert "Ошибка при установке палитры." & vbNewLine & crz.palette.errText
End If
End Sub

Property Get shiftSmall() As Integer
shiftSmall = sldUpBorder.SmallChange
End Property

Property Let shiftSmall(s As Integer)
sldUpBorder.SmallChange = s
sldDnBorder.SmallChange = s
End Property

Property Get shiftPage() As Integer
shiftPage = sldUpBorder.LargeChange
End Property

Property Let shiftPage(s As Integer)
sldUpBorder.LargeChange = s
sldDnBorder.LargeChange = s
End Property

Private Sub labDnBorder_Click()
Dim s As String

s = InputBox("Нижняя граница палитры", "Введите границу палитры", crz.palette.usrMin)
If Len(s) > 0 Then
  sldDnBorder.Value = val(s)
  setPosition
  RaiseEvent Change
End If
End Sub

Private Sub labUpBorder_Click()
Dim s As String

s = InputBox("Верхняя граница палитры", "Введите границу палитры", crz.palette.usrMax)
If Len(s) > 0 Then
  sldUpBorder.Value = val(s)
  setPosition
  RaiseEvent Change
End If
End Sub

Private Sub pic_DblClick()
sldUpBorder.Value = crz.palette.maxVal
sldDnBorder.Value = crz.palette.minVal
setPosition
RaiseEvent Change
End Sub

Private Sub Pic_Paint()
Draw
End Sub

Private Sub sldDnBorder_Change()
If scrollFlag = False Then Exit Sub
scrollFlag = False
RaiseEvent Change
End Sub

Private Sub sldUpBorder_Change()
If scrollFlag = False Then Exit Sub
scrollFlag = False
RaiseEvent Change
End Sub

Private Sub sldUpBorder_Scroll()
If sldUpBorder.Value < sldDnBorder.Value Then
 sldUpBorder.Value = sldDnBorder.Value
End If
setPosition
scrollFlag = True
End Sub

Private Sub sldDnBorder_Scroll()
If sldDnBorder.Value > sldUpBorder.Value Then
 sldDnBorder.Value = sldUpBorder.Value
End If
setPosition
scrollFlag = True
End Sub

Property Get picHwnd() As Long
picHwnd = pic.hWnd
End Property

Private Sub UserControl_Initialize()
w_delta = sldUpBorder.width - pic.width
End Sub

Private Sub UserControl_Resize()
Static intFlag As Boolean

If intFlag Then Exit Sub

intFlag = True

labPalUp.Left = UserControl.width - labPalUp.width
labPalDn.Left = labPalUp.Left
pic.width = labPalUp.Left - pic.Left - w_delta

sldUpBorder.width = pic.width + w_delta
sldDnBorder.width = pic.width + w_delta

intFlag = False

If trc Is Nothing Then Exit Sub
pic.ScaleLeft = crz.palette.datMin
pic.ScaleWidth = crz.palette.datMax
End Sub
