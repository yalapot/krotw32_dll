VERSION 5.00
Begin VB.UserControl multyNum 
   ClientHeight    =   870
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1785
   ScaleHeight     =   870
   ScaleWidth      =   1785
   ToolboxBitmap   =   "multyNum.ctx":0000
   Begin VB.HScrollBar scrlMulty 
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   975
   End
   Begin VB.Label MultyLab 
      Caption         =   "9999"
      Height          =   255
      Left            =   1000
      TabIndex        =   1
      Top             =   0
      Width           =   420
   End
End
Attribute VB_Name = "multyNum"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private resizeFlag As Boolean
Public Event Change(m As Integer)

Property Get ToolTipText() As String
ToolTipText = MultyLab.ToolTipText
End Property

Property Let ToolTipText(m As String)
MultyLab.ToolTipText = m
End Property

Property Get Value() As Integer
Value = scrlMulty.Value
End Property

Property Let Value(m As Integer)
If m > scrlMulty.Max Then m = scrlMulty.Max
scrlMulty.Value = m
End Property

Property Get SmallChange() As Integer
SmallChange = scrlMulty.SmallChange
End Property

Property Let SmallChange(m As Integer)
scrlMulty.SmallChange = m
End Property

Property Get LargeChange() As Integer
LargeChange = scrlMulty.LargeChange
End Property

Property Let LargeChange(m As Integer)
scrlMulty.LargeChange = m
End Property

Property Get Min() As Integer
Min = scrlMulty.Min
End Property

Property Let Min(m As Integer)
scrlMulty.Min = m
End Property

Property Get Max() As Integer
Max = scrlMulty.Max
End Property

Property Let Max(m As Integer)
scrlMulty.Max = m
End Property

Private Sub scrlMulty_Change()
MultyLab.Caption = scrlMulty.Value
RaiseEvent Change(scrlMulty.Value)
End Sub

Private Sub scrlMulty_Scroll()
MultyLab.Caption = scrlMulty.Value
End Sub

Private Sub UserControl_Initialize()
resizeFlag = False
scrlMulty.Min = 1
scrlMulty.Max = 100
scrlMulty.LargeChange = 10
scrlMulty.SmallChange = 1
scrlMulty.Value = 1
MultyLab.Caption = scrlMulty.Value
MultyLab.ToolTipText = ""
End Sub

Private Sub UserControl_Resize()
If resizeFlag Then Exit Sub
resizeFlag = True
UserControl.Height = scrlMulty.Height
UserControl.width = MultyLab.Left + MultyLab.width
resizeFlag = False
End Sub