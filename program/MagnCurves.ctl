VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Object = "{00028CDA-0000-0000-0000-000000000046}#6.0#0"; "TDBG6.OCX"
Object = "{C643EB3F-235C-4181-9B55-36A268833718}#7.0#0"; "olch2x7.ocx"
Begin VB.UserControl ctrlMagnCurves 
   ClientHeight    =   4305
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   9660
   ScaleHeight     =   4305
   ScaleWidth      =   9660
   Begin VB.CommandButton btmAct 
      Caption         =   "Очистить"
      Height          =   375
      Index           =   3
      Left            =   3720
      TabIndex        =   6
      Top             =   3840
      Width           =   1095
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Удалить"
      Height          =   375
      Index           =   2
      Left            =   2400
      TabIndex        =   5
      Top             =   3840
      Width           =   1095
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Изменить"
      Height          =   375
      Index           =   1
      Left            =   1200
      TabIndex        =   4
      Top             =   3840
      Width           =   1095
   End
   Begin VB.CommandButton btmAct 
      Caption         =   "Добавить"
      Height          =   375
      Index           =   0
      Left            =   0
      TabIndex        =   3
      Top             =   3840
      Width           =   1095
   End
   Begin C1Chart2D7.Chart2D graph 
      Height          =   4095
      Left            =   4920
      TabIndex        =   0
      Top             =   120
      Width           =   4695
      _Version        =   458752
      _Revision       =   4
      _ExtentX        =   8281
      _ExtentY        =   7223
      _StockProps     =   0
      ControlProperties=   "MagnCurves.ctx":0000
   End
   Begin ComctlLib.TabStrip tabCurve 
      Height          =   735
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   4815
      _ExtentX        =   8493
      _ExtentY        =   1296
      MultiRow        =   -1  'True
      _Version        =   327682
      BeginProperty Tabs {0713E432-850A-101B-AFC0-4210102A8DA7} 
         NumTabs         =   1
         BeginProperty Tab1 {0713F341-850A-101B-AFC0-4210102A8DA7} 
            Key             =   ""
            Object.Tag             =   ""
            ImageVarType    =   2
         EndProperty
      EndProperty
   End
   Begin TrueDBGrid60.TDBGrid grid 
      Height          =   3015
      Left            =   0
      OleObjectBlob   =   "MagnCurves.ctx":06A4
      TabIndex        =   2
      Top             =   720
      Width           =   4815
   End
End
Attribute VB_Name = "ctrlMagnCurves"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private xarr As New XArrayDB
Private cSet As clsMagnCurveSet
Private d_graphTitle As String
Private d_swapColumn As Boolean
Private frm As Form

Public Sub Bind( _
parentForm As Form, _
curveSet As clsMagnCurveSet, _
ByVal ro As Boolean, _
ByVal graphTitle As String, _
ByVal titleX As String, _
ByVal titleY As String, _
ByVal tblTitle As String, _
ByVal colTitleX As String, _
ByVal colTitleY As String, _
ByVal swapColumn As Boolean _
)

Set frm = parentForm
Set cSet = curveSet
d_graphTitle = graphTitle
d_swapColumn = swapColumn

If ro Then
 btmAct(0).visible = False
 btmAct(1).visible = False
 btmAct(2).visible = False
 btmAct(3).visible = False
 grid.Height = btmAct(0).Height + btmAct(0).Top - grid.Top
End If

With grid
.Caption = tblTitle
.Columns(0).Caption = IIf(d_swapColumn, colTitleY, colTitleX)
.Columns(1).Caption = IIf(d_swapColumn, colTitleX, colTitleY)
.Array = xarr
End With

With graph.ChartArea
.PlotArea.IsBoxed = True
.Axes("Y").AnnotationMethod = oc2dAnnotateValues
.Axes("X").AnnotationMethod = oc2dAnnotateValues
.Axes("Y").title = IIf(d_swapColumn, titleX, titleY)
.Axes("X").title = IIf(d_swapColumn, titleY, titleX)
End With

If cSet.count > 0 Then
 loadCurves cSet.curve_by_index(1)
 Else
 dsblCurves
End If

setButtons
End Sub

Private Sub reloadCurves(curr As clsMagnCurve)
dsblCurves
loadCurves curr
End Sub

Private Sub dsblCurves()
tabCurve.Tabs.Clear
tabCurve.Tabs.Add , , " "
tabCurve.visible = False
graph.ChartGroups(1).data.NumSeries = 0
graph.Header.Text = ""
xarr.Clear
xarr.ReDim 0, 0, 0, 1
grid.ReBind
grid.visible = False
End Sub

Private Sub loadCurves(curr As clsMagnCurve)
Dim i As Integer, c As Integer

c = 1
tabCurve.Tabs(1).Caption = cSet.curve_by_index(1).keymm & " " & cSet.title
For i = 2 To cSet.count
 tabCurve.Tabs.Add i, , cSet.curve_by_index(i).keymm & " " & cSet.title
 If curr.keymm = cSet.curve_by_index(i).keymm Then c = i
Next

grid.visible = True
tabCurve.visible = True

Set tabCurve.SelectedItem = tabCurve.Tabs(c)
End Sub

Private Sub drawGraph()
Dim i As Integer, j As Integer, indx As Integer, crv As clsMagnCurve
Dim x() As Double, y() As Double, minX As Double, maxX As Double, minY As Double, maxY As Double

graph.isBatched = True
With graph.ChartGroups(1).data
.isBatched = True
.NumSeries = cSet.count
.Layout = oc2dDataGeneral
End With
graph.ChartGroups(1).Styles.RemoveAll

indx = tabCurve.SelectedItem.Index
graph.Header.Text = d_graphTitle & " " & cSet.curve_by_index(indx).keymm & " " & cSet.title

j = 1
minX = 0
maxX = 0
minY = 0
maxY = 0
While j <= cSet.count
 
 graph.ChartGroups(1).Styles.Add
 With graph.ChartGroups(1).Styles(j)
  If indx = j Then
   .Symbol.Shape = oc2dShapeDot
   .Symbol.color = RGB(255, 0, 0)
   .Symbol.size = 3
   .line.color = RGB(255, 0, 0)
   Else
   .Symbol.Shape = oc2dShapeNone
   .line.color = RGB(0, 0, 0)
  End If
 End With

 Set crv = cSet.curve_by_index(j)
 If crv.count > 0 Then
  ReDim x(0 To crv.count - 1) As Double
  ReDim y(0 To crv.count - 1) As Double
  For i = 0 To crv.count - 1
   x(i) = crv.x(i)
   y(i) = crv.y(i)
   If x(i) < minX Then minX = x(i)
   If x(i) > maxX Then maxX = x(i)
   If y(i) < minY Then minY = y(i)
   If y(i) > maxY Then maxY = y(i)
  Next

  With graph.ChartGroups(1).data
  .NumPoints(j) = crv.count
  .CopyXVectorIn j, IIf(d_swapColumn, y, x)
  .CopyYVectorIn j, IIf(d_swapColumn, x, y)
  End With
 End If
 
 j = j + 1
Wend

With graph.ChartArea
.Axes("X").Min = IIf(d_swapColumn, minY, minX)
.Axes("X").Max = IIf(d_swapColumn, maxY, maxX)
.Axes("Y").Min = IIf(d_swapColumn, minX, minY)
.Axes("Y").Max = IIf(d_swapColumn, maxX, maxY)
End With

graph.ChartGroups(1).data.isBatched = False
graph.isBatched = False
End Sub

Private Sub setButtons()
Dim b As Boolean

b = (cSet.count > 0)
btmAct(1).enabled = b
btmAct(2).enabled = b
btmAct(3).enabled = b
End Sub

Private Function setKey(crv As clsMagnCurve, ByVal title As String) As Boolean
Dim skey As String, x As Single, y As Single

setKey = False

x = frm.Left + frm.width / 4
y = frm.Top + frm.Height / 4
skey = InputBox("Идентификатор кривой", title, crv.keymm, x, y)
If Len(skey) = 0 Then Exit Function
crv.keymm = Fix(val(skey))

setKey = True
End Function

Private Sub addCurve()
Dim c As clsMagnCurve

Set c = cSet.newCurve
If setKey(c, "Новая кривая") Then
 If cSet.addCurve(c) Then reloadCurves c
End If
End Sub

Private Sub edtCurve()
Dim c As clsMagnCurve

Set c = cSet.curve_by_index(tabCurve.SelectedItem.Index)
If setKey(c, "Изменение кривой") Then
 cSet.Sort
 reloadCurves c
End If
End Sub

Private Sub delCurve()
Dim c As clsMagnCurve

Set c = cSet.curve_by_index(tabCurve.SelectedItem.Index)
If ogdWin.AskAction("Удалить кривую " & c.keymm & " " & cSet.title & " ?") Then
 cSet.delCurve c.keymm
 If cSet.count > 0 Then
  reloadCurves cSet.curve_by_index(1)
  Else
  dsblCurves
 End If
End If
End Sub

Private Sub btmAct_Click(Index As Integer)
Select Case Index
 Case 0 'добавить
  addCurve
 Case 1 'изменить
  edtCurve
 Case 2 'удалить
  delCurve
 Case 3 'очистить
  If ogdWin.AskAction("Хотите отключить уточнение диаметра для этой магнитной системы?") = False Then Exit Sub
  cSet.Clear
  dsblCurves
End Select
setButtons
End Sub

Private Sub tabCurve_Click()
Dim i As Integer, c As Integer, crv As clsMagnCurve

Set crv = cSet.curve_by_index(tabCurve.SelectedItem.Index)
c = IIf(crv.count = 0, 0, crv.count - 1)

With xarr
.Clear
.ReDim 0, c, 0, 1
For i = 0 To crv.count - 1
 .Value(i, 0) = IIf(d_swapColumn, crv.y(i), crv.x(i))
 .Value(i, 1) = IIf(d_swapColumn, crv.x(i), crv.y(i))
Next
End With
grid.ReBind
drawGraph
End Sub

Public Sub FixData()
grid_AfterUpdate
End Sub

Private Sub grid_BeforeColUpdate(ByVal ColIndex As Integer, OldValue As Variant, Cancel As Integer)
If IsNumeric(grid.Columns(ColIndex).Value) Then Exit Sub
ogdWin.Alert "Неверное значение ячейки. Допустимы только числа."
Cancel = 1
End Sub

Private Sub grid_AfterDelete()
updateCurve
End Sub

Private Sub grid_AfterUpdate()
Dim i As Integer, j As Integer, tmp As Double, vi As Double, vj As Double
Dim minIndx As Integer

'сортировка массива. встроенная не работает.
'xarr.QuickSort 1, cnt, 1, XORDER_ASCEND, XTYPE_SINGLE
With xarr

For i = 0 To .count(1) - 1
 minIndx = i

 For j = i To .count(1) - 1
  vj = val(.Value(j, 0))
  vi = val(.Value(minIndx, 0))
  If vj < vi Then minIndx = j
 Next j

 If minIndx <> i Then
  'обмен данными
  tmp = .Value(i, 0)
  .Value(i, 0) = .Value(minIndx, 0)
  .Value(minIndx, 0) = tmp

  tmp = .Value(i, 1)
  .Value(i, 1) = .Value(minIndx, 1)
  .Value(minIndx, 1) = tmp
 End If

Next i

End With
updateCurve
grid.ReBind
End Sub

Private Sub updateCurve()
Dim i As Integer, crv As clsMagnCurve

If cSet.count = 0 Then Exit Sub

With xarr
Set crv = cSet.curve_by_index(tabCurve.SelectedItem.Index)

crv.count = xarr.count(1)
For i = 0 To xarr.count(1) - 1
 crv.x(i) = IIf(d_swapColumn, .Value(i, 1), .Value(i, 0))
 crv.y(i) = IIf(d_swapColumn, .Value(i, 0), .Value(i, 1))
Next
End With
drawGraph
End Sub

Private Sub UserControl_Initialize()
UserControl.BorderStyle = 0
End Sub
