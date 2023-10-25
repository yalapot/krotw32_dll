VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsObjThick"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Enum THCK_ERROR_CODE
THCK_NOERROR
THCK_BADTHICK
End Enum

Private d_thick As Double
Private d_pressure As Double
Private d_thickPrev As Double
Private d_thickNext As Double
Private d_objCommon As New clsObjCommon

Private errCode As THCK_ERROR_CODE
Private extErr As String

Public Sub Init( _
objCommon As clsObjCommon, _
ByVal dThickPrev As Double, _
ByVal dThick As Double, _
ByVal dThickNext As Double, _
ByVal dPress As Double _
)
d_objCommon.Init objCommon.trc, objCommon.objDist, objCommon.objLen, objCommon.comment, objCommon.isAttention, objCommon.objTyp
d_thick = dThick
d_thickPrev = dThickPrev
d_thickNext = dThickNext
d_pressure = dPress
errCode = THCK_NOERROR
extErr = ""
End Sub

Property Get dPress() As Double
dPress = d_pressure
End Property

Property Let dPress(c As Double)
d_pressure = c
End Property

Property Get dThick() As Double
dThick = d_thick
End Property

Property Let dThick(c As Double)
d_thick = c
End Property

Property Get dThickPrev() As Double
dThickPrev = d_thickPrev
End Property

Property Get dThickNext() As Double
dThickNext = d_thickNext
End Property

Property Get objCommon() As clsObjCommon
Set objCommon = d_objCommon
End Property

Public Function Valid() As Boolean
Valid = False

Select Case d_objCommon.objTyp.id

  Case OBJ_TYPE.OBJ_category
  
    If (Me.dThick <= 0) Or (Me.dThick > 5) Then
      errCode = THCK_BADTHICK
      extErr = "Категория должна быть от 1 до 5"
      Exit Function
    End If
  
  'Case OBJ_TYPE.OBJ_thick
  Case Else
  
    If Me.dThick <= 0 Then
      errCode = THCK_BADTHICK
      extErr = "Толщина должна быть больше 0"
      Exit Function
    End If

End Select

Valid = True
End Function

Property Get errText() As String
Select Case errCode
 Case THCK_NOERROR
  errText = "Все в порядке"
  
 Case THCK_BADTHICK
  errText = "Неверные данные." & vbNewLine & extErr
 
 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property
