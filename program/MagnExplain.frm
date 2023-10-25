VERSION 5.00
Begin VB.Form frmMagnExplain 
   Caption         =   "Form1"
   ClientHeight    =   3975
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7155
   LinkTopic       =   "Form1"
   ScaleHeight     =   3975
   ScaleWidth      =   7155
   Begin VB.TextBox txt 
      Height          =   2055
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Text            =   "MagnExplain.frx":0000
      Top             =   0
      Width           =   3015
   End
End
Attribute VB_Name = "frmMagnExplain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private hlp As New clsHelp

Private Sub Form_Resize()
txt.width = Me.width - 150
txt.Height = Me.Height - 500
End Sub

Public Sub View(fZoom As frmZoom, ByVal title As String, ByVal explain As String)
Me.Icon = frmMain.Icon
Me.Caption = title
hlp.BindHelp Me, KRT_AnaCorozZoomGeom
txt.Text = explain
centerForm fZoom, Me
Me.Show 0, fZoom
End Sub
