VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMagnetSet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const MAGN_SECT_COMMON = "Common"
Private Const MAGN_LIST = "Magnets"
Private Const MAGN_SECT_PREFIX = "Magnet_"

Private magnSet As Collection
Private cfgFile As String
Private nextIdNum As Integer

Private dfl_magnit As New clsMagnit

Public Sub Init(ByVal iniFile As String)
Dim i As Integer, s As String

cfgFile = iniFile

s = getParam(MAGN_SECT_COMMON, MAGN_LIST, "")
clearCollection magnSet

cfg.parser.Delim = ";"
cfg.parser.TestString = cfg.parser.Delim & s
cfg.parser.Parse
For i = 1 To cfg.parser.count
 Me.loadItem cfg.parser.Item(i)
Next

End Sub

Public Function loadItem(magnId As String) As clsMagnit
Dim magn As New clsMagnit

If magn.restoreFrom(cfgFile, MAGN_SECT_PREFIX & magnId) Then
 magn.idNum = nextIdNum
 nextIdNum = nextIdNum + 1
 magnSet.Add magn, magnId
 Set loadItem = magn
 Else
 Set loadItem = Nothing
End If
End Function

Public Sub AddNew(magn As clsMagnit)
magn.idNum = nextIdNum
nextIdNum = nextIdNum + 1
magnSet.Add magn, magn.id
End Sub

Public Function Item(ByVal id As String) As clsMagnit
On Error GoTo no_magnet
Set Item = magnSet.Item(id)
On Error GoTo 0
Exit Function

no_magnet:
On Error GoTo 0
Set Item = dfl_magnit
End Function

Public Function ItemNum(ByVal idNum As Long) As clsMagnit
Dim m As clsMagnit

For Each m In magnSet
 If m.idNum = idNum Then
  Set ItemNum = m
  Exit Function
 End If
Next
Set ItemNum = dfl_magnit
End Function

Property Get magnString() As String
Dim m As clsMagnit

magnString = ""
For Each m In magnSet
 If Len(magnString) > 0 Then magnString = magnString & ";"
 magnString = magnString & m.id
Next
End Property

Public Sub Save()
Dim m As clsMagnit

For Each m In magnSet
 m.saveTo cfgFile, MAGN_SECT_PREFIX & m.id
Next
setParam MAGN_SECT_COMMON, MAGN_LIST, Me.magnString
End Sub

Private Sub setParam(sec As String, par As String, itmval As String)
setIniItem cfgFile, sec, par, itmval
End Sub

Private Function getParam(sec As String, par As String, dflt As String) As String
getParam = getIniItem(cfgFile, sec, par, dflt)
End Function

Public Function count() As Long
count = magnSet.count
End Function

Public Sub Delete(ByVal id As String)
magnSet.Remove id
End Sub

Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Set NewEnum = magnSet.[_NewEnum]
End Function

Private Sub Class_Initialize()
Set magnSet = New Collection
nextIdNum = 1
End Sub

Private Sub Class_Terminate()
Set magnSet = Nothing
End Sub
