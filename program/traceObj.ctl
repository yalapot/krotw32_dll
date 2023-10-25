VERSION 5.00
Begin VB.UserControl traceObjects 
   ClientHeight    =   510
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   4365
   ScaleHeight     =   510
   ScaleWidth      =   4365
   ToolboxBitmap   =   "traceObj.ctx":0000
   Begin VB.PictureBox labbord 
      BorderStyle     =   0  'None
      Height          =   375
      Index           =   1
      Left            =   3840
      ScaleHeight     =   375
      ScaleWidth      =   495
      TabIndex        =   3
      Top             =   120
      Width           =   495
   End
   Begin VB.PictureBox labbord 
      BorderStyle     =   0  'None
      Height          =   375
      Index           =   0
      Left            =   240
      ScaleHeight     =   375
      ScaleWidth      =   375
      TabIndex        =   2
      Top             =   120
      Width           =   375
   End
   Begin VB.PictureBox dfltObj 
      Height          =   350
      Index           =   0
      Left            =   0
      ScaleHeight     =   285
      ScaleWidth      =   195
      TabIndex        =   0
      ToolTipText     =   "Обьект для вставки"
      Top             =   125
      Width           =   255
   End
   Begin VB.PictureBox objects 
      Height          =   400
      Left            =   600
      ScaleHeight     =   345
      ScaleWidth      =   1755
      TabIndex        =   1
      Top             =   90
      Width           =   1815
   End
End
Attribute VB_Name = "traceObjects"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private leftShiftBorder As Single
Private rsObjCount As Integer
Private visStart As Variant
Private visEnd As Variant
Private noDrawFlag As Boolean
Private poolVis As New Collection
Private picHWidth As Long
Private oldPos As Long
Private trc As clsTrace
Private normalColor As Long
Private pixRight As Integer
Private noFirstDistEvent As Boolean
Private dragFlag As Boolean
Private startDrag As Single
Private lastWeldEdit As Long

Public Event mouseMove(ByVal X As Long)
Public Event popUpMenu(ByVal X As Long)
Public Event objMenu(ByVal dst As Long)
Public Event objWeldEdit(ByVal dst As Long)
Public Event showObj(ByVal dst As Long, objPic As PictureBox, ByVal flash As Boolean)
Public Event showDefect(dfkt As clsObjDefekt)

Public Event showWeld( _
 ByVal dst As Long, _
 ByVal wldBefore1 As Double, _
 ByVal wldBefore2 As Double, _
 ByVal wldAfter1 As Double, _
 ByVal wldAfter2 As Double)

Public Event setMark(ByVal X As Long)
Public Event askFilter()
Public Event firstDist(ByVal dst As Long)
Public Event newObj(ByVal dst As Long)
Public Event setDfltObj(ByVal id As Integer)

Public Function Init( _
trace As clsTrace, _
ByVal leftShift As Single _
) As Boolean
Dim i As Integer

Init = False
noFirstDistEvent = False

leftShiftBorder = leftShift
Set trc = trace
noDrawFlag = False
normalColor = Objects.BackColor

For i = 1 To cfg.obj.maxNum
 Load dfltObj(i)
 dfltObj(i).BorderStyle = 0
Next i

lastWeldEdit = -1
End Function

Private Function selectMdb(newMdb As String, trcFile As String) As String
selectMdb = ""

newMdb = ogdWin.fileOpen( _
 "Выберите файл базы обьектов", _
 newMdb, _
 cfg.dir.trc, _
 "Файлы обьектов (*.mdb)|*.mdb", _
 frmMain.hWnd)

If newMdb = "" Then Exit Function
setIniItem trcFile, "Files", "Database", newMdb
selectMdb = newMdb
End Function

Private Function createNewMdb(newMdb As String, templateMdb As String, trcFile As String) As String
Dim ret As Integer

createNewMdb = ""

ret = ogdWin.AskYNC("Файл обьектов не найден: " & newMdb & vbNewLine & "Создать новый?")
Select Case ret
 Case vbYes
  newMdb = Left(trcFile, Len(trcFile) - 3) & "mdb"
  createNewMdb = makeNewMdb(newMdb, templateMdb)
  Exit Function
 Case vbNo
  createNewMdb = selectMdb(newMdb, trcFile)
  Exit Function
 Case vbCancel
  Exit Function
 Case Else
  Exit Function
End Select

End Function

Private Function twip2pos(x As Single) As Long
twip2pos = (x - startDrag - Objects.Left) * Objects.ScaleWidth / Objects.width + Objects.ScaleLeft
End Function

Private Sub dfltObj_MouseDown(Index As Integer, Button As Integer, Shift As Integer, x As Single, y As Single)
If Index = 0 Then Exit Sub
Select Case Button
 Case 1 'левая кнопка
   If trc.db.isRO Then Exit Sub
   dragFlag = True
   UserControl.MouseIcon = LoadResPicture(HAND_CURSOR, vbResCursor)
   UserControl.MousePointer = vbCustom
   startDrag = x - dfltObj(Index).width / 2
   'Debug.Print "drag start " & dfltObj(Index).Tag & " (" & twip2pos(dfltObj(Index).Left + dfltObj(Index).width / 2) & ")"
End Select
End Sub

Private Sub dfltObj_MouseMove(Index As Integer, Button As Integer, Shift As Integer, x As Single, y As Single)
Dim dst As Long

If Index = 0 Then Exit Sub
dst = val(dfltObj(Index).Tag)
RaiseEvent mouseMove(dst)

If dragFlag = True Then
 'Debug.Print "drag do " & twip2pos(dfltObj(Index).Left + x)
 objects_mouseMove 1, 0, twip2pos(dfltObj(Index).Left + x), 0
End If

If isControlDown() Then

 If lastWeldEdit <> dst Then
   trc.db.rsWeldTable.Seek "=", dst
   If trc.db.rsWeldTable.NoMatch = False Then
     lastWeldEdit = dst
     RaiseEvent objWeldEdit(dst)
     'Debug.Print "RaiseEvent objWeldEdit"
   End If
 End If
 
Else

 lastWeldEdit = -1

End If

End Sub

Private Function getDbVal(rs As Recordset, fld As String, dflt As Variant) As Variant
getDbVal = IIf(IsNull(rs(fld)), dflt, rs(fld))
End Function

Public Sub showAllObj()
Dim p As PictureBox, dst As Long, tTyp As Integer
Dim WA1 As Double, WA2 As Double, WB1 As Double, WB2 As Double
Dim dfkt As New clsObjDefekt, comn As New clsObjCommon, objTyp As New clsObjType, cmnt As String

For Each p In poolVis
 dst = Val(p.Tag)

 ' сместиться на него в общей таблице
 trc.db.rsObj.Seek "=", dst
 If trc.db.rsObj.NoMatch Then
 
   ogdWin.Alert "poolVis error: Can't find object at dist " & dst
 
 Else
   
   tTyp = trc.db.rsObj("type")
   cmnt = getDbVal(trc.db.rsObj, "name", "")
   objTyp.Init trc.db.rsObj("type"), cmnt, False, ""
   comn.Init trc, dst, getDbVal(trc.db.rsObj, "len", 0), cmnt, getDbVal(trc.db.rsObj, "isAttention", False), objTyp
 
   'смотрим, не дефект ли это
   trc.db.rsDefectTable.Seek "=", dst
   If trc.db.rsDefectTable.NoMatch = False Then
    dfkt.Init comn, _
     getDbVal(trc.db.rsDefectTable, "width", 0), _
     getDbVal(trc.db.rsDefectTable, "orient_s", 0), _
     getDbVal(trc.db.rsDefectTable, "orient_e", 0), _
     getDbVal(trc.db.rsDefectTable, "value_min", 0), _
     getDbVal(trc.db.rsDefectTable, "value_max", 0), _
     getDbVal(trc.db.rsDefectTable, "insidetype", 0), _
     getDbVal(trc.db.rsDefectTable, "feat_size_id", 0), _
     getDbVal(trc.db.rsDefectTable, "ex1", 0), _
     getDbVal(trc.db.rsDefectTable, "ex2", 0), _
     getDbVal(trc.db.rsDefectTable, "ey1", 0), _
     getDbVal(trc.db.rsDefectTable, "ey2", 0), _
     getDbVal(trc.db.rsDefectTable, "ix1", 0), _
     getDbVal(trc.db.rsDefectTable, "ix2", 0), _
     getDbVal(trc.db.rsDefectTable, "iy1", 0), _
     getDbVal(trc.db.rsDefectTable, "iy2", 0)
     RaiseEvent showDefect(dfkt)
   End If
 
   'смотрим, не шов ли это
   trc.db.rsWeldTable.Seek "=", dst
   If trc.db.rsWeldTable.NoMatch = False Then
 
     'выдать информацию о пересекающих его продольных и спиральных швах
     'на последующей трубе
     WA1 = IIf(IsNull(trc.db.rsWeldTable("weld1")), -1, trc.db.rsWeldTable("weld1"))
     Select Case tTyp
      Case OBJ_shov_s
       WA2 = -1
      Case Else
       WA2 = IIf(IsNull(trc.db.rsWeldTable("weld2")), -1, trc.db.rsWeldTable("weld2"))
     End Select

     'на предыдущей трубе
     trc.db.rsWeldTable.MovePrevious
     If trc.db.rsWeldTable.BOF Then
      WB1 = -1
      WB2 = -1
      Else
      trc.db.rsObj.Seek "=", trc.db.rsWeldTable("dist")
      If trc.db.rsObj.NoMatch Then
       WB1 = -1
       WB2 = -1
       ogdWin.Alert "В таблице common не найден обьект weld с дистанцией: " & trc.db.rsWeldTable("dist")
       Else
       tTyp = trc.db.rsObj("type")
       WB2 = IIf(IsNull(trc.db.rsWeldTable("weld2")), -1, trc.db.rsWeldTable("weld2"))
       Select Case tTyp
        Case OBJ_shov_s
         WB1 = -1
        Case Else
         WB1 = IIf(IsNull(trc.db.rsWeldTable("weld1")), -1, trc.db.rsWeldTable("weld1"))
       End Select
      End If
     End If
     RaiseEvent showWeld(dst, WB1, WB2, WA1, WA2)
   End If
 End If
 RaiseEvent showObj(dst, p, False)

Next
End Sub

Private Sub moveObject(source_dist As Long, target_dist As Long)
Dim objcmn As New clsObjCommon

If trc.db.objCommon(source_dist, objcmn) = False Then Exit Sub
If objcmn.moveTo(target_dist) = False Then Exit Sub
'Debug.Print "Move " & source_dist & " -> " & target_dist
End Sub

Private Sub dfltObj_MouseUp(Index As Integer, Button As Integer, Shift As Integer, x As Single, y As Single)
Dim newPos As Long, oldPos As Long

Select Case Button

 Case 1 'левая кнопка
  'иконка обьекта для вставки
  If Index = 0 Then
   showAllObj
   Exit Sub
  End If
  
  If dragFlag = True Then
   dragFlag = False
   UserControl.MousePointer = 0
   newPos = twip2pos(dfltObj(Index).Left + x)
   If (newPos > Objects.ScaleLeft) And (newPos < (Objects.ScaleLeft + Objects.ScaleWidth)) Then
     oldPos = CLng(dfltObj(Index).Tag)
     moveObject oldPos, newPos
     Me.Draw
     trc.db.move_Object oldPos, newPos
   End If
  End If
  
  'обьект в полосе
  Select Case Shift
   Case 0 'клик
   RaiseEvent showObj(dfltObj(Index).Tag, dfltObj(Index), True)
   Case 1 'нажат shift
   If Not trc.db.isRO Then
    trc.db.objDel dfltObj(Index).Tag
    Me.Draw
   End If
  End Select

 Case 2 'правая кнопка
 If Index = 0 Then
  RaiseEvent popUpMenu(-1)
  Else
  RaiseEvent objMenu(dfltObj(Index).Tag)
 End If

End Select
End Sub

Private Sub labbord_Click(Index As Integer)
If Index = 0 Then RaiseEvent askFilter
End Sub

Private Sub objects_mouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
RaiseEvent mouseMove(X)
End Sub

Private Sub UserControl_Initialize()
pixRight = 0
picHWidth = (dfltObj(0).width / 2)
End Sub

Private Sub UserControl_Resize()
Dim oldStart As Single, oldWidth As Single, wd As Single

oldStart = Objects.ScaleLeft
oldWidth = Objects.ScaleWidth

Objects.Left = leftShiftBorder
wd = UserControl.ScaleWidth - Objects.Left - pixRight * Screen.twipsPerPixelX
If wd <= 0 Then wd = 1
Objects.width = wd
If (Objects.Left > labbord(0).Left) Then labbord(0).width = Objects.Left - labbord(0).Left
labbord(1).Left = Objects.Left + Objects.width
UserControl.Height = Objects.Top + Objects.Height

Objects.ScaleLeft = oldStart
Objects.ScaleWidth = oldWidth

End Sub

Private Sub offAllObj()
Dim c As PictureBox, num As Integer

For num = 1 To poolVis.count
 Set c = poolVis(1)
 c.visible = False
 poolVis.Remove 1
Next
End Sub

Private Sub procVisibleObj()
Dim c As PictureBox, i As Integer, cnt As Integer, d As Long

cnt = poolVis.count
If cnt = 0 Then Exit Sub
i = 1
While i <= cnt
 Set c = poolVis(i)
 d = Val(c.Tag)
 trc.db.rsObj.Seek "=", d
 If trc.db.currObjVisible Then
  If (d > Objects.ScaleLeft) And (d < Objects.ScaleLeft + Objects.ScaleWidth) Then
   'c.Left = calcPos(d)
   c.Move calcPos(d)
   c.ToolTipText = makeToolTip(trc.db.rsObj)
   i = i + 1
   Else
   c.visible = False
   poolVis.Remove i
   cnt = cnt - 1
  End If
  Else
  c.visible = False
  poolVis.Remove i
  cnt = cnt - 1
 End If
Wend
labbord(0).ZOrder
labbord(1).ZOrder
End Sub

Private Function makeRsNewObj(ByVal pStart As Long, ByVal pLength As Long) As Boolean
Dim endPoint As Long, cnt As Long, startDist As Long

makeRsNewObj = True
visStart = Empty
visEnd = Empty
startDist = -1

trc.db.rsObj.Seek ">=", pStart
If trc.db.rsObj.NoMatch Then Exit Function
endPoint = pStart + pLength

If getDistFromRs(trc.db.rsObj, endPoint) >= endPoint Then Exit Function

visStart = trc.db.rsObj.Bookmark
startDist = trc.db.rsObj("dist")

cnt = 0
rsObjCount = 0
Do
 If trc.db.currObjVisible() Then cnt = cnt + 1
 visEnd = trc.db.rsObj.Bookmark
 
 trc.db.rsObj.MoveNext
 If trc.db.rsObj.EOF Then Exit Do

Loop While getDistFromRs(trc.db.rsObj, endPoint) < endPoint
rsObjCount = cnt

If cnt + poolVis.count > cfg.obj.maxNum Then
 notifyStateChange True
 makeRsNewObj = False
 Else
 notifyStateChange False
End If

If noFirstDistEvent Then Exit Function
If startDist >= 0 Then RaiseEvent firstDist(startDist)
End Function

Private Sub notifyStateChange(ByVal flagValue As Boolean)
If noDrawFlag Then
 If flagValue = False Then
  Objects.BackColor = normalColor
  noDrawFlag = False
 End If
Else
 If flagValue Then
  Objects.BackColor = color.noDataX
  noDrawFlag = True
 End If
End If
End Sub

Private Function refreshRs() As Boolean
offAllObj
refreshRs = makeRsNewObj(Objects.ScaleLeft, Objects.ScaleWidth)
End Function

Private Function shiftRs() As Boolean
Dim delta As Long

delta = Objects.ScaleLeft - oldPos

If Abs(delta) > Objects.ScaleWidth Then
 offAllObj
 shiftRs = makeRsNewObj(Objects.ScaleLeft, Objects.ScaleWidth)
 Exit Function
End If

If delta < 0 Then
 shiftRs = makeRsNewObj(Objects.ScaleLeft, -delta)
 Else
 shiftRs = makeRsNewObj(oldPos + Objects.ScaleWidth, delta)
End If
End Function

Public Sub Draw()
If trc Is Nothing Then Exit Sub
If trc.db.enable = False Then Exit Sub

dfltObj(0).Picture = LoadResPicture(trc.db.dfltObjType.Picture, vbResBitmap)
If trc.db.Filter = "" Then
 labbord(0).Picture = LoadResPicture(BMP_fltroff, vbResBitmap)
 labbord(0).ToolTipText = "Фильтр обьектов выключен"
 Else
 labbord(0).Picture = LoadResPicture(BMP_fltron, vbResBitmap)
 labbord(0).ToolTipText = "Фильтр обьектов включен"
End If

oldPos = trc.pageStart
Objects.ScaleLeft = oldPos
Objects.ScaleWidth = trc.pageLength

refreshRs
drawObj
Objects.Refresh
End Sub

Private Sub drawObj()
Dim dist As Long

If noDrawFlag Then
 offAllObj
 Exit Sub
End If
procVisibleObj

If IsEmpty(visStart) Then
 If trc.db.showForever Then Me.showAllObj
 Exit Sub
End If

If rsObjCount = 0 Then
 If trc.db.showForever Then Me.showAllObj
 Exit Sub
End If

trc.db.rsObj.Bookmark = visEnd
dist = trc.db.rsObj("dist")
trc.db.rsObj.Bookmark = visStart
While getDistFromRs(trc.db.rsObj, dist) <= dist
 makeVisible trc.db.rsObj
 trc.db.rsObj.MoveNext
 If trc.db.rsObj.EOF Then
  If trc.db.showForever Then Me.showAllObj
  Exit Sub
 End If
Wend
If trc.db.showForever Then Me.showAllObj
End Sub

Private Function makeToolTip(rs As Recordset) As String
Dim id As String, cmnt As String, strLen As String
Dim typ As clsObjType, is_ok As Boolean

makeToolTip = "Error"
is_ok = True

id = rs("type")
On Error GoTo notType
Set typ = trc.db.objTypes(id)
On Error GoTo 0

cmnt = "" & rs("name")
strLen = "" & IIf(rs("userLen") > 0, rs("userLen"), "")
If Len(strLen) > 0 Then strLen = " длина " & strLen & " мм"
If Len(cmnt) > 0 Then cmnt = " <" & cmnt & ">"

id = typ.name
Dim ext_str As String
ext_str = ""
Dim objCommon As New clsObjCommon
Select Case typ.tbl
  
  Case "thick"
    Dim objThick As New clsObjThick
    trc.db.objCommon rs("dist"), objCommon
    is_ok = trc.db.objThick(objCommon, objThick)
    ext_str = " (" & objThick.dThickPrev & " <- " & objThick.dThick & " -> " & objThick.dThickNext & ")"
  
  Case "defect"
    Dim objDfct As New clsObjDefekt
    trc.db.objCommon rs("dist"), objCommon
    is_ok = trc.db.objDefect(objCommon, objDfct)
    strLen = " " & objDfct.dValMax & "%"

End Select

If is_ok Then
  makeToolTip = id & " на " & mm2txt(rs("userDist")) & strLen & cmnt & ext_str
End If
notType:
On Error GoTo 0
End Function

Private Function makeVisible(rs As Recordset) As Boolean
Dim pic As PictureBox, ttip As String

If trc.db.currObjVisible() = False Then Exit Function

ttip = makeToolTip(rs)
If ttip = "Error" Then Exit Function

Set pic = getFreePicture()
pic.Tag = rs("dist")

pic.ToolTipText = ttip
pic.Picture = LoadResPicture(trc.db.dfltObjType.ObjPicture(rs("type")), vbResBitmap)
pic.Left = calcPos(val(pic.Tag))
poolVis.Add pic
pic.ZOrder
pic.visible = True
labbord(0).ZOrder
labbord(1).ZOrder
End Function

Private Function calcPos(ByVal pos As Long) As Single
calcPos = Objects.Left + (Objects.width / Objects.ScaleWidth * (pos - Objects.ScaleLeft)) - picHWidth
End Function

Private Function getFreePicture() As PictureBox
Dim i As Integer

For i = 1 To cfg.obj.maxNum
 If dfltObj(i).visible = False Then
  Set getFreePicture = dfltObj(i)
  Exit Function
 End If
Next i
Err.Raise ERR_FREEPICT, "traceobjects.getFreePicture", "Нет свободных пикчурбоксов!!!"
End Function

Private Sub objects_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
Dim db As clsDb, typ As OBJ_TYPE, tbl As String
Dim objTyp As New clsObjType

Set db = trc.db

With db

If .isRO Then Exit Sub

Select Case Button
 Case 1
  typ = .dfltObjType.id
  tbl = .dfltObjType.tbl
  If IsKeyPressed(VK_S) Then
    typ = OBJ_TYPE.OBJ_shov_s
    tbl = "weld"
  End If
  If IsKeyPressed(VK_P) Then
    typ = OBJ_TYPE.OBJ_shov_p
    tbl = "weld"
  End If
  If IsKeyPressed(VK_B) Then
    typ = OBJ_TYPE.OBJ_shov_b
    tbl = "weld"
  End If
  objTyp.Init typ, "", False, tbl
  If .objAdd(x, IIf(objTyp.id = OBJ_prigruz, .prigruzLength, 0), objTyp) = False Then Exit Sub
  RaiseEvent setDfltObj(objTyp.id)
  RaiseEvent newObj(x)
 Case 2
  RaiseEvent popUpMenu(X)
End Select

End With
End Sub

Public Sub showObject(ByVal dst As Long)
Dim p As PictureBox

For Each p In poolVis
 If Val(p.Tag) = dst Then
  RaiseEvent showObj(p.Tag, p, True)
  Exit Sub
 End If
Next
End Sub

Property Get pixelRight() As Integer
pixelRight = pixRight
End Property

Property Let pixelRight(p As Integer)
pixRight = p
UserControl_Resize
End Property