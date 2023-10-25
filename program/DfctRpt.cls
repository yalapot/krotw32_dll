VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDfctRpt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

''''''''''''''''''''''''''''''''''''
'Описание шаблона MS Word
''''''''''''''''''''''''''''''''''''

'имена shape-ов, используемых для динамической отрисовки положения
'дефекта на трубе
Private Const RPT_SHP_POINT = "dfktPoint"  'кружок дефекта
Private Const RPT_SHP_HLINE = "horLine"    'горизонтальная линия привязки дефекта к левому шву
Private Const RPT_SHP_VLINE = "verLine"    'вертикальная линия привязки дефекта к левому шву

Private Const msoLineDash = 4
Private Const msoArrowheadTriangle = 4

Private Const msoPicture = 13

'расстояния, на которые можно сдвигать кружок дефекта для обозначения
'положения дефекта на трубе
Private Const RPT_SIZEY = 106  'по вертикали
Private Const RPT_SIZEX = 45   'по горизонтали

'имена элементов автотекста
Private Const RPT_DFLT = "DFLTUBE"  'расстояние от камеры запуска до шва трубы с дефектом
Private Const RPT_UMname = "UMname" 'имя маркера перед дефектом
Private Const RPT_UMdist = "UMdist" 'дистанция маркера перед дефектом
Private Const RPT_UMlink = "UMlink" 'расстояние до маркера перед дефектом
Private Const RPT_DMname = "DMname" 'имя маркера после дефекта
Private Const RPT_DMdist = "DMdist" 'дистанция маркера после дефекта
Private Const RPT_DMlink = "DMlink" 'расстояние до маркера после дефекта
Private Const RPT_DFL = "DFL"       'расстояние от камеры запуска до дефекта
Private Const RPT_UWlink = "UWlink" 'расстояние от дефекта до шва перед ним
Private Const RPT_DWlink = "DWlink" 'расстояние от дефекта до шва после него
Private Const RPT_dl = "dl"         'длина дефекта мм
Private Const RPT_dw = "dw"         'ширина дефекта мм
Private Const RPT_dd = "dd"         'глубина дефекта %%
Private Const RPT_dp = "dp"         'ориентация дефекта часы
Private Const RPT_dc = "dc"         'примечание
Private Const RPT_ERF = "ERF"       'ERF
Private Const RPT_dtube = "dtube"   'длина трубы, на которой расположен дефект
Private Const RPT_dtube_t = "dtube_t" 'тип трубы, на которой расположен дефект
Private Const RPT_ut01 = "ut01"     'длина первой трубы перед дефектом
Private Const RPT_ut01_t = "ut01_t" 'тип первой трубы перед дефектом
Private Const RPT_ut02 = "ut02"     'длина второй трубы перед дефектом
Private Const RPT_ut02_t = "ut02_t" 'тип второй трубы перед дефектом
Private Const RPT_ut03 = "ut03"     'длина третьей трубы перед дефектом
Private Const RPT_ut03_t = "ut03_t" 'тип третьей трубы перед дефектом
Private Const RPT_ut04 = "ut04"     'длина четвертой трубы перед дефектом
Private Const RPT_ut04_t = "ut04_t" 'тип четвертой трубы перед дефектом
Private Const RPT_ut05 = "ut05"     'длина пятой трубы перед дефектом
Private Const RPT_ut05_t = "ut05_t" 'тип пятой трубы перед дефектом
Private Const RPT_dt01 = "dt01"     'длина первой трубы после дефекта
Private Const RPT_dt01_t = "dt01_t" 'тип первой трубы перед дефектом
Private Const RPT_dt02 = "dt02"     'длина второй трубы после дефекта
Private Const RPT_dt02_t = "dt02_t" 'тип второй трубы перед дефектом
Private Const RPT_dt03 = "dt03"     'длина третьей трубы после дефекта
Private Const RPT_dt03_t = "dt03_t" 'тип третьей трубы перед дефектом
Private Const RPT_dt04 = "dt04"     'длина четвертой трубы после дефекта
Private Const RPT_dt04_t = "dt04_t" 'тип четвертой трубы перед дефектом
Private Const RPT_dt05 = "dt05"     'длина пятой трубы после дефекта
Private Const RPT_dt05_t = "dt05_t" 'тип пятой трубы перед дефектом

''''''''''''''''''''''''''''''''''''
'Конец описания шаблона MS Word
''''''''''''''''''''''''''''''''''''

Private Const NONE_VALUE = ""

Private d_wordTemplate As String
Private trc As clsTrace

Property Get wordTemplate() As String
wordTemplate = d_wordTemplate
End Property

Property Let wordTemplate(t As String)
d_wordTemplate = t
End Property

Private Function pDst(ByVal p As Long) As String
pDst = IIf(p < 0, NONE_VALUE, mm2txt(trc.getDistKoef(p)))
End Function

Private Function pLen(ByVal strt As Long, ByVal p As Long) As String
pLen = IIf(p < 0, NONE_VALUE, mm2txt(trc.getLenKoef(strt, p)))
End Function

Private Function pType(ByVal p As Integer) As String
Select Case p
 Case OBJ_shov_p
  pType = cfg.lngExpress.msg(expTubeDirect)
 Case OBJ_shov_s
  pType = cfg.lngExpress.msg(expTubeSpiral)
 Case OBJ_shov_b
  pType = cfg.lngExpress.msg(expTubeWithout)
 Case Else
  pType = ""
End Select
End Function

Private Sub procTube(t As Object, lnk As clsPointLink, ByVal tubeIndex As Integer, aLength As String, aType As String)
Dim x As Single, y As Single, ln As Single
Dim wld As clsObjWeld
Dim sh As Object

Select Case tubeIndex
 Case Is < 0
  Set wld = lnk.getTube(-tubeIndex - 1, True)
 Case Is > 0
  Set wld = lnk.getTube(tubeIndex - 1, False)
 Case 0
  Set wld = lnk.getTubeDfkt()
End Select

Set sh = t.Shapes("dfktPoint")
x = sh.Left + sh.width / 2 + tubeIndex * RPT_SIZEX
y = sh.Top + sh.Height / 2

Select Case wld.objCommon.objTyp.id

 Case OBJ_shov_p
  If wld.weld1 >= 0 Then
   ln = y + wld.weld1 * RPT_SIZEY / 12
   Set sh = t.Shapes.AddLine(x, ln, x + RPT_SIZEX, ln, sh.Anchor)
   sh.Line.Weight = 2
   sh.Line.DashStyle = msoLineDash
  End If
  If wld.weld2 >= 0 Then
   ln = y + wld.weld2 * RPT_SIZEY / 12
   Set sh = t.Shapes.AddLine(x, ln, x + RPT_SIZEX, ln, sh.Anchor)
   sh.Line.Weight = 2
   sh.Line.DashStyle = msoLineDash
  End If

 Case OBJ_shov_s
  If wld.weld1 >= 0 Then
   ln = y + wld.weld1 * RPT_SIZEY / 12
   Set sh = t.Shapes.AddLine(x, ln, x + RPT_SIZEX / 4#, ln, sh.Anchor)
   sh.Line.Weight = 2
   sh.Line.BeginArrowheadStyle = msoArrowheadTriangle
  End If
  If wld.weld2 >= 0 Then
   ln = y + wld.weld2 * RPT_SIZEY / 12
   Set sh = t.Shapes.AddLine(x + 3 / 4 * RPT_SIZEX, ln, x + RPT_SIZEX, ln, sh.Anchor)
   sh.Line.Weight = 2
   sh.Line.EndArrowheadStyle = msoArrowheadTriangle
  End If

End Select

t.AttachedTemplate.AutoTextEntries(aLength).Value = pLen(wld.objCommon.objDist, wld.tubeLength)
t.AttachedTemplate.AutoTextEntries(aType).Value = pType(wld.objCommon.objTyp.id)
End Sub

Private Sub updateOrient(doc As Object, tmp_file As String)
Dim s As Object

For Each s In doc.Shapes
 If Not s.LinkFormat Is Nothing Then
   'Debug.Print s.id & " - > " & s.LinkFormat.SourceFullName
   'Debug.Print tmp_file
   s.LinkFormat.SourceFullName = tmp_file
   s.LinkFormat.Update
   s.LinkFormat.BreakLink
   doc.UndoClear
 End If
Next
End Sub

Public Function wordReport(dfkt As clsObjDefekt, lnk As clsPointLink, trace As clsTrace, imgOrientFileName As String) As Boolean
Dim word As Object, doc As Object, t As Object, at As Object
Dim s1 As String, s2 As String, s3 As String, tb As Long, ornt As Double
Dim or1  As New clsAnglUnit, or2  As New clsAnglUnit

setWait "Формирую документ..."

On Error GoTo errWord
Set word = CreateObject("word.application")
Set doc = word.Documents.Add(d_wordTemplate, False, , True)
Set t = doc.AttachedTemplate
On Error GoTo 0

Set trc = trace

On Error Resume Next
t.AutoTextEntries(RPT_DFL).Value = pDst(lnk.pointDist)
On Error GoTo 0

If lnk.mrk1Dist < 0 Then
 s1 = cfg.lngExpress.msg(expTraceStart)
 s2 = "0.00"
 Else
 s1 = lnk.mrk1Name
 s2 = pDst(lnk.mrk1Dist)
End If

On Error Resume Next
t.AutoTextEntries(RPT_UMname).Value = s1
t.AutoTextEntries(RPT_UMdist).Value = s2
On Error GoTo 0

If lnk.mrk2Dist < 0 Then
 s1 = cfg.lngExpress.msg(expTraceEnd)
 s2 = pDst(trc.length)
 Else
 s1 = lnk.mrk2Name
 s2 = pDst(lnk.mrk2Dist)
End If

On Error Resume Next
t.AutoTextEntries(RPT_DMname).Value = s1
t.AutoTextEntries(RPT_DMdist).Value = s2
On Error GoTo 0

If lnk.tubeDfktLeft < 0 Then

 s1 = NONE_VALUE
 s2 = NONE_VALUE
 s3 = NONE_VALUE

 Else

 s1 = pDst(lnk.pointDist - lnk.tubeDfktLeft)
 If lnk.mrk1Dist < 0 Then
  s2 = s1
  Else
  s2 = pLen(lnk.mrk1Dist, lnk.pointDist - lnk.tubeDfktLeft - lnk.mrk1Dist)
 End If
 If lnk.mrk2Dist < 0 Then
  s3 = pLen(lnk.pointDist - lnk.tubeDfktLeft, trc.length - lnk.pointDist + lnk.tubeDfktLeft)
  Else
  s3 = pLen(lnk.pointDist - lnk.tubeDfktLeft, lnk.mrk2Dist - lnk.pointDist + lnk.tubeDfktLeft)
 End If

End If

On Error Resume Next
t.AutoTextEntries(RPT_DFLT).Value = s1
t.AutoTextEntries(RPT_UMlink).Value = s2
t.AutoTextEntries(RPT_DMlink).Value = s3

t.AutoTextEntries(RPT_UWlink).Value = pLen(lnk.pointDist - lnk.tubeDfktLeft, lnk.tubeDfktLeft)
t.AutoTextEntries(RPT_DWlink).Value = pLen(lnk.pointDist, lnk.tubeDfktRight)

procTube doc, lnk, -5, RPT_ut05, RPT_ut05_t
procTube doc, lnk, -4, RPT_ut04, RPT_ut04_t
procTube doc, lnk, -3, RPT_ut03, RPT_ut03_t
procTube doc, lnk, -2, RPT_ut02, RPT_ut02_t
procTube doc, lnk, -1, RPT_ut01, RPT_ut01_t
procTube doc, lnk, 0, RPT_dtube, RPT_dtube_t
procTube doc, lnk, 1, RPT_dt01, RPT_dt01_t
procTube doc, lnk, 2, RPT_dt02, RPT_dt02_t
procTube doc, lnk, 3, RPT_dt03, RPT_dt03_t
procTube doc, lnk, 4, RPT_dt04, RPT_dt04_t
procTube doc, lnk, 5, RPT_dt05, RPT_dt05_t

t.AutoTextEntries(RPT_dl).Value = dfkt.dLength
t.AutoTextEntries(RPT_dw).Value = dfkt.dWidth
t.AutoTextEntries(RPT_dd).Value = dfkt.dValMax

or1.fullHour = dfkt.dOrients
or2.fullHour = dfkt.dOriente

t.AutoTextEntries(RPT_dp).Value = or1.dStr & " - " & or2.dStr
t.AutoTextEntries(RPT_dc).Value = dfkt.objCommon.comment
t.AutoTextEntries(RPT_ERF).Value = NONE_VALUE
On Error GoTo 0

doc.Fields.Update
For Each at In doc.Shapes
 If at.TextFrame.HasText Then at.TextFrame.TextRange.Fields.Update
Next at

If (lnk.tubeDfktLeft < 0) Or (lnk.tubeDfktRight < 0) Then
 On Error Resume Next
 doc.Shapes(RPT_SHP_HLINE).Delete
 doc.Shapes(RPT_SHP_POINT).Delete
 On Error GoTo 0
 Else
 tb = lnk.tubeDfktLeft * RPT_SIZEX / (lnk.tubeDfktLeft + lnk.tubeDfktRight)
 On Error Resume Next
 doc.Shapes(RPT_SHP_POINT).IncrementLeft tb
 doc.Shapes(RPT_SHP_VLINE).IncrementLeft tb
 On Error GoTo 0
 'если есть переход через 12 часов
 ornt = IIf(dfkt.dOrients > dfkt.dOriente, 12, 0)
 ornt = (dfkt.dOriente + ornt - dfkt.dOrients) / 2
 ornt = dfkt.dOrients + ornt
 If ornt >= 12 Then ornt = tb - 12
 ornt = ornt * RPT_SIZEY / 12
 On Error Resume Next
 doc.Shapes(RPT_SHP_POINT).IncrementTop ornt
 On Error GoTo 0
End If

If Len(imgOrientFileName) > 0 Then
  updateOrient doc, imgOrientFileName
End If

t.Saved = True
setReady
word.Visible = True
Exit Function

errWord:
ogdWin.Alert "Ошибка при запуске MS Word:" & vbNewLine & Err.Description
On Error GoTo 0
End Function