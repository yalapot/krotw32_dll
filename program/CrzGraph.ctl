VERSION 5.00
Begin VB.UserControl ctrlCorozGraph 
   ClientHeight    =   495
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3195
   ScaleHeight     =   495
   ScaleWidth      =   3195
   Begin VB.CheckBox btmGraph 
      DownPicture     =   "CrzGraph.ctx":0000
      Height          =   375
      Left            =   0
      Picture         =   "CrzGraph.ctx":0442
      Style           =   1  'Graphical
      TabIndex        =   2
      Top             =   50
      Width           =   495
   End
   Begin krotw32.multyNum kMul 
      Height          =   255
      Left            =   1800
      TabIndex        =   0
      ToolTipText     =   "Коэффициент усиления сигналов датчиков"
      Top             =   240
      Width           =   1335
      _ExtentX        =   2434
      _ExtentY        =   450
   End
   Begin krotw32.multyNum kSens 
      Height          =   255
      Left            =   1800
      TabIndex        =   1
      ToolTipText     =   "Коэффициент прореживания числа датчиков"
      Top             =   0
      Width           =   1335
      _ExtentX        =   2434
      _ExtentY        =   450
   End
   Begin VB.Label labKSens 
      Caption         =   "прореживание"
      Height          =   255
      Left            =   600
      TabIndex        =   4
      Top             =   0
      Width           =   1215
   End
   Begin VB.Label labKMul 
      Caption         =   "усиление"
      Height          =   255
      Left            =   600
      TabIndex        =   3
      Top             =   240
      Width           =   1215
   End
End
Attribute VB_Name = "ctrlCorozGraph"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Event paramChange()
Public Event OnOff()

Property Get isOn() As Boolean
If btmGraph.Value = 1 Then isOn = True
End Property

Property Let isOn(v As Boolean)
btmGraph.Value = IIf(v, 1, 0)
End Property

Private Sub switchOn()
btmGraph.ToolTipText = IIf(Me.isOn, _
 "Показать развертку цветом", _
 "Показать развертку в виде графиков" _
)
UserControl_Resize
RaiseEvent OnOff
End Sub

Private Sub btmGraph_Click()
switchOn
End Sub

Private Sub kMul_Change(m As Integer)
RaiseEvent paramChange
End Sub

Private Sub kSens_Change(m As Integer)
RaiseEvent paramChange
End Sub

Private Sub UserControl_Resize()
Static flg As Boolean

If flg Then Exit Sub
flg = True
UserControl.Height = kMul.Top + kMul.Height
If Me.isOn Then
 UserControl.width = kMul.Left + kMul.width
 Else
 UserControl.width = btmGraph.Left + btmGraph.width
End If
flg = False
End Sub

Property Get gapMin() As Integer
gapMin = kSens.Min
End Property

Property Let gapMin(g As Integer)
kSens.Min = g
End Property

Property Get gapMax() As Integer
gapMax = kSens.Max
End Property

Property Let gapMax(g As Integer)
kSens.Max = g
End Property

Property Get gap() As Integer
gap = kSens.Value
End Property

Property Let gap(k As Integer)
kSens.Value = k
End Property

Property Get amplifMin() As Integer
amplifMin = kMul.Min
End Property

Property Let amplifMin(a As Integer)
kMul.Min = a
End Property

Property Get amplifMax() As Integer
amplifMax = kMul.Max
End Property

Property Let amplifMax(a As Integer)
kMul.Max = a
End Property

Property Get amplif() As Integer
amplif = kMul.Value
End Property

Property Let amplif(k As Integer)
kMul.Value = k
End Property
