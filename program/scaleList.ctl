VERSION 5.00
Begin VB.UserControl scaleList 
   ClientHeight    =   1410
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3090
   ScaleHeight     =   1410
   ScaleWidth      =   3090
   Begin VB.Frame Frame 
      Caption         =   "Масштабы развертки"
      Height          =   1335
      Left            =   0
      TabIndex        =   3
      Top             =   0
      Width           =   3015
      Begin VB.ListBox lst 
         Height          =   1035
         Left            =   120
         TabIndex        =   0
         ToolTipText     =   "Список масштабов растяжения/сжатия корозионной развертки"
         Top             =   240
         Width           =   1575
      End
      Begin VB.CommandButton btmAdd 
         Caption         =   "Добавить"
         Height          =   375
         Left            =   1800
         TabIndex        =   1
         ToolTipText     =   "Добавить новый масштаб"
         Top             =   240
         Width           =   1095
      End
      Begin VB.CommandButton btmDel 
         Caption         =   "Удалить"
         Height          =   375
         Left            =   1800
         TabIndex        =   2
         ToolTipText     =   "Удалить существующий масштаб"
         Top             =   720
         Width           =   1095
      End
   End
End
Attribute VB_Name = "scaleList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private controlX As Single
Private controlY As Single

Private Sub UserControl_Initialize()
controlX = UserControl.width
controlY = UserControl.Height
End Sub

Private Sub UserControl_Resize()
Static intFlag As Boolean

If intFlag Then Exit Sub
intFlag = True
UserControl.width = controlX
UserControl.Height = controlY
intFlag = False
End Sub

Property Get Caption() As String
Caption = Frame.Caption
End Property

Property Let Caption(s As String)
Frame.Caption = s
End Property

Property Let sclString(s As String)
Dim i As Long

cfg.parser.Delim = ";"
cfg.parser.TestString = cfg.parser.Delim & s
cfg.parser.Parse
For i = 1 To cfg.parser.Count
 lst.addItem cfg.crz.scaleText(Val(cfg.parser.Item(i)))
 lst.ItemData(i - 1) = Val(cfg.parser.Item(i))
Next
lst.ListIndex = 0
If lst.ListCount = 1 Then btmDel.enabled = False
End Property

Property Get sclString() As String
Dim txt As String, i As Long

txt = ""
For i = 0 To lst.ListCount - 1
 If Len(txt) > 0 Then txt = txt & ";"
 txt = txt & lst.ItemData(i)
Next
sclString = txt
End Property

Property Get dfltScale() As Integer
dfltScale = lst.ItemData(lst.ListIndex)
End Property

Property Let dfltScale(dflt As Integer)
Dim i As Long

For i = 0 To lst.ListCount - 1
 If lst.ItemData(i) = dflt Then
  lst.ListIndex = i
  Exit Property
 End If
Next
End Property

Private Sub btmAdd_Click()
Dim dflt As Integer, indx As Integer
Dim sclTxt As String

dflt = lst.ItemData(lst.ListIndex)
If frmScaleNew.Edit(dflt) = False Then Exit Sub
indx = findIndex(lst, dflt)
sclTxt = cfg.crz.scaleText(dflt)

If indx = -1 Then
 ogdWin.Alert "Масштаб " & sclTxt & " уже есть в списке."
 Else
 lst.AddItem sclTxt, indx
 lst.ItemData(indx) = dflt
 lst.ListIndex = indx
 btmDel.enabled = True
End If
End Sub

Private Sub btmDel_Click()
Dim indx As Integer

indx = lst.ListIndex
If ogdWin.AskAction("Удалить масштаб " & lst.List(indx) & " ?") Then
 lst.RemoveItem (indx)
 If indx >= lst.ListCount Then indx = lst.ListCount - 1
 lst.ListIndex = indx
 If lst.ListCount = 1 Then btmDel.enabled = False
End If
End Sub

Private Function findIndex(lst As ListBox, ByVal dflt As Integer) As Integer
Dim i As Integer

For i = 0 To lst.ListCount - 1
 If lst.ItemData(i) = dflt Then
  findIndex = -1
  Exit Function
 End If
 If lst.ItemData(i) > dflt Then
  findIndex = i
  Exit Function
 End If
Next
findIndex = i
End Function