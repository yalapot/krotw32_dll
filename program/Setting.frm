VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "TabCtl32.Ocx"
Begin VB.Form frmSetting 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Параметры просмотра записи"
   ClientHeight    =   5355
   ClientLeft      =   2040
   ClientTop       =   1695
   ClientWidth     =   8655
   Icon            =   "Setting.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5355
   ScaleWidth      =   8655
   ShowInTaskbar   =   0   'False
   Begin TabDlg.SSTab SSTab 
      Height          =   4695
      Left            =   120
      TabIndex        =   13
      Top             =   0
      Width           =   8415
      _ExtentX        =   14843
      _ExtentY        =   8281
      _Version        =   393216
      Style           =   1
      TabsPerRow      =   6
      TabHeight       =   520
      TabCaption(0)   =   "Основные"
      TabPicture(0)   =   "Setting.frx":0442
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "Label1(0)"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).Control(1)=   "Label1(2)"
      Tab(0).Control(1).Enabled=   0   'False
      Tab(0).Control(2)=   "Label1(3)"
      Tab(0).Control(2).Enabled=   0   'False
      Tab(0).Control(3)=   "Label1(5)"
      Tab(0).Control(3).Enabled=   0   'False
      Tab(0).Control(4)=   "Label1(6)"
      Tab(0).Control(4).Enabled=   0   'False
      Tab(0).Control(5)=   "labDriver"
      Tab(0).Control(5).Enabled=   0   'False
      Tab(0).Control(6)=   "speedVector"
      Tab(0).Control(6).Enabled=   0   'False
      Tab(0).Control(7)=   "frameDist"
      Tab(0).Control(7).Enabled=   0   'False
      Tab(0).Control(8)=   "mainSens"
      Tab(0).Control(8).Enabled=   0   'False
      Tab(0).Control(9)=   "speed"
      Tab(0).Control(9).Enabled=   0   'False
      Tab(0).Control(10)=   "vog"
      Tab(0).Control(10).Enabled=   0   'False
      Tab(0).Control(11)=   "txtName"
      Tab(0).Control(11).Enabled=   0   'False
      Tab(0).Control(12)=   "btmMdb"
      Tab(0).Control(12).Enabled=   0   'False
      Tab(0).Control(13)=   "btmRpt"
      Tab(0).Control(13).Enabled=   0   'False
      Tab(0).Control(14)=   "txtMdb"
      Tab(0).Control(14).Enabled=   0   'False
      Tab(0).Control(15)=   "txtRpt"
      Tab(0).Control(15).Enabled=   0   'False
      Tab(0).Control(16)=   "txtOdoStart"
      Tab(0).Control(16).Enabled=   0   'False
      Tab(0).Control(17)=   "txtDiam"
      Tab(0).Control(17).Enabled=   0   'False
      Tab(0).Control(18)=   "frameOrient"
      Tab(0).Control(18).Enabled=   0   'False
      Tab(0).Control(19)=   "Frame3"
      Tab(0).Control(19).Enabled=   0   'False
      Tab(0).Control(20)=   "frmCurveMode"
      Tab(0).Control(20).Enabled=   0   'False
      Tab(0).Control(21)=   "frmPigGeometry"
      Tab(0).Control(21).Enabled=   0   'False
      Tab(0).Control(22)=   "chkObjNewEdit"
      Tab(0).Control(22).Enabled=   0   'False
      Tab(0).Control(23)=   "Frame2"
      Tab(0).Control(23).Enabled=   0   'False
      Tab(0).ControlCount=   24
      TabCaption(1)   =   "Дополнительные"
      TabPicture(1)   =   "Setting.frx":045E
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "FrameCurve"
      Tab(1).Control(1)=   "FrameThick"
      Tab(1).Control(2)=   "FrameAngle"
      Tab(1).Control(3)=   "FrameTemp"
      Tab(1).Control(4)=   "FramePress"
      Tab(1).Control(5)=   "FrameShake"
      Tab(1).Control(6)=   "FrameOdo"
      Tab(1).Control(7)=   "frameTimer"
      Tab(1).ControlCount=   8
      TabCaption(2)   =   "Вспомогательные"
      TabPicture(2)   =   "Setting.frx":047A
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "Frame5"
      Tab(2).ControlCount=   1
      Begin VB.Frame Frame5 
         BorderStyle     =   0  'None
         Height          =   4215
         Left            =   -74880
         TabIndex        =   73
         Top             =   360
         Width           =   8175
         Begin VB.VScrollBar scroll 
            Height          =   4095
            Left            =   7920
            TabIndex        =   76
            Top             =   120
            Visible         =   0   'False
            Width           =   255
         End
         Begin VB.Frame Frame1 
            BorderStyle     =   0  'None
            Height          =   495
            Left            =   0
            TabIndex        =   74
            Top             =   120
            Width           =   7620
            Begin VB.CheckBox extended 
               Caption         =   "Check1"
               Height          =   255
               Index           =   0
               Left            =   120
               TabIndex        =   75
               ToolTipText     =   "Показ графика вспомогательного датчика"
               Top             =   120
               Width           =   7560
            End
         End
      End
      Begin VB.Frame Frame2 
         Caption         =   "Тип масштабирования"
         Height          =   1335
         Left            =   6240
         TabIndex        =   64
         Top             =   1800
         Width           =   2055
         Begin VB.OptionButton rbtnScaleMode 
            Caption         =   "выбор максимума"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   68
            Top             =   240
            Width           =   1815
         End
         Begin VB.OptionButton rbtnScaleMode 
            Caption         =   "выбор минимума"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   67
            Top             =   480
            Width           =   1695
         End
         Begin VB.OptionButton rbtnScaleMode 
            Caption         =   "выбор среднего"
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   66
            Top             =   720
            Width           =   1815
         End
         Begin VB.OptionButton rbtnScaleMode 
            Caption         =   "прореживание"
            Height          =   255
            Index           =   3
            Left            =   120
            TabIndex        =   65
            Top             =   960
            Width           =   1815
         End
      End
      Begin VB.CheckBox chkObjNewEdit 
         Caption         =   "Редактор при вставке обьекта"
         Height          =   375
         Left            =   120
         TabIndex        =   63
         Top             =   4200
         Width           =   2895
      End
      Begin VB.Frame frmPigGeometry 
         Caption         =   "Геометр.размеры снаряда"
         Height          =   615
         Left            =   3120
         TabIndex        =   56
         Top             =   3960
         Width           =   5175
         Begin VB.TextBox txtPigL3 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3600
            TabIndex        =   70
            Text            =   "Text4"
            Top             =   240
            Width           =   855
         End
         Begin VB.TextBox txtPigL0 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   480
            TabIndex        =   58
            Text            =   "Text4"
            ToolTipText     =   "Параметр L0 длины снаряда для поправки в расчете параметров углов стыка и изгиба трубы в VOG-подсистеме"
            Top             =   240
            Width           =   975
         End
         Begin VB.TextBox txtPigL1 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2040
            TabIndex        =   57
            Text            =   "Text4"
            ToolTipText     =   "Параметр L1 длины снаряда для поправки в расчете параметров углов стыка и изгиба трубы в VOG-подсистеме"
            Top             =   240
            Width           =   855
         End
         Begin VB.Label Label1 
            Caption         =   "L3"
            Height          =   255
            Index           =   4
            Left            =   3120
            TabIndex        =   69
            Top             =   240
            Width           =   375
         End
         Begin VB.Label Label1 
            Caption         =   "L0"
            Height          =   255
            Index           =   7
            Left            =   120
            TabIndex        =   60
            Top             =   240
            Width           =   375
         End
         Begin VB.Label Label1 
            Caption         =   "L1"
            Height          =   255
            Index           =   1
            Left            =   1680
            TabIndex        =   59
            Top             =   240
            Width           =   375
         End
      End
      Begin VB.Frame frmCurveMode 
         Caption         =   "Режим графика изгиба"
         Height          =   1215
         Left            =   3120
         TabIndex        =   52
         Top             =   2760
         Width           =   3015
         Begin VB.TextBox txtCurveLength 
            Height          =   285
            Left            =   2040
            TabIndex        =   61
            Text            =   "Text1"
            ToolTipText     =   "Длина окна вычисления изгиба для графика изгиба в мм."
            Top             =   800
            Width           =   855
         End
         Begin VB.OptionButton crvMode 
            Caption         =   "изгиб, градусы"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   54
            Top             =   240
            Width           =   1815
         End
         Begin VB.OptionButton crvMode 
            Caption         =   "радиус поворота, диам. трубы"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   53
            Top             =   480
            Width           =   2775
         End
         Begin VB.Label Label2 
            Caption         =   "Длина изгиба, мм"
            Height          =   255
            Index           =   3
            Left            =   120
            TabIndex        =   62
            Top             =   795
            Width           =   1815
         End
      End
      Begin VB.Frame Frame3 
         Caption         =   "Коррозионный датчик "
         Height          =   1335
         Left            =   6240
         TabIndex        =   49
         Top             =   420
         Width           =   2055
         Begin VB.OptionButton crzTesla 
            Caption         =   "миллитесла"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   51
            Top             =   480
            Width           =   1815
         End
         Begin VB.OptionButton crzTesla 
            Caption         =   "единицы АЦП"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   50
            Top             =   240
            Width           =   1815
         End
      End
      Begin VB.Frame FrameCurve 
         Caption         =   "Навигация"
         Height          =   1935
         Left            =   -68760
         TabIndex        =   47
         Top             =   2400
         Width           =   1935
         Begin VB.CheckBox tangazh 
            Caption         =   "Тангаж"
            Height          =   255
            Left            =   120
            TabIndex        =   78
            Top             =   1560
            Width           =   1455
         End
         Begin VB.CheckBox azimut 
            Caption         =   "Азимут"
            Height          =   255
            Left            =   120
            TabIndex        =   77
            Top             =   1320
            Width           =   1335
         End
         Begin VB.CheckBox curve 
            Caption         =   "3D"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   27
            ToolTipText     =   "Показ графика датчика акселерометра"
            Top             =   240
            Width           =   1215
         End
         Begin VB.PictureBox picCurve 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   48
            Top             =   240
            Width           =   255
         End
      End
      Begin VB.Frame FrameThick 
         Caption         =   "Толщина"
         Height          =   1935
         Left            =   -68760
         TabIndex        =   40
         Top             =   420
         Width           =   1935
         Begin VB.CheckBox thick 
            Caption         =   "Базовый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   23
            ToolTipText     =   "Показ графика датчика ускорения"
            Top             =   240
            Width           =   1215
         End
         Begin VB.PictureBox picThick 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   41
            Top             =   240
            Width           =   255
         End
      End
      Begin VB.Frame frameOrient 
         Caption         =   "Ориентация"
         Height          =   1335
         Left            =   2880
         TabIndex        =   14
         Top             =   420
         Width           =   3255
         Begin VB.PictureBox picOrient 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   2760
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   15
            Top             =   240
            Width           =   255
         End
         Begin VB.CheckBox orient 
            Caption         =   "Базовая"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   3
            ToolTipText     =   "Показ показаний датчика ориентации"
            Top             =   240
            Width           =   2055
         End
      End
      Begin VB.TextBox txtDiam 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   2160
         TabIndex        =   10
         Text            =   "Text4"
         ToolTipText     =   "Диаметр трубы для для пересчета геометрических размеров изображения в лупе"
         Top             =   3720
         Width           =   855
      End
      Begin VB.TextBox txtOdoStart 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   2160
         TabIndex        =   9
         Text            =   "Text4"
         ToolTipText     =   "Сдвиг отметки нуля дистанции"
         Top             =   3960
         Width           =   855
      End
      Begin VB.TextBox txtRpt 
         Height          =   285
         Left            =   1920
         TabIndex        =   8
         Text            =   "Text1"
         ToolTipText     =   "Имя файла с описанием внешних GPS маркеров"
         Top             =   2400
         Width           =   4215
      End
      Begin VB.TextBox txtMdb 
         Height          =   285
         Left            =   1920
         TabIndex        =   6
         Text            =   "Text1"
         ToolTipText     =   "Имя файла обьектов полосы расшифровки"
         Top             =   2160
         Width           =   4215
      End
      Begin VB.CommandButton btmRpt 
         Caption         =   "..."
         Height          =   255
         Left            =   1320
         TabIndex        =   7
         ToolTipText     =   "Выбор файла с описанием внешних GPS маркеров"
         Top             =   2400
         Width           =   615
      End
      Begin VB.CommandButton btmMdb 
         Caption         =   "..."
         Height          =   255
         Left            =   1320
         TabIndex        =   5
         ToolTipText     =   "Выбор файла обьектов полосы расшифровки"
         Top             =   2160
         Width           =   615
      End
      Begin VB.TextBox txtName 
         Height          =   285
         Left            =   240
         TabIndex        =   4
         Text            =   "Text1"
         ToolTipText     =   "Пользовательское название записи в trc-файле"
         Top             =   1800
         Width           =   5895
      End
      Begin VB.Frame FrameAngle 
         Caption         =   "Вращение"
         Height          =   1935
         Left            =   -70800
         TabIndex        =   29
         Top             =   2400
         Width           =   1935
         Begin VB.PictureBox picAngle 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   33
            Top             =   240
            Width           =   255
         End
         Begin VB.CheckBox angle 
            Caption         =   "Базовый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   26
            ToolTipText     =   "Показ графика датчика акселерометра"
            Top             =   240
            Width           =   1215
         End
      End
      Begin VB.Frame FrameTemp 
         Caption         =   "Температура"
         Height          =   1935
         Left            =   -72840
         TabIndex        =   28
         Top             =   2400
         Width           =   1935
         Begin VB.PictureBox picTemp 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   32
            Top             =   240
            Width           =   255
         End
         Begin VB.CheckBox temperature 
            Caption         =   "Базовый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   25
            ToolTipText     =   "Показ графика датчика температуры"
            Top             =   240
            Width           =   1215
         End
      End
      Begin VB.Frame FramePress 
         Caption         =   "Вибрация"
         Height          =   1935
         Left            =   -74880
         TabIndex        =   19
         Top             =   2400
         Width           =   1935
         Begin VB.PictureBox picShake 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   71
            Top             =   240
            Width           =   255
         End
         Begin VB.CheckBox shake 
            Caption         =   "Базовый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   24
            ToolTipText     =   "Показ графика датчика ускорения"
            Top             =   240
            Width           =   1215
         End
      End
      Begin VB.Frame FrameShake 
         Caption         =   "Давление"
         Height          =   1935
         Left            =   -70800
         TabIndex        =   18
         Top             =   420
         Width           =   1935
         Begin VB.PictureBox picPress 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   72
            Top             =   240
            Width           =   255
         End
         Begin VB.CheckBox press 
            Caption         =   "Базовый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   22
            ToolTipText     =   "Показ графика датчика давления"
            Top             =   240
            Width           =   1335
         End
      End
      Begin VB.Frame FrameOdo 
         Caption         =   "Одометры"
         Height          =   1935
         Left            =   -72840
         TabIndex        =   17
         Top             =   420
         Width           =   1935
         Begin VB.PictureBox picOdo 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   31
            Top             =   240
            Width           =   255
         End
         Begin VB.CheckBox odo 
            Caption         =   "Базовый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   21
            ToolTipText     =   "Показ данных бортового одометра"
            Top             =   240
            Width           =   1215
         End
      End
      Begin VB.Frame frameTimer 
         Caption         =   "Таймеры"
         Height          =   1935
         Left            =   -74880
         TabIndex        =   16
         Top             =   420
         Width           =   1935
         Begin VB.PictureBox picTimeSens 
            BackColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   1560
            ScaleHeight     =   195
            ScaleWidth      =   195
            TabIndex        =   30
            Top             =   240
            Width           =   255
         End
         Begin VB.CheckBox timeSens 
            Caption         =   "Базовый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   20
            ToolTipText     =   "Показ данных бортового таймера"
            Top             =   240
            Width           =   1335
         End
      End
      Begin VB.CheckBox vog 
         Caption         =   "VOG Ctrl+D"
         Height          =   255
         Left            =   240
         TabIndex        =   2
         ToolTipText     =   "Показ навигационной записи движения снаряда"
         Top             =   960
         Width           =   2175
      End
      Begin VB.CheckBox speed 
         Caption         =   "Скорость"
         Height          =   255
         Left            =   240
         TabIndex        =   1
         ToolTipText     =   "Показ графика скорости движения снаряда"
         Top             =   720
         Width           =   1095
      End
      Begin VB.CheckBox mainSens 
         Caption         =   "Развертка"
         Height          =   255
         Left            =   240
         TabIndex        =   0
         ToolTipText     =   "Показ магнитной развертки трубы "
         Top             =   480
         Width           =   2175
      End
      Begin VB.Frame frameDist 
         Caption         =   "Поправки дистанции"
         Height          =   975
         Left            =   120
         TabIndex        =   42
         Top             =   2640
         Width           =   2895
         Begin krotw32.ctrlNumBox txtOdoKoef 
            Height          =   285
            Left            =   1920
            TabIndex        =   44
            Top             =   240
            Width           =   855
            _ExtentX        =   1508
            _ExtentY        =   503
         End
         Begin VB.CommandButton btmDistTable 
            Caption         =   "Таблица"
            Height          =   350
            Left            =   1920
            TabIndex        =   46
            ToolTipText     =   "Настройка таблицы поправок по дистанции"
            Top             =   560
            Width           =   855
         End
         Begin VB.OptionButton optDist 
            Caption         =   "Таблица поправок"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   45
            Top             =   600
            Width           =   2175
         End
         Begin VB.OptionButton optDist 
            Caption         =   "Коэф-нт одометра"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   43
            Top             =   240
            Width           =   2175
         End
      End
      Begin krotw32.multyNum speedVector 
         Height          =   255
         Left            =   1320
         TabIndex        =   55
         Top             =   720
         Width           =   1380
         _ExtentX        =   2434
         _ExtentY        =   450
      End
      Begin VB.Label labDriver 
         Caption         =   "Driver description"
         Height          =   375
         Left            =   240
         TabIndex        =   39
         ToolTipText     =   "Название драйвера записи"
         Top             =   1200
         Width           =   2535
      End
      Begin VB.Label Label1 
         Caption         =   "Диаметр трубы, мм"
         Height          =   255
         Index           =   6
         Left            =   120
         TabIndex        =   38
         Top             =   3720
         Width           =   1695
      End
      Begin VB.Label Label1 
         Caption         =   "Отметка начала, мм"
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   37
         Top             =   3960
         Width           =   1695
      End
      Begin VB.Label Label1 
         Caption         =   "Бланк деф-та"
         Height          =   255
         Index           =   3
         Left            =   240
         TabIndex        =   36
         Top             =   2400
         Width           =   1095
      End
      Begin VB.Label Label1 
         Caption         =   "Обьекты"
         Height          =   255
         Index           =   2
         Left            =   240
         TabIndex        =   35
         Top             =   2160
         Width           =   1095
      End
      Begin VB.Label Label1 
         Caption         =   "Наименование записи"
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   34
         Top             =   1560
         Width           =   2535
      End
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   4440
      TabIndex        =   12
      Top             =   4800
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   2880
      TabIndex        =   11
      Top             =   4800
      Width           =   1215
   End
End
Attribute VB_Name = "frmSetting"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const MAX_ORIENT_SENS = 8
Private Const MAX_OTHER_SENS = 4
Private Const MAX_EXTEND_SENS = 100
Private Const CHECKBOX_SHIFT = 10

Private ret As Boolean
Private d_distMode As Integer
Private frm As frmTrace
Private hlp As New clsHelp
Private XYScaleMode As Integer

Public Function Edit(prnt As frmTrace) As Boolean
Set frm = prnt
Load Me
hlp.BindHelp Me, KRT_AnaControls
setControls
ret = False
centerForm frmMain, Me
Me.Show 1, frmMain
Edit = ret
End Function

Private Function isUserOrigin() As Boolean
If frm.trc.vog.enable Then
 isUserOrigin = True ' здесь анализ формата вога
 Else
 isUserOrigin = False
End If
End Function

Private Sub setControls()
Dim i As Integer, cnt As Integer, vsb As Boolean
Dim scroll_size As Long

XYScaleMode = GetScaleMode
rbtnScaleMode(XYScaleMode).Value = True

mainSens.visible = (frm.trc.Coroz.num > 0)
mainSens.Value = IIf(frm.trc.Coroz.visible, 1, 0)

vsb = frm.trc.speed.num > 0
speed.visible = vsb
speedVector.Min = SV_MIN
speedVector.Max = SV_MAX
speedVector.visible = vsb

speed.Value = IIf(frm.trc.speed.visible, 1, 0)
speedVector.Value = frm.trc.speedVector

vog.visible = frm.trc.vog.enable
vog.Value = IIf(frm.trc.vog.visible, 1, 0)

labDriver.Caption = frm.trc.drv.name
txtName.Text = frm.trc.Description
txtMdb.Text = frm.trc.db.Mdb
txtRpt.Text = frm.trc.rptFile

If frm.trc.db.enable Then
 
 frameDist.visible = True
 d_distMode = frm.trc.distMode
 optDist(d_distMode).Value = True
 txtOdoKoef.dbl = frm.trc.odoKoef
 txtOdoStart.Text = frm.trc.odoStart
 
 frameDist.enabled = Not (frm.trc.db.isRO)
 txtOdoKoef.enabled = Not (frm.trc.db.isRO)
 txtOdoStart.enabled = Not (frm.trc.db.isRO)
 
 Else
 frameDist.visible = False
End If

txtDiam.Text = frm.trc.pigDiam
chkObjNewEdit.Value = IIf(frm.trc.objNewEdit, 1, 0)

If frm.trc.vog.enable Then

 frmCurveMode.visible = True
 i = IIf(frm.trc.isCurveGraphRadius, 1, 0)
 crvMode(i).Value = True
 txtCurveLength.Text = frm.trc.vog.curveLength
 
 frmPigGeometry.visible = True
 txtPigL0.Text = frm.trc.pigL0
 txtPigL1.Text = frm.trc.pigL1
 txtPigL3.Text = frm.trc.pigL3
 
 Else
 
 frmCurveMode.visible = False
 frmPigGeometry.visible = False
 
End If

i = IIf(frm.trc.Coroz.tesla, 1, 0)
crzTesla(i).Value = True

setOtherSens frm.trc.ornt, orient, picOrient, MAX_ORIENT_SENS
setOtherSens frm.trc.Timer, timeSens, picTimeSens, MAX_OTHER_SENS
setOtherSens frm.trc.odo, odo, picOdo, MAX_OTHER_SENS
setOtherSens frm.trc.shake, shake, picShake, MAX_OTHER_SENS
setOtherSens frm.trc.press, press, picPress, MAX_OTHER_SENS
setOtherSens frm.trc.temp, temperature, picTemp, MAX_OTHER_SENS
setOtherSens frm.trc.angle, angle, picAngle, MAX_OTHER_SENS
setOtherSens frm.trc.curve, curve, picCurve, MAX_OTHER_SENS
setOtherSens frm.trc.thick, thick, picThick, MAX_OTHER_SENS

azimut.visible = False
tangazh.visible = False
If frm.trc.vog.enable Then
 If isSensAvail(frm.trc, SENS_AZIMUTH) Then
   azimut.visible = True
   azimut.Value = IIf(frm.trc.azimuth.visible, 1, 0)
 End If
 If isSensAvail(frm.trc, SENS_TANGAZH) Then
   tangazh.visible = True
   tangazh.Value = IIf(frm.trc.tangazh.visible, 1, 0)
 End If
End If

If frm.trc.numExt > 0 Then
 extended(0).Value = IIf(frm.trc.sensExt(0).visible, 1, 0)
 extended(0).Caption = frm.trc.sensExt(0).name
 For i = 1 To frm.trc.numExt - 1
  If i > MAX_EXTEND_SENS Then Exit For
  Load extended(i)
  extended(i).Top = extended(i - 1).Top + extended(i - 1).Height + CHECKBOX_SHIFT
  extended(i).Caption = frm.trc.sensExt(i).name
  extended(i).visible = True
  extended(i).Value = IIf(frm.trc.sensExt(i).visible, 1, 0)
 Next i
 Frame1.Height = Frame1.Height + i * (extended(0).Height + CHECKBOX_SHIFT)
 scroll_size = Frame1.Height - Frame5.Height
 If scroll_size > 0 Then
  scroll.Max = scroll_size
  scroll.LargeChange = Frame5.Height
  scroll.SmallChange = 50
  scroll.visible = True
 End If
 Else
 extended(0).visible = False
End If

'датчики углов
'setOtherSens frm.trc.vogdata, vogdata, picAngle, MAX_OTHER_SENS
'If frm.trc.vog.enable Then
 
' Else
'  vogdata(0).visible = False
'End If
End Sub

Private Sub setOtherSens( _
sens As clsSensor, _
ByRef chk As Variant, _
ByRef pic As Variant, _
ByVal maxSens As Integer _
)
Dim i As Integer

If sens.num > 0 Then
 chk(0).Value = IIf(sens.line(0).visible, 1, 0)
 chk(0).Caption = sens.line(0).Caption
 If sens.num > 1 Then
  For i = 1 To sens.num - 1
   If i > maxSens Then Exit For
   Load chk(i)
   Load pic(i)
   chk(i).Top = chk(i - 1).Top + chk(i - 1).Height + CHECKBOX_SHIFT
   pic(i).Top = chk(i).Top
   chk(i).Caption = sens.line(i).Caption
   pic(i).BackColor = color.clrIndx(i)
   chk(i).visible = True
   pic(i).visible = True
   chk(i).Value = IIf(sens.line(i).visible, 1, 0)
  Next i
 End If
 Else
 chk(0).visible = False
 pic(0).visible = False
End If
End Sub

Private Sub getOtherSens( _
sens As clsSensor, _
ByRef chk As Variant _
)
Dim i As Integer, j As Integer, s As clsSensorLine

If sens.num > 0 Then
 Set s = sens.line(0)
 s.visible = chk(0).Value
 If sens.num > 1 Then
  j = sens.num
  For i = 1 To j - 1
   Set s = sens.line(i)
   s.visible = chk(i).Value
  Next i
 End If
End If
End Sub

Private Sub readControls()
Dim i As Integer, cnt As Integer, s As clsSensorLine
Dim oldBool As Boolean

frm.trc.Coroz.visible = mainSens.Value
frm.trc.vog.visible = vog.Value

frm.trc.Description = txtName.Text
frm.trc.db.Mdb = txtMdb.Text
frm.trc.rptFile = txtRpt.Text

If frm.trc.db.enable Then
 frm.trc.distMode = d_distMode
 frm.trc.odoKoef = txtOdoKoef.dbl
 frm.trc.odoStart = val(txtOdoStart.Text)
End If

frm.trc.pigDiam = txtDiam.Text
frm.trc.objNewEdit = IIf(chkObjNewEdit.Value = 1, True, False)

If frm.trc.vog.enable Then
 frm.trc.isCurveGraphRadius = crvMode(1).Value
 frm.trc.vog.curveLength = IIf(Len(txtCurveLength.Text) = 0, 10, val(txtCurveLength.Text))
 frm.trc.pigL0 = txtPigL0.Text
 frm.trc.pigL1 = txtPigL1.Text
 frm.trc.pigL3 = txtPigL3.Text
End If

frm.trc.Coroz.tesla = crzTesla(1).Value

If frm.trc.speed.num > 0 Then
 Set s = frm.trc.speed.line(0)
 s.visible = speed.Value
 frm.trc.speedVector = speedVector.Value
End If

getOtherSens frm.trc.ornt, orient
getOtherSens frm.trc.Timer, timeSens
getOtherSens frm.trc.odo, odo
getOtherSens frm.trc.shake, shake
getOtherSens frm.trc.press, press
getOtherSens frm.trc.temp, temperature
getOtherSens frm.trc.angle, angle
getOtherSens frm.trc.curve, curve
getOtherSens frm.trc.thick, thick

Dim l As clsSensorLine
If azimut.visible Then
 Set l = frm.trc.azimuth.line(0)
 l.visible = azimut.Value
End If
If tangazh.visible Then
 Set l = frm.trc.tangazh.line(0)
 l.visible = tangazh.Value
End If

For i = 0 To frm.trc.numExt - 1
 Dim ln As clsSensorLine
 Set ln = frm.trc.sensExt(i).line(0)
 ln.visible = extended(i).Value  ' .graph.visible ' .sens.line(0)
 's.visible = extended(i).Value
Next i
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0
 readControls
 ret = True
 SetScaleMode XYScaleMode
End Select
Unload Me
End Sub

Private Sub btmDistTable_Click()
frmDistKoef.Edit Me, frm.trc
End Sub

Private Sub btmMdb_Click()
ogdWin.fileOpen _
 "Выберите файл базы обьектов", _
 txtMdb.Text, _
 cfg.dir.trc, _
 "Файлы обьектов (*.mdb)|*.mdb", _
 Me.hwnd, _
 txtMdb
End Sub

Private Sub btmRpt_Click()
ogdWin.fileOpen _
 "Выберите файл шаблона", _
 txtRpt.Text, _
 cfg.dir.Rpt, _
 "Файлы шаблонов (*.dot)|*.dot", _
 Me.hwnd, _
 txtRpt
End Sub

Private Sub optDist_Click(Index As Integer)
d_distMode = Index
Select Case d_distMode
 Case 0 'коэф-нт одометра
  txtOdoKoef.enabled = True
  btmDistTable.enabled = False
 Case 1 'таблица поправок
  txtOdoKoef.enabled = False
  btmDistTable.enabled = True
End Select
End Sub

Private Sub rbtnScaleMode_Click(Index As Integer)
XYScaleMode = Index
End Sub

Private Sub scroll_Change()
Frame1.Top = 0 - scroll.Value
End Sub
