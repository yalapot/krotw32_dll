VERSION 5.00
Begin VB.Form frmScanTube 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Настройки поиска труб"
   ClientHeight    =   8295
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4275
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8295
   ScaleWidth      =   4275
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame frameSpiral 
      Caption         =   "Спиральный шов"
      Height          =   1455
      Left            =   120
      TabIndex        =   34
      Top             =   11640
      Width           =   4095
      Begin VB.TextBox txtSpiral_area 
         Height          =   285
         Left            =   3240
         TabIndex        =   56
         Text            =   "Text1"
         Top             =   1080
         Width           =   735
      End
      Begin VB.TextBox txtSpiral_bord 
         Height          =   285
         Left            =   3240
         TabIndex        =   53
         Text            =   "Text1"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtSpiral_sens 
         Height          =   285
         Left            =   3240
         TabIndex        =   52
         Text            =   "Text1"
         Top             =   480
         Width           =   735
      End
      Begin VB.TextBox txtSpiral_width 
         Height          =   285
         Left            =   3240
         TabIndex        =   50
         Text            =   "Text1"
         Top             =   240
         Width           =   735
      End
      Begin VB.Label Label12 
         Caption         =   "Ширина области"
         Height          =   255
         Left            =   120
         TabIndex        =   55
         Top             =   1080
         Width           =   2895
      End
      Begin VB.Label Label11 
         Caption         =   "Порог чувствительности"
         Height          =   255
         Left            =   120
         TabIndex        =   54
         Top             =   480
         Width           =   2895
      End
      Begin VB.Label Label10 
         Caption         =   "Порог фильтрации"
         Height          =   255
         Left            =   120
         TabIndex        =   51
         Top             =   720
         Width           =   2895
      End
      Begin VB.Label Label9 
         Caption         =   "Минимальная ширина"
         Height          =   255
         Left            =   120
         TabIndex        =   49
         Top             =   240
         Width           =   2895
      End
   End
   Begin VB.Frame frameWeld2 
      Caption         =   "Продольный шов"
      Height          =   1455
      Left            =   120
      TabIndex        =   33
      Top             =   10200
      Width           =   4095
      Begin VB.TextBox txtWeld2_second 
         Height          =   285
         Left            =   3240
         TabIndex        =   57
         Text            =   "Text1"
         Top             =   1080
         Width           =   735
      End
      Begin VB.TextBox txtWeld2_bord 
         Height          =   285
         Left            =   3240
         TabIndex        =   47
         Text            =   "Text1"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtWeld2_sens 
         Height          =   285
         Left            =   3240
         TabIndex        =   46
         Text            =   "Text1"
         Top             =   480
         Width           =   735
      End
      Begin VB.TextBox txtWeld2_width 
         Height          =   285
         Left            =   3240
         TabIndex        =   44
         Text            =   "Text1"
         Top             =   240
         Width           =   735
      End
      Begin VB.Label Label13 
         Caption         =   "Зона расположения второго шва"
         Height          =   255
         Left            =   120
         TabIndex        =   58
         Top             =   1080
         Width           =   2895
      End
      Begin VB.Label Label8 
         Caption         =   "Порог чувствительности"
         Height          =   255
         Left            =   120
         TabIndex        =   48
         Top             =   480
         Width           =   2895
      End
      Begin VB.Label Label7 
         Caption         =   "Порог фильтрации"
         Height          =   255
         Left            =   120
         TabIndex        =   45
         Top             =   720
         Width           =   2895
      End
      Begin VB.Label Label6 
         Caption         =   "Минимальная ширина"
         Height          =   255
         Left            =   120
         TabIndex        =   43
         Top             =   240
         Width           =   2895
      End
   End
   Begin VB.Frame frameWeld1 
      Caption         =   "Поперечный шов"
      Height          =   1455
      Left            =   120
      TabIndex        =   32
      Top             =   8760
      Width           =   4095
      Begin VB.TextBox txtWeld1_otst 
         Height          =   285
         Left            =   3240
         TabIndex        =   42
         Text            =   "Text1"
         Top             =   1080
         Width           =   735
      End
      Begin VB.TextBox txtWeld1_bord 
         Height          =   285
         Left            =   3240
         TabIndex        =   41
         Text            =   "Text1"
         Top             =   720
         Width           =   735
      End
      Begin VB.TextBox txtWeld1_sens 
         Height          =   285
         Left            =   3240
         TabIndex        =   40
         Text            =   "Text1"
         Top             =   480
         Width           =   735
      End
      Begin VB.TextBox txtWeld1_width 
         Height          =   285
         Left            =   3240
         TabIndex        =   36
         Text            =   "Text1"
         Top             =   240
         Width           =   735
      End
      Begin VB.Label Label5 
         Caption         =   "Отступ"
         Height          =   255
         Left            =   120
         TabIndex        =   39
         Top             =   1080
         Width           =   2895
      End
      Begin VB.Label Label4 
         Caption         =   "Порог фильтрации"
         Height          =   255
         Left            =   120
         TabIndex        =   38
         Top             =   720
         Width           =   2895
      End
      Begin VB.Label Label3 
         Caption         =   "Порог чувствительности"
         Height          =   255
         Left            =   120
         TabIndex        =   37
         Top             =   480
         Width           =   2895
      End
      Begin VB.Label Label2 
         Caption         =   "Минимальная ширина"
         Height          =   255
         Left            =   120
         TabIndex        =   35
         Top             =   240
         Width           =   2895
      End
   End
   Begin VB.Frame Frame5 
      Caption         =   "Исходные данные"
      Height          =   975
      Left            =   120
      TabIndex        =   27
      Top             =   3120
      Width           =   4095
      Begin VB.ComboBox cbCrzIndex 
         Height          =   315
         Left            =   120
         Style           =   2  'Dropdown List
         TabIndex        =   29
         Top             =   480
         Width           =   2055
      End
      Begin VB.Label Label1 
         Caption         =   "Пояс датчиков для поиска швов"
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   28
         Top             =   240
         Width           =   3855
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   "Параметры"
      Height          =   1095
      Left            =   120
      TabIndex        =   20
      Top             =   4200
      Width           =   4095
      Begin VB.TextBox txtMask 
         Height          =   285
         Left            =   2760
         TabIndex        =   23
         Text            =   "Text1"
         Top             =   240
         Width           =   1215
      End
      Begin VB.TextBox txtList 
         Height          =   285
         Left            =   2760
         TabIndex        =   22
         Text            =   "Text1"
         Top             =   480
         Width           =   1215
      End
      Begin VB.TextBox txtLevel 
         Height          =   285
         Left            =   2760
         TabIndex        =   21
         Text            =   "Text1"
         Top             =   720
         Width           =   1215
      End
      Begin VB.Label Label1 
         Caption         =   "Размер маски, в отсч. одометра"
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   26
         Top             =   240
         Width           =   2535
      End
      Begin VB.Label Label1 
         Caption         =   "Ширина прокатного листа, мм"
         Height          =   255
         Index           =   6
         Left            =   120
         TabIndex        =   25
         Top             =   480
         Width           =   2535
      End
      Begin VB.Label Label1 
         Caption         =   "Уровень сигнала"
         Height          =   255
         Index           =   7
         Left            =   120
         TabIndex        =   24
         Top             =   720
         Width           =   2535
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Продольные швы"
      Height          =   855
      Left            =   120
      TabIndex        =   19
      Top             =   5280
      Width           =   4095
      Begin VB.OptionButton slitNum 
         Caption         =   "два"
         Height          =   255
         Index           =   1
         Left            =   240
         TabIndex        =   3
         Top             =   480
         Width           =   2055
      End
      Begin VB.OptionButton slitNum 
         Caption         =   "один"
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   2
         Top             =   240
         Width           =   2055
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Чувствительность швов, %%"
      Height          =   1455
      Left            =   120
      TabIndex        =   15
      Top             =   6120
      Width           =   4095
      Begin krotw32.multyNum wldSens 
         Height          =   255
         Left            =   2640
         TabIndex        =   4
         Top             =   360
         Width           =   1380
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin krotw32.multyNum slitSens 
         Height          =   255
         Left            =   2640
         TabIndex        =   5
         Top             =   720
         Width           =   1380
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin krotw32.multyNum spirSens 
         Height          =   255
         Left            =   2640
         TabIndex        =   6
         Top             =   1080
         Width           =   1380
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin VB.Label labSpir 
         Caption         =   "Спиральные"
         Height          =   255
         Left            =   120
         TabIndex        =   18
         Top             =   1080
         Width           =   2415
      End
      Begin VB.Label labSlit 
         Caption         =   "Продольные"
         Height          =   255
         Left            =   120
         TabIndex        =   17
         Top             =   720
         Width           =   2415
      End
      Begin VB.Label Label1 
         Caption         =   "Поперечные"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   16
         Top             =   360
         Width           =   2415
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "На участке могут быть трубы"
      Height          =   2295
      Left            =   120
      TabIndex        =   14
      Top             =   720
      Width           =   4095
      Begin VB.ComboBox cbDefaultWeld 
         Height          =   315
         ItemData        =   "ScanTube.frx":0000
         Left            =   120
         List            =   "ScanTube.frx":000D
         Style           =   2  'Dropdown List
         TabIndex        =   30
         Top             =   1440
         Width           =   2055
      End
      Begin VB.CheckBox chkWithout 
         Caption         =   "бесшовные"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   840
         Width           =   2415
      End
      Begin VB.CheckBox chkSpiral 
         Caption         =   "спиралешовные"
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   600
         Width           =   2415
      End
      Begin VB.CheckBox chkDirect 
         Caption         =   "прямошовные"
         Height          =   255
         Left            =   120
         TabIndex        =   7
         Top             =   360
         Width           =   2415
      End
      Begin VB.Label labSensType 
         Caption         =   "labSensType"
         Height          =   255
         Left            =   1440
         TabIndex        =   60
         Top             =   1920
         Width           =   2535
      End
      Begin VB.Label Label1 
         Caption         =   "Тип датчиков:"
         Height          =   255
         Index           =   8
         Left            =   120
         TabIndex        =   59
         Top             =   1920
         Width           =   1095
      End
      Begin VB.Label Label1 
         Caption         =   "Тип трубы по умолчанию"
         Height          =   255
         Index           =   4
         Left            =   120
         TabIndex        =   31
         Top             =   1200
         Width           =   3855
      End
   End
   Begin VB.TextBox txtMax 
      Height          =   285
      Left            =   2880
      TabIndex        =   1
      Text            =   "Text1"
      Top             =   360
      Width           =   1335
   End
   Begin VB.TextBox txtMin 
      Height          =   285
      Left            =   2880
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   120
      Width           =   1335
   End
   Begin VB.CommandButton btmRun 
      Caption         =   "Да"
      Height          =   375
      Left            =   600
      TabIndex        =   10
      Top             =   7800
      Width           =   1215
   End
   Begin VB.CommandButton btmCancel 
      Caption         =   "Отказ"
      Height          =   375
      Left            =   2280
      TabIndex        =   11
      Top             =   7800
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Максимальная длина трубы, мм"
      Height          =   255
      Index           =   1
      Left            =   240
      TabIndex        =   13
      Top             =   360
      Width           =   2535
   End
   Begin VB.Label Label1 
      Caption         =   "Минимальная длина трубы, мм"
      Height          =   255
      Index           =   0
      Left            =   240
      TabIndex        =   12
      Top             =   120
      Width           =   2535
   End
End
Attribute VB_Name = "frmScanTube"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private trc As clsTrace
Private crz As clsCorozZones
Private hlp As New clsHelp

Public Sub Edit(prnt As Form, trace As clsTrace, ByVal is2013 As Boolean)
Me.Icon = prnt.Icon
hlp.BindHelp Me, KRT_ObjAuto
centerForm prnt, Me
Set trc = trace
Set crz = trc.Coroz

Frame2.visible = Not is2013
Frame3.visible = Not is2013
Frame4.visible = Not is2013
Frame5.visible = Not is2013

frameWeld1.visible = is2013
frameWeld2.visible = is2013
frameSpiral.visible = is2013

setControls
Me.Show 1, prnt
End Sub

Private Sub setControls()
Dim i As Integer, indx As Integer

With trc.tubeScan
txtMin.Text = .lenMin
txtMax.Text = .lenMax

slitSens.Min = 0
spirSens.Min = 0

txtMask.Text = .maskSize
txtList.Text = .listSize
txtLevel.Text = .signalLevel

labSensType.Caption = .sensorTypeString
txtWeld1_bord.enabled = False
If .sensorType = SENS_PROFIL Then
  txtWeld1_bord.enabled = True
End If

cbDefaultWeld.ListIndex = trc.tubeScan.dfltTubeType

With cbCrzIndex
 If cbCrzIndex.ListCount = 0 Then
  For indx = 1 To crz.num
    .addItem "пояс " & indx
    .ItemData(.ListCount - 1) = indx - 1
  Next
  If .ListCount > 0 Then
   .ListIndex = trc.tubeScan.crzIndex
  End If
 End If
End With

i = IIf(.slitNum = 1, 0, 1)
slitNum(i).Value = True
wldSens.Value = .weldSensitiv
slitSens.Value = .slitSensitiv
spirSens.Value = .spirSensitiv

chkDirect.Value = IIf(.canDirect, 1, 0)
chkSpiral.Value = IIf(.canSpiral, 1, 0)
chkWithout.Value = IIf(.canWithout, 1, 0)


txtWeld1_width.Text = .Weld1_width
txtWeld1_sens.Text = .Weld1_sens
txtWeld1_bord.Text = .Weld1_bord
txtWeld1_otst.Text = .Weld1_otst

txtWeld2_width.Text = .Weld2_width
txtWeld2_sens.Text = .Weld2_sens
txtWeld2_bord.Text = .Weld2_bord
txtWeld2_second.Text = .Weld2_second

txtSpiral_width.Text = .Spiral_width
txtSpiral_sens.Text = .Spiral_sens
txtSpiral_bord.Text = .Spiral_bord
txtSpiral_area.Text = .Spiral_area

End With
End Sub

Private Function getControls() As Boolean
getControls = True

With trc.tubeScan
.lenMin = val(txtMin.Text)
.lenMax = val(txtMax.Text)

.maskSize = txtMask.Text
.listSize = txtList.Text
.signalLevel = txtLevel.Text
.crzIndex = cbCrzIndex.ItemData(cbCrzIndex.ListIndex)
.dfltTubeType = cbDefaultWeld.ListIndex
.slitNum = IIf(slitNum(0).Value = True, 1, 2)
.weldSensitiv = wldSens.Value
.slitSensitiv = slitSens.Value
.spirSensitiv = spirSens.Value

.canDirect = IIf(chkDirect.Value = 1, True, False)
.canSpiral = IIf(chkSpiral.Value = 1, True, False)
.canWithout = IIf(chkWithout.Value = 1, True, False)

On Error GoTo paramWrong
.Weld1_width = CInt(txtWeld1_width.Text)
.Weld1_sens = CSng(txtWeld1_sens.Text)
.Weld1_bord = CSng(txtWeld1_bord.Text)
.Weld1_otst = CInt(txtWeld1_otst.Text)

.Weld2_width = CInt(txtWeld2_width.Text)
.Weld2_sens = CSng(txtWeld2_sens.Text)
.Weld2_bord = CSng(txtWeld2_bord.Text)
.Weld2_second = CInt(txtWeld2_second.Text)

.Spiral_width = CInt(txtSpiral_width.Text)
.Spiral_sens = CSng(txtSpiral_sens.Text)
.Spiral_bord = CSng(txtSpiral_bord.Text)
.Spiral_area = CInt(txtSpiral_area.Text)

End With
Exit Function

paramWrong:
ogdWin.Alert Err.Description
On Error GoTo 0
getControls = False
End Function

Private Sub btmCancel_Click()
Unload Me
End Sub

Private Sub btmRun_Click()
If getControls Then Unload Me
End Sub

Private Sub Form_Load()
Dim dlt As Long

dlt = frameWeld1.Top - Frame5.Top
frameWeld1.Top = frameWeld1.Top - dlt
frameWeld2.Top = frameWeld2.Top - dlt
frameSpiral.Top = frameSpiral.Top - dlt
End Sub

Private Sub slitSens_Change(m As Integer)
labSlit.Caption = IIf(m = 0, "Продольные (не определять)", "Продольные")
End Sub

Private Sub spirSens_Change(m As Integer)
labSpir.Caption = IIf(m = 0, "Спиральные (не определять)", "Спиральные")
End Sub
