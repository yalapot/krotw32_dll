VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDriverSet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private drvSet As Collection
Private drvCount As Long
Private d_magnets As clsMagnetSet

Public Sub Init(Magnets As clsMagnetSet)
Dim i As Integer, s As String

Set d_magnets = Magnets
s = cfg.drvList
clearCollection drvSet
drvCount = 0

cfg.parser.Delim = ";"
cfg.parser.TestString = cfg.parser.Delim & s
cfg.parser.Parse
For i = 1 To cfg.parser.Count
 Me.Add cfg.parser.Item(i)
Next

End Sub

Property Get drvString() As String
Dim c As clsDriver, s As String

s = ""
For Each c In drvSet
 If Len(s) > 0 Then s = s & ";"
 s = s & c.id
Next
drvString = s
End Property

Public Sub Save()
Dim c As clsDriver

For Each c In drvSet
 c.Save
Next
cfg.saveDrvList Me.drvString
End Sub

Public Function Item(ByVal id As String) As clsDriver
Attribute Item.VB_UserMemId = 0
On Error Resume Next
Set Item = drvSet.Item(id)
On Error GoTo 0
End Function

Public Function ItemNum(ByVal idNum As Long) As clsDriver
Dim c As clsDriver

For Each c In drvSet
 If c.idNum = idNum Then
  Set ItemNum = c
  Exit Function
 End If
Next
ogdWin.Alert "clsDriverSet->ItemNum: idNum " & idNum & " not found."
Set ItemNum = Nothing
End Function

Public Function Add(drvId As String) As clsDriver
Dim drvNew As New clsDriver

drvCount = drvCount + 1
If drvNew.Init(cfg.drvIni, drvId, drvCount, d_magnets) Then
 drvSet.Add drvNew, drvId
 Set Add = drvNew
 Else
 Set Add = Nothing
End If
End Function

Public Sub AddNew(drv As clsDriver)
drvCount = drvCount + 1
drvSet.Add drv, drv.id
End Sub

Public Function Count() As Long
Count = drvSet.Count
End Function

Public Sub Delete(ByVal id As String)
drvSet.Remove id
End Sub

Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
Set NewEnum = drvSet.[_NewEnum]
End Function

Private Sub Class_Initialize()
Set drvSet = New Collection
End Sub

Private Sub Class_Terminate()
Set drvSet = Nothing
End Sub
