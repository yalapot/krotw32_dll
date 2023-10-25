VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsPointLink"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const TUBES_NUM = 5       'количество труб до и после дефекта, длины которых надо вычислить

Private d_DFL As Long             'расстояние от камеры запуска до дефекта

Private d_UMname As String        'имя маркера перед дефектом
Private d_UMdist As Long          'дистанция маркера перед дефектом
Private d_DMname As String        'имя маркера после дефекта
Private d_DMdist As Long          'дистанция маркера после дефекта
Private d_UWlink As Long          'расстояние от начала дефекта до шва перед ним
Private d_DWlink As Long          'расстояние от начала дефекта до шва после него
Private d_tt As New clsObjWeld    'труба с дефектом
Private d_ut(TUBES_NUM) As clsObjWeld 'трубы перед дефектом
Private d_dt(TUBES_NUM) As clsObjWeld 'трубы после дефекта

Public trc As clsTrace

Property Get tubesNum() As Integer
tubesNum = TUBES_NUM
End Property

Property Get pointDist() As Long
pointDist = d_DFL
End Property

Property Let pointDist(p As Long)
Dim i As Integer, cmn As New clsObjCommon, tp As New clsObjType

d_DFL = p

d_UMname = ""
d_UMdist = -1
d_DMname = ""
d_DMdist = -1
d_UWlink = -1
d_DWlink = -1

tp.Init -1, "", False, ""
cmn.Init trc, -1, 0, "", False, tp
d_tt.Init cmn, -1, -1, -1, -1, False, ""
For i = 0 To TUBES_NUM - 1
 d_ut(i).Init cmn, -1, -1, -1, -1, False, ""
 d_dt(i).Init cmn, -1, -1, -1, -1, False, ""
Next
End Property

Public Function getTubeDfkt() As clsObjWeld
Set getTubeDfkt = d_tt
End Function

Public Sub setTubeDfkt(tube As clsObjWeld)
With tube
d_tt.Init .objCommon, .weld1, .weld2, .curve, .angle, .curveComplex, .tube_number
End With
End Sub

Public Function getTube(ByVal indx As Integer, ByVal leftFlag As Boolean) As clsObjWeld

If (indx >= TUBES_NUM) Or (indx < 0) Then
 Set getTube = Nothing
 Exit Function
End If

If leftFlag Then
 Set getTube = d_ut(indx)
 Else
 Set getTube = d_dt(indx)
End If
End Function

Public Sub setTube(ByVal indx As Integer, ByVal leftFlag As Boolean, tube As clsObjWeld)

If (indx >= TUBES_NUM) Or (indx < 0) Then Exit Sub

With tube
If leftFlag Then
 d_ut(indx).Init .objCommon, .weld1, .weld2, .curve, .angle, .curveComplex, .tube_number
 Else
 d_dt(indx).Init .objCommon, .weld1, .weld2, .curve, .angle, .curveComplex, .tube_number
End If
End With
End Sub

Property Get mrk1Name() As String
mrk1Name = d_UMname
End Property

Property Let mrk1Name(n As String)
d_UMname = n
End Property

Property Get mrk1Dist() As Long
mrk1Dist = d_UMdist
End Property

Property Let mrk1Dist(d As Long)
d_UMdist = d
End Property

Property Get mrk2Name() As String
mrk2Name = d_DMname
End Property

Property Let mrk2Name(n As String)
d_DMname = n
End Property

Property Get mrk2Dist() As Long
mrk2Dist = d_DMdist
End Property

Property Let mrk2Dist(d As Long)
d_DMdist = d
End Property

Property Get tubeDfktLeft() As Long
tubeDfktLeft = d_UWlink
End Property

Property Let tubeDfktLeft(d As Long)
d_UWlink = d
End Property

Property Get tubeDfktRight() As Long
tubeDfktRight = d_DWlink
End Property

Property Let tubeDfktRight(d As Long)
d_DWlink = d
End Property

Private Sub Class_Initialize()
Dim i As Integer

For i = 0 To TUBES_NUM - 1
 Set d_ut(i) = New clsObjWeld
 Set d_dt(i) = New clsObjWeld
Next
End Sub

Private Sub Class_Terminate()
Dim i As Integer

For i = 0 To TUBES_NUM - 1
 Set d_ut(i) = Nothing
 Set d_dt(i) = Nothing
Next
End Sub
