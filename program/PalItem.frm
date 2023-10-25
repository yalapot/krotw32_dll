VERSION 5.00
Begin VB.Form frmPalItem 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Элемент палитры"
   ClientHeight    =   2505
   ClientLeft      =   9390
   ClientTop       =   3735
   ClientWidth     =   2820
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2505
   ScaleWidth      =   2820
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton btmRGB 
      Caption         =   "Blue"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   9
      Top             =   1080
      Width           =   1335
   End
   Begin VB.CommandButton btmRGB 
      Caption         =   "Green"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   8
      Top             =   840
      Width           =   1335
   End
   Begin VB.CommandButton btmAction 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   375
      Index           =   1
      Left            =   1440
      TabIndex        =   4
      Top             =   2040
      Width           =   1095
   End
   Begin VB.CommandButton btmAction 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   375
      Index           =   0
      Left            =   240
      TabIndex        =   3
      Top             =   2040
      Width           =   1095
   End
   Begin VB.CommandButton btmColor 
      Caption         =   "Выбор цвета"
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   1440
      Width           =   1335
   End
   Begin VB.CommandButton btmRGB 
      Caption         =   "Red"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   1
      Top             =   600
      Width           =   1335
   End
   Begin VB.CommandButton btmPos 
      Caption         =   "Позиция"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1335
   End
   Begin VB.Label labRGB 
      Alignment       =   1  'Right Justify
      Caption         =   "255"
      Height          =   255
      Index           =   2
      Left            =   1680
      TabIndex        =   11
      Top             =   1080
      Width           =   975
   End
   Begin VB.Label labRGB 
      Alignment       =   1  'Right Justify
      Caption         =   "255"
      Height          =   255
      Index           =   1
      Left            =   1680
      TabIndex        =   10
      Top             =   840
      Width           =   975
   End
   Begin VB.Label labColor 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Height          =   375
      Left            =   1680
      TabIndex        =   7
      Top             =   1440
      Width           =   975
   End
   Begin VB.Label labRGB 
      Alignment       =   1  'Right Justify
      Caption         =   "255"
      Height          =   255
      Index           =   0
      Left            =   1680
      TabIndex        =   6
      Top             =   600
      Width           =   975
   End
   Begin VB.Label labPos 
      Alignment       =   1  'Right Justify
      Caption         =   "200"
      Height          =   255
      Left            =   1680
      TabIndex        =   5
      Top             =   120
      Width           =   975
   End
End
Attribute VB_Name = "frmPalItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private act As Boolean
Private d_pos As Long
Private d_clr As Long
Private d_min As Long
Private d_max As Long
Dim dlg As New clsCommonDialog
Private hlp As New clsHelp

Public Function Edit( _
parentFrm As Form, _
ByRef entryPos As Long, _
ByRef entryColor As Long, _
ByVal posMin As Long, _
ByVal posMax As Long _
) As Boolean

act = False
centerForm parentFrm, Me
Me.Icon = parentFrm.Icon
hlp.BindHelp Me, KRT_PalEditWork

d_pos = entryPos
d_clr = entryColor
d_min = posMin
d_max = posMax

btmPos.enabled = (d_pos <> d_min) And (d_pos <> d_max)
labPos.caption = d_pos
labColor.BackColor = d_clr
labRGB(0).caption = rgbColor(d_clr, RGB_RED)
labRGB(1).caption = rgbColor(d_clr, RGB_GREEN)
labRGB(2).caption = rgbColor(d_clr, RGB_BLUE)

Me.Show 1, parentFrm
entryPos = d_pos
entryColor = d_clr
Edit = act
End Function

Private Sub btmAction_Click(Index As Integer)
If Index = 0 Then
 d_clr = labColor.BackColor
 d_pos = labPos.caption
 act = True
End If
Unload Me
End Sub

Private Function getRGBpart(partName As String, ByVal dflt As Integer) As Integer
Dim s As String

s = InputBox( _
 "Введите значение " & partName & " составляющей цвета (0-255)", _
 "Установка цвета", _
 dflt)

If s = "" Then
 getRGBpart = -1
 Exit Function
End If

If Val(s) < 0 Then
 getRGBpart = 0
 Exit Function
End If

If Val(s) > 255 Then
 getRGBpart = 255
 Exit Function
End If

getRGBpart = Val(s)
End Function

Private Sub btmColor_Click()

dlg.CancelError = True
dlg.color = labColor.BackColor
dlg.hWnd = Me.hWnd
On Error GoTo CancelColor

dlg.ShowColor
d_clr = dlg.color
labColor.BackColor = d_clr
labRGB(0).caption = rgbColor(d_clr, RGB_RED)
labRGB(1).caption = rgbColor(d_clr, RGB_GREEN)
labRGB(2).caption = rgbColor(d_clr, RGB_BLUE)

CancelColor:
End Sub

Private Sub btmPos_Click()
Dim s As String, v As Long

s = InputBox( _
 "Введите положение цвета в палитре (" & d_min & " - " & d_max & ")", _
 "Установка положения", _
 d_pos)

If s = "" Then Exit Sub
v = Val(s)

If (v <= d_min) Or (v >= d_max) Then
 ogdWin.Alert "Значение должно быть между " & d_min & " - " & d_max
 Exit Sub
End If

d_pos = v
labPos.caption = d_pos
End Sub

Private Sub btmRGB_Click(Index As Integer)
Dim c As Integer

c = getRGBpart(btmRGB(Index).caption, labRGB(Index).caption)
If c >= 0 Then
 labRGB(Index).caption = c
 labColor.BackColor = RGB(labRGB(0).caption, labRGB(1).caption, labRGB(2).caption)
End If
End Sub