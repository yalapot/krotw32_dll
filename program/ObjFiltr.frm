VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "TabCtl32.Ocx"
Begin VB.Form frmObjFilter 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Фильтр обьектов"
   ClientHeight    =   5865
   ClientLeft      =   150
   ClientTop       =   435
   ClientWidth     =   9015
   Icon            =   "ObjFiltr.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5865
   ScaleWidth      =   9015
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton btmSet 
      Caption         =   "Сбросить все"
      Height          =   495
      Index           =   3
      Left            =   7200
      TabIndex        =   12
      Top             =   3120
      Width           =   1695
   End
   Begin VB.CommandButton btmSet 
      Caption         =   "Включить все"
      Height          =   495
      Index           =   2
      Left            =   7200
      TabIndex        =   11
      Top             =   2520
      Width           =   1695
   End
   Begin VB.CommandButton btmSet 
      Caption         =   "Сбросить"
      Height          =   495
      Index           =   1
      Left            =   7200
      TabIndex        =   10
      Top             =   840
      Width           =   1695
   End
   Begin VB.CommandButton btmSet 
      Caption         =   "Включить"
      Height          =   495
      Index           =   0
      Left            =   7200
      TabIndex        =   9
      Top             =   240
      Width           =   1695
   End
   Begin TabDlg.SSTab filter 
      Height          =   4935
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   6855
      _ExtentX        =   12091
      _ExtentY        =   8705
      _Version        =   393216
      Tabs            =   6
      TabHeight       =   520
      TabCaption(0)   =   "Обшие"
      TabPicture(0)   =   "ObjFiltr.frx":0442
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "lstObj(0)"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).ControlCount=   1
      TabCaption(1)   =   "Дефекты"
      TabPicture(1)   =   "ObjFiltr.frx":045E
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "lstObj(1)"
      Tab(1).ControlCount=   1
      TabCaption(2)   =   "Трубы"
      TabPicture(2)   =   "ObjFiltr.frx":047A
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "lstObj(2)"
      Tab(2).ControlCount=   1
      TabCaption(3)   =   "Линейные"
      TabPicture(3)   =   "ObjFiltr.frx":0496
      Tab(3).ControlEnabled=   0   'False
      Tab(3).Control(0)=   "lstObj(3)"
      Tab(3).ControlCount=   1
      TabCaption(4)   =   "Участки"
      TabPicture(4)   =   "ObjFiltr.frx":04B2
      Tab(4).ControlEnabled=   0   'False
      Tab(4).Control(0)=   "lstObj(4)"
      Tab(4).ControlCount=   1
      TabCaption(5)   =   "Повороты"
      TabPicture(5)   =   "ObjFiltr.frx":04CE
      Tab(5).ControlEnabled=   0   'False
      Tab(5).Control(0)=   "lstObj(5)"
      Tab(5).ControlCount=   1
      Begin VB.ListBox lstObj 
         Height          =   3885
         Index           =   5
         ItemData        =   "ObjFiltr.frx":04EA
         Left            =   -74880
         List            =   "ObjFiltr.frx":04EC
         Style           =   1  'Checkbox
         TabIndex        =   8
         Top             =   720
         Width           =   3255
      End
      Begin VB.ListBox lstObj 
         Height          =   3885
         Index           =   4
         ItemData        =   "ObjFiltr.frx":04EE
         Left            =   -74880
         List            =   "ObjFiltr.frx":04F0
         Style           =   1  'Checkbox
         TabIndex        =   7
         Top             =   720
         Width           =   3255
      End
      Begin VB.ListBox lstObj 
         Height          =   3885
         Index           =   3
         ItemData        =   "ObjFiltr.frx":04F2
         Left            =   -74880
         List            =   "ObjFiltr.frx":04F4
         Style           =   1  'Checkbox
         TabIndex        =   6
         Top             =   720
         Width           =   3255
      End
      Begin VB.ListBox lstObj 
         Height          =   3885
         Index           =   2
         ItemData        =   "ObjFiltr.frx":04F6
         Left            =   -74880
         List            =   "ObjFiltr.frx":04F8
         Style           =   1  'Checkbox
         TabIndex        =   5
         Top             =   720
         Width           =   3255
      End
      Begin VB.ListBox lstObj 
         Height          =   3885
         Index           =   1
         ItemData        =   "ObjFiltr.frx":04FA
         Left            =   -74880
         List            =   "ObjFiltr.frx":04FC
         Style           =   1  'Checkbox
         TabIndex        =   4
         Top             =   720
         Width           =   3255
      End
      Begin VB.ListBox lstObj 
         Height          =   3885
         Index           =   0
         ItemData        =   "ObjFiltr.frx":04FE
         Left            =   120
         List            =   "ObjFiltr.frx":0500
         Style           =   1  'Checkbox
         TabIndex        =   3
         Top             =   720
         Width           =   3255
      End
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   2160
      TabIndex        =   0
      Top             =   5280
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   3720
      TabIndex        =   1
      Top             =   5280
      Width           =   1215
   End
End
Attribute VB_Name = "frmObjFilter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private ret As Boolean
Private objLst As Collection
Private hlp As New clsHelp

Public Event UpdateObjList()

Public Function Edit(prnt As Form, objList As Collection) As Boolean
Dim c As clsObjType, indx As Integer

Set objLst = objList
hlp.BindHelp Me, KRT_ObjFilter

Load Me

For Each c In objLst
 If c.off = False Then
  indx = getTabIndex(c)
  lstObj(indx).addItem c.name
  lstObj(indx).ItemData(lstObj(indx).NewIndex) = c.id
  lstObj(indx).Selected(lstObj(indx).NewIndex) = c.enabled
 End If
Next
ret = False
centerForm prnt, Me
Me.Show 1, frmMain
Edit = ret
End Function

Private Function getTabIndex(c As clsObjType) As Integer
getTabIndex = 0
Select Case c.tbl
 Case "defect"
  getTabIndex = 1
 Case "weld"
  getTabIndex = 2
 Case "lin_obj"
  getTabIndex = 3
 Case "thick"
  getTabIndex = 4
 Case "turn"
  getTabIndex = 5
End Select
End Function

Private Sub readList()
Dim i As Integer, j As Integer, c As clsObjType, s As String

For j = 0 To 5
 For i = 0 To lstObj(j).ListCount - 1
  s = lstObj(j).ItemData(i)
  Set c = objLst(s)
  c.enabled = lstObj(j).Selected(i)
 Next i
Next j
End Sub

Private Sub setList(ByVal indx As Integer, ByVal selStat As Boolean)
Dim i As Integer

For i = 0 To lstObj(indx).ListCount - 1
 lstObj(indx).Selected(i) = selStat
Next
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0
  readList
  ret = True
  RaiseEvent UpdateObjList
End Select
Unload Me
End Sub

Private Sub btmSet_Click(Index As Integer)
Dim i As Integer

Select Case Index
 
 Case 0
 setList filter.Tab, True
 
 Case 1
 setList filter.Tab, False
 
 Case 2
 For i = 0 To filter.Tabs - 1
  setList i, True
 Next
 
 Case 3
 For i = 0 To filter.Tabs - 1
  setList i, False
 Next
End Select
End Sub
