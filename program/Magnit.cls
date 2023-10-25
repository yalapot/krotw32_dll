VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMagnit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const MAGN_SECT_PREFIX = "Magnet_"

Private Const ITM_EXTEND = "Extend"
Private Const ITM_TESLA1 = "Tesla1"
Private Const ITM_TESLA2 = "Tesla2"
Private Const ITM_TFI = "isTFI"

Private Const ITM_DFKT_MODE = "DefektWidthMode"
Private Const ITM_DFKT_WIDTH_ACP = "DefektWidthACP"

Private Const ITM_CURVE = "Curve"
Private Const DESCRIPT = "MagnDesc"
Private Const ITM_LOW_DEFKT_PRCNT = "DfktLowPrcnt"

Private Const ITM_DIAM = "Diam"
Private Const ITM_DIAM_NUM = "DiamNum"

Private Const ITM_SLIT = "Slit"
Private Const ITM_SLIT_NUM = "SlitNum"

Private Const ITM_CURVE_NUM = "CurveNum"
Private Const ITM_DESC_DFLT = "Магнитная система по умолчанию (волшебные прямые)"
Private Const ITM_CURVE1_DFLT = "60|5:7;200:85" 'prcnt = dltH / h0 * 40 + 5
Private Const ITM_CURVE2_DFLT = "70|5:5;300:99" 'prcnt = dltH / h0 * 32 + 5

Private Const DFLT_CURVE_NUM = 2
Private Const DFKT_LOW_LEVEL_PRCNT = 10

Private d_diam As New clsMagnCurveSet
Private d_prcnt As New clsMagnCurveSet
Private d_slit As New clsMagnCurveSet

Private d_id As String
Private d_lowDefektResponsePrcnt As Integer
Private d_file As String
Private d_sect As String
Private d_explain As String

Public idNum As Integer
Public teslaK1 As Double
Public teslaK2 As Double

Public dfktWidthADC As Integer
Public dfktWidthMode As Integer

Public lastPrcntSlit As Long
Public Description As String

Private Sub setParam(ByVal itm As String, ByVal dflt As String)
setIniItem d_file, d_sect, itm, dflt
End Sub

Private Function getParam(ByVal itm As String, ByVal dflt As String) As String
getParam = getIniItem(d_file, d_sect, itm, dflt)
End Function

Private Function getParamBool(ByVal itm As String, ByVal dflt As Boolean) As Boolean
Dim s As String

s = IIf(dflt, "1", "0")
s = getIniItem(d_file, d_sect, itm, s)
getParamBool = IIf(s = "1", True, False)
End Function

Private Sub setParamBool(ByVal itm As String, ByVal itmval As Boolean)
setIniItem d_file, d_sect, itm, IIf(itmval, "1", "0")
End Sub

Public Function restoreFrom(ByVal fName As String, ByVal secName As String) As Boolean
Dim i As Integer, cnt As Integer, c As clsMagnCurve, d As clsMagnCurve
Dim base_id As String, base_magn As clsMagnit, c_num As Integer

restoreFrom = False
d_file = fName
d_sect = secName

base_id = Trim$(getParam(ITM_EXTEND, ""))
If Len(base_id) > 0 Then
  Set base_magn = New clsMagnit
  base_magn.restoreFrom fName, MAGN_SECT_PREFIX & base_id
  Me.copyFrom base_magn
End If

If InStr(secName, MAGN_SECT_PREFIX) = 1 Then
  d_id = Mid$(secName, Len(MAGN_SECT_PREFIX) + 1)
End If

cnt = CInt(getParam(ITM_DIAM_NUM, "0"))
If cnt > 0 Then
 Me.diam.Clear
 Me.diam.title = "мм"
 For i = 1 To cnt
  Set d = New clsMagnCurve
  d.dataString = getParam(ITM_DIAM & i, "")
  Me.diam.addCurve d
 Next
End If

Description = getParam(DESCRIPT, Me.Description)
Me.teslaK1 = readDoubleFromString(getParam(ITM_TESLA1, "" & Me.teslaK1))
Me.teslaK2 = readDoubleFromString(getParam(ITM_TESLA2, "" & Me.teslaK2))
Me.dfktWidthADC = val(getParam(ITM_DFKT_WIDTH_ACP, "" & Me.dfktWidthADC))
Me.dfktWidthMode = val(getParam(ITM_DFKT_MODE, "" & Me.dfktWidthMode))
Me.lowDefektResponsePrcnt = val(getParam(ITM_LOW_DEFKT_PRCNT, "" & Me.lowDefektResponsePrcnt))

c_num = CInt(getParam(ITM_CURVE_NUM, "0"))
If c_num > 0 Then
  Me.prcnt.Clear
  Me.prcnt.title = "мм"
  For i = 1 To c_num
    Set c = New clsMagnCurve
    c.dataString = getParam(ITM_CURVE & i, IIf(i > 1, ITM_CURVE2_DFLT, ITM_CURVE1_DFLT))
    If c.keymm = 0 Then 'строка в старом формате. считаем, что диаметр равен индексу умноженному на 10.
      c.keymm = i * 10
    End If
    Me.prcnt.addCurve c
  Next
End If

c_num = CInt(getParam(ITM_SLIT_NUM, "0"))
If c_num > 0 Then
  Me.slit.Clear
  Me.slit.title = "мм"
  For i = 1 To c_num
    Set c = New clsMagnCurve
    c.dataString = getParam(ITM_SLIT & i, IIf(i > 1, ITM_CURVE2_DFLT, ITM_CURVE1_DFLT))
    If c.keymm = 0 Then 'строка в старом формате. считаем, что диаметр равен индексу умноженному на 10.
      c.keymm = i * 10
    End If
    Me.slit.addCurve c
  Next
End If

If Len(Description) = 0 Then
 Description = ITM_DESC_DFLT
 Exit Function
End If

restoreFrom = True
End Function

Public Sub saveTo(ByVal fName As String, ByVal secName As String)
Dim i As Integer

d_file = fName
d_sect = secName
setParam DESCRIPT, Description
setParam ITM_TESLA1, dblStr(teslaK1)
setParam ITM_TESLA2, dblStr(teslaK2)
setParam ITM_DFKT_WIDTH_ACP, Me.dfktWidthADC
setParam ITM_DFKT_MODE, Me.dfktWidthMode
setParam ITM_LOW_DEFKT_PRCNT, Me.lowDefektResponsePrcnt

If Me.prcnt.count < 1 Then
 i = DFLT_CURVE_NUM
 Else
 i = Me.prcnt.count
End If

setParam ITM_CURVE_NUM, i
For i = 1 To Me.prcnt.count
 setParam ITM_CURVE & i, Me.prcnt.curve_by_index(i).dataString
Next

setParam ITM_DIAM_NUM, Me.diam.count
If Me.diam.count > 0 Then
 For i = 1 To Me.diam.count
  setParam ITM_DIAM & i, Me.diam.curve_by_index(i).dataString
 Next
End If

If Me.slit.count < 1 Then
 i = DFLT_CURVE_NUM
 Else
 i = Me.slit.count
End If

setParam ITM_SLIT_NUM, i
For i = 1 To Me.slit.count
 setParam ITM_SLIT & i, Me.slit.curve_by_index(i).dataString
Next

End Sub

Public Function getADCunit(ByVal tesla As Double) As Long
getADCunit = Fix((tesla - teslaK2) / teslaK1)
End Function

Public Function getTesla(ByVal ADCunit As Long) As Double
getTesla = ADCunit * teslaK1 + teslaK2
End Function

Public Function getKAmp_m2(ByVal ADCunit As Long) As Double
getKAmp_m2 = Me.getTesla(ADCunit) / 1.25
End Function

Property Get prcnt() As clsMagnCurveSet
Set prcnt = d_prcnt
End Property

Property Get diam() As clsMagnCurveSet
Set diam = d_diam
End Property

Property Get slit() As clsMagnCurveSet
Set slit = d_slit
End Property

Private Sub copyCurve(from_ As clsMagnCurve, to_ As clsMagnCurve)
to_.keymm = from_.keymm
to_.dataString = from_.dataString
End Sub

Public Sub copyFrom(drvMagn As clsMagnit)
Dim i As Integer, c As clsMagnCurve

With drvMagn
Me.setID .id
Me.Description = .Description
Me.teslaK1 = .teslaK1
Me.teslaK2 = .teslaK2
Me.dfktWidthADC = .dfktWidthADC
Me.dfktWidthMode = .dfktWidthMode
Me.lowDefektResponsePrcnt = .lowDefektResponsePrcnt

Me.prcnt.title = .prcnt.title
Me.prcnt.Clear
For i = 1 To .prcnt.count
 Set c = New clsMagnCurve
 copyCurve .prcnt.curve_by_index(i), c
 Me.prcnt.addCurve c
Next

Me.slit.title = .slit.title
Me.slit.Clear
For i = 1 To .slit.count
 Set c = New clsMagnCurve
 copyCurve .slit.curve_by_index(i), c
 Me.slit.addCurve c
Next

Me.diam.title = .diam.title
Me.diam.Clear
If .diam.count > 0 Then
 For i = 1 To .diam.count
  Set c = New clsMagnCurve
  copyCurve .diam.curve_by_index(i), c
  Me.diam.addCurve c
 Next
End If

End With
End Sub

Property Get explain() As String
explain = d_explain
End Property

Private Sub test1(x As Integer, y As Integer)
Dim c1 As clsMagnCurve, c2 As clsMagnCurve

Set c1 = Me.diam.curveByX(x, y, True)
Set c2 = Me.diam.curveByX(x, y, False)
Debug.Print "(" & x & ", " & y & ") -> " & c1.keymm & " | " & c2.keymm
End Sub

Public Function transPrcnt( _
ByVal wallThickMm As Double, _
ByVal dfktLenMm As Double, _
ByVal dfktWidMm As Double, _
ByVal prcnt As Double _
) As Double
Dim c1 As clsMagnCurve, c2 As clsMagnCurve, p1 As Double, p2 As Double, i As Integer, effective_diam As Integer, area As Double

Dim tmpPrcnt As Double

d_explain = "В используемой магнитной системе "

If Me.prcnt.count < 1 Then
  d_explain = d_explain & vbNewLine & "Отсутствуют магнитные кривые (количество " & Me.prcnt.count & ")."
  d_explain = d_explain & vbNewLine & "Расчет глубины дефекта невозможен."
  transPrcnt = 0
  Exit Function
End If

If Me.diam.count > 0 Then
 
 d_explain = d_explain & "имеется набор кривых определения приведенного диаметра (" & Me.diam.count & ")"
 d_explain = d_explain & vbNewLine & "Ищем ближайшие кривые для дефекта длиной " & dfktLenMm & " мм, шириной " & CInt(dfktWidMm) & " мм и отношением dltH/h0 = " & dblStr(prcnt, 2) & " %"
 
 'test1 30, 600
 'prcnt = 30
 'area = 300
 area = dfktLenMm * dfktWidMm
 
 If Me.diam.outOfDomain(prcnt, area) Then
 
  ' случай, когда точка лежит за пределами области определения нашего набора кривых
  'Set c1 = Me.diam.nearestCurve(prcnt, area)
  'effective_diam = c1.keymm
  d_explain = d_explain & vbNewLine & "Точка x=" & dblStr(prcnt, 2) & " y=" & dblStr(area, 2) & " лежит за границами области определения набора кривых"
  d_explain = d_explain & " x1=" & dblStr(Me.diam.domain_x1, 2) & " y1=" & dblStr(Me.diam.domain_y1, 2) & " x2=" & dblStr(Me.diam.domain_x2, 2) & " y2=" & dblStr(Me.diam.domain_y2, 2)
  'd_explain = d_explain & vbNewLine & Me.diam.explain
  
  tmpPrcnt = prcnt
  If prcnt > Me.diam.domain_x2 Then
    tmpPrcnt = Me.diam.domain_x2
    d_explain = d_explain & vbNewLine & "Изменяем x=" & dblStr(Me.diam.domain_x2, 2)
  End If
  If area > Me.diam.domain_y2 Then
    area = Me.diam.domain_y2
    d_explain = d_explain & vbNewLine & "Изменяем y=" & dblStr(Me.diam.domain_y2, 2)
  End If
  
  
  Set c1 = Me.diam.nearestCurve(tmpPrcnt, area)
  effective_diam = c1.keymm
  
    d_explain = d_explain & vbNewLine & Me.diam.explain
 Else

  'd_explain = d_explain & vbNewLine & "Находим ближайшую меньшую кривую"
 
  Set c1 = Me.diam.curveByX(prcnt, area, False)
  p1 = c1.getValue(prcnt)
  'd_explain = d_explain & vbNewLine & Me.diam.explain
  d_explain = d_explain & vbNewLine & "Ближайшая меньшая кривая: " & c1.keymm & " мм. Значение по ней " & dblStr(p1, 2)
 
  'd_explain = d_explain & vbNewLine & "Находим ближайшую большую кривую"
  Set c2 = Me.diam.curveByX(prcnt, area, True)
  p2 = c2.getValue(prcnt)
  'd_explain = d_explain & vbNewLine & Me.diam.explain
  d_explain = d_explain & vbNewLine & "Ближайшая большая кривая: " & c2.keymm & " мм. Значение по ней " & dblStr(p2, 2)
 
  d_explain = d_explain & vbNewLine & "Значение приведенного диаметра "
  If p1 = p2 Then
   d_explain = d_explain & "берется с одной кривой " & c1.keymm & " мм"
   effective_diam = c1.keymm
  Else
   d_explain = d_explain & "находим пропорцией между значениями кривых " & c1.keymm & " мм (" & dblStr(p1, 2) & ") и " & c2.keymm & " мм (" & dblStr(p2, 2) & ") для значения " & area
   effective_diam = (c1.keymm - c2.keymm) * (area - p2) / (p1 - p2) + c2.keymm
  End If
  
 End If
 
Else
 
 d_explain = d_explain & "нет набора кривых определения приведенного диаметра."
 d_explain = d_explain & vbNewLine & "В качестве приведенного диаметра используем длину дефекта " & dfktLenMm & " мм"
 effective_diam = dfktLenMm

End If

d_explain = d_explain & vbNewLine & "Найденное значение приведенного диаметра = " & effective_diam & " мм"

d_explain = d_explain & vbNewLine & "Количество кривых расчета глубины: " & Me.prcnt.count
For i = 1 To Me.prcnt.count
 d_explain = d_explain & vbNewLine & i & " строка: " & Me.prcnt.curve_by_index(i).dataString
Next i

d_explain = d_explain & vbNewLine & "Для диаметра " & effective_diam & " мм:"

Set c1 = Me.prcnt.curveByMm(effective_diam, False)
d_explain = d_explain & vbNewLine & "ближайшая меньшая кривая: " & c1.keymm & " мм"
p1 = c1.getValue(prcnt)
d_explain = d_explain & vbNewLine & "значение процентов по кривой " & c1.keymm & " мм = " & dblStr(p1, 2) & " %"

Set c2 = Me.prcnt.curveByMm(effective_diam, True)
d_explain = d_explain & vbNewLine & "ближайшая большая кривая: " & c2.keymm & " мм"
p2 = c2.getValue(prcnt)
d_explain = d_explain & vbNewLine & "значение процентов по кривой " & c2.keymm & " мм = " & dblStr(p2, 2) & " %"

d_explain = d_explain & vbNewLine & "Для диаметра " & effective_diam & " мм итоговое значение "
If p1 = p2 Then
  d_explain = d_explain & "берется с одной кривой " & c1.keymm & " мм"
  transPrcnt = p1
  Else
  d_explain = d_explain & "находим пропорцией между значениями кривых " & c1.keymm & " мм (" & dblStr(p1, 2) & " %) и " & c2.keymm & " мм (" & dblStr(p2, 2) & " %)"
  transPrcnt = (p2 - p1) * (effective_diam - c1.keymm) / (c2.keymm - c1.keymm) + p1
End If

d_explain = d_explain & vbNewLine & "Итоговое значение: " & dblStr(transPrcnt, 2) & "%"

'определяем глубину дефекта как канавки
d_explain = d_explain & vbNewLine & "Определяем глубину дефекта как канавки"
d_explain = d_explain & vbNewLine & "В используемой магнитной системе "

If Me.slit.count < 1 Then
  d_explain = d_explain & "отсутствуют кривые для канавок (количество " & Me.slit.count & ")."
  d_explain = d_explain & vbNewLine & "Расчет глубины дефекта как канавки невозможен."
  Me.lastPrcntSlit = 0
  Exit Function
End If

d_explain = d_explain & "количество кривых для канавок: " & Me.slit.count
For i = 1 To Me.slit.count
 d_explain = d_explain & vbNewLine & i & " строка: " & Me.slit.curve_by_index(i).dataString
Next i

d_explain = d_explain & vbNewLine & "В качестве эффективного диаметра для канавки используем длину дефекта " & Int(dfktLenMm) & " мм."

Set c1 = Me.slit.curveByMm(dfktLenMm, False)
d_explain = d_explain & vbNewLine & "ближайшая меньшая кривая: " & c1.keymm & " мм"
p1 = c1.getValue(prcnt)
d_explain = d_explain & vbNewLine & "значение процентов по кривой " & c1.keymm & " мм = " & dblStr(p1, 2) & " %"

Set c2 = Me.slit.curveByMm(dfktLenMm, True)
d_explain = d_explain & vbNewLine & "ближайшая большая кривая: " & c2.keymm & " мм"
p2 = c2.getValue(prcnt)
d_explain = d_explain & vbNewLine & "значение процентов по кривой " & c2.keymm & " мм = " & dblStr(p2, 2) & " %"

d_explain = d_explain & vbNewLine & "Для диаметра " & dfktLenMm & " мм итоговое значение "
If p1 = p2 Then
  d_explain = d_explain & "берется с одной кривой " & c1.keymm & " мм"
  Me.lastPrcntSlit = p1
  Else
  d_explain = d_explain & "находим пропорцией между значениями кривых " & c1.keymm & " мм (" & dblStr(p1, 2) & " %) и " & c2.keymm & " мм (" & dblStr(p2, 2) & " %)"
  Me.lastPrcntSlit = (p2 - p1) * (dfktLenMm - c1.keymm) / (c2.keymm - c1.keymm) + p1
End If

d_explain = d_explain & vbNewLine & "Итоговое значение для канавки: " & dblStr(Me.lastPrcntSlit, 2) & "%"

'Set c = Me.prcnt.curveByMm(45, True)
'Set c = Me.prcnt.curveByMm(45, False)
'Set c = Me.prcnt.curveByMm(5, True)
'Set c = Me.prcnt.curveByMm(5, False)
'Set c = Me.prcnt.curveByMm(100, True)
'Set c = Me.prcnt.curveByMm(100, False)
'Set c = Me.prcnt.curveByMm(10, True)
'Set c = Me.prcnt.curveByMm(10, False)
'Set c = Me.prcnt.curveByMm(80, True)
'Set c = Me.prcnt.curveByMm(80, False)
'Set c = Me.prcnt.curveByMm(30, True)
'Set c = Me.prcnt.curveByMm(30, False)
End Function

Public Sub setID(ByVal new_id As String)
d_id = new_id
End Sub

Property Get id() As String
id = d_id
End Property

Property Get lowDefektResponsePrcnt() As Integer
lowDefektResponsePrcnt = d_lowDefektResponsePrcnt
End Property

Property Let lowDefektResponsePrcnt(l As Integer)
If l > 100 Then l = 100
If l < 1 Then l = 1
d_lowDefektResponsePrcnt = l
End Property

Property Get curveNum() As Integer
curveNum = d_prcnt.count
End Property

Private Sub Class_Initialize()
d_id = ""
d_diam.Init New clsMagnCurve
d_prcnt.Init New clsMagnCurve
d_slit.Init New clsMagnCurve
Description = ITM_DESC_DFLT
teslaK1 = 1
teslaK2 = 0
d_lowDefektResponsePrcnt = DFKT_LOW_LEVEL_PRCNT
dfktWidthADC = 0
dfktWidthMode = 0
End Sub
