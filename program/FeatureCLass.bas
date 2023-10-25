Attribute VB_Name = "FeatureCLass"
Option Explicit

Public Enum EN_FEAT_CLASS
  FT_NONE = 0
  FT_AXGR = 1
  FT_AXSL = 2
  FT_CIGR = 3
  FT_CISL = 4
  FT_GENE = 5
  FT_PINH = 6
  FT_PITT = 7
End Enum

Private need_class_percent As New Collection
Private need_class As New Collection

'http://www.cyberforum.ru/algorithms/thread144722.html
'Реализация - считаются произведения (1, 2, 3 - вершины треугольника, 0 - точка):
'(x1 - x0) * (y2 - y1) - (x2 - x1) * (y1 - y0)
'(x2 - x0) * (y3 - y2) - (x3 - x2) * (y2 - y0)
'(x3 - x0) * (y1 - y3) - (x1 - x3) * (y3 - y0)
'Если они одинакового знака, то точка внутри треугольника, если что-то из этого - ноль, то точка лежит на стороне,
'иначе точка вне треугольника.
Public Function isInsideTriangle( _
ByVal x0 As Single, _
ByVal y0 As Single, _
ByVal x1 As Single, _
ByVal y1 As Single, _
ByVal x2 As Single, _
ByVal y2 As Single, _
ByVal x3 As Single, _
ByVal y3 As Single _
) As Boolean
Dim a As Single, b As Single, c As Single

isInsideTriangle = True

a = (x1 - x0) * (y2 - y1) - (x2 - x1) * (y1 - y0)
b = (x2 - x0) * (y3 - y2) - (x3 - x2) * (y2 - y0)
c = (x3 - x0) * (y1 - y3) - (x1 - x3) * (y3 - y0)

If a = 0 Or b = 0 Or c = 0 Then
  Exit Function
End If

If a > 0 And b > 0 And c > 0 Then
  Exit Function
End If

If a < 0 And b < 0 And c < 0 Then
  Exit Function
End If

isInsideTriangle = False
End Function

Public Function CalcFeatureClass( _
ByVal SizeX As Double, _
ByVal SizeY As Double, _
ByVal thick As Single _
) As EN_FEAT_CLASS
 
Dim a As Single
Dim w As Double, l As Double

CalcFeatureClass = FT_NONE

If thick < 10 Then
 a = 10
Else
 a = thick
End If

l = Abs(SizeX / a)
w = Abs(SizeY / a)

If (w >= 3) And (l >= 3) Then
   CalcFeatureClass = FT_GENE
   Exit Function
End If
'If (w <= 1) And (l <= 1) Then
If (w < 1) And (l < 1) Then
   CalcFeatureClass = FT_PINH
   Exit Function
End If
'If (w <= 1) And (l > 1) Then
If (w < 1) And (l >= 1) Then
 CalcFeatureClass = FT_AXSL
 Exit Function
End If
'If (w > 1) And (l <= 1) Then
If (w >= 1) And (l < 1) Then
 CalcFeatureClass = FT_CISL
 Exit Function
End If

If (w >= 1) And (w < 3) And (l / w >= 2) Then
   CalcFeatureClass = FT_AXGR
   Exit Function
End If

'If l >= 6 Then
'   CalcFeatureClass = FT_AXGR
'   Exit Function
'End If
'
'If isInsideTriangle(l, w, 2, 1, 6, 1, 6, 3) Then
'   CalcFeatureClass = FT_AXGR
'   Exit Function
'End If
 If (l / w <= 0.5) And (1 <= l) And (l < 3) Then
   CalcFeatureClass = FT_CIGR
   Exit Function
End If
'If w >= 6 Then
'   CalcFeatureClass = FT_CIGR
'   Exit Function
'End If
'
'If isInsideTriangle(l, w, 1, 2, 1, 6, 3, 6) Then
'   CalcFeatureClass = FT_CIGR
'   Exit Function
'End If
 
CalcFeatureClass = FT_PITT
End Function

Public Function DefineDefType( _
ByVal rType As Long, _
ByVal rFeatClass As EN_FEAT_CLASS _
) As Long

Dim rTypeOut As Long

rTypeOut = rType

Select Case rType
  Case 8, 9, 10, 217, 218
    Select Case rFeatClass
      Case FT_PITT
        rTypeOut = 10
      Case FT_AXGR
        rTypeOut = 8
      Case FT_CIGR
        rTypeOut = 9
      Case FT_GENE
        rTypeOut = 217
      Case FT_PINH
        rTypeOut = 218
      Case FT_AXSL
        rTypeOut = 8
      Case FT_CISL
        rTypeOut = 9
    End Select
End Select
    
DefineDefType = rTypeOut
End Function

Public Function FeatClassName(featClass As EN_FEAT_CLASS) As String
FeatClassName = ""
Select Case featClass

 Case EN_FEAT_CLASS.FT_GENE
   FeatClassName = "Обширный GENE"
   
 Case EN_FEAT_CLASS.FT_AXGR
   FeatClassName = "Продольная канавка AXGR"
   
 Case EN_FEAT_CLASS.FT_CIGR
   FeatClassName = "Поперечная канавка CIGR"
   
 Case EN_FEAT_CLASS.FT_PINH
   FeatClassName = "Язва PINH"
   
 Case EN_FEAT_CLASS.FT_PITT
   FeatClassName = "Каверна PITT"
   
 Case EN_FEAT_CLASS.FT_AXSL
   FeatClassName = "Продольная щель AXSL"
   
 Case EN_FEAT_CLASS.FT_CISL
   FeatClassName = "Поперечная щель CISL"
   
End Select
End Function

' https://stackoverflow.com/questions/40651/check-if-a-record-exists-in-a-vb6-collection
Private Function IsInCollection(ByVal code As EN_TR_DEFECT_TYPE, collect As Collection) As Boolean
On Error GoTo ExistsNonObjectErrorHandler
    Dim d As Variant

    d = collect(CStr(code))
    IsInCollection = True
    Exit Function
    
ExistsNonObjectErrorHandler:
    IsInCollection = False
End Function

Public Sub init_feat_class()
need_class.Add DT_CORROZ, CStr(DT_CORROZ)
need_class.Add DT_CORROZ_GROUP, CStr(DT_CORROZ_GROUP)
need_class.Add DT_MECH, CStr(DT_MECH)
need_class.Add DT_PRODOL_KANAV, CStr(DT_PRODOL_KANAV)
need_class.Add DT_POPERECH_KANAV, CStr(DT_POPERECH_KANAV)
need_class.Add DT_POTERYA_MET, CStr(DT_POTERYA_MET)
need_class.Add DT_TOCHECHN_KORR, CStr(DT_TOCHECHN_KORR)
need_class.Add DT_ZASHLIFOVKA, CStr(DT_ZASHLIFOVKA)
need_class.Add DT_KOROZ, CStr(DT_KOROZ)

need_class_percent.Add DT_TEHNDEFEKT, CStr(DT_TEHNDEFEKT)
need_class_percent.Add DT_PROKAT, CStr(DT_PROKAT)
End Sub

' https://msdn.microsoft.com/en-us/library/aa231021(v=vs.60).aspx
Public Function getFeatClass4Defect(ByVal trType As EN_TR_DEFECT_TYPE, ByVal dfktClass, ByVal percent_text As String) As Long
Dim i As Long

getFeatClass4Defect = IIf(IsNull(dfktClass), 0, dfktClass)

If IsInCollection(trType, need_class) Then
  Exit Function
End If

If IsInCollection(trType, need_class_percent) Then
  i = 0
  On Error Resume Next
  i = CLng(percent_text)
  On Error GoTo 0
  If i > 0 Then
    Exit Function
  End If
End If

getFeatClass4Defect = EN_FEAT_CLASS.FT_NONE
End Function

