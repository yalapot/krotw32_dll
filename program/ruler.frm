VERSION 5.00
Begin VB.Form frmRuler 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   1680
   ClientLeft      =   45
   ClientTop       =   375
   ClientWidth     =   3840
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1680
   ScaleWidth      =   3840
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtValue 
      Height          =   285
      Index           =   1
      Left            =   1560
      TabIndex        =   7
      Text            =   "Text1"
      Top             =   600
      Width           =   855
   End
   Begin VB.CheckBox chkEnable 
      Caption         =   "вторая"
      Height          =   375
      Index           =   1
      Left            =   120
      TabIndex        =   6
      Top             =   570
      Width           =   1215
   End
   Begin VB.TextBox txtValue 
      Height          =   285
      Index           =   0
      Left            =   1560
      TabIndex        =   3
      Text            =   "Text1"
      Top             =   120
      Width           =   855
   End
   Begin VB.CheckBox chkEnable 
      Caption         =   "первая"
      Height          =   375
      Index           =   0
      Left            =   120
      TabIndex        =   2
      Top             =   90
      Width           =   1215
   End
   Begin VB.CommandButton btmAction 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   375
      Index           =   1
      Left            =   2040
      TabIndex        =   1
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton btmAction 
      Caption         =   "Установить"
      Default         =   -1  'True
      Height          =   375
      Index           =   0
      Left            =   600
      TabIndex        =   0
      Top             =   1200
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "цвет"
      Height          =   255
      Index           =   0
      Left            =   2520
      TabIndex        =   9
      Top             =   600
      Width           =   495
   End
   Begin VB.Label markColor 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   1
      Left            =   3120
      TabIndex        =   8
      Top             =   600
      Width           =   615
   End
   Begin VB.Label Label1 
      Caption         =   "цвет"
      Height          =   255
      Index           =   1
      Left            =   2520
      TabIndex        =   5
      Top             =   120
      Width           =   495
   End
   Begin VB.Label markColor 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   0
      Left            =   3120
      TabIndex        =   4
      Top             =   120
      Width           =   615
   End
End
Attribute VB_Name = "frmRuler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private trc As clsTrace
Private ctrlGraph As ctrlGrfSpec
Private hlp As New clsHelp
Private act As Boolean
Dim dlg As New clsCommonDialog

Public Function View(prnt As frmTrace, ctrl As ctrlGrfSpec) As Boolean
Set trc = prnt.trc
Set ctrlGraph = ctrl
Me.Icon = prnt.Icon
hlp.BindHelp Me, KRT_Ruler
Me.Caption = "Линейки " & prnt.Caption
centerForm prnt, Me

markColor(0).BackColor = ctrlGraph.sens.rul1clr
markColor(1).BackColor = ctrlGraph.sens.rul2clr
txtValue(0).Text = "" & ctrlGraph.sens.rul1val
txtValue(1).Text = "" & ctrlGraph.sens.rul2val
chkEnable(0).Value = IIf(ctrlGraph.sens.rul1enb, 1, 0)
chkEnable(1).Value = IIf(ctrlGraph.sens.rul2enb, 1, 0)
chkEnable_Click 0
chkEnable_Click 1

act = False
Me.Show 1, frmMain
View = act
End Function

Private Sub btmAction_Click(Index As Integer)
Select Case Index
  Case 0 'установить
    ctrlGraph.sens.rul1clr = markColor(0).BackColor
    ctrlGraph.sens.rul2clr = markColor(1).BackColor
    ctrlGraph.sens.rul1val = val(txtValue(0).Text)
    ctrlGraph.sens.rul2val = val(txtValue(1).Text)
    ctrlGraph.sens.rul1enb = IIf(chkEnable(0).Value = 1, True, False)
    ctrlGraph.sens.rul2enb = IIf(chkEnable(1).Value = 1, True, False)
    act = True
  Case 1 'отказ
    act = False
End Select

Unload Me
End Sub

Private Sub chkEnable_Click(Index As Integer)
Dim is_enable As Boolean

is_enable = True
If chkEnable(Index).Value = 0 Then
  is_enable = False
End If
txtValue(Index).enabled = is_enable
End Sub

Private Sub markColor_Click(Index As Integer)
Dim clr As Long

If chkEnable(Index).Value = 0 Then
  Exit Sub
End If

dlg.CancelError = True
dlg.color = markColor(Index).BackColor
dlg.hwnd = Me.hwnd
On Error GoTo CancelColor

dlg.ShowColor
clr = dlg.color
markColor(Index).BackColor = clr

CancelColor:
End Sub
