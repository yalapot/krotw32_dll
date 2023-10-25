VERSION 5.00
Begin VB.Form frmScaleNew 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Новый масштаб"
   ClientHeight    =   1785
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3465
   Icon            =   "ScaleNew.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1785
   ScaleWidth      =   3465
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtScale 
      Height          =   285
      Left            =   2160
      TabIndex        =   2
      Text            =   "Text1"
      Top             =   600
      Width           =   1215
   End
   Begin VB.Frame Frame1 
      Caption         =   "Тип масштаба"
      Height          =   855
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   1935
      Begin VB.OptionButton sclType 
         Caption         =   "сжатие"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   1
         Top             =   480
         Width           =   1695
      End
      Begin VB.OptionButton sclType 
         Caption         =   "растяжение"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   0
         Top             =   240
         Width           =   1575
      End
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   1920
      TabIndex        =   4
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   360
      TabIndex        =   3
      Top             =   1200
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Во сколько раз"
      Height          =   255
      Left            =   2160
      TabIndex        =   6
      Top             =   240
      Width           =   1455
   End
End
Attribute VB_Name = "frmScaleNew"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private act As Boolean
Private newScale
Private hlp As New clsHelp

Public Function Edit(ByRef dflt As Integer) As Boolean
Load Me
hlp.BindHelp Me, KRT_CfgCoroz
centerForm frmMain, Me

newScale = dflt
Select Case newScale
 Case -1, 0, 1
 newScale = 0
End Select

If newScale < 0 Then
 sclType(0).Value = True
 Else
 sclType(1).Value = True
End If
txtScale.Text = Abs(newScale)

act = False

Me.Show 1, frmMain

If act Then dflt = newScale
Edit = act
End Function

Private Sub btmAct_Click(Index As Integer)
Dim i As Integer

Select Case Index
 Case 0
  i = IIf((sclType(0).Value = True), -1, 1)
  newScale = Val(txtScale.Text)
  newScale = i * newScale
  act = True
End Select
Unload Me
End Sub

