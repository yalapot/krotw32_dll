VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsObjLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_marker As Boolean
Private d_markerText As String
Private d_traceDist As String
Private d_objCommon As New clsObjCommon

Public Sub Init( _
objCommon As clsObjCommon, _
ByVal dMarker As Boolean, _
ByVal dMarkerText As String, _
ByVal dTraceDist As String _
)
d_objCommon.Init objCommon.trc, objCommon.objDist, objCommon.objLen, objCommon.comment, objCommon.isAttention, objCommon.objTyp
d_marker = dMarker
d_markerText = dMarkerText
d_traceDist = dTraceDist
End Sub

Property Get dTraceDist() As String
dTraceDist = d_traceDist
End Property

Property Let dTraceDist(c As String)
d_traceDist = c
End Property

Property Get dMarkerText() As String
dMarkerText = d_markerText
End Property

Property Let dMarkerText(c As String)
d_markerText = c
End Property

Property Get dMarker() As Boolean
dMarker = d_marker
End Property

Property Let dMarker(c As Boolean)
d_marker = c
End Property

Property Get objCommon() As clsObjCommon
Set objCommon = d_objCommon
End Property


