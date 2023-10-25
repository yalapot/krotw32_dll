VERSION 5.00
Begin VB.Form frmDriver 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   7080
   ClientLeft      =   8730
   ClientTop       =   3330
   ClientWidth     =   6555
   Icon            =   "driver.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7080
   ScaleWidth      =   6555
   ShowInTaskbar   =   0   'False
   Begin VB.ComboBox lstMagnet 
      Height          =   315
      Left            =   1800
      Style           =   2  'Dropdown List
      TabIndex        =   33
      Top             =   600
      Width           =   4695
   End
   Begin VB.TextBox txtOdoAngle 
      Height          =   285
      Left            =   3480
      TabIndex        =   30
      Text            =   "Text1"
      Top             =   2760
      Width           =   975
   End
   Begin VB.Frame frmProfil 
      Caption         =   "Профильный снаряд"
      Height          =   1455
      Left            =   120
      TabIndex        =   24
      Top             =   3240
      Width           =   6375
      Begin VB.CheckBox chkIsProfil 
         Alignment       =   1  'Right Justify
         Caption         =   "Профильный снаряд?"
         Height          =   255
         Left            =   120
         TabIndex        =   31
         Top             =   240
         Width           =   3495
      End
      Begin VB.TextBox txtProfPigLength 
         Height          =   285
         Left            =   3360
         TabIndex        =   28
         Text            =   "Text1"
         Top             =   960
         Width           =   975
      End
      Begin VB.TextBox txtProf0 
         Height          =   285
         Left            =   3360
         TabIndex        =   25
         Text            =   "Text1"
         Top             =   600
         Width           =   975
      End
      Begin VB.Label Label1 
         Caption         =   "Расстояние между манжетами, мм"
         Height          =   255
         Index           =   9
         Left            =   120
         TabIndex        =   27
         Top             =   960
         Width           =   3135
      End
      Begin VB.Label Label1 
         Caption         =   "Ноль профильных датчиков, мм"
         Height          =   255
         Index           =   8
         Left            =   120
         TabIndex        =   26
         Top             =   600
         Width           =   3135
      End
   End
   Begin VB.TextBox txtOdo 
      Height          =   285
      Left            =   3480
      TabIndex        =   23
      Text            =   "Text1"
      Top             =   2400
      Width           =   975
   End
   Begin krotw32.multyNum speedVector 
      Height          =   255
      Left            =   3480
      TabIndex        =   21
      Top             =   2040
      Width           =   1380
      _ExtentX        =   2434
      _ExtentY        =   450
   End
   Begin VB.TextBox txtDiam 
      Height          =   285
      Left            =   1800
      TabIndex        =   2
      Text            =   "Text1"
      ToolTipText     =   "Диаметр трубы по умолчанию"
      Top             =   240
      Width           =   1815
   End
   Begin VB.TextBox txtThick 
      Height          =   285
      Left            =   5040
      TabIndex        =   3
      Text            =   "Text1"
      ToolTipText     =   "Наиболее характерная толщина стенки трубы для данного снаряда в мм."
      Top             =   240
      Width           =   1335
   End
   Begin VB.TextBox txtPal 
      Height          =   285
      Left            =   1800
      TabIndex        =   7
      Text            =   "Text1"
      ToolTipText     =   "Имя файла палитры по умолчанию"
      Top             =   1680
      Width           =   3975
   End
   Begin VB.CommandButton btmPal 
      Caption         =   "..."
      Height          =   255
      Left            =   5880
      TabIndex        =   8
      ToolTipText     =   "Выбор файла палитры по умолчанию"
      Top             =   1680
      Width           =   615
   End
   Begin VB.CommandButton btmDll 
      Caption         =   "..."
      Height          =   255
      Left            =   5880
      TabIndex        =   6
      ToolTipText     =   "Выбор файла драйвера"
      Top             =   1440
      Width           =   615
   End
   Begin VB.TextBox txtDll 
      Height          =   285
      Left            =   1800
      TabIndex        =   5
      Text            =   "Text1"
      ToolTipText     =   "Имя файла драйвера"
      Top             =   1440
      Width           =   3975
   End
   Begin VB.TextBox txtID 
      Height          =   285
      Left            =   1800
      TabIndex        =   0
      Text            =   "Text1"
      ToolTipText     =   "Уникальная сигнатура драйвера"
      Top             =   0
      Width           =   1815
   End
   Begin VB.TextBox txtName 
      Height          =   285
      Left            =   1800
      TabIndex        =   4
      Text            =   "Text1"
      ToolTipText     =   "Наименование драйвера"
      Top             =   1080
      Width           =   4695
   End
   Begin VB.TextBox txtExt 
      Height          =   285
      Left            =   5040
      TabIndex        =   1
      Text            =   "Text1"
      ToolTipText     =   "Расширения файлов первичных данных драйвера"
      Top             =   0
      Width           =   1335
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   3480
      TabIndex        =   12
      Top             =   6480
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   1920
      TabIndex        =   11
      Top             =   6480
      Width           =   1215
   End
   Begin krotw32.scaleList sclx 
      Height          =   1410
      Left            =   120
      TabIndex        =   9
      Top             =   4920
      Width           =   3090
      _extentx        =   5450
      _extenty        =   2487
   End
   Begin krotw32.scaleList scly 
      Height          =   1410
      Left            =   3480
      TabIndex        =   10
      Top             =   4920
      Width           =   3090
      _extentx        =   5450
      _extenty        =   2487
   End
   Begin VB.Label Label1 
      Caption         =   "Магнитная система"
      Height          =   255
      Index           =   11
      Left            =   120
      TabIndex        =   32
      Top             =   600
      Width           =   1575
   End
   Begin VB.Label Label1 
      Caption         =   "Угол между плоскостью колеса одометра и первой ластой, в градусах"
      Height          =   435
      Index           =   10
      Left            =   120
      TabIndex        =   29
      Top             =   2685
      Width           =   3105
   End
   Begin VB.Label Label1 
      Caption         =   "Коэф-нт одометра по умолчанию"
      Height          =   255
      Index           =   7
      Left            =   120
      TabIndex        =   22
      Top             =   2400
      Width           =   3135
   End
   Begin VB.Label Label1 
      Caption         =   "Длина окна графика скорости, м"
      Height          =   255
      Index           =   4
      Left            =   120
      TabIndex        =   20
      Top             =   2040
      Width           =   3135
   End
   Begin VB.Label Label1 
      Caption         =   "Диаметр,мм"
      Height          =   255
      Index           =   6
      Left            =   120
      TabIndex        =   19
      Top             =   240
      Width           =   1575
   End
   Begin VB.Label Label1 
      Caption         =   "Стенка трубы"
      Height          =   255
      Index           =   5
      Left            =   3840
      TabIndex        =   18
      Top             =   240
      Width           =   1095
   End
   Begin VB.Label Label1 
      Caption         =   "Палитра"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   17
      Top             =   1680
      Width           =   1095
   End
   Begin VB.Label Label1 
      Caption         =   "Файл"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   16
      Top             =   1440
      Width           =   1095
   End
   Begin VB.Label Label1 
      Caption         =   "Расширения"
      Height          =   255
      Index           =   1
      Left            =   3840
      TabIndex        =   15
      Top             =   0
      Width           =   1095
   End
   Begin VB.Label Label1 
      Caption         =   "Описание"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   14
      Top             =   1080
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Идентификатор"
      Height          =   255
      Index           =   16
      Left            =   120
      TabIndex        =   13
      Top             =   0
      Width           =   1455
   End
End
Attribute VB_Name = "frmDriver"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private act As Boolean
Private drv As clsDriver
Private nFlag As Boolean
Private hlp As New clsHelp

Public Function Edit(krtDrv As clsDriver, ByVal newFlag As Boolean) As Boolean
Set drv = krtDrv
Load Me
nFlag = newFlag
If nFlag Then
 txtID.enabled = True
 Me.Caption = "Подключение нового драйвера"
 Else
 txtID.enabled = False
 Me.Caption = "Изменение настроек драйвера"
End If
centerForm frmMain, Me
setControls
act = False
Me.Show 1, frmMain
Edit = act
End Function

Private Sub setControls()
txtID.Text = drv.id
txtExt.Text = drv.fileExt
txtDiam.Text = drv.diamDflt
sclx.Caption = "Масштабы развертки по X"
scly.Caption = "Масштабы развертки по Y"
sclx.sclString = drv.scales(True)
scly.sclString = drv.scales(False)
sclx.dfltScale = drv.scaleDflt(True)
scly.dfltScale = drv.scaleDflt(False)
txtDll.Text = drv.dll
txtPal.Text = drv.pallete
txtName.Text = drv.descripion
txtThick.Text = drv.wallThick
txtOdo.Text = dblStr(drv.odoKoef)
txtProf0.Text = drv.profZero
txtProfPigLength.Text = drv.profPigLength
chkIsProfil.Value = Abs(drv.IsProfil)
txtOdoAngle.Text = drv.OdoAngle
speedVector.Min = SV_MIN
speedVector.Max = SV_MAX
speedVector.Value = drv.speedVector

Dim m As clsMagnit, dfltindx As Integer

Set m = cfg.magnets.Item("")
lstMagnet.addItem m.Description
lstMagnet.ItemData(lstMagnet.ListCount - 1) = -1
dfltindx = 0

For Each m In cfg.magnets
 lstMagnet.addItem m.Description
 lstMagnet.ItemData(lstMagnet.ListCount - 1) = m.idNum
 If m.id = drv.magnit.id Then
   dfltindx = lstMagnet.ListCount - 1
 End If
Next
lstMagnet.ListIndex = dfltindx
End Sub

Private Function findDrv(id As String) As Boolean
Dim c As clsDriver

findDrv = True
For Each c In cfg.Drivers
 If c.id = id Then Exit Function
Next
findDrv = False
End Function

Private Function checkDriver() As Boolean
Dim s As String, drv As clsDriver

checkDriver = False
Set drv = cfg.Drivers.Item(txtID.Text)

If drv Is Nothing Then
 ogdWin.Alert drv.errText
 Exit Function
End If

s = Trim(UCase(txtID.Text))

If Len(s) = 0 Then
 ogdWin.Alert "Не указана сигнатура драйвера"
 Exit Function
End If

If nFlag Then
 If findDrv(s) Then
  ogdWin.Alert "Сигнатуру " & s & " имеет драйвер" & _
  vbNewLine & cfg.Drivers(s).descripion
  Exit Function
 End If
End If

checkDriver = True
End Function

Private Sub getControls()
If nFlag Then drv.Init cfg.fName, UCase(txtID.Text), 0, cfg.magnets
drv.fileExt = txtExt.Text
drv.diamDflt = txtDiam.Text
drv.scalesSet True, sclx.sclString
drv.scalesSet False, scly.sclString

drv.scaleDfltSet True, sclx.dfltScale
drv.scaleDfltSet False, scly.dfltScale

drv.dll = txtDll.Text
drv.pallete = txtPal.Text
drv.descripion = txtName.Text
drv.wallThick = txtThick.Text

drv.odoKoef = val(txtOdo.Text)
drv.speedVector = speedVector.Value
drv.profZero = val(txtProf0.Text)

drv.profPigLength = val(txtProfPigLength.Text)
drv.IsProfil = CBool(chkIsProfil.Value)
drv.OdoAngle = val(txtOdoAngle.Text)

drv.magnit.setID cfg.magnets.ItemNum(lstMagnet.ListIndex).id
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0
  If checkDriver() = False Then Exit Sub
  getControls
  act = True
End Select
Unload Me
End Sub

Private Sub btmDll_Click()
ogdWin.fileOpen _
 "Выберите файл драйвера", _
 drv.dll, _
 cfg.dir.trc, _
 "Файлы драйверов (*.dll)|*.dll", _
 Me.hWnd, _
 txtDll
End Sub

Private Sub btmPal_Click()
ogdWin.fileOpen _
 "Выберите файл палитры по умолчанию", _
 drv.pallete, _
 cfg.dir.pal, _
 "Файлы палитр (*.kpl)|*.kpl", _
 Me.hWnd, _
 txtPal
End Sub

Private Sub Form_Load()
hlp.BindHelp Me, KRT_CfgDriver
End Sub