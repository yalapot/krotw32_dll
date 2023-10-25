VERSION 5.00
Begin VB.Form frmTubeProfile 
   Caption         =   "Form1"
   ClientHeight    =   5010
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7020
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5010
   ScaleWidth      =   7020
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin krotw32.multyNum profZero 
      Height          =   255
      Left            =   1440
      TabIndex        =   8
      Top             =   120
      Width           =   1380
      _ExtentX        =   2514
      _ExtentY        =   450
   End
   Begin VB.CheckBox markBlack 
      Caption         =   "черный"
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   6120
      TabIndex        =   1
      ToolTipText     =   "рисовать профиль трубы на черном маркере"
      Top             =   120
      Width           =   855
   End
   Begin VB.CheckBox markWhite 
      Caption         =   "белый"
      Height          =   255
      Left            =   5160
      TabIndex        =   0
      ToolTipText     =   "рисовать профиль трубы на белом маркере"
      Top             =   120
      Width           =   855
   End
   Begin VB.CommandButton btmLeft 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   120
      Picture         =   "TubeProfile.frx":0000
      Style           =   1  'Graphical
      TabIndex        =   3
      TabStop         =   0   'False
      ToolTipText     =   "Сдвиг маркеров назад"
      Top             =   120
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.CommandButton btmRight 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   360
      Picture         =   "TubeProfile.frx":0102
      Style           =   1  'Graphical
      TabIndex        =   4
      TabStop         =   0   'False
      ToolTipText     =   "Сдвиг маркеров вперед"
      Top             =   120
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.ComboBox lstProfil 
      Height          =   315
      Left            =   960
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   465
      Width           =   3855
   End
   Begin VB.PictureBox picTube 
      Height          =   2295
      Left            =   120
      ScaleHeight     =   2235
      ScaleWidth      =   4635
      TabIndex        =   5
      Top             =   840
      Width           =   4695
   End
   Begin krotw32.multyNum profDiam 
      Height          =   255
      Left            =   3720
      TabIndex        =   9
      Top             =   120
      Width           =   1380
      _ExtentX        =   2514
      _ExtentY        =   450
   End
   Begin VB.Label Label3 
      Caption         =   "диаметр"
      Height          =   255
      Left            =   2880
      TabIndex        =   10
      Top             =   120
      Width           =   735
   End
   Begin VB.Label Label2 
      Caption         =   "нормаль"
      Height          =   255
      Left            =   720
      TabIndex        =   7
      Top             =   120
      Width           =   735
   End
   Begin VB.Label Label1 
      Caption         =   "Профиль"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   480
      Width           =   855
   End
End
Attribute VB_Name = "frmTubeProfile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const MRK_WHITE = "MrkWhite"
Private Const MRK_BLACK = "MrkBlack"
Private Const SEL_ZONE = "SelZone"

Private init_flag As Boolean
Private frm As New clsFormProps
Private trc As clsTrace
Private prf As clsCoroz

Public Event formOFF()
Public Event shiftMark(ByVal onLeft As Boolean, ByVal wMark As Boolean, ByVal bMark As Boolean)

Property Get mrkWhite() As Boolean
mrkWhite = IIf(markWhite.Value = 1, True, False)
End Property

Property Let mrkWhite(v As Boolean)
markWhite.Value = IIf(v, 1, 0)
End Property

Property Get mrkBlack() As Boolean
mrkBlack = IIf(markBlack.Value = 1, True, False)
End Property

Property Let mrkBlack(v As Boolean)
markBlack.Value = IIf(v, 1, 0)
End Property

Private Sub btmLeft_Click()
RaiseEvent shiftMark(True, Me.mrkWhite, Me.mrkBlack)
End Sub

Private Sub btmRight_Click()
RaiseEvent shiftMark(False, Me.mrkWhite, Me.mrkBlack)
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.HideForm
 RaiseEvent formOFF
End If
End Sub

Public Sub Init(trace As clsTrace)
Dim i As Integer

init_flag = True
Set trc = trace
frm.Init trc.secUser, "frmTubeProfile"
frm.restoreForm Me

Me.Caption = "Профиль трубы " & trc.Description
Me.Icon = frmMain.Icon

For i = 0 To trc.Coroz.num - 1
' If trc.Coroz.zone(i).sensType = SENS_PROFIL Then
  lstProfil.addItem trc.Coroz.zone(i).name
  lstProfil.ItemData(lstProfil.ListCount - 1) = i
' End If
Next
If lstProfil.ListCount > 0 Then lstProfil.ListIndex = 0
lstProfil.enabled = (lstProfil.ListCount > 1)

Me.mrkWhite = trc.secUser.getBool(frm.fullKey(MRK_WHITE), False)
Me.mrkBlack = trc.secUser.getBool(frm.fullKey(MRK_BLACK), False)

markWhite.BackColor = color.markWhite
markWhite.ForeColor = color.markWhiteText
markBlack.BackColor = color.markBlack
markBlack.ForeColor = color.markBlackText
'markWhite.Caption = 0
'markBlack.Caption = 0

profZero.min = -100
profZero.max = 100
profZero.Value = trc.profilZero

init_flag = False
If trc.Coroz.tubeProfileVisible Then Me.View
End Sub

Public Sub Save()
frm.saveForm Me
trc.secUser.setBool frm.fullKey(MRK_WHITE), IIf(markWhite.Value = 1, True, False)
trc.secUser.setBool frm.fullKey(MRK_BLACK), IIf(markBlack.Value = 1, True, False)
trc.secUser.setInt frm.fullKey(SEL_ZONE), lstProfil.ListIndex
End Sub

Public Sub HideForm()
Me.visible = False
End Sub

Public Sub View()
Me.Show 0, frmMain
End Sub

Private Sub Form_Resize()
Dim h As Double

If Me.WindowState = 1 Then Exit Sub
 
picTube.width = Me.ScaleWidth - picTube.Left * 2

h = Me.ScaleHeight - picTube.Top - 150
If h < 150 Then h = 150
picTube.Height = IIf(Me.ScaleHeight > picTube.Top, h, 1)
picTube_Paint
End Sub

Private Sub lstProfil_Click()
Set prf = trc.Coroz.zone(lstProfil.ItemData(lstProfil.ListIndex))
End Sub

Private Sub markBlack_Click()
picTube_Paint
End Sub

Private Sub markWhite_Click()
picTube_Paint
End Sub

Private Sub picTube_Paint()
Dim size As Single, x As Single, y As Single, k As Single, size1 As Single

If init_flag Then Exit Sub

With picTube
size = IIf(.ScaleWidth > .ScaleHeight, .ScaleHeight, .ScaleWidth)
.ForeColor = 0
.drawMode = 13
.DrawWidth = 1
.DrawStyle = 2
End With

picTube.Cls

x = size / 2
y = size / 2


'If trc.Coroz.zone(0).sensType = SENS_PROFIL Then
size = size / 2 - 200
'End If

k = (profDiam.max - profDiam.Value) / profDiam.max
size1 = size * k

If size < 200 Then size = 200
picTube.Circle (x, y), size1, 0

If prf Is Nothing Then Exit Sub

If Me.mrkWhite Then prf.markerWhite.DrawCircle picTube, x, y, size, color.markWhite
If Me.mrkBlack Then prf.markerBlack.DrawCircle picTube, x, y, size, color.markBlack
End Sub

Private Sub profDiam_Change(m As Integer)
If init_flag Then Exit Sub
'trc.profilZero = profZero.Value
picTube_Paint
End Sub

Private Sub profZero_Change(m As Integer)
If init_flag Then Exit Sub

trc.profilZero = profZero.Value
picTube_Paint
End Sub

Public Sub redraw()
picTube_Paint
End Sub
