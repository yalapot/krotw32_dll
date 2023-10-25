VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsObjDefekt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_initDist As Long
Private d_width As Double
Private d_orients As Double
Private d_oriente As Double
Private d_valmin As Double
Private d_valmax As Double
Private d_insidetype As Long
Private d_featClass As EN_FEAT_CLASS
Private d_ex1 As Long
Private d_ex2 As Long
Private d_ey1 As Long
Private d_ey2 As Long
Private d_ix1 As Long
Private d_ix2 As Long
Private d_iy1 As Long
Private d_iy2 As Long

Private d_objCommon As New clsObjCommon

Public Event Changed(ByVal dst As Long)

Public Sub Init( _
objCommon As clsObjCommon, _
ByVal dWidth As Double, _
ByVal dOrients As Double, _
ByVal dOriente As Double, _
ByVal dValMin As Double, _
ByVal dValMax As Double, _
ByVal dInsideType As Long, _
ByVal dFeatClass As EN_FEAT_CLASS, _
ByVal dEx1 As Long, _
ByVal dEx2 As Long, _
ByVal dEy1 As Long, _
ByVal dEy2 As Long, _
ByVal dIx1 As Long, _
ByVal dIx2 As Long, _
ByVal dIy1 As Long, _
ByVal dIy2 As Long _
)
d_objCommon.Init objCommon.trc, objCommon.objDist, objCommon.objLen, objCommon.comment, objCommon.isAttention, objCommon.objTyp
d_initDist = objCommon.objDist
d_width = dWidth
d_orients = dOrients
d_oriente = dOriente
d_valmin = dValMin
d_valmax = dValMax
d_insidetype = dInsideType
d_featClass = dFeatClass
d_ex1 = dEx1
d_ex2 = dEx2
d_ey1 = dEy1
d_ey2 = dEy2
d_ix1 = dIx1
d_ix2 = dIx2
d_iy1 = dIy1
d_iy2 = dIy2
End Sub

Property Get dValMax() As Double
dValMax = d_valmax
End Property

Property Let dValMax(c As Double)
d_valmax = c
End Property

Property Get dValMin() As Double
dValMin = d_valmin
End Property

Property Let dValMin(c As Double)
d_valmin = c
End Property

Property Get dOriente() As Double
dOriente = d_oriente
End Property

Property Let dOriente(c As Double)
d_oriente = c
End Property

Property Get dOrients() As Double
dOrients = d_orients
End Property

Property Let dOrients(c As Double)
d_orients = c
End Property

Property Get dWidth() As Double
dWidth = d_width
End Property

Property Let dWidth(c As Double)
d_width = c
End Property

Property Get dLength() As Long
dLength = d_objCommon.objLen
End Property

Property Let dLength(c As Long)
d_objCommon.objLen = c
End Property

Property Get dInsideType() As Long
dInsideType = d_insidetype
End Property

Property Let dInsideType(i As Long)
d_insidetype = i
End Property

Property Get dFeatClass() As EN_FEAT_CLASS
dFeatClass = d_featClass
End Property

Property Let dFeatClass(d As EN_FEAT_CLASS)
d_featClass = d
End Property

Property Get dEx1() As Long
dEx1 = d_ex1
End Property

Property Let dEx1(d As Long)
d_ex1 = d
End Property

Property Get dEx2() As Long
dEx2 = d_ex2
End Property

Property Let dEx2(d As Long)
d_ex2 = d
End Property

Property Get dEy1() As Long
dEy1 = d_ey1
End Property

Property Let dEy1(d As Long)
d_ey1 = d
End Property

Property Get dEy2() As Long
dEy2 = d_ey2
End Property

Property Let dEy2(d As Long)
d_ey2 = d
End Property

Property Get dIx1() As Long
dIx1 = d_ix1
End Property

Property Let dIx1(d As Long)
d_ix1 = d
End Property

Property Get dIx2() As Long
dIx2 = d_ix2
End Property

Property Let dIx2(d As Long)
d_ix2 = d
End Property

Property Get dIy1() As Long
dIy1 = d_iy1
End Property

Property Let dIy1(d As Long)
d_iy1 = d
End Property

Property Get dIy2() As Long
dIy2 = d_iy2
End Property

Property Let dIy2(d As Long)
d_iy2 = d
End Property

Property Get objCommon() As clsObjCommon
Set objCommon = d_objCommon
End Property

Public Sub raiseChange()
RaiseEvent Changed(d_initDist)
End Sub
