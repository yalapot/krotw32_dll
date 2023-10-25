VERSION 5.00
Begin VB.Form frmTubeFiltr 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Фильтр длин труб"
   ClientHeight    =   3420
   ClientLeft      =   1215
   ClientTop       =   1380
   ClientWidth     =   3645
   Icon            =   "TubFiltr.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3420
   ScaleWidth      =   3645
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame2 
      Caption         =   "Режим фильтра"
      Height          =   1815
      Left            =   120
      TabIndex        =   6
      Top             =   0
      Width           =   3375
      Begin VB.OptionButton optMode 
         Caption         =   "Сдвинутые дефекты"
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   14
         Top             =   1440
         Width           =   3015
      End
      Begin VB.OptionButton optMode 
         Caption         =   "Угол стыка"
         Height          =   255
         Index           =   4
         Left            =   120
         TabIndex        =   12
         Top             =   1200
         Width           =   3015
      End
      Begin VB.OptionButton optMode 
         Caption         =   "Изгиб трубы"
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   11
         Top             =   960
         Width           =   3015
      End
      Begin VB.OptionButton optMode 
         Caption         =   "Продольные швы"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   9
         Top             =   720
         Width           =   3015
      End
      Begin VB.OptionButton optMode 
         Caption         =   "Длины труб"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   8
         Top             =   480
         Width           =   3015
      End
      Begin VB.OptionButton optMode 
         Caption         =   "Отключен"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   7
         Top             =   240
         Width           =   3015
      End
   End
   Begin VB.Frame frameLength 
      Caption         =   "Показывать все трубы, длины которых"
      Height          =   735
      Left            =   120
      TabIndex        =   2
      Top             =   1920
      Width           =   3375
      Begin VB.ComboBox lstOper 
         Height          =   315
         ItemData        =   "TubFiltr.frx":0442
         Left            =   120
         List            =   "TubFiltr.frx":0455
         Style           =   2  'Dropdown List
         TabIndex        =   4
         Top             =   240
         Width           =   1335
      End
      Begin VB.TextBox txtLen 
         Height          =   285
         Left            =   1560
         TabIndex        =   3
         Text            =   "Text1"
         Top             =   240
         Width           =   855
      End
      Begin VB.Label labEdIzm 
         Caption         =   "м."
         Height          =   255
         Left            =   2640
         TabIndex        =   5
         Top             =   240
         Width           =   495
      End
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   375
      Index           =   1
      Left            =   1920
      TabIndex        =   1
      Top             =   2880
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   375
      Index           =   0
      Left            =   360
      TabIndex        =   0
      Top             =   2880
      Width           =   1215
   End
   Begin VB.Label labDefect 
      Caption         =   "Показать дефекты, у которых дистанции не совпадают с данными из линзы."
      Height          =   615
      Left            =   120
      TabIndex        =   13
      Top             =   4080
      Width           =   3375
   End
   Begin VB.Label labSlit 
      Caption         =   "Показывать все трубы с неверным количеством продольных швов (спирал < 2; прямошов < 1; бесшов >0)"
      Height          =   615
      Left            =   120
      TabIndex        =   10
      Top             =   3360
      Width           =   3375
   End
End
Attribute VB_Name = "frmTubeFiltr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private ret As Boolean
Private tFlt As clsTubeFiltr
Private frm As frmTrace
Private curMode As T_TUBEFILTR
Private hlp As New clsHelp

Public Function Edit(prnt As frmTrace, tFilter As clsTubeFiltr) As Boolean
Load Me
hlp.BindHelp Me, KRT_ObjTubeLength
ret = False
Set frm = prnt
Set tFlt = tFilter
centerForm frmMain, Me
setControls
Me.Show 1, frmMain
Edit = ret
End Function

Private Function getIndex(s As String) As Integer
Dim i As Integer

For i = 0 To lstOper.ListCount
 If lstOper.List(i) = s Then
  getIndex = i
  Exit Function
 End If
Next
'ogdWin.Alert "Unknoun operation " & s
getIndex = 0
End Function

Private Sub setControls()
lstOper.ListIndex = getIndex(tFlt.tubeCompare)
optMode(tFlt.mode).Value = True
End Sub

Private Sub getControls()
tFlt.tubeLen = Val(txtLen.Text) * 1000
tFlt.tubeAngle = Val(txtLen.Text)
tFlt.tubeCompare = lstOper.List(lstOper.ListIndex)
tFlt.mode = curMode
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0 'да
  getControls
  ret = True
End Select
Unload Me
End Sub

Private Sub optMode_Click(Index As Integer)
curMode = Index
frameLength.Visible = False
labSlit.Visible = False
labSlit.Top = frameLength.Top
labDefect.visible = False
labDefect.Top = frameLength.Top
Select Case curMode
 Case TUBEF_CURVE
  frameLength.Caption = "Показывать трубы изгиб которых"
  labEdIzm.Caption = "град."
  txtLen.Text = tFlt.tubeAngle
  frameLength.Visible = True
 Case TUBEF_ANGLE
  frameLength.Caption = "Показывать трубы у которых углы стыка"
  labEdIzm.Caption = "град."
  txtLen.Text = tFlt.tubeAngle
  frameLength.Visible = True
 Case TUBEF_LENGTH
  frameLength.Caption = "Показывать трубы, длины которых"
  labEdIzm.Caption = "м."
  txtLen.Text = mm2txt(tFlt.tubeLen)
  frameLength.Visible = True
 Case TUBEF_SLIT
  labSlit.Visible = True
 Case TUBEF_DEFECT
  labDefect.visible = True
End Select
End Sub