VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsTubeFiltr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum T_TUBEFILTR
 TUBEF_OFF = 0
 TUBEF_LENGTH = 1
 TUBEF_SLIT = 2
 TUBEF_CURVE = 3
 TUBEF_ANGLE = 4
 TUBEF_DEFECT = 5
End Enum

Private d_mode As T_TUBEFILTR
Private d_len As Long
Private d_angle As Double
Private d_oper As String

Property Get mode() As T_TUBEFILTR
mode = d_mode
End Property

Property Let mode(m As T_TUBEFILTR)
d_mode = m
End Property

Property Get tubeLen() As Long
tubeLen = d_len
End Property

Property Let tubeLen(t As Long)
d_len = t
End Property

Property Get tubeCompare() As String
tubeCompare = d_oper
End Property

Property Let tubeCompare(s As String)
d_oper = s
End Property

Property Get tubeAngle() As Double
tubeAngle = d_angle
End Property

Property Let tubeAngle(a As Double)
d_angle = a
End Property
