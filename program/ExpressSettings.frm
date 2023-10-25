VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Begin VB.Form frmExpressSettings 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Form1"
   ClientHeight    =   5670
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   4290
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5670
   ScaleWidth      =   4290
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame frameThick 
      Caption         =   "Настройки графика намагниченности"
      Height          =   735
      Left            =   120
      TabIndex        =   20
      Top             =   4200
      Width           =   4095
      Begin VB.ComboBox thkUnit 
         Height          =   315
         Left            =   2040
         Style           =   2  'Dropdown List
         TabIndex        =   21
         ToolTipText     =   "Вид информации для графика"
         Top             =   240
         Width           =   1935
      End
      Begin VB.Label Label3 
         Caption         =   "Единицы"
         Height          =   255
         Left            =   120
         TabIndex        =   22
         Top             =   240
         Width           =   855
      End
   End
   Begin VB.Frame frameSpeed 
      Caption         =   "Настройки графика скорости"
      Height          =   1215
      Left            =   120
      TabIndex        =   15
      Top             =   2880
      Width           =   4095
      Begin VB.ComboBox spdUnit 
         Height          =   315
         Left            =   2040
         Style           =   2  'Dropdown List
         TabIndex        =   17
         ToolTipText     =   "Вид информации для графика"
         Top             =   240
         Width           =   1935
      End
      Begin krotw32.multyNum speedVector 
         Height          =   255
         Left            =   2040
         TabIndex        =   16
         Top             =   720
         Width           =   1380
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin VB.Label labSpeedUnit 
         Caption         =   "Единицы"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   240
         Width           =   855
      End
      Begin VB.Label Label1 
         Caption         =   "Длина окна, м"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   18
         Top             =   720
         Width           =   1335
      End
   End
   Begin VB.CommandButton btmColor 
      Caption         =   "Цвет..."
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   2400
      Width           =   1335
   End
   Begin VB.TextBox txtMax 
      Height          =   285
      Left            =   2880
      TabIndex        =   8
      Text            =   "Text1"
      ToolTipText     =   "Верхняя граница значений графика"
      Top             =   1320
      Width           =   1095
   End
   Begin VB.TextBox txtMin 
      Height          =   285
      Left            =   2880
      TabIndex        =   7
      Text            =   "Text1"
      ToolTipText     =   "Нижняя граница значений графика"
      Top             =   1560
      Width           =   1095
   End
   Begin VB.ComboBox grType 
      Height          =   315
      Left            =   720
      Style           =   2  'Dropdown List
      TabIndex        =   5
      ToolTipText     =   "Вид информации для графика"
      Top             =   120
      Width           =   3255
   End
   Begin VB.CommandButton btmRefresh 
      Caption         =   "Обновить"
      Default         =   -1  'True
      Height          =   375
      Left            =   240
      TabIndex        =   0
      Top             =   5160
      Width           =   3735
   End
   Begin krotw32.ctrlNumBox txtStart 
      Height          =   255
      Left            =   2880
      TabIndex        =   1
      Top             =   600
      Width           =   1095
      _ExtentX        =   1931
      _ExtentY        =   450
   End
   Begin krotw32.ctrlNumBox txtEnd 
      Height          =   255
      Left            =   2880
      TabIndex        =   2
      Top             =   840
      Width           =   1095
      _ExtentX        =   1931
      _ExtentY        =   450
   End
   Begin ComctlLib.Slider lnWidth 
      Height          =   255
      Left            =   2040
      TabIndex        =   12
      Top             =   1920
      Width           =   1935
      _ExtentX        =   3413
      _ExtentY        =   450
      _Version        =   327682
      Min             =   1
      SelStart        =   1
      Value           =   1
   End
   Begin VB.Label Label2 
      Caption         =   "Толщина линии"
      Height          =   255
      Left            =   120
      TabIndex        =   14
      Top             =   1920
      Width           =   1695
   End
   Begin VB.Label labColor 
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Left            =   2160
      TabIndex        =   13
      Top             =   2400
      Width           =   1815
   End
   Begin VB.Label labMax 
      Caption         =   "Максимальная скорость, м/с"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   1320
      Width           =   2775
   End
   Begin VB.Label labMin 
      Caption         =   "Минимальная скорость, м/с"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   1560
      Width           =   2775
   End
   Begin VB.Label Label1 
      Caption         =   "График"
      Height          =   255
      Index           =   4
      Left            =   120
      TabIndex        =   6
      Top             =   120
      Width           =   615
   End
   Begin VB.Label Label1 
      Caption         =   "Начальная отметка, м"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   4
      Top             =   600
      Width           =   2775
   End
   Begin VB.Label Label1 
      Caption         =   "Конечная отметка, м"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   3
      Top             =   840
      Width           =   2775
   End
End
Attribute VB_Name = "frmExpressSettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private parent As frmSpeed
Public trc As clsTrace

Private Const EXT_SHIFT = 10000

Private Enum SPEED_UNIT
 SPEED_KM_HOUR = 36
 SPEED_M_SEC = 10
End Enum

Private Enum THICK_UNIT
 THICK_ADC = 0
 THICK_TSL = 1
End Enum

Private spd As New clsPrnGraph
Private tmp As New clsPrnGraph
Private orn As New clsPrnGraph
Private shk As New clsPrnGraph
Private prs As New clsPrnGraph
Private thk As New clsPrnGraph
Private crv As New clsPrnGraph
Private azm As New clsPrnGraph
Private tng As New clsPrnGraph

Private ext() As New clsPrnGraph
Private extNum As Integer

Private initFlag As Boolean
Private prevTypeIndex As Integer
Private enableGraph As Boolean

Public grf As clsPrnGraph
Public multKoef As Double
Public traceStart As Long
Public traceEnd As Long
Private traceLength As Long

Public Function Init(parentForm As frmSpeed, trace As clsTrace) As Boolean
Dim i As Integer

initFlag = True

Set parent = parentForm
Set trc = trace

Me.Icon = parent.Icon
Me.Caption = trc.Description & " настройка графиков экспресс-анализа"

traceStart = trc.getDistKoef(0)
traceEnd = trc.getDistKoef(trc.length)
traceLength = traceEnd - traceStart

labColor.BackColor = trc.expGraphColor

With thkUnit
.addItem "ед.АЦП"
.ItemData(.ListCount - 1) = THICK_UNIT.THICK_ADC
.addItem "млТесла"
.ItemData(.ListCount - 1) = THICK_UNIT.THICK_TSL
.ListIndex = 0
End With

With spdUnit
.addItem "метры в секунду"
.ItemData(.ListCount - 1) = SPEED_M_SEC
.addItem "километры в час"
.ItemData(.ListCount - 1) = SPEED_KM_HOUR
.ListIndex = 0
End With
multKoef = 1

speedVector.Min = SV_MIN
speedVector.Max = SV_MAX

extNum = trc.numExt
If extNum > 0 Then
 ReDim ext(extNum) As New clsPrnGraph
End If

With grType

 If trc.Timer.num > 0 Then
  spd.Init trc.Timer, trc, parent
  .addItem "Скорость"
  .ItemData(.ListCount - 1) = KRT_SENS.SENS_TIMER
 End If

 If trc.temp.num > 0 Then
  tmp.Init trc.temp, trc, parent
  .addItem "Температура"
  .ItemData(.ListCount - 1) = KRT_SENS.SENS_TEMP
 End If

 If trc.shake.num > 0 Then
  shk.Init trc.shake, trc, parent
  .addItem "Вибрация"
  .ItemData(.ListCount - 1) = KRT_SENS.SENS_SHAKE
 End If

 If trc.press.num > 0 Then
  prs.Init trc.press, trc, parent
  .addItem "Давление"
  .ItemData(.ListCount - 1) = KRT_SENS.SENS_PRESS
 End If

 If trc.angle.num > 0 Then
  orn.Init trc.angle, trc, parent
  orn.cycled = True
  .addItem "Вращение"
  .ItemData(.ListCount - 1) = KRT_SENS.SENS_ORIENT
 End If

 If trc.thick.num > 0 Then
  thk.Init trc.thick, trc, parent
  .addItem "Намагниченность"
  .ItemData(.ListCount - 1) = KRT_SENS.SENS_THICK
 End If

 If trc.curve.num > 0 Then
  crv.Init trc.curve, trc, parent
  .addItem "Изгиб"
  .ItemData(.ListCount - 1) = KRT_SENS.SENS_CURVE
 End If

 If trc.vog.enable Then
   If isSensAvail(trc, KRT_SENS.SENS_AZIMUTH) Then
    azm.Init trc.azimuth, trc, parent
    .addItem "Азимут"
    .ItemData(.ListCount - 1) = KRT_SENS.SENS_AZIMUTH
   End If
   If isSensAvail(trc, SENS_TANGAZH) Then
    tng.Init trc.tangazh, trc, parent
    .addItem "Тангаж"
    .ItemData(.ListCount - 1) = KRT_SENS.SENS_TANGAZH
   End If
 End If
 
 If extNum > 0 Then
  For i = 1 To extNum
   ext(i).Init trc.sensExt(i - 1), trc, parent, i - 1
  .addItem trc.sensExt(i - 1).name
  .ItemData(.ListCount - 1) = EXT_SHIFT + i
  Next
 End If

 prevTypeIndex = 0
 .ListIndex = 0
End With

FrameThick.Top = frameSpeed.Top
initFlag = False
End Function

Private Function crvUnitExp() As EXP_MSG
crvUnitExp = IIf(trc.isCurveGraphRadius, expCurveRad, expCurveGrad)
End Function

Public Sub changeSettings()
crv.ClearData
End Sub

Private Function thkUnitExp() As EXP_MSG
Select Case thkUnit.ItemData(thkUnit.ListIndex)
 Case THICK_UNIT.THICK_ADC
  thkUnitExp = EXP_MSG.expThickADC
 Case THICK_UNIT.THICK_TSL
  thkUnitExp = EXP_MSG.expThickTesla
End Select
End Function

Private Function spdUnitExp() As EXP_MSG
Select Case spdUnit.ItemData(spdUnit.ListIndex)
 Case SPEED_KM_HOUR
  spdUnitExp = EXP_MSG.expSpeedKM
 Case SPEED_M_SEC
  spdUnitExp = EXP_MSG.expSpeedMS
End Select
End Function

Private Function grfUnitStr(typ As KRT_SENS) As String

Select Case typ

  Case KRT_SENS.SENS_TIMER

    Select Case spdUnit.ItemData(spdUnit.ListIndex)
      Case SPEED_UNIT.SPEED_KM_HOUR
        grfUnitStr = ", " & "км/ч"
      Case SPEED_UNIT.SPEED_M_SEC
        grfUnitStr = ", " & "м/с"
      Case Else
        grfUnitStr = ""
    End Select
  
  Case KRT_SENS.SENS_THICK
  
    Select Case thkUnit.ItemData(thkUnit.ListIndex)
      Case THICK_UNIT.THICK_ADC
        grfUnitStr = ", " & "ед.АЦП"
      Case THICK_UNIT.THICK_TSL
        grfUnitStr = ", " & "млТесла"
      Case Else
        grfUnitStr = ""
    End Select
  
  Case Else
    grfUnitStr = ""

End Select

End Function

Private Sub setLangText()
Dim s As String

grf.setLang
parent.speed.Header.Text = grf.title

Select Case grf.typ

 Case KRT_SENS.SENS_TIMER
  s = grf.titleY & ", " & cfg.lngExpress.msg(spdUnitExp())
  
 Case KRT_SENS.SENS_THICK
  s = grf.titleY & ", " & cfg.lngExpress.msg(thkUnitExp())
  
 Case KRT_SENS.SENS_CURVE
  s = grf.titleY & ", " & cfg.lngExpress.msg(crvUnitExp())
 
 Case Else
  s = grf.titleY
  If Trim(s) = "" Then
    s = grf.title
  End If
  
End Select

parent.speed.ChartArea.Axes("Y").title = s
parent.speed.ChartArea.Axes("X").title = grf.titleX
End Sub

Private Sub showData()
Dim gType As KRT_SENS, mStr As String

If (grf.nodesCount = 0) And (Not enableGraph) Then Exit Sub
If grf.nodesCount = 0 Then grf.readData

'поправить ошибки преобразования дистанций с использованием коэф-ов одометра
If grf.Xmin < traceStart Then grf.Xmin = traceStart
If grf.Xmax > traceEnd Then grf.Xmax = traceEnd

setLangText

With parent.speed
.isBatched = True
.ChartLabels.RemoveAll
.Header.IsShowing = False
.ChartArea.Location.Left.Value = 0
.ChartArea.Location.Top.Value = 0
.ChartArea.border.width = 0
.ChartArea.PlotArea.Top.Value = 30
.ChartArea.PlotArea.Bottom.Value = 40
.ChartArea.PlotArea.Right.Value = 0
End With


gType = grType.ItemData(grType.ListIndex)
If gType = SENS_TIMER Then
 multKoef = spdUnit.ItemData(spdUnit.ListIndex) / 10#
 mStr = dblStr(multKoef * 0.01, 3)
 Else
 multKoef = 1
 mStr = "0.01"
End If

With parent.speed.ChartArea
.PlotArea.IsBoxed = True
.Axes("Y").AnnotationMethod = oc2dAnnotateValues
.Axes("Y").LabelFormat.Category = oc2dCategoryCustom
.Axes("Y").LabelFormat.Format = "[multiplier " & mStr & "]0.0"
'.Axes("Y").MajorGrid.Spacing = 100
'.Axes("Y").MajorGrid.Style.Pattern = oc2dLineDotted
.Axes("X").AnnotationMethod = oc2dAnnotateValues
.Axes("X").LabelFormat.Category = oc2dCategoryCustom
.Axes("X").LabelFormat.Format = "[multiplier 0.001]0.00"
.Axes("X").Min = grf.Xmin
.Axes("X").Max = grf.Xmax
.Axes("Y").Min = grf.Ymin
.Axes("Y").Max = grf.Ymax
End With

With parent.speed.ChartGroups(1).Styles(1)
.Symbol.Shape = oc2dShapeNone
.line.color = labColor.BackColor
.line.width = lnWidth.Value
End With

With parent.speed.ChartGroups(1).data
If grf.cycled Then .holeValue = grf.holeValue
 .NumSeries = 1
.NumPoints(1) = grf.nodesCount
.Layout = oc2dDataGeneral
.CopyXVectorIn 1, grf.arrX
.CopyYVectorIn 1, grf.arrY
End With

parent.speed.isBatched = False
parent.initFlag = False
Me.MousePointer = 0
End Sub

Private Sub setEnable(ByVal b As Boolean)
parent.speed.visible = b
btmRefresh.Caption = IIf(b, "Обновить", "Отмена")
btmRefresh.Tag = IIf(b, "", "1")
txtStart.enabled = b
txtEnd.enabled = b
txtMax.enabled = b
txtMin.enabled = b
grType.enabled = b
parent.Refresh
End Sub

Public Sub setXtexts()
txtStart.mm = grf.Xmin
txtEnd.mm = grf.Xmax
End Sub

Private Sub setYtexts()
txtMax.Text = Format$(grf.Ymax / 100# * multKoef, "0.00")
txtMin.Text = Format$(grf.Ymin / 100# * multKoef, "0.00")
End Sub

Public Sub showGraph()
enableGraph = cfg.expressOnOpen
speedVector.Value = trc.speedVector
If showGraphInt() = False Then
 parent.visible = False
End If
setReady
enableGraph = True
End Sub

Private Function showGraphInt() As Boolean
Dim i As Integer

showGraphInt = False
parent.Caption = grf.title & " " & trc.FileName
setXtexts
labMin.Caption = grf.labMin & grfUnitStr(grf.typ)
labMax.Caption = grf.labMax & grfUnitStr(grf.typ)
setYtexts

parent.visible = True
setEnable False

setWait "Формирую график...", vbArrowHourglass
If (grf.nodesCount = 0) And enableGraph Then
 grf.readData
 Else
 parent.speed.ChartGroups(1).data.NumSeries = 0
 parent.speed.ChartLabels.RemoveAll
End If

If (grf.nodesCount = 0) And enableGraph Then Exit Function

setEnable True
btmRefresh_Click
showGraphInt = True
End Function

Private Sub btmColor_Click()
Dim dlg As New clsCommonDialog

dlg.CancelError = True
dlg.color = labColor.BackColor
dlg.hwnd = Me.hwnd
On Error GoTo CancelColor

dlg.ShowColor
labColor.BackColor = dlg.color
Set dlg = Nothing
btmRefresh_Click

CancelColor:
End Sub

Private Sub btmRefresh_Click()

If btmRefresh.Tag = "1" Then
 If ogdWin.AskAction("Прервать формирование графика?") Then
  grf.breakFlag = True
 End If
 Exit Sub
End If

setWait "Пересчитываю график ..."

grf.Xmin = txtStart.mm
grf.Xmax = txtEnd.mm

grf.Ymin = CSng(txtMin.Text) * 100 / multKoef
grf.Ymax = CSng(txtMax.Text) * 100 / multKoef

showData
setReady
End Sub

Public Sub pageShift(ByVal forwardDirection As Boolean)
Dim pg As Long

pg = grf.Xmax - grf.Xmin
If pg >= traceLength Then Exit Sub

If forwardDirection Then
 grf.Xmin = grf.Xmax
 grf.Xmax = grf.Xmax + pg
 Else
 grf.Xmax = grf.Xmin
 grf.Xmin = grf.Xmin - pg
End If

If grf.Xmin < traceStart Then
 grf.Xmin = traceStart
 grf.Xmax = grf.Xmin + pg
End If

If grf.Xmax > traceEnd Then
 grf.Xmax = traceEnd
 grf.Xmin = grf.Xmax - pg
End If

setXtexts
setWait "Пересчитываю график ..."
showData
setReady

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.visible = False
 grf.breakFlag = True
End If
End Sub

Private Sub grType_Click()
Dim gType As KRT_SENS, spdFlag As Boolean, thkFlag As Boolean, i As Integer

spdFlag = False
thkFlag = False

gType = grType.ItemData(grType.ListIndex)

If initFlag Then
 Set grf = spd
 spdFlag = True
End If

If grf.typ <> gType Then
 Select Case gType
  Case KRT_SENS.SENS_TIMER
   Set grf = spd
   spdFlag = True
  Case KRT_SENS.SENS_TEMP
   Set grf = tmp
  Case KRT_SENS.SENS_ORIENT
   Set grf = orn
  Case KRT_SENS.SENS_SHAKE
   Set grf = shk
  Case KRT_SENS.SENS_PRESS
   Set grf = prs
  Case KRT_SENS.SENS_THICK
   Set grf = thk
   thkFlag = True
  Case KRT_SENS.SENS_CURVE
   Set grf = crv
  Case KRT_SENS.SENS_AZIMUTH
   Set grf = azm
  Case KRT_SENS.SENS_TANGAZH
   Set grf = tng
  Case Else
   If gType > EXT_SHIFT Then
    i = gType - EXT_SHIFT
    Set grf = ext(i)
   End If
 End Select
End If

frameSpeed.visible = spdFlag
FrameThick.visible = thkFlag

If initFlag Then Exit Sub
If showGraphInt() Then
 prevTypeIndex = grType.ListIndex
 Else
 If prevTypeIndex >= 0 Then
  grType.ListIndex = prevTypeIndex
 End If
End If
End Sub

Private Sub lnWidth_Change()
showData
End Sub

Private Sub spdUnit_Click()
If initFlag Then Exit Sub
showData
showGraphInt
setYtexts
End Sub

Public Sub full_graph()
grf.Xmin = traceStart
grf.Xmax = traceEnd
grf.Ymin = grf.valMin
grf.Ymax = grf.valMax
setXtexts
setYtexts
setWait "Пересчитываю график ..."
showData
setReady
End Sub

Private Sub speedVector_Change(m As Integer)
trc.speedVector = m
spd.ClearData
End Sub

Private Sub thkUnit_Click()
If initFlag Then Exit Sub
setWait "Формирую график...", vbArrowHourglass
grf.setUnits thkUnit.ListIndex
showData
showGraphInt
setYtexts
setReady
End Sub

