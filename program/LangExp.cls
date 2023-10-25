VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsLangExp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum EXP_LANG
EXP_LANG_RU = 100
EXP_LANG_EN = 1000
End Enum

Public Enum EXP_MSG
expSpeedY = 1
expSpeedTitle = 2
expTempY = 3
expTempTitle = 4
expX = 5
expOrientY = 6
expOrientTitle = 7
expShakeY = 8
expShakeTitle = 9
expPressY = 10
expPressTitle = 11
expAngleY = 12
expAngleTitle = 13
expThickY = 14
expThickTitle = 15

expTubeDirect = 16
expTubeSpiral = 17
expTubeWithout = 18
expTraceStart = 19
expTraceEnd = 20

expSpeedKM = 21
expSpeedMS = 22

expCurveY = 23
expCurveTitle = 24
expCurveGrad = 25
expCurveRad = 26

expAzimuthY = 27
expAzimuthTitle = 28
expTangazhY = 29
expTangazhTitle = 30

expThickADC = 31
expThickTesla = 32
End Enum

Private lng As EXP_LANG

Property Get strRUS() As String
strRUS = "Русский"
End Property

Property Get strENG() As String
strENG = "English"
End Property

Property Get langID() As String
Select Case lng
 Case EXP_LANG_EN
  langID = EXP_LNG_ENG
 Case Else
  langID = EXP_LNG_RUS
End Select
End Property

Property Let langID(l As String)
Select Case l
 Case EXP_LNG_ENG
  Me.lang = EXP_LANG_EN
 Case Else
  Me.lang = EXP_LANG_RU
End Select
End Property

Property Get lang() As EXP_LANG
lang = lng
End Property

Property Let lang(l As EXP_LANG)
lng = l
End Property

Public Function msg(ByVal msgID As EXP_MSG) As String
msg = LoadResString(msgID + lng)
End Function

Private Sub Class_Initialize()
lng = EXP_LANG_RU
End Sub
