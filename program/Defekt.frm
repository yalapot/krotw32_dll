VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Object = "{C643EB3F-235C-4181-9B55-36A268833718}#7.0#0"; "olch2x7.ocx"
Begin VB.Form frmDefekt 
   Caption         =   "Form1"
   ClientHeight    =   3930
   ClientLeft      =   2625
   ClientTop       =   3540
   ClientWidth     =   7170
   Icon            =   "Defekt.frx":0000
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   3930
   ScaleWidth      =   7170
   Begin ComctlLib.StatusBar sbar 
      Align           =   2  'Align Bottom
      Height          =   255
      Left            =   0
      TabIndex        =   6
      Top             =   3675
      Width           =   7170
      _ExtentX        =   12647
      _ExtentY        =   450
      SimpleText      =   ""
      _Version        =   327682
      BeginProperty Panels {0713E89E-850A-101B-AFC0-4210102A8DA7} 
         NumPanels       =   2
         BeginProperty Panel1 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            TextSave        =   ""
            Key             =   ""
            Object.Tag             =   ""
         EndProperty
         BeginProperty Panel2 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            TextSave        =   ""
            Key             =   ""
            Object.Tag             =   ""
         EndProperty
      EndProperty
   End
   Begin VB.ComboBox lstZone 
      Height          =   315
      Left            =   4440
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   80
      Width           =   2655
   End
   Begin VB.CommandButton btmRefresh 
      Caption         =   "Обновить"
      Default         =   -1  'True
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   1095
   End
   Begin VB.CommandButton brmPrint 
      Caption         =   "Печать"
      Height          =   375
      Left            =   1320
      TabIndex        =   1
      Top             =   0
      Width           =   1095
   End
   Begin VB.CommandButton btmClip 
      Caption         =   "Буфер"
      Height          =   375
      Left            =   2520
      TabIndex        =   2
      Top             =   0
      Width           =   1095
   End
   Begin C1Chart2D7.Chart2D pic 
      Height          =   3135
      Left            =   0
      TabIndex        =   3
      Top             =   480
      Width           =   7095
      _Version        =   458752
      _Revision       =   4
      _ExtentX        =   12515
      _ExtentY        =   5530
      _StockProps     =   0
      ControlProperties=   "Defekt.frx":0442
   End
   Begin VB.Label lab 
      Caption         =   "Пояс"
      Height          =   255
      Left            =   3720
      TabIndex        =   4
      Top             =   120
      Width           =   615
   End
End
Attribute VB_Name = "frmDefekt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private crz As ctrlCoroz
Private trc As clsTrace
Private frm As frmTrace
Private tmpBitmap As String

Private minWidth As Single
Private minHeight As Single
Private initFlag As Boolean
Private hlp As New clsHelp
Private frm_setting As New clsFormProps
Private isSetWidth As Boolean

Public Event snapShot()

Public Sub showData()
Dim dlt As Double, j As Integer, i As Integer

i = lstZone.ListIndex
Set crz = frm.Coroz.zone(i)

If (crz.crz.Index > 0) And (crz.crz.visible = False) Then
 btmRefresh_Click
 Exit Sub
End If

RaiseEvent snapShot
 
crz.Draw
If trc.db.showForever Then frm.Objects.showAllObj

If krotSetClipboard(crz.pic.hWnd) = KRT_ERR Then
 ogdWin.Alert "Error frmDefekt.showData.krotSetClipboard" & vbNewLine & lastError()
 Exit Sub
End If

dlt = (crz.crz.num - crz.crz.topSens) * 12# / crz.crz.num
SavePicture Clipboard.GetData(vbCFBitmap), tmpBitmap

If Me.visible Then Me.SetFocus

With pic
.IsBatched = True
'.Header.Text = "Заголовок"
.ChartLabels.RemoveAll
End With

With pic.ChartArea.Axes("Y").ValueLabels
.RemoveAll
j = Fix(0 - dlt)
For i = 0 To 12
 .Add j, IIf(j < 0, j + 12, j)
 j = j + 1
Next
End With

With pic.ChartArea

.PlotArea.IsBoxed = True
.PlotArea.Interior.Image.FileName = ""
.PlotArea.Interior.Image.FileName = tmpBitmap
.PlotArea.Interior.Image.Layout = oc2dImageStretched

'.Axes("Y").title = "часы"
.Axes("Y").AnnotationMethod = oc2dAnnotateValueLabels
.Axes("Y").MajorGrid.Spacing = 1
.Axes("Y").MajorGrid.Style.Pattern = oc2dLineNone
'.Axes("X").title = "дистанция"
.Axes("X").AnnotationMethod = oc2dAnnotateValues
.Axes("X").LabelFormat.Category = oc2dCategoryCustom
.Axes("X").LabelFormat.Format = "[multiplier 0.001]0.00"

.Axes("X").Min = trc.getDistKoef(trc.pageStart)
.Axes("X").Max = trc.getDistKoef(trc.pageStart + trc.pageLength)
.Axes("Y").IsReversed = True
.Axes("Y").Min = 0 - dlt
.Axes("Y").Max = 12 - dlt
.Axes("Y").OriginPlacement = oc2dOriginMinimum
End With

With pic.ChartGroups(1).Styles(1)
.Symbol.Shape = oc2dShapeNone
.line.color = RGB(0, 0, 0)
End With

With pic.ChartGroups(1).data
.NumSeries = 1
.NumPoints(1) = 2
.Layout = oc2dDataGeneral
.x(1, 1) = trc.getDistKoef(trc.pageStart)
.y(1, 1) = 0
.x(1, 2) = trc.getDistKoef(trc.pageStart + trc.pageLength)
.y(1, 2) = 0
End With

pic.IsBatched = False

Me.visible = True
End Sub

Public Sub Init(formTrace As frmTrace)
Dim i As Integer

initFlag = True
Set frm = formTrace
Set trc = formTrace.trc

For i = 0 To trc.Coroz.num - 1
 lstZone.addItem trc.Coroz.zone(i).name
 lstZone.ItemData(lstZone.ListCount - 1) = i
Next
setLst lstZone, 0

tmpBitmap = Left$(trc.FileName, Len(trc.FileName) - 3) & "bmp"
Me.Caption = "Фрагмент развертки " & trc.FileName

frm_setting.Init trc.secUser, "frmDefekt"
frm_setting.restoreForm Me

initFlag = False
End Sub

Public Sub Save()
frm_setting.saveForm Me
End Sub

Private Sub brmPrint_Click()
pic.PrintChart oc2dFormatBitmap, oc2dScaleToMax, 0, 0, 0, 0
End Sub

Private Sub btmClip_Click()
pic.CopyToClipboard oc2dFormatBitmap
End Sub

Private Sub btmRefresh_Click()
Dim vis As Boolean

pic.CallAction oc2dActionReset, 0, 0
vis = trc.Coroz.visible

If crz.crz.Index > 0 Then
 If crz.crz.visible Then
 vis = vis
 Else
 vis = False
 End If
End If

If vis Then
 showData
Else
 ogdWin.Alert lstZone.List(lstZone.ListIndex) & " отключен" & vbNewLine & _
  "Не могу создать изображение."
End If
End Sub

Private Sub Form_Load()
minWidth = 7290 'Me.width
minHeight = 4080 'Me.Height
Me.width = minWidth
Me.Height = minHeight
hlp.BindHelp Me, KRT_AnaCorozTube
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.visible = False
End If
End Sub

Private Sub Form_Resize()
Static intFlag As Boolean

If intFlag Then Exit Sub
intFlag = True
If Me.WindowState = vbMinimized Then Exit Sub

If Me.width < minWidth Then Me.width = minWidth
If Me.Height < minHeight Then Me.Height = minHeight

pic.width = Me.ScaleWidth - pic.Left - 100
pic.Height = Me.ScaleHeight - pic.Top - 100

sbar.Panels(1).Text = "X: " & Me.width
sbar.Panels(2).Text = "Y: " & Me.Height

intFlag = False
End Sub

Private Sub lstZone_Click()
If initFlag Then Exit Sub
showData
End Sub

Private Sub sbar_DblClick()
Dim s As String, v As Long

If isSetWidth Then
  s = InputBox("Ширина окна:", "Задайте ширину окна", Me.width)
  If Len(s) > 0 Then
    v = val(s)
    If v < minWidth Then v = minWidth
    Me.width = v
  End If
  Else
  s = InputBox("Высота окна:", "Задайте высоту окна", Me.Height)
  If Len(s) > 0 Then
    v = val(s)
    If v < minHeight Then v = minHeight
    Me.Height = v
  End If
End If
End Sub

Private Sub sbar_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
isSetWidth = IIf(x > 1440, False, True)
End Sub
