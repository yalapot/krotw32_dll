VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsHistory"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const HIST_SEC = "CommentHistory"
Private Const HIST_ITM = "Item"
Private Const HIST_MAX = 32

Private trc As clsTrace

Private d_items As New Collection

Public Sub Init(trace As clsTrace)
Dim i As Integer, s As String

Set trc = trace
clearCollection d_items
For i = 1 To Me.maxItems
 s = getIniItem(trc.FileName, HIST_SEC, HIST_ITM & i)
 If Len(Trim(s)) > 0 Then Me.addItem s
Next
End Sub

Property Get maxItems() As Long
maxItems = HIST_MAX
End Property

Property Get count() As Long
count = d_items.count
End Property

Public Function addItem(str As String) As Boolean
Dim newFlag As Boolean

newFlag = True
On Error GoTo notFound
d_items.Remove str
GoTo contLab
notFound:
newFlag = False

contLab:
On Error GoTo 0

If d_items.count > 0 Then
 d_items.Add str, str, 1
 Else
 d_items.Add str, str
End If
addItem = newFlag
End Function

Public Sub Save()
Dim cnt As Integer, i As Integer

cnt = IIf(Me.count < Me.maxItems, Me.count, Me.maxItems)
For i = 1 To cnt
 setIniItem trc.FileName, HIST_SEC, HIST_ITM & i, d_items.Item(i)
Next
End Sub

Public Sub setCombo(ctrlCombo As ComboBox, Optional ByVal clearFlag As Boolean = True)
Dim i As Integer

If clearFlag Then ctrlCombo.Clear
For i = 1 To d_items.count
 ctrlCombo.addItem d_items.Item(i)
Next
End Sub
