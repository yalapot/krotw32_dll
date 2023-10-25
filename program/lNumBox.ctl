VERSION 5.00
Begin VB.UserControl ctrlNumBox 
   ClientHeight    =   390
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1965
   ScaleHeight     =   390
   ScaleWidth      =   1965
   Begin VB.TextBox txt 
      Alignment       =   1  'Right Justify
      Height          =   285
      Left            =   0
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   0
      Width           =   1815
   End
End
Attribute VB_Name = "ctrlNumBox"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Sub UserControl_Resize()
txt.width = UserControl.width
txt.Height = UserControl.Height
End Sub

Property Get dbl() As Double
dbl = Val(txt.Text)
End Property

Property Let dbl(m As Double)
txt.Text = dblStr(m)
End Property

Property Get intgr() As Long
intgr = Val(txt.Text)
End Property

Property Let intgr(m As Long)
txt.Text = str(m)
End Property

Property Get mm() As Long
mm = Val(txt.Text) * 1000
End Property

Property Let mm(m As Long)
txt.Text = mm2txt(m)
End Property

Property Get enabled() As Boolean
enabled = txt.enabled
End Property

Property Let enabled(e As Boolean)
txt.enabled = e
End Property

Property Get SelStart() As Long
SelStart = txt.SelStart
End Property

Property Let SelStart(s As Long)
txt.SelStart = s
End Property

Property Get SelLength() As Long
SelLength = txt.SelLength
End Property

Property Let SelLength(s As Long)
txt.SelLength = s
End Property

Public Sub selText()
txt.SelStart = 0
txt.SelLength = Len(txt.Text)
End Sub
