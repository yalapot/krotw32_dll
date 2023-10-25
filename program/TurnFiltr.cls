VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsTurnFiltr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum T_TURNFILTR
    TURNF_OFF = 0
    TURNF_LENGTH = 1
    TURNF_CURVE = 2
    TURNF_ANGLE = 3
End Enum

Private d_mode As T_TURNFILTR
Private d_len As Long   'дина
Private d_angle As Double   'угол 3Д
Private d_oper As String    'оператор сравнения
Private d_type As Integer   'тип
Private d_rad As Double 'радиус 3Д
Private d_lstType As String 'список типов для select
Private d_selectType(0 To 6) As Boolean 'выбранные типы
 
 Property Get selectedCount() As Integer
 Dim i As Integer
 Dim cnt As Integer
    For i = 0 To UBound(d_selectType)
        If d_selectType(i) Then cnt = cnt + 1
    Next
    selectedCount = cnt
 End Property
 
Property Get selectType(index As T_TURN_TYPE) As Boolean
    selectType = d_selectType(index)
End Property

Property Let onSelectType(index As T_TURN_TYPE)
    d_selectType(index) = True
End Property

Property Let offSelectType(index As T_TURN_TYPE)
    d_selectType(index) = False
End Property

Property Get mode() As T_TURNFILTR
    mode = d_mode
End Property

Property Let mode(m As T_TURNFILTR)
    d_mode = m
End Property

Property Get turnLen() As Long
    turnLen = d_len
End Property

Property Let turnLen(t As Long)
    d_len = t
End Property

Property Get turnType() As T_TURN_TYPE
    turnType = d_type
End Property

Property Let turnType(t As T_TURN_TYPE)
    d_type = t
End Property

Property Get turnCompare() As String
    turnCompare = d_oper
End Property

Property Let turnCompare(s As String)
    d_oper = s
End Property

Property Get turnAngle3D() As Double
    turnAngle3D = d_angle
End Property

Property Let turnAngle3D(a As Double)
    d_angle = a
End Property

Property Get turnRad3D() As Double
    turnRad3D = d_rad
End Property

Property Let tubeRad3D(a As Double)
    d_rad = a
End Property

Property Get turnLstType() As String
    turnLstType = d_lstType
End Property
Property Let turnLstType(s As String)
    d_lstType = s
End Property

Private Sub Class_Initialize()
Dim i As Integer
 For i = 0 To 6
    d_selectType(i) = True
 Next

 
End Sub

