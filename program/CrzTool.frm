VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.1#0"; "mscomctl.ocx"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Begin VB.Form frmCrzTool 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Настройка коррозионной развертки"
   ClientHeight    =   5850
   ClientLeft      =   6105
   ClientTop       =   6765
   ClientWidth     =   5625
   Icon            =   "CrzTool.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5850
   ScaleWidth      =   5625
   ShowInTaskbar   =   0   'False
   Begin VB.Frame frameAlign 
      Caption         =   "Расположение поясов"
      Height          =   615
      Left            =   120
      TabIndex        =   27
      Top             =   240
      Width           =   5415
      Begin VB.OptionButton optAlign 
         Caption         =   "горизонтально"
         Height          =   255
         Index           =   1
         Left            =   2760
         TabIndex        =   1
         Top             =   240
         Width           =   2415
      End
      Begin VB.OptionButton optAlign 
         Caption         =   "вертикально"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   0
         Top             =   240
         Width           =   2415
      End
   End
   Begin VB.Frame zfrm 
      BorderStyle     =   0  'None
      Height          =   7095
      Index           =   0
      Left            =   120
      TabIndex        =   18
      Top             =   1320
      Width           =   5415
      Begin VB.CheckBox chkFIlterTFI 
         Height          =   255
         Index           =   0
         Left            =   2640
         TabIndex        =   51
         ToolTipText     =   "базовая линия"
         Top             =   4800
         Width           =   255
      End
      Begin MSComctlLib.Slider sldFilterParam 
         Height          =   255
         Index           =   0
         Left            =   1440
         TabIndex        =   37
         Top             =   4080
         Width           =   1575
         _ExtentX        =   2778
         _ExtentY        =   450
         _Version        =   393216
         Min             =   1
         Max             =   30
         SelStart        =   1
         TickFrequency   =   5
         Value           =   1
      End
      Begin VB.ComboBox lstFilter 
         Height          =   315
         Index           =   0
         ItemData        =   "CrzTool.frx":0442
         Left            =   120
         List            =   "CrzTool.frx":0444
         Style           =   2  'Dropdown List
         TabIndex        =   36
         Top             =   3600
         Width           =   2895
      End
      Begin VB.Frame frameScaleMode 
         Caption         =   "Тип масштабирования"
         Height          =   1695
         Index           =   0
         Left            =   3120
         TabIndex        =   30
         Top             =   1680
         Width           =   2175
         Begin VB.OptionButton rbtnScaleMode3 
            Caption         =   "прореживание"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   34
            Top             =   960
            Width           =   1815
         End
         Begin VB.OptionButton rbtnScaleMode2 
            Caption         =   "выбор среднего"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   33
            Top             =   720
            Width           =   1815
         End
         Begin VB.OptionButton rbtnScaleMode1 
            Caption         =   "выбор минимума"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   32
            Top             =   480
            Width           =   1935
         End
         Begin VB.OptionButton rbtnScaleMode0 
            Caption         =   "выбор максимума"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   31
            Top             =   240
            Width           =   1935
         End
      End
      Begin VB.Frame framePal 
         Caption         =   "Палитра"
         Height          =   735
         Index           =   0
         Left            =   120
         TabIndex        =   29
         Top             =   960
         Width           =   2295
         Begin VB.CommandButton btmPalLoad 
            Caption         =   "Загрузить"
            Height          =   375
            Index           =   0
            Left            =   1200
            TabIndex        =   6
            Top             =   240
            Width           =   975
         End
         Begin VB.CommandButton btmPalEdit 
            Caption         =   "Редактор"
            Height          =   375
            Index           =   0
            Left            =   120
            TabIndex        =   5
            Top             =   240
            Width           =   975
         End
      End
      Begin VB.Frame frameObj 
         Caption         =   "Отображение обьектов"
         Height          =   975
         Index           =   0
         Left            =   3120
         TabIndex        =   28
         Top             =   3480
         Width           =   2175
         Begin VB.CheckBox chkObjSlit 
            Caption         =   "продольные швы"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   14
            Top             =   240
            Width           =   1935
         End
         Begin VB.CheckBox chkObjWeld 
            Caption         =   "поперечные швы"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   15
            Top             =   480
            Width           =   1935
         End
      End
      Begin VB.CheckBox chkTubeProfil 
         Caption         =   "Профиль трубы"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   13
         ToolTipText     =   "Графики отображают сырые данные"
         Top             =   3000
         Visible         =   1   'True
         Width           =   1575
      End
      Begin VB.CheckBox chkOn 
         Caption         =   "вкл"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   2
         Top             =   120
         Width           =   615
      End
      Begin VB.CheckBox chkCircle 
         Caption         =   "Срез датчиков"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   12
         ToolTipText     =   "Графики отображают сырые данные"
         Top             =   2760
         Width           =   1455
      End
      Begin VB.CheckBox chkOneSens 
         Caption         =   "График датчика"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   11
         ToolTipText     =   "Графики отображают сырые данные"
         Top             =   2520
         Width           =   1815
      End
      Begin VB.ComboBox lstYscale 
         Height          =   315
         Index           =   0
         Left            =   3720
         Style           =   2  'Dropdown List
         TabIndex        =   7
         Top             =   1080
         Width           =   1695
      End
      Begin VB.CheckBox chkRowData 
         Caption         =   "Сырые"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   10
         ToolTipText     =   "Графики отображают сырые данные"
         Top             =   2280
         Width           =   975
      End
      Begin VB.CommandButton btmSens 
         Caption         =   "Датчики"
         Height          =   375
         Index           =   0
         Left            =   3840
         TabIndex        =   24
         ToolTipText     =   "Настройка отображения датчиков"
         Top             =   5400
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.CommandButton btmIntWin 
         Caption         =   "Интеграл"
         Height          =   375
         Index           =   0
         Left            =   3840
         TabIndex        =   23
         ToolTipText     =   "Длина окна интегрирования"
         Top             =   5880
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.CommandButton btmAmplif 
         Caption         =   "Усиление"
         Height          =   375
         Index           =   0
         Left            =   3840
         TabIndex        =   22
         ToolTipText     =   "Коэффициент усиления сигнала"
         Top             =   6360
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.CheckBox chkMark 
         Caption         =   "Маркера"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   9
         ToolTipText     =   "Отрисовывать маркера"
         Top             =   2040
         Width           =   975
      End
      Begin VB.CheckBox chkOrnt 
         Caption         =   "Ориентация"
         Height          =   255
         Index           =   0
         Left            =   2520
         TabIndex        =   19
         ToolTipText     =   "Учет ориентации снаряда при отрисовке развертки"
         Top             =   5520
         Visible         =   0   'False
         Width           =   1215
      End
      Begin VB.CheckBox chkBase 
         Caption         =   "Вырав. (Ctrl+V)"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   8
         ToolTipText     =   "Режим поперечного выравнивания короз.датчиков по левой границе развертки"
         Top             =   1800
         Width           =   2175
      End
      Begin krotw32.ctrlPallete pallette 
         Height          =   450
         Index           =   0
         Left            =   1200
         TabIndex        =   4
         Top             =   480
         Width           =   4155
         _ExtentX        =   7329
         _ExtentY        =   794
      End
      Begin krotw32.ctrlCorozGraph graf 
         Height          =   495
         Index           =   0
         Left            =   120
         TabIndex        =   3
         Top             =   480
         Width           =   495
         _ExtentX        =   873
         _ExtentY        =   873
      End
      Begin VB.Label labFIlterValTFI1 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Index           =   0
         Left            =   840
         TabIndex        =   50
         ToolTipText     =   "ширина окна фильтра в отсчетах одометра"
         Top             =   4800
         Width           =   375
      End
      Begin VB.Label labFIlterValTFI2 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Index           =   0
         Left            =   2160
         TabIndex        =   49
         ToolTipText     =   "усиление фильтра"
         Top             =   4800
         Width           =   375
      End
      Begin VB.Label labFIlterTFI2 
         Caption         =   "усиление"
         Height          =   255
         Index           =   0
         Left            =   1320
         TabIndex        =   48
         Top             =   4800
         Width           =   735
      End
      Begin VB.Label labFIlterTFI1 
         Caption         =   "ширина"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   47
         Top             =   4800
         Width           =   615
      End
      Begin VB.Label labFIlterValAmplifer 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Index           =   0
         Left            =   2520
         TabIndex        =   46
         ToolTipText     =   "коэффициент усиления вейвлет-фильтра"
         Top             =   4440
         Width           =   375
      End
      Begin VB.Label labFIlterAmplifer 
         Caption         =   "z"
         Height          =   255
         Index           =   0
         Left            =   2160
         TabIndex        =   45
         Top             =   4440
         Width           =   255
      End
      Begin VB.Label labFIlterRolled1 
         Caption         =   "x1"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   44
         Top             =   4440
         Width           =   255
      End
      Begin VB.Label labFIlterRolled2 
         Caption         =   "x2"
         Height          =   255
         Index           =   0
         Left            =   960
         TabIndex        =   43
         Top             =   4440
         Width           =   255
      End
      Begin VB.Label labFIlterValRolled1 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Index           =   0
         Left            =   480
         TabIndex        =   42
         ToolTipText     =   "начальная ширина окна вейвлет-фильтра"
         Top             =   4440
         Width           =   375
      End
      Begin VB.Label labFIlterValRolled2 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "0"
         Height          =   255
         Index           =   0
         Left            =   1320
         TabIndex        =   41
         ToolTipText     =   "конечная ширина окна вейвлет-фильтра"
         Top             =   4440
         Width           =   375
      End
      Begin VB.Label labFilterParamValue 
         Caption         =   "0"
         Height          =   255
         Index           =   0
         Left            =   1080
         TabIndex        =   40
         Top             =   4080
         Width           =   375
      End
      Begin VB.Label labFIlterParam 
         Caption         =   "Параметр"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   39
         Top             =   4080
         Width           =   855
      End
      Begin VB.Label labFilter 
         Caption         =   "Фильтр"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   35
         Top             =   3360
         Width           =   735
      End
      Begin VB.Label labScale 
         Caption         =   "Масштаб по Y"
         Height          =   255
         Index           =   0
         Left            =   2520
         TabIndex        =   26
         Top             =   1080
         Width           =   1095
      End
      Begin VB.Label labName 
         Caption         =   "Наименование пояса"
         Height          =   255
         Index           =   0
         Left            =   1200
         TabIndex        =   25
         Top             =   135
         Width           =   4215
      End
      Begin VB.Label labIntWin 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Label1"
         Height          =   255
         Index           =   0
         Left            =   2760
         TabIndex        =   21
         Top             =   5880
         Visible         =   0   'False
         Width           =   855
      End
      Begin VB.Label labAmplif 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Label1"
         Height          =   255
         Index           =   0
         Left            =   2760
         TabIndex        =   20
         Top             =   6360
         Visible         =   0   'False
         Width           =   855
      End
   End
   Begin TabDlg.SSTab zone 
      Height          =   420
      Left            =   120
      TabIndex        =   16
      Top             =   960
      Width           =   5055
      _ExtentX        =   8916
      _ExtentY        =   741
      _Version        =   393216
      Style           =   1
      Tabs            =   1
      TabsPerRow      =   7
      TabHeight       =   520
      TabCaption(0)   =   "Tab 0"
      TabPicture(0)   =   "CrzTool.frx":0446
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).ControlCount=   0
   End
   Begin VB.Label Label2 
      Caption         =   "Label2"
      Height          =   255
      Left            =   240
      TabIndex        =   38
      Top             =   5400
      Width           =   1695
   End
   Begin VB.Label labTrace 
      Caption         =   "Label1"
      Height          =   255
      Left            =   120
      TabIndex        =   17
      Top             =   0
      Width           =   5415
   End
End
Attribute VB_Name = "frmCrzTool"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private crz As clsCorozZones
Attribute crz.VB_VarHelpID = -1
Private trc As clsTrace
Private initFlag As Boolean
Private scales As New clsCommandLine
Private hlp As New clsHelp

Private WithEvents frmPal As frmPalette
Attribute frmPal.VB_VarHelpID = -1
Private editIndex As Integer
Private XYScaleMode As Integer

Public Event off()
Public Event changeZone(ByVal Index As Integer)
Public Event changeSensRow(ByVal Index As Integer)
Public Event redraw(ByVal Index As Integer)
Public Event sizeChange()
Public Event tubeProfil()

Private Sub setupZone(ByVal indx As Integer)
Dim czone As clsCoroz, i As Integer, itm As Integer, tp As Long

Set czone = crz.zone(indx)

For i = 1 To scales.count
 itm = val(scales.Item(i))
 lstYscale(indx).addItem cfg.crz.scaleText(itm)
 lstYscale(indx).ItemData(lstYscale(indx).ListCount - 1) = itm
 If itm = czone.scaleY Then lstYscale(indx).ListIndex = lstYscale(indx).ListCount - 1
Next

chkOn(indx).Value = IIf(indx = 0, 2, IIf(czone.visible, 1, 0))
chkOn(indx).enabled = IIf(indx = 0, False, True)

labName(indx).Caption = czone.name & " (" & decorSensNum(czone.num) & ")"
zone.TabCaption(indx) = "пояс " & (indx + 1)
With graf(indx)
.gapMin = czone.grKoefSnsMin
.gapMax = czone.grKoefSnsMax
.gap = czone.grKoefSns
.amplifMin = czone.grKoefMulMin
.amplifMax = czone.grKoefMulMax
.amplif = czone.grKoefMul
.isOn = czone.isGraph
End With
chkRowData(indx).visible = czone.isRowPresent
pallette(indx).Init trc, czone
chkBase(indx).Value = IIf(czone.baseLine < 0, 0, 1)
chkMark(indx).Value = IIf(czone.isMarkDraw, 1, 0)
chkRowData(indx).Value = IIf(czone.isRow, 1, 0)
chkOneSens(indx).Value = IIf(czone.oneSens.visible, 1, 0)
chkCircle(indx).Value = IIf(czone.circl.visible, 1, 0)

chkObjSlit(indx).Value = IIf(czone.showObjSlit, 1, 0)
chkObjWeld(indx).Value = IIf(czone.showObjWeld, 1, 0)

rbtnScaleMode0(indx).Value = 1

'If czone.sensType = SENS_PROFIL Then
 chkTubeProfil(indx).visible = True
 chkTubeProfil(indx).Value = IIf(czone.isTubeProfVisible, 1, 0)
'End If

lstFilter(indx).addItem "отключен"
lstFilter(indx).addItem "чешка"
lstFilter(indx).addItem "цельнотянутая"
lstFilter(indx).addItem "пригрузы"
lstFilter(indx).addItem "продольные трещины"
lstFilter(indx).addItem "без математики Ctrl+M"
lstFilter(indx).addItem "фильтр 2021"
lstFilter(indx).addItem "фильтр 2019"
lstFilter(indx).addItem "фильтр Свертка Лапласиан"
lstFilter(indx).addItem "фильтр Свертка Резкость"
lstFilter(indx).addItem "фильтр Медианное усреднение"

lstFilter(indx).ListIndex = czone.filterType

tp = labFIlterParam(indx).Top
labFIlterRolled1(indx).Top = tp
labFIlterValRolled1(indx).Top = tp
labFIlterRolled2(indx).Top = tp
labFIlterValRolled2(indx).Top = tp
labFIlterAmplifer(indx).Top = tp
labFIlterValAmplifer(indx).Top = tp

labFIlterTFI1(indx).Top = tp
labFIlterValTFI1(indx).Top = tp
labFIlterTFI2(indx).Top = tp
labFIlterValTFI2(indx).Top = tp
chkFIlterTFI(indx).Top = tp

sldFilterParam(indx).LargeChange = 5
sldFilterParam(indx).max = 30
sldFilterParam(indx).min = 1
sldFilterParam(indx).TickFrequency = 5
sldFilterParam(indx).Value = czone.filterUnweldParam
labFIlterValRolled1(indx).Caption = czone.filterRolled1Param
labFIlterValRolled2(indx).Caption = czone.filterRolled2Param
labFIlterValAmplifer(indx).Caption = czone.filterRolledAmplifer
labFIlterValTFI1(indx).Caption = czone.filterTFI1Param
labFIlterValTFI2(indx).Caption = czone.filterTFI2Param
chkFIlterTFI(indx).Value = czone.filterTFIbase

sldFilterParam_Change indx
End Sub

Public Sub tubeProfilSwitch()
Dim i As Integer

initFlag = True
For i = 0 To crz.num - 1
 chkTubeProfil(i).Value = 1 'IIf(crz.zone(i).isTubeProfVisible, 1, 0)
Next
initFlag = False
End Sub

Public Sub oneSensOff(ByVal indx As Integer)
initFlag = True
chkOneSens(indx).Value = 0
initFlag = False
End Sub

Public Sub circleOff(ByVal indx As Integer)
initFlag = True
chkCircle(indx).Value = 0
initFlag = False
End Sub

Public Sub Init(trace As clsTrace)
Dim i As Integer

initFlag = True

Set trc = trace
Set crz = trc.Coroz

scales.Delim = ";"
scales.TestString = cfg.parser.Delim & trc.drv.scales(False)
scales.Parse

labTrace.Caption = trc.Description
zone.Tabs = crz.num

If crz.num > 1 Then
 i = IIf(crz.isAlignVert, 1, 0)
 optAlign(i).Value = True
 Else
 optAlign(0).Value = True
 frameAlign.enabled = False
 optAlign(0).enabled = False
 optAlign(1).enabled = False
End If

setupZone 0

For i = 1 To crz.num - 1
  Load zfrm(i)
  zfrm(i).Left = zfrm(i - 1).Left
  zfrm(i).Top = zfrm(i - 1).Top

  Load chkOn(i)
  Set chkOn(i).Container = zfrm(i)
  chkOn(i).Left = chkOn(i - 1).Left
  chkOn(i).Top = chkOn(i - 1).Top
  chkOn(i).visible = True

  Load pallette(i)
  Set pallette(i).Container = zfrm(i)
  pallette(i).Left = pallette(i - 1).Left
  pallette(i).Top = pallette(i - 1).Top
  pallette(i).visible = True

  Load labName(i)
  Set labName(i).Container = zfrm(i)
  labName(i).Left = labName(i - 1).Left
  labName(i).Top = labName(i - 1).Top
  labName(i).visible = True

  Load chkBase(i)
  Set chkBase(i).Container = zfrm(i)
  chkBase(i).Left = chkBase(i - 1).Left
  chkBase(i).Top = chkBase(i - 1).Top
  chkBase(i).visible = True

  Load chkRowData(i)
  Set chkRowData(i).Container = zfrm(i)
  chkRowData(i).Left = chkRowData(i - 1).Left
  chkRowData(i).Top = chkRowData(i - 1).Top
  chkRowData(i).visible = True

  Load chkMark(i)
  Set chkMark(i).Container = zfrm(i)
  chkMark(i).Left = chkMark(i - 1).Left
  chkMark(i).Top = chkMark(i - 1).Top
  chkMark(i).visible = True

  Load graf(i)
  Set graf(i).Container = zfrm(i)
  graf(i).Left = graf(i - 1).Left
  graf(i).Top = graf(i - 1).Top
  graf(i).visible = True

  Load labScale(i)
  Set labScale(i).Container = zfrm(i)
  labScale(i).Left = labScale(i - 1).Left
  labScale(i).Top = labScale(i - 1).Top
  labScale(i).visible = True

  Load lstYscale(i)
  Set lstYscale(i).Container = zfrm(i)
  lstYscale(i).Left = lstYscale(i - 1).Left
  lstYscale(i).Top = lstYscale(i - 1).Top
  lstYscale(i).visible = True

  Load framePal(i)
  Set framePal(i).Container = zfrm(i)
  framePal(i).Left = framePal(i - 1).Left
  framePal(i).Top = framePal(i - 1).Top
  framePal(i).visible = True
  
  Load btmPalEdit(i)
  Set btmPalEdit(i).Container = framePal(i)
  btmPalEdit(i).Left = btmPalEdit(i - 1).Left
  btmPalEdit(i).Top = btmPalEdit(i - 1).Top
  btmPalEdit(i).visible = True

  Load btmPalLoad(i)
  Set btmPalLoad(i).Container = framePal(i)
  btmPalLoad(i).Left = btmPalLoad(i - 1).Left
  btmPalLoad(i).Top = btmPalLoad(i - 1).Top
  btmPalLoad(i).visible = True

  Load frameObj(i)
  Set frameObj(i).Container = zfrm(i)
  frameObj(i).Left = frameObj(i - 1).Left
  frameObj(i).Top = frameObj(i - 1).Top
  frameObj(i).visible = True
  
  Load chkObjSlit(i)
  Set chkObjSlit(i).Container = frameObj(i)
  chkObjSlit(i).Left = chkObjSlit(i - 1).Left
  chkObjSlit(i).Top = chkObjSlit(i - 1).Top
  chkObjSlit(i).visible = True
  
  Load chkObjWeld(i)
  Set chkObjWeld(i).Container = frameObj(i)
  chkObjWeld(i).Left = chkObjWeld(i - 1).Left
  chkObjWeld(i).Top = chkObjWeld(i - 1).Top
  chkObjWeld(i).visible = True

  Load chkOneSens(i)
  Set chkOneSens(i).Container = zfrm(i)
  chkOneSens(i).Left = chkOneSens(i - 1).Left
  chkOneSens(i).Top = chkOneSens(i - 1).Top
  chkOneSens(i).visible = True

  Load chkCircle(i)
  Set chkCircle(i).Container = zfrm(i)
  chkCircle(i).Left = chkCircle(i - 1).Left
  chkCircle(i).Top = chkCircle(i - 1).Top
  chkCircle(i).visible = True

  Load chkTubeProfil(i)
  Set chkTubeProfil(i).Container = zfrm(i)
  chkTubeProfil(i).Left = chkTubeProfil(i - 1).Left
  chkTubeProfil(i).Top = chkTubeProfil(i - 1).Top
  chkTubeProfil(i).visible = False

  Load frameScaleMode(i)
  Set frameScaleMode(i).Container = zfrm(i)
  frameScaleMode(i).Left = frameScaleMode(i - 1).Left
  frameScaleMode(i).Top = frameScaleMode(i - 1).Top
  frameScaleMode(i).visible = True
  
  Load rbtnScaleMode0(i)
  Set rbtnScaleMode0(i).Container = frameScaleMode(i)
  rbtnScaleMode0(i).Left = rbtnScaleMode0(i - 1).Left
  rbtnScaleMode0(i).Top = rbtnScaleMode0(i - 1).Top
  rbtnScaleMode0(i).visible = True
  rbtnScaleMode0(i - 1).Value = True
  
  Load rbtnScaleMode1(i)
  Set rbtnScaleMode1(i).Container = frameScaleMode(i)
  rbtnScaleMode1(i).Left = rbtnScaleMode1(i - 1).Left
  rbtnScaleMode1(i).Top = rbtnScaleMode1(i - 1).Top
  rbtnScaleMode1(i).visible = True
  
  Load rbtnScaleMode2(i)
  Set rbtnScaleMode2(i).Container = frameScaleMode(i)
  rbtnScaleMode2(i).Left = rbtnScaleMode2(i - 1).Left
  rbtnScaleMode2(i).Top = rbtnScaleMode2(i - 1).Top
  rbtnScaleMode2(i).visible = True
  
  Load rbtnScaleMode3(i)
  Set rbtnScaleMode3(i).Container = frameScaleMode(i)
  rbtnScaleMode3(i).Left = rbtnScaleMode3(i - 1).Left
  rbtnScaleMode3(i).Top = rbtnScaleMode3(i - 1).Top
  rbtnScaleMode3(i).visible = True
  
  Load lstFilter(i)
  Set lstFilter(i).Container = zfrm(i)
  lstFilter(i).Left = lstFilter(i - 1).Left
  lstFilter(i).Top = lstFilter(i - 1).Top
  lstFilter(i).visible = True
  
  Load labFIlterParam(i)
  Set labFIlterParam(i).Container = zfrm(i)
  labFIlterParam(i).Left = labFIlterParam(i - 1).Left
  labFIlterParam(i).Top = labFIlterParam(i - 1).Top
  labFIlterParam(i).visible = True
  
  Load sldFilterParam(i)
  Set sldFilterParam(i).Container = zfrm(i)
  sldFilterParam(i).Left = sldFilterParam(i - 1).Left
  sldFilterParam(i).Top = sldFilterParam(i - 1).Top
  sldFilterParam(i).visible = True
  
  Load labFilterParamValue(i)
  Set labFilterParamValue(i).Container = zfrm(i)
  labFilterParamValue(i).Left = labFilterParamValue(i - 1).Left
  labFilterParamValue(i).Top = labFilterParamValue(i - 1).Top
  labFilterParamValue(i).visible = True
  
  Load labFIlterRolled1(i)
  Set labFIlterRolled1(i).Container = zfrm(i)
  labFIlterRolled1(i).Left = labFIlterRolled1(i - 1).Left
  labFIlterRolled1(i).Top = labFIlterRolled1(i - 1).Top
  labFIlterRolled1(i).visible = True
  
  Load labFIlterValRolled1(i)
  Set labFIlterValRolled1(i).Container = zfrm(i)
  labFIlterValRolled1(i).Left = labFIlterValRolled1(i - 1).Left
  labFIlterValRolled1(i).Top = labFIlterValRolled1(i - 1).Top
  labFIlterValRolled1(i).visible = True
  
  Load labFIlterRolled2(i)
  Set labFIlterRolled2(i).Container = zfrm(i)
  labFIlterRolled2(i).Left = labFIlterRolled2(i - 1).Left
  labFIlterRolled2(i).Top = labFIlterRolled2(i - 1).Top
  labFIlterRolled2(i).visible = True
  
  Load labFIlterAmplifer(i)
  Set labFIlterAmplifer(i).Container = zfrm(i)
  labFIlterAmplifer(i).Left = labFIlterAmplifer(i - 1).Left
  labFIlterAmplifer(i).Top = labFIlterAmplifer(i - 1).Top
  labFIlterAmplifer(i).visible = True
  
  Load labFIlterValAmplifer(i)
  Set labFIlterValAmplifer(i).Container = zfrm(i)
  labFIlterValAmplifer(i).Left = labFIlterValAmplifer(i - 1).Left
  labFIlterValAmplifer(i).Top = labFIlterValAmplifer(i - 1).Top
  labFIlterValAmplifer(i).visible = True
  
  Load labFIlterValRolled2(i)
  Set labFIlterValRolled2(i).Container = zfrm(i)
  labFIlterValRolled2(i).Left = labFIlterValRolled2(i - 1).Left
  labFIlterValRolled2(i).Top = labFIlterValRolled2(i - 1).Top
  labFIlterValRolled2(i).visible = True
  
  Load labFilter(i)
  Set labFilter(i).Container = zfrm(i)
  labFilter(i).Left = labFilter(i - 1).Left
  labFilter(i).Top = labFilter(i - 1).Top
  labFilter(i).visible = True

  Load labFIlterTFI1(i)
  Set labFIlterTFI1(i).Container = zfrm(i)
  labFIlterTFI1(i).Left = labFIlterTFI1(i - 1).Left
  labFIlterTFI1(i).Top = labFIlterTFI1(i - 1).Top
  labFIlterTFI1(i).visible = True

  Load labFIlterValTFI1(i)
  Set labFIlterValTFI1(i).Container = zfrm(i)
  labFIlterValTFI1(i).Left = labFIlterValTFI1(i - 1).Left
  labFIlterValTFI1(i).Top = labFIlterValTFI1(i - 1).Top
  labFIlterValTFI1(i).visible = True

  Load labFIlterTFI2(i)
  Set labFIlterTFI2(i).Container = zfrm(i)
  labFIlterTFI2(i).Left = labFIlterTFI2(i - 1).Left
  labFIlterTFI2(i).Top = labFIlterTFI2(i - 1).Top
  labFIlterTFI2(i).visible = True

  Load labFIlterValTFI2(i)
  Set labFIlterValTFI2(i).Container = zfrm(i)
  labFIlterValTFI2(i).Left = labFIlterValTFI2(i - 1).Left
  labFIlterValTFI2(i).Top = labFIlterValTFI2(i - 1).Top
  labFIlterValTFI2(i).visible = True

  Load chkFIlterTFI(i)
  Set chkFIlterTFI(i).Container = zfrm(i)
  chkFIlterTFI(i).Left = chkFIlterTFI(i - 1).Left
  chkFIlterTFI(i).Top = chkFIlterTFI(i - 1).Top
  chkFIlterTFI(i).visible = True

  setupZone i

Next
initFlag = False
End Sub

Private Sub btmAmplif_Click(Index As Integer)
Dim s As String

s = InputBox( _
 "Коэффициент усиления сигнала:", _
 "Настройка развертки", _
 labAmplif(Index).Caption, _
 Me.Left, Me.Top)

If s = "" Then Exit Sub
Me.valAmplif(Index) = Fix(val(s))
End Sub

Property Get valAmplif(ByVal indx As Integer) As Integer
valAmplif = val(labAmplif(indx).Caption)
End Property

Property Let valAmplif(ByVal indx As Integer, i As Integer)
If i < 1 Then i = 1
labAmplif(indx).Caption = i
crz.zone(indx).setGraphsMode crz.zone(indx).grKoefSns, i, crz.zone(indx).isGraph
End Property

Private Sub btmPalEdit_Click(Index As Integer)
Set frmPal = New frmPalette
editIndex = Index

If frmPal.EditCurrent(Me, crz.zone(Index)) Then
 pallette_Change Index
End If
End Sub

Private Sub btmPalLoad_Click(Index As Integer)
Dim Pal As String
Dim czone As clsCoroz

Set czone = crz.zone(Index)

Pal = ogdWin.fileOpen( _
 "Выберите файл палитры", _
 czone.palette.file, _
 cfg.dir.Pal, _
 "Файлы палитры (*.kpl)|*.kpl", _
 frmMain.hwnd _
)

If Pal = "" Then Exit Sub

If czone.palette.LoadFromFile(Pal) Then
 pallette_Change Index
 Else
 ogdWin.Alert "Ошибка при загрузке палитры." & vbNewLine & czone.palette.errText
End If
End Sub

Private Sub chkBase_Click(Index As Integer)
If chkBase(Index).Value = 0 Then
 crz.zone(Index).baseLine = -1
 chkBase(Index).ToolTipText = "Выравнивание отключено"
 Else
 crz.zone(Index).baseLine = trc.pageStart
 chkBase(Index).ToolTipText = _
  "Выравнивание по отметке " & mm2txt(trc.getDistKoef(trc.pageStart))
End If

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub chkMark_Click(Index As Integer)
crz.zone(Index).isMarkDraw = IIf(chkMark(Index).Value = 0, False, True)

If initFlag Then Exit Sub
RaiseEvent redraw(Index)
End Sub

Private Sub chkObjSlit_Click(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).showObjSlit = IIf(chkObjSlit(Index).Value = 0, False, True)
RaiseEvent sizeChange 'changeZone(Index)
End Sub

Private Sub chkObjWeld_Click(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).showObjWeld = IIf(chkObjWeld(Index).Value = 0, False, True)
RaiseEvent sizeChange 'changeZone(Index)
End Sub

Private Sub chkOn_Click(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).visible = IIf(chkOn(Index).Value = 0, False, True)
RaiseEvent sizeChange
End Sub

Private Sub chkCircle_Click(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).circl.visible = IIf(chkCircle(Index).Value = 0, False, True)
RaiseEvent sizeChange
End Sub

Private Sub chkOneSens_Click(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).oneSens.visible = IIf(chkOneSens(Index).Value = 0, False, True)
RaiseEvent sizeChange
End Sub

Private Sub chkRowData_Click(Index As Integer)
crz.zone(Index).isRow = IIf(chkRowData(Index).Value = 0, False, True)
If initFlag Then Exit Sub
RaiseEvent changeSensRow(Index)
End Sub

Private Sub chkTubeProfil_Click(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).isTubeProfVisible = IIf(chkTubeProfil(Index).Value = 0, False, True)
RaiseEvent tubeProfil
End Sub

Public Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
Dim i As Integer, j As Integer

Select Case KeyCode
 
 Case VK_V
  For j = 0 To crz.num - 1
    If crz.zone(j).visible Then
      If isControlDown() Then
        i = 1
        If chkBase(j).Value = 1 Then
          i = 0
        End If
        chkBase(j).Value = i
      End If
    End If
  Next

 Case VK_M
  If isControlDown() Then
    
    If crz.zone(0).filterType = lstFilter(0).ListIndex Then
      filterUnweldOn 0, False
      filterRollOn 0, False
      filterTFIOn 0, False
      crz.zone(0).filterType = 5
    Else
      lstFilter_Click 0
      'crz.zone(0).filterType = lstFilter(0).ListIndex
    End If
  
    RaiseEvent changeZone(0)
    setReady
  
  End If

End Select
End Sub

Private Sub Form_Load()
hlp.BindHelp Me, KRT_AnaCorozTube
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.visible = False
 RaiseEvent off
End If
End Sub

Private Sub frmPal_Change()
pallette_Change editIndex
End Sub

Private Sub graf_OnOff(Index As Integer)
pallette(Index).visible = Not graf(Index).isOn
crz.zone(Index).setGraphsMode crz.zone(Index).grKoefSns, crz.zone(Index).grKoefMul, graf(Index).isOn

If initFlag Then Exit Sub
RaiseEvent redraw(Index)
End Sub

Private Sub graf_paramChange(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).setGraphsMode graf(Index).gap, graf(Index).amplif, crz.zone(Index).isGraph
RaiseEvent redraw(Index)
End Sub

Private Sub filterUnweldOn(Index As Integer, isOn As Boolean)
Select Case lstFilter(Index).ListIndex
 ' чешка
 Case 1
   labFIlterParam(Index).Caption = "Параметр"
   sldFilterParam(Index).min = 1
   sldFilterParam(Index).max = 30
 ' волосок
 Case 6
   labFIlterParam(Index).Caption = "Усиление"
   sldFilterParam(Index).min = 0
   sldFilterParam(Index).max = 64
 ' Фильтр 2019
 Case 7
   labFIlterParam(Index).Caption = "Усиление"
   sldFilterParam(Index).min = 0
   sldFilterParam(Index).max = 64
 ' Свертка 1
 Case 8
   labFIlterParam(Index).Caption = "Усиление"
   sldFilterParam(Index).min = 0
   sldFilterParam(Index).max = 64
 Case 9
   labFIlterParam(Index).Caption = "Усиление"
   sldFilterParam(Index).min = 0
   sldFilterParam(Index).max = 64
 Case 10
   labFIlterParam(Index).Caption = "Усиление"
   sldFilterParam(Index).min = 0
   sldFilterParam(Index).max = 64
End Select

sldFilterParam(Index).visible = isOn
labFIlterParam(Index).visible = isOn
labFilterParamValue(Index).visible = isOn
End Sub

Private Sub filterRollOn(Index As Integer, isOn As Boolean)
labFIlterRolled1(Index).visible = isOn
labFIlterValRolled1(Index).visible = isOn
labFIlterRolled2(Index).visible = isOn
labFIlterValRolled2(Index).visible = isOn
labFIlterValAmplifer(Index).visible = isOn
labFIlterAmplifer(Index).visible = isOn
End Sub

Private Sub filterTFIOn(Index As Integer, isOn As Boolean)
labFIlterTFI1(Index).visible = isOn
labFIlterValTFI1(Index).visible = isOn
labFIlterTFI2(Index).visible = isOn
labFIlterValTFI2(Index).visible = isOn
chkFIlterTFI(Index).visible = isOn
End Sub

Private Sub labFIlterValAmplifer_Click(Index As Integer)
Dim s As String, v As Long

s = InputBox("Введите значение параметра усиления фильтра", "Значение параметра", crz.zone(Index).filterRolledAmplifer)
If Len(s) = 0 Then Exit Sub

v = CLng(s)

labFIlterValAmplifer(Index).Caption = CStr(v)
crz.zone(Index).filterRolledAmplifer = v

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub chkFIlterTFI_Click(Index As Integer)
crz.zone(Index).filterTFIbase = chkFIlterTFI(Index).Value

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub labFIlterValTFI1_Click(Index As Integer)
Dim s As String, v As Long

s = InputBox("Введите значение ширины окна фильтра в отсчетах одометра", "Значение параметра", crz.zone(Index).filterTFI1Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v > 500 Then
 ogdWin.Alert "Значение ширины окна фильтра не должно превышать 500"
 Exit Sub
End If
If v < 1 Then
 ogdWin.Alert "Значение ширины окна фильтра не должно быть меньше 1"
 Exit Sub
End If

labFIlterValTFI1(Index).Caption = CStr(v)
crz.zone(Index).filterTFI1Param = v

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub labFIlterValTFI2_Click(Index As Integer)
Dim s As String, v As Long

s = InputBox("Введите значение усиления фильтра", "Значение параметра", crz.zone(Index).filterTFI2Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v > 30 Then
 ogdWin.Alert "Значение усиления фильтра не должно превышать 30"
 Exit Sub
End If
If v < 1 Then
 ogdWin.Alert "Значение усиления фильтра не должно быть меньше 1"
 Exit Sub
End If

labFIlterValTFI2(Index).Caption = CStr(v)
crz.zone(Index).filterTFI2Param = v

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub labFIlterValRolled1_Click(Index As Integer)
Dim s As String, v As Long

s = InputBox("Введите значение параметра фильтра", "Значение параметра", crz.zone(Index).filterRolled1Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v > crz.zone(Index).filterRolled2Param Then
 ogdWin.Alert "Значение параметра1 не должно превышать значение параметра2"
 Exit Sub
End If
If v < 1 Then
 ogdWin.Alert "Значение параметра1 не должно быть меньше 1"
 Exit Sub
End If

labFIlterValRolled1(Index).Caption = CStr(v)
crz.zone(Index).filterRolled1Param = v

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub labFIlterValRolled2_Click(Index As Integer)
Dim s As String, v As Long

s = InputBox("Введите значение параметра фильтра", "Значение параметра", crz.zone(Index).filterRolled2Param)
If Len(s) = 0 Then Exit Sub

v = CLng(s)
If v < crz.zone(Index).filterRolled1Param Then
 ogdWin.Alert "Значение параметра2 не должно быть меньше значения параметра1"
 Exit Sub
End If
If v > 15 Then
 ogdWin.Alert "Значение параметра2 не должно быть больше 15"
 Exit Sub
End If

labFIlterValRolled2(Index).Caption = CStr(v)
crz.zone(Index).filterRolled2Param = v

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub labFilterParamValue_Click(Index As Integer)
Dim s As String

s = InputBox("Введите значение параметра фильтра", "Значение параметра", sldFilterParam(Index).Value)
If Len(s) > 0 Then
  sldFilterParam(Index).Value = val(s)
End If
End Sub

Private Sub lstFilter_Click(Index As Integer)

Select Case lstFilter(Index).ListIndex

 ' отключен
 Case 0
  filterUnweldOn Index, False
  filterRollOn Index, False
  filterTFIOn Index, False
  
 ' чешка
 Case 1
  filterUnweldOn Index, True
  filterRollOn Index, False
  filterTFIOn Index, False
  sldFilterParam(Index).Value = crz.zone(Index).filterUnweldParam
  
 ' цельнотянутая
 Case 2
  filterUnweldOn Index, False
  filterRollOn Index, True
  filterTFIOn Index, False
  
 ' пригрузы
 Case 3
  filterUnweldOn Index, False
  filterRollOn Index, False
  filterTFIOn Index, False
  
 ' продольные трещины
 Case 4
  filterUnweldOn Index, False
  filterRollOn Index, False
  filterTFIOn Index, True
  
 ' без математики
 Case 5
  filterUnweldOn Index, False
  filterRollOn Index, False
  filterTFIOn Index, False
  
 ' волосок
 Case 6
  filterUnweldOn Index, True
  filterRollOn Index, False
  filterTFIOn Index, False
  sldFilterParam(Index).Value = crz.zone(Index).filterVolosokParam

 ' Фильтр 2019
 Case 7
  filterUnweldOn Index, True
  filterRollOn Index, False
  filterTFIOn Index, False
  sldFilterParam(Index).Value = crz.zone(Index).filterFilter2019Param
  
 ' Свертка 1
 Case 8
  filterUnweldOn Index, True
  filterRollOn Index, False
  filterTFIOn Index, False
  sldFilterParam(Index).Value = crz.zone(Index).filterConvolution1Param
  
 ' Свертка 2
 Case 9
  filterUnweldOn Index, True
  filterRollOn Index, False
  filterTFIOn Index, False
  sldFilterParam(Index).Value = crz.zone(Index).filterConvolution2Param

' Свертка 3
 Case 10
  filterUnweldOn Index, True
  filterRollOn Index, False
  filterTFIOn Index, False
  sldFilterParam(Index).Value = crz.zone(Index).filterConvolution3Param
End Select
crz.zone(Index).filterType = lstFilter(Index).ListIndex

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub lstYscale_Click(Index As Integer)
If initFlag Then Exit Sub
crz.zone(Index).scaleY = lstYscale(Index).ItemData(lstYscale(Index).ListIndex)
RaiseEvent sizeChange
End Sub

Private Sub optAlign_Click(Index As Integer)
If initFlag Then Exit Sub
crz.isAlignVert = IIf(optAlign(0).Value = True, False, True)
RaiseEvent sizeChange
End Sub

Private Sub pallette_Change(Index As Integer)
pallette(Index).Draw

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
RaiseEvent redraw(Index)
End Sub

Private Sub rbtnScaleMode0_Click(Index As Integer)
If initFlag Then Exit Sub
XYScaleMode = 0
SetScaleMode XYScaleMode
RaiseEvent redraw(Index)
End Sub

Private Sub rbtnScaleMode1_Click(Index As Integer)
If initFlag Then Exit Sub
XYScaleMode = 1
SetScaleMode XYScaleMode
RaiseEvent redraw(Index)
End Sub

Private Sub rbtnScaleMode2_Click(Index As Integer)
If initFlag Then Exit Sub
XYScaleMode = 2
SetScaleMode XYScaleMode
RaiseEvent redraw(Index)
End Sub

Private Sub rbtnScaleMode3_Click(Index As Integer)
If initFlag Then Exit Sub
XYScaleMode = 3
SetScaleMode XYScaleMode
RaiseEvent redraw(Index)
End Sub

Private Sub sldFilterParam_Change(Index As Integer)
labFilterParamValue(Index).Caption = sldFilterParam(Index).Value

Select Case lstFilter(Index).ListIndex
 ' чешка
 Case 1
   crz.zone(Index).filterUnweldParam = sldFilterParam(Index).Value
 ' волосок
 Case 6
   crz.zone(Index).filterVolosokParam = sldFilterParam(Index).Value
 ' Фильтр 2019
 Case 7
   crz.zone(Index).filterFilter2019Param = sldFilterParam(Index).Value
 ' Свертка 1
 Case 8
   crz.zone(Index).filterConvolution1Param = sldFilterParam(Index).Value
' Свертка 2
 Case 9
   crz.zone(Index).filterConvolution2Param = sldFilterParam(Index).Value
' Свертка 3
 Case 10
   crz.zone(Index).filterConvolution3Param = sldFilterParam(Index).Value
End Select

If initFlag Then Exit Sub
RaiseEvent changeZone(Index)
setReady
End Sub

Private Sub zone_Click(PreviousTab As Integer)
zfrm(PreviousTab).visible = False
zfrm(zone.Tab).visible = True
zfrm(zone.Tab).ZOrder
End Sub

'Private Sub btmIntWin_Click(Index As Integer)
'Dim s As String
's = InputBox( _
' "Длина окна интегрирования сигнала:", _
' "Настройка развертки", _
' labIntWin(Index).caption, _
' Me.Left, Me.Top)
'If s = "" Then Exit Sub
'Me.valIntWin(Index) = Fix(Val(s))
'End Sub

'Property Get valIntWin(ByVal indx As Integer) As Integer
'valIntWin = Val(labIntWin(indx).caption)
'End Property

'Property Let valIntWin(ByVal indx As Integer, i As Integer)
'If i < 0 Then i = 0
'labIntWin(indx).caption = i
'crz.zone(indx).sensors.intwin = i
'End Property

'Private Sub btmSens_Click(Index As Integer)
'If frmSensors.Edit(crz.zone(Index).sensors) Then
' crz.zone(Index).sensors.raiseChange "frmCrzTool.btmSens_Click(" & Index & ")"
' crz.zone(Index).sensors.sizeChange
'End If
'End Sub

'Private Sub chkOrnt_Click(Index As Integer)
'crz.zone(Index).sensors.orntOff = IIf(chkOrnt(Index).Value = 0, True, False)
'crz.zone(Index).sensors.raiseChange "frmCrzTool.chkOrnt_Click"
'crz.zone(Index).redraw
'End Sub
