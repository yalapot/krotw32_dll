VERSION 5.00
Begin VB.UserControl trcCtrl 
   ClientHeight    =   750
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   8550
   ScaleHeight     =   750
   ScaleWidth      =   8550
   ToolboxBitmap   =   "trcCtrl.ctx":0000
   Begin VB.ComboBox lstScale 
      Height          =   315
      Left            =   5280
      Style           =   2  'Dropdown List
      TabIndex        =   13
      Top             =   0
      Width           =   735
   End
   Begin krotw32.longScroll lScroll 
      Height          =   255
      Left            =   0
      TabIndex        =   6
      ToolTipText     =   "Указатель положения на трассе"
      Top             =   480
      Width           =   8535
      _ExtentX        =   15055
      _ExtentY        =   450
   End
   Begin krotw32.autoScroll aScroll 
      Height          =   255
      Left            =   960
      TabIndex        =   5
      Top             =   0
      Width           =   1215
      _ExtentX        =   2143
      _ExtentY        =   450
   End
   Begin VB.TextBox txtInput 
      Height          =   285
      Left            =   2880
      TabIndex        =   4
      Text            =   "Text1"
      Top             =   1680
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.Label labScale 
      Caption         =   "масштаб X"
      Height          =   255
      Left            =   6120
      TabIndex        =   14
      Top             =   0
      Width           =   975
   End
   Begin VB.Label markDist 
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Left            =   2160
      TabIndex        =   9
      Top             =   240
      Width           =   1335
   End
   Begin VB.Label dMarkWhite 
      Alignment       =   1  'Right Justify
      BackColor       =   &H80000005&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   960
      TabIndex        =   12
      ToolTipText     =   "Дистанция от курсора до белого маркера"
      Top             =   240
      Width           =   975
   End
   Begin VB.Label dMarkBlack 
      Alignment       =   1  'Right Justify
      BackColor       =   &H80000008&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   6600
      TabIndex        =   11
      ToolTipText     =   "Дистанция от курсора до черного маркера"
      Top             =   240
      Width           =   975
   End
   Begin VB.Label visLength 
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Left            =   2160
      TabIndex        =   10
      ToolTipText     =   "Длина видимого участка"
      Top             =   0
      Width           =   1335
   End
   Begin VB.Label markBlack 
      Alignment       =   1  'Right Justify
      BackColor       =   &H80000008&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   7560
      TabIndex        =   8
      ToolTipText     =   "Отметка черного маркера"
      Top             =   240
      Width           =   975
   End
   Begin VB.Label markWhite 
      Alignment       =   1  'Right Justify
      BackColor       =   &H80000005&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   0
      TabIndex        =   7
      ToolTipText     =   "Отметка белого маркера"
      Top             =   240
      Width           =   975
   End
   Begin VB.Label labEd 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      Height          =   255
      Left            =   7320
      TabIndex        =   3
      ToolTipText     =   "Единицы измерения трассы (дистанция/время)"
      Top             =   0
      Width           =   255
   End
   Begin VB.Label markEnd 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      Height          =   255
      Left            =   7560
      TabIndex        =   2
      ToolTipText     =   "Конец видимого участка"
      Top             =   0
      Width           =   975
   End
   Begin VB.Label cursPosX 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "999999.99"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3550
      TabIndex        =   1
      ToolTipText     =   "Текущая отметка курсора"
      Top             =   0
      Width           =   1695
   End
   Begin VB.Label markStart 
      Alignment       =   1  'Right Justify
      BorderStyle     =   1  'Fixed Single
      Caption         =   "500000.00"
      Height          =   255
      Left            =   0
      TabIndex        =   0
      ToolTipText     =   "Начало видимого участка"
      Top             =   0
      Width           =   975
   End
End
Attribute VB_Name = "trcCtrl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const LEFT_SHIFT = 500

Private ctlWidth As Single, ctlHeight As Single
Private scrlSide As Integer
Private initFlag As Boolean
Private trc As clsTrace

Public Event Scroll(ByVal isOn As Boolean)
Public Event pageChange(ByVal newScale As Integer)
Public Event posChange(ByVal newPos As Long)

Public Function Init(trace As clsTrace) As Boolean
Dim i As Integer, itm As Integer

initFlag = True

Set trc = trace
'заполнить список масштабов по X
cfg.parser.Delim = ";"
cfg.parser.TestString = cfg.parser.Delim & trc.drv.scales(True)
cfg.parser.Parse

For i = 1 To cfg.parser.count
 itm = Val(cfg.parser.Item(i))
 lstScale.addItem cfg.crz.scaleText(itm)
 lstScale.ItemData(lstScale.ListCount - 1) = itm
 If itm = trc.pageScaleX Then lstScale.ListIndex = lstScale.ListCount - 1
Next
lstScale.addItem "Пользовательский"
lstScale.ItemData(lstScale.ListCount - 1) = USER_SCALE_X
If trc.pageScaleX = USER_SCALE_X Then lstScale.ListIndex = lstScale.ListCount - 1

labEd.caption = "Д"
labEd.ToolTipText = "Развертка по дистанции"

lScroll.Init trc
aScroll.TimerInterval = cfg.TimerInterval
aScroll.asCurSpeed = trc.scrollSpeed

cursPosX.caption = ""
dMarkWhite.caption = ""
dMarkBlack.caption = ""

initFlag = False
Init = True
End Function

Property Get minWidth() As Single
minWidth = ctlWidth
End Property

Property Get minHeight() As Single
minHeight = ctlHeight
End Property

Public Sub scrollDo(ByVal side As Integer)
RaiseEvent posChange(trc.pageStart + trc.smallShift * side)
End Sub

Public Sub setScale(ByVal scl As Long)
Dim i As Integer, oldIndex As Integer

oldIndex = lstScale.ListIndex
For i = 0 To lstScale.ListCount - 1
 If lstScale.ItemData(i) = scl Then lstScale.ListIndex = i
Next
If oldIndex = lstScale.ListIndex Then lstScale_Click
End Sub

Private Sub lScroll_Change(ByVal pos As Long)
RaiseEvent posChange(pos)
End Sub

Private Sub lstScale_Click()
If initFlag Then Exit Sub
RaiseEvent pageChange(lstScale.ItemData(lstScale.ListIndex))
End Sub

Private Sub aScroll_asScroll(ByVal speed As Integer)
Dim newVal As Long

On Error GoTo errHandler
newVal = trc.pageStart + trc.smallShift * scrlSide

If (newVal <= 0) Or (newVal >= (trc.length - trc.pageLength)) Then
 aScroll.asStop
 Else
 RaiseEvent posChange(newVal)
End If
On Error GoTo 0
Exit Sub

errHandler:
ogdWin.Alert "Err number: " & Err.Number & vbCrLf & "Description: " & Err.Description & vbCrLf & "Source: " & Err.Source
End
End Sub

Private Sub aScroll_asSpeed(ByVal speed As Integer)
trc.scrollSpeed = speed
End Sub

Private Sub aScroll_asStartLeft()
scrlSide = -1
RaiseEvent Scroll(True)
End Sub

Private Sub aScroll_asStartRight()
scrlSide = 1
RaiseEvent Scroll(True)
End Sub

Private Sub aScroll_asStop()
scrlSide = 0
RaiseEvent Scroll(False)
End Sub

Property Get isScrollInProgress() As Boolean
isScrollInProgress = IIf(scrlSide = 0, False, True)
End Property

Public Sub mouseMove(ByVal x As Long)
Dim st As Long, ln As Long

cursPosX.Caption = mm2txt(trc.getDistKoef(x))

If X > trc.mark.white Then
 st = trc.mark.white
 ln = trc.getLenKoef(st, X - trc.mark.white)
 Else
 st = X
 ln = trc.getLenKoef(st, trc.mark.white - X) * -1
End If
dMarkWhite.Caption = mm2txt(ln)

If X > trc.mark.black Then
 st = trc.mark.black
 ln = trc.getLenKoef(st, X - trc.mark.black)
 Else
 st = X
 ln = trc.getLenKoef(st, trc.mark.black - X) * -1
End If
dMarkBlack.Caption = mm2txt(ln)
End Sub

Private Sub markDist_Click()
trc.mark.isCurrWhite = Not (trc.mark.isCurrWhite)
Me.Draw
End Sub

Private Sub UserControl_Initialize()
ctlWidth = UserControl.width
ctlHeight = UserControl.Height
scrlSide = 0
markWhite.BackColor = Color.markWhiteBackColor
dMarkWhite.BackColor = Color.markWhiteBackColor
dMarkBlack.BackColor = Color.markBlackBackColor
markBlack.BackColor = Color.markBlackBackColor
End Sub

Private Sub UserControl_Resize()
Static intFlag As Boolean

If intFlag Then Exit Sub
intFlag = True

If UserControl.width < ctlWidth Then UserControl.width = ctlWidth
lScroll.width = UserControl.width
markEnd.Left = lScroll.Left + lScroll.width - markEnd.width
markBlack.Left = markEnd.Left
dMarkBlack.Left = markBlack.Left - dMarkBlack.width
labEd.Left = markEnd.Left - labEd.width
UserControl.Height = ctlHeight

intFlag = False
End Sub

Public Sub Draw()

lScroll.Draw

With trc.mark

If .isCurrWhite Then
 markDist.BackColor = markWhite.BackColor
 markDist.ForeColor = markWhite.ForeColor
 markDist.ToolTipText = "Дистанция между маркерами. Активен белый маркер"
 Else
 markDist.BackColor = markBlack.BackColor
 markDist.ForeColor = markBlack.ForeColor
 markDist.ToolTipText = "Дистанция между маркерами. Активен черный маркер"
End If

markWhite.Caption = mm2txt(trc.getDistKoef(.white))
markBlack.Caption = mm2txt(trc.getDistKoef(.black))
markDist.Caption = mm2txt(trc.getLenKoef(.white, .black - .white))
End With

markStart.Caption = mm2txt(trc.getDistKoef(trc.pageStart))
markEnd.Caption = mm2txt(trc.getDistKoef(trc.pageStart + trc.pageLength))
visLength.Caption = mm2txt(trc.getLenKoef(trc.pageStart, trc.pageLength))

End Sub

Public Sub switchScroll()
aScroll.switchScroll
End Sub