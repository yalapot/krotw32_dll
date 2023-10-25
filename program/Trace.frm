VERSION 5.00
Begin VB.Form frmTrace 
   Caption         =   "Form1"
   ClientHeight    =   6030
   ClientLeft      =   -150
   ClientTop       =   405
   ClientWidth     =   7935
   Icon            =   "Trace.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   6030
   ScaleWidth      =   7935
   Begin krotw32.ctrlCrzZones Coroz 
      Height          =   1935
      Left            =   0
      TabIndex        =   13
      Top             =   840
      Width           =   4575
      _ExtentX        =   8070
      _ExtentY        =   3413
   End
   Begin krotw32.ctrlGrfSpec ctrlSpeed 
      Height          =   735
      Left            =   4680
      TabIndex        =   11
      Top             =   3240
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.traceObjects Objects 
      Height          =   495
      Left            =   4680
      TabIndex        =   10
      Top             =   5040
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   873
   End
   Begin krotw32.ctrlGrfSimple ctrlExt 
      Height          =   975
      Left            =   4680
      TabIndex        =   9
      Top             =   3960
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   1720
   End
   Begin krotw32.ctrlGrfDigit ctrlTime 
      Height          =   495
      Left            =   6360
      TabIndex        =   8
      Top             =   3240
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   873
   End
   Begin krotw32.ctrlGrfDigit ctrlOdo 
      Height          =   495
      Left            =   5520
      TabIndex        =   7
      Top             =   3240
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   873
   End
   Begin krotw32.ctrlGrfSpec ctrlTemp 
      Height          =   735
      Left            =   5520
      TabIndex        =   6
      Top             =   2400
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.ctrlGrfSpec ctrlShake 
      Height          =   735
      Left            =   4680
      TabIndex        =   5
      Top             =   2400
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.ctrlGrfSpec ctrlAngle 
      Height          =   735
      Left            =   5520
      TabIndex        =   4
      Top             =   1560
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.ctrlGrfSpec ctrlPress 
      Height          =   735
      Left            =   4680
      TabIndex        =   3
      Top             =   1560
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.ctrlVOG vog 
      Height          =   3090
      Left            =   0
      TabIndex        =   2
      Top             =   3000
      Width           =   4575
      _ExtentX        =   9763
      _ExtentY        =   5450
   End
   Begin krotw32.ctrlOrient orient 
      Height          =   1455
      Left            =   5520
      TabIndex        =   1
      Top             =   0
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   2566
   End
   Begin krotw32.trcCtrl trcCtrl 
      Height          =   750
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   5655
      _ExtentX        =   15081
      _ExtentY        =   1323
   End
   Begin krotw32.ctrlGrfSpec ctrlThick 
      Height          =   735
      Left            =   6360
      TabIndex        =   12
      Top             =   1560
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.ctrlGrfSpec ctrlCurve 
      Height          =   735
      Left            =   6360
      TabIndex        =   14
      Top             =   2400
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.ctrlGrfSpec ctrlAzimuth 
      Height          =   735
      Left            =   7080
      TabIndex        =   15
      Top             =   1680
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin krotw32.ctrlGrfSpec ctrlTangazh 
      Height          =   735
      Left            =   7080
      TabIndex        =   16
      Top             =   2400
      Visible         =   0   'False
      Width           =   735
      _ExtentX        =   1296
      _ExtentY        =   1296
   End
   Begin VB.Menu menuFile 
      Caption         =   "&Файлы"
      WindowList      =   -1  'True
      Begin VB.Menu mnuTrace 
         Caption         =   "Регистрация"
         Index           =   0
         Shortcut        =   ^R
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Открыть запись"
         Index           =   1
         Shortcut        =   ^O
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Закрыть запись"
         Index           =   2
         Shortcut        =   ^E
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Синхронная прокрутка"
         Index           =   3
         Shortcut        =   {F11}
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "-"
         Index           =   4
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Настройки программы"
         Index           =   5
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Сохранить настройки"
         Index           =   6
         Shortcut        =   ^S
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Редактор палитр"
         Index           =   7
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "История"
         Index           =   8
         Begin VB.Menu mnuHistory 
            Caption         =   "пусто"
            Enabled         =   0   'False
            Index           =   0
         End
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Таймерные маркеры"
         Index           =   9
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Автоматический анализ"
         Index           =   10
         Shortcut        =   ^A
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Колеса одометра"
         Index           =   11
      End
      Begin VB.Menu mnuTrace 
         Caption         =   "Выход"
         Index           =   12
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu menuView 
      Caption         =   "&Вид"
      Begin VB.Menu mnuView 
         Caption         =   "Настройки записи..."
         Index           =   0
         Shortcut        =   {F2}
      End
      Begin VB.Menu mnuView 
         Caption         =   "Полоса расшифровки"
         Index           =   1
         Shortcut        =   {F4}
      End
      Begin VB.Menu mnuView 
         Caption         =   "Вся трасса"
         Index           =   2
         Shortcut        =   ^{F3}
      End
      Begin VB.Menu mnuView 
         Caption         =   "Область просмотра"
         Index           =   3
         Shortcut        =   +{F3}
      End
      Begin VB.Menu mnuView 
         Caption         =   "Переход на отметку"
         Index           =   4
         Shortcut        =   {F3}
      End
      Begin VB.Menu mnuView 
         Caption         =   "Маркеры"
         Index           =   5
         Shortcut        =   {F5}
      End
      Begin VB.Menu mnuView 
         Caption         =   "Экспресс анализ..."
         Index           =   6
         Begin VB.Menu mnuExp 
            Caption         =   "Графики"
            Index           =   0
         End
         Begin VB.Menu mnuExp 
            Caption         =   "Развертка"
            Index           =   1
         End
      End
      Begin VB.Menu mnuView 
         Caption         =   "Размещение"
         Index           =   7
         Begin VB.Menu mnuArrange 
            Caption         =   "Каскадом"
            Index           =   0
         End
         Begin VB.Menu mnuArrange 
            Caption         =   "Вертикально"
            Index           =   1
         End
         Begin VB.Menu mnuArrange 
            Caption         =   "Горизонтально"
            Index           =   2
         End
      End
      Begin VB.Menu mnuView 
         Caption         =   "Переход в конец трассы"
         Index           =   8
      End
   End
   Begin VB.Menu menuVog 
      Caption         =   "VO&G"
      Begin VB.Menu mnuVog 
         Caption         =   "Параметры поворота"
         Index           =   0
      End
      Begin VB.Menu mnuVog 
         Caption         =   "Совмещение..."
         Index           =   1
      End
      Begin VB.Menu mnuVog 
         Caption         =   "Копировать в буффер"
         Index           =   2
      End
      Begin VB.Menu mnuVog 
         Caption         =   "Повернуть изображение"
         Index           =   3
      End
      Begin VB.Menu mnuVog 
         Caption         =   "Вставить поворот"
         Index           =   4
      End
      Begin VB.Menu mnuVog 
         Caption         =   "Экспорт Z"
         Index           =   5
      End
      Begin VB.Menu mnuVog 
         Caption         =   "Запомнить диапазон"
         Index           =   6
      End
      Begin VB.Menu mnuVog 
         Caption         =   "Восстановить диапазон"
         Index           =   7
      End
   End
   Begin VB.Menu menuObject 
      Caption         =   "&Объекты"
      Begin VB.Menu mnuObj 
         Caption         =   "Команды"
         Index           =   0
         Begin VB.Menu mnuObjCmd 
            Caption         =   "Экспорт"
            Index           =   0
            Begin VB.Menu mnuObjExp 
               Caption         =   "Швы"
               Index           =   0
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Линейные объекты"
               Index           =   1
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Дефекты"
               Index           =   2
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Пригрузы"
               Index           =   3
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "График скорости"
               Index           =   4
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Толщина"
               Index           =   5
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Намагниченность"
               Index           =   6
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Категории"
               Index           =   7
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Повороты"
               Index           =   8
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "-"
               Index           =   9
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Таблица поправок"
               Index           =   10
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "VOG с учетом таблицы поправок"
               Index           =   11
            End
            Begin VB.Menu mnuObjExp 
               Caption         =   "Расширенный экспорт швов"
               Index           =   12
            End
         End
         Begin VB.Menu mnuObjCmd 
            Caption         =   "Фильтр"
            Index           =   1
         End
         Begin VB.Menu mnuObjCmd 
            Caption         =   "Отобразить"
            Index           =   2
         End
         Begin VB.Menu mnuObjCmd 
            Caption         =   "Отображать постоянно"
            Index           =   3
         End
         Begin VB.Menu mnuObjCmd 
            Caption         =   "Таблица"
            Index           =   4
            Shortcut        =   ^T
         End
         Begin VB.Menu mnuObjCmd 
            Caption         =   "Импорт"
            Index           =   5
            Begin VB.Menu mnuObjImp 
               Caption         =   "Швы"
               Index           =   0
            End
            Begin VB.Menu mnuObjImp 
               Caption         =   "Линейные объекты"
               Index           =   1
            End
            Begin VB.Menu mnuObjImp 
               Caption         =   "Дефекты"
               Index           =   2
            End
            Begin VB.Menu mnuObjImp 
               Caption         =   "Пригрузы"
               Index           =   3
            End
            Begin VB.Menu mnuObjImp 
               Caption         =   "Толщина"
               Index           =   4
            End
            Begin VB.Menu mnuObjImp 
               Caption         =   "Повороты"
               Index           =   5
            End
            Begin VB.Menu mnuObjImp 
               Caption         =   "Категории"
               Index           =   6
            End
         End
      End
      Begin VB.Menu mnuObj 
         Caption         =   "-"
         Index           =   1
      End
      Begin VB.Menu mnuObj 
         Caption         =   "Обьект"
         Index           =   2
      End
   End
   Begin VB.Menu menuSingleObj 
      Caption         =   "Обьект"
      Visible         =   0   'False
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Изменить"
         Index           =   0
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Удалить"
         Index           =   1
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Найти в таблице"
         Index           =   2
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
Attribute VB_Name = "frmTrace"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Implements clsMouseWeel

Private Const LEFT_SHIFT = 500

Private Enum T_CHANGE_SOURCE
SRC_NONE
SRC_USER
SRC_COROZ
SRC_VOG
SRC_OBJ
SRC_PRESS
SRC_SHAKE
SRC_SPEED
SRC_TEMP
SRC_ANGLE
SRC_THICK
SRC_CURVE
SRC_AZIMUTH
SRC_TANGAZH
SRC_EXT
End Enum

'константы учитывающие неклиентскую часть формы при ресайзе
'нужно переделать в переменные, заполняемые через API
Private Const FRM_HBORDER = 650 'высота
Private Const FRM_WBORDER = 250 'ширина

Private lastPixelRight As Integer ' нужно для контрола вспом.датчиков
Private vogHitArea As VOG_AREA
Private currentObjectDist As Long
Private objCommon As New clsObjCommon
Private objDefekt As New clsObjDefekt
Private objDefektZoom As New clsObjDefekt
Private objLine As New clsObjLine
Private objThick As New clsObjThick
Private objTurn As New clsobjTurn
Private objWeld As New clsObjWeld
Private d_prevWndProc As Long
Private frm As New clsFormProps

Private openWithoutZoomFlag As Boolean

Public trc As clsTrace
Public WithEvents db As clsDb
Attribute db.VB_VarHelpID = -1

Public WithEvents fTable As frmTable
Attribute fTable.VB_VarHelpID = -1
Public WithEvents fZoom As frmZoom
Attribute fZoom.VB_VarHelpID = -1
Public WithEvents fSpeed As frmSpeed
Attribute fSpeed.VB_VarHelpID = -1
Public WithEvents fDefekt As frmDefekt
Attribute fDefekt.VB_VarHelpID = -1
Public WithEvents fCrzTool As frmCrzTool
Attribute fCrzTool.VB_VarHelpID = -1
Public WithEvents fTubeProfil As frmTubeProfile
Attribute fTubeProfil.VB_VarHelpID = -1
Public WithEvents fObjFilter As frmObjFilter
Attribute fObjFilter.VB_VarHelpID = -1
Public fTimeMrk As frmTimeMark

Public objDlgTop As Single
Public objDlgLeft As Single

Private controlPosition As Single
Private d_skipHeight As Single

'флаг устанавливается, если прогон открыт
Private openFlag As Boolean
Private busyFlag As Boolean
Private stopEventFlag As Boolean
Private WithEvents objDefektRef As clsObjDefekt
Attribute objDefektRef.VB_VarHelpID = -1
Private WithEvents objDefektZoomRef As clsObjDefekt
Attribute objDefektZoomRef.VB_VarHelpID = -1
Private hlp As New clsHelp

Private popupMenuItem As Integer
Private popupMenuFlag As Boolean
Private isCommonControlsVisible As Boolean

Public Function View(trace As clsTrace) As Boolean
Dim mainControl As Boolean
Dim tubeCheckFlag As Boolean, badTube As Long, s As String

View = False

Set trc = trace
Set db = trc.db
frm.Init trc.secUser, "frmTrace"

objDlgTop = -1
objDlgLeft = -1
Load Me

Set fTubeProfil = New frmTubeProfile
Set fTable = New frmTable
Set fZoom = New frmZoom
Set fSpeed = New frmSpeed
Set fDefekt = New frmDefekt
Set fTimeMrk = New frmTimeMark
Set fCrzTool = New frmCrzTool
Set objDefektRef = objDefekt
Set objDefektZoomRef = objDefektZoom
Set fObjFilter = frmObjFilter

openFlag = False

' настройка контролов
mainControl = True
trcCtrl.Init trc

If trc.db.enable Then

 Objects.Init trc, LEFT_SHIFT

 Select Case cfg.obj.tubeCheck
  Case 0 ' не проверять
   tubeCheckFlag = False
  Case 1 ' спрашивать
   tubeCheckFlag = ogdWin.AskAction("Проверить целостность таблицы длин труб записи" & vbNewLine & trc.FileName & " ?")
  Case 2 ' проверять автоматом
   tubeCheckFlag = True
 End Select

 If tubeCheckFlag Then
  badTube = trc.db.TubLengthCheck
  Select Case badTube
   Case -1
    s = "В базе отсутствует таблица длин труб" & vbNewLine & _
    "Создать ?"
   Case Is > 0
    s = "В таблице обнаружено " & badTube & " труб неверной длины." & vbNewLine & _
    "Пересчитать таблицу длин труб ?"
  End Select
  If badTube <> 0 Then
   If ogdWin.AskAction(s) Then trc.db.TubLengthRecalc
  End If
 End If

 trc.db.Refresh

End If

If trc.Coroz.num > 0 Then
 Coroz.Init trc, Me, mainControl, LEFT_SHIFT
 mainControl = False
End If

If trc.ornt.num > 0 Then
 orient.Init trc, trcCtrl.Height, color
End If

If trc.vog.enable Then
 If vog.Init(trc, mainControl, LEFT_SHIFT) = False Then
   ogdWin.Alert "Ошибка при инициализации VOG"
  Exit Function
 End If
 mainControl = False
 
 Else
 
 mnuView(2).enabled = False
 mnuView(3).enabled = False
 
End If

initSpec ctrlAzimuth, trc.azimuth
initSpec ctrlTangazh, trc.tangazh
initSpec ctrlCurve, trc.curve
initSpec ctrlSpeed, trc.speed
initSpec ctrlPress, trc.press
initSpec ctrlAngle, trc.angle
initSpec ctrlThick, trc.thick
initSpec ctrlShake, trc.shake
initSpec ctrlTemp, trc.temp

initDigit ctrlOdo, trc.odo
initDigit ctrlTime, trc.Timer

If trc.numExt > 0 Then
 If ctrlExt.Init(LEFT_SHIFT, Me) = False Then
   ogdWin.Alert "Ошибка при инициализации вспомогательных датчиков"
  Exit Function
 End If
 ' не может быть присвоено при событии от coroz, так как еще не было инициализации
 ctrlExt.pixelRight = lastPixelRight
End If

If mainControl Then ogdWin.Alert "Ни одного ведущего контрола!"
'конец настройки контролов

openFlag = True
Me.Caption = trc.FileName
Me.Tag = trc.handle
mnuTrace(3).Checked = frmMain.Sinhro

mnuView(1).enabled = trc.db.enable
menuObject.visible = trc.db.enable
mnuView(1).Checked = trc.db.visible

mnuTrace(9).enabled = Not trc.db.isRO
mnuTrace(10).enabled = Not trc.db.isRO
mnuObjCmd(0).enabled = Not trc.db.isRO
mnuObjCmd(5).enabled = Not trc.db.isRO
mnuVog(4).enabled = Not trc.db.isRO
mnuSingleObj(0).enabled = Not trc.db.isRO
mnuSingleObj(1).enabled = Not trc.db.isRO

If trc.speed.num > 0 Then fSpeed.Init Me.trc

frm.restoreForm Me

fTable.Init Me
fTubeProfil.Init trc
fZoom.Init Me
fDefekt.Init Me
fTimeMrk.Init trc
fCrzTool.Init trc

'настройка спец.меню контролов
setMenuObjTypes
mnuObjCmd(4).Checked = fTable.formVisible
mnuObjCmd(3).Checked = trc.db.showForever

mnuTrace(9).visible = Not appVersionRestricted
mnuTrace(10).visible = Not appVersionRestricted

popupMenuFlag = False

sizeAndDrawControls
Me.Show

If trc.isOnLine Then onLineTraceHwnd = Me.hwnd
View = True
End Function

Private Sub initSpec(c As ctrlGrfSpec, s As clsSensorGraph)
If s.num > 0 Then
 If c.Init(Me, s, LEFT_SHIFT) = False Then ogdWin.Alert "Ошибка при инициализации:" & vbNewLine & s.name
End If
End Sub

Private Sub initDigit(c As ctrlGrfDigit, s As clsSensor)
If s.num > 0 Then
 If c.Init(trc, s) = False Then ogdWin.Alert "Ошибка при инициализации:" & vbNewLine & s.name
End If
End Sub

Private Sub switchMark()
trc.mark.isCurrWhite = Not (trc.mark.isCurrWhite)
trcCtrl.Draw
End Sub

Private Property Get clsMouseWeel_hwnd() As Long
clsMouseWeel_hwnd = Me.hwnd
End Property

Private Sub clsMouseWeel_MouseWeel(ByVal direction As Long)
Dim code As Integer, i As Integer

Select Case cfg.mouseWeelMode
  Case MW_HOR
    code = IIf(direction > 0, VK_LEFT, VK_RIGHT)
  Case MW_WIN
    code = IIf(direction > 0, VK_DN, VK_UP)
  Case Else
    Exit Sub
End Select

For i = 1 To Abs(direction)
  Form_KeyDown code, 0
Next
End Sub

Private Property Let clsMouseWeel_prevWndProc(ByVal RHS As Long)
d_prevWndProc = RHS
End Property

Private Property Get clsMouseWeel_prevWndProc() As Long
clsMouseWeel_prevWndProc = d_prevWndProc
End Property

Private Sub Coroz_changeMark()
switchMark
End Sub

Private Sub Coroz_objIns(ByVal x As Long)
If Not trc.db.isRO Then trc.db.objAddEx x, trc.mark.black
End Sub

Private Sub Coroz_keyDown(ByVal KeyCode As Integer, ByVal Shift As Integer)
Select Case KeyCode
 Case VK_LEFT, VK_RIGHT
 Form_KeyDown KeyCode, Shift
End Select
End Sub

Private Sub Coroz_circleOff(ByVal indx As Integer)
fCrzTool.circleOff indx
End Sub

Private Sub Coroz_mouseMove(ByVal y As Integer, ByVal x As Long, ByVal zoneNum As Long)
setMouse SRC_COROZ, x, y, zoneNum
End Sub

Private Sub Coroz_oneSensOff(ByVal indx As Integer)
fCrzTool.oneSensOff indx
End Sub

Private Sub Coroz_onTool(ByVal isOn As Boolean)
If isOn Then
 fCrzTool.Show 0, frmMain
 fCrzTool.ZOrder
 Else
 fCrzTool.visible = False
End If
End Sub

Private Sub Coroz_pixelRight(ByVal pix As Integer)
setPixelRight SRC_COROZ, pix
End Sub

Private Sub Coroz_redraw()
Objects.Draw
End Sub

Private Sub Coroz_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub Coroz_setMarkGroup(ByVal posWhite As Long, ByVal posBlack As Long)
setMarkGroup posWhite, posBlack
End Sub

'Private Sub Coroz_setMarkOsnap(ByVal mrkWhite As Boolean, ByVal newPos As Long)
'setMarkOsnap mrkWhite, newPos
'End Sub

Private Sub Coroz_sizeChange()
sizeAndDrawControls
End Sub

Private Sub Coroz_waitMessage(ByVal isWait As Boolean, ByVal msgText As String)
If isWait Then
 setWait msgText
 Else
 setReady
End If
End Sub

Private Sub Coroz_Zoom(crz As ctrlCoroz, ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Long, ByVal y2 As Long)
fZoom.showData crz, x1, x2, y1, y2
End Sub

Public Sub ZoomDefekt(dfkt As clsObjDefekt)
fZoom.showDefekt Coroz.zone(0), dfkt
End Sub

Private Sub ctrlAngle_changeMark()
switchMark
End Sub

Private Sub ctrlAngle_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_ANGLE, x, y
End Sub

Private Sub ctrlAngle_Off()
sizeAndDrawControls
End Sub

Private Sub ctrlAngle_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlAngle_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlAzimuth_addTurn()
addTurn
End Sub

Private Sub ctrlAzimuth_changeMark()
switchMark
End Sub

Private Sub ctrlAzimuth_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse T_CHANGE_SOURCE.SRC_AZIMUTH, x, y
End Sub

Private Sub ctrlAzimuth_off()
sizeAndDrawControls
End Sub

Private Sub ctrlAzimuth_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlAzimuth_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlCurve_addTurn()
addTurn
End Sub

Private Sub ctrlCurve_changeMark()
switchMark
End Sub

Private Sub ctrlCurve_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_CURVE, x, y
End Sub

Private Sub ctrlCurve_off()
sizeAndDrawControls
End Sub

Private Sub ctrlCurve_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlCurve_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlExt_changeMark()
switchMark
End Sub

Private Sub ctrlExt_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_EXT, x, y
End Sub

Private Sub ctrlExt_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlExt_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlPress_changeMark()
switchMark
End Sub

Private Sub ctrlPress_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_PRESS, x, y
End Sub

Private Sub ctrlPress_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlPress_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlShake_changeMark()
switchMark
End Sub

Private Sub ctrlShake_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_SHAKE, x, y
End Sub

Private Sub ctrlShake_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlShake_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlSpeed_changeMark()
switchMark
End Sub

Private Sub ctrlSpeed_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_SPEED, x, y
End Sub

Private Sub ctrlSpeed_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlSpeed_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlTangazh_addTurn()
addTurn
End Sub

Private Sub ctrlTangazh_changeMark()
switchMark
End Sub

Private Sub ctrlTangazh_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse T_CHANGE_SOURCE.SRC_TANGAZH, x, y
End Sub

Private Sub ctrlTangazh_off()
sizeAndDrawControls
End Sub

Private Sub ctrlTangazh_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlTangazh_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlTemp_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_TEMP, x, y
End Sub

Private Sub ctrlTemp_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlTemp_sizeChange()
sizeAndDrawControls
End Sub

Private Sub ctrlThick_changeMark()
switchMark
End Sub

Private Sub ctrlThick_mouseMove(ByVal y As Integer, ByVal x As Long)
setMouse SRC_THICK, x, y
End Sub

Private Sub ctrlThick_Off()
sizeAndDrawControls
End Sub

Private Sub ctrlPress_Off()
sizeAndDrawControls
End Sub

Private Sub ctrlShake_Off()
sizeAndDrawControls
End Sub

Private Sub ctrlSpeed_Off()
sizeAndDrawControls
End Sub

Private Sub ctrlTemp_Off()
sizeAndDrawControls
End Sub

Private Sub ctrlThick_setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
setMark mrkWhite, newPos
End Sub

Private Sub ctrlThick_sizeChange()
sizeAndDrawControls
End Sub

Private Sub db_eraseObjects()
If trc.vog.visible Then vog.Draw
End Sub

Private Sub db_sbMessage(ByVal ready As Boolean, msg As String)
If Not ready Then
 setWait msg
 Else
 setReady
End If
End Sub

Private Sub fCrzTool_changeSensRow(ByVal Index As Integer)
'Coroz.zone(Index).resetSens
Coroz.zone(Index).Draw True
End Sub

Private Sub fCrzTool_changeZone(ByVal Index As Integer)
Coroz.zone(Index).Draw True
End Sub

Private Sub fCrzTool_Off()
Coroz.isToolVisible = False
End Sub

Private Sub fCrzTool_redraw(ByVal Index As Integer)
Coroz.zone(Index).Draw
End Sub

Private Sub fCrzTool_sizeChange()
Coroz.changePicHeight
sizeAndDrawControls
End Sub

Private Sub fCrzTool_tubeProfil()
If trc.Coroz.tubeProfileVisible Then
 fTubeProfil.View
 Else
 fTubeProfil.HideForm
End If
End Sub

Private Sub fDefekt_snapShot()
Me.SetFocus
End Sub

Private Sub fObjFilter_UpdateObjList()
setMenuObjTypes
End Sub

Private Sub Form_DblClick()
If onLineData.d_start = -1 Then Exit Sub
onLineDataSub onLineData.d_start, onLineData.d_length
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
Dim oldPos As Long
Dim mdiclientwin As Long
Dim ret As Long, x1 As Long, x2 As Long, cmd As Long

oldPos = trc.pageStart
Select Case KeyCode

 Case VK_F4
  If Shift = 1 Then
    isCommonControlsVisible = Not isCommonControlsVisible
    sizeAndDrawControls
  End If
  
 Case VK_PGUP, VK_A
  trcCtrl_posChange trc.pageStart - trc.pageLength
 Case VK_PGDN
  trcCtrl_posChange trc.pageStart + trc.pageLength
 Case VK_LEFT
  trcCtrl_posChange trc.pageStart - trc.smallShift
 Case VK_RIGHT
  trcCtrl_posChange trc.pageStart + trc.smallShift
 Case VK_SPACE
  If trcCtrl.visible Then trcCtrl.switchScroll
 
 Case VK_NUM2
  If isControlDown() Then
    If trc.Coroz.num > 1 Then
      trc.Coroz.zone(1).visible = Not trc.Coroz.zone(1).visible
      fCrzTool_sizeChange
    End If
  End If
  
 Case VK_D
  If isControlDown() Then
    If trc.vog.enable Then
      trc.vog.visible = Not trc.vog.visible
      sizeAndDrawControls
    End If
  Else
    ' as VK_PGDN
    trcCtrl_posChange trc.pageStart + trc.pageLength
  End If
  
 Case VK_V
  If isControlDown() Then
    fCrzTool.Form_KeyDown KeyCode, Shift
  End If
  
 Case VK_M
  If isControlDown() Then
    fCrzTool.Form_KeyDown KeyCode, Shift
  End If
  
 Case VK_DN, VK_UP
  If KeyCode = VK_DN Then
    cmd = SB_LINEDOWN
  Else
    cmd = SB_LINEUP
  End If
  mdiclientwin = GetWindow(frmMain.hwnd, GW_CHILD)
  ret = GetScrollRange(mdiclientwin, SB_VERT, x1, x2)
  'Debug.Print "GetScrollRange " & ret & " min " & x1 & " max " & x2
  If ret > 0 And x2 > 0 Then
    SendMessage mdiclientwin, WM_VSCROLL, cmd, ByVal 0&
  End If

End Select
End Sub

Private Sub Form_Load()
stopEventFlag = False
busyFlag = False
isCommonControlsVisible = True
mouseWeelHook Me
hlp.BindHelp Me, KRT_ANALNAVIGATE
mnuHelp(1).Caption = LoadResString(200)
mnuTrace(0).enabled = Not appVersionViewer
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
Dim needSave As Boolean, i As Integer

If openFlag = False Then Exit Sub

needSave = False
Select Case cfg.exitMode
 Case EM_ASK_USER
  i = ogdWin.AskYNC("Сохранить текущие настройки записи" & vbNewLine & Me.Caption & " ?")
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

If needSave Then Me.Save

waitMessage True, "Закрытие " & trc.FileName & " ..."

Unload fTable
Unload fTubeProfil
Unload fZoom
Unload fSpeed
Unload fDefekt
Unload fTimeMrk
Unload fCrzTool

openFlag = False
trc.traceClose
waitMessage False
End Sub

Private Sub Form_Resize()
If Me.WindowState = vbMinimized Then Exit Sub
sizeAndDrawControls
End Sub

Private Sub drawCtlDgit(sens As clsSensor, ctl As ctrlGrfDigit)
If sens.visible Then
 With ctl
 .Top = controlPosition
 .Left = trcCtrl.Left
 .width = Me.width - FRM_WBORDER
 .Resize
 .visible = True
 controlPosition = .Top + .Height
 End With
End If
End Sub

Private Sub drawCtlSpec(sens As clsSensorGraph, ctl As ctrlGrfSpec)
If sens.visible Then
 With ctl
 .Top = controlPosition
 .Left = trcCtrl.Left
 .width = Me.width - FRM_WBORDER
 .visible = True
 controlPosition = .Top + .Height
 End With
End If
End Sub

Private Sub ClearData()
fSpeed.changeSettings
trc.curve.ClearData
End Sub

Public Sub sizeAndDrawControls()
Static intFlag As Boolean
Dim downPosition As Single
Dim frmWidth As Single, orntWidth As Single

If intFlag Then Exit Sub
intFlag = True

waitMessage True
orient.visible = False

vog.visible = False
menuVog.visible = False
mnuView(8).visible = False
trcCtrl.visible = False
Objects.visible = False
ctrlSpeed.visible = False
ctrlPress.visible = False
ctrlAngle.visible = False
ctrlThick.visible = False
ctrlCurve.visible = False
ctrlShake.visible = False
ctrlTemp.visible = False
ctrlOdo.visible = False
ctrlTime.visible = False
ctrlExt.visible = False
ctrlAzimuth.visible = False
ctrlTangazh.visible = False

Me.Caption = trc.Description
controlPosition = trcCtrl.Top

If trc.ornt.visible Then
 orntWidth = orient.width
 downPosition = trcCtrl.Top + orient.Height
 Else
 orntWidth = 0
 downPosition = controlPosition
End If

frmWidth = trcCtrl.minWidth + orntWidth + FRM_WBORDER

If Me.width < frmWidth Then
 If Me.WindowState = vbNormal Then Me.width = frmWidth
 trcCtrl.width = trcCtrl.minWidth
 Else
 trcCtrl.width = Me.width - orntWidth - FRM_WBORDER
End If

If trc.ornt.visible Then
 orient.Top = trcCtrl.Top
 orient.Left = trcCtrl.Left + trcCtrl.width + FRM_WBORDER / 2
 orient.visible = True
End If

'первй этап отрисовки полосы для правильного расположения
'на форме остальных контролов
If isCommonControlsVisible = True Then
 trcCtrl.visible = True
 controlPosition = controlPosition + trcCtrl.Height
End If

If trc.db.visible Then
 Objects.Top = controlPosition
 Objects.Left = trcCtrl.Left
 Objects.width = Me.width - FRM_WBORDER 'trcCtrl.Width
 controlPosition = Objects.Top + Objects.Height
 Objects.visible = True
End If

If trc.Coroz.visible Then
 Coroz.Top = controlPosition
 Coroz.Left = trcCtrl.Left
 Coroz.width = Me.width - FRM_WBORDER 'trcCtrl.Width
 Coroz.visible = True
 controlPosition = Coroz.Top + Coroz.Height
 Else
 Coroz.visible = False
End If

If trc.vog.visible Then
 With vog
 .Top = controlPosition
 .Left = trcCtrl.Left
 .width = Me.width - FRM_WBORDER 'trcCtrl.Width
 .visible = True
 controlPosition = .Top + .Height
 End With
 menuVog.visible = True
End If

If trc.isOnLine Then
 mnuView(8).visible = True
End If

drawCtlSpec trc.speed, ctrlSpeed
drawCtlSpec trc.press, ctrlPress
drawCtlSpec trc.angle, ctrlAngle
drawCtlSpec trc.thick, ctrlThick
drawCtlSpec trc.curve, ctrlCurve
drawCtlSpec trc.shake, ctrlShake
drawCtlSpec trc.temp, ctrlTemp
drawCtlSpec trc.azimuth, ctrlAzimuth
drawCtlSpec trc.tangazh, ctrlTangazh

drawCtlDgit trc.odo, ctrlOdo
drawCtlDgit trc.Timer, ctrlTime

If trc.sensExtVis Then
 With ctrlExt
 .Resize
 .Top = controlPosition
 .Left = trcCtrl.Left
 .width = Me.width - FRM_WBORDER
 .visible = True
 controlPosition = .Top + .Height
 End With
End If

If controlPosition > downPosition Then downPosition = controlPosition
If Me.WindowState <> vbMaximized Then
 d_skipHeight = (downPosition + FRM_HBORDER)
 Me.Height = d_skipHeight
 d_skipHeight = d_skipHeight - Me.Height
End If

If Me.skippedHeight > 0 Then
 If trc.Coroz.visible Then
  Coroz.TrimHeight Me, Me.skippedHeight
 End If
End If

waitMessage False
drawControls
intFlag = False
End Sub

Private Sub Form_Unload(Cancel As Integer)
mouseWeelUnHook Me
End Sub

Private Sub fSpeed_goDist(ByVal dst As Long)
goDist dst
frmMain.goDist trc.getDistKoef(dst), Me.hwnd
End Sub

Private Sub fTable_askFilter()
mnuObjCmd_Click 1
End Sub

Private Sub fTable_delObj(ByVal dst As Long, ByVal askFlag As Boolean)
currentObjectDist = dst
If askFlag Then
 mnuSingleObj_Click 1
 Else
 trc.db.objDel currentObjectDist
End If
End Sub

Private Sub fTable_delObjRange()
trc.db.objDelRange
End Sub

Private Sub fTable_edtCmnt(ByVal dst As Long, cmnt As String)
If trc.db.objCommon(dst, objCommon) Then
 objCommon.comment = cmnt
 trc.db.objCommonSet dst, objCommon, True
End If
End Sub

Private Sub fTable_edtDfkt(ByVal dst As Long, d_type As EN_INT_TYPE)
If trc.db.objCommon(dst, objCommon) Then
  If trc.db.objDefect(objCommon, objDefekt, True) = True Then
    objDefekt.dInsideType = d_type
    trc.db.objDefectSet dst, objDefekt, True
  End If
End If
End Sub

Private Sub fTable_edtObj(ByVal dst As Long, ByVal openWithoutZoom As Boolean)
currentObjectDist = dst
openWithoutZoomFlag = openWithoutZoom
mnuSingleObj_Click 0
End Sub

Private Sub fTable_formOFF()
mnuObjCmd(4).Checked = False
End Sub

Private Sub fTable_showObj(ByVal dst As Long)
showObj dst
End Sub

Public Sub showObj(ByVal dst As Long)
goDist dst
Objects.showObject dst
frmMain.goDist trc.getDistKoef(dst), Me.hwnd

If trc.db.objCommon(dst, objCommon) = False Then Exit Sub
If trc.db.objDefect(objCommon, objDefekt, True) = False Then
 Coroz.zone(0).drawBorder 0, 0, 0, 0, False
 Exit Sub
End If
Coroz.zone(0).drawBorder objDefekt.dEx1, objDefekt.dEx2, objDefekt.dEy1, objDefekt.dEy2, False
End Sub

Public Sub goDist(ByVal dst As Long)
Dim p As Long

p = (dst - trc.pageLength / 2) / trc.Step
p = IIf(p < 0, 0, p * trc.Step)

waitMessage True
trc.pageStart = p
drawControls
waitMessage False
End Sub

Public Sub jumpTo(ByVal dst As Long)
waitMessage True
trc.pageStart = trc.getDistReal(dst)
drawControls
waitMessage False
End Sub

Private Sub Coroz_goDist(ByVal dst As Long)
waitMessage True, "Переход на дистанцию..."
If trc.pageScaleX = USER_SCALE_X Then trcCtrl.setScale trc.pageScaleXLast
goDist dst
frmMain.goDist trc.getDistKoef(dst), Me.hwnd
waitMessage False
End Sub

Private Sub fTable_updateData()
If trc.Coroz.visible Then Coroz.Draw
If trc.db.visible Then Objects.Draw
End Sub

Private Sub fTubeProfil_formOFF()
trc.Coroz.tubeProfileHide
fCrzTool.tubeProfilSwitch
End Sub

Private Sub fTubeProfil_shiftMark(ByVal onLeft As Boolean, ByVal wMark As Boolean, ByVal bMark As Boolean)
Dim x As Long, wx As Long, bx As Long

x = IIf(onLeft, -1, 1)
wx = trc.mark.white + IIf(wMark, trc.scrollSpeed * trc.Step * x, 0)
bx = trc.mark.black + IIf(bMark, trc.scrollSpeed * trc.Step * x, 0)
setMarkGroup wx, bx
End Sub

Private Sub fZoom_formOFF()
orient.zoomClear
End Sub

Private Sub fZoom_mouseMove(ByVal y As Integer, ByVal x As Long, ByVal zoneNum As Long)

On Error GoTo errHandle

setMouse SRC_USER, x, y, zoneNum

Exit Sub
errHandle:
ogdWin.Alert "fZoom_mouseMove error:" & vbNewLine & Err.Description
Resume Next

End Sub

Private Sub fZoom_newDefekt( _
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
ByVal featClass As EN_FEAT_CLASS, _
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

On Error GoTo errHandle

fZoom.setLastInsertedDefect _
trc.db.newDefekt( _
 id, dst, dx, dy, orntStart, orntEnd, valMin, valMax, cmnt, _
 dInsideType, featClass, dEx1, dEx2, dEy1, dEy2, dIx1, dIx2, dIy1, dIy2, attention _
)
Objects.Draw

Exit Sub
errHandle:
ogdWin.Alert "fZoom_newDefekt error:" & vbNewLine & Err.Description
Resume Next

End Sub

Private Sub fZoom_selChange(ByVal x1 As Long, ByVal x2 As Long, ByVal y1 As Integer, ByVal y2 As Integer, ByVal zoneNum As Integer)
orient.zoomClear
orient.zoomDraw y1, y2, zoneNum
End Sub

Private Sub fZoom_setMarkers(ByVal x1 As Long, ByVal x2 As Long)
setMarkGroup x1, x2
drawControls
End Sub

Private Sub mnuArrange_Click(Index As Integer)
Dim i As Integer
Select Case Index
 Case 0
  i = vbCascade
 Case 1
  i = vbTileHorizontal
 Case 2
  i = vbTileVertical
End Select
frmMain.Arrange i
End Sub

Private Sub mnuExp_Click(Index As Integer)
Select Case Index
 Case 0 'графики
  fSpeed.showGraph
 Case 1 'развертка
  fDefekt.showData
End Select
End Sub

Private Sub mnuHelp_Click(Index As Integer)
Select Case Index

 Case 0 'содержание
  ShowHelp KRT_INTRO
  
 Case 1 'гпас
  StartURL LoadResString(201)
  
 Case 3 'о программе
  frmAbout.showInfo frmMain
 
End Select
End Sub

Private Sub mnuHistory_Click(Index As Integer)
openTrace mnuHistory(Index).Caption
updateHistory
End Sub

Private Sub objDefektRef_Changed(ByVal dst As Long)
Me.setObjDefekt objDefekt, dst
End Sub

Private Sub objDefektZoomRef_Changed(ByVal dst As Long)
Me.setObjDefekt objDefektZoom, dst
End Sub

Private Sub Objects_askFilter()
mnuObjCmd_Click 1
End Sub

Private Sub objects_mouseMove(ByVal x As Long)
setMouse SRC_OBJ, x, 0
End Sub

Private Sub Objects_newObj(ByVal dst As Long)
Objects.Draw
If trc.objNewEdit = False Then Exit Sub
If trc.db.objCommon(dst, objCommon) Then
 currentObjectDist = dst
 EditObj objCommon
End If
End Sub

Private Sub Objects_objWeldEdit(ByVal dst As Long)
If trc.db.objCommon(dst, objCommon) Then
  If trc.db.objWeld(objCommon, objWeld) = False Then Exit Sub
  frmObjWeld.Edit frmMain, objWeld, Me, dst, True
End If
End Sub

Private Sub Objects_setDfltObj(ByVal id As Integer)
Dim i As Integer
 i = 1
 While i < mnuObj.count
   If id = Int(val(mnuObj.Item(i).Tag)) Then
     mnuObj_Click i
     Exit Sub
   End If
   i = i + 1
 Wend
End Sub

Private Sub Objects_showDefect(dfkt As clsObjDefekt)
With dfkt
Coroz.drawRect .dEx1, .dEx2, .dEy1, .dEy2
End With
End Sub

Private Sub objects_showObj(ByVal dst As Long, objPic As PictureBox, ByVal flash As Boolean)
If trc.vog.visible Then
 Dim cmn As New clsObjCommon
 If trc.db.objCommon(dst, cmn) = False Then Exit Sub
 If cmn.objTyp.tbl = "weld" Then
   If trc.vog.showWelds = True Then
     vog.drawObj dst, objPic, flash
   End If
 Else
   vog.drawObj dst, objPic, flash
 End If
End If
End Sub

Private Sub objects_showWeld(ByVal dst As Long, ByVal wldBefore1 As Double, ByVal wldBefore2 As Double, ByVal wldAfter1 As Double, ByVal wldAfter2 As Double)
Coroz.drawWeld dst, wldBefore1, wldBefore2, wldAfter1, wldAfter2
End Sub

Private Sub setMouse(ByVal src As T_CHANGE_SOURCE, ByVal x As Long, ByVal y As Long, Optional ByVal zoneNum As Long = 0)

trcCtrl.mouseMove x

If trc.ornt.visible Then orient.Draw y, x, zoneNum
If trc.odo.visible Then ctrlOdo.mouseMove x
If trc.Timer.visible Then ctrlTime.mouseMove x

If trc.isUserScale Then Exit Sub
If stopEventFlag Then Exit Sub

If src <> SRC_COROZ Then
 If trc.Coroz.visible Then Coroz.mouseMove x, y
End If

If src <> SRC_ANGLE Then
 If trc.angle.visible Then ctrlAngle.mouseMove x
End If

If src <> SRC_THICK Then
 If trc.thick.visible Then ctrlThick.mouseMove x
End If

If src <> SRC_PRESS Then
 If trc.press.visible Then ctrlPress.mouseMove x
End If

If src <> SRC_CURVE Then
 If trc.curve.visible Then ctrlCurve.mouseMove x
End If

If src <> SRC_AZIMUTH Then
 If trc.azimuth.visible Then ctrlAzimuth.mouseMove x
End If

If src <> SRC_TANGAZH Then
 If trc.tangazh.visible Then ctrlTangazh.mouseMove x
End If

If src <> SRC_SHAKE Then
 If trc.shake.visible Then ctrlShake.mouseMove x
End If

If src <> SRC_TEMP Then
 If trc.temp.visible Then ctrlTemp.mouseMove x
End If

If src <> SRC_SPEED Then
 If trc.speed.visible Then ctrlSpeed.mouseMove x
End If

If src <> SRC_EXT Then
 If trc.sensExtVis Then ctrlExt.mouseMove x
End If

fSpeed.mouseMove x
End Sub

Private Sub drawControls()
stopEventFlag = True
waitMessage True
trcCtrl.Draw
If trc.vog.visible Then
 vog.setPage False
 vog.Draw
End If
If trc.Coroz.visible Then Coroz.Draw
If trc.Timer.visible Then ctrlTime.Draw
If trc.odo.visible Then ctrlOdo.Draw
If trc.angle.visible Then ctrlAngle.Draw
If trc.thick.visible Then ctrlThick.Draw
If trc.press.visible Then ctrlPress.Draw
If trc.curve.visible Then ctrlCurve.Draw
If trc.azimuth.visible Then ctrlAzimuth.Draw
If trc.tangazh.visible Then ctrlTangazh.Draw
If trc.shake.visible Then ctrlShake.Draw
If trc.temp.visible Then ctrlTemp.Draw
If trc.speed.visible Then ctrlSpeed.Draw
If trc.sensExtVis Then ctrlExt.Draw
'должен быть последним, для того чтобы отображаемые обьекты
'полосы не были стерты перерисовкой контролов
If trc.db.visible Then Objects.Draw
waitMessage False
stopEventFlag = False
End Sub

Private Sub trcCtrl_pageChange(ByVal newScale As Integer)
waitMessage True
If vog.visible Then vog.SetFocus
If Coroz.visible Then Coroz.SetFocus

trc.pageScaleX = newScale
drawControls
waitMessage False
End Sub

Private Sub setMark(ByVal mrkWhite As Boolean, ByVal newPos As Long)
If mrkWhite Then
 setMarkGroup newPos, trc.mark.black
 Else
 setMarkGroup trc.mark.white, newPos
End If
End Sub

Public Sub setMarkGroup(ByVal posWhite As Long, ByVal posBlack As Long)
trc.mark.setPos posWhite, posBlack
fTubeProfil.Redraw
drawControls
End Sub

Private Sub trcCtrl_posChange(ByVal newPos As Long)
Static intFlag As Boolean

If trc.pageStart = newPos Then Exit Sub

If intFlag Then Exit Sub
intFlag = True

waitMessage True
trc.pageStart = newPos
drawControls
waitMessage False

If frmMain.Sinhro And (isShiftDown() = False) Then
 frmMain.shiftPos trc.pageLastShift, Me.Tag
End If

intFlag = False
End Sub

Public Sub switchSinh(ByVal sync As Boolean)
Me.mnuTrace(3).Checked = sync
End Sub

Public Sub slaveScroll(ByVal isOn As Boolean)
Coroz.autoScrollOn = isOn
trcCtrl.visible = Not (isOn)
End Sub

Private Sub trcCtrl_Scroll(ByVal isOn As Boolean)
Coroz.autoScrollOn = isOn
frmMain.Scroll isOn, Me.Tag
End Sub

Public Function shiftPos(ByVal dlt As Long)
trc.pageStart = trc.pageStart + dlt
drawControls
End Function

Private Sub mnuTrace_Click(Index As Integer)
Dim s As String

Select Case Index
 Case 0 'регистрация
  registerTrace
  'Objects.debug_Fill_50K_weld
 Case 1 'открыть запись
  s = ogdWin.fileOpen( _
   "Выберите файл описания прогона", _
   "", cfg.dir.trc, _
   "Файлы прогонов (*.trc)|*.trc", Me.hWnd _
   )
  If s = "" Then Exit Sub
  openTrace s
  updateHistory

 Case 2 'закрыть запись
  Unload Me
 Case 3 'синхронная прокрутка
  frmMain.switchSinh

 Case 5 'настройки программы
  frmPrgSetting.Edit

 Case 6 'сохранить настройки
  If isShiftDown Then
   trc.distSave
   ogdWin.Info "Текущая дистанция записи" & vbNewLine & _
   Me.Caption & vbNewLine & "успешно сохранена."
   Else
   cfg.Save frmMain
   Me.Save
   ogdWin.Info "Пользовательские настройки записи" & vbNewLine & _
   Me.Caption & vbNewLine & "успешно сохранены."
  End If

 Case 7 'редактор палитр
  frmPalette.Edit frmMain, ""

 Case 9 'таймерные маркеры
  fTimeMrk.Edit

 Case 10 'автоматический анализ
  If frmAutoScan.View(Me) Then
   waitMessage True, "Обновление данных..."
   trc.db.Refresh
   waitMessage False
  End If

 Case 11 'колеса одометра
  frmOdoWheel.Edit frmMain, trc

 Case 12 'выход
  Unload frmMain
End Select
End Sub

Private Sub mnuView_Click(Index As Integer)
Dim v1 As Long, v2 As Long, s As String
Select Case Index

 Case 0 'видимые датчики
  If frmSetting.Edit(Me) Then
   ClearData
   sizeAndDrawControls
  End If
  If trc.isNeedRecalc Then
   trc.db.calcKoefData
   fTable.refreshData
  End If

 Case 1 'полоса расшифровки
  trc.db.visible = Not (trc.db.visible)
  isCommonControlsVisible = trc.db.visible
  mnuView(1).Checked = trc.db.visible
  menuObject.visible = trc.db.visible
  If mnuView(1).Checked = False Then
   fTable.formVisible = False
   Else
   If mnuObjCmd(4).Checked Then fTable.formVisible = True
  End If
  sizeAndDrawControls

 Case 2 'вся трасса
  v1 = 0
  v2 = trc.length
  setInterval v1, v2

 Case 3 'область просмотра
  v1 = trc.pageStart
  v2 = trc.pageStart + trc.pageLength
  If frmInterval.Interval( _
       Me, _
       0, _
       trc.length, _
       v1, v2, trc) Then
     setInterval v1, v2
   End If

 Case 4 'переход на отметку
  v1 = frmInterval.getDist(Me, "Переход на отметку", "Отметка:", trc.getDistKoef(trc.pageStart))
  trc.pageStart = trc.getDistReal(v1)
  drawControls
  frmMain.jumpTo v1
  
 Case 5 'маркеры
  v1 = trc.mark.white
  v2 = trc.mark.black
  If frmInterval.setMarkers(Me, v1, v2, trc) Then Me.setMarkGroup v1, v2
  
 Case 8 'переход в конец трассы
  If trc.isOnLine Then
    v1 = onLineCurrentDist - trc.pageLength
    'MsgBox v1
    If v1 > trc.pageStart Then trc.pageStart = onLineCurrentDist
    drawControls
  End If
  

End Select
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''
'функции обслуживания специальных меню контролов
'''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''
'функции меню для vog
Private Sub VOG_popUpMenu(ByVal hitArea As VOG_AREA)
vogHitArea = hitArea
popupMenuFlag = True
popupMenuItem = -1
Me.popUpMenu menuVog
popupMenuFlag = False
If popupMenuItem >= 0 Then
 mnuVog_Click popupMenuItem
 popupMenuItem = -1
End If
End Sub

Private Sub vog_changeMark()
switchMark
End Sub

Private Sub vog_redraw()
If trc.db.showForever Then Objects.showAllObj
End Sub

Private Sub exportVogZ()
Dim f As String

f = ogdWin.fileSave( _
 "Укажите имя файла", _
 "", _
 "", _
 "Файлы обьектов (*.csv)|*.csv", _
 Me.hWnd _
)

If f = "" Then Exit Sub
waitMessage True, "Запись в '" & f & "' ..."
If vog.exportZ(f) Then ogdWin.Info "Данные записаны в файл " & vbNewLine & f
waitMessage False
End Sub

Private Sub addTurn()
Dim t As New clsObjType, c As New clsObjCommon, turn As New clsobjTurn

t.Init OBJ_TYPE.OBJ_povorot, "Поворот", False, OBJ_TBL_TURN
If trc.db.objAdd(trc.mark.white, trc.mark.black - trc.mark.white, t, False) = False Then Exit Sub
If trc.db.objCommon(trc.mark.white, c) = False Then Exit Sub
If trc.db.objTurn(c, turn) = False Then Exit Sub

turn.dTuneStart = cfg.vog.tuneStart
turn.dTuneEnd = cfg.vog.tuneEnd
If turn.reCalc(vog, cfg.vog.turnHor, cfg.vog.turnVer) = False Then Exit Sub
If trc.db.objTurnSet(turn.objCommon.objDist, turn) = False Then Exit Sub

If trc.objNewEdit Then
 currentObjectDist = turn.objCommon.objDist
 EditObj turn.objCommon
End If
Objects.Draw
End Sub

Private Sub mnuVog_Click(Index As Integer)

If popupMenuFlag Then
 popupMenuItem = Index
 Exit Sub
End If

Select Case Index

 Case 0 'параметры поворота
  vogTurnInfo

 Case 1 'совместить
  If frmVogMatchSelect.SelSlave(Me) Then
   Me.Refresh
   vog.Draw
  End If

 Case 2 'копировать в буфер
  vog.copyClipboard vogHitArea

 Case 3 'поворот
  vog.setRotAngle

 Case 4 'вставить обьект
  addTurn

 Case 5 'экспорт Z
  exportVogZ

 Case 6 'Запомнить диапазон
  trc.vog.saveStart = trc.pageStart
  trc.vog.saveEnd = trc.pageStart + trc.pageLength
  vog.Draw

 Case 7 'Восстановить диапазон
  vog.visRestore
  'vog.Draw
  
 End Select
End Sub

Private Sub vogTurnInfo()
Dim Start As Long, length As Long, user_length As Long
Dim radiusXY As Long, angleXY As Single, angle3D As Single
Dim radiusZ As Long, angleZ As Single, markX As Long, markY As Long, markZ As Long

Start = trc.mark.white
length = trc.mark.black - trc.mark.white
user_length = trc.getLenKoef(Start, length)
If vog.turnInfo(Start, length, 0, radiusXY, angleXY, radiusZ, angleZ, markX, markY, markZ, angle3D, user_length) Then
 frmTurnInfo.View Me, Start, length, radiusXY, angleXY, radiusZ, angleZ, markX, markY, markZ, angle3D, trc
End If
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''
'функции меню для полосы расшифровки

Private Sub Objects_objMenu(ByVal dst As Long)
currentObjectDist = dst

popupMenuFlag = True
popupMenuItem = -1
Me.popUpMenu menuSingleObj
popupMenuFlag = False
If popupMenuItem >= 0 Then
 mnuSingleObj_Click popupMenuItem
 popupMenuItem = -1
End If

End Sub

Private Sub mnuObjCmd_Click(Index As Integer)
Select Case Index
 Case 1 'фильтр
  If frmObjFilter.Edit(Me, trc.db.objTypes) Then
   trc.db.Refresh
   Objects.Draw
  End If
 Case 2 'отобразить
  Objects.showAllObj
 Case 3 'отображать постоянно
  waitMessage True, "Обработка ..."
  trc.db.showForever = Not (trc.db.showForever)
  mnuObjCmd(3).Checked = trc.db.showForever
  If trc.db.showForever Then
   Objects.showAllObj
   Else
   vog.Draw
   Coroz.Draw
  End If
  waitMessage False
 Case 4 'таблица
  fTable.formVisible = Not fTable.formVisible
  mnuObjCmd(4).Checked = fTable.formVisible
End Select
End Sub

Private Sub mnuObjImp_Click(Index As Integer)
Dim typ As EN_EXP_TYPE

Select Case Index
 Case 0 'швы
  typ = ET_WELD
 Case 1 'лин.обьекты
  typ = ET_LINEOBJ
 Case 2 'дефекты
  typ = ET_DEFECT
 Case 3 'пригрузы
  typ = ET_PRIGRUZ
 Case 4 'толщина
  typ = ET_THICK
 Case 5 'повороты
  typ = ET_VOG_POVOROT
 Case 6 'категории
  typ = ET_CATEGORY
End Select
trc.db.ImportData typ, vog
Objects.Draw
If fTable.visible Then fTable.refreshData
End Sub

Private Sub mnuObjExp_Click(Index As Integer)
Dim typ As EN_EXP_TYPE

Select Case Index
 Case 0
  typ = ET_WELD
 Case 1
  typ = ET_LINEOBJ
 Case 2
  typ = ET_DEFECT
 Case 3
  typ = ET_PRIGRUZ
 Case 4
  typ = ET_SPEED
 Case 5
  typ = ET_THICK
 Case 6
  typ = ET_MAGNETS
 Case 7
  typ = ET_CATEGORY
 Case 8
  typ = ET_VOG_POVOROT
 Case 10
  typ = ET_CRCT_TABLE
 Case 11
  typ = ET_VOG_CSV
 Case 12
  typ = ET_WELD_EXTENDED

End Select
trc.db.ExportData typ
End Sub

Private Sub Objects_popUpMenu(ByVal x As Long)
popupMenuFlag = True
popupMenuItem = -1
Me.popUpMenu menuObject
popupMenuFlag = False
If popupMenuItem >= 0 Then
 mnuObj_Click popupMenuItem
 If (popupMenuItem > 0) And (x > 0) Then
  trc.db.addObj x
  Objects_newObj x
 End If
 popupMenuItem = -1
End If
End Sub

Private Sub UpMenuItem(ByVal ItemIndex As Integer)
Dim i As Integer, prevCaption As String, prevTag As String
Dim nextCaption As String, nextTag As String

If ItemIndex = 1 Then Exit Sub

i = 1

prevCaption = Me.mnuObj(i).Caption
prevTag = Me.mnuObj(i).Tag

Me.mnuObj(i).Caption = Me.mnuObj(ItemIndex).Caption
Me.mnuObj(i).Tag = Me.mnuObj(ItemIndex).Tag

'mnuObj.count
While i < ItemIndex
 nextCaption = Me.mnuObj(i + 1).Caption
 nextTag = Me.mnuObj(i + 1).Tag
 Me.mnuObj(i + 1).Caption = prevCaption
 Me.mnuObj(i + 1).Tag = prevTag
 prevCaption = nextCaption
 prevTag = nextTag
 i = i + 1
Wend
End Sub

Public Sub setMenuObjTypes()
Dim obj As clsObjType, i As Integer, dfltObjIsSet As Boolean

If trc.db.enable = False Then Exit Sub

For i = 3 To Me.mnuObj.count - 1
 Unload Me.mnuObj(i)
Next

dfltObjIsSet = False

i = 2
For Each obj In trc.db.objTypes
 If (obj.off = False) And (obj.enabled = True) Then
  If i > 2 Then Load Me.mnuObj(i)
  Me.mnuObj(i).Caption = obj.name
  Me.mnuObj(i).Tag = obj.id
  If obj.id = trc.db.dfltType Then
'   mnuObj(i).Checked = True
'   mnuObj_Click i
   dfltObjIsSet = True
  End If
  i = i + 1
 End If
Next

If Not dfltObjIsSet Then
 On Error Resume Next
 trc.db.dfltType = Me.mnuObj(2).Tag
 mnuObj_Click 2
 On Error GoTo 0
End If
End Sub

Private Sub mnuObj_Click(Index As Integer)
If popupMenuFlag Then
 popupMenuItem = Index
 Exit Sub
End If

If Index = 0 Then Exit Sub

trc.db.dfltType = mnuObj(Index).Tag
UpMenuItem Index
Objects.Draw
End Sub

Private Sub mnuSingleObj_Click(Index As Integer)

If popupMenuFlag Then
 popupMenuItem = Index
 Exit Sub
End If
Select Case Index
 Case 0 'изменить
  If trc.db.objCommon(currentObjectDist, objCommon) Then EditObj objCommon
 Case 1 'удалить
  If ogdWin.AskAction("Удалить обьект?") Then
   trc.db.objDel currentObjectDist
   Objects.Draw
  End If
 Case 2 'найти в таблице
  fTable.findObj currentObjectDist
End Select
End Sub

Private Sub EditObj(objCommonInfo As clsObjCommon)
Dim editInZoom As Boolean, dfkt As clsObjDefekt

Select Case objCommonInfo.objTyp.tbl

 Case OBJ_TBL_NONE
  frmObjCommon.Edit frmMain, objCommonInfo, Me, currentObjectDist

 Case OBJ_TBL_WELD
  If trc.db.objWeld(objCommonInfo, objWeld) = False Then Exit Sub
  frmObjWeld.Edit frmMain, objWeld, Me, currentObjectDist

 Case OBJ_TBL_DFKT

  editInZoom = False
  If (isShiftDown() = False) And Not openWithoutZoomFlag Then
   Set dfkt = New clsObjDefekt
   If trc.db.objDefect(objCommonInfo, dfkt) = False Then Exit Sub
   If dfkt.dEx1 > 0 Then
    editInZoom = True
   End If
   Set dfkt = Nothing
  End If
  
  openWithoutZoomFlag = False

  If editInZoom Then
   If trc.db.objDefect(objCommonInfo, objDefektZoom) = False Then Exit Sub
   ZoomDefekt objDefektZoom
   Else
   If trc.db.objDefect(objCommonInfo, objDefekt) = False Then Exit Sub
   frmObjDefekt.Edit frmMain, objDefekt, Me, currentObjectDist
  End If

 Case OBJ_TBL_LINE
  If trc.db.objLine(objCommonInfo, objLine) = False Then Exit Sub
  frmObjLine.Edit frmMain, objLine, Me, currentObjectDist

 Case OBJ_TBL_THICK
  If trc.db.objThick(objCommonInfo, objThick) = False Then Exit Sub
  frmObjThick.Edit frmMain, objThick, Me, currentObjectDist

 Case OBJ_TBL_TURN
  If trc.db.objTurn(objCommonInfo, objTurn) = False Then Exit Sub
  frmObjTurn.Edit frmMain, objTurn, Me, currentObjectDist

 Case Else
  ogdWin.Alert "Неизвестный тип обьекта " & objCommonInfo.objTyp.tbl
End Select
End Sub

Public Sub setObjCommon(obj As clsObjCommon, ByVal dst As Long)
trc.db.objCommonSet dst, obj, True
Objects.Draw
End Sub

Public Sub setObjWeld(obj As clsObjWeld, ByVal dst As Long)
trc.db.objWeldSet dst, obj
Coroz.Draw
Objects.Draw
End Sub

Public Sub setObjDefekt(obj As clsObjDefekt, ByVal dst As Long)

On Error GoTo errHandle

If trc.db.objDefectSet(dst, obj) Then
 Objects.Draw
 currentObjectDist = obj.objCommon.objDist
End If

Exit Sub
errHandle:
ogdWin.Alert "setObjDefekt error:" & vbNewLine & Err.Description
Resume Next

End Sub

Public Sub setObjLine(obj As clsObjLine, ByVal dst As Long)
trc.db.objLineSet dst, obj
Objects.Draw
End Sub

Public Sub setObjThick(obj As clsObjThick, ByVal dst As Long)
trc.db.objThickSet dst, obj
Objects.Draw
End Sub

Public Sub setObjTurn(obj As clsobjTurn, ByVal dst As Long)
trc.db.objTurnSet dst, obj
Objects.Draw
End Sub

Public Sub Save()
waitMessage True, "Сохранение настроек..."
trc.Save
frm.saveForm Me
fZoom.Save
fTimeMrk.Save
fTable.Save
fTubeProfil.Save
fDefekt.Save
waitMessage False
End Sub

Private Sub setPixelRight( _
ByVal src As T_CHANGE_SOURCE, _
ByVal pix As Integer)

lastPixelRight = pix
If trc.db.enable Then Objects.pixelRight = pix

If (trc.speed.num > 0) Then ctrlSpeed.pixelRight = pix
If (trc.press.num > 0) Then ctrlPress.pixelRight = pix
If (trc.angle.num > 0) Then ctrlAngle.pixelRight = pix
If (trc.thick.num > 0) Then ctrlThick.pixelRight = pix
If (trc.shake.num > 0) Then ctrlShake.pixelRight = pix
If (trc.curve.num > 0) Then ctrlCurve.pixelRight = pix
If (trc.azimuth.num > 0) Then ctrlAzimuth.pixelRight = pix
If (trc.tangazh.num > 0) Then ctrlTangazh.pixelRight = pix
If (trc.temp.num > 0) Then ctrlTemp.pixelRight = pix
If (trc.odo.num > 0) Then ctrlOdo.pixelRight = pix
If (trc.Timer.num > 0) Then ctrlTime.pixelRight = pix
If (trc.numExt > 0) Then ctrlExt.pixelRight = pix
End Sub

Private Sub vog_setMark(ByVal x As Long)
setMark trc.mark.isCurrWhite, x
End Sub

Private Sub vog_visualPartChange(ByVal visStart As Long, ByVal visLength As Long)
setInterval visStart, visStart + visLength
End Sub

Private Sub setInterval(ByVal vStart As Long, ByVal vEnd As Long)
waitMessage True, "Расчет трассы..."
trc.pageLength = vEnd - vStart
trc.pageStart = vStart
vog.setPage
trcCtrl.setScale USER_SCALE_X
waitMessage False
End Sub

Private Sub waitMessage(ByVal isWait As Boolean, Optional ByVal msgText As String = "Формирую изображение...")
If trcCtrl.isScrollInProgress Then Exit Sub
If Coroz.autoScrollOn Then Exit Sub
If isWait Then
 busyFlag = True
 setWait msgText
 Else
 setReady
 busyFlag = False
End If
End Sub

Private Sub onLineDataSub(ByVal ol_start As Long, ByVal ol_length As Long)
While busyFlag
ogdPause 50
Wend

onLineData.d_start = -1
onLineData.d_length = -1
onLineCurrentDist = ol_start + ol_length

waitMessage True, "New data: start " & ol_start & " len " & ol_length

Dim x As Long
x = ol_start - trc.pageLength
'MsgBox ol_start & " " & ol_length & " " & trc.pageLength
If x <= trc.pageStart Then
 'изменения в пределах экрана
 'надо принудительно перерисовать текущую развертку
 Coroz.Draw True
 Else
 'сдвинуться на соотв. дистанцию
 If cfg.isOnLine Then trcCtrl_posChange x
End If

waitMessage False
End Sub

Property Get skippedHeight() As Long
skippedHeight = d_skipHeight / Screen.twipsPerPixelY
End Property