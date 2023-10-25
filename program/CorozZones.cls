VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsCorozZones"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const CTL_COROZ = "ctlCoroz"
Private Const CRZ_TESLA = "crzTeslaOn"
Private Const CRZ_ALIGN = "crzAlign"

Private trc As clsTrace
Private crzZone() As clsCoroz
Private d_num As Integer

Public tesla As Boolean
Public isAlignVert As Boolean

Public Sub Init(trace As clsTrace, ByVal num As Integer)
Dim i As Integer, s As String

Set trc = trace
d_num = num

ReDim crzZone(Me.num) As clsCoroz
For i = 1 To Me.num
 Set crzZone(i) = New clsCoroz
 crzZone(i).Init trc, i - 1, CTL_COROZ & (i - 1)
Next i

visible = trc.getUserBool(CTL_COROZ, True)
tesla = trc.getUserBool(CRZ_TESLA, False)
isAlignVert = trc.getUserBool(CRZ_ALIGN, False)
End Sub

Public Sub Save()
Dim i As Integer

For i = 1 To Me.num
 crzZone(i).Save
Next

trc.setUserBool CTL_COROZ, visible
trc.setUserBool CRZ_TESLA, tesla
trc.setUserBool CRZ_ALIGN, isAlignVert
End Sub

Property Get Zone(ByVal indx As Integer) As clsCoroz
If (indx < 0) Or (indx > Me.num) Then
 ogdWin.Alert "Bad index in zone"
 Exit Property
End If
Set Zone = crzZone(indx + 1)
End Property

Property Get num() As Integer
num = d_num
End Property

Property Get visible() As Boolean
If Me.num > 0 Then visible = crzZone(1).visible
End Property

Property Let visible(v As Boolean)
If Me.num > 0 Then crzZone(1).visible = v
End Property

Property Get tubeProfileVisible() As Boolean
Dim i As Integer

For i = 0 To Me.num - 1
 If Me.zone(i).isTubeProfVisible Then
   tubeProfileVisible = True
   Exit Property
 End If
Next

tubeProfileVisible = False
End Property

Public Sub tubeProfileHide()
Dim i As Integer
For i = 0 To Me.num - 1
 Me.zone(i).isTubeProfVisible = False
Next
End Sub