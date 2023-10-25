VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.1#0"; "MSCOMCTL.OCX"
Object = "{A4F5504C-4D7B-4827-87C7-7CA6D5794D06}#7.0#0"; "olch3x7.ocx"
Begin VB.Form frmZoom 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   9585
   ClientLeft      =   3015
   ClientTop       =   2205
   ClientWidth     =   7065
   Icon            =   "Zoom.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   639
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   471
   ShowInTaskbar   =   0   'False
   Begin VB.PictureBox imageOrient 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   1440
      Left            =   2880
      ScaleHeight     =   1380
      ScaleWidth      =   1380
      TabIndex        =   45
      Top             =   5280
      Visible         =   0   'False
      Width           =   1440
   End
   Begin VB.Frame Frame3 
      Caption         =   "Расчет глубины"
      Height          =   4095
      Left            =   0
      TabIndex        =   33
      Top             =   2520
      Width           =   2655
      Begin VB.CheckBox chkWarning 
         Caption         =   "без предупреждений"
         Height          =   255
         Left            =   120
         TabIndex        =   47
         ToolTipText     =   "Отключить предупреждения о нулевой ширине дефекта"
         Top             =   2400
         Value           =   1  'Checked
         Width           =   2295
      End
      Begin VB.TextBox valMin 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   2040
         TabIndex        =   44
         ToolTipText     =   "Минимальное значение глубины дефекта в процентах толщины стенки трубы"
         Top             =   240
         Visible         =   0   'False
         Width           =   495
      End
      Begin VB.CheckBox chkAttension 
         Caption         =   "внимание!"
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   2400
         Width           =   2415
      End
      Begin VB.ComboBox lstInsideType 
         Height          =   315
         Left            =   120
         Style           =   2  'Dropdown List
         TabIndex        =   1
         Top             =   1680
         Width           =   2415
      End
      Begin VB.TextBox valMax 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   960
         TabIndex        =   0
         ToolTipText     =   "Максимальное значение глубины дефекта в процентах толщины стенки трубы"
         Top             =   220
         Width           =   495
      End
      Begin VB.ComboBox txtCmnt 
         Height          =   315
         Left            =   120
         TabIndex        =   5
         Top             =   3240
         Width           =   2415
      End
      Begin VB.CheckBox chkNoDepth 
         Caption         =   "не записывать глубину"
         Height          =   255
         Left            =   120
         TabIndex        =   4
         ToolTipText     =   "При записи в базу устанавливать глубину дефекта в ноль"
         Top             =   2640
         Width           =   2295
      End
      Begin VB.ComboBox dfktType 
         Height          =   315
         Left            =   120
         Style           =   2  'Dropdown List
         TabIndex        =   2
         ToolTipText     =   "Тип дефекта для записи в базу"
         Top             =   2040
         Width           =   2415
      End
      Begin MSComctlLib.Slider sldPrcntBorder 
         Height          =   375
         Left            =   1440
         TabIndex        =   50
         ToolTipText     =   "Минимальная глубина дефекта, проценты"
         Top             =   960
         Width           =   1095
         _ExtentX        =   1931
         _ExtentY        =   661
         _Version        =   393216
         Min             =   5
         Max             =   85
         SelStart        =   85
         Value           =   85
      End
      Begin VB.Label labBorderMsg 
         Caption         =   "Порог"
         Height          =   255
         Left            =   120
         TabIndex        =   49
         Top             =   1020
         Width           =   975
      End
      Begin VB.Label labBorder 
         Caption         =   "Label11"
         Height          =   255
         Left            =   1170
         TabIndex        =   48
         Top             =   1020
         Width           =   280
      End
      Begin VB.Label Label8 
         Alignment       =   1  'Right Justify
         Caption         =   "%"
         Height          =   255
         Left            =   1560
         TabIndex        =   42
         Top             =   600
         Width           =   255
      End
      Begin VB.Label labSlit 
         Alignment       =   1  'Right Justify
         BorderStyle     =   1  'Fixed Single
         Height          =   255
         Left            =   960
         TabIndex        =   41
         ToolTipText     =   "Глубина дефекта, рассчитанная по правилам для канавки"
         Top             =   600
         Width           =   495
      End
      Begin VB.Label Label7 
         Caption         =   "Канавка"
         Height          =   255
         Left            =   120
         TabIndex        =   40
         Top             =   600
         Width           =   735
      End
      Begin VB.Label legend 
         Alignment       =   1  'Right Justify
         Caption         =   "%"
         Height          =   255
         Left            =   1560
         TabIndex        =   39
         Top             =   240
         Width           =   255
      End
      Begin VB.Label Label4 
         Caption         =   "Глубина"
         Height          =   255
         Left            =   120
         TabIndex        =   38
         Top             =   240
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "Тип дефекта"
         Height          =   255
         Left            =   120
         TabIndex        =   37
         Top             =   1440
         Width           =   2415
      End
      Begin VB.Label labFeatClass 
         Caption         =   "Класс размера"
         Height          =   255
         Left            =   120
         TabIndex        =   36
         Top             =   3720
         Width           =   2415
      End
      Begin VB.Label Label6 
         Caption         =   "Примечание"
         Height          =   255
         Left            =   120
         TabIndex        =   34
         Top             =   3000
         Width           =   2295
      End
   End
   Begin VB.ComboBox viewScale 
      Height          =   315
      ItemData        =   "Zoom.frx":0442
      Left            =   960
      List            =   "Zoom.frx":0444
      Style           =   2  'Dropdown List
      TabIndex        =   7
      Top             =   7080
      Width           =   1695
   End
   Begin VB.Frame frame3D 
      Caption         =   "3М"
      Height          =   975
      Left            =   0
      TabIndex        =   25
      Top             =   8520
      Visible         =   0   'False
      Width           =   2655
      Begin VB.CommandButton btmReset 
         Caption         =   "Сброс"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         ToolTipText     =   "Сбросить параметры изображения в вид по умолчанию"
         Top             =   240
         Width           =   1095
      End
      Begin VB.CheckBox chkShade 
         Caption         =   "Заливка"
         Height          =   255
         Left            =   120
         TabIndex        =   13
         ToolTipText     =   "Переключение между каркасным и твердотельным видом"
         Top             =   600
         Width           =   1095
      End
   End
   Begin C1Chart3D7.Chart3D pic3D 
      Height          =   1095
      Left            =   5520
      TabIndex        =   28
      ToolTipText     =   "Обе кнопки мыши - вращение; +Ctrl - масштабирование; +Shift - перенос"
      Top             =   4200
      Width           =   1455
      _Version        =   458752
      _Revision       =   2
      _ExtentX        =   2566
      _ExtentY        =   1931
      _StockProps     =   0
      ControlProperties=   "Zoom.frx":0446
   End
   Begin VB.Frame frameGraf 
      Caption         =   "Графики"
      Height          =   975
      Left            =   2760
      TabIndex        =   26
      Top             =   4080
      Visible         =   0   'False
      Width           =   2655
      Begin krotw32.multyNum kSens 
         Height          =   255
         Left            =   1200
         TabIndex        =   14
         ToolTipText     =   "Коэффициент прореживания числа датчиков"
         Top             =   240
         Width           =   1335
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin krotw32.multyNum kMul 
         Height          =   255
         Left            =   1200
         TabIndex        =   15
         ToolTipText     =   "Коэффициент усиления сигналов датчиков"
         Top             =   600
         Width           =   1335
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin VB.Label labKSens 
         Caption         =   "Прореж-ние"
         Height          =   255
         Left            =   120
         TabIndex        =   30
         Top             =   240
         Width           =   1215
      End
      Begin VB.Label Label9 
         Caption         =   "Усиление"
         Height          =   255
         Left            =   120
         TabIndex        =   27
         Top             =   600
         Width           =   1095
      End
   End
   Begin VB.ComboBox viewType 
      Height          =   315
      ItemData        =   "Zoom.frx":148E
      Left            =   960
      List            =   "Zoom.frx":1490
      Style           =   2  'Dropdown List
      TabIndex        =   6
      Top             =   6720
      Width           =   1695
   End
   Begin VB.Frame Frame2 
      Caption         =   "Геометрия"
      Height          =   2415
      Left            =   0
      TabIndex        =   17
      Top             =   0
      Width           =   2655
      Begin VB.CommandButton BtnSmarun 
         Caption         =   "Смарунь"
         Height          =   570
         Left            =   1820
         TabIndex        =   51
         Top             =   1725
         Width           =   615
      End
      Begin VB.CommandButton btmMagn 
         Height          =   570
         Left            =   960
         Picture         =   "Zoom.frx":1492
         Style           =   1  'Graphical
         TabIndex        =   43
         ToolTipText     =   "Настройка коэффициентов расчета"
         Top             =   1725
         Width           =   615
      End
      Begin VB.CommandButton btmH0 
         Caption         =   "h0"
         Height          =   255
         Left            =   120
         TabIndex        =   10
         ToolTipText     =   "задать уровень h0 (в единицах АЦП) вручную"
         Top             =   960
         Width           =   855
      End
      Begin VB.CommandButton btmDai 
         Height          =   570
         Left            =   120
         Picture         =   "Zoom.frx":15BC
         Style           =   1  'Graphical
         TabIndex        =   11
         ToolTipText     =   "Протол определения глубины дефекта"
         Top             =   1725
         Width           =   615
      End
      Begin VB.Label labh0 
         Alignment       =   1  'Right Justify
         Caption         =   "999999.99"
         Height          =   255
         Left            =   1200
         TabIndex        =   35
         Top             =   960
         Width           =   1335
      End
      Begin VB.Label labAmpl 
         Alignment       =   1  'Right Justify
         Caption         =   "999999.99"
         Height          =   255
         Left            =   1200
         TabIndex        =   32
         Top             =   720
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "амплитуда"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   31
         Top             =   720
         Width           =   975
      End
      Begin VB.Label labY 
         Height          =   255
         Left            =   120
         TabIndex        =   23
         Top             =   1440
         Width           =   2415
      End
      Begin VB.Label Label1 
         Caption         =   "ориентация"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   22
         Top             =   1200
         Width           =   1095
      End
      Begin VB.Label labSize 
         Alignment       =   1  'Right Justify
         Caption         =   "999999.99"
         Height          =   255
         Left            =   1200
         TabIndex        =   21
         ToolTipText     =   "Длина х Ширина (длина в кол-ве измерений)"
         Top             =   480
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "размер"
         Height          =   255
         Index           =   4
         Left            =   120
         TabIndex        =   20
         Top             =   480
         Width           =   735
      End
      Begin VB.Label labX 
         Alignment       =   1  'Right Justify
         Caption         =   "999999.99"
         Height          =   255
         Left            =   1200
         TabIndex        =   19
         Top             =   240
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "дистанция"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   18
         Top             =   240
         Width           =   1095
      End
   End
   Begin VB.CommandButton btmBord 
      Caption         =   "&Рамка"
      Height          =   375
      Left            =   1440
      TabIndex        =   9
      ToolTipText     =   "Показать выбранный фрагмент рамкой на корозионной развертке"
      Top             =   8040
      Width           =   1095
   End
   Begin VB.CommandButton btmBase 
      Caption         =   "В &базу"
      Height          =   375
      Left            =   120
      TabIndex        =   8
      ToolTipText     =   "Поместить выбранный фрагмент как дефект в базу обьектов"
      Top             =   8040
      Width           =   1095
   End
   Begin VB.PictureBox pic 
      Height          =   3255
      Left            =   2760
      ScaleHeight     =   213
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   277
      TabIndex        =   16
      Top             =   0
      Width           =   4215
   End
   Begin VB.Label labFilter 
      Caption         =   "Фильтр"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H000000FF&
      Height          =   255
      Left            =   120
      TabIndex        =   46
      Top             =   7440
      Width           =   2535
   End
   Begin VB.Label Label2 
      Caption         =   "Масштаб"
      Height          =   255
      Left            =   120
      TabIndex        =   29
      Top             =   7080
      Width           =   855
   End
   Begin VB.Label Label5 
      Caption         =   "Вид"
      Height          =   255
      Left            =   120
      TabIndex        =   24
      Top             =   6720
      Width           =   495
   End
   Begin VB.Menu Context_menu 
      Caption         =   "Контекст"
      Visible         =   0   'False
      Begin VB.Menu context_mnu 
         Caption         =   "В базу"
         Index           =   0
      End
      Begin VB.Menu context_mnu 
         Caption         =   "Рамка"
         Index           =   1
      End
      Begin VB.Menu context_mnu 
         Caption         =   "Бланк дефекта"
         Index           =   2
      End
      Begin VB.Menu context_mnu 
         Caption         =   "В буфер обмена"
         Index           =   3
      End
      Begin VB.Menu context_mnu 
         Caption         =   "Анализ"
         Index           =   4
         Begin VB.Menu mnu_extapp 
            Caption         =   "Команда"
            Index           =   0
         End
      End
      Begin VB.Menu context_mnu 
         Caption         =   "Изменить последний обьект"
         Index           =   5
      End
   End
End
Attribute VB_Name = "frmZoom"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const ZOOM_3D_PERSPECTIVE = 2.5
Private Const ZOOM_X_ROTATION = 45
Private Const ZOOM_Y_ROTATION = 0
Private Const ZOOM_Z_ROTATION = 45

Private Const ZOOM_SETTING_lstInsideType = "lstInsideType"

Private minHeight As Single

Private dx1 As Long
Private dx2 As Long
Private d_sens1 As Long
Private d_sens2 As Long
Private dataX As Long
Private dataY As Long

Private sel_x1 As Long
Private sel_x2 As Long
Private sel_sens1 As Long
Private sel_sens2 As Long
Private defekt_rectangles As New Collection

Private prntForm As frmTrace
Private trc As clsTrace
Private frm As New clsFormProps
Private WithEvents crz As ctrlCoroz
Attribute crz.VB_VarHelpID = -1
Private WithEvents obj As clsDb
Attribute obj.VB_VarHelpID = -1
Private Zoom As New clsZoom
Private depth As clsDepth
Private sel_Start As New clsAnglUnit
Private sel_End As New clsAnglUnit
Private dllData() As Integer
Private dllDataRow() As Long
Private initFlag As Boolean
Private h0 As Long
Private clearFlag As Boolean
Private calcSelFlag As Boolean
Private dfktEditOK As Boolean
Private explainHead As String
Private explainGeom As String
Private featClass As EN_FEAT_CLASS
Private isSavedValue As Boolean
Private isNew As Boolean

Private daiFlag As Boolean
Private daiBreakFlag As Boolean

Private editDefekt As clsObjDefekt
Private hlp As New clsHelp

Private popupMenuItem As Integer
Private popupMenuFlag As Boolean

Public Event setMarkers(ByVal x1 As Long, ByVal x2 As Long)
Public Event formOFF()
Public Event selChange(ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Integer, ByVal y2 As Integer, ByVal zoneNum As Integer)
Public Event mouseMove(ByVal y As Integer, ByVal x As Long, ByVal zoneNum As Long)
Public Event newDefekt( _
 ByVal id As Long, _
 ByVal dst As Long, _
 ByVal dx As Long, _
 ByVal dy As Long, _
 ByVal orntStart As Double, _
 ByVal orntEnd As Double, _
 ByVal valMin As Integer, _
 ByVal valMax As Integer, _
 cmnt As String, _
 ByVal dInsideType As Long, _
 ByVal fClass As EN_FEAT_CLASS, _
 ByVal dEx1 As Long, _
 ByVal dEx2 As Long, _
 ByVal dEy1 As Long, _
 ByVal dEy2 As Long, _
 ByVal dIx1 As Long, _
 ByVal dIx2 As Long, _
 ByVal dIy1 As Long, _
 ByVal dIy2 As Long, _
 ByVal attention As Boolean _
)

Property Get sens1() As Long
sens1 = d_sens1
End Property

Property Get sens2() As Long
sens2 = d_sens2
End Property

Property Get x1() As Long
x1 = dx1
End Property

Property Get x2() As Long
x2 = dx2
End Property

Property Get SizeX() As Long
SizeX = dataX * trc.Step
End Property

Property Get SizeY() As Long
SizeY = dataY * crz.crz.mmPerSensor
End Property

Public Sub UpdateObjTypes(obj As clsDb)
Dim typ As clsObjType

With dfktType
 .Clear
 For Each typ In obj.objTypes
  If (typ.tbl = OBJ_TBL_DFKT) And (typ.off = False) Then  ') And (typ.enabled = True)
   .addItem typ.name
   .ItemData(.ListCount - 1) = typ.id
  End If
 Next
 If .ListCount > 0 Then
  .ListIndex = 0
 Else
  .enabled = False
 End If
End With
setLst dfktType, OBJ_TYPE.OBJ_anomal
End Sub

Public Sub Init(parentForm As frmTrace)
Dim tmp As Integer

initFlag = True
popupMenuFlag = False

Set prntForm = parentForm
Set trc = prntForm.trc
Set obj = trc.db
frm.Init trc.secUser, "frmZoom"

If trc.drv.isSpiral Then
 Set depth = New clsDepthSpiral
 Else
 Set depth = New clsDepth
End If

With viewType
 .addItem "Обычный"
 .ItemData(.ListCount - 1) = ZOOM_COMMON
 .addItem "Сглаженный"
 .ItemData(.ListCount - 1) = ZOOM_SMOOTH
 .addItem "Графики"
 .ItemData(.ListCount - 1) = ZOOM_LINES
 .addItem "Трехмерный"
 .ItemData(.ListCount - 1) = ZOOM_3D
 .ListIndex = 0
End With

With lstInsideType
 .addItem "Внешний"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_EXT
 .addItem "Внутренний"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_INT
 .addItem "Внутристенный"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_MID
 .addItem "Не определено"
 .ItemData(.ListCount - 1) = EN_INT_TYPE.IT_NA
 .ListIndex = trc.secUser.getInt(ZOOM_SETTING_lstInsideType, 0)
End With

With viewScale
 .addItem "4 пикс = 1 мм"
 .ItemData(.ListCount - 1) = -4
 .addItem "3 пикс = 1 мм"
 .ItemData(.ListCount - 1) = -3
 .addItem "2 пикс = 1 мм"
 .ItemData(.ListCount - 1) = -2
 .addItem "1 пикс = 1 мм"
 .ItemData(.ListCount - 1) = 1
 .addItem "1 пикс = 2 мм"
 .ItemData(.ListCount - 1) = 2
 .addItem "1 пикс = 3 мм"
 .ItemData(.ListCount - 1) = 3
 .addItem "1 пикс = 4 мм"
 .ItemData(.ListCount - 1) = 4
 .addItem "1 пикс = 5 мм"
 .ItemData(.ListCount - 1) = 5
 .addItem "1 пикс = 6 мм"
 .ItemData(.ListCount - 1) = 6
 .addItem "1 пикс = 7 мм"
 .ItemData(.ListCount - 1) = 7
 .addItem "1 пикс = 8 мм"
 .ItemData(.ListCount - 1) = 8
 .addItem "1 пикс = 9 мм"
 .ItemData(.ListCount - 1) = 9
 .addItem "1 пикс = 10 мм"
 .ItemData(.ListCount - 1) = 10
 .addItem "1 пикс = 11 мм"
 .ItemData(.ListCount - 1) = 11
 .addItem "1 пикс = 12 мм"
 .ItemData(.ListCount - 1) = 12
 .addItem "1 пикс = 13 мм"
 .ItemData(.ListCount - 1) = 13
 .addItem "1 пикс = 14 мм"
 .ItemData(.ListCount - 1) = 14
 .addItem "1 пикс = 15 мм"
 .ItemData(.ListCount - 1) = 15
 .addItem "1 пикс = 20 мм"
 .ItemData(.ListCount - 1) = 20
 .addItem "1 пикс = 25 мм"
 .ItemData(.ListCount - 1) = 25
 .addItem "1 пикс = 30 мм"
 .ItemData(.ListCount - 1) = 30
 .ListIndex = 3
End With

If obj.enable Then
 dfktType.enabled = True
 chkNoDepth.enabled = True
 btmBase.enabled = Not obj.isRO
 Me.UpdateObjTypes obj
 Else
 dfktType.enabled = False
 chkNoDepth.enabled = False
 btmBase.enabled = False
End If

With depth
 .dltX = trc.Step
 Set .magnit = trc.magnit
End With

With pic3D
.AllowUserChanges = False
.Interior.BackgroundColor = pic.BackColor
.ChartArea.Surface.IsSolid = True
.border.type = oc3dBorder3DIn
.border.width = 1
.ChartArea.Axes("X").AnnotationMethod = oc3dAnnotateDataLabels
.ChartArea.Axes("Y").AnnotationMethod = oc3dAnnotateDataLabels
.ChartArea.Axes("Z").AnnotationMethod = oc3dAnnotateValueLabels
.legend.IsShowing = False
.PreviewMethod = oc3dPreviewFull
End With

With pic3D.ChartGroups(1)
.ChartType = oc3dTypeSurface
.Contour.ZoneMethod = oc3dZoneContours
.Elevation.IsMeshed = True
End With

chkShade.Value = 1
frm.restoreDialog Me
setEditMode True
externalModeOn False
initFlag = False
End Sub

Private Function findIndexForValue(lst As ComboBox, ByVal v As Long) As Integer
Dim i As Integer, dlt As Long, mindlt As Long, closeIndex As Integer

mindlt = 999999999
If (v = 0) Or (v = -1) Then v = 1

For i = 0 To lst.ListCount - 1
 dlt = Abs(lst.ItemData(i) - v)
 If dlt < mindlt Then
   mindlt = dlt
   closeIndex = i
 End If
 If mindlt = 0 Then
  findIndexForValue = closeIndex
  Exit Function
 End If
Next
findIndexForValue = IIf(closeIndex < (lst.ListCount - 1), closeIndex + 1, closeIndex)
End Function

Private Function findIndexForInsTypeValue(lst As ComboBox, ByVal v As Long) As Integer
Dim i As Integer, dlt As Long, mindlt As Long, closeIndex As Integer

mindlt = 999999999
If (v = -1) Then v = 1

For i = 0 To lst.ListCount - 1
 dlt = Abs(lst.ItemData(i) - v)
 If dlt < mindlt Then
   mindlt = dlt
   closeIndex = i
 End If
 If mindlt = 0 Then
  findIndexForInsTypeValue = closeIndex
  Exit Function
 End If
Next
findIndexForInsTypeValue = IIf(closeIndex < (lst.ListCount - 1), closeIndex + 1, closeIndex)
End Function

Private Sub resetRotation()
With pic3D.ChartArea.View3D
.Perspective = ZOOM_3D_PERSPECTIVE
.XRotation = ZOOM_X_ROTATION
.YRotation = ZOOM_Y_ROTATION
.ZRotation = ZOOM_Z_ROTATION
End With
End Sub

Public Sub showDefekt(corozZone As ctrlCoroz, dfkt As clsObjDefekt)
With dfkt
showData corozZone, .dEx1, .dEx2, .dEy1, .dEy2, .dIx1, .dIx2, .dIy1, .dIy2
chkAttension.Value = IIf(.objCommon.isAttention, 1, 0)
lstInsideType.ListIndex = .dInsideType
txtCmnt.Text = .objCommon.comment
setLst dfktType, .objCommon.objTyp.id
isSavedValue = True
valMax.Text = .dValMax
valMin.Text = .dValMin
Set editDefekt = dfkt
End With
setEditMode False
externalModeOn False
End Sub

Private Sub externalModeOn(ByVal isOn As Boolean)
labBorderMsg.visible = isOn
labBorder.visible = isOn
sldPrcntBorder.visible = isOn
End Sub

Public Sub showData( _
corozZone As ctrlCoroz, _
ByVal x1 As Long, _
ByVal x2 As Long, _
ByVal y1 As Long, _
ByVal y2 As Long, _
Optional ix1 As Long = -1, _
Optional ix2 As Long = -1, _
Optional iy1 As Long = -1, _
Optional iy2 As Long = -1 _
)

Dim sW As Single, sh As Single, scl As Integer
Dim dat As T_NODEDATA

If ix1 = -1 Then
 calcSelFlag = True
 sel_x1 = 0
 sel_x2 = dx2 - dx1
 sel_sens1 = d_sens1
 sel_sens2 = d_sens2
 
 labBorder.Caption = sldPrcntBorder.Value & "%"
 
 Else
 
 calcSelFlag = False
 sel_x1 = ix1
 sel_x2 = ix2
 sel_sens1 = iy1
 sel_sens2 = iy2
 
End If

clearCollection defekt_rectangles
Set editDefekt = Nothing
Set crz = corozZone

explainHead = "Расчет "
If crz.crz.sensType = SENS_PROFIL Then
 legend.Caption = "мм"
 'lstInsideType.enabled = False
 btmMagn.enabled = False
 explainHead = explainHead & "глубины вмятины по поясу профильных датчиков '" & crz.crz.name & "'."
 Else
 legend.Caption = "%"
 lstInsideType.enabled = True
 If cfg.zoomTypeSave = False Then
   initFlag = True
   lstInsideType.ListIndex = 0
   initFlag = False
 End If
 btmMagn.enabled = True
 explainHead = explainHead & "процента потери металла стенки трубы по поясу корррозинных датчиков '" & crz.crz.name & "'."
End If

explainHead = explainHead & vbNewLine & "Для расчета выбран фрагмент данных с отметки " & x1 & " мм по " & x2 & " мм, с датчика " & y1 & " по датчик " & y2

With depth
 .dltY = crz.crz.mmPerSensor
 If (crz.crz.isRowPresent) And (crz.crz.sensType <> SENS_PROFIL) Then
  .sensMax = crz.crz.valMaxRow
  .sensMin = crz.crz.valMinRow
 Else
  .sensMax = crz.crz.valMax
  .sensMin = crz.crz.valMin
 End If
End With

'выравнять дистанции границы показаний датчиков
'иначе глюки при заполнении буферов данных
x1 = (x1 \ trc.Step) * trc.Step
x2 = (x2 \ trc.Step) * trc.Step
If x1 = x2 Then x2 = x2 + trc.Step
If (((x2 - x1) / trc.Step) Mod 2) > 0 Then x2 = x2 + trc.Step

dx1 = x1
dx2 = x2
d_sens1 = y1
d_sens2 = y2

dataX = (x2 - x1) / trc.Step

If d_sens2 > d_sens1 Then
 dataY = d_sens2 - d_sens1
 Else
 dataY = crz.crz.num - (d_sens1 - d_sens2)
End If

ReDim dllData(dataX * dataY) As Integer
ReDim dllDataRow(dataX * dataY) As Long

explainHead = explainHead & vbNewLine & "После выравнивания данных по X, отметка начала: " & dx1 & " мм по " & dx2 & " мм"
explainHead = explainHead & vbNewLine & "Шаг опроса вдоль оси трубы " & trc.Step & " мм, по окружности трубы " & depth.dltY & " мм"
explainHead = explainHead & vbNewLine & "Диапазон показаний датчиков от " & depth.sensMin & " до " & depth.sensMax
explainHead = explainHead & vbNewLine & "Геометрические размеры дефекта внутри области "

'посчитать H нулевое
If labh0.FontBold = False Then h0 = -1

'закоментированоб т.к. может не быть толщины
'If krotGetFirstNode(trc.tHandle, dat, dx1, SENS_THICK, -1, 1, 1) = KRT_ERR Then
' ogdWin.Alert lastError()
' Exit Sub
'End If
'h0 = dat.sensVal
'If krotGetFirstNode(trc.tHandle, dat, dx2, SENS_THICK, -1, 1, 1) = KRT_ERR Then
' ogdWin.Alert lastError()
' Exit Sub
'End If
'h0 = (dat.sensVal + h0) / 2
'h0 = (crz.tSensMaxRow - crz.tSensMinRow) / (trc.wallThickMax - trc.wallThickMin) * h0

'автоопределение подходящих размеров окна
sW = Me.SizeX / (Screen.width / Screen.twipsPerPixelX * 0.8)
sh = Me.SizeY / (Screen.Height / Screen.twipsPerPixelY * 0.8)
scl = Fix(IIf(sW > sh, sW, sh))
scl = findIndexForValue(viewScale, scl)
initFlag = True
viewScale.ListIndex = scl
initFlag = False
clearFlag = False

Form_Resize

initFlag = True
With crz.crz
kSens.Min = .grKoefSnsMin
kSens.Max = .grKoefSnsMax
kMul.Min = .grKoefMulMin
kMul.Max = .grKoefMulMax
kMul.Value = .grKoefMul
kSens.Value = .grKoefSns
If .isGraph Then
 scl = findIndexForValue(viewType, ZOOM_LINES)
 viewType.ListIndex = scl
End If
End With
initFlag = False

Me.Show 0, frmMain
Me.ZOrder
drawPic

If calcSelFlag Then
  setWait "Поиск дефектов..."
  findZoomDefekts 85, defekt_rectangles
  setReady
End If

calcDefect
trc.commentHistory.setCombo txtCmnt
setSel valMax
updateFeatClass
setDefektTypeList
setEditMode True
externalModeOn False
End Sub

Private Sub findZoomDefekts(ByVal border_percent As Integer, defekts As Collection)
Dim save_dllData() As Integer, save_dllDataRow() As Long, zoom_dfkt As clsZoomAnomaly
Dim baseIndex As Long, i As Long, j As Long, loop_flag As Boolean

ReDim save_dllData(dataX * dataY) As Integer
copyMatrixInt dataX, dataY, dllData, save_dllData

ReDim save_dllDataRow(dataX * dataY) As Long
copyMatrixLong dataX, dataY, dllDataRow, save_dllDataRow

loop_flag = True
Set zoom_dfkt = getZoomAnomaly()
While loop_flag And (zoom_dfkt.depth > border_percent)
 If zoom_dfkt.isNear(defekts) = False Then
   defekts.Add zoom_dfkt
 End If
 For i = zoom_dfkt.y1 To zoom_dfkt.y2
   baseIndex = dataX * i
   For j = zoom_dfkt.x1 To zoom_dfkt.x2
     dllDataRow(baseIndex + j) = dllDataRow(baseIndex)
     dllData(baseIndex + j) = dllData(baseIndex)
   Next
 Next
 
 If crz.crz.sensType = SENS_PROFIL Then
   loop_flag = False
 Else
   Set zoom_dfkt = getZoomAnomaly()
 End If
Wend

copyMatrixInt dataX, dataY, save_dllData, dllData
copyMatrixLong dataX, dataY, save_dllDataRow, dllDataRow
End Sub

Private Function getZoomAnomaly() As clsZoomAnomaly
Dim d As clsZoomAnomaly, is_tfi As Boolean

Set d = New clsZoomAnomaly

is_tfi = False
If crz.crz.sensType = KRT_SENS_TYPE.SENS_TFI Then
  is_tfi = True
End If

If crz.crz.sensType = KRT_SENS_TYPE.SENS_PROFIL Then
  copyMatrix dataX, dataY, dllData, dllDataRow
  d.depth = depth.CalcDent( _
   dllDataRow, _
   dataX, _
   dataY, _
   trc.profilZero, _
   -1, -1, -1, IIf(chkWarning.Value = 1, True, False) _
  )
Else
  d.depth = depth.Calculate( _
   dllDataRow, _
   dataX, _
   dataY, _
   -1, _
   IIf(lstInsideType.ItemData(lstInsideType.ListIndex) = EN_INT_TYPE.IT_EXT, False, True), _
   -1, -1, -1, IIf(chkWarning.Value = 1, True, False), is_tfi, crz.crz.sensType _
  )
End If

d.x1 = depth.dfktSize.posLeft
d.x2 = depth.dfktSize.posRight
d.y1 = depth.widthTop
d.y2 = depth.widthBottom

d.draw_x1 = depth.minPos1
d.draw_x2 = depth.minPos2
d.draw_y1 = sensors2y(d.y1)
d.draw_y2 = sensors2y(d.y2)

Set getZoomAnomaly = d
End Function

Private Sub updateFeatClass()
Dim featClass As Long

If dfktType.ListIndex = -1 Then Exit Sub

Select Case dfktType.ItemData(dfktType.ListIndex)
  Case OBJ_ANOM_PROD_SHVA, OBJ_ZAVARKA_PROD_SHVA, OBJ_FORM_PRODOLN_SHVA
    labFeatClass.Caption = "привязка ко шву"
    Exit Sub
  Case Else
    labFeatClass.Caption = ""
End Select

If dfktType.ListIndex >= 0 Then
 'featClass = CalcFeatureClass(Me.selSizeX, Me.selSizeY, trc.db.GetWallThick(Me.x1))
 featClass = CalcFeatureClass(trc.getLenKoef(Me.x1, Me.selSizeX), Me.selSizeY, trc.db.GetWallThick(Me.x1))
 featClass = getFeatClass4Defect(trDefektType(dfktType.ItemData(dfktType.ListIndex)), featClass, Me.valMax.Text)
 labFeatClass.Caption = FeatClassName(featClass)
End If
End Sub

Private Sub setDefektTypeList()
If trc.db.enable Then
 With dfktType
  .ListIndex = findIndexForValue(dfktType, DefineDefType(.ItemData(.ListIndex), featClass))
 End With
Else
 dfktType.enabled = False
End If
End Sub

Property Get formVisible() As Boolean
formVisible = Me.visible
End Property

Property Let formVisible(ByVal v As Boolean)
Me.visible = v
If v Then drawPic
End Property

Public Sub setLastInsertedDefect(dfkt As clsObjDefekt)
Set editDefekt = dfkt
End Sub

Private Function saveDefekt() As Boolean
Dim ot As clsObjType, clearComment As Boolean

dfktEditOK = False
clearComment = True
If (obj.enable = False) Or obj.isRO Then Exit Function

If isNew Then

RaiseEvent newDefekt( _
 dfktType.ItemData(dfktType.ListIndex), _
 Me.selPosX, _
 Me.selSizeX, _
 Me.selSizeY, _
 crz.crz.sens2hour(sel_sens1), _
 crz.crz.sens2hour(sel_sens2), _
 IIf(chkNoDepth.Value = 0, val(valMin.Text), 0), _
 IIf(chkNoDepth.Value = 0, val(valMax.Text), 0), _
 txtCmnt.Text, _
 lstInsideType.ItemData(lstInsideType.ListIndex), _
 featClass, _
 dx1, _
 dx2, _
 d_sens1 * trc.Coroz.zone(0).num / crz.crz.num, _
 d_sens2 * trc.Coroz.zone(0).num / crz.crz.num, _
 sel_x1, _
 sel_x2, _
 sel_sens1 * trc.Coroz.zone(0).num / crz.crz.num, _
 sel_sens2 * trc.Coroz.zone(0).num / crz.crz.num, _
 IIf(chkAttension.Value = 1, True, False) _
)

If editDefekt Is Nothing Then
 clearComment = False
End If

Else

 With editDefekt
  Set ot = New clsObjType
  ot.Init _
    dfktType.ItemData(dfktType.ListIndex), _
    dfktType.List(dfktType.ListIndex), _
    .objCommon.objTyp.off, _
    .objCommon.objTyp.tbl

  .objCommon.objTyp.Init ot.id, ot.name, ot.off, ot.tbl
  .objCommon.objDist = Me.selPosX
  .objCommon.comment = txtCmnt.Text
  .objCommon.isAttention = IIf(chkAttension.Value = 1, True, False)
  .dLength = Me.selSizeX
  .dWidth = Me.selSizeY
  .dOrients = crz.crz.sens2hour(sel_sens1)
  .dOriente = crz.crz.sens2hour(sel_sens2)
  If chkNoDepth.Value = 0 Then
   .dValMin = val(valMin.Text)
   .dValMax = val(valMax.Text)
   Else
   .dValMin = 0
   .dValMax = 0
  End If
  .dInsideType = lstInsideType.ItemData(lstInsideType.ListIndex)
  .dFeatClass = featClass
  .dEx1 = dx1
  .dEx2 = dx2
  .dEy1 = d_sens1
  .dEy2 = d_sens2
  .dIx1 = sel_x1
  .dIx2 = sel_x2
  .dIy1 = sel_sens1
  .dIy2 = sel_sens2
  .raiseChange
 End With
 trc.db.objDefectSet editDefekt.objCommon.objDist, editDefekt

End If

addToHistory trc, txtCmnt, clearComment
setEditMode True
saveDefekt = dfktEditOK
End Function

Private Sub btmBase_Click()
context_mnu_Click 0
End Sub

Private Sub btmBord_Click()
context_mnu_Click 1
End Sub

Private Sub toClipBoard()
Dim h As Long

If viewType.ItemData(viewType.ListIndex) = ZOOM_3D Then
 h = pic3D.hwnd
 Else
 h = pic.hwnd
End If

If krotSetClipboard(h) = KRT_ERR Then
 ogdWin.Alert "Error frmZoom.showData.btmClip_Click" & vbNewLine & lastError()
End If
End Sub

Property Get daiRuning() As Boolean
daiRuning = daiFlag
End Property

Property Get daiBreak() As Boolean
daiBreak = daiBreakFlag
End Property

Private Sub runDai()
Dim ret As Integer, daiData As DAI_INFO, extInfo As VB_DAI_INFO
Dim buf As String, msgText As String, mp As Integer, tmpY As Long

daiFlag = True
daiBreakFlag = False
setWait "Анализ данных...", vbArrowHourglass
mp = Me.MousePointer
Me.MousePointer = vbArrowHourglass
Set frmZoomDAI = Me
btmDai.Picture = LoadResPicture(DAI_STOP, vbResIcon)

daiData.internal = lstInsideType.ItemData(lstInsideType.ListIndex)
daiData.wallThickness = trc.drv.wallThick
daiData.x1 = sel_x1 / trc.Step

tmpY = sel_sens1 - d_sens1
If tmpY < 0 Then tmpY = tmpY + crz.crz.num
daiData.y1 = tmpY

daiData.x2 = sel_x2 / trc.Step

tmpY = sel_sens2 - d_sens1
If tmpY < 0 Then tmpY = tmpY + crz.crz.num
daiData.y2 = tmpY

extInfo.itemX = trc.Step
extInfo.itemY = crz.crz.mmPerSensor
extInfo.orntStart = crz.crz.sens2degree(d_sens1)
extInfo.orntLen = crz.crz.sens2degree(d_sens2 - d_sens1)

buf = String(DAI_EXPLAIN_TEXT_MAX_LENGTH, Asc(" "))
ret = krotDai(trc.handle, crz.crz.Index, daiData, extInfo, buf, AddressOf daiCallBack)

If ret = DAI_QUEST_ERROR Then
 ogdWin.Alert "Ошибка при анализе данных:" & vbNewLine & lastError()
 Else
 msgText = Left$(buf, InStr(buf, Chr(0)) - 1)
 If Len(msgText) > 0 Then msgText = "Пояснения:" & vbNewLine & msgText
 ogdWin.Info "Вероятность трещин: " & ret & "%" & vbNewLine & msgText
End If
btmDai.Picture = LoadResPicture(DAI_RUN, vbResIcon)
Set frmZoomDAI = Nothing
Me.MousePointer = mp
setReady
daiFlag = False
End Sub

Private Sub btmDai_Click()
'If Me.daiRuning Then
' daiBreakFlag = True
' Else
' runDai
'End If
frmMagnExplain.View Me, trc.Description, explainHead & explainGeom & vbNewLine & depth.explain
End Sub

Private Sub BtnSmarun_Click() 'Внешний обработчик данных линзы (Смарунь)
    fileAnalize 1 'Index
End Sub

Private Sub labh0_Click()

If ogdWin.AskAction("Сбросить фиксированный уровень h0 для расчета глубин?") Then
  h0 = -1
  labh0.FontBold = False
  labh0.ToolTipText = ""

  calcDefect

  drawPic
  updateGeom False
End If

End Sub

Private Sub btmH0_Click()
Dim s As String

s = InputBox( _
 "Введите уровень h0 в единицах АЦП для расчета глубины:", _
 "Задание h0", _
 depth.h0)
If s = "" Then Exit Sub

h0 = val(s)
labh0.FontBold = True
labh0.ToolTipText = "Уровень h0 зафиксирован оператором. Для сброса кликните по этой цифре."

calcSelFlag = True
calcDefect

drawPic
updateGeom False
End Sub

Private Sub btmMagn_Click()
frmMagnit.Edit depth.magnit, trc.FileName, Me, False
End Sub

Private Sub btmReset_Click()
pic3D.CallAction oc3dActionReset, 0, 0
resetRotation
End Sub

'Private Sub chkInside_Click()
'calcDefect
'End Sub

Private Sub chkShade_Click()
Dim v As Boolean

v = IIf(chkShade.Value = 0, False, True)
With pic3D.ChartGroups(1)
.Contour.IsZoned = v
.Elevation.IsShaded = v
.Elevation.IsTransparent = Not (v)
End With
End Sub

Private Sub context_mnu_Click(Index As Integer)
If popupMenuFlag Then
 popupMenuItem = Index
 Exit Sub
End If

Select Case Index

  Case 0 'в базу
   If saveDefekt() Then
     Me.visible = False
     RaiseEvent formOFF
   End If
   
  Case 1 'рамка
   If clearFlag Then
     crz.drawBorder 0, 0, 0, 0, True
     clearFlag = False
   Else
     crz.drawBorder dx1, dx2, d_sens1, d_sens2, True
     clearFlag = True
   End If
    
  Case 2 'бланк
    makeDoc
    
  Case 3 'в буфер
    toClipBoard
    
  Case 5 'редактор последнего обьекта
    editLastObject
    
End Select

End Sub

Private Sub editLastObject()
Dim dfkt As New clsObjDefekt

trc.db.objDefect editDefekt.objCommon, dfkt
Me.showDefekt crz, dfkt
End Sub

Private Sub dfktType_Click()
If initFlag Then Exit Sub
updateFeatClass
'calcDefect
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
If KeyAscii = 27 Then
 Me.visible = False
 RaiseEvent formOFF
End If
End Sub

Private Sub Form_Load()
Dim ext_app As clsExtApp, i As Integer

minHeight = Me.Height
pic3D.visible = False
hlp.BindHelp Me, KRT_AnaCorozZoom

Set ext_app = cfg.ExternalApps.zoomApp(0)
Me.mnu_extapp(0).Caption = ext_app.title
Set ext_app = Nothing
For i = 1 To cfg.ExternalApps.zoomCount
  Load Me.mnu_extapp(i)
  Set ext_app = cfg.ExternalApps.zoomApp(i)
  Me.mnu_extapp(i).Caption = ext_app.title
  Set ext_app = Nothing
Next i
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.visible = False
 RaiseEvent formOFF
End If
End Sub

Private Sub Form_Resize()
Static inFlag As Boolean
Dim y As Single, scl As Integer, tmp1 As Long, tmp2 As Long

If inFlag Then Exit Sub
inFlag = True

If crz Is Nothing Then
  inFlag = False
  Exit Sub
End If

scl = viewScale.ItemData(viewScale.ListIndex)
If scl > 0 Then
 tmp1 = Me.SizeX / scl
 tmp2 = IIf(tmp1 > dataX, tmp1 Mod dataX, 0)
 pic.width = tmp1 - tmp2 + NON_CLIENT_AREA
 tmp1 = Me.SizeY / scl
 tmp2 = IIf(tmp1 > dataY, tmp1 Mod dataY, 0)
 pic.Height = tmp1 - tmp2 + NON_CLIENT_AREA
 Else
 pic.width = Me.SizeX * -scl + NON_CLIENT_AREA
 pic.Height = Me.SizeY * -scl + NON_CLIENT_AREA
End If

If Me.WindowState = vbNormal Then
 y = (pic.Top + pic.Height + 30) * Screen.twipsPerPixelY
 If y < minHeight Then
  Me.Height = minHeight
  Else
  Me.Height = y
 End If
 Me.width = (pic.Left + pic.width + 10) * Screen.twipsPerPixelX
End If

If Me.SizeX > 0 Then pic.ScaleWidth = Me.SizeX
If Me.SizeY > 0 Then pic.ScaleHeight = dataY

inFlag = False
End Sub

Private Sub drawPic()
Dim l As Long, i As Long, ret As Long

Me.Refresh
setWait "Формирую изображение..."

pic.Cls

On Error Resume Next
l = viewType.ItemData(viewType.ListIndex)
ret = krotPaintZoom(trc.handle, crz.crz.Index, pic.hwnd, dx1, dataX, d_sens1, dataY, dllData(0), dllDataRow(0), l)

If ret = KRT_ERR Then
 ogdWin.Alert "Error frmZoom.showData.krotPaintZoom" & vbNewLine & lastError()
End If
On Error GoTo 0

If ret = KRT_ZOOM_FILTER Then
 i = crz.crz.filterType
 If i <> 0 Then
   labFilter.Caption = prntForm.fCrzTool.lstFilter(crz.crz.Index).List(i)
 Else
   labFilter.Caption = ""
 End If
Else
 labFilter.Caption = ""
End If

Select Case l

 Case ZOOM_COMMON
  frame3D.visible = False
  frameGraf.visible = False
  pic3D.visible = False
  pic.visible = True

 Case ZOOM_SMOOTH
  frame3D.visible = False
  frameGraf.visible = False
  pic3D.visible = False
  pic.visible = True

 Case ZOOM_3D
  frame3D.visible = True
  frameGraf.visible = False
  pic3D.Left = pic.Left
  pic3D.Top = pic.Top
  pic3D.width = pic.width
  pic3D.Height = pic.Height
  draw3D
  pic.visible = False
  pic3D.visible = True

 Case ZOOM_LINES
  frameGraf.Left = frame3D.Left
  frameGraf.Top = frame3D.Top
  frame3D.visible = False
  frameGraf.visible = True
  pic3D.visible = False
  pic.visible = True
  drawGraphLines

End Select

drawSel
setReady

End Sub

Private Sub draw3D()
Dim i As Integer, j As Integer
Dim da() As Integer

pic3D.isBatched = True
With pic3D.ChartGroups(1).ElevationData
.Layout = oc3dDataGrid
.ColumnCount = dataY
.RowCount = dataX

ReDim da(1 To dataX, 1 To dataY) As Integer
For j = 1 To dataY
 For i = 1 To dataX
  da(i, j) = dllData(dataX * (j - 1) + i)
  '.Value(j, i) = dllData(dataX * (j - 1) + i)
 Next
Next
.CopyZArrayIn da
End With
pic3D.isBatched = False
End Sub

Private Sub drawGraphLines()
Dim i As Integer, j As Integer
Dim oldTop As Single, oldHeigh As Single, oldLeft As Single, oldwidth As Single
Dim sensInterval As Single, clr As Long
Dim x1 As Single, x2 As Single, y1 As Single, y2 As Single, y0 As Single
Dim sh As Long, kf As Double

oldTop = pic.ScaleTop
oldHeigh = pic.ScaleHeight
oldLeft = pic.ScaleLeft
oldwidth = pic.ScaleWidth

pic.ScaleLeft = 0
pic.ScaleWidth = dataX
pic.ScaleTop = 0
pic.ScaleHeight = dataY
pic.Cls

sensInterval = (crz.crz.valMax - crz.crz.valMin) * 1.2
clr = &HFF0000
kf = kMul.Value
sh = kSens.Value
For j = 0 To dataY - 1
 'clr = IIf(clr = &HFF, &HFFFFFF, &HFF)
 y0 = dllData(j * dataX)
 x1 = 0
 y1 = j
 For i = 1 To dataX
  x2 = i
  y2 = j - (dllData(j * dataX + i) - y0) * kf * sh / sensInterval
  pic.Line (x1, y1)-(x2, y2), clr
  x1 = x2
  y1 = y2
 Next i
 j = j + sh
Next j

pic.ScaleTop = oldTop
pic.ScaleHeight = oldHeigh
pic.ScaleLeft = oldLeft
pic.ScaleWidth = oldwidth
End Sub

Private Sub kMul_Change(m As Integer)
If initFlag Then Exit Sub
drawPic
End Sub

Private Sub kSens_Change(m As Integer)
If initFlag Then Exit Sub
drawPic
End Sub

Private Sub Label4_DblClick()
calcDefect
End Sub

Private Sub labSlit_Click()
valMax.Text = labSlit.Caption
End Sub

Private Sub lstInsideType_Click()
If initFlag Then Exit Sub
calcDefect
End Sub

Public Sub magnetEdit_Callback()
calcDefect
End Sub

Private Sub calcDefect()
Dim lnum As Long, ot As New clsObjType, is_tfi As Boolean

If crz Is Nothing Then Exit Sub

If dfktType.ListIndex >= 0 Then
 ot.Init dfktType.ItemData(dfktType.ListIndex), dfktType.List(dfktType.ListIndex), False, OBJ_TBL_DFKT
 If Not ot.isDepth Then
  valMax.Text = ""
  valMin.Text = ""
  labSlit.Caption = ""
  drawSel
  updateGeom False
  Exit Sub
 End If
End If

If (lstInsideType.ListIndex <> EN_INT_TYPE.IT_MID) And _
   (lstInsideType.ListIndex <> EN_INT_TYPE.IT_NA) Then
 
 If crz.crz.sensType = SENS_PROFIL Then
 
  copyMatrix dataX, dataY, dllData, dllDataRow
  valMax.Text = "" & depth.CalcDent( _
   dllDataRow, _
   dataX, _
   dataY, _
   trc.profilZero, _
   IIf(calcSelFlag, -1, trc.getLenKoef(Me.selPosX, Me.selSizeX)), _
   IIf(calcSelFlag, -1, sel_sens1 - d_sens1), _
   IIf(calcSelFlag, -1, sel_sens2 - d_sens1), _
   IIf(chkWarning.Value = 1, True, False) _
  )
  labSlit.Caption = ""
 
  Else
  
  If calcSelFlag Then
    explainGeom = "не определены"
  Else
    explainGeom = "заданы пользователем: по X " & sel_x1 & ":" & sel_x2 & " по Y " & sel_sens1 & ":" & sel_sens2
  End If
  
  is_tfi = False
  If crz.crz.sensType = KRT_SENS_TYPE.SENS_TFI Then
    is_tfi = True
  End If
  
  valMax.Text = "" & depth.Calculate( _
   dllDataRow, _
   dataX, _
   dataY, _
   h0, _
   IIf(lstInsideType.ItemData(lstInsideType.ListIndex) = EN_INT_TYPE.IT_EXT, False, True), _
   IIf(calcSelFlag, -1, trc.getLenKoef(Me.selPosX, Me.selSizeX)), _
   IIf(calcSelFlag, -1, sel_sens1 - d_sens1), _
   IIf(calcSelFlag, -1, sel_sens2 - d_sens1), _
   IIf(chkWarning.Value = 1, True, False), is_tfi, crz.crz.sensType _
  )
  labSlit.Caption = "" & depth.lastPrcntSlit
 
 End If
 
End If

valMin.Text = valMax.Text

If calcSelFlag Then
 sel_x1 = depth.minPos1
 sel_x2 = depth.minPos2
 sel_sens1 = d_sens1 + depth.widthTop
 sel_sens2 = d_sens1 + depth.widthBottom
End If

If cfg.crz.zoomSync Then
 If trc.drv.isSpiral Then
  lnum = dx1 + depth.lineNumber * depth.dltX
  crz.setOneSensIndex ((sel_sens1 + sel_sens2) / 2 + (crz.crz.num - crz.crz.topSens) + 1) Mod crz.crz.num
  RaiseEvent setMarkers(lnum, 0)
  crz.setCircleMarkers False, True
  Else
  lnum = (d_sens1 + depth.lineNumber + (crz.crz.num - crz.crz.topSens)) Mod crz.crz.num
  crz.setOneSensIndex lnum
 End If
End If

drawSel
updateGeom False
End Sub

Private Sub updateGeom(ByVal isExternalAnalyze As Boolean)
Dim s As String

If isExternalAnalyze Then
  labAmpl.Caption = ""
Else

  s = ""
  If depth.h0 > 0 Then
    s = " (" & dblStr(100 * depth.Amplitude / depth.h0, 1) & ")"
  End If
  
  labAmpl.Caption = depth.Amplitude & s
  labh0.Caption = depth.h0
End If

labX.Caption = mm2txt(trc.getDistKoef(Me.selPosX))
'sel_sens1 = sel_sens1 * trc.Coroz.zone(0).num / crz.crz.num
'sel_sens2 = sel_sens2 * trc.Coroz.zone(0).num / crz.crz.num

sel_Start.fullHour = crz.crz.sens2hour(sel_sens1)
sel_End.fullHour = crz.crz.sens2hour(sel_sens2)

labY.Caption = sel_Start.dStr & "-" & sel_End.dStr & " час. (" & sel_sens1 & "-" & sel_sens2 & " датчики)"

Dim popugay As Long
popugay = CLng((Me.selSizeY / crz.crz.mmPerSensor) * (Me.selSizeX / 10))

labSize.Caption = trc.getLenKoef(Me.selPosX, Me.selSizeX) & " x " & Me.selSizeY & " (" & popugay & ")"
RaiseEvent setMarkers(dx1 + sel_x1, dx1 + sel_x2)
RaiseEvent selChange(sel_x1, sel_x2, sel_sens1, sel_sens2, crz.crz.Index)
End Sub

Private Sub mnu_extapp_Click(Index As Integer)
fileAnalize Index
End Sub

Private Sub obj_dfktChange(ByVal dst As Long, dfkt As clsObjDefekt)
dfktEditOK = True
End Sub

Private Sub pic_Click()
Dim r As clsZoomAnomaly

If sldPrcntBorder.visible = False Then Exit Sub

For Each r In defekt_rectangles

  If r.isIside(Zoom.startX, Zoom.startY) Then
     
     sel_x1 = r.draw_x1
     sel_x2 = r.draw_x2
     sel_sens1 = d_sens1 + r.y1
     sel_sens2 = d_sens1 + r.y1 + r.y2
     
     If r.dflt_type = 1 Then
       valMax.Text = "" & r.depth
       valMin.Text = valMax.Text
       labSlit.Caption = ""
     End If

     If r.dflt_type = 2 Then
       valMax.Text = ""
       valMin.Text = valMax.Text
       labSlit.Caption = "" & r.depth
     End If

     updateGeom True
     drawSel

     Exit Sub
     
  End If

Next
End Sub

Private Sub pic_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
'On Error GoTo errHandle

Select Case Button

 Case 1 'левая клавиша мыши
  If Shift = 0 Then Shift = IIf(cfg.crz.zoomNoShift, 1, 0)
  Select Case Shift
   Case 1, 2 'нажат shift или ctrl - начало зуммирования
   Zoom.Start pic, x, y
  End Select

 Case 2 'щелкнули правой кнопкой мыши
  If cfg.zoomInsertMode = ZIM_RIGHT_MOUSE Then
    saveDefekt 'внести дефект в базу
  Else
    popContextMenu
  End If
  
 Case 4 'щелкнули средней кнопкой мыши
  If cfg.zoomInsertMode = ZIM_MIDDLE_MOUSE Then
    saveDefekt
  Else
    popContextMenu
  End If

End Select

'Exit Sub
'errHandle:
'ogdWin.Alert "pic_MouseDown error:" & vbNewLine & Err.Description
'Resume Next
End Sub

Private Sub popContextMenu()
popupMenuFlag = True
popupMenuItem = -1

context_mnu.Item(5).enabled = Not (editDefekt Is Nothing)

Me.popUpMenu Context_menu
popupMenuFlag = False
If popupMenuItem >= 0 Then
 context_mnu_Click popupMenuItem
 popupMenuItem = -1
End If
End Sub

Private Sub pic_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim i As Integer

On Error GoTo errHandle

If Zoom.inProgress Then
 If Shift = 0 Then Shift = IIf(cfg.crz.zoomNoShift, 1, 0)
 Select Case Shift
  Case 1, 2
   Zoom.Continue x, y
  Case Else
   Zoom.Finish
 End Select
End If

'correct sensor field detect
i = d_sens1 + Fix(y) 'здесь может быть Fix(Y+1) ???
If i >= crz.crz.num Then i = i - crz.crz.num

x = (x - pic.ScaleLeft) * (dx2 - dx1) / pic.ScaleWidth
RaiseEvent mouseMove(i, dx1 + x, crz.crz.Index)

Exit Sub
errHandle:
ogdWin.Alert "pic_MouseMove error:" & vbNewLine & Err.Description
Resume Next

End Sub

Private Function y2sensors(ByVal y As Single) As Integer
On Error GoTo errHandle
y2sensors = dataY * y / pic.ScaleHeight
Exit Function
errHandle:
y2sensors = 0
End Function

Private Function sensors2y(ByVal sens As Integer) As Single
On Error GoTo errHandle
sensors2y = sens * pic.ScaleHeight / dataY
Exit Function
errHandle:
sensors2y = 0
End Function

Private Function size2sensors(ByVal sizemm As Integer) As Integer
On Error GoTo errHandle
size2sensors = sizemm / crz.crz.mmPerSensor
Exit Function
errHandle:
size2sensors = 0
End Function

Private Sub pic_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim x1 As Single, x2 As Single, y1 As Single, y2 As Single

On Error GoTo errHandle

If Zoom.inProgress Then
 Zoom.Continue x, y
 Zoom.Finish
 Zoom.Coords x1, y1, x2, y2
 y1 = d_sens1 + y2sensors(y1)
 If y1 > crz.crz.num Then y1 = y1 - crz.crz.num
 y2 = d_sens1 + y2sensors(y2)
 If y2 > crz.crz.num Then y2 = y2 - crz.crz.num
 'защита от выбора, сведенного в точку
 If (x1 = x2) Or (y1 = y2) Then Exit Sub

 If Shift = 0 Then
  Shift = IIf(cfg.crz.zoomNoShift, 2, 0)
  Else
  If Shift = 2 Then
   Shift = IIf(cfg.crz.zoomNoShift, 1, 2)
  End If
 End If

 Select Case Shift
  Case 1 'shift
   Me.showData crz, dx1 + x1, dx1 + x2, y1, y2
  Case 2 'ctrl
   sel_x1 = x1
   sel_x2 = x2
   sel_sens1 = y1
   sel_sens2 = y2
   calcSelFlag = False
   
   If labh0.FontBold = False Then h0 = -1
   
   updateFeatClass
   setDefektTypeList
   calcDefect
 End Select

End If
drawPic
updateGeom False

On Error Resume Next
setSel valMax

Exit Sub
errHandle:
ogdWin.Alert "pic_MouseUp error:" & vbNewLine & Err.Description
Resume Next

End Sub

Property Get selPosX() As Long
selPosX = dx1 + sel_x1
End Property

Property Get selSizeX() As Long
selSizeX = sel_x2 - sel_x1
End Property

Property Get selSizeY() As Long
Dim y1 As Single, y2 As Single

y1 = sel_sens1 - d_sens1
If y1 < 0 Then y1 = y1 + crz.crz.num
y2 = sel_sens2 - d_sens1
If y2 < 0 Then y2 = y2 + crz.crz.num

selSizeY = (y2 - y1) * crz.crz.mmPerSensor
End Property

Private Sub drawSel()
Dim y1 As Single, y2 As Single, cnt As Integer
Dim r As clsZoomAnomaly
Static intFlag As Boolean

If intFlag Then Exit Sub

intFlag = True
pic.Refresh

labBorderMsg.Caption = "Порог"
cnt = 0
For Each r In defekt_rectangles
  If r.depth > sldPrcntBorder.Value Then
    pic.Line (r.draw_x1, r.draw_y1)-(r.draw_x2, r.draw_y2), &HFFFFFF, B
    cnt = cnt + 1
  End If
Next

If cnt > 0 Then
  labBorderMsg.Caption = labBorderMsg.Caption & " (" & cnt & ")"
End If

y1 = sel_sens1 - d_sens1
If y1 < 0 Then y1 = y1 + crz.crz.num
y2 = sel_sens2 - d_sens1
If y2 < 0 Then y2 = y2 + crz.crz.num

Dim li As Integer
li = pic.DrawWidth
If defekt_rectangles.count > 1 Then
  pic.DrawWidth = 3
End If
pic.Line (sel_x1, sensors2y(y1))-(sel_x2, sensors2y(y2)), &HFFFFFF, B
pic.DrawWidth = li

intFlag = False
End Sub

Private Sub Pic_Paint()
On Error GoTo errHandle
drawPic

Exit Sub
errHandle:
ogdWin.Alert "Pic_Paint error:" & vbNewLine & Err.Description
Resume Next
End Sub

Private Sub sldPrcntBorder_Click()
labBorder.Caption = sldPrcntBorder.Value & "%"
pic.Refresh
drawSel
End Sub

Private Sub txtCmnt_Change()
Static intFlag As Boolean

If intFlag Then Exit Sub
intFlag = True
If Len(txtCmnt.Text) > CMNT_LENGTH Then
 txtCmnt.Text = Left(txtCmnt.Text, CMNT_LENGTH)
 txtCmnt.SelStart = CMNT_LENGTH
 txtCmnt.SelLength = 0
End If
intFlag = False

End Sub

Private Sub valMax_GotFocus()
setSel valMax
End Sub

Private Sub viewScale_Click()
If initFlag Then Exit Sub
Form_Resize
drawPic
End Sub

Private Sub viewType_Click()
If initFlag Then Exit Sub
drawPic
End Sub

Private Sub makeDoc()
Dim pointLink As New clsPointLink, dfkt As New clsObjDefekt
Dim tmp As String

Set pointLink.trc = trc
tmp = trc.rptFile
If ogdWin.fExist(tmp) = False Then
 ogdWin.Alert "Файл шаблона " & tmp & " не найден."
 Exit Sub
End If

With dfkt
  
  .objCommon.objTyp.Init _
    dfktType.ItemData(dfktType.ListIndex), _
    dfktType.List(dfktType.ListIndex), False, OBJ_TBL_DFKT
  
  .objCommon.Init trc, Me.selPosX, Me.selSizeX, txtCmnt.Text, IIf(chkAttension.Value = 1, True, False), .objCommon.objTyp
  
  .Init .objCommon, _
    Me.selSizeY, _
    crz.crz.sens2hour(sel_sens1), _
    crz.crz.sens2hour(sel_sens2), _
    val(valMin.Text), _
    val(valMax.Text), _
    lstInsideType.ItemData(lstInsideType.ListIndex), _
    featClass, _
    dx1, _
    dx2, _
    d_sens1, _
    d_sens2, _
    sel_x1, _
    sel_x2, _
    sel_sens1, _
    sel_sens2

End With

pointLink.pointDist = Me.selPosX

If obj.getPointLinks(pointLink) = False Then Exit Sub

Dim tmp_file As String, x0 As Double, y0 As Double
Dim or1  As New clsAnglUnit, or2  As New clsAnglUnit

imageOrient.BackColor = &HFFFFFF
imageOrient.ForeColor = 0
imageOrient.drawMode = 13
imageOrient.DrawWidth = 8
x0 = imageOrient.ScaleWidth / 2
y0 = imageOrient.ScaleHeight / 2
or1.fullHour = dfkt.dOrients
or2.fullHour = dfkt.dOriente

imageOrient.Circle (x0, y0), y0 - 100, 0
imageOrient.Circle (x0, y0), y0 - 150, &HFF, krtAngle2VBangle(or2.radian), krtAngle2VBangle(or1.radian)

tmp_file = GetTempFile()
SavePicture imageOrient.Image, tmp_file

Rpt.wordTemplate = tmp
Rpt.wordReport dfkt, pointLink, trc, tmp_file

Kill tmp_file
End Sub

Public Sub Save()
frm.saveDialog Me
trc.secUser.setInt ZOOM_SETTING_lstInsideType, Me.lstInsideType.ListIndex
End Sub

Public Sub SaveLocalMagnetSystem()
trc.SaveLocalMagnet
End Sub

'Private Sub Form_DblClick()
'debug_analyze_result
'End Sub

'Private Sub debug_analyze_result()
'showAnalyzeResult "error_zoom.json"
'End Sub

Public Sub showAnalyzeResult(ByVal resultFile As String)
Dim json As String, json_row As String, errStart As String, pos As Integer, pos1 As Integer, s As String, frmt As Integer
Dim items As Variant, itm As Variant
Dim dfktProps As Variant, dprop As Variant
Dim x1 As Integer, x2 As Integer, y1 As Integer, y2 As Integer, depth As Integer, dfkt_type As Integer
Dim d As clsZoomAnomaly, cur_depth As Integer, sens_size1 As Integer, sens_size2 As Integer, cur_type  As Integer

json_row = read2string(resultFile)
json = Replace(json_row, " ", "")

s = Chr(34) & "zoomDataFormat" & Chr(34) & ":"
frmt = InStr(json, s)
If frmt <= 0 Then
  ogdWin.Alert "В файле с результатами анализа " & resultFile & " отсутствует ключ " & "zoomDataFormat" & vbNewLine & vbNewLine & json
  Exit Sub
End If
frmt = readIntFromString(Mid(json, frmt + Len(s)))

If (frmt < 1) Or (frmt > 2) Then
  ogdWin.Alert "zoomDataFormat " & frmt & " не поддерживается"
  Exit Sub
End If

If InStr(json, Chr(34) & "status" & Chr(34) & ":" & Chr(34) & "error" & Chr(34)) > 0 Then
  errStart = Chr(34) & "error" & Chr(34) & ":"
  s = ""
  pos = InStr(json_row, errStart)
  If pos > 0 Then
    
    pos = InStr(pos + Len(errStart), json_row, Chr(34))
    If pos > 0 Then
      'Debug.Print Mid(json_row, pos + 1)
      pos1 = InStr(pos + 1, json_row, Chr(34))
      s = Mid(json_row, pos + 1, pos1 - pos - 1)
    End If
  End If
  ogdWin.Alert "При анализе произошла ошибка:" & vbNewLine & DecodeUTF8(s)
  Exit Sub
End If

errStart = Chr(34) & "result" & Chr(34) & ":[]"
pos = InStr(json, errStart)
If pos > 0 Then
  ogdWin.Info "Внешняя программа анализа не обнаружила дефектов в переданных данных"
  Exit Sub
End If

errStart = Chr(34) & "result" & Chr(34) & ":[["
pos = InStr(json, errStart)
If pos <= 0 Then
  ogdWin.Alert "В файле с результатами анализа " & resultFile & " отсутствует секция " & "result" & vbNewLine & vbNewLine & json
  Exit Sub
End If

pos1 = InStr(pos + Len(errStart), json, "]]")
If pos1 <= 0 Then
  ogdWin.Alert "В файле с результатами анализа " & resultFile & " повреждена секция " & "result" & vbNewLine & vbNewLine & json
  Exit Sub
End If

'pic.Line (sel_x1, sensors2y(y1))-(sel_x2, sensors2y(y2)), &HFFFFFF, B
clearCollection defekt_rectangles

cur_depth = 0
cur_type = 1
s = Mid(json, pos + Len(errStart), pos1 - pos - Len(errStart))
items = Split(s, "],[")
s = ""
For Each itm In items
  s = s & itm & vbNewLine
  dfktProps = Split(itm, ",")
  x1 = readIntFromString(dfktProps(0))
  y1 = readIntFromString(dfktProps(1))
  x2 = readIntFromString(dfktProps(2))
  y2 = readIntFromString(dfktProps(3))
  depth = readIntFromString(dfktProps(4))
  dfkt_type = readIntFromString(dfktProps(5))

  Set d = New clsZoomAnomaly
  
  Select Case frmt
  
    Case 1
    
      d.x1 = x1
      d.x2 = x2
      d.y1 = y1
      d.y2 = y2
      
      d.draw_x1 = x1 * trc.Step
      d.draw_x2 = x1 * trc.Step + x2 * trc.Step
      d.draw_y1 = sensors2y(y1)
      d.draw_y2 = sensors2y(y1 + y2)
      sens_size1 = y1
      sens_size2 = y1 + y2
      
    Case 2
    
      d.x1 = x1 / trc.Step
      d.x2 = x2 / trc.Step
      d.y1 = size2sensors(y1)
      d.y2 = size2sensors(y2)
    
      d.draw_x1 = x1
      d.draw_x2 = x1 + x2
      d.draw_y1 = sensors2y(size2sensors(y1))
      d.draw_y2 = sensors2y(size2sensors(y1 + y2))
      sens_size1 = size2sensors(y1)
      sens_size2 = size2sensors(y1 + y2)
      
  End Select
  
  d.depth = depth
  d.dflt_type = dfkt_type
  
  defekt_rectangles.Add d

  If depth > cur_depth Then
    sel_x1 = d.draw_x1
    sel_x2 = d.draw_x2
    sel_sens1 = d_sens1 + sens_size1
    sel_sens2 = d_sens1 + sens_size2
    cur_depth = depth
    cur_type = dfkt_type
  End If

Next

If cur_type = 1 Then
  valMax.Text = "" & cur_depth
  valMin.Text = valMax.Text
  labSlit.Caption = ""
End If

If cur_type = 2 Then
  valMax.Text = ""
  valMin.Text = valMax.Text
  labSlit.Caption = "" & cur_depth
End If

externalModeOn True

updateGeom True
drawSel
End Sub

Private Function dumpSelection(ByVal p As String) As String
Dim s As String, p1 As String
Dim y1 As Integer, y2 As Integer, x1 As Integer, x2 As Integer

y1 = sel_sens1 - d_sens1
If y1 < 0 Then y1 = y1 + crz.crz.num

y2 = sel_sens2 - d_sens1
If y2 < 0 Then y2 = y2 + crz.crz.num

x1 = sel_x1 / trc.Step
x2 = sel_x2 / trc.Step


p1 = p & "  "
s = "{" & vbNewLine
s = s & p1 & Chr(34) & "x_left" & Chr(34) & ": " & x1 & "," & vbNewLine
s = s & p1 & Chr(34) & "x_right" & Chr(34) & ": " & x2 & "," & vbNewLine
s = s & p1 & Chr(34) & "y_top" & Chr(34) & ": " & y1 & "," & vbNewLine
s = s & p1 & Chr(34) & "y_bottom" & Chr(34) & ": " & y2 & "," & vbNewLine
s = s & p1 & Chr(34) & "calc_row" & Chr(34) & ": " & depth.lineNumber & "," & vbNewLine
s = s & p1 & Chr(34) & "calc_col" & Chr(34) & ": " & depth.maxPos & vbNewLine
s = s & p & "}"

dumpSelection = s
End Function

Private Sub fileAnalize(ByVal app_index As Integer)
Dim fl_row As String, fl_prc As String, fl_res As String
Dim fl As Integer, ap As clsExtApp
Dim Hash As New MD5Hash, d_h0 As String

Dim zoomDataFormat As Integer

zoomDataFormat = 1
If labh0.FontBold = False Then
  d_h0 = Chr(34) & Chr(34)
Else:
  d_h0 = "" & h0
End If

fl_row = GetTempFile()
fl_prc = GetTempFile()
fl_res = GetTempFile()

Kill fl_res
fl_res = fl_res + ".json"

If krotZoomDump(trc.handle, crz.crz.Index, fl_row, 1) = KRT_ERR Then
  ogdWin.Alert "Ошибка при записи дампа сырых данных:" & vbNewLine & lastError()
End If

If krotZoomDump(trc.handle, crz.crz.Index, fl_prc, 0) = KRT_ERR Then
  ogdWin.Alert "Ошибка при записи дампа обработанных данных:" & vbNewLine & lastError()
End If

fl = FreeFile
Open fl_res For Output As #fl

Print #fl, "{"

Print #fl, "  " & Chr(34) & "dataType" & Chr(34) & ": " & Chr(34) & dataTypeName(crz.crz.sensType) & Chr(34) & ","
Print #fl, "  " & Chr(34) & "magnetID" & Chr(34) & ": " & Chr(34) & trc.drv.d_magnID & Chr(34) & ","
Print #fl, "  " & Chr(34) & "isInside" & Chr(34) & ": " & IIf(lstInsideType.ItemData(lstInsideType.ListIndex) = EN_INT_TYPE.IT_EXT, 0, 1) & ","

Print #fl, "  " & Chr(34) & "sensNuminZone" & Chr(34) & ": " & trc.Coroz.zone(0).num & ","
Print #fl, "  " & Chr(34) & "dDiam" & Chr(34) & ": " & trc.drv.diamDflt & ","

Print #fl, "  " & Chr(34) & "crz_crz_num" & Chr(34) & ": " & crz.crz.num & ","
Print #fl, "  " & Chr(34) & "trc_Step" & Chr(34) & ": " & trc.Step & ","

Print #fl, "  " & Chr(34) & "sizeX" & Chr(34) & ": " & Me.SizeX & ","
Print #fl, "  " & Chr(34) & "sizeY" & Chr(34) & ": " & Me.SizeY & ","
Print #fl, "  " & Chr(34) & "operatorID" & Chr(34) & ": " & Chr(34) & Hash.HashBytes(CurrentUserName()) & Chr(34) & ","
Print #fl, "  " & Chr(34) & "recordID" & Chr(34) & ": " & Chr(34) & Hash.HashBytes(trc.FileName) & Chr(34) & ","
Print #fl, "  " & Chr(34) & "recordPosition" & Chr(34) & ": " & Me.x1 & ","
Print #fl, "  " & Chr(34) & "user_h0" & Chr(34) & ": " & d_h0 & ","

Print #fl, "  " & Chr(34) & "selection" & Chr(34) & ": " & dumpSelection("  ") & ","

Print #fl, "  " & Chr(34) & "dataRow" & Chr(34) & ": ["
AppendFileContent fl, fl_row, "    [", "]"
Print #fl, "  ],"

Print #fl, "  " & Chr(34) & "dataProc" & Chr(34) & ": ["
AppendFileContent fl, fl_prc, "    [", "]"
Print #fl, "  ],"

Print #fl, "  " & Chr(34) & "zoomDataFormat" & Chr(34) & ": " & zoomDataFormat

Print #fl, "}"

Close #fl

Kill fl_row

trc.extZoomData = fl_res

Set ap = cfg.ExternalApps.zoomApp(app_index)
ap.Run fl_res
Set ap = Nothing
End Sub

Private Sub setEditMode(ByVal isNewFlag As Boolean)
Dim s As String

If isNewFlag Then
 s = "Линза"
 Else
 s = "Редактирование дефекта"
End If

Me.Caption = s & " - " & trc.Description
isNew = isNewFlag
End Sub
