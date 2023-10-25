VERSION 5.00
Begin VB.UserControl ctrlCrzZonesSettings 
   ClientHeight    =   345
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   2625
   ScaleHeight     =   345
   ScaleWidth      =   2625
   Begin VB.CheckBox chkTool 
      Caption         =   "Панель управления"
      Height          =   255
      Left            =   720
      TabIndex        =   0
      Top             =   0
      Width           =   1935
   End
   Begin VB.Label cursPosY 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Left            =   0
      TabIndex        =   1
      ToolTipText     =   "Номер датчика под курсором"
      Top             =   0
      Width           =   615
   End
End
Attribute VB_Name = "ctrlCrzZonesSettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private resizeFlag As Boolean

Public Event onTool(ByVal isOn As Boolean)

Property Get sensOnCurs() As String
sensOnCurs = cursPosY.caption
End Property

Property Let sensOnCurs(s As String)
cursPosY.caption = s
End Property

Property Let isToolVisible(v As Boolean)
resizeFlag = True
chkTool.Value = IIf(v, 1, 0)
resizeFlag = False
End Property

Property Get isToolVisible() As Boolean
isToolVisible = IIf(chkTool.Value = 0, False, True)
End Property

Private Sub chkTool_Click()
If resizeFlag Then Exit Sub
If Len(chkTool.Tag) = 0 Then RaiseEvent onTool(Me.isToolVisible)
End Sub
