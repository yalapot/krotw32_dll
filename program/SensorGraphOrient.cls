VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorGraphOrient"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements clsSensor

Private sens As clsSensor
Private absentFlag As Boolean

Public Sub Init(trace As clsTrace, ByVal iniKey As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long)
If num < 1 Then
 num = 1
 vMin = 0
 vMax = 360 - 1
 absentFlag = True
End If
sens.Init trace, SENS_ORIENT, iniKey, "Ориентация, датчики", num, vMin, vMax
End Sub

Private Sub Class_Initialize()
Set sens = New clsSensor
absentFlag = False
End Sub

Private Function clsSensor_canDraw(pic As PictureBox) As Boolean
clsSensor_canDraw = sens.canDraw(pic)
End Function

Private Sub clsSensor_ClearData()
sens.ClearData
End Sub

Private Function clsSensor_Draw(pic As PictureBox, ByVal diskret As Boolean, ByVal cycledLevel As Long, ByVal reverse As Boolean, Optional forceReadData As Boolean = False) As Boolean
clsSensor_Draw = sens.Draw(pic, diskret, cycledLevel, reverse, forceReadData)
End Function

Private Function clsSensor_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
If absentFlag Then
 clsSensor_getVal = 0
 Else
 clsSensor_getVal = sens.getVal(x, lineIndex)
End If
End Function

Private Sub clsSensor_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKey As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long)
Me.Init trace, iniKey, num, vMin, vMax
End Sub

Private Property Get clsSensor_isCurrMarkWhite() As Boolean
clsSensor_isCurrMarkWhite = sens.isCurrMarkWhite
End Property

Private Property Get clsSensor_line(ByVal indx As Integer) As clsSensorLine
Set clsSensor_line = sens.line(indx)
End Property

Private Property Get clsSensor_markB(ByVal lineIndex As Long) As Long
clsSensor_markB = sens.markB(lineIndex)
End Property

Private Property Get clsSensor_markW(ByVal lineIndex As Long) As Long
clsSensor_markW = sens.markW(lineIndex)
End Property

Private Property Get clsSensor_maxPageVal() As Long
clsSensor_maxPageVal = sens.maxPageVal
End Property

Private Property Get clsSensor_minPageVal() As Long
clsSensor_minPageVal = sens.minPageVal
End Property

Private Property Get clsSensor_name() As String
clsSensor_name = sens.name
End Property

Private Property Get clsSensor_num() As Long
clsSensor_num = sens.num
End Property

Private Sub clsSensor_offAll()
sens.offAll
End Sub

Private Sub clsSensor_Save()
sens.Save
End Sub

Private Property Get clsSensor_typ() As KRT_SENS
clsSensor_typ = SENS_ORIENT
End Property

Private Property Get clsSensor_valMax() As Long
clsSensor_valMax = sens.valMax
End Property

Private Property Get clsSensor_valMin() As Long
clsSensor_valMin = sens.valMin
End Property

Private Property Get clsSensor_visible() As Boolean
clsSensor_visible = sens.visible
End Property
