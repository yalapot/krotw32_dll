VERSION 5.00
Begin VB.Form frmTurnInfo 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Информация о повороте"
   ClientHeight    =   3360
   ClientLeft      =   5460
   ClientTop       =   4260
   ClientWidth     =   4710
   Icon            =   "TurnInfo.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3360
   ScaleWidth      =   4710
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton btmOK 
      Caption         =   "Осознал"
      Height          =   375
      Left            =   1920
      TabIndex        =   12
      Top             =   2880
      Width           =   1095
   End
   Begin VB.Label labAngle3D 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   20
      Top             =   1680
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Угол 3D"
      Height          =   255
      Index           =   9
      Left            =   120
      TabIndex        =   19
      Top             =   1560
      Width           =   1695
   End
   Begin VB.Label Label1 
      Caption         =   "Отметка X"
      Height          =   255
      Index           =   8
      Left            =   120
      TabIndex        =   18
      Top             =   2040
      Width           =   1695
   End
   Begin VB.Label labMarkX 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   17
      Top             =   2160
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Отметка Y"
      Height          =   255
      Index           =   7
      Left            =   120
      TabIndex        =   16
      Top             =   2280
      Width           =   1695
   End
   Begin VB.Label labMarkY 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   15
      Top             =   2400
      Width           =   975
   End
   Begin VB.Label labMarkZ 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   14
      Top             =   2640
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Отметка Z"
      Height          =   255
      Index           =   6
      Left            =   120
      TabIndex        =   13
      Top             =   2520
      Width           =   1695
   End
   Begin VB.Label labAngleZ 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   11
      Top             =   1440
      Width           =   975
   End
   Begin VB.Label labAngleXY 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   10
      Top             =   1200
      Width           =   975
   End
   Begin VB.Label labRadZ 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   2040
      TabIndex        =   9
      Top             =   960
      Width           =   2535
   End
   Begin VB.Label labRadXY 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   2040
      TabIndex        =   8
      Top             =   720
      Width           =   2535
   End
   Begin VB.Label labLength 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   7
      Top             =   480
      Width           =   975
   End
   Begin VB.Label labStart 
      Alignment       =   1  'Right Justify
      Caption         =   "Label2"
      Height          =   255
      Left            =   3600
      TabIndex        =   6
      Top             =   240
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Угол в Z"
      Height          =   255
      Index           =   5
      Left            =   120
      TabIndex        =   5
      Top             =   1320
      Width           =   1695
   End
   Begin VB.Label Label1 
      Caption         =   "Угол в XY"
      Height          =   255
      Index           =   4
      Left            =   120
      TabIndex        =   4
      Top             =   1080
      Width           =   1695
   End
   Begin VB.Label Label1 
      Caption         =   "Радиус в Z, м"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   3
      Top             =   840
      Width           =   1695
   End
   Begin VB.Label Label1 
      Caption         =   "Радиус в XY, м"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   2
      Top             =   600
      Width           =   1695
   End
   Begin VB.Label Label1 
      Caption         =   "Длина поворота, м"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   1
      Top             =   360
      Width           =   1695
   End
   Begin VB.Label Label1 
      Caption         =   "Начало поворота, м"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1695
   End
End
Attribute VB_Name = "frmTurnInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Public Sub View( _
prnt As Form, _
ByVal Start As Long, _
ByVal length As Long, _
ByVal radiusXY As Long, _
ByVal angleXY As Single, _
ByVal radiusZ As Long, _
ByVal angleZ As Single, _
ByVal markX As Long, _
ByVal markY As Long, _
ByVal markZ As Long, _
ByVal angle3D As Single, _
trc As clsTrace _
)

labStart.Caption = mm2txt(trc.getDistKoef(Start))
labLength.Caption = mm2txt(trc.getLenKoef(Start, length))
labRadXY.Caption = angle_label(radiusXY, prnt.trc.Diametr)
labAngleXY.Caption = rad2degree(angleXY)
labradz.Caption = angle_label(radiusZ, prnt.trc.Diametr)
labAngleZ.Caption = rad2degree(angleZ)
labMarkX.Caption = markX
labMarkY.Caption = markY
labMarkZ.Caption = markZ
labAngle3D.Caption = rad2degree(angle3D)

Load Me
Me.Icon = prnt.Icon
centerForm prnt, Me
Me.Show 1
End Sub

Private Sub btmOK_Click()
Unload Me
End Sub
