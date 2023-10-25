VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsObjWeld"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_objCommon As New clsObjCommon
Private d_weld1 As Double
Private d_weld2 As Double
Private d_curve As Double
Private d_angle As Double
Private d_complexCurve As Boolean
Public tube_number As String

Public Sub Init( _
objCommon As clsObjCommon, _
ByVal dWeld1 As Double, _
ByVal dWeld2 As Double, _
ByVal dCurve As Double, _
ByVal dAngle As Double, _
ByVal dComplex As Boolean, _
ByVal dNumber As String _
)
d_objCommon.Init objCommon.trc, objCommon.objDist, objCommon.objLen, objCommon.comment, objCommon.isAttention, objCommon.objTyp
d_weld1 = dWeld1
d_weld2 = dWeld2
d_curve = dCurve
d_angle = dAngle
d_complexCurve = dComplex
tube_number = dNumber
End Sub

Property Get tubeLength() As Long
tubeLength = d_objCommon.objLen
End Property

Property Get objCommon() As clsObjCommon
Set objCommon = d_objCommon
End Property

Property Get weld1() As Double
If d_objCommon.objTyp.id = OBJ_shov_b Then
 weld1 = -1
 Else
 weld1 = d_weld1
End If
End Property

Property Let weld1(w As Double)
d_weld1 = w
End Property

Property Get weld2() As Double
If d_objCommon.objTyp.id = OBJ_shov_b Then
 weld2 = -1
 Else
 weld2 = d_weld2
End If
End Property

Property Let weld2(w As Double)
d_weld2 = w
End Property

Property Get curve() As Double
curve = d_curve
End Property

Property Let curve(c As Double)
d_curve = c
End Property

Property Get curveComplex() As Boolean
curveComplex = d_complexCurve
End Property

Property Let curveComplex(c As Boolean)
d_complexCurve = c
If c Then d_angle = -1
End Property

Property Get angle() As Double
angle = d_angle
End Property

Property Let angle(a As Double)
d_angle = a
End Property

Public Sub reCalcAngle(trc As clsTrace)
trc.vog.tubeCurve d_objCommon.objDist, Me.tubeLength, d_curve, d_angle, d_complexCurve
End Sub
