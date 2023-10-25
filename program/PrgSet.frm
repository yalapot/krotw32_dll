VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "TabCtl32.Ocx"
Begin VB.Form frmPrgSetting 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Настройки программы"
   ClientHeight    =   5445
   ClientLeft      =   3525
   ClientTop       =   2550
   ClientWidth     =   6840
   Icon            =   "PrgSet.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5445
   ScaleWidth      =   6840
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   2280
      TabIndex        =   48
      Top             =   4920
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   3840
      TabIndex        =   49
      Top             =   4920
      Width           =   1215
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   4695
      Left            =   120
      TabIndex        =   50
      Top             =   120
      Width           =   6615
      _ExtentX        =   11668
      _ExtentY        =   8281
      _Version        =   393216
      Tabs            =   7
      Tab             =   3
      TabsPerRow      =   4
      TabHeight       =   520
      TabCaption(0)   =   "Каталоги"
      TabPicture(0)   =   "PrgSet.frx":0442
      Tab(0).ControlEnabled=   0   'False
      Tab(0).Control(0)=   "btmRptDir"
      Tab(0).Control(1)=   "txtRptDir"
      Tab(0).Control(2)=   "txtMaxHist"
      Tab(0).Control(3)=   "txtPrm"
      Tab(0).Control(4)=   "btmPrm"
      Tab(0).Control(5)=   "txtPal"
      Tab(0).Control(6)=   "btmPal"
      Tab(0).Control(7)=   "txtTrc"
      Tab(0).Control(8)=   "btmTrc"
      Tab(0).Control(9)=   "Label1(23)"
      Tab(0).Control(10)=   "Label1(18)"
      Tab(0).Control(11)=   "Label1(2)"
      Tab(0).Control(12)=   "Label1(0)"
      Tab(0).Control(13)=   "Label1(1)"
      Tab(0).ControlCount=   14
      TabCaption(1)   =   "Обьекты"
      TabPicture(1)   =   "PrgSet.frx":045E
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "btmRpt"
      Tab(1).Control(1)=   "txtRpt"
      Tab(1).Control(2)=   "btmMdb"
      Tab(1).Control(3)=   "txtWeldDist"
      Tab(1).Control(4)=   "txtLogMdb"
      Tab(1).Control(5)=   "btmLogMdb"
      Tab(1).Control(6)=   "logFlag"
      Tab(1).Control(7)=   "txtMaxObj"
      Tab(1).Control(8)=   "objLineFlag"
      Tab(1).Control(9)=   "Frame1"
      Tab(1).Control(10)=   "txtMdb"
      Tab(1).Control(11)=   "Label1(24)"
      Tab(1).Control(12)=   "Label1(22)"
      Tab(1).Control(13)=   "Label1(4)"
      Tab(1).Control(14)=   "Label1(3)"
      Tab(1).ControlCount=   15
      TabCaption(2)   =   "VOG"
      TabPicture(2)   =   "PrgSet.frx":047A
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "txtVturn"
      Tab(2).Control(1)=   "txtHturn"
      Tab(2).Control(2)=   "tuneEnd"
      Tab(2).Control(3)=   "tuneStart"
      Tab(2).Control(4)=   "Frame5"
      Tab(2).Control(5)=   "txtAngle"
      Tab(2).Control(6)=   "Frame3"
      Tab(2).Control(7)=   "Frame2"
      Tab(2).Control(8)=   "vogNodeMax"
      Tab(2).Control(9)=   "calcZX"
      Tab(2).Control(10)=   "txtLogVog"
      Tab(2).Control(11)=   "btmLogVog"
      Tab(2).Control(12)=   "logFlagVog"
      Tab(2).Control(13)=   "Label1(26)"
      Tab(2).Control(14)=   "Label1(25)"
      Tab(2).Control(15)=   "Label1(19)"
      Tab(2).Control(16)=   "Label1(5)"
      Tab(2).ControlCount=   17
      TabCaption(3)   =   "Общие"
      TabPicture(3)   =   "PrgSet.frx":0496
      Tab(3).ControlEnabled=   -1  'True
      Tab(3).Control(0)=   "Label1(16)"
      Tab(3).Control(0).Enabled=   0   'False
      Tab(3).Control(1)=   "txtTimer"
      Tab(3).Control(1).Enabled=   0   'False
      Tab(3).Control(2)=   "Frame4"
      Tab(3).Control(2).Enabled=   0   'False
      Tab(3).Control(3)=   "Frame7"
      Tab(3).Control(3).Enabled=   0   'False
      Tab(3).Control(4)=   "chkOnline"
      Tab(3).Control(4).Enabled=   0   'False
      Tab(3).Control(5)=   "Frame8"
      Tab(3).Control(5).Enabled=   0   'False
      Tab(3).Control(6)=   "Frame9"
      Tab(3).Control(6).Enabled=   0   'False
      Tab(3).Control(7)=   "chkSyncJump"
      Tab(3).Control(7).Enabled=   0   'False
      Tab(3).Control(8)=   "chkZoomType"
      Tab(3).Control(8).Enabled=   0   'False
      Tab(3).ControlCount=   9
      TabCaption(4)   =   "Драйвера"
      TabPicture(4)   =   "PrgSet.frx":04B2
      Tab(4).ControlEnabled=   0   'False
      Tab(4).Control(0)=   "btmDrvSave"
      Tab(4).Control(1)=   "btmDrvDel"
      Tab(4).Control(2)=   "lstDrv"
      Tab(4).Control(3)=   "btmDrvAdd"
      Tab(4).Control(4)=   "btmDrvEdt"
      Tab(4).ControlCount=   5
      TabCaption(5)   =   "Коррозионник"
      TabPicture(5)   =   "PrgSet.frx":04CE
      Tab(5).ControlEnabled=   0   'False
      Tab(5).Control(0)=   "chkDrag"
      Tab(5).Control(1)=   "Frame6"
      Tab(5).Control(2)=   "markSlit"
      Tab(5).Control(3)=   "crzChannel"
      Tab(5).Control(4)=   "crzZoomNoShift"
      Tab(5).Control(5)=   "crzZoomSync"
      Tab(5).Control(6)=   "btmPalDflt"
      Tab(5).Control(7)=   "txtPalDflt"
      Tab(5).Control(8)=   "crzClickObj"
      Tab(5).Control(9)=   "sclY"
      Tab(5).Control(10)=   "sclX"
      Tab(5).Control(11)=   "Label2"
      Tab(5).Control(12)=   "Label1(20)"
      Tab(5).ControlCount=   13
      TabCaption(6)   =   "Магниты"
      TabPicture(6)   =   "PrgSet.frx":04EA
      Tab(6).ControlEnabled=   0   'False
      Tab(6).Control(0)=   "btmMagnSave"
      Tab(6).Control(1)=   "btmMagnEdt"
      Tab(6).Control(2)=   "btmMagnAdd"
      Tab(6).Control(3)=   "lstMagn"
      Tab(6).Control(4)=   "btmMagnDel"
      Tab(6).ControlCount=   5
      Begin VB.CheckBox chkZoomType 
         Caption         =   "Запоминать тип дефекта в линзе"
         Height          =   255
         Left            =   3120
         TabIndex        =   123
         Top             =   1320
         Width           =   3135
      End
      Begin VB.CheckBox chkSyncJump 
         Caption         =   "Синхронный переход на отметку"
         Height          =   255
         Left            =   3120
         TabIndex        =   122
         Top             =   1080
         Width           =   3135
      End
      Begin VB.Frame Frame9 
         Caption         =   "Вставка объектов из линзы"
         Height          =   1095
         Left            =   3240
         TabIndex        =   118
         Top             =   1860
         Width           =   3135
         Begin VB.OptionButton zoomInsert 
            Caption         =   "правой кнопкой мыши"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   120
            ToolTipText     =   "Режимы записи настроек при завершении сеанса работы с прогоном"
            Top             =   480
            Width           =   2775
         End
         Begin VB.OptionButton zoomInsert 
            Caption         =   "средней кнопкой мыши"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   119
            ToolTipText     =   "Режимы записи настроек при завершении сеанса работы с прогоном"
            Top             =   240
            Width           =   2775
         End
      End
      Begin VB.CommandButton btmDrvSave 
         Caption         =   "Сохранить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   117
         Top             =   3600
         Width           =   1095
      End
      Begin VB.CommandButton btmMagnSave 
         Caption         =   "Сохранить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   116
         Top             =   3720
         Width           =   1095
      End
      Begin VB.CommandButton btmMagnEdt 
         Caption         =   "Изменить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   115
         Top             =   1440
         Width           =   1095
      End
      Begin VB.CommandButton btmMagnAdd 
         Caption         =   "Добавить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   114
         Top             =   960
         Width           =   1095
      End
      Begin VB.ListBox lstMagn 
         Height          =   3180
         Left            =   -74880
         TabIndex        =   113
         Top             =   960
         Width           =   4935
      End
      Begin VB.CommandButton btmMagnDel 
         Caption         =   "Удалить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   112
         Top             =   1920
         Width           =   1095
      End
      Begin VB.Frame Frame8 
         Caption         =   "Цвет маркеров"
         Height          =   1215
         Left            =   3960
         TabIndex        =   107
         Top             =   3060
         Width           =   2415
         Begin VB.Label markColor 
            BackColor       =   &H80000007&
            BorderStyle     =   1  'Fixed Single
            Height          =   255
            Index           =   1
            Left            =   1560
            TabIndex        =   111
            Top             =   600
            Width           =   615
         End
         Begin VB.Label markColor 
            BackColor       =   &H8000000E&
            BorderStyle     =   1  'Fixed Single
            Height          =   255
            Index           =   0
            Left            =   1560
            TabIndex        =   110
            Top             =   240
            Width           =   615
         End
         Begin VB.Label Label3 
            Caption         =   "второй"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   109
            Top             =   600
            Width           =   1215
         End
         Begin VB.Label Label3 
            Caption         =   "первый"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   108
            Top             =   240
            Width           =   1215
         End
      End
      Begin VB.CheckBox chkDrag 
         Caption         =   "Перетаскивание развертки"
         Height          =   255
         Left            =   -74880
         TabIndex        =   106
         ToolTipText     =   "Перетаскивать развертку при помощи мыши."
         Top             =   1500
         Width           =   2655
      End
      Begin VB.CheckBox chkOnline 
         Caption         =   "Подлистывание при новых данных"
         Height          =   255
         Left            =   3120
         TabIndex        =   105
         Top             =   840
         Width           =   3135
      End
      Begin VB.Frame Frame7 
         Caption         =   "Экспресс-анализ"
         Height          =   1215
         Left            =   120
         TabIndex        =   101
         Top             =   3060
         Width           =   3735
         Begin VB.CheckBox chkExpressOnOpen 
            Caption         =   "график скорости при открытии"
            Height          =   255
            Left            =   120
            TabIndex        =   104
            Top             =   240
            Width           =   2775
         End
         Begin VB.ComboBox lstLang 
            Height          =   315
            Left            =   120
            Style           =   2  'Dropdown List
            TabIndex        =   102
            Top             =   600
            Width           =   1335
         End
         Begin VB.Label Label1 
            Caption         =   "Язык документов"
            Height          =   255
            Index           =   27
            Left            =   1560
            TabIndex        =   103
            Top             =   600
            Width           =   1455
         End
      End
      Begin VB.Frame Frame6 
         Caption         =   "Колесо мыши"
         Height          =   1245
         Left            =   -71640
         TabIndex        =   97
         Top             =   1020
         Width           =   2775
         Begin VB.OptionButton optWeel 
            Caption         =   "главное окно"
            Height          =   240
            Index           =   3
            Left            =   120
            TabIndex        =   121
            Top             =   960
            Width           =   2535
         End
         Begin VB.OptionButton optWeel 
            Caption         =   "вертикальная прокрутка"
            Height          =   240
            Index           =   2
            Left            =   120
            TabIndex        =   100
            Top             =   720
            Width           =   2535
         End
         Begin VB.OptionButton optWeel 
            Caption         =   "не используется"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   99
            Top             =   240
            Width           =   2535
         End
         Begin VB.OptionButton optWeel 
            Caption         =   "горизонтальная прокрутка"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   98
            Top             =   480
            Width           =   2535
         End
      End
      Begin VB.TextBox txtVturn 
         Height          =   285
         Left            =   -72720
         TabIndex        =   96
         Text            =   "Text1"
         ToolTipText     =   "Проставлять флажок вертикального поворота, если угол в вертикальной плоскости больше или равен указанного значения"
         Top             =   2580
         Width           =   735
      End
      Begin VB.TextBox txtHturn 
         Height          =   285
         Left            =   -72720
         TabIndex        =   95
         Text            =   "Text1"
         ToolTipText     =   "Проставлять флажок горизонтального поворота, если угол в горизонтальной плоскости больше или равен указанного значения"
         Top             =   2340
         Width           =   735
      End
      Begin krotw32.multyNum markSlit 
         Height          =   255
         Left            =   -73080
         TabIndex        =   92
         ToolTipText     =   "Толщина стрелок-маркеров на швах"
         Top             =   1980
         Width           =   1380
         _ExtentX        =   2514
         _ExtentY        =   450
      End
      Begin VB.CheckBox crzChannel 
         Caption         =   "Каналы вместо датчиков"
         Height          =   255
         Left            =   -71640
         TabIndex        =   90
         ToolTipText     =   "Отображать на графике одного корозионного датчика параметры определения глубины дефекта в лупе"
         Top             =   720
         Width           =   2655
      End
      Begin VB.CheckBox crzZoomNoShift 
         Caption         =   "Линза без Shift"
         Height          =   255
         Left            =   -74880
         TabIndex        =   89
         ToolTipText     =   "Зуммирование начинается при нажатии на левую кнопку мыши без нажатой клавиши Shift"
         Top             =   1260
         Width           =   2655
      End
      Begin VB.CheckBox tuneEnd 
         Caption         =   "Поправка конца поворота"
         Height          =   255
         Left            =   -74880
         TabIndex        =   88
         ToolTipText     =   "Значение поправки конца поворота по умолчанию"
         Top             =   1980
         Width           =   3135
      End
      Begin VB.CheckBox tuneStart 
         Caption         =   "Поправка начала поворота"
         Height          =   255
         Left            =   -74880
         TabIndex        =   87
         ToolTipText     =   "Значение поправки начала поворота по умолчанию"
         Top             =   1740
         Width           =   3135
      End
      Begin VB.CommandButton btmRpt 
         Caption         =   "..."
         Height          =   255
         Left            =   -73560
         TabIndex        =   85
         ToolTipText     =   "Выбор файла шаблона бланка дефекта"
         Top             =   1620
         Width           =   615
      End
      Begin VB.TextBox txtRpt 
         Height          =   285
         Left            =   -72840
         TabIndex        =   84
         Text            =   "Text1"
         ToolTipText     =   "Имя файла шаблона бланка дефекта"
         Top             =   1620
         Width           =   4215
      End
      Begin VB.CommandButton btmMdb 
         Caption         =   "..."
         Height          =   255
         Left            =   -73560
         TabIndex        =   8
         ToolTipText     =   "Выбор файла прототипа базы обьектов"
         Top             =   1380
         Width           =   615
      End
      Begin VB.CommandButton btmRptDir 
         Caption         =   "..."
         Height          =   255
         Left            =   -73560
         TabIndex        =   82
         ToolTipText     =   "Выбор каталога для файлов шаблонов бланка дефекта"
         Top             =   1860
         Width           =   615
      End
      Begin VB.TextBox txtRptDir 
         Height          =   285
         Left            =   -72840
         TabIndex        =   81
         Text            =   "Text1"
         ToolTipText     =   "Каталог по умолчанию для файлов шаблонов бланка дефекта"
         Top             =   1860
         Width           =   4215
      End
      Begin VB.CheckBox crzZoomSync 
         Caption         =   "Синхронизация лупы и графика"
         Height          =   255
         Left            =   -74880
         TabIndex        =   80
         ToolTipText     =   "Отображать на графике одного корозионного датчика параметры определения глубины дефекта в лупе"
         Top             =   1020
         Width           =   2775
      End
      Begin VB.TextBox txtWeldDist 
         Height          =   285
         Left            =   -69360
         TabIndex        =   78
         Text            =   "Text1"
         ToolTipText     =   "При установке швов нельзя поставить их друг к другу ближе этого расстояния"
         Top             =   2820
         Width           =   735
      End
      Begin VB.Frame Frame5 
         Caption         =   "Линия между маркерами"
         Height          =   975
         Left            =   -71640
         TabIndex        =   75
         Top             =   1980
         Width           =   3015
         Begin VB.PictureBox picVogMrkColor 
            Height          =   255
            Left            =   2160
            ScaleHeight     =   195
            ScaleWidth      =   675
            TabIndex        =   77
            ToolTipText     =   "Цвет линии между маркерами"
            Top             =   600
            Width           =   735
         End
         Begin VB.CommandButton btmVogMrkColor 
            Caption         =   "Цвет"
            Height          =   375
            Left            =   120
            TabIndex        =   24
            ToolTipText     =   "Выбор цвета линии между маркерами"
            Top             =   480
            Width           =   975
         End
         Begin VB.TextBox txtVogMrkWidth 
            Height          =   285
            Left            =   2160
            TabIndex        =   23
            Text            =   "Text1"
            ToolTipText     =   "Толщина линии между маркерами в пикселах"
            Top             =   240
            Width           =   735
         End
         Begin VB.Label Label1 
            Caption         =   "Толщина"
            Height          =   255
            Index           =   21
            Left            =   120
            TabIndex        =   76
            Top             =   240
            Width           =   975
         End
      End
      Begin VB.CommandButton btmPalDflt 
         Caption         =   "..."
         Height          =   255
         Left            =   -73560
         TabIndex        =   44
         ToolTipText     =   "Выбор файла палитры по умолчанию"
         Top             =   2340
         Width           =   615
      End
      Begin VB.TextBox txtPalDflt 
         Height          =   285
         Left            =   -72840
         TabIndex        =   45
         Text            =   "Text1"
         ToolTipText     =   "Имя файла палитры по умолчанию"
         Top             =   2340
         Width           =   4215
      End
      Begin VB.CheckBox crzClickObj 
         Caption         =   "Вставка обьектов при клике"
         Height          =   255
         Left            =   -74880
         TabIndex        =   43
         ToolTipText     =   "Включить вставку обьектов при клике на корозионной развертке"
         Top             =   780
         Width           =   2655
      End
      Begin VB.CommandButton btmDrvDel 
         Caption         =   "Удалить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   42
         Top             =   1860
         Width           =   1095
      End
      Begin VB.TextBox txtAngle 
         Height          =   285
         Left            =   -69360
         TabIndex        =   21
         Text            =   "Text1"
         ToolTipText     =   "Угол поворота изображения в окне XY"
         Top             =   1380
         Width           =   735
      End
      Begin VB.TextBox txtMaxHist 
         Height          =   285
         Left            =   -69360
         TabIndex        =   6
         Text            =   "Text1"
         ToolTipText     =   "Максимальное количество запоминаемых загрузок прогонов"
         Top             =   2340
         Width           =   735
      End
      Begin VB.ListBox lstDrv 
         Height          =   3180
         Left            =   -74880
         TabIndex        =   39
         Top             =   900
         Width           =   4935
      End
      Begin VB.CommandButton btmDrvAdd 
         Caption         =   "Добавить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   40
         Top             =   900
         Width           =   1095
      End
      Begin VB.CommandButton btmDrvEdt 
         Caption         =   "Изменить"
         Height          =   375
         Left            =   -69840
         TabIndex        =   41
         Top             =   1380
         Width           =   1095
      End
      Begin VB.Frame Frame4 
         Caption         =   "При закрытии записи настройки ..."
         Height          =   1095
         Left            =   120
         TabIndex        =   71
         Top             =   1860
         Width           =   3015
         Begin VB.OptionButton exitMode 
            Caption         =   "не сохранять"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   36
            ToolTipText     =   "Режимы записи настроек при завершении сеанса работы с прогоном"
            Top             =   240
            Width           =   2175
         End
         Begin VB.OptionButton exitMode 
            Caption         =   "спрашивать оператора"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   37
            ToolTipText     =   "Режимы записи настроек при завершении сеанса работы с прогоном"
            Top             =   480
            Width           =   2295
         End
         Begin VB.OptionButton exitMode 
            Caption         =   "сохранять автоматически"
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   38
            ToolTipText     =   "Режимы записи настроек при завершении сеанса работы с прогоном"
            Top             =   720
            Width           =   2415
         End
      End
      Begin VB.TextBox txtTimer 
         Height          =   285
         Left            =   1800
         TabIndex        =   35
         Text            =   "Text1"
         ToolTipText     =   "Производительность компьютера влияет на скорость скроллинга"
         Top             =   1020
         Width           =   735
      End
      Begin VB.Frame Frame3 
         Caption         =   "Ползунок Y-координат"
         Height          =   1695
         Left            =   -71640
         TabIndex        =   64
         Top             =   2940
         Width           =   3015
         Begin VB.TextBox yMultyMin 
            Height          =   285
            Left            =   2160
            TabIndex        =   30
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Y-координат"
            Top             =   240
            Width           =   735
         End
         Begin VB.TextBox yMultyMax 
            Height          =   285
            Left            =   2160
            TabIndex        =   31
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Y-координат"
            Top             =   480
            Width           =   735
         End
         Begin VB.TextBox yMultySmallStep 
            Height          =   285
            Left            =   2160
            TabIndex        =   32
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Y-координат"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox yMultyPageStep 
            Height          =   285
            Left            =   2160
            TabIndex        =   33
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Y-координат"
            Top             =   960
            Width           =   735
         End
         Begin VB.TextBox yMultyDflt 
            Height          =   285
            Left            =   2160
            TabIndex        =   34
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Y-координат"
            Top             =   1200
            Width           =   735
         End
         Begin VB.Label Label1 
            Caption         =   "Минимум"
            Height          =   255
            Index           =   15
            Left            =   120
            TabIndex        =   69
            Top             =   240
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "Максимум"
            Height          =   255
            Index           =   14
            Left            =   120
            TabIndex        =   68
            Top             =   480
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "Размер сдвига"
            Height          =   255
            Index           =   13
            Left            =   120
            TabIndex        =   67
            Top             =   720
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "Размер страницы"
            Height          =   255
            Index           =   12
            Left            =   120
            TabIndex        =   66
            Top             =   960
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "По умолчанию"
            Height          =   255
            Index           =   11
            Left            =   120
            TabIndex        =   65
            Top             =   1200
            Width           =   1815
         End
      End
      Begin VB.Frame Frame2 
         Caption         =   "Ползунок Z-координат"
         Height          =   1695
         Left            =   -74880
         TabIndex        =   58
         Top             =   2940
         Width           =   3015
         Begin VB.TextBox zMultyDflt 
            Height          =   285
            Left            =   2160
            TabIndex        =   29
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Z-координат"
            Top             =   1200
            Width           =   735
         End
         Begin VB.TextBox zMultyPageStep 
            Height          =   285
            Left            =   2160
            TabIndex        =   28
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Z-координат"
            Top             =   960
            Width           =   735
         End
         Begin VB.TextBox zMultySmallStep 
            Height          =   285
            Left            =   2160
            TabIndex        =   27
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Z-координат"
            Top             =   720
            Width           =   735
         End
         Begin VB.TextBox zMultyMax 
            Height          =   285
            Left            =   2160
            TabIndex        =   26
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Z-координат"
            Top             =   480
            Width           =   735
         End
         Begin VB.TextBox zMultyMin 
            Height          =   285
            Left            =   2160
            TabIndex        =   25
            Text            =   "Text1"
            ToolTipText     =   "Параметры ползунка масштабирования Z-координат"
            Top             =   240
            Width           =   735
         End
         Begin VB.Label Label1 
            Caption         =   "По умолчанию"
            Height          =   255
            Index           =   10
            Left            =   120
            TabIndex        =   63
            Top             =   1200
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "Размер страницы"
            Height          =   255
            Index           =   9
            Left            =   120
            TabIndex        =   62
            Top             =   960
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "Размер сдвига"
            Height          =   255
            Index           =   8
            Left            =   120
            TabIndex        =   61
            Top             =   720
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "Максимум"
            Height          =   255
            Index           =   7
            Left            =   120
            TabIndex        =   60
            Top             =   480
            Width           =   1815
         End
         Begin VB.Label Label1 
            Caption         =   "Минимум"
            Height          =   255
            Index           =   6
            Left            =   120
            TabIndex        =   59
            Top             =   240
            Width           =   1815
         End
      End
      Begin VB.TextBox vogNodeMax 
         Height          =   285
         Left            =   -69360
         TabIndex        =   22
         Text            =   "Text1"
         ToolTipText     =   "Если количество узлов графика VOG будет меньше этого значения, то они будут отображаться кружочками"
         Top             =   1620
         Width           =   735
      End
      Begin VB.CheckBox calcZX 
         Caption         =   "Расчет X для Z-окна"
         Height          =   255
         Left            =   -74880
         TabIndex        =   20
         ToolTipText     =   "Включить расчет действительной координаты X для записей VOG в Z-окне"
         Top             =   1380
         Width           =   2415
      End
      Begin VB.TextBox txtLogVog 
         Height          =   285
         Left            =   -74880
         TabIndex        =   18
         Text            =   "Text1"
         ToolTipText     =   "Имя файла протокола координат точек совмещаемых записей VOG"
         Top             =   1020
         Width           =   5535
      End
      Begin VB.CommandButton btmLogVog 
         Caption         =   "..."
         Height          =   255
         Left            =   -69240
         TabIndex        =   19
         ToolTipText     =   "Выбор файла протокола координат точек совмещаемых записей VOG"
         Top             =   1020
         Width           =   615
      End
      Begin VB.CheckBox logFlagVog 
         Caption         =   "Протокол отрисовки совмещенных графиков"
         Height          =   255
         Left            =   -74880
         TabIndex        =   17
         ToolTipText     =   "Включить запись в протокол координат точек совмещаемых записей VOG"
         Top             =   780
         Width           =   4935
      End
      Begin VB.TextBox txtLogMdb 
         Height          =   285
         Left            =   -74880
         TabIndex        =   11
         Text            =   "Text1"
         ToolTipText     =   "Имя файла протокола операций с базой обьектов"
         Top             =   2220
         Width           =   5535
      End
      Begin VB.CommandButton btmLogMdb 
         Caption         =   "..."
         Height          =   255
         Left            =   -69240
         TabIndex        =   12
         ToolTipText     =   "Выбор файла протокола операций с базой обьектов"
         Top             =   2220
         Width           =   615
      End
      Begin VB.CheckBox logFlag 
         Caption         =   "Протокол операций с базой"
         Height          =   255
         Left            =   -74880
         TabIndex        =   10
         ToolTipText     =   "Записывать все операции с базой данных обьектов в файл протокола"
         Top             =   1980
         Width           =   2535
      End
      Begin VB.TextBox txtMaxObj 
         Height          =   285
         Left            =   -69360
         TabIndex        =   13
         Text            =   "Text1"
         ToolTipText     =   "Сколько обьектов могут одновременно показываться в полосе расшифровки"
         Top             =   2580
         Width           =   735
      End
      Begin VB.CheckBox objLineFlag 
         Caption         =   "Полоса расшифровки"
         Height          =   255
         Left            =   -74880
         TabIndex        =   7
         ToolTipText     =   "Если полоса расшифровки отключена, то программа работает в режиме просмотра записи"
         Top             =   1020
         Width           =   2055
      End
      Begin VB.Frame Frame1 
         Caption         =   "При открытии записи таблицу труб... "
         Height          =   1095
         Left            =   -74880
         TabIndex        =   55
         Top             =   3180
         Width           =   6255
         Begin VB.OptionButton tubeCheck 
            Caption         =   "проверять автоматически"
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   16
            ToolTipText     =   "Режимы проверки целостности таблицы длин труб при открытии записи"
            Top             =   720
            Width           =   3375
         End
         Begin VB.OptionButton tubeCheck 
            Caption         =   "спрашивать оператора"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   15
            ToolTipText     =   "Режимы проверки целостности таблицы длин труб при открытии записи"
            Top             =   480
            Width           =   3255
         End
         Begin VB.OptionButton tubeCheck 
            Caption         =   "не проверять"
            Height          =   255
            Index           =   0
            Left            =   120
            TabIndex        =   14
            ToolTipText     =   "Режимы проверки целостности таблицы длин труб при открытии записи"
            Top             =   240
            Width           =   2775
         End
      End
      Begin VB.TextBox txtMdb 
         Height          =   285
         Left            =   -72840
         TabIndex        =   9
         Text            =   "Text1"
         ToolTipText     =   "Имя файла базы данных обьектов на основе которого создаются такие файлы для записей"
         Top             =   1380
         Width           =   4215
      End
      Begin VB.TextBox txtPrm 
         Height          =   285
         Left            =   -72840
         TabIndex        =   5
         Text            =   "Text1"
         ToolTipText     =   "Каталог по умолчанию для файлов первичных данных"
         Top             =   1620
         Width           =   4215
      End
      Begin VB.CommandButton btmPrm 
         Caption         =   "..."
         Height          =   255
         Left            =   -73560
         TabIndex        =   4
         ToolTipText     =   "Выбор каталога для файлов первичных данных"
         Top             =   1620
         Width           =   615
      End
      Begin VB.TextBox txtPal 
         Height          =   285
         Left            =   -72840
         TabIndex        =   3
         Text            =   "Text1"
         ToolTipText     =   "Каталог по умолчанию для файлов палитр"
         Top             =   1380
         Width           =   4215
      End
      Begin VB.CommandButton btmPal 
         Caption         =   "..."
         Height          =   255
         Left            =   -73560
         TabIndex        =   2
         ToolTipText     =   "Выбор каталога для файлов палитр"
         Top             =   1380
         Width           =   615
      End
      Begin VB.TextBox txtTrc 
         Height          =   285
         Left            =   -72840
         TabIndex        =   1
         Text            =   "Text1"
         ToolTipText     =   "Каталог по умолчанию для trc-файлов"
         Top             =   1140
         Width           =   4215
      End
      Begin VB.CommandButton btmTrc 
         Caption         =   "..."
         Height          =   255
         Left            =   -73560
         TabIndex        =   0
         ToolTipText     =   "Выбор каталога для trc-файлов"
         Top             =   1140
         Width           =   615
      End
      Begin krotw32.scaleList sclY 
         Height          =   1410
         Left            =   -71760
         TabIndex        =   47
         Top             =   2700
         Width           =   3090
         _ExtentX        =   5450
         _ExtentY        =   2487
      End
      Begin krotw32.scaleList sclX 
         Height          =   1410
         Left            =   -74880
         TabIndex        =   46
         Top             =   2700
         Width           =   3090
         _ExtentX        =   5450
         _ExtentY        =   2487
      End
      Begin VB.Label Label1 
         Caption         =   "Верт. поворот >= (град)"
         Height          =   255
         Index           =   26
         Left            =   -74880
         TabIndex        =   94
         Top             =   2580
         Width           =   2055
      End
      Begin VB.Label Label1 
         Caption         =   "Гор. поворот >= (град)"
         Height          =   255
         Index           =   25
         Left            =   -74880
         TabIndex        =   93
         Top             =   2340
         Width           =   2055
      End
      Begin VB.Label Label2 
         Caption         =   "Толщина стрелок"
         Height          =   255
         Left            =   -74880
         TabIndex        =   91
         Top             =   1980
         Width           =   1695
      End
      Begin VB.Label Label1 
         Caption         =   "Бланк деф-та"
         Height          =   255
         Index           =   24
         Left            =   -74880
         TabIndex        =   86
         Top             =   1620
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Бланки деф-тов"
         Height          =   255
         Index           =   23
         Left            =   -74880
         TabIndex        =   83
         Top             =   1860
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Минимальное расстояние между швами, см"
         Height          =   255
         Index           =   22
         Left            =   -74880
         TabIndex        =   79
         Top             =   2820
         Width           =   5295
      End
      Begin VB.Label Label1 
         Caption         =   "Палитра"
         Height          =   255
         Index           =   20
         Left            =   -74880
         TabIndex        =   74
         Top             =   2340
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Угол поворота XY"
         Height          =   255
         Index           =   19
         Left            =   -71640
         TabIndex        =   73
         Top             =   1380
         Width           =   1695
      End
      Begin VB.Label Label1 
         Caption         =   "Максимальное количество элементов в истории загрузок"
         Height          =   255
         Index           =   18
         Left            =   -74880
         TabIndex        =   72
         Top             =   2340
         Width           =   5535
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Caption         =   "Скроллинг (1-1000)"
         Height          =   255
         Index           =   16
         Left            =   120
         TabIndex        =   70
         Top             =   1020
         Width           =   1575
      End
      Begin VB.Label Label1 
         Caption         =   "Кол-во отображаемых узлов"
         Height          =   255
         Index           =   5
         Left            =   -71640
         TabIndex        =   57
         Top             =   1620
         Width           =   2295
      End
      Begin VB.Label Label1 
         Caption         =   "Максимальное кол-во одновременно показываемых обьектов"
         Height          =   255
         Index           =   4
         Left            =   -74880
         TabIndex        =   56
         Top             =   2580
         Width           =   5295
      End
      Begin VB.Label Label1 
         Caption         =   "Прототип базы"
         Height          =   255
         Index           =   3
         Left            =   -74880
         TabIndex        =   54
         Top             =   1380
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Данные"
         Height          =   255
         Index           =   2
         Left            =   -74880
         TabIndex        =   53
         Top             =   1620
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Палитры"
         Height          =   255
         Index           =   0
         Left            =   -74880
         TabIndex        =   52
         Top             =   1380
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Trc-файлы"
         Height          =   255
         Index           =   1
         Left            =   -74880
         TabIndex        =   51
         Top             =   1140
         Width           =   1335
      End
   End
End
Attribute VB_Name = "frmPrgSetting"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private ret As Boolean

Private objTubeCheck As Integer
Private prgExitMode As Integer
Private mouseWeelMode As Integer
Private zoomInsertMode As Integer
Private hlp As New clsHelp
Dim dlg As New clsCommonDialog

Dim newMagnet As clsMagnit

Public Function Edit() As Boolean
setWait "Загрузка..."
Load Me
hlp.BindHelp Me, KRT_Cfg
setControls
ret = False
centerForm frmMain, Me
setReady
Me.Show 1, frmMain
Edit = ret
End Function

Private Sub setControls()
Dim s As String

cfg.initMagnets
cfg.initDrivers

With lstLang
 .addItem cfg.lngExpress.strRUS
 .ItemData(.ListCount - 1) = EXP_LANG_RU
 .addItem cfg.lngExpress.strENG
 .ItemData(.ListCount - 1) = EXP_LANG_EN
 setLst lstLang, cfg.lngExpress.lang
End With

txtTrc.Text = cfg.dir.trc
txtPal.Text = cfg.dir.Pal
txtPrm.Text = cfg.dir.Prim
txtRptDir.Text = cfg.dir.Rpt
txtMaxHist.Text = cfg.fileHist.capacity

objLineFlag.Value = IIf(cfg.obj.dbLine, 1, 0)
txtMdb.Text = cfg.dir.dbTemplete
txtRpt.Text = cfg.dir.ReportFile

txtLogMdb.Text = cfg.obj.sqlLog
logFlag.Value = IIf((txtLogMdb.Text = ""), 0, 1)
logFlag_Click

txtMaxObj.Text = cfg.obj.maxNum
txtWeldDist.Text = cfg.obj.weldDist

objTubeCheck = cfg.obj.tubeCheck
tubeCheck(objTubeCheck).Value = True

txtLogVog.Text = cfg.vog.logFile
logFlagVog.Value = IIf((txtLogVog.Text = ""), 0, 1)
logFlagVog_Click

calcZX.Value = IIf(cfg.vog.calcXZ, 1, 0)
tuneStart.Value = IIf(cfg.vog.tuneStart, 1, 0)
tuneEnd.Value = IIf(cfg.vog.tuneEnd, 1, 0)
vogNodeMax.Text = cfg.vog.maxNode
txtAngle.Text = cfg.vog.rotAngle
txtHturn.Text = cfg.vog.turnHor
txtVturn.Text = cfg.vog.turnVer
txtVogMrkWidth.Text = cfg.vog.markWidth
picVogMrkColor.BackColor = cfg.vog.markColor

zMultyMin.Text = cfg.vog.sldZ.Min
zMultyMax.Text = cfg.vog.sldZ.Max
zMultySmallStep.Text = cfg.vog.sldZ.Shift
zMultyPageStep.Text = cfg.vog.sldZ.page
zMultyDflt.Text = cfg.vog.sldZ.dflt

yMultyMin.Text = cfg.vog.sldY.Min
yMultyMax.Text = cfg.vog.sldY.Max
yMultySmallStep.Text = cfg.vog.sldY.Shift
yMultyPageStep.Text = cfg.vog.sldY.page
yMultyDflt.Text = cfg.vog.sldY.dflt

txtTimer.Text = cfg.crz.PCperf
crzClickObj.Value = IIf(cfg.crz.objIns, 1, 0)
crzZoomSync.Value = IIf(cfg.crz.zoomSync, 1, 0)
crzZoomNoShift.Value = IIf(cfg.crz.zoomNoShift, 1, 0)
chkDrag.Value = IIf(cfg.crz.corozDrag, 1, 0)
crzChannel.Value = IIf(cfg.crz.channel, 1, 0)
chkSyncJump.Value = IIf(cfg.syncJump, 1, 0)
chkZoomType.Value = IIf(cfg.zoomTypeSave, 1, 0)

mouseWeelMode = cfg.mouseWeelMode
optWeel(mouseWeelMode).Value = True
zoomInsertMode = cfg.zoomInsertMode
zoomInsert(zoomInsertMode).Value = True

markSlit.Max = 5
markSlit.Min = 1
markSlit.SmallChange = 1
markSlit.LargeChange = 1
markSlit.Value = cfg.crz.slitWidth

prgExitMode = cfg.exitMode
exitMode(prgExitMode).Value = True
chkExpressOnOpen.Value = IIf(cfg.expressOnOpen, 1, 0)
chkOnline.Value = IIf(cfg.isOnLine, 1, 0)
markColor(0).BackColor = color.markWhite
markColor(1).BackColor = color.markBlack

sclx.Caption = "Масштабы развертки по X"
scly.Caption = "Масштабы развертки по Y"

sclx.sclString = cfg.crz.scaleXmnu
scly.sclString = cfg.crz.scaleYmnu

sclx.dfltScale = cfg.crz.scaleXdflt
scly.dfltScale = cfg.crz.scaleYdflt

txtPalDflt.Text = cfg.crz.dfltPal

restoreDrvList
restoreMagnList

End Sub

Private Function readControls() As Boolean

readControls = False

cfg.lngExpress.lang = lstLang.ItemData(lstLang.ListIndex)
cfg.dir.trc = txtTrc.Text
cfg.dir.Pal = txtPal.Text
cfg.dir.Prim = txtPrm.Text
cfg.dir.Rpt = txtRptDir.Text

cfg.fileHist.capacity = txtMaxHist.Text

cfg.obj.dbLine = IIf((objLineFlag.Value = 1), True, False)
cfg.dir.dbTemplete = txtMdb.Text
cfg.dir.ReportFile = txtRpt.Text
cfg.obj.sqlLog = IIf((logFlag.Value = 1), txtLogMdb.Text, "")

cfg.obj.maxNum = val(txtMaxObj.Text)
cfg.obj.tubeCheck = objTubeCheck
cfg.obj.weldDist = txtWeldDist.Text

With cfg.vog
.logFile = IIf((logFlagVog.Value = 1), txtLogVog.Text, "")
.calcXZ = IIf((calcZX.Value = 1), True, False)
.tuneStart = IIf((tuneStart.Value = 1), True, False)
.tuneEnd = IIf((tuneEnd.Value = 1), True, False)
.maxNode = vogNodeMax.Text
.rotAngle = txtAngle.Text
.turnHor = txtHturn.Text
.turnVer = txtVturn.Text

.markWidth = txtVogMrkWidth.Text
.markColor = picVogMrkColor.BackColor

.sldZ.Min = zMultyMin.Text
.sldZ.Max = zMultyMax.Text
.sldZ.Shift = zMultySmallStep.Text
.sldZ.page = zMultyPageStep.Text
.sldZ.dflt = zMultyDflt.Text

.sldY.Min = yMultyMin.Text
.sldY.Max = yMultyMax.Text
.sldY.Shift = yMultySmallStep.Text
.sldY.page = yMultyPageStep.Text
.sldY.dflt = yMultyDflt.Text
End With

cfg.crz.PCperf = txtTimer.Text
cfg.crz.objIns = IIf((crzClickObj.Value = 0), False, True)
cfg.crz.zoomSync = IIf((crzZoomSync.Value = 0), False, True)
cfg.crz.zoomNoShift = IIf((crzZoomNoShift.Value = 0), False, True)
cfg.crz.corozDrag = IIf(chkDrag.Value = 0, False, True)
cfg.crz.channel = IIf(crzChannel.Value = 0, False, True)
cfg.crz.slitWidth = markSlit.Value

cfg.zoomTypeSave = IIf(chkZoomType.Value = 1, True, False)
cfg.syncJump = IIf(chkSyncJump.Value = 1, True, False)
cfg.mouseWeelMode = mouseWeelMode
cfg.zoomInsertMode = zoomInsertMode
cfg.exitMode = prgExitMode
cfg.expressOnOpen = IIf((chkExpressOnOpen.Value = 1), True, False)
cfg.isOnLine = IIf((chkOnline.Value = 1), True, False)
color.markWhite = markColor(0).BackColor
color.markBlack = markColor(1).BackColor

cfg.crz.scaleXmnu = sclx.sclString
cfg.crz.scaleYmnu = scly.sclString

cfg.crz.scaleXdflt = sclx.dfltScale
cfg.crz.scaleYdflt = scly.dfltScale

cfg.crz.dfltPal = txtPalDflt.Text

readControls = True
End Function

Private Sub tuneMagnList(ByVal dflt_index As Integer)
If lstMagn.ListCount > 0 Then
  btmMagnEdt.enabled = True
  btmMagnDel.enabled = True
  lstMagn.ListIndex = dflt_index
  Else
  btmMagnEdt.enabled = False
  btmMagnDel.enabled = False
End If
End Sub

Private Sub restoreMagnList()
Dim m As clsMagnit

For Each m In cfg.Magnets
 lstMagn.addItem m.Description
 lstMagn.ItemData(lstMagn.ListCount - 1) = m.idNum
Next
tuneMagnList 0
End Sub

Private Sub restoreDrvList()
Dim c As clsDriver

For Each c In cfg.Drivers
 lstDrv.addItem c.name
 lstDrv.ItemData(lstDrv.ListCount - 1) = c.idNum
Next

btmDrvDel.enabled = False
btmDrvEdt.enabled = False
btmDrvSave.enabled = False
If lstDrv.ListCount > 0 Then
  lstDrv.ListIndex = 0
  btmDrvEdt.enabled = True
  btmDrvSave.enabled = True
  If lstDrv.ListCount > 1 Then btmDrvDel.enabled = True
End If
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0 ' да
  If readControls() = False Then Exit Sub
  ret = True
 Case 1 ' отказ
End Select
Unload Me
End Sub

Private Sub selFolder(capt As String, ctrl As TextBox)
ogdWin.fileFolder frmMain.hwnd, capt, ctrl
End Sub

Private Sub btmDrvAdd_Click()
Dim c As New clsDriver

Set c.magnit = cfg.magnets.Item(0)
If frmDriver.Edit(c, True) = False Then Exit Sub
cfg.Drivers.AddNew c

lstDrv.addItem c.name
lstDrv.ItemData(lstDrv.ListCount - 1) = c.idNum
lstDrv.ListIndex = lstDrv.ListCount - 1

If lstDrv.ListCount <= 0 Then
 btmDrvDel.enabled = False
 btmDrvEdt.enabled = False
 Else
 btmDrvDel.enabled = True
 btmDrvEdt.enabled = True
End If
End Sub

Private Sub btmDrvDel_Click()
Dim indx As Integer, s As String

indx = lstDrv.ListIndex
If ogdWin.AskAction("Удалить " & getDrvDesc(lstDrv.List(indx)) & " ?") = False Then Exit Sub

cfg.Drivers.Delete cfg.Drivers.ItemNum(lstDrv.ItemData(lstDrv.ListIndex)).id
lstDrv.RemoveItem (indx)
If indx >= lstDrv.ListCount Then indx = lstDrv.ListCount - 1
If indx >= 0 Then
 lstDrv.ListIndex = indx
 btmDrvDel.enabled = True
 btmDrvEdt.enabled = True
 Else
 btmDrvDel.enabled = False
 btmDrvEdt.enabled = False
End If
End Sub

Private Function getDrvId(ByVal s As String) As String
Dim i As Integer

i = InStr(s, " ")
getDrvId = Left$(s, i - 1)
End Function

Private Function getDrvDesc(ByVal s As String) As String
Dim i As Integer

i = InStr(s, " ")
getDrvDesc = Right$(s, Len(s) - i)
End Function

Private Sub btmDrvEdt_Click()
Dim c As clsDriver

Set c = cfg.Drivers.ItemNum(lstDrv.ItemData(lstDrv.ListIndex))
If frmDriver.Edit(c, False) Then
 lstDrv.List(lstDrv.ListIndex) = c.name
End If
End Sub

Private Sub btmDrvSave_Click()
setWait "Сохранение..."
cfg.Drivers.Save
setReady
End Sub

Private Sub btmLogMdb_Click()
ogdWin.fileSave _
 "Выберите файл протокола операций с базой обьектов", _
 cfg.obj.sqlLog, _
 cfg.dir.trc, _
 "Файлы протокола (*.log)|*.log", _
 Me.hwnd, _
 txtLogMdb
End Sub

Private Sub btmLogVog_Click()
ogdWin.fileSave _
 "Выберите файл протокола отрисовки графиков VOG", _
 cfg.vog.logFile, _
 cfg.dir.trc, _
 "Файлы протокола (*.log)|*.log", _
 Me.hwnd, _
 txtLogVog
End Sub

Private Sub btmMagnAdd_Click()
Set newMagnet = New clsMagnit
frmMagnit.Edit newMagnet, "Добавление новой магнитной системы", Me, True
End Sub

Public Sub magnetEdit_Callback()
cfg.Magnets.AddNew newMagnet

lstMagn.addItem newMagnet.Description
lstMagn.ItemData(lstMagn.ListCount - 1) = newMagnet.idNum
tuneMagnList lstMagn.ListCount - 1
End Sub

Private Sub btmMagnDel_Click()
Dim indx As Integer

indx = lstMagn.ListIndex
If ogdWin.AskAction("Удалить " & lstMagn.List(indx) & " ?") = False Then Exit Sub

cfg.Magnets.Delete cfg.Magnets.ItemNum(lstMagn.ItemData(indx)).id
lstMagn.RemoveItem (indx)
tuneMagnList 0
End Sub

Private Sub btmMagnEdt_Click()
Set newMagnet = cfg.Magnets.ItemNum(lstMagn.ItemData(lstMagn.ListIndex))
frmMagnit.Edit newMagnet, "Изменение параметров магнитной системы", Me, False
End Sub

Private Sub btmMagnSave_Click()
setWait "Сохранение..."
cfg.magnets.Save
setReady
End Sub

Private Sub btmMdb_Click()
ogdWin.fileOpen _
 "Выберите прототип базы обьектов", _
 cfg.dir.dbTemplete, _
 cfg.dir.trc, _
 "Файлы обьектов (*.mdb)|*.mdb", _
 Me.hwnd, _
 txtMdb
End Sub

Private Sub btmRpt_Click()
ogdWin.fileOpen _
 "Выберите шаблон бланка дефекта по умолчанию", _
 cfg.dir.ReportFile, _
 cfg.dir.Rpt, _
 "Файлы шаблонов (*.dot)|*.dot", _
 Me.hwnd, _
 txtRpt
End Sub

Private Sub btmPal_Click()
selFolder "Каталог по умолчанию для файлов палитр", txtPal
End Sub

Private Sub btmPalDflt_Click()
ogdWin.fileOpen _
 "Выберите файл палитры по умолчанию", _
 cfg.dir.Pal, _
 cfg.crz.dfltPal, _
 "Файлы палитр (*.kpl)|*.kpl", _
 Me.hwnd, _
 txtPalDflt
End Sub

Private Sub btmPrm_Click()
selFolder "Каталог по умолчанию для файлов первичных данных", txtPrm
End Sub

Private Sub btmRptDir_Click()
selFolder "Каталог по умолчанию для шаблонов бланка дефекта", txtRptDir
End Sub

Private Sub btmTrc_Click()
selFolder "Каталог по умолчанию для trc-файлов", txtTrc
End Sub

Private Sub btmVogMrkColor_Click()
ogdWin.selColor picVogMrkColor.BackColor, picVogMrkColor
End Sub

Private Sub exitMode_Click(Index As Integer)
prgExitMode = Index
End Sub

Private Sub Form_Load()

If appVersionIran Then
 chkOnline.visible = False
 crzClickObj.visible = False
 crzChannel.visible = False
 chkDrag.visible = False
 SSTab1.TabVisible(2) = False
End If

If appVersionRestricted Then
 SSTab1.TabVisible(2) = False
End If

If appVersionViewer Then
 SSTab1.TabVisible(4) = False
End If

End Sub

Private Sub logFlag_Click()
If logFlag.Value = 1 Then
 txtLogMdb.enabled = True
 btmLogMdb.enabled = True
 Else
 txtLogMdb.enabled = False
 btmLogMdb.enabled = False
End If
End Sub

Private Sub logFlagVog_Click()
If logFlagVog.Value = 1 Then
 txtLogVog.enabled = True
 btmLogVog.enabled = True
 Else
 txtLogVog.enabled = False
 btmLogVog.enabled = False
End If
End Sub

Private Sub markColor_Click(Index As Integer)
Dim clr As Long

dlg.CancelError = True
dlg.color = markColor(Index).BackColor
dlg.hwnd = Me.hwnd
On Error GoTo CancelColor

dlg.ShowColor
clr = dlg.color
markColor(Index).BackColor = clr

CancelColor:
End Sub

Private Sub optWeel_Click(Index As Integer)
mouseWeelMode = Index
End Sub

Private Sub tubeCheck_Click(Index As Integer)
objTubeCheck = Index
End Sub

Private Sub zoomInsert_Click(Index As Integer)
zoomInsertMode = Index
End Sub
