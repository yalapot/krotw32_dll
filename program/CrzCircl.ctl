VERSION 5.00
Begin VB.UserControl ctrlCrzCircle 
   ClientHeight    =   3060
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   2715
   ScaleHeight     =   3060
   ScaleWidth      =   2715
   Begin VB.CheckBox diskret 
      Caption         =   "Дскр"
      Height          =   255
      Left            =   1800
      TabIndex        =   11
      ToolTipText     =   "Отрисовка дискретных полок показаний"
      Top             =   480
      Width           =   735
   End
   Begin VB.CommandButton btmRight 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   2280
      Picture         =   "CrzCircl.ctx":0000
      Style           =   1  'Graphical
      TabIndex        =   9
      TabStop         =   0   'False
      ToolTipText     =   "Прокрутка вперед"
      Top             =   840
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.CommandButton btmLeft 
      Appearance      =   0  'Flat
      Height          =   255
      Left            =   2040
      Picture         =   "CrzCircl.ctx":0102
      Style           =   1  'Graphical
      TabIndex        =   8
      TabStop         =   0   'False
      ToolTipText     =   "Прокрутка назад"
      Top             =   840
      UseMaskColor    =   -1  'True
      Width           =   255
   End
   Begin VB.CheckBox markWhite 
      Caption         =   "999999"
      Height          =   255
      Left            =   1800
      TabIndex        =   7
      ToolTipText     =   "Значение на курсоре по белому маркеру"
      Top             =   1080
      Width           =   855
   End
   Begin VB.CheckBox markBlack 
      Caption         =   "999999"
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   1800
      TabIndex        =   6
      ToolTipText     =   "Значение на курсоре по черному маркеру"
      Top             =   1560
      Width           =   855
   End
   Begin VB.CheckBox autoInterval 
      Caption         =   "Авто"
      Height          =   255
      Left            =   1800
      TabIndex        =   4
      ToolTipText     =   "Автоматически менять интервал показаний в зависимости от текущих значений графика"
      Top             =   240
      Width           =   735
   End
   Begin VB.PictureBox pic 
      Height          =   1455
      Left            =   0
      ScaleHeight     =   93
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   109
      TabIndex        =   0
      Top             =   480
      Width           =   1695
   End
   Begin VB.Label markCurs 
      Caption         =   "500000.00"
      Height          =   255
      Left            =   1800
      TabIndex        =   10
      ToolTipText     =   "значение по курсору"
      Top             =   1800
      Width           =   855
   End
   Begin VB.Label labMax 
      Alignment       =   1  'Right Justify
      Caption         =   "65500"
      Height          =   255
      Left            =   1200
      TabIndex        =   2
      ToolTipText     =   "Нижняя граница диапазона"
      Top             =   240
      Width           =   495
   End
   Begin VB.Label markDiff 
      Caption         =   "500000.00"
      Height          =   255
      Left            =   1800
      TabIndex        =   5
      ToolTipText     =   "разница по маркерам на курсоре"
      Top             =   1320
      Width           =   855
   End
   Begin VB.Label labDiff 
      Alignment       =   2  'Center
      Caption         =   "65500"
      Height          =   255
      Left            =   600
      TabIndex        =   3
      ToolTipText     =   "Размер диапазона"
      Top             =   240
      Width           =   495
   End
   Begin VB.Label labMin 
      Caption         =   "65500"
      Height          =   255
      Left            =   0
      TabIndex        =   1
      ToolTipText     =   "Верхняя граница диапазона"
      Top             =   240
      Width           =   495
   End
   Begin VB.Menu menuGraph 
      Caption         =   "Меню"
      Begin VB.Menu mnuGraph 
         Caption         =   "Интервал значений"
         Index           =   0
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "В буфер"
         Index           =   1
      End
      Begin VB.Menu mnuGraph 
         Caption         =   "Закрыть"
         Index           =   2
      End
   End
End
Attribute VB_Name = "ctrlCrzCircle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private crc As clsSensCircle
Private crzCtrl As ctrlCoroz

Private curs As New clsCursor
Private batchFlag As Boolean

Public Event keyDown(ByVal KeyCode As Integer, ByVal Shift As Integer)
Public Event mouseMove(ByVal y As Integer, ByVal x As Long)
Public Event off()
Public Event shiftMark(ByVal onLeft As Boolean, ByVal wMark As Boolean, ByVal bMark As Boolean)

Private Sub diskret_Click()
crc.diskret = IIf(diskret.Value = 0, False, True)
If batchFlag Then Exit Sub
Me.Draw
End Sub

Private Sub autoInterval_Click()
crc.autoBorders = IIf(autoInterval.Value = 0, False, True)
If batchFlag Then Exit Sub
Me.Draw
End Sub

Private Sub btmLeft_Click()
RaiseEvent shiftMark(True, crc.mwEnable, crc.mbEnable)
End Sub

Private Sub btmRight_Click()
RaiseEvent shiftMark(False, crc.mwEnable, crc.mbEnable)
End Sub

Public Sub setMarkersOnOff(ByVal white As Boolean, ByVal black As Boolean)
batchFlag = True
markBlack.Value = IIf(black, 1, 0)
markWhite.Value = IIf(white, 1, 0)
autoInterval.Value = 1
batchFlag = False
Me.Draw
End Sub

Private Sub markBlack_Click()
crc.mbEnable = IIf(markBlack.Value = 1, True, False)
If batchFlag Then Exit Sub
Me.Draw
End Sub

Private Sub markWhite_Click()
crc.mwEnable = IIf(markWhite.Value = 1, True, False)
If batchFlag Then Exit Sub
Me.Draw
End Sub

Private Sub mnuGraph_Click(Index As Integer)
Dim v1 As Long, v2 As Long
Dim maximumValue As Long, minimumValue As Long

Select Case Index

 Case 0 'интервал значений
  v1 = crc.brdMin
  v2 = crc.brdMax
  If frmInterval.IntervalCommon(frmMain, crc.valMin, crc.valMax, v1, v2) Then
   If (v2 - v1) = 0 Then
    ogdWin.Alert "Задан нулевой интервал значений"
    Exit Sub
   End If
   crc.setMinMax v1, v2
   Me.Draw
  End If

 Case 1 'скопировать в буфер обмена
  If krotSetClipboard(pic.hWnd) = KRT_ERR Then
   ogdWin.Alert "Error ctrlCrzCircle.mnuGraph_Click(1)" & vbNewLine & lastError()
  End If

 Case 2 'закрыть
  RaiseEvent off

End Select
End Sub

Public Sub setCursorPos(ByVal x As Single, ByVal indx As Integer)
Dim y As Single

If crc Is Nothing Then Exit Sub

y = (((indx - crc.corozZone.topSens) Mod crc.corozZone.num) + pic.ScaleHeight) Mod pic.ScaleHeight

markWhite.Caption = crc.markW(indx)
markBlack.Caption = crc.markB(indx)
markDiff.Caption = crc.markB(indx) - crc.markW(indx)
markCurs.Caption = x
curs.Draw x, y
End Sub

Private Sub pic_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim indx As Integer

indx = (Fix(y) + crc.corozZone.topSens) Mod crc.corozZone.num
setCursorPos x, indx
RaiseEvent mouseMove(y, 0)
End Sub

Private Sub pic_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
Select Case Button
 Case 2
 UserControl.popUpMenu menuGraph
 Exit Sub
End Select
End Sub

Private Sub Pic_Paint()
Me.Draw
End Sub

Private Sub UserControl_Initialize()
markWhite.BackColor = color.markWhite
markWhite.ForeColor = color.markWhiteText
markBlack.BackColor = color.markBlack
markBlack.ForeColor = color.markBlackText
batchFlag = False
End Sub

Private Sub UserControl_Resize()
Static intFlag As Boolean

'design time support
If crc Is Nothing Then Exit Sub

If intFlag Then Exit Sub
intFlag = True
pic.Height = crzCtrl.pic.Height * Screen.twipsPerPixelY
UserControl.width = markDiff.Left + markDiff.width 'Pic.width + Screen.twipsPerPixelX * 8
UserControl.Height = pic.Top + pic.Height

intFlag = False
End Sub

Public Sub Resize()
UserControl_Resize
End Sub

Public Function Init(circl As clsSensCircle, corozControl As ctrlCoroz) As Boolean

Set crc = circl
Set crzCtrl = corozControl

autoInterval.Value = IIf(crc.autoBorders, 1, 0)
markWhite.Value = IIf(crc.mwEnable, 1, 0)
markBlack.Value = IIf(crc.mbEnable, 1, 0)

curs.Init pic, USR_BIGCROSS
curs.cursType = CURS_USER_NORMAL

markWhite.Caption = 0
markDiff.Caption = 0
markBlack.Caption = 0

UserControl_Resize
End Function

Private Sub UserControl_KeyDown(keyCode As Integer, Shift As Integer)
RaiseEvent keyDown(keyCode, Shift)
End Sub

Public Sub Draw()
If UserControl.Extender.Visible = False Then Exit Sub
crc.Draw pic 'должно быть первым
labMax.Caption = crc.brdMax
labMin.Caption = crc.brdMin
labDiff.Caption = crc.brdMax - crc.brdMin
curs.needErase = False
End Sub