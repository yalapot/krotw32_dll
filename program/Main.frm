VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Begin VB.MDIForm frmMain 
   AutoShowChildren=   0   'False
   BackColor       =   &H8000000C&
   Caption         =   "Krot for Win32"
   ClientHeight    =   3720
   ClientLeft      =   225
   ClientTop       =   855
   ClientWidth     =   7410
   Icon            =   "Main.frx":0000
   LinkTopic       =   "MDIForm1"
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer Timer1 
      Left            =   0
      Top             =   0
   End
   Begin ComctlLib.StatusBar sbar 
      Align           =   2  'Align Bottom
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   3465
      Width           =   7410
      _ExtentX        =   13070
      _ExtentY        =   450
      SimpleText      =   ""
      _Version        =   327682
      BeginProperty Panels {0713E89E-850A-101B-AFC0-4210102A8DA7} 
         NumPanels       =   1
         BeginProperty Panel1 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            AutoSize        =   2
            Text            =   "Готов"
            TextSave        =   "Готов"
            Key             =   ""
            Object.Tag             =   ""
            Object.ToolTipText     =   "Выполняемая операция"
         EndProperty
      EndProperty
   End
   Begin VB.Menu menuFile 
      Caption         =   "&Файлы"
      Begin VB.Menu mnuFile 
         Caption         =   "Регистрация"
         Index           =   0
         Shortcut        =   ^R
      End
      Begin VB.Menu mnuFile 
         Caption         =   "Открыть запись"
         Index           =   1
         Shortcut        =   ^O
      End
      Begin VB.Menu mnuFile 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu mnuFile 
         Caption         =   "Настройки программы"
         Index           =   3
      End
      Begin VB.Menu mnuFile 
         Caption         =   "Сохранить настройки"
         Index           =   4
      End
      Begin VB.Menu mnuFile 
         Caption         =   "Редактор палитр"
         Index           =   5
      End
      Begin VB.Menu mnuFile 
         Caption         =   "История"
         Index           =   6
         Begin VB.Menu mnuHistory 
            Caption         =   "пусто"
            Enabled         =   0   'False
            Index           =   0
         End
      End
      Begin VB.Menu mnuFile 
         Caption         =   "Выход"
         Index           =   7
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu menuHelp 
      Caption         =   "Помощь"
      Begin VB.Menu mnuHelp 
         Caption         =   "Содержание"
         Index           =   0
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "ГПАС on Web"
         Index           =   1
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "О программе"
         Index           =   3
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private sinhroFlag As Boolean
Private mWindow As String
Private krotCmdLine As New clsKrtCmdLine

Public krotZoomMessage As String

Property Get Sinhro() As Boolean
Sinhro = sinhroFlag
End Property

Public Sub switchSinh()
Dim frm As Form

sinhroFlag = Not (sinhroFlag)
For Each frm In Forms
 If frm.name = "frmTrace" Then frm.switchSinh sinhroFlag
Next
End Sub

Public Sub jumpTo(ByVal dst As Long)
Dim f As Form, ft As frmTrace

If Not sinhroFlag Then Exit Sub

For Each f In Forms
  If f.name = "frmTrace" Then
    Set ft = f
    ft.jumpTo dst
  End If
Next
End Sub

Public Sub goDist(ByVal dst As Long, sourceFormHWNND As Long)
Dim f As Form, ft As frmTrace

If Not sinhroFlag Then Exit Sub
If Not cfg.syncJump Then Exit Sub

For Each f In Forms
  If f.name = "frmTrace" Then
    Set ft = f
    If ft.hwnd <> sourceFormHWNND Then
      ft.goDist ft.trc.getDistReal(dst)
    End If
  End If
Next
End Sub

Public Sub scroll(ByVal isOn As Boolean, ftag As String)
Dim frm As Form
For Each frm In Forms
 If frm.name = "frmTrace" Then
  If frm.Tag <> ftag Then frm.slaveScroll isOn
 End If
Next
sbar.Panels(1).Text = IIf(isOn, "Скроллинг...", "Готов")
End Sub

Public Sub shiftPos(ByVal dlt As Long, ftag As String)
Dim frm As Form
For Each frm In Forms
 If frm.name = "frmTrace" Then
  If frm.Tag <> ftag Then frm.shiftPos dlt
 End If
Next
End Sub

Private Sub procExtZoom(opt As String)
Dim optImp As String, optOut As String, itm As Variant

On Error GoTo errHandle
itm = Split(opt, krotMessageZoomDelimeter)
optImp = itm(0)
optOut = itm(1)
On Error GoTo 0

krotMessage optImp & krotMessageZoomDelimeter & optOut
Exit Sub

errHandle:
ogdWin.Alert "Ошибка при обработке параметра -z " & opt
On Error GoTo 0
End Sub

Private Sub MDIForm_Load()
Dim cfgFile As String, arg As String, s As String
Dim i As Integer

init_feat_class

arg = Command$
'Log "D:\data\krt.log", "start krot: " & arg
If Len(arg) > 2 Then
  s = Mid(arg, 1, 2)
  If s = "-z" Then
    s = Mid(arg, 3)
    procExtZoom s
    Unload Me
    Exit Sub
  End If
End If

Me.Icon = LoadResPicture(1004, vbResIcon) 'vbResBitmap
mnuHelp(1).Caption = LoadResString(200)
mnuFile(0).enabled = Not appVersionViewer

onLineTraceHwnd = -1
onLineData.d_start = -1
onLineData.d_length = -1

With krotCmdLine
If .Init(Command()) = False Then ogdWin.Alert .errText
If .config = "" Then
 cfgFile = App.path & "\" & IIf(appVersionRestricted, "krotw32r.ini", "krotw32.ini")
 Else
 cfgFile = .config
End If
End With

If cfg.Init(cfgFile) = False Then
 ogdWin.Alert cfg.errText
 End
End If

If checkVmode() = KRT_ERR Then
 ogdWin.Alert lastError()
 End
End If

cfg.fileHist.restoreForm Me, True
For i = 1 To krotCmdLine.traceNum
 openTrace krotCmdLine.traceFile(i)
Next i
updateHistory
mainFormHook
End Sub

Private Sub MDIForm_QueryUnload(Cancel As Integer, UnloadMode As Integer)
Dim needSave As Boolean, i As Integer

needSave = False
Select Case cfg.exitMode
 Case EM_ASK_USER
  i = ogdWin.AskYNC("Сохранить текущие настройки главного окна?")
  Select Case i
   Case vbYes
    needSave = True
   Case vbCancel
    Cancel = True
    Exit Sub
  End Select
 Case EM_AUTO_SAVE
  needSave = True
End Select
If needSave Then cfg.Save Me
mainFormUnHook
End Sub

Private Sub mnuFile_Click(Index As Integer)
Dim s As String

Select Case Index
 Case 0 'регистрация
  registerTrace
 Case 1 'открыть
  s = ogdWin.fileOpen( _
   "Выберите файл описания прогона", _
   "", cfg.dir.trc, _
   "Файлы прогонов (*.trc)|*.trc", Me.hwnd _
   )
  If s = "" Then Exit Sub
  openTrace s
  updateHistory

 Case 3 'настройки программы
  frmPrgSetting.Edit

 Case 4
  cfg.Save Me
  ogdWin.Info "Пользовательские настройки главного окна успешно сохранены."

 Case 5 'редактор палитр
  frmPalette.Edit frmMain, ""

 Case 7 'выход
  Unload Me
End Select
End Sub

Private Sub mnuHelp_Click(Index As Integer)
Select Case Index

 Case 0 'содержание
  ShowHelp KRT_INTRO
  
 Case 1 'гпас
  StartURL LoadResString(201)
  
 Case 3 'о программе
  frmAbout.showInfo Me
 
End Select
End Sub

Private Sub mnuHistory_Click(Index As Integer)
openTrace mnuHistory(Index).Caption
updateHistory
End Sub

Private Sub Timer1_Timer()
Dim frm As Form, frmt As frmTrace, itm As Variant, optInp As String, optOut As String

Timer1.Interval = 0

itm = Split(Me.krotZoomMessage, krotMessageZoomDelimeter)
optInp = itm(0)
optOut = itm(1)

For Each frm In Forms
 If frm.name = "frmTrace" Then
   Set frmt = frm
   If frmt.trc.extZoomData = optInp Then
     frmt.fZoom.showAnalyzeResult optOut
     Kill optInp
     Kill optOut
     frmt.trc.extZoomData = ""
     Me.krotZoomMessage = ""
     Exit Sub
   End If
 End If
Next
Me.krotZoomMessage = ""
End Sub
