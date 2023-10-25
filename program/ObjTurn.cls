VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsobjTurn"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum T_TURN_CALC_TYPE
    Classic = 0
    Profil = 1
End Enum

Private d_vert As Boolean
Private d_horz As Boolean
Private d_typ As T_TURN_TYPE
Private d_tuneStart As Boolean
Private d_tuneEnd As Boolean
Private d_dCalctyp As Integer

Private d_radXY As Long
Private d_anglXY As Single
Private d_radZ As Long
Private d_anglZ As Single
Private d_markX As Long
Private d_markY As Long
Private d_markZ As Long
Private d_angl3d As Single
Private d_objCommon As New clsObjCommon

Private d_calcType As T_TURN_CALC_TYPE

Public Sub Init( _
objCommon As clsObjCommon, _
ByVal dTurnVert As Boolean, _
ByVal dTurnHorz As Boolean, _
ByVal dTurnTyp As T_TURN_TYPE, _
ByVal dTuneStart As Boolean, _
ByVal dTuneEnd As Boolean, _
ByVal dCalctyp As Integer, _
ByVal dTurnRadXY As Long, _
ByVal dTurnAnglXY As Single, _
ByVal dTurnRadZ As Long, _
ByVal dTurnAnglZ As Single, _
ByVal dMarkX As Long, _
ByVal dMarkY As Long, _
ByVal dMarkZ As Long _
)

d_objCommon.Init objCommon.trc, objCommon.objDist, objCommon.objLen, objCommon.comment, objCommon.isAttention, objCommon.objTyp
d_vert = dTurnVert
d_horz = dTurnHorz
d_typ = dTurnTyp
d_tuneStart = dTuneStart
d_tuneEnd = dTuneEnd
d_dCalctyp = IIf(dCalctyp = 1, 1, 0)

d_radXY = dTurnRadXY
d_anglXY = dTurnAnglXY
d_radZ = dTurnRadZ
d_anglZ = dTurnAnglZ

d_markX = dMarkX
d_markY = dMarkY
d_markZ = dMarkZ
End Sub

Property Get dAngl3D() As Single
dAngl3D = calck_angle_common(Me.dAnglZ, Me.dAnglXY)
End Property

Property Get dRad3D() As Long
Dim ln As Long

ln = 0
dRad3D = 0

If Me.dCalctyp = 1 Then
   ln = d_objCommon.trc.pigL0 + d_objCommon.trc.pigL1
End If

On Error GoTo zero
dRad3D = (Me.user_Length - ln) / Me.dAngl3D
On Error GoTo 0
Exit Property

zero:
dRad3D = 0
End Property

Property Get dAnglXY() As Single
dAnglXY = d_anglXY
End Property

Property Get dRadXY() As Long
dRadXY = d_radXY
End Property

Property Get dAnglZ() As Single
dAnglZ = d_anglZ
End Property

Property Get dRadZ() As Long
dRadZ = d_radZ
End Property

Property Get dMarkZ() As Long
dMarkZ = d_markZ
End Property

Property Get dMarkX() As Long
dMarkX = d_markX
End Property

Property Get dMarkY() As Long
dMarkY = d_markY
End Property

Property Get user_Length() As Long
user_Length = d_objCommon.usrLen
End Property

Property Get dLength() As Long
dLength = d_objCommon.objLen
End Property

Property Let dLength(c As Long)
d_objCommon.objLen = c
End Property

Property Get objCommon() As clsObjCommon
Set objCommon = d_objCommon
End Property

Public Function reCalc(vog As ctrlVOG, ByVal turnHorBorder As Double, ByVal turnVerBorder As Double, Optional calc_type As Long = 0) As Boolean
Dim tmode As Long

tmode = 0
If Me.dTuneStart Then tmode = tmode Or TURN_START
If Me.dTuneEnd Then tmode = tmode Or TURN_END

reCalc = True
If vog.turnInfo( _
 d_objCommon.objDist, _
 Me.dLength, _
 tmode, _
 d_radXY, _
 d_anglXY, _
 d_radZ, _
 d_anglZ, _
 d_markX, d_markY, d_markZ, d_angl3d, Me.user_Length, calc_type) = False Then
 reCalc = False
 Exit Function
End If

Me.dHorz = (Abs(Me.dAnglXY * 180 / PI) >= turnHorBorder)
Me.dVert = (Abs(Me.dAnglZ * 180 / PI) >= turnVerBorder)
d_dCalctyp = calc_type
End Function

Property Get dHorz() As Boolean
dHorz = d_horz
End Property

Property Let dHorz(d As Boolean)
d_horz = d
End Property

Property Get dVert() As Boolean
dVert = d_vert
End Property

Property Let dVert(d As Boolean)
d_vert = d
End Property

Property Get dTyp() As T_TURN_TYPE
dTyp = d_typ
End Property

Property Let dTyp(d As T_TURN_TYPE)
d_typ = d
End Property

Property Get dTuneStart() As Boolean
dTuneStart = d_tuneStart
End Property

Property Let dTuneStart(d As Boolean)
d_tuneStart = d
End Property

Property Get dCalctyp() As Integer
dCalctyp = d_dCalctyp
End Property

Property Get dTuneEnd() As Boolean
dTuneEnd = d_tuneEnd
End Property

Property Let dTuneEnd(d As Boolean)
d_tuneEnd = d
End Property
