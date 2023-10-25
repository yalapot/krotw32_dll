VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsExport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private trc As clsTrace

Private sDist As String
Private sCoord As String
Private v1 As Long, v2 As Long, v3 As Long
Private nWeldExpStatus As Boolean
 
Private Type TP_EXP_PROPERTY
 name As String
 ext As String
End Type

Private db As Database
Private ep As TP_EXP_PROPERTY

Private Sub SetExportProperty(exp_type As EN_EXP_TYPE)
Select Case exp_type
Case ET_WELD
    ep.name = "раскладка труб"
    ep.ext = "wld"
    nWeldExpStatus = False
Case ET_LINEOBJ
    ep.name = "линейные объекты"
    ep.ext = "lbj"
Case ET_DEFECT
    ep.name = "дефекты"
    ep.ext = "dfc"
Case ET_PRIGRUZ
    ep.name = "пригрузы"
    ep.ext = "grv"
Case ET_SPEED
    ep.name = "график скорости"
    ep.ext = "spd"
Case ET_THICK
    ep.name = "толщина стенки трубы"
    ep.ext = "tck"
Case ET_MAGNETS
    ep.name = "намагниченность стенки трубы"
    ep.ext = "mgn"
Case ET_CATEGORY
    ep.name = "категории участков"
    ep.ext = "ctg"
Case ET_VOG_POVOROT
    ep.name = "СНТ: повороты"
    ep.ext = "str"
Case ET_CRCT_TABLE
    ep.name = "таблица поправок"
    ep.ext = "crc"
Case ET_VOG_CSV
    ep.name = "экспорт vog в файл"
    ep.ext = "csv"
    v1 = 0
    v2 = trc.length
    v3 = 10
    If Not frmInterval.IntervalVOG( _
        0, _
        trc.length, _
        v1, v2, v3, trc) Then Exit Sub
Case ET_WELD_EXTENDED
    ep.name = "раскладка труб расширенная"
    ep.ext = "wld"
    nWeldExpStatus = True
    
End Select
End Sub

Private Function GetDistCoord(tHandle As Long, rs As Recordset) As Boolean
Dim vogx As Long, vogy As Long, vogZ As Long, dst As Long

sDist = "" & rs("userDist") 'trc.getDistKoef(dist)
dst = IIf(IsNull(rs("linkedDist")), rs("dist"), rs("linkedDist"))

trc.vog.getCoord dst, vogx, vogy, vogZ
sCoord = _
 CStr(intDblStr(vogZ, 1, 0)) & "," & _
 CStr(intDblStr(vogx, 1, 0)) & "," & _
 CStr(intDblStr(vogy, 1, 0))
End Function

Private Function GetFileName() As String
Dim dlg As New clsCommonDialog
dlg.CancelError = False
dlg.Flags = cdlOFNExplorer + cdlOFNHideReadOnly + cdlOFNLongNames + cdlOFNOverwritePrompt + cdlOFNPathMustExist
dlg.DefaultExt = "." + ep.ext
dlg.DialogTitle = "Выберите файл для экспорта"
dlg.Filter = ep.name + " (*." + ep.ext + ")|*." + ep.ext
dlg.ShowSave
GetFileName = dlg.FileName
Set dlg = Nothing
End Function

Public Sub Export(exp_type As EN_EXP_TYPE, trace As clsTrace)
Dim lFileHandle As Long
Dim sFileName As String, msg As String

Set trc = trace
SetExportProperty exp_type
sFileName = GetFileName()
If sFileName = "" Then Exit Sub

msg = "Запись в '" & sFileName & "' ..."
setWait msg
Set db = trc.db.db
lFileHandle = FreeFile
Open sFileName For Output As lFileHandle
Select Case exp_type
Case ET_WELD
    ExportWeld lFileHandle, trc.handle
Case ET_LINEOBJ
    ExportLineObj lFileHandle, trc.handle
Case ET_DEFECT
    ExportDefect lFileHandle, trc.handle
Case ET_PRIGRUZ
    ExportPrigruz lFileHandle, trc.handle
Case ET_SPEED
    ExportSpeed lFileHandle, trc.handle
Case ET_MAGNETS
    ExportMagnitude lFileHandle, trc.handle, getCutKoef()
Case ET_THICK
    ExportThick lFileHandle, OBJ_thick
Case ET_CATEGORY
    ExportThick lFileHandle, OBJ_category
Case ET_VOG_POVOROT
    ExportVOGPovorot lFileHandle, trc.handle
Case ET_CRCT_TABLE
    ExportCorrectionTable lFileHandle
Case ET_VOG_CSV
    ExportVOGCSVData lFileHandle
Case ET_WELD_EXTENDED
    ExportWeld lFileHandle, trc.handle
End Select
Close lFileHandle
setReady
End Sub

Private Function getNode(tHandle As Long, ByRef dat As T_NODEDATA, ByVal koef As Integer) As Integer
Dim i As Integer

i = 0
getNode = KRT_OK
While i < koef
 If krotGetNextNode(tHandle, dat) = KRT_ERR Then
   getNode = KRT_ERR
   Exit Function
 End If
 i = i + 1
Wend
End Function

Private Function getCutKoef() As Integer
Dim s As String

s = InputBox("Задайте коэффициент прореживания данных", "Экспорт толщины", "1")
If Trim(s) = "" Then
 getCutKoef = 0
 Else
 getCutKoef = Int(s)
End If
End Function

Private Sub ExportMagnitude(lFileHandle As Long, tHandle As Long, ByVal koef As Integer)
Dim dat0 As T_NODEDATA, dat1 As T_NODEDATA, dat2 As T_NODEDATA, distOut As Long

If koef <= 0 Then Exit Sub

If krotGetFirstNode(tHandle, dat0, 0, SENS_THICK, 0, trc.length, 0) = KRT_ERR Then
 ogdWin.Alert "Ошибка при формировании графика (krotGetFirstNode)" & vbNewLine & lastError()
 Exit Sub
End If

If krotLockNodeSequence(trc.handle, 1) = KRT_ERR Then
 ogdWin.Alert "Не могу включить режим блокировки" & vbNewLine & lastError()
 Exit Sub
End If

getNode tHandle, dat1, koef
getNode tHandle, dat2, koef

Print #lFileHandle, "VERSION2"

While dat2.prevPos < trc.length
 
 If Not ((dat0.sensVal = dat1.sensVal) And (dat0.sensVal = dat2.sensVal)) Then
  'Debug.Print dat0.sensVal
  distOut = trc.getDistKoef(dat0.prevPos)
  Print #lFileHandle, CStr(distOut) + "," & CLng(trc.magnit.getTesla(dat0.sensVal) * 1000)
  dat0 = dat1
 End If
 
 dat1 = dat2
 If getNode(tHandle, dat2, koef) = KRT_ERR Then
   krotLockNodeSequence tHandle, 0
   ogdWin.Alert "Ошибка при формировании графика (krotGetNextNode)" & vbNewLine & lastError()
   Exit Sub
 End If
 
 Dim tmp As Double
 tmp = dat2.prevPos
 setWait "Выполнено: " & CInt(tmp * 100 / trc.length) & "%"
Wend

distOut = trc.getDistKoef(dat0.prevPos)
Print #lFileHandle, CStr(distOut) + "," & CLng(trc.magnit.getTesla(dat0.sensVal) * 1000)
distOut = trc.getDistKoef(dat1.prevPos)
Print #lFileHandle, CStr(distOut) + "," & CLng(trc.magnit.getTesla(dat0.sensVal) * 1000)
distOut = trc.getDistKoef(dat2.prevPos)
Print #lFileHandle, CStr(distOut) + "," & CLng(trc.magnit.getTesla(dat0.sensVal) * 1000)

If krotLockNodeSequence(tHandle, 0) = KRT_ERR Then
 ogdWin.Alert "Не могу выключить режим блокировки" & vbNewLine & lastError()
End If

End Sub

Private Sub ExportSpeed(lFileHandle As Long, tHandle As Long)
Dim x As Long, distOut As Long, ret As Integer, dst As Long

'MsgBox (CStr(trc.Step) + " " + CStr(trc.length))
ret = MsgBox("через 2м", vbYesNo + vbQuestion, "Выберите способ экспорта")

If ret = vbYes Then
    dst = 0
    x = trc.getDistReal(dst)
    While (x < trc.length)
     distOut = trc.getDistKoef(x)
     distOut = distOut / 2000
     distOut = distOut * 2000
     If (distOut + trc.odoStart) >= 0 Then
       Print #lFileHandle, CStr(distOut) + "," + CStr(trc.speedAt(x))
     End If
     dst = dst + 2000
     x = trc.getDistReal(dst)
    Wend
    
    x = trc.length
    Print #lFileHandle, CStr(trc.getDistKoef(x)) + "," + CStr(trc.speedAt(x))
    
    'x = trc.getDistReal(0)
    'While (x < trc.length)
    ' Print #lFileHandle, CStr(trc.getDistKoef(x)) + "," + CStr(trc.speedAt(x))
    ' x = x + 2000
    'Wend
    
    'x = trc.length
    'Print #lFileHandle, CStr(trc.getDistKoef(x)) + "," + CStr(trc.speedAt(x))
Else
    x = 0
    While (x < trc.length)
      distOut = trc.getDistKoef(x)
      If (distOut + trc.odoStart) >= 0 Then
        Print #lFileHandle, CStr(distOut) + "," + CStr(trc.speedAt(x))
      End If
      x = x + trc.speedVector * SV_AMPL
    Wend
    
    x = trc.length
    Print #lFileHandle, CStr(trc.getDistKoef(x)) + "," + CStr(trc.speedAt(x))
End If
End Sub

Private Sub ExportThick(lFileHandle As Long, typ As OBJ_TYPE)
Dim rs As Recordset, thickParam As String, pressParam As String
Dim sql As String

sql = "SELECT thick.dist AS dist, thick, pressure FROM thick LEFT JOIN common ON common.dist=thick.dist WHERE common.type = " & typ & " ORDER BY thick.dist"
Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

Select Case typ
  Case OBJ_TYPE.OBJ_category
    Print #lFileHandle, "VERSION3"
  Case Else
    Print #lFileHandle, "VERSION2"
End Select

While Not rs.EOF

    Select Case typ
      Case OBJ_TYPE.OBJ_category
        thickParam = "" & rs("thick")
        pressParam = IIf(IsNull(rs("pressure")), "0", "" & rs("pressure"))
        Print #lFileHandle, CStr(Round(trc.getDistKoef(rs("dist")))) + "," + thickParam + "," + pressParam
      'OBJ_TYPE.OBJ_thick
      Case Else
        thickParam = CStr(Round(rs("thick") * 100))
        Print #lFileHandle, CStr(Round(trc.getDistKoef(rs("dist")))) + "," + thickParam
    End Select
    
    setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
    rs.MoveNext
Wend
rs.Close
End Sub

Private Sub ExportPrigruz(lFileHandle As Long, tHandle As Long)
Dim rs As Recordset
Dim sql As String, tmpl As Long
Dim eType As EN_TR_PRIGRUZ_TYPE, eLen As Long

sql = "SELECT dist,type,name,len,userDist,userLen,linkedDist FROM common WHERE type IN ( +" _
+ CStr(OBJ_prigruz) + "," _
+ CStr(OBJ_startprgrz) + "," _
+ CStr(OBJ_endprgrz) + _
") AND dist>0 ORDER BY dist"
Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

Print #lFileHandle, "VERSION3"
While Not rs.EOF
    If GetDistCoord(tHandle, rs) Then Exit Sub
    
    Select Case rs("type")
    Case OBJ_prigruz
     eType = PT_SINGLE
     eLen = IIf(IsNull(rs("len")), 0, rs("len"))
    Case OBJ_startprgrz
     eType = PT_START
     eLen = getPrigruzStartLen(rs)
    Case OBJ_endprgrz
     eType = PT_END
     eLen = getPrigruzEndLen(rs)
    End Select

    Dim s As String
    If IsNull(rs("name")) Then
     s = ""
    Else
     s = Trim$(rs("name"))
    End If
    Print #lFileHandle, sDist; "," + CStr(eType) + "," + CStr(eLen) + "," + sCoord + "," + s
    setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
    rs.MoveNext
Wend
rs.Close
Set rs = Nothing
End Sub

Private Function getPrigruzStartLen(rs As Recordset) As Long
Dim bk As Variant, startDist As Long, endDist As Long

getPrigruzStartLen = 0
bk = rs.Bookmark
startDist = rs("dist")

rs.FindNext "type=" & OBJ_endprgrz
If rs.NoMatch Then
 ogdWin.Alert _
   "Для начала участка пригрузов на отметке " & _
   mm2txt(trc.getDistKoef(startDist)) & _
   " м. не найден конец."
 rs.Bookmark = bk
 Exit Function
End If

endDist = rs("dist")

rs.FindPrevious "type=" & OBJ_startprgrz
If rs("dist") <> startDist Then
 ogdWin.Alert _
  "Между началами участка пригрузов на отметке " & _
  mm2txt(trc.getDistKoef(startDist)) & _
  " м. и на отметке " & _
  mm2txt(trc.getDistKoef(rs("dist"))) & _
  " м. нет конца участка пригрузов"
 Exit Function
End If

rs.Bookmark = bk
getPrigruzStartLen = endDist - startDist
End Function

Private Function getPrigruzEndLen(rs As Recordset) As Long
Dim bk As Variant, startDist As Long, endDist As Long

getPrigruzEndLen = 0
bk = rs.Bookmark
endDist = rs("dist")

rs.FindPrevious "type=" & OBJ_startprgrz
If rs.NoMatch Then
 ogdWin.Alert _
   "Для конца участка пригрузов на отметке " & _
   mm2txt(trc.getDistKoef(endDist)) & _
   " м. не найдено начало."
 Exit Function
End If

startDist = rs("dist")

rs.FindNext "type=" & OBJ_endprgrz
If rs("dist") <> endDist Then
 ogdWin.Alert _
  "Между концами участка пригрузов на отметке " & _
  mm2txt(trc.getDistKoef(rs("dist"))) & _
  " м. и на отметке " & _
  mm2txt(trc.getDistKoef(endDist)) & _
  " м. нет начала участка пригрузов"
 rs.Bookmark = bk
 Exit Function
End If

rs.Bookmark = bk
getPrigruzEndLen = endDist - startDist
End Function

Private Sub ExportVOGCoord(lFileHandle As Long, tHandle As Long)
Dim rs As Recordset
Dim sql As String
Dim node As T_NODEDATAGROUP
sql = "SELECT dist AS dist FROM common WHERE type NOT IN (" + _
 CStr(OBJ_runplace) + "," + _
 CStr(OBJ_getplace) + "," + _
 CStr(OBJ_thick) + "," + _
 CStr(OBJ_category) + "," + _
 CStr(OBJ_shov_b) + "," + _
 CStr(OBJ_shov_s) + "," + _
 CStr(OBJ_shov_p) + _
 ") AND dist>0 ORDER BY dist"
Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
While Not rs.EOF
    If krotGetFirstNodeGroup(tHandle, node, rs("dist"), SENS_VOG, 1, 1) = KRT_ERR Then
        ogdWin.Alert _
        "Ошибка драйвера при вызове krotGetFirstNodeGroup." & _
        vbNewLine & lastError()
        Exit Sub
    End If
    
    Print #lFileHandle, CStr(trc.getDistKoef(rs("dist"))) + "," + _
    CStr(Round(node.vogZ / 10)) + "," + _
    CStr(Round(node.vogx / 10)) + "," + _
    CStr(Round(node.vogy / 10))
    
    DoEvents
    
    setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
    rs.MoveNext
Wend
rs.Close
Set rs = Nothing
End Sub

' Precession  - точность, в минутах
Private Function Rad2Min(r As Single, Optional Precession As Long = 0) As Long
Dim l As Long
l = Round(60 * r * 180 / PI)
Rad2Min = IIf(Abs(l) < Precession, 0, l)
End Function

Private Function GetVOG_Z(tHandle As Long, dist As Long) As Long
Dim node As T_NODEDATAGROUP
    If krotGetFirstNodeGroup(tHandle, node, dist, SENS_VOG, 1, 1) = KRT_ERR Then
        ogdWin.Alert _
        "Ошибка драйвера при вызове krotGetFirstNodeGroup." & _
        vbNewLine & lastError()
        Exit Function
    End If
    GetVOG_Z = node.vogy
End Function

Private Sub ExportVOGPovorot(lFileHandle As Long, tHandle As Long)
On Error GoTo eh
Dim rs As Recordset
Dim sql As String
Dim d As Long, h As Long, l As Long, e As Long, delta As Long, delta1 As Long
Dim real_d As Long, real_l As Long, real_e As Long, calctyp As Integer

sql = "SELECT common.dist AS dist,typ,len,anglxy,anglz,xmark,ymark,zmark,name,userDist,userLen,linkedDist,calctyp " & _
"FROM common INNER JOIN turn ON common.dist=turn.dist WHERE " & _
"type=" & CStr(OBJ_povorot) & _
" AND common.dist>0 " & _
"ORDER BY common.dist"

'" AND (anglxy>0 OR anglz>0) " & _

Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

rs.filter = ""
real_e = 0

Print #lFileHandle, "VERSION2"

While Not rs.EOF
        
 calctyp = IIf(IsNull(rs("calctyp")), 0, rs("calctyp"))
 delta = 0
 delta1 = 0
 If calctyp = 1 Then
   delta = trc.pigL0 + trc.pigL1
   delta1 = trc.pigL0
 End If
 
 If GetDistCoord(tHandle, rs) Then Exit Sub
 
 real_d = rs("dist")
 real_l = rs("len")
 
 d = trc.getDistKoef(real_d)
 l = trc.getLenKoef(real_d, real_l)
 ' h - уклон в см на 100 м
 If (real_d = real_e) Then
  h = 0
 Else
  If trc.vog.enable Then
    h = (GetVOG_Z(tHandle, real_d) - GetVOG_Z(tHandle, real_e)) / (real_d - real_e) * 10000
  Else
    h = 0
  End If
 End If
 real_e = real_d + real_l
 Print #lFileHandle, CStr(d + delta1) + "," + _
        CStr(translateKrtTurnType2Tr(rs("typ"))) + "," + _
        CStr(l - delta) + "," + _
        CStr(Rad2Min(rs("anglxy"), 0)) + "," + _
        CStr(Rad2Min(rs("anglz"), 0)) + "," + _
        CStr(h) + "," + _
        sCoord + "," + _
        (rs("name") & "")
 setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
 rs.MoveNext
Wend
rs.Close

Set rs = Nothing
Exit Sub
eh:
    If Err.Number = 94 Then 'invalid use of null
        Resume Next
    Else
        MsgBox Err.Description, vbCritical
    End If
End Sub

Private Function getChainCurve(dst As Long, rs As Recordset) As Double
Dim bk As Variant, p1 As Long, p2 As Long, v As Double
Dim w As New clsAnglUnit

bk = rs.Bookmark
p1 = dst - VOG_SHIFT01 - trc.pigL0
If p1 < 0 Then p1 = 0
v = -1
While (Not rs.EOF) And (v = -1)
 v = IIf(IsNull(rs("curve")), -1, rs("curve"))
 rs.MoveNext
Wend

If rs.EOF Then
 rs.MoveLast
 Else
 rs.MovePrevious
End If

p2 = rs("dist") + trc.pigL1 - VOG_SHIFT01
If p2 > trc.length Then p2 = trc.length

w.radian = trc.vog.calcAngle(p1, p2)

rs.Bookmark = bk
getChainCurve = w.degree
End Function

Private Sub ExportWeld(lFileHandle As Long, tHandle As Long)
Dim rs As Recordset
Dim sql As String
Dim iType As EN_TR_WELD_TYPE
Dim w1 As New clsAnglUnit
Dim w2 As New clsAnglUnit
Dim tubeAngle As Double, weldAngle As Double, dst As Long, angCompl As Integer
Dim prevLen As Long
Dim chainInProgress As Boolean
Dim rsThick As Recordset, thickVal As String, thickDist As Long

Print #lFileHandle, "VERSION3"

sql = "SELECT thick.dist AS dist, thick FROM thick LEFT JOIN common ON common.dist=thick.dist WHERE common.type = " & OBJ_thick & " ORDER BY thick.dist"
Set rsThick = db.OpenRecordset(sql, dbOpenSnapshot)

If rsThick.RecordCount > 0 Then
 rsThick.MoveFirst
 thickDist = 0
 Else
 thickDist = trc.length
End If

thickVal = "0"

'sql = "SELECT common.dist AS dist,type,weld1,weld2,len,curve,angle,isComplexCurve " & _
'"FROM common  LEFT OUTER JOIN weld ON weld.dist=common.dist WHERE type IN (" + _
'CStr(OBJ_shov_b) + ", " + _
'CStr(OBJ_shov_s) + ", " + _
'CStr(OBJ_shov_p) + _
'") AND common.dist>0 ORDER BY common.dist"

sql = "SELECT weld.dist AS dist,type,weld1,weld2,len,curve,angle,isComplexCurve,name,tube_number,userDist,userLen,linkedDist " & _
 "FROM common RIGHT JOIN weld ON weld.dist=common.dist WHERE weld.dist>0 ORDER BY weld.dist"
Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
iType = WT_NORMAL

prevLen = 0
Do While Not rs.EOF

    dst = getDistFromRs(rs, trc.length)
    
    While thickDist < (dst + rs("len"))
    
     If Not rsThick.EOF Then
      thickVal = CStr(Round(rsThick("thick") * 100))
      rsThick.MoveNext
     End If
      
     If Not rsThick.EOF Then
      thickDist = rsThick("dist")
      Else
      thickDist = dst + rs("len")
     End If
     
    Wend
    
    If Not nWeldExpStatus Then
        If GetDistCoord(tHandle, rs) Then Exit Do
     Else
        If GetDistCoordVOGCSV(dst) Then Exit Do
    End If

    If trc.vog.enable Then

     'изгиб трубы
     w1.fullHour = IIf(IsNull(rs("curve")), -1, rs("curve"))
     If w1.fullHour = -1 Then
      If chainInProgress = False Then
       chainInProgress = True
       tubeAngle = getChainCurve(dst, rs)
       angCompl = 2
      End If
     Else
      chainInProgress = False
      tubeAngle = w1.degree
      angCompl = IIf(rs("isComplexCurve"), 1, 0)
     End If

     'угол стыка
     w1.fullHour = IIf(IsNull(rs("angle")), -1, rs("angle"))
     weldAngle = IIf(w1.fullHour = -1, -0.01, w1.degree)

    Else

     angCompl = 0
     tubeAngle = -0.01
     weldAngle = -0.01

    End If

    w1.fullHour = IIf(IsNull(rs("weld1")), -1, rs("weld1"))
    w2.fullHour = IIf(IsNull(rs("weld2")), -1, rs("weld2"))
    Select Case rs("type")
    Case OBJ_shov_p
        iType = WT_NORMAL
    Case OBJ_shov_s
        iType = WT_SPIRAL
    Case OBJ_shov_b
        iType = WT_NOSLIT
    Case OBJ_neopr_sektsiya
        iType = WT_NEOPR_SEKTSIYA
    Case OBJ_odoshovn
        iType = WT_ODNOSHOVN
    Case OBJ_dvuhshovn
        iType = WT_DVUHSHOVN
    Case OBJ_tubekran
        iType = WT_KRAN
    Case OBJ_tubetroynik
        iType = WT_TROYNIK
    
    End Select
    
    If Not IsNull(rs("len")) Then
      
      Print #lFileHandle, _
      sDist + "," + _
      CStr(iType) + _
      "," + w1.dStr + _
      "," + w2.dStr + _
      "," + Trim$(str$(Fix(tubeAngle * 100))) + _
      "," + Trim$(str$(Fix(weldAngle * 100))) + _
      "," + sCoord + "," + Trim(str$(angCompl)) + "," + thickVal + _
      "," + IIf(IsNull(rs("tube_number")), "", rs("tube_number")) + _
      "," + IIf(IsNull(rs("name")), "", rs("name"))
      
      setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
      prevLen = rs("len")
    End If
    
    rs.MoveNext
Loop
rs.Close
rsThick.Close

Set w1 = Nothing
Set w2 = Nothing
Set rs = Nothing
End Sub

Private Sub ExportLineObj(lFileHandle As Long, tHandle As Long)
Dim rs As Recordset
Dim sql As String, trace_dist As String, marker_text As String
Dim eType As EN_TR_LINEOBJ_TYPE


sql = "SELECT " & _
"common.dist AS dist, type,marker,marker_text,trace_dist,userDist,userLen,linkedDist, " & _
"common.name AS name " & _
"FROM objtypes RIGHT JOIN " & _
"(common LEFT JOIN lin_obj ON lin_obj.dist=common.dist) " & _
"ON objtypes.id=common.type " & _
"WHERE objtypes.tbl='" & OBJ_TBL_LINE & "' " & _
"AND common.dist>0 ORDER BY common.dist"

Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

Print #lFileHandle, "VERSION2"
While Not rs.EOF
    If GetDistCoord(tHandle, rs) Then Exit Sub
    
    Select Case rs("type")
    Case OBJ_waterin
        eType = LT_WATERIN
    Case OBJ_waterout
        eType = LT_WATEROUT
    Case OBJ_kran
        eType = LT_KRAN
    Case OBJ_marker
        eType = LT_MARKER
    Case OBJ_marktime
        eType = LT_MARKER
    Case OBJ_otvod
        eType = LT_OTVOD
    Case OBJ_patron_in
        eType = LT_PATRON_VHOD
    Case OBJ_patron_out
        eType = LT_PATRON_VIHOD
    Case OBJ_troynik
        eType = LT_TROYNIK
    Case OBJ_povorot
        eType = LT_SEGM_POVOROT_START
    Case OBJ_runplace
        eType = LT_KZ
    Case OBJ_getplace
        eType = LT_KP
    Case OBJ_tehokno
        eType = LT_TEHOKNO
    Case OBJ_mufta_nach
        eType = LT_MUFTA_NACH
    Case OBJ_mufta_kon
        eType = LT_MUFTA_KON
    Case OBJ_FLANGE
        eType = LT_FLANGE
    Case OBJ_IZOL_STYK
        eType = LT_IZOL_STYK
    Case OBJ_PATRON_MALOY_DLINY
        eType = LT_PATRON_MALOY_DLINY
    Case OBJ_HOMUT
        eType = LT_HOMUT
    Case OBJ_ZADVIZHKA
        eType = LT_ZADVIZHKA
    Case OBJ_MARKERN_KOLTSO
        eType = LT_MARKERN_KOLTSO
    Case OBJ_MARKER_MAGN
        eType = LT_MARKER_MAGN
    Case OBJ_ZAVARKA_BOBYSHKI
        eType = LT_ZAVARKA_BOBYSHKI
    Case OBJ_REM_NAKLADKA
        eType = LT_REM_NAKLADKA
    Case OBJ_OTREM_UCH
        eType = LT_OTREM_UCH
    Case OBJ_NERASPOZN_OBJ
        eType = LT_NERASPOZN_OBJ
    Case OBJ_TRUBN_ARMATURA
        eType = LT_TRUBN_ARMATURA
    Case OBJ_ELEM_OBUSTROISTVA
        eType = LT_ELEM_OBUSTROISTVA
    Case OBJ_NEDOPUSTIM_KONSTR_ELEM
        eType = LT_NEDOPUSTIM_KONSTR_ELEM
    Case OBJ_met_mufta_nach
        eType = LT_MET_MUFTA_NACH
    Case OBJ_diststart
        eType = LT_STARTDIST
    Case OBJ_distend
        eType = LT_ENDTDIST
    Case OBJ_met_mufta_kon
        eType = LT_MET_MUFTA_KON
    Case OBJ_looping_in
        eType = LT_LUPING_VHOD
    Case OBJ_looping_out
        eType = LT_LUPING_VIHOD
    Case Else
        eType = LT_MARKER

    End Select
    
    trace_dist = ""
    If Not IsNull(rs("trace_dist")) Then
      trace_dist = rs("trace_dist")
      If InStr(trace_dist, ",") > 0 Then
        trace_dist = Replace(trace_dist, ",", ".")
      End If
      trace_dist = Trim$(clearNewLine(trace_dist))
    End If
    
    marker_text = ""
    If Not IsNull(rs("marker_text")) Then
      marker_text = Trim$(clearNewLine(rs("marker_text")))
    End If
    
    Print #lFileHandle, _
        sDist + "," + _
        CStr(eType) + "," + _
        CStr(Abs(rs("marker"))) + "," + _
        marker_text + "," + _
        trace_dist + "," + _
        Trim$(sCoord) + "," + IIf(IsNull(rs("name")), "", rs("name"))
        
    setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
    rs.MoveNext
Wend
rs.Close

Set rs = Nothing
End Sub

Private Sub ExportCorrectionTable(lFileHandle As Long)
Dim rs As Recordset, sql As String

sql = "SELECT odo, rpt FROM distnode ORDER BY odo"
Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

Print #lFileHandle, "Mode " & trc.distMode & "; Start " & trc.odoStart & "; OdoKoef " & trc.odoKoef

While Not rs.EOF
 Print #lFileHandle, rs("odo") & " , " & rs("rpt")
 setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
 rs.MoveNext
Wend
rs.Close
End Sub

Private Sub ExportDefect(lFileHandle As Long, tHandle As Long)
Dim rs As Recordset
Dim sql As String
Dim eType As EN_TR_DEFECT_TYPE
Dim node As T_NODEDATAGROUP
Dim rLen As Long, rWidth As Long, rMin As Long, rInsideType As Long
Dim rMax As Long, rStart As New clsAnglUnit, rEnd As New clsAnglUnit
Dim rFeatClass As Long, ret As Integer
Dim comment As String

trc.db.featSizeRecalc

Print #lFileHandle, "VERSION3"

sql = "SELECT " & _
"common.dist AS dist, type, len, width, orient_s, orient_e,userDist,userLen,linkedDist, " & _
"value_min, value_max,insidetype, feat_size_id, common.name AS name " & _
"FROM objtypes RIGHT JOIN " & _
"(common LEFT JOIN defect ON defect.dist=common.dist) " & _
"ON objtypes.id=common.type " & _
"WHERE objtypes.tbl='" & OBJ_TBL_DFKT & "' " & _
"AND common.dist>0 ORDER BY common.dist"
Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

While Not rs.EOF
    If GetDistCoord(tHandle, rs) Then Exit Sub
     
    rLen = IIf(IsNull(rs("len")), 0, rs("len"))
    rWidth = IIf(IsNull(rs("width")), 0, rs("width"))
    rMin = IIf(IsNull(rs("value_min")), 0, rs("value_min"))
    rMax = IIf(IsNull(rs("value_max")), 0, rs("value_max"))
    
    rStart.fullHour = IIf(IsNull(rs("orient_s")), 0, rs("orient_s"))
    rEnd.fullHour = IIf(IsNull(rs("orient_e")), 0, rs("orient_e"))
     
    rMin = rMax
    rInsideType = IIf(IsNull(rs("insidetype")), IT_EXT, rs("insidetype"))
    comment = Trim(CStr(rs("name") & ""))
    eType = trDefektType(rs("type"))
    
    Select Case rs("type")
    
    Case OBJ_bad_styk
        rLen = 0
        'rWidth = 0
        rMin = 0
        rMax = 0
    
    Case OBJ_privarka
        rMin = 0
        rMax = 0
        
    Case OBJ_KORR_NA_KOLTSEV_SHVE
        rLen = 0
        'rWidth = 0
        rMin = 0
        rMax = 0
        
    Case OBJ_NEPROVAR_UTYAZHINA
        rLen = 0
        rWidth = 0
        rMin = 0
        rMax = 0
        
    Case OBJ_VISHLIV_PRODOLN_SHVA
        rWidth = 20
        rStart.fullHour = getNearProdolWeldOrient(rs("dist"), rs("orient_s"))
        rStart.fullMinute = rStart.fullMinute - 1
        rEnd.fullMinute = rStart.fullMinute + 2

    Case OBJ_ZASHLOFOVKA_PRODOLN_SHVA
        rWidth = 20
        rStart.fullHour = getNearProdolWeldOrient(rs("dist"), rs("orient_s"))
        rStart.fullMinute = rStart.fullMinute - 1
        rEnd.fullMinute = rStart.fullMinute + 2

    Case OBJ_FORM_PRODOLN_SHVA
        rWidth = 20
        rStart.fullHour = getNearProdolWeldOrient(rs("dist"), rs("orient_s"))
        rStart.fullMinute = rStart.fullMinute - 1
        rEnd.fullMinute = rStart.fullMinute + 2
    
    Case OBJ_ANOM_PROD_SHVA
        rWidth = 20
        'rInsideType = IT_NA
        rStart.fullHour = getNearProdolWeldOrient(rs("dist"), rs("orient_s"))
        rStart.fullMinute = rStart.fullMinute - 1
        rEnd.fullMinute = rStart.fullMinute + 2
    
    Case OBJ_ZAVARKA_PROD_SHVA
        rWidth = 20
        rStart.fullHour = getNearProdolWeldOrient(rs("dist"), rs("orient_s"))
        rStart.fullMinute = rStart.fullMinute - 1
        rEnd.fullMinute = rStart.fullMinute + 2
        comment = "продольного шва"
        
    End Select

    rFeatClass = getFeatClass4Defect(eType, rs("feat_size_id"), str(rMax))

    Print #lFileHandle, _
        sDist + "," + _
        CStr(eType) + "," + _
        CStr(trc.getLenKoef(rs("dist"), rLen)) + "," + _
        CStr(rWidth) + "," + _
        CStr(rInsideType) + "," + _
        CStr(rFeatClass) + ", " + _
        CStr(rMin) + "," + _
        CStr(rMax) + "," + _
        rStart.dStr + "," + _
        rEnd.dStr + "," + _
        sCoord + "," + _
        comment
    setWait "Выполнено: " + CStr(CInt(rs.PercentPosition)) + "%"
    rs.MoveNext
Wend
rs.Close
Set rStart = Nothing
Set rEnd = Nothing
Set rs = Nothing
End Sub

Private Function getNearProdolWeldOrient(ByVal dst As Long, ByVal ornt As Double) As Double
Dim ow As clsObjWeld, dlt1 As Double, dlt2 As Double

On Error GoTo errHandle
Set ow = trc.db.getTubeAtDist(dst)
On Error GoTo 0

'Debug.Print "stick ornt: " & dblStr(ornt, 2) & " w1: " & dblStr(ow.weld1, 2) & " w2: " & dblStr(ow.weld2, 2)

If ow.weld1 = -1 Then
  getNearProdolWeldOrient = ornt
  Exit Function
End If

If ow.weld2 = -1 Then
  getNearProdolWeldOrient = ow.weld1
  Exit Function
End If

dlt1 = Abs(ornt - ow.weld1)
If dlt1 > 6 Then dlt1 = 12 - dlt1

dlt2 = Abs(ornt - ow.weld2)
If dlt2 > 6 Then dlt2 = 12 - dlt2

If dlt1 < dlt2 Then
  getNearProdolWeldOrient = ow.weld1
Else
  getNearProdolWeldOrient = ow.weld2
End If

Exit Function

errHandle:
getNearProdolWeldOrient = ornt
End Function

Private Sub ExportVOGCSVData(lFileHandle As Long)
Dim intDist As Long
    intDist = v1
    While intDist <= v2
      If GetDistCoordVOGCSV(intDist) Then Exit Sub
      Print #lFileHandle, sDist + "," + sCoord
        
      setWait "Выполнено: " + CStr(CInt((intDist - v1) / (v2 - v1) * 100)) + "%"
      intDist = intDist + v3
    Wend

End Sub

Private Function GetDistCoordVOGCSV(dist As Long) As Boolean
Dim vogx As Long, vogy As Long, vogZ As Long
Dim vogext1 As Single, vogext2 As Single, vogext3 As Single
sDist = "" & trc.getDistKoef(dist)
trc.vog.getCoord dist, vogx, vogy, vogZ, vogext1, vogext2, vogext3
sCoord = _
 CStr(intDblStr(vogZ, 1, 0)) & "," & _
 CStr(intDblStr(vogx, 1, 0)) & "," & _
 CStr(intDblStr(vogy, 1, 0)) & "," & _
 CStr(CDec(vogext1)) & "," & _
 CStr(CDec(vogext2)) & "," & _
 CStr(CDec(vogext3))
End Function

Private Sub krt_lock()
If krotLockNodeSequence(trc.handle, 1) = KRT_ERR Then
    ogdWin.Alert "Не могу включить режим блокировки" & vbNewLine & lastError()
End If
End Sub

Private Sub krt_unlock()
If krotLockNodeSequence(trc.handle, 0) = KRT_ERR Then
    ogdWin.Alert "Не могу выключить режим блокировки" & vbNewLine & lastError()
End If
End Sub
