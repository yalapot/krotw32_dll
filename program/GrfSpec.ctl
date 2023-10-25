VERSION 5.00
Begin VB.UserControl ctrlGrfSpec 
   ClientHeight    =   750
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   14805
   HasDC           =   0   'False
   ScaleHeight     =   750
   ScaleWidth      =   14805
   ToolboxBitmap   =   "GrfSpec.ctx":0000
   Begin VB.CheckBox chkReverse 
      Caption         =   "Инв"
      Height          =   255
      Left            =   13320
      TabIndex        =   11
      ToolTipText     =   "Зеркальная отрисовка графиков"
      Top             =   0
      Width           =   855
   End
   Begin VB.CheckBox diskret 
      Caption         =   "Дискрет"
      Height          =   255
      Left            =   12240
      TabIndex        =   10
      ToolTipText     =   "Не апроксимированный реальный дискретный график"
      Top             =   0
      Width           =   975
   End
   Begin VB.PictureBox picGraf 
      Height          =   495
      Left            =   360
      ScaleHeight     =   435
      ScaleWidth      =   1035
      TabIndex        =   0
      Top             =   240
      Width           =   1095
   End
   Begin VB.CheckBox autoInterval 
      Caption         =   "Авто"
      Height          =   255
      Left            =   11400
      TabIndex        =   8
      ToolTipText     =   "Автоматически менять интервал показаний в зависимости от текущих значений графика"
      Top             =   0
      Width           =   735
   End
   Begin VB.Label labTurnAngle 
      Height          =   255
      Left            =   6810
      TabIndex        =   15
      ToolTipText     =   "радиус поворота между маркерами"
      Top             =   0
      Width           =   4350
   End
   Begin VB.Label markBlack 
      Alignment       =   1  'Right Justify
      BackColor       =   &H80000008&
      Caption         =   "500000.00"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   3120
      TabIndex        =   14
      ToolTipText     =   "на правом маркере"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label markWhite 
      Alignment       =   1  'Right Justify
      BackColor       =   &H00FFFFFF&
      Caption         =   "500000.00"
      Height          =   255
      Left            =   1200
      TabIndex        =   13
      ToolTipText     =   "на левом маркере"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label markRelDiff 
      Alignment       =   1  'Right Justify
      Caption         =   "500000.00"
      Height          =   255
      Left            =   4080
      TabIndex        =   12
      ToolTipText     =   "приведенная разница, dH/H0"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label brdDif 
      AutoSize        =   -1  'True
      Caption         =   "X-X-X-X-X"
      Height          =   195
      Left            =   1560
      TabIndex        =   9
      ToolTipText     =   "Размер диапазона"
      Top             =   360
      Width           =   705
   End
   Begin VB.Label markBlackRelDiff 
      Alignment       =   1  'Right Justify
      BackColor       =   &H80000008&
      Caption         =   "500000.00"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   5790
      TabIndex        =   7
      ToolTipText     =   "приведенная разница на правом маркере (правый маркер берется за минимум), dH/H0"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label markDiff 
      Alignment       =   1  'Right Justify
      Caption         =   "500000.00"
      Height          =   255
      Left            =   2160
      TabIndex        =   6
      ToolTipText     =   "разница по маркерам"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label markWhiteRelDiff 
      Alignment       =   1  'Right Justify
      BackColor       =   &H00FFFFFF&
      Caption         =   "500000.00"
      Height          =   255
      Left            =   4935
      TabIndex        =   5
      ToolTipText     =   "приведенная разница на левом маркере (левый маркер берется за минимум), dH/H0"
      Top             =   0
      Width           =   855
   End
   Begin VB.Label brdLow 
      AutoSize        =   -1  'True
      Caption         =   "123456"
      Height          =   195
      Left            =   0
      TabIndex        =   4
      ToolTipText     =   "Нижняя граница диапазона"
      Top             =   480
      Width           =   540
   End
   Begin VB.Label brdHigh 
      AutoSize        =   -1  'True
      Caption         =   "123456"
      Height          =   195
      Left            =   0
      TabIndex        =   3
      ToolTipText     =   "Верхняя граница диапазона"
      Top             =   240
      Width           =   540
   End
   Begin VB.Label labVal 
      AutoSize        =   -1  'True
      Caption         =   "123456"
      Height          =   195
      Left            =   360
      TabIndex        =   2
      ToolTipText     =   "Значение на курсоре"
      Top             =   0
      Width           =   540
   End
   Begin VB.Label labName 
      AutoSize        =   -1  'True
      Caption         =   "Label1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   195
      Left            =   14160
      TabIndex        =   1
      Top             =   0
      Width           =   585
   End
   Begin VB.Menu menuGraph 
      Caption         =   "Меню"
      Begin VB.Menu mnuGraph 
         Caption         =   "Интервал значений"
         Index           =   0
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "Размер"
         Index           =   1
         Begin VB.Menu mnuSize 
            Caption         =   "x 1"
            Index           =   0
         End
         Begin VB.Menu mnuSize 
            Caption         =   "x 2"
            Index           =   1
         End
         Begin VB.Menu mnuSize 
            Caption         =   "x 3"
            Index           =   2
         End
         Begin VB.Menu mnuSize 
            Caption         =   "x 4"
            Index           =   3
         End
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "Маркера"
         Index           =   2
         Begin VB.Menu mnuMark 
            Caption         =   "Базовый"
            Index           =   0
         End
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "Копировать в буфер"
         Index           =   3
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "Вставить поворот"
         Index           =   4
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "Линейки"
         Index           =   5
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "Закрыть"
         Index           =   6
      End
   End
End
Attribute VB_Name = "ctrlGrfSpec"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private drawFlag As Boolean
Private leftShiftBorder As Single
Private trc As clsTrace
Private parentForm As frmTrace
Private graphHight As Single
Private markIndex As Integer

Private pixRight As Integer

Private curs As New clsCursor
Private WithEvents dragEntry As clsDragMark
Attribute dragEntry.VB_VarHelpID = -1

Public sens As clsSensorGraph

Public Event mouseMove(ByVal y As Integer, ByVal x As Long)
Public Event setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
Public Event setMarkOsnap(ByVal mrkWhite As Boolean, ByVal newPos As Long)
Public Event sizeChange()
Public Event changeMark()
Public Event off()
Public Event addTurn()
Public Event keyDown(ByVal KeyCode As Integer, ByVal Shift As Integer)

Public Function Init( _
frm As frmTrace, _
sensor As clsSensorGraph, _
ByVal leftShift As Single _
) As Boolean
Dim minVal As Long, maxVal As Long

Init = False

Set sens = sensor
Set parentForm = frm
Set trc = frm.trc

drawFlag = False
Set dragEntry = New clsDragMark
leftShiftBorder = leftShift
labName.Caption = sens.name

curs.Init picGraf, USR_VLINE
curs.cursType = CURS_USER_NORMAL

mnuSize(sens.hKoef).Checked = True
markIndex = -1
If sens.num > 1 Then
 mnuGraph(2).visible = True
 makeMarkMenu
 Else
 mnuGraph(2).visible = False
End If
mnuGraph(4).visible = sensor.isVOG

Init = True
End Function

Public Sub mouseMove(ByVal x As Single)
curs.Draw x, 0
End Sub

Private Sub autoInterval_Click()
If drawFlag Then Exit Sub
sens.autoBrd = IIf(autoInterval.Value = 0, False, True)
Me.Draw
End Sub

Private Sub chkReverse_Click()
If drawFlag Then Exit Sub
sens.reverse = IIf(chkReverse.Value = 0, False, True)
Me.Draw
End Sub

Private Sub diskret_Click()
If drawFlag Then Exit Sub
sens.diskret = IIf(diskret.Value = 0, False, True)
Me.Draw
End Sub

Private Sub dragEntry_Complete(ByVal mrkWhite As Boolean, ByVal newPos As Single)
RaiseEvent setMark(mrkWhite, newPos)
Me.Draw
End Sub

Private Sub mnuGraph_Click(Index As Integer)

Select Case Index

 Case 0 'интервал значений
  If frmSensInterval.setInterval(frmMain, sens) Then Me.Draw

 Case 3 'скопировать в буфер обмена
  If krotSetClipboard(picGraf.hWnd) = KRT_ERR Then
   ogdWin.Alert "Error ctrlGrfSpec.mnuGraph_Click(3)" & vbNewLine & lastError()
  End If

 Case 4 'вставить поворот
  RaiseEvent addTurn

 Case 5 'линейки
  If frmRuler.View(parentForm, Me) Then
    Me.Draw
  End If

 Case 6 'закрыть
  offAllGraph
  RaiseEvent off

End Select
End Sub

Private Sub offAllGraph()
sens.offAll
End Sub

Private Sub mnuMark_Click(Index As Integer)
Me.markSensIndex = Index
drawMarkSens
End Sub

Private Sub mnuSize_Click(Index As Integer)
mnuSize(sens.hKoef).Checked = False
mnuSize(Index).Checked = True
sens.hKoef = Index
UserControl_Resize
RaiseEvent sizeChange
Me.Draw
End Sub

Private Sub picGraf_DblClick()
RaiseEvent changeMark
End Sub

Private Sub picGraf_KeyDown(KeyCode As Integer, Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Private Sub picGraf_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim m As Boolean

If Button = 1 Then
 Select Case sens.findMarker(picGraf, x)
  Case 0 'нет маркера
   Exit Sub
  Case 1 'белый
   dragEntry.drawColor = color.markWhite
   m = True
  Case 2 'черный
   dragEntry.drawColor = color.markBlack
   m = False
 End Select
 dragEntry.drawInvert = True
 dragEntry.Start picGraf, x, m
End If
End Sub

Private Sub picGraf_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim s As String

' curs.cursType = CURS_USER_NORMAL
Select Case Shift
 Case 2 'ctrl
 curs.uType = USR_HLINE
 s = sens.dispVal(Y - picGraf.ScaleHeight * IIf(sens.reverse, 0, 1))
 Case 1 'shift
 Case 0 'ничего не нажато
  curs.uType = USR_VLINE
  s = sens.dispVal(sens.getVal(X, markIndex))
End Select

labVal.Caption = s
If dragEntry.inProgress = False Then curs.Draw X, Y
RaiseEvent mouseMove(0, x)
End Sub

Private Sub picGraf_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)

Select Case Button
 Case 2
 UserControl.popUpMenu menuGraph
 Exit Sub
End Select

Select Case Shift
 Case 0 'ничего не нажато
 Case 1 'shift
 Case 2 'ctrl
 curs.needErase = False
 RaiseEvent setMark(sens.isCurrMarkWhite, x)
 Me.Draw
 Case 4 'alt
 'MsgBox "Установить маркер"
 curs.needErase = False
 RaiseEvent setMarkOsnap(sens.isCurrMarkWhite, x)
End Select
End Sub

Private Sub picGraf_Paint()
If sens Is Nothing Then Exit Sub
Me.Draw
End Sub

Private Sub UserControl_Initialize()
markWhite.ForeColor = color.markWhite
markBlack.ForeColor = color.markBlack
graphHight = picGraf.Height
pixRight = 0
End Sub

Private Sub UserControl_Resize()
Dim tmp As Single

If sens Is Nothing Then Exit Sub

picGraf.Left = leftShiftBorder
labVal.Left = picGraf.Left
brdDif.Left = brdLow.Left

tmp = UserControl.ScaleWidth - picGraf.Left - pixRight * Screen.twipsPerPixelX
picGraf.width = IIf(tmp > 0, tmp, 1)
picGraf.Height = graphHight * (sens.hKoef + 1)
brdLow.Top = picGraf.Top + picGraf.Height - brdLow.Height
brdDif.Top = (brdLow.Top - brdHigh.Top) / 2 + brdHigh.Top
brdDif.ZOrder 1
UserControl.Height = picGraf.Top + picGraf.Height ' * Screen.twipsPerPixelY
End Sub

Property Get markSensIndex() As Integer
markSensIndex = markIndex
End Property

Property Let markSensIndex(i As Integer)
If markIndex > -1 Then mnuMark(markIndex).Checked = False
markIndex = i
mnuMark(markIndex).Checked = True
End Property

Private Sub makeMarkMenu()
Dim i As Integer

mnuMark(0).Caption = sens.line(0).Caption
For i = 1 To sens.num - 1
 Load mnuMark(i)
 mnuMark(i).Caption = sens.line(i).Caption
 mnuMark(i).visible = True
Next i
Me.markSensIndex = 0
End Sub

Public Sub Draw(Optional forceRead As Boolean = False)
If UserControl.Extender.visible = False Then Exit Sub
labName.Caption = sens.name
sens.Draw picGraf, forceRead

drawFlag = True
autoInterval.Value = IIf(sens.autoBrd, 1, 0)
diskret.Value = IIf(sens.diskret, 1, 0)
chkReverse = IIf(sens.reverse, 1, 0)
drawFlag = False

drawMarkSens
curs.needErase = False
End Sub

Private Sub drawMarkSens()
Dim w As Single, b As Single, cl As Long, markMin As Long, s As String
Dim mrkBlack As Long, mrkWhite As Long
Dim dt As T_TURNDATA
Dim markBlackRelDiffStr As String, markWhiteRelDiffStr As String, markRelDiffStr As String, labTurnAngleStr As String

If markIndex > 0 Then
 cl = color.clrIndx(markIndex)
 markWhite.ForeColor = cl
 markBlack.ForeColor = cl
 Else
 markWhite.ForeColor = color.markWhiteText
 markBlack.ForeColor = color.markBlackText
End If

markRelDiffStr = "" '"dH/H0: "
markWhite.Caption = sens.dispVal(sens.markW(markIndex))
markBlack.Caption = sens.dispVal(sens.markB(markIndex))
markDiff.Caption = sens.dispVal(sens.markB(markIndex) - sens.markW(markIndex))
markMin = IIf(sens.markW(markIndex) < sens.markB(markIndex), sens.markW(markIndex), sens.markB(markIndex))
If markMin <> 0 Then
  markRelDiff.Caption = markRelDiffStr + sens.dispVal((sens.markB(markIndex) - sens.markW(markIndex)) / markMin * 100)
  Else
  markRelDiff.Caption = markRelDiffStr + "n/a"
End If

markWhiteRelDiffStr = "" '"dH/H0: "
markMin = sens.markW(markIndex)
If markMin <> 0 Then
  markWhiteRelDiff.Caption = markWhiteRelDiffStr + sens.dispVal((sens.brdMax - sens.markW(markIndex)) / markMin * 100)
  Else
  markWhiteRelDiff.Caption = markWhiteRelDiffStr + "n/a"
End If

markBlackRelDiffStr = "" '"dH/H0: "
markMin = sens.markB(markIndex)
If markMin <> 0 Then
  markBlackRelDiff.Caption = markBlackRelDiffStr + sens.dispVal((sens.markB(markIndex) - sens.brdMax) / markMin * 100)
  Else
  markBlackRelDiff.Caption = markBlackRelDiffStr + "n/a"
End If

brdHigh.Caption = sens.dispVal(IIf(sens.reverse, sens.brdMin, sens.brdMax))
brdLow.Caption = sens.dispVal(IIf(sens.reverse, sens.brdMax, sens.brdMin))
brdDif.Caption = sens.dispVal(sens.brdMax - sens.brdMin)

If Len(sens.TurnAngleTitle) > 0 Then
 labTurnAngle.Caption = sens.TurnAngleTitle & sens.TurnAngleValue
End If
End Sub

Property Get pixelRight() As Integer
pixelRight = pixRight
End Property

Property Let pixelRight(p As Integer)
pixRight = p
UserControl_Resize
End Property

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
RaiseEvent keyDown(KeyCode, Shift)
End Sub

Property Get Height() As Single
Height = UserControl.Extender.Height
End Property

Property Get Top() As Single
Top = UserControl.Extender.Top
End Property

Property Let Top(t As Single)
UserControl.Extender.Top = t
End Property

Property Get Left() As Single
Left = UserControl.Extender.Left
End Property

Property Let Left(t As Single)
UserControl.Extender.Left = t
End Property

Property Get width() As Single
width = UserControl.Extender.width
End Property

Property Let width(t As Single)
UserControl.Extender.width = t
End Property

Property Get visible() As Boolean
visible = UserControl.Extender.visible
End Property

Property Let visible(t As Boolean)
UserControl.Extender.visible = t
End Property