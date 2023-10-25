VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Begin VB.Form frmRegister 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Регистрация записи"
   ClientHeight    =   3825
   ClientLeft      =   2100
   ClientTop       =   1890
   ClientWidth     =   5820
   Icon            =   "Register.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3825
   ScaleWidth      =   5820
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox txtDiam 
      Height          =   285
      Left            =   4920
      TabIndex        =   8
      Top             =   240
      Width           =   855
   End
   Begin VB.CommandButton btmMdb 
      Caption         =   "Выбор..."
      Height          =   375
      Left            =   4920
      TabIndex        =   7
      Top             =   2280
      Width           =   855
   End
   Begin VB.TextBox txtMdb 
      Height          =   285
      Left            =   120
      TabIndex        =   6
      Top             =   2400
      Width           =   4695
   End
   Begin ComctlLib.ProgressBar progBar 
      Height          =   255
      Left            =   120
      TabIndex        =   18
      Top             =   3000
      Visible         =   0   'False
      Width           =   5655
      _ExtentX        =   9975
      _ExtentY        =   450
      _Version        =   327682
      Appearance      =   1
   End
   Begin VB.CommandButton btmAction 
      Caption         =   "Отказ"
      Height          =   375
      Index           =   1
      Left            =   3120
      TabIndex        =   11
      Top             =   3360
      Width           =   1215
   End
   Begin VB.CommandButton btmAction 
      Caption         =   "Регистрация"
      Enabled         =   0   'False
      Height          =   375
      Index           =   0
      Left            =   1440
      TabIndex        =   10
      Top             =   3360
      Width           =   1215
   End
   Begin VB.CheckBox optOpen 
      Caption         =   "Открыть запись"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   2760
      Value           =   1  'Checked
      Width           =   1695
   End
   Begin VB.CommandButton btmTrc 
      Caption         =   "Выбор..."
      Height          =   375
      Left            =   4920
      TabIndex        =   5
      Top             =   1680
      Width           =   855
   End
   Begin VB.TextBox txtTrc 
      Height          =   285
      Left            =   120
      TabIndex        =   4
      Top             =   1800
      Width           =   4695
   End
   Begin VB.CommandButton btmBrowse 
      Caption         =   "Выбор..."
      Height          =   375
      Left            =   4920
      TabIndex        =   3
      Top             =   1080
      Width           =   855
   End
   Begin VB.TextBox txtPrimary 
      Height          =   285
      Left            =   120
      TabIndex        =   2
      Top             =   1200
      Width           =   4695
   End
   Begin VB.ComboBox lstDriver 
      Height          =   315
      ItemData        =   "Register.frx":0442
      Left            =   1200
      List            =   "Register.frx":0444
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   600
      Width           =   3615
   End
   Begin VB.TextBox txtName 
      Height          =   285
      Left            =   120
      TabIndex        =   0
      Text            =   "Новая запись"
      Top             =   240
      Width           =   4695
   End
   Begin VB.Label labInfo 
      Caption         =   "Label2"
      Height          =   255
      Left            =   1920
      TabIndex        =   20
      Top             =   2760
      Width           =   3855
   End
   Begin VB.Label Label1 
      Caption         =   "Файл базы данных обьектов"
      Height          =   255
      Index           =   5
      Left            =   120
      TabIndex        =   19
      Top             =   2160
      Width           =   3495
   End
   Begin VB.Label labExt 
      Caption         =   "*.krt,*.vog"
      Height          =   255
      Left            =   4920
      TabIndex        =   17
      Top             =   600
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Имя trc-файла"
      Height          =   255
      Index           =   4
      Left            =   120
      TabIndex        =   16
      Top             =   1560
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "Первичная запись"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   15
      Top             =   960
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "Диаметр"
      Height          =   255
      Index           =   2
      Left            =   4920
      TabIndex        =   14
      Top             =   0
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Драйвер"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   13
      Top             =   600
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Наименование записи"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   12
      Top             =   0
      Width           =   1815
   End
End
Attribute VB_Name = "frmRegister"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private act As String
Private dlg As New clsCommonDialog

Private breakFlag As Boolean
Private regInProgress As Boolean
Private hlp As New clsHelp

Public Function informUser(ByVal prcnt As Integer, ByVal msg As String) As Long
Me.progBar.Value = prcnt
labInfo.Caption = prcnt & "% " & msg
ogdPause 50
informUser = IIf(breakFlag, 1, 0)
End Function

Public Function View() As String
Dim c As clsDriver

setWait "Загрузка списка драйверов..."

cfg.initMagnets
cfg.initDrivers

hlp.BindHelp Me, KRT_Reg

lstDriver.Clear
For Each c In cfg.Drivers
 lstDriver.addItem c.descripion
 lstDriver.ItemData(lstDriver.ListCount - 1) = c.idNum
Next

If lstDriver.ListCount > 0 Then
  lstDriver.ListIndex = 0
  btmAction(0).enabled = True
End If

centerForm frmMain, Me
labInfo.Caption = ""
regInProgress = False

act = ""
setReady
Me.Show 1, frmMain
View = act
End Function

Private Function saveTrc() As Boolean
Dim trc As New clsTrace, errParam As String

saveTrc = False
errParam = ""

cFile.fullName = txtTrc.Text
If cFile.isPathContainLeadingSpace Then
 errParam = "trc файлу"
End If

cFile.fullName = txtMdb.Text
If cFile.isPathContainLeadingSpace Then
 errParam = "mdb файлу базы данных"
End If

cFile.fullName = txtPrimary.Text
If cFile.isPathContainLeadingSpace Then
 errParam = "файлам первичных данных"
End If

If Len(errParam) > 0 Then
 ogdWin.Alert _
  "Путь к " & errParam & " содержит имя каталога, " & vbNewLine & _
  "начинающиеся с символа пробела. " & vbNewLine & _
  "Такое имя каталога недопустимо при работе с программой." & vbNewLine & _
  "Переименуйте каталог и повторите попытку регистрации."
 Exit Function
End If

If trc.Register( _
       txtTrc.Text, _
       txtName.Text, _
       txtMdb.Text, _
       txtDiam.Text, _
       cfg.Drivers.ItemNum(lstDriver.ItemData(lstDriver.ListIndex)) _
) = False Then
 ogdWin.Alert trc.errText
 Exit Function
End If

breakFlag = False
setCtrlMode False
progBar.Value = 0

If krotRegisterTrace(trc.drv.dll, txtPrimary.Text, "", trc.FileName, AddressOf registerCallBack) = KRT_ERR Then
 ogdWin.Alert "Ошибка при регистрации записи:" & vbNewLine & lastError()
 setCtrlMode True
 Exit Function
End If

setWait "Загрузка '" & trc.FileName & "' ...", vbHourglass, True
If trc.traceOpen(trc.FileName) = False Then
 setReady
 ogdWin.Alert trc.errText
End If

Dim sl As clsSensorLine
If trc.ornt.num > 0 Then
 Set sl = trc.ornt.line(0)
 sl.visible = True
 trc.ornt.Save
End If

trc.traceClose
setReady

breakFlag = False
setCtrlMode True
saveTrc = True
End Function

Private Sub setCtrlMode(ByVal md As Boolean)
txtName.enabled = md
txtDiam.enabled = md
lstDriver.enabled = md
txtPrimary.enabled = md
btmBrowse.enabled = md
txtTrc.enabled = md
btmTrc.enabled = md
txtMdb.enabled = md
btmMdb.enabled = md
btmAction(0).enabled = md
regInProgress = Not (md)
progBar.visible = Not (md)
labInfo.Caption = ""
End Sub

Private Sub btmAction_Click(Index As Integer)
Select Case Index

 Case 0 'регистрация
  If saveTrc() Then
   If optOpen.Value = 1 Then
    act = txtTrc.Text
    Unload Me
    Else
    If ogdWin.AskAction("Открыть зарегистрированный прогон?") Then
     act = txtTrc.Text
     Unload Me
     Else
     Unload Me
    End If
   End If
  End If

 Case 1 'отказ
  If regInProgress Then
   breakFlag = True
   Else
   Unload Me
  End If

End Select

End Sub

Private Sub btmBrowse_Click()
Dim s As String, i As Integer

cfg.parser.Delim = ";"
s = cfg.Drivers.ItemNum(lstDriver.ItemData(lstDriver.ListIndex)).fileExt
cfg.parser.TestString = cfg.parser.Delim & s
cfg.parser.Parse

s = ""
For i = 1 To cfg.parser.count
 If Len(cfg.parser.Item(i)) > 0 Then
  If Len(s) > 0 Then s = s & "|"
  s = s & "*." & cfg.parser.Item(i) & "|*." & cfg.parser.Item(i)
 End If
Next

s = ogdWin.fileOpen( _
 "Выберите первичный файл прогона", _
 txtPrimary.Text, _
 cfg.dir.Prim, _
 s, _
 Me.hWnd, _
 txtPrimary)

If Len(s) > 0 Then
 cFile.fullName = s
 s = cFile.basePath & cFile.lastFolder
 txtMdb.Text = s & ".mdb"
 txtTrc.Text = s & ".trc"
End If

End Sub

Private Sub btmMdb_Click()
Dim s As String

s = ogdWin.fileSave( _
 "Задайте имя создаваемого mdb-файла", _
 txtMdb.Text, _
 cfg.dir.trc, _
 "Файлы базы данных (*.mdb)|*.mdb", _
 Me.hWnd _
 )

If Len(s) = 0 Then Exit Sub
If Not (LCase(Right(s, 4)) = ".mdb") Then s = s & ".mdb"
txtMdb.Text = s
End Sub

Private Sub btmTrc_Click()
Dim s As String

s = ogdWin.fileSave( _
 "Задайте имя создаваемого trc-файла", _
 txtTrc.Text, _
 cfg.dir.trc, _
 "Файлы прогонов (*.trc)|*.trc", _
 Me.hWnd _
 )

If Len(s) = 0 Then Exit Sub
If Not (LCase(Right(s, 4)) = ".trc") Then s = s & ".trc"
txtTrc.Text = s
End Sub

Private Sub lstDriver_Click()
Dim i As Integer, s As String, c As clsDriver

Set c = cfg.Drivers.ItemNum(lstDriver.ItemData(lstDriver.ListIndex))
cfg.parser.Delim = ";"
cfg.parser.TestString = cfg.parser.Delim & c.fileExt
cfg.parser.Parse
s = ""
For i = 1 To cfg.parser.count
 If Len(cfg.parser.Item(i)) > 0 Then s = s & "*." & cfg.parser.Item(i) & " "
Next
labExt.caption = s
txtDiam.Text = c.diamDflt
End Sub