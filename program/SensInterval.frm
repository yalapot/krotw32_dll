VERSION 5.00
Begin VB.Form frmSensInterval 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   1545
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4095
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1545
   ScaleWidth      =   4095
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox valEnd 
      Height          =   285
      Left            =   2160
      TabIndex        =   5
      Text            =   "Text1"
      Top             =   480
      Width           =   1815
   End
   Begin VB.TextBox valStart 
      Height          =   285
      Left            =   120
      TabIndex        =   4
      Text            =   "Text1"
      Top             =   480
      Width           =   1815
   End
   Begin VB.CommandButton btmYes 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Left            =   600
      TabIndex        =   1
      Top             =   960
      Width           =   1335
   End
   Begin VB.CommandButton btmNo 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Left            =   2160
      TabIndex        =   0
      Top             =   960
      Width           =   1335
   End
   Begin VB.Label labValStart 
      Alignment       =   1  'Right Justify
      Caption         =   "Label1"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   120
      Width           =   1815
   End
   Begin VB.Label labValEnd 
      Alignment       =   1  'Right Justify
      Caption         =   "Label1"
      Height          =   255
      Left            =   2160
      TabIndex        =   2
      Top             =   120
      Width           =   1815
   End
End
Attribute VB_Name = "frmSensInterval"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private retCode As Boolean
Private d_sens As clsSensorGraph
Private hlp As New clsHelp

Public Function setInterval(prntForm As Form, sens As clsSensorGraph) As Boolean
Set d_sens = sens
Load Me
hlp.BindHelp Me, KRT_AnaGraph
Me.Icon = prntForm.Icon
centerForm prntForm, Me
Me.Caption = "Интервал показаний графика"
labValStart.Caption = "Мин. " & sens.dispVal(sens.valMin)
labValEnd.Caption = "Макс. " & sens.dispVal(sens.valMax)

valStart.Text = sens.dispVal(sens.brdMin)
valEnd.Text = sens.dispVal(sens.brdMax)
retCode = False
Me.Show 1
setInterval = retCode
End Function

Private Sub btmNo_Click()
Unload Me
End Sub

Private Sub btmYes_Click()
Dim dMin As Long, dMax As Long

dMin = d_sens.sensVal(valStart.Text)
dMax = d_sens.sensVal(valEnd.Text)

If dMin < d_sens.valMin Then
 ogdWin.Alert "Нижняя граница должна быть больше минимального значения"
 valStart.SetFocus
 Exit Sub
End If
If dMax > d_sens.valMax Then
 ogdWin.Alert "Верхняя граница должна быть меньше максимального значения"
 valEnd.SetFocus
 Exit Sub
End If
If dMin >= dMax Then
 ogdWin.Alert "Нижняя граница должна быть меньше верхней границы"
 valStart.SetFocus
 Exit Sub
End If

d_sens.brdMin = dMin
d_sens.brdMax = dMax
d_sens.autoBrd = False
retCode = True
Unload Me
End Sub

Private Sub valStart_GotFocus()
setSel valStart
End Sub

Private Sub valEnd_GotFocus()
setSel valEnd
End Sub
