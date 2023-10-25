VERSION 5.00
Begin VB.Form frmTableColumns 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Настройки колонок"
   ClientHeight    =   5145
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5145
   ScaleWidth      =   4680
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton btmAct 
      Cancel          =   -1  'True
      Caption         =   "Отказ"
      Height          =   495
      Index           =   1
      Left            =   2520
      TabIndex        =   4
      Top             =   4560
      Width           =   1215
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Да"
      Default         =   -1  'True
      Height          =   495
      Index           =   0
      Left            =   960
      TabIndex        =   3
      Top             =   4560
      Width           =   1215
   End
   Begin VB.ListBox lstCol 
      Height          =   3885
      ItemData        =   "TableColumns.frx":0000
      Left            =   120
      List            =   "TableColumns.frx":0007
      Style           =   1  'Checkbox
      TabIndex        =   2
      Top             =   480
      Width           =   4455
   End
   Begin VB.CommandButton btmSet 
      Caption         =   "Выделить все"
      Height          =   375
      Index           =   0
      Left            =   120
      TabIndex        =   1
      Top             =   0
      Width           =   2175
   End
   Begin VB.CommandButton btmSet 
      Caption         =   "Снять выделение"
      Height          =   375
      Index           =   1
      Left            =   2400
      TabIndex        =   0
      Top             =   0
      Width           =   2175
   End
End
Attribute VB_Name = "frmTableColumns"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private ret As Boolean
Private colLst As Columns
Private hlp As New clsHelp

Public Function Edit(prnt As Form, colList As Columns) As Boolean
Dim c As Column

Set colLst = colList
Load Me
hlp.BindHelp Me, KRT_ObjTableColumn
Me.Icon = prnt.Icon
lstCol.Clear

For Each c In colLst
 If c.FooterDivider Then
  lstCol.addItem c.Caption
  lstCol.ItemData(lstCol.NewIndex) = c.ColIndex
  lstCol.Selected(lstCol.NewIndex) = c.visible
 End If
Next
ret = False
centerForm prnt, Me
Me.Show 1, frmMain
Edit = ret
End Function

Private Sub readList()
Dim i As Integer, c As Column, s As Integer

For i = 0 To lstCol.ListCount - 1
 s = lstCol.ItemData(i)
 Set c = colLst(s)
 c.visible = lstCol.Selected(i)
Next
End Sub

Private Sub setList(ByVal selStat As Boolean)
Dim i As Integer

For i = 0 To lstCol.ListCount - 1
 lstCol.Selected(i) = selStat
Next
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0
  readList
  ret = True
End Select
Unload Me
End Sub

Private Sub btmSet_Click(Index As Integer)
Select Case Index
 Case 0
 setList True
 Case 1
 setList False
End Select
End Sub

