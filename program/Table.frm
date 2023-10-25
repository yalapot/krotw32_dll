VERSION 5.00
Object = "{00028CDA-0000-0000-0000-000000000046}#6.0#0"; "TDBG6.OCX"
Begin VB.Form frmTable 
   Caption         =   "Form1"
   ClientHeight    =   4065
   ClientLeft      =   1935
   ClientTop       =   4995
   ClientWidth     =   9810
   Icon            =   "Table.frx":0000
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   4065
   ScaleWidth      =   9810
   Begin VB.TextBox txtCell 
      Height          =   285
      Left            =   1440
      MaxLength       =   50
      TabIndex        =   8
      TabStop         =   0   'False
      Text            =   "Text1"
      Top             =   2640
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.CommandButton btmPrint 
      Caption         =   "Печать"
      Height          =   255
      Left            =   5400
      TabIndex        =   5
      Top             =   0
      Width           =   735
   End
   Begin TrueDBGrid60.TDBGrid grid 
      Bindings        =   "Table.frx":0442
      Height          =   2295
      Left            =   0
      OleObjectBlob   =   "Table.frx":0455
      TabIndex        =   0
      Top             =   360
      Width           =   9615
   End
   Begin VB.Data data 
      Caption         =   "Data1"
      Connect         =   "Access"
      DatabaseName    =   ""
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   300
      Left            =   120
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   2640
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.CheckBox chkSynhro 
      Caption         =   "Подлистывать"
      Height          =   255
      Left            =   6960
      TabIndex        =   6
      ToolTipText     =   "Подлистывать таблицу при передвижении по трассе"
      Top             =   0
      Width           =   1575
   End
   Begin VB.Label labNum 
      Caption         =   "999999"
      Height          =   255
      Left            =   6240
      TabIndex        =   7
      ToolTipText     =   "Количество строк в таблице"
      Top             =   0
      Width           =   615
   End
   Begin VB.Label Label1 
      Caption         =   "Фильтр обьектов"
      Height          =   255
      Left            =   0
      TabIndex        =   4
      Top             =   0
      Width           =   1575
   End
   Begin VB.Label labTube 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "все"
      Height          =   255
      Left            =   3600
      TabIndex        =   3
      Top             =   0
      Width           =   1815
   End
   Begin VB.Label Label2 
      Caption         =   "Трубы"
      Height          =   255
      Left            =   2520
      TabIndex        =   2
      Top             =   0
      Width           =   1095
   End
   Begin VB.Label labFilter 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "выключен"
      Height          =   255
      Left            =   1560
      TabIndex        =   1
      Top             =   0
      Width           =   975
   End
   Begin VB.Menu menuSet 
      Caption         =   "Установки"
      Begin VB.Menu mnuSet 
         Caption         =   "Фильтр обьектов"
         Index           =   0
         Shortcut        =   {F9}
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Фильтр длин"
         Index           =   1
         Shortcut        =   +{F9}
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Печать"
         Index           =   2
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Установка минут"
         Index           =   3
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Обновление списка обьектов"
         Index           =   4
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Сброс продольных швов"
         Index           =   5
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Сдвиг обьектов"
         Index           =   6
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Пересчет дистанций и длин"
         Index           =   7
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Пересчет поворотов"
         Index           =   8
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Колонки таблицы"
         Index           =   9
         Shortcut        =   ^C
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Импорт обьектов"
         Index           =   10
      End
      Begin VB.Menu mnuSet 
         Caption         =   "-"
         Index           =   11
      End
      Begin VB.Menu mnuSet 
         Caption         =   "Выход"
         Index           =   12
      End
   End
   Begin VB.Menu menuSingleObj 
      Caption         =   "Действия"
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Перейти"
         Index           =   0
         Shortcut        =   {F6}
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Изменить"
         Index           =   1
         Shortcut        =   {F4}
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Удалить"
         Index           =   2
         Shortcut        =   {F8}
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Изменение группы"
         Index           =   3
         Shortcut        =   {F2}
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Изменить без линзы"
         Index           =   4
         Shortcut        =   +{F4}
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Пересчитать класс размера"
         Index           =   5
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "-"
         Index           =   6
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Задать цвет"
         Index           =   7
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Сбросить цвет"
         Index           =   8
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "-"
         Index           =   9
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Привязать к ближайшему стыку"
         Index           =   10
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Отвязать от стыка"
         Index           =   11
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "-"
         Index           =   12
      End
      Begin VB.Menu mnuSingleObj 
         Caption         =   "Удаление группы"
         Index           =   13
         Shortcut        =   +{F8}
      End
   End
End
Attribute VB_Name = "frmTable"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Const COL_DIST = "userDist"

Private Const TBL_SYNC = "Synhro"
Private Const TBL_VSBL = "Visible"

'индексы колонок таблицы обьектов
Private Enum COL_INDEX
 C_DIST = 0              'дистанция
 C_IS_MARK = 1           'использовать как маркер?
 C_MARK_TEXT = 2         'наименование маркера
 C_OBJ_LEN = 3           'длина обьекта
 C_OBJ_TYPE = 4          'тип обьекта
 C_DFKT_WIDTH = 5        'ширина дефекта
 C_DFKT_ORNTS = 6        'начальная ориентация дефекта
 C_DFKT_ORNTE = 7        'конечная ориентация дефекта
 C_DFKT_VAL_MIN = 8      'минимальное значение глубины дефекта
 C_DFKT_VAL_MAX = 9      'максимальное значение глубины дефекта
 C_TURN_HOR = 10         'горизонтальный поворот?
 C_TURN_VER = 11         'вертикальный поворот?
 C_TURN_TYP = 12         'технологический поворот?
 C_TURN_XY = 13          'угол поворота в горизонтальной плоскости
 C_TURN_Z = 14           'угол поворота в вертикальной плоскости
 C_DFKT_INT = 15         'внутренний дефект?
 C_THICK = 16            'толщина стенки
 C_TURN_COMPL = 17       'комплексный изгиб трубы?
 C_TUBE_CURVE_D = 18     'радиус изгиба трубы
 C_TUBE_CURVE = 19       'угол изгиба трубы
 C_TUBE_ANGLE = 20       'угол стыка трубы
 C_CMNT = 21             'примечание
 C_TUBE_WELD1 = 22       'ориентация первого продольного шва
 C_TUBE_WELD2 = 23       'ориентация второго продольного шва
 C_OBJ_ID_TYPE = 24      'id типа обьекта
 C_FEAT_SIZE_NAME = 25   'название типа размера дефекта
 C_FEAT_SIZE_CODE_NAME = 26 'код размера дефекта
 C_TRACE_DIST = 27       'дистанция по трассе линейного обьекта
 C_TRACE_ATTENTION = 28  'отметка внимание
 C_TRACE_CREATEBY = 29   'автор
 C_TRACE_CREATEDATE = 30 'дата создания
 C_TRACE_EDITBY = 31     'редактор
 C_TRACE_EDITDATE = 32   'дата изменения
 C_TUBE_NUMBER = 33      'номер трубы
 C_ROW_COLOR = 34        'цвет строки
 C_RADS_XY = 35          'радиус поворота в горизонтальной плоскости
 C_RADS_Z = 36           'радиус поворота в вертикальной плоскости
 C_RADS_3D = 37          'радиус поворота в 3D
 C_CATEGORY = 38         'категория участка
 C_TURNCALCTYPE = 39     'тип расчета поворота
End Enum

Private WithEvents cObj As clsDb
Attribute cObj.VB_VarHelpID = -1
Private fTrace As frmTrace
Private fltrObj As String
Private curDist As Long
Private rsTable As Recordset, rsRecordset As Recordset
Private or1 As New clsAnglUnit
Private or2 As New clsAnglUnit
Private edtCmnt As New clsCommentEdit
Private frm As New clsFormProps

Private fltTube As New clsTubeFiltr
Private printFlag As Boolean
Private sortString As String
Private nextAfterDelete As Long
Private userColor As Long

Private waitDfktChange As Boolean
Private ignoreDataChange As Boolean
Private dfktEditDist As Long
Private selRow As New Collection
Private hlp As New clsHelp

Public Event formOFF()
Public Event updateData()
Public Event askFilter()
Public Event showObj(ByVal dst As Long)
Public Event delObj(ByVal dst As Long, ByVal askFlag As Boolean)
Public Event delObjRange()
Public Event edtObj(ByVal dst As Long, ByVal openWithoutZoom As Boolean)
Public Event edtCmnt(ByVal dst As Long, cmnt As String)
Public Event edtDfkt(ByVal dst As Long, d_type As EN_INT_TYPE)

Private popupMenuItem As Integer
Private popupMenuFlag As Boolean

Private Sub setCol( _
ByVal indx As COL_INDEX, _
ByVal sortField As String, _
ByVal isEnable As Boolean _
)
grid.Columns(indx).FooterDivider = isEnable
If Len(sortField) > 0 Then
 grid.Columns(indx).ButtonHeader = True
 grid.Columns(indx).FooterText = sortField
End If
End Sub

Public Sub Save()
If cObj.enable = False Then Exit Sub

frm.saveFormTable Me, grid
fTrace.trc.secUser.setInt frm.fullKey(TBL_SYNC), Me.chkSynhro.Value
fTrace.trc.secUser.setBool frm.fullKey(TBL_VSBL), Me.visible
End Sub

Public Sub Init(prntForm As frmTrace)
Dim ro As Boolean, vogFlag As Boolean

popupMenuFlag = False
printFlag = False
Set fTrace = prntForm
Set cObj = fTrace.trc.db

If cObj.enable = False Then Exit Sub

sortString = ""
hlp.BindHelp Me, KRT_ObjTable

userColor = vbCyan

frm.Init fTrace.trc.secUser, "frmObjects"
frm.restoreFormTable Me, grid
Me.chkSynhro.Value = fTrace.trc.secUser.getInt(frm.fullKey(TBL_SYNC), Me.chkSynhro.Value)

ro = cObj.isRO
data.Exclusive = ro
data.ReadOnly = ro

mnuSet(3).enabled = Not ro
mnuSet(4).enabled = Not ro
mnuSet(5).enabled = Not ro
mnuSet(6).enabled = Not ro
mnuSet(7).enabled = Not ro
mnuSet(8).enabled = (Not ro) And (fTrace.trc.vog.enable)
mnuSet(10).enabled = Not ro

mnuSingleObj(1).enabled = Not ro
mnuSingleObj(2).enabled = Not ro
mnuSingleObj(3).enabled = Not ro
mnuSingleObj(4).enabled = Not ro
mnuSingleObj(5).enabled = Not ro
mnuSingleObj(7).enabled = Not ro
mnuSingleObj(8).enabled = Not ro
mnuSingleObj(10).enabled = Not ro
mnuSingleObj(11).enabled = Not ro
mnuSingleObj(13).enabled = Not ro

edtCmnt.Init fTrace.trc
Me.Caption = "Обьекты " & fTrace.Caption
data.DatabaseName = cObj.Mdb

fltTube.tubeLen = 0
fltTube.tubeCompare = "="
fltTube.mode = TUBEF_OFF

switchLabFiltr cObj.filter
switchTubeFiltr fltTube
curDist = 0

vogFlag = fTrace.trc.vog.enable

setCol C_DIST, COL_DIST, True
setCol C_IS_MARK, "marker", True
setCol C_MARK_TEXT, "marker_text", True
setCol C_OBJ_LEN, "userLen", True
setCol C_OBJ_TYPE, "objtypes.name", True
'setCol C_DFKT_WIDTH, "userLen", True
setCol C_DFKT_WIDTH, "width", True
setCol C_DFKT_ORNTS, "", False
setCol C_DFKT_ORNTE, "", True
setCol C_DFKT_VAL_MIN, "", False
setCol C_DFKT_VAL_MAX, "value_max", True
setCol C_TURN_HOR, "horz", vogFlag
setCol C_TURN_VER, "vert", vogFlag
setCol C_TURN_TYP, "typ", vogFlag
setCol C_TURN_XY, "anglxy", vogFlag
setCol C_RADS_XY, "radxy", vogFlag 'радиус поворота в горизонтальной плоскости
setCol C_RADS_Z, "radz", vogFlag 'радиус поворота в вертикальной плоскости
setCol C_RADS_3D, "radcom", vogFlag 'радиус поворота в 3D
setCol C_TURNCALCTYPE, "calctyp", vogFlag
setCol C_TURN_Z, "anglz", vogFlag
setCol C_DFKT_INT, "insidetype", True
setCol C_THICK, "thick", True
setCol C_CATEGORY, "thick", True
setCol C_TURN_COMPL, "isComplexCurve", vogFlag
setCol C_TUBE_CURVE_D, "curve", vogFlag
setCol C_TUBE_CURVE, "curve", vogFlag
setCol C_TUBE_ANGLE, "angle", vogFlag
setCol C_CMNT, "common.name", True
setCol C_TUBE_WELD1, "", False
setCol C_TUBE_WELD2, "", False
setCol C_OBJ_ID_TYPE, "", False
setCol C_FEAT_SIZE_NAME, "dct_feat_size.name", True
setCol C_FEAT_SIZE_CODE_NAME, "dct_feat_size.code_name", True
setCol C_TRACE_DIST, "trace_dist", True

setCol C_TRACE_ATTENTION, "isAttention", True
setCol C_TRACE_CREATEBY, "createBy", True
setCol C_TRACE_CREATEDATE, "createDate", True
setCol C_TRACE_EDITBY, "editBy", True
setCol C_TRACE_EDITDATE, "editDate", True

setCol C_TUBE_NUMBER, "tube_number", True
setCol C_ROW_COLOR, "color", True

grid.FetchRowStyle = True
Me.formVisible = fTrace.trc.secUser.getBool(frm.fullKey(TBL_VSBL), False)
End Sub

Private Sub switchTubeFiltr(flt As clsTubeFiltr)
Dim a As New clsAnglUnit

Select Case flt.mode

 Case TUBEF_OFF
  labTube.Caption = "все"
  labTube.FontBold = False

 Case TUBEF_LENGTH
  labTube.Caption = flt.tubeCompare & " " & mm2txt(flt.tubeLen) & " м."
  labTube.FontBold = True

 Case TUBEF_CURVE
  a.degree = flt.tubeAngle
  labTube.Caption = "изгиб " & flt.tubeCompare & " " & rad2degree(a.radian)
  labTube.FontBold = True

 Case TUBEF_ANGLE
  a.degree = flt.tubeAngle
  labTube.Caption = "стык " & flt.tubeCompare & " " & rad2degree(a.radian)
  labTube.FontBold = True

 Case TUBEF_SLIT
  labTube.Caption = "продол.швы"
  labTube.FontBold = True

 Case TUBEF_DEFECT
  labTube.Caption = "сдвин.дефекты"
  labTube.FontBold = True

End Select

End Sub

Private Sub switchLabFiltr(fltStr As String)
fltrObj = fltStr
If fltrObj = "" Then
 labFilter.Caption = "выключен"
 labFilter.FontBold = False
 Else
 labFilter.Caption = "включен"
 labFilter.FontBold = True
End If
End Sub

Public Sub findObj(ByVal dst As Long)

If Me.visible = False Then
 Me.visible = True
 cObj_dataChange fltrObj, dst
End If

setWait "Поиск в таблице..."
data.Recordset.FindFirst "common.dist = " & dst
If data.Recordset.NoMatch Then
 If Not data.Recordset.EOF Then data.Recordset.MoveLast
 ogdWin.Alert "Обьект не найден в таблице." & vbNewLine & _
 "Возможно он не показан из-за текущих настроек фильтра."
End If
setReady
End Sub

Property Get formVisible() As Boolean
formVisible = Me.visible
End Property

Property Let formVisible(ByVal v As Boolean)
Me.visible = v
If Me.visible Then cObj_dataChange fltrObj, curDist
End Property

Private Function dataSrc() As String
Dim cmd As String, cmd1 As String
Dim a As New clsAnglUnit

If fltrObj = "" Then
 cmd = ""
 Else
 cmd = "WHERE common.type NOT IN (" & fltrObj & ") "
End If

Select Case fltTube.mode

 Case TUBEF_OFF
  cmd1 = ""

 Case TUBEF_LENGTH
  cmd1 = _
   " (userLen " & fltTube.tubeCompare & " " & fltTube.tubeLen & _
   " OR userLen Is Null) "

 Case TUBEF_CURVE
  a.degree = fltTube.tubeAngle
  cmd1 = _
   " (curve " & fltTube.tubeCompare & " " & a.fullHour & _
   " OR curve Is Null) "

 Case TUBEF_ANGLE
  a.degree = fltTube.tubeAngle
  cmd1 = _
   " (angle " & fltTube.tubeCompare & " " & a.fullHour & _
   " OR angle Is Null) "

 Case TUBEF_SLIT
  cmd1 = _
   " ((type=" & OBJ_shov_b & " AND (weld1 > -1 OR weld2 > -1)) OR " & _
   "  (type=" & OBJ_shov_p & " AND (weld1 < 0 AND weld2 < 0)) OR " & _
   "  (type=" & OBJ_shov_s & " AND (weld1 < 0 OR weld2 < 0)) ) "

 Case TUBEF_DEFECT
  cmd1 = " defect.dist<>(defect.ex1+defect.ix1)"

End Select

If cmd = "" Then
 If cmd1 = "" Then
  cmd = ""
  Else
  cmd = "WHERE " & cmd1
 End If
 Else
 If cmd1 = "" Then
  cmd = cmd
  Else
  cmd = cmd & " AND " & cmd1
 End If
End If

dataSrc = "SELECT " & _
"color, type, objtypes.name, tbl, common.dist, len, type, common.name, userLen, userDist, isAttention, createBy, createDate, editBy, editDate, " & _
"weld1, weld2, curve, angle, isComplexCurve, tube_number, " & _
"lin_obj.marker, lin_obj.marker_text, lin_obj.trace_dist, " & _
"defect.width, defect.orient_s, defect.orient_e, " & _
"defect.value_min, defect.value_max, defect.insidetype, " & _
"dct_feat_size.name as feat_size_name, dct_feat_size.code_name as feat_size_code_name, " & _
"turn.vert, turn.horz, turn.typ, turn.anglxy, turn.anglz, turn.radxy, turn.radz, turn.radcom, turn.calctyp, " & _
"thick " & _
"FROM " & _
"dct_feat_size RIGHT JOIN " & _
"(thick RIGHT JOIN " & _
"(turn RIGHT JOIN " & _
"(defect RIGHT JOIN " & _
"(lin_obj RIGHT JOIN " & _
"(weld RIGHT JOIN " & _
"(common LEFT JOIN objtypes ON common.type=objtypes.id) " & _
"ON weld.dist=common.dist) " & _
"ON lin_obj.dist=common.dist) " & _
"ON defect.dist=common.dist) " & _
"ON turn.dist=common.dist) " & _
"ON thick.dist=common.dist) " & _
"ON defect.feat_size_id=dct_feat_size.id " & _
cmd & "ORDER BY " & sortString & "common.dist"
End Function

Private Sub btmPrint_Click()
Dim xl As Object
Dim xlWB As Object
Dim xlSheet As Object
Dim sTmpFile As String, sString As String, sColName As String, sVal As String, wait_message As String
Dim i As Long, j As Long, nRows As Long, nCols As Long, lFileHandle As Long, Bmk As Variant
Dim v As Double, tmp As Variant, Value As Variant
Dim leftDist As Long, rightDist As Long, lstr As String, rstr As String
Dim a As New clsAnglUnit

setWait "Подготовка данных..."
sTmpFile = GetTempFile()
On Error GoTo eh

'rsTable.MoveFirst
'While Not rsTable.EOF
'    Debug.Print rsTable(0)
'    rsTable.MoveNext
'Wend
'grid.ExportBegin
'grid.ExportRows sTmpFile, False, 100
'grid.ExportToDelimitedFile sTmpFile, 0, "|"
'grid.ExportEnd

Set rsRecordset = data.Recordset.Clone

lFileHandle = FreeFile
Open sTmpFile For Output As lFileHandle
rsRecordset.MoveFirst
nRows = 0
wait_message = "Подготовка данных..." & rsRecordset.RecordCount & " / "

While Not rsRecordset.EOF
    setWait wait_message & nRows
    sString = ""
    For j = 0 To grid.Columns.count - 1
        If grid.Columns(j).visible Then
            'sColName = grid.Columns(j).DataField
            'If IsNull(rsTable(sColName)) Then
            '  sString = sString + "|"
            'Else
            '  sString = sString + CStr(rsTable(sColName)) + "|"
            'End If
            Select Case j
                Case C_DIST
                   sVal = intDblStr(rsRecordset("userDist"), 3, 2)
                   sString = sString & sVal & "|"
                Case C_MARK_TEXT 'маркер
                    leftDist = val(rsRecordset("userDist"))
                    rsTable.FindFirst "userDist=" & leftDist
                    tmp = rsTable("tbl")
                    Select Case tmp

                        Case OBJ_TBL_DFKT

                            If rsTable.RecordCount > 0 Then

                                rsTable.FindFirst "userDist > " & leftDist & " AND marker=True"
                                If rsTable.NoMatch Then
                                    rstr = ""
                                Else
                                    rstr = mm2txt(rsTable("userDist") - leftDist)
                                End If

                                rsTable.FindLast "userDist < " & leftDist & " AND marker=True"
                                If rsTable.NoMatch Then
                                    lstr = ""
                                Else
                                    lstr = mm2txt(leftDist - rsTable("userDist"))
                                End If
    
                            Else
     
                                rstr = ""
                                lstr = ""
    
                            End If
    
                            Value = lstr & " / " & rstr

                        Case OBJ_TBL_LINE
                            Value = IIf(IsNull(rsRecordset("marker_text")), "", rsRecordset("marker_text"))

                        Case Else
                            Value = ""

                    End Select
                    sString = sString & Value & "|"
                Case C_OBJ_LEN 'длина
                    Value = rsRecordset("userLen")
                    If Not (Value = "") Then
                        If Value = 0 Then
                          Value = ""
                        Else
                            Value = intDblStr(Value, 3, 2)
                        End If
                    End If
                    sString = sString & Value & "|"
                Case C_DFKT_WIDTH 'размер

                    Value = IIf(IsNull(rsRecordset("width")), "", rsRecordset("width"))
                    Select Case rsRecordset("type")
                        Case OBJ_prigruz
                            Value = mm2txt(rsRecordset("userLen"))

                        '   Case OBJ_thick
                        Case Else
                            If Not (Value = "") Then
                                tmp = rsRecordset("userLen")
                                Value = tmp & " x " & Value
                            End If
                    End Select
                    sString = sString & Value & "|"
                Case C_DFKT_ORNTE 'ориентация
                    Value = IIf(IsNull(rsRecordset("orient_e")), "", rsRecordset("orient_e"))
                    If Value = "" Then
                        lstr = ""
                        If Len(CStr(IIf(IsNull(rsRecordset("weld1")), "", rsRecordset("weld1")))) > 0 Then
                            v = rsRecordset("weld1")
                            If v >= 0 Then
                                or1.fullHour = v
                                lstr = or1.dStr
                            End If
                        End If

                        rstr = ""
                        If Len(CStr(IIf(IsNull(rsRecordset("weld2")), "", rsRecordset("weld2")))) > 0 Then
                            v = rsRecordset("weld2")
                            If v >= 0 Then
                                or2.fullHour = v
                                rstr = or2.dStr
                            End If
                        End If

                        If (Len(lstr) > 0) And (Len(rstr) > 0) Then
                            Value = lstr & " / " & rstr
                        Else
                            Value = lstr & rstr
                        End If

                    Else

                        or1.fullHour = IIf(IsNull(rsRecordset("orient_s")), "", rsRecordset("orient_s"))
                        or2.fullHour = Value
                        Value = or1.dStr & " - " & or2.dStr
                    End If
                    sString = sString & Value & "|"
                Case C_DFKT_VAL_MAX 'глубина
                    Value = IIf(IsNull(rsRecordset("value_max")), "", rsRecordset("value_max"))
                    'If Not (Value = "") Then
                    '    tmp = IIf(IsNull(rsRecordset("value_min")), "", rsRecordset("value_min"))
                    '    Value = tmp & " - " & Value
                    'End If
                    sString = sString & Value & "|"
                Case C_DFKT_INT 'положение дефекта
                    Value = IIf(IsNull(rsRecordset("insidetype")), "", rsRecordset("insidetype"))
                    Select Case Value
                        Case EN_INT_TYPE.IT_EXT
                            Value = "Внешний"
                        Case EN_INT_TYPE.IT_INT
                            Value = "Внутренний"
                        Case EN_INT_TYPE.IT_MID
                            Value = "Внутристенный"
                        Case EN_INT_TYPE.IT_NA
                            Value = "Не определено"
                    End Select
                    sString = sString & Value & "|"
                    
                Case C_TURN_TYP 'тип поворота
                
                    If IsNull(rsRecordset("typ")) Then
                      Value = ""
                    Else
                       Value = TurnTypeName(rsRecordset("typ"))
                    End If
                    sString = sString & Value & "|"

                Case C_TURN_XY 'угол поворота в XY
                    Value = IIf(IsNull(rsRecordset("anglxy")), "", rsRecordset("anglxy"))
                    If Not (Value = "") Then
                        Value = rad2degree(Value)
                    End If
                    sString = sString & Value & "|"

                Case C_TURN_Z 'угол поворота в Z
                    Value = IIf(IsNull(rsRecordset("anglz")), "", rsRecordset("anglz"))
                    If Not (Value = "") Then
                        Value = rad2degree(Value)
                    End If
                    sString = sString & Value & "|"
 
                Case C_TURNCALCTYPE 'тип расчета поворота
                    tmp = IIf(IsNull(rsRecordset("radxy")), 0, rsRecordset("radxy"))
                    sString = sString & tmp & "|"
                    Value = IIf(tmp = 1, "X", "")

                Case C_RADS_XY 'радиус поворота в горизонтальной плоскости
                    Value = IIf(IsNull(rsRecordset("radxy")), 0, rsRecordset("radxy"))
                    sString = sString & angle_label(Value, fTrace.trc.Diametr) & "|"

                Case C_RADS_Z 'радиус поворота в вертикальной плоскости
                    Value = IIf(IsNull(rsRecordset("radz")), 0, rsRecordset("radz"))
                    sString = sString & angle_label(Value, fTrace.trc.Diametr) & "|"

                Case C_RADS_3D 'радиус поворота в 3D
                    Value = IIf(IsNull(rsRecordset("radcom")), 0, rsRecordset("radcom"))
                    sString = sString & angle_label(Value, fTrace.trc.Diametr) & "|"
 
                Case C_TUBE_CURVE_D 'изгиб трубы, D
                    If Not (Value = "") Then
                        If Value = -1 Then
                            Value = "-"
                        Else
                            v = rsRecordset("userLen")
                            a.fullHour = Value
                            sString = sString & angle_label(v / a.radian, fTrace.trc.Diametr, True) & "|"
                        End If
                    End If
                
                Case C_TUBE_CURVE 'изгиб трубы, гр
                    Value = IIf(IsNull(rsRecordset("curve")), "", rsRecordset("curve"))
                    If Not (Value = "") Then
                        If Value = -1 Then
                            Value = "-"
                        Else
                            a.fullHour = Value
                            Value = rad2degree(a.radian)
                        End If
                    End If
                    sString = sString & Value & "|"
                
                Case C_TUBE_ANGLE 'угол стыка
                    Value = IIf(IsNull(rsRecordset("angle")), "", rsRecordset("angle"))
                    If Not (Value = "") Then
                        If Value = -1 Then
                            Value = "-"
                        Else
                            a.fullHour = Value
                            Value = rad2degree(a.radian)
                        End If
                    End If
                    sString = sString & Value & "|"
                    
                Case C_OBJ_TYPE
                    Value = IIf(IsNull(rsRecordset("objtypes.name")), "", rsRecordset("objtypes.name"))
                    sString = sString & Value & "|"
                    
                Case Else
                    sColName = grid.Columns(j).DataField
                    If IsNull(rsRecordset(sColName)) Then
                      sString = sString & "|"
                    Else
                      sString = sString & CStr(rsRecordset(sColName)) & "|"
                    End If
            End Select
            'sString = sVal + "|"
        End If
    Next j
    nRows = nRows + 1
    rsRecordset.MoveNext
    Print #lFileHandle, sString
Wend
'nRows = 0
'For i = 0 To data.Recordset.RecordCount - 1
'    sString = ""
'    For j = 0 To grid.Columns.count - 1
'        If grid.Columns(j).visible Then
'            Bmk = grid.GetBookmark(i)
'            sString = sString + grid.Columns(j).CellText(Bmk) + "|"
'        End If
'    Next j
'    nRows = nRows + 1
'    Print #lFileHandle, sString
'Next i
Close lFileHandle

setWait "Запуск Excel..."

Set xl = GetOLEObject("Excel.Application")
Set xlWB = xl.Workbooks.Add
While xlWB.Sheets.count > 1
    xlWB.Sheets(1).Delete
Wend
Set xlSheet = xlWB.Sheets(1)
xl.DisplayAlerts = False
xl.ScreenUpdating = False
xlSheet.Cells.NumberFormat = "@"

With xlSheet.QueryTables.Add(Connection:="TEXT;" + sTmpFile, Destination:= _
        xlSheet.Cells(2, 1))
        .name = "1"
        .FieldNames = True
        .RowNumbers = False
        .FillAdjacentFormulas = False
        .PreserveFormatting = True
        .RefreshOnFileOpen = False
        .RefreshStyle = 1 'xlInsertDeleteCells
        .saveData = True
        .TextFilePlatform = 1251
        .TextFileStartRow = 1
        .TextFileParseType = 1 'xlDelimited
        .TextFileConsecutiveDelimiter = False
        .TextFileTabDelimiter = False
        .TextFileSemicolonDelimiter = False
        .TextFileCommaDelimiter = False
        .TextFileSpaceDelimiter = False
        .TextFileOtherDelimiter = "|"
        .TextFileColumnDataTypes = Array(2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2)
        .Refresh BackgroundQuery:=False
End With

i = 0
For j = 0 To grid.Columns.count - 1
    If grid.Columns(j).visible Then
       i = i + 1
       xlSheet.Cells(1, i).Value = grid.Columns(j).Caption
       xlSheet.Cells(1, i).Font.Bold = True
    End If
Next j

nCols = i

For j = 7 To 12
    With xlSheet.Range(xlSheet.Cells(1, 1), xlSheet.Cells(nRows + 1, nCols)).Borders(j)
        .LineStyle = 1
        .Weight = 2
        .ColorIndex = -4105
    End With
Next j

Kill sTmpFile
xlSheet.Cells.EntireColumn.AutoFit
xlSheet.Cells.EntireColumn.HorizontalAlignment = 3 'xlCenter
xl.ScreenUpdating = True
xl.visible = True

On Error GoTo 0
setReady
Exit Sub
eh:
    ogdWin.Alert "Ошибка при экспорте таблицы:" & vbNewLine & Err.Description
    On Error GoTo 0
    setReady
End Sub

Private Sub btmPrint1_Click()
setWait "Подготовка страницы..."
On Error GoTo printErr
printFlag = True
With grid.PrintInfo
 .PreviewCaption = fTrace.trc.FileName
 .PageHeader = fTrace.trc.FileName
 .RepeatColumnHeaders = True
 .PageFooter = "\t" & "Страница:" & " \p"
 .PrintPreview
End With
printFlag = False
data.Recordset.MoveFirst
On Error GoTo 0
setReady
Exit Sub

printErr:
ogdWin.Alert "Ошибка при печати таблицы:" & vbNewLine & Err.Description
On Error GoTo 0
End Sub

Private Sub cObj_dataChange(fltStr As String, ByVal dst As Long)
Dim vogFlag As Boolean

If ignoreDataChange Then
 waitDfktChange = False
 ignoreDataChange = False
 Exit Sub
End If

switchLabFiltr fltStr
If dst < 0 Then
 dst = curDist
 Else
 curDist = dst
End If
If Me.visible = False Then Exit Sub

grid.Columns(C_DFKT_ORNTS).visible = False
grid.Columns(C_DFKT_VAL_MIN).visible = False
grid.Columns(C_TUBE_WELD1).visible = False
grid.Columns(C_TUBE_WELD2).visible = False
grid.Columns(C_OBJ_ID_TYPE).visible = False

vogFlag = fTrace.trc.vog.enable
grid.Columns(C_TURN_HOR).visible = vogFlag And grid.Columns(C_TURN_HOR).visible
grid.Columns(C_TURN_VER).visible = vogFlag And grid.Columns(C_TURN_VER).visible
grid.Columns(C_TURN_TYP).visible = vogFlag And grid.Columns(C_TURN_TYP).visible
grid.Columns(C_TURN_XY).visible = vogFlag And grid.Columns(C_TURN_XY).visible
grid.Columns(C_TURN_Z).visible = vogFlag And grid.Columns(C_TURN_Z).visible
grid.Columns(C_TURNCALCTYPE).visible = vogFlag And grid.Columns(C_TURNCALCTYPE).visible
grid.Columns(C_RADS_XY).visible = vogFlag And grid.Columns(C_RADS_XY).visible
grid.Columns(C_RADS_Z).visible = vogFlag And grid.Columns(C_RADS_Z).visible
grid.Columns(C_RADS_3D).visible = vogFlag And grid.Columns(C_RADS_3D).visible
grid.Columns(C_TURN_COMPL).visible = vogFlag And grid.Columns(C_TURN_COMPL).visible
grid.Columns(C_TUBE_CURVE_D).visible = vogFlag And grid.Columns(C_TUBE_CURVE_D).visible
grid.Columns(C_TUBE_CURVE).visible = vogFlag And grid.Columns(C_TUBE_CURVE).visible
grid.Columns(C_TUBE_ANGLE).visible = vogFlag And grid.Columns(C_TUBE_ANGLE).visible

setWait "Обновление таблицы..."
data.RecordSource = dataSrc()
data.Refresh

''''' не удалять, используется для восстановления данных при повреждении таблицы швов
'Dim lFileHandle As Long
'lFileHandle = FreeFile
'Open "export_data.txt" For Output As lFileHandle
'With data.Recordset
'Debug.Print "items: ", .RecordCount
'.MoveFirst
'While Not .EOF
' Print #lFileHandle, data.Recordset("type") & " " & data.Recordset("dist")
' .MoveNext
'Wend
'End With
'Close lFileHandle
'''''' python script
'import sys
'f = open(sys.argv[1], 'rt')
's = 'VERSION3'
'While s:
'  Print s
'  s = f.readLine()
'  if s:
'    typ , dist = s.Split()
'    s = '%d,%d,,,-1,-1,0,0,0,0,0,,' % (int(dist), int(typ) - 190)
'f.close()

If nextAfterDelete >= 0 Then
 dst = nextAfterDelete
 nextAfterDelete = -1
End If

Set rsTable = data.Recordset.Clone
data.Recordset.FindFirst "common.dist = " & dst
If data.Recordset.NoMatch Then
 data.Recordset.FindFirst "common.dist >= " & dst
 If data.Recordset.NoMatch Then
  If Not data.Recordset.EOF Then data.Recordset.MoveLast
 End If
End If
labNum.Caption = data.Recordset.RecordCount
setReady
End Sub

Private Sub cObj_dfktChange(ByVal dst As Long, dfkt As clsObjDefekt)
If waitDfktChange Then
 If dfktEditDist = dst Then
  'отредактировать текущую строку таблицы
  grid.Columns(C_DIST).Value = dfkt.objCommon.usrDist
  grid.Columns(C_OBJ_TYPE).Value = dfkt.objCommon.objTyp.id
  grid.Columns(C_OBJ_LEN).Value = dfkt.objCommon.usrLen
  grid.Columns(C_DFKT_WIDTH).Value = dfkt.dWidth
  grid.Columns(C_DFKT_ORNTS).Value = dfkt.dOrients
  grid.Columns(C_DFKT_ORNTE).Value = dfkt.dOriente
  grid.Columns(C_DFKT_VAL_MIN).Value = dfkt.dValMin
  grid.Columns(C_DFKT_VAL_MAX).Value = dfkt.dValMax
  
  grid.Columns(C_TRACE_ATTENTION).Value = dfkt.objCommon.isAttention
  grid.Columns(C_TRACE_EDITBY).Value = cObj.userName
  grid.Columns(C_TRACE_EDITDATE).Value = Now()
  
  grid.Update
  ignoreDataChange = True
 End If
End If
waitDfktChange = False
End Sub

Private Sub data_Reposition()
Dim enb As Boolean

If data.Recordset.EOF Then
 enb = False
 mnuSingleObj(0).enabled = False
 Else
 enb = Not cObj.isRO
 mnuSingleObj(0).enabled = True
End If
mnuSingleObj(1).enabled = enb
mnuSingleObj(2).enabled = enb
End Sub

Private Sub Form_Initialize()
nextAfterDelete = -1
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
If KeyCode = 122 Then ' F11
  frmMain.switchSinh
End If
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
If UnloadMode = vbFormControlMenu Then
 Cancel = True
 Me.visible = False
 RaiseEvent formOFF
End If
End Sub

Private Sub Form_Resize()
If Me.WindowState <> 1 Then
 grid.width = Me.ScaleWidth - grid.Left
 grid.Height = IIf(Me.ScaleHeight > grid.Top, Me.ScaleHeight - grid.Top, 1)
End If
End Sub

Private Sub grid_DblClick()
mnuSingleObj_Click 0
End Sub

Private Sub grid_FetchRowStyle(ByVal Split As Integer, Bookmark As Variant, ByVal RowStyle As TrueDBGrid60.StyleDisp)
On Error GoTo errHandl
rsTable.Bookmark = Bookmark
If rsTable.Fields("color") <> 0 Then
 RowStyle.BackColor = rsTable.Fields("color")
End If
Exit Sub

errHandl:
On Error GoTo 0
End Sub

Private Function filterType(v As Variant, Bookmark As Variant, typ As OBJ_TYPE) As String
Dim leftDist As Long, tmp As Variant

filterType = v
leftDist = grid.Columns(C_DIST).CellValue(Bookmark)
rsTable.FindFirst "userDist=" & leftDist
tmp = rsTable("type")
If tmp <> typ Then
 filterType = ""
End If
End Function

Private Sub grid_FormatText(ByVal ColIndex As Integer, Value As Variant, Bookmark As Variant)
Dim v As Double, tmp As Variant
Dim leftDist As Long, rightDist As Long, lstr As String, rstr As String
Dim a As New clsAnglUnit

If Bookmark = "" Then Exit Sub
If printFlag Then grid.Bookmark = Bookmark

On Error Resume Next

Select Case ColIndex

 Case C_OBJ_TYPE 'тип обьекта
  Dim typ As clsObjType
  Set typ = cObj.objTypes.Item(CStr(Value))
  Value = typ.name

 Case C_DIST 'дистанция
  Value = intDblStr(Value, 3, 3)

 Case C_MARK_TEXT 'маркер
  leftDist = grid.Columns(C_DIST).CellValue(Bookmark)
  rsTable.FindFirst "userDist=" & leftDist
  tmp = rsTable("tbl")
  Select Case tmp

   Case OBJ_TBL_DFKT

    If rsTable.RecordCount > 0 Then

     rsTable.FindFirst "userDist > " & leftDist & " AND marker=True"
     If rsTable.NoMatch Then
      rstr = ""
      Else
      rstr = mm2txt(rsTable("userDist") - leftDist)
     End If

     rsTable.FindLast "userDist < " & leftDist & " AND marker=True"
     If rsTable.NoMatch Then
      lstr = ""
      Else
      lstr = mm2txt(leftDist - rsTable("userDist"))
     End If
    
     Else
     
      rstr = ""
      lstr = ""
    
    End If
    
    Value = lstr & " / " & rstr

   Case OBJ_TBL_LINE
    Value = Value
'    tmp = grid.Columns(C_IS_MARK).CellValue(Bookmark)
'    If IsNull(tmp) Then
'      Value = ""
'    Else
'      If val(tmp) = 0 Then Value = ""
'    End If
    
   Case Else
    Value = ""

  End Select

 Case C_OBJ_LEN 'длина
 
  If Not (Value = "") Then
   If Value = 0 Then
    Value = ""
  '  Else
  '  Value = intDblStr(Value, 3, 2)
   End If
  End If

 Case C_DFKT_WIDTH 'размер

  If Not (Value = "") Then
   If Value = 0 Then
    Value = ""
   End If
  End If
  'Value = mm2txt(grid.Columns(C_DFKT_WIDTH).CellValue(Bookmark))
  'Select Case grid.Columns(C_OBJ_ID_TYPE).CellValue(Bookmark)

   'Case OBJ_prigruz
    'Value = mm2txt(grid.Columns(C_OBJ_LEN).CellValue(Bookmark))

'  ' Case OBJ_thick
   'Case Else
    'If Not (Value = "") Then
     'tmp = grid.Columns(C_OBJ_LEN).CellValue(Bookmark)
     'Value = tmp & " x " & Value
    'End If
  'End Select

 Case C_CATEGORY 'категория участка
  If Len(Value) > 0 Then
    Value = filterType(Value, Bookmark, OBJ_TYPE.OBJ_category)
  End If
  
 Case C_THICK 'переход толщины
  If Len(Value) > 0 Then
    Value = filterType(Value, Bookmark, OBJ_TYPE.OBJ_thick)
  End If
  
 Case C_DFKT_ORNTE 'ориентация
  If Value = "" Then

   lstr = ""
   If Len(grid.Columns(C_TUBE_WELD1).CellText(Bookmark)) > 0 Then
    v = grid.Columns(C_TUBE_WELD1).CellValue(Bookmark)
    If v >= 0 Then
     or1.fullHour = v
     lstr = or1.dStr
    End If
   End If

   rstr = ""
   If Len(grid.Columns(C_TUBE_WELD2).CellText(Bookmark)) > 0 Then
    v = grid.Columns(C_TUBE_WELD2).CellValue(Bookmark)
    If v >= 0 Then
     or2.fullHour = v
     rstr = or2.dStr
    End If
   End If

   If (Len(lstr) > 0) And (Len(rstr) > 0) Then
    Value = lstr & " / " & rstr
    Else
    Value = lstr & rstr
   End If

   Else

   or1.fullHour = grid.Columns(C_DFKT_ORNTS).CellValue(Bookmark)
   or2.fullHour = Value
   Value = or1.dStr & " - " & or2.dStr
  End If

 'Case C_DFKT_VAL_MAX 'глубина
 ' If Not (Value = "") Then
 '  tmp = grid.Columns(C_DFKT_VAL_MIN).CellValue(Bookmark)
 '  Value = tmp & " - " & Value
 ' End If
  
 Case C_DFKT_INT 'положение дефекта
  If Not (Value = "") Then
   Select Case Value
    Case EN_INT_TYPE.IT_EXT
     Value = "Внешний"
    Case EN_INT_TYPE.IT_INT
     Value = "Внутренний"
    Case EN_INT_TYPE.IT_MID
     Value = "Внутристенный"
    Case EN_INT_TYPE.IT_NA
     Value = "Не определено"
   End Select
  End If

 Case C_TURN_TYP 'тип поворота
  Value = TurnTypeName(Value)

 Case C_TURN_XY 'угол поворота в XY
  If Not (Value = "") Then
   Value = rad2degree(Value)
  End If

 Case C_TURN_Z 'угол поворота в Z
  If Not (Value = "") Then
   Value = rad2degree(Value)
  End If
 
 Case C_TURNCALCTYPE 'тип расчета поворота
  If Value = 1 Then
   Value = "X"
  Else
   Value = ""
  End If
 
 'радиус поворота в вертикальной плоскости
 'радиус поворота в горизонтальной плоскости
 'радиус поворота в 3D
 Case C_RADS_Z, C_RADS_XY, C_RADS_3D
  If Not (Value = "") Then
   Value = angle_label(Value, fTrace.trc.Diametr, True)
   'Value = Value / 1000#
  End If
 
 'изгиб трубы, D
 Case C_TUBE_CURVE_D
  If Not (Value = "") Then
   If Value = -1 Then
    Value = "-"
    Else
    v = grid.Columns(C_OBJ_LEN).CellValue(Bookmark)
    a.fullHour = Value
    Value = angle_label(v / a.radian, fTrace.trc.Diametr, True)
   End If
  End If
 
 Case C_TUBE_CURVE, C_TUBE_ANGLE 'изгиб трубы гр, угол стыка
  If Not (Value = "") Then
   If Value = -1 Then
    Value = "-"
    Else
    a.fullHour = Value
    Value = rad2degree(a.radian)
   End If
  End If

End Select

On Error GoTo 0
End Sub

Private Sub addSel(row As Variant)
Dim i As Variant, s As String, notFound As Boolean

s = str$(grid.Columns(C_DIST).CellValue(row))
notFound = False
On Error GoTo errNotFound
i = selRow.Item(s)
On Error GoTo 0

If notFound Then
 selRow.Add row, s
 Else
 selRow.Remove s
End If

For Each i In selRow
 grid.SelBookmarks.Add i
Next
Exit Sub

errNotFound:
notFound = True
Resume Next
End Sub

Private Sub grid_HeadClick(ByVal ColIndex As Integer)
If grid.Columns(ColIndex).ButtonHeader = False Then Exit Sub

setWait "Установка фильтра..."
sortString = getSortString(grid.Columns(ColIndex).FooterText)
cObj_dataChange fltrObj, curDist
setReady
End Sub

Private Function getSortString(fldSort As String)

If fldSort = COL_DIST Then
 getSortString = ""
 Exit Function
End If

If isShiftDown() Then
 getSortString = sortString & fldSort & ","
 Else
 getSortString = fldSort & ","
End If

End Function

Private Sub grid_RowColChange(LastRow As Variant, ByVal LastCol As Integer)
If chkSynhro.Value = 0 Then Exit Sub
grid_DblClick
End Sub

Private Sub txtCell_KeyPress(KeyAscii As Integer)
Select Case KeyAscii
 Case 27 'esc
  txtCell.visible = False
  grid.SetFocus
 Case 13 'enter
  If data.Recordset.EOF Then Exit Sub
  RaiseEvent edtCmnt(data.Recordset("dist"), txtCell.Text)
  txtCell.visible = False
  grid.SetFocus
  grid.Col = C_CMNT
End Select
End Sub

Private Sub txtCell_LostFocus()
txtCell.visible = False
End Sub

Private Sub grid_KeyPress(KeyAscii As Integer)
If (KeyAscii = Asc(" ")) And (grid.Col = C_CMNT) Then
 txtCell.Left = grid.Columns(grid.Col).Left
 txtCell.Top = grid.RowTop(grid.row) + grid.RowHeight
 txtCell.Height = grid.RowHeight
 txtCell.width = grid.Columns(grid.Col).width
 txtCell.Text = grid.Columns(grid.Col).CellValue(grid.Bookmark)
 txtCell.visible = True
 txtCell.SetFocus
End If
End Sub

Private Sub grid_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
If Button = 2 Then
  popupMenuFlag = True
  Me.popUpMenu menuSingleObj
  popupMenuFlag = False
  If popupMenuItem >= 0 Then
   mnuSingleObj_Click popupMenuItem
   popupMenuItem = -1
  End If
End If
End Sub

Private Sub labFilter_Click()
mnuSet_Click 0
End Sub

Private Sub labTube_Click()
mnuSet_Click 1
End Sub

Private Sub shiftObj()
Dim v1 As Long, v2 As Long

v1 = 0
v2 = 0
If frmInterval.getShift(Me, v1, v2) Then
 setWait "Сдвиг обьектов..."
 v1 = fTrace.trc.getDistReal(v1)
 v2 = fTrace.trc.getDistReal(v2)
 If cObj.shiftObjects(v1, v2) Then
  cObj.TubLengthRecalc
  Me.refreshData
  RaiseEvent updateData
 End If
 setReady
End If
End Sub

Private Sub mnuSet_Click(Index As Integer)
Dim i As Integer

Select Case Index

 Case 0 'фильтр обьектов
  RaiseEvent askFilter

 Case 1 'фильтр длин
  If frmTubeFiltr.Edit(fTrace, fltTube) = False Then Exit Sub
  setWait "Обновление таблицы..."
  Me.Refresh
  fTrace.Refresh
  switchTubeFiltr fltTube
  cObj_dataChange fltrObj, curDist
  setReady

 Case 2 'печать
  btmPrint_Click

 Case 3 'установка минут
  frmUtilMinute.setMinutes fTrace.trc
  cObj_dataChange fltrObj, curDist

 Case 4 'обновление обьектов
  setWait "Обновление списка обьектов..."
  cObj.updateObjects
  cObj_dataChange fltrObj, curDist
  fTrace.setMenuObjTypes
  setReady

 Case 5 'сброс продольных швов
  If ogdWin.AskAction( _
   "Данная операция уберет продольные швы у труб," & vbNewLine & _
   "в которых оба продольных шва имеют ориентацию 0 часов 0 минут." & vbNewLine & _
   "Продолжить?", _
  True) = False Then Exit Sub

  setWait "Сброс продольных швов..."
  cObj.dropSlits
  cObj_dataChange fltrObj, curDist
  setReady

 Case 6 'сдвиг обьектов
  shiftObj

 Case 7 'пересчет дистанций и длин
  If ogdWin.AskAction("Пересчитать расчетные дистанции и длины всех объектов в базе?") = False Then Exit Sub
  setWait "Пересчет длин труб..."
  cObj.TubLengthRecalc
  setWait "Обновление обьектов..."
  cObj.calcKoefData
  Me.refreshData
  RaiseEvent updateData
  setReady

 Case 8 'пересчет поворотов
  If ogdWin.AskAction("Пересчитать параметры всех поворотов в базе?") = False Then Exit Sub
  setWait "Пересчет поворотов..."
  cObj.TurnsRecalc fTrace.vog
  Me.refreshData
  RaiseEvent updateData
  setReady

 Case 9 'колонки таблицы
  If frmTableColumns.Edit(Me, grid.Columns) Then grid.Refresh

 Case 10 'импорт обьектов
  Dim fName As String, ret As String, f As Variant
  fName = ogdWin.fileOpen( _
   "Выберите файлы для импорта", _
   "", _
   "", _
   "Файлы обьектов (*.mdb)|*.mdb", _
   Me.hwnd) ', , True)
   
  If Len(fName) = 0 Then Exit Sub
  
  setWait "Импорт данных из '" & fName & "' ..."
  ret = importMdb(fName)
  setReady
  If Len(ret) > 0 Then
    ogdWin.Info ret
  End If
  
  'If Len(fName) > 0 Then
  ' For Each f In Split(fName)
  '  MsgBox f, vbOKOnly, "Import:"
  ' Next
  'End If

 Case 12 'выход
  Form_QueryUnload i, vbFormControlMenu

End Select
End Sub

Private Function importMdb(FileName As String) As String
Dim db As Database, impObj As Recordset, rs As Recordset
Dim cnt As Long, msg As String, cmd As String, errcount As Long
Dim obj As New clsObjCommon, objTyp As New clsObjType
Dim oLin As New clsObjLine, oThick As New clsObjThick, oDfkt As New clsObjDefekt, oTurn As New clsobjTurn, oWeld As New clsObjWeld

importMdb = ""
Set db = OpenDatabase(FileName, True, True)

On Error GoTo noIid
Set impObj = db.OpenRecordset("common", dbOpenTable)
impObj.Index = "iid"
On Error GoTo 0

If impObj.EOF And impObj.BOF Then
 db.Close
 Exit Function
End If

cnt = 0
errcount = 0
msg = "Импорт... " & impObj.RecordCount & " / "
impObj.MoveFirst
While Not impObj.EOF
 cnt = cnt + 1
 setWait msg & cnt
 
 cmd = "SELECT * FROM common LEFT JOIN objtypes ON common.type=objtypes.id WHERE dist=" & impObj("dist")
 Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
 
 objTyp.Init rs("id"), rs("objtypes.name"), rs("off"), rs("tbl")
 obj.Init fTrace.trc, 0, rs("len"), IIf(IsNull(rs("common.name")), "", rs("common.name")), rs("isAttention"), objTyp
 
 obj.usrDist = impObj("userDist")
 obj.usrLen = impObj("userLen")
 
 rs.Close
 If Len(obj.objTyp.tbl) > 0 Then
  Set rs = db.OpenRecordset("SELECT * FROM " & obj.objTyp.tbl & " WHERE dist=" & impObj("dist"), dbOpenSnapshot)
  rs.MoveFirst
 End If
 
 If cObj.objAdd(obj.objDist, obj.objLen, objTyp, True, True) Then
 
  Select Case obj.objTyp.tbl
  
   Case "lin_obj"
    'Debug.Print obj.objTyp.tbl & " " & obj.objDist & " marker " & rs("marker") & " name " & obj.comment
    oLin.Init _
     obj, _
     rs("marker"), _
     IIf(IsNull(rs("marker_text")), "", rs("marker_text")), _
     IIf(IsNull(rs("trace_dist")), "", rs("trace_dist"))
    cObj.objLineSet obj.objDist, oLin, True
    
   Case "defect"
    'Debug.Print obj.objTyp.tbl & " " & obj.objDist & " insidetype " & rs("insidetype") & " name " & obj.comment
    oDfkt.Init obj, _
     IIf(IsNull(rs("width")), 0, rs("width")), _
     IIf(IsNull(rs("orient_s")), 0, rs("orient_s")), _
     IIf(IsNull(rs("orient_e")), 0, rs("orient_e")), _
     IIf(IsNull(rs("value_min")), 0, rs("value_min")), _
     IIf(IsNull(rs("value_max")), 0, rs("value_max")), _
     IIf(IsNull(rs("insidetype")), 0, rs("insidetype")), _
     IIf(IsNull(rs("feat_size_id")), 0, rs("feat_size_id")), _
     IIf(IsNull(rs("ex1")), 0, obj.trc.getDistReal(rs("ex1") * impObj("userDist") / impObj("dist"))), _
     IIf(IsNull(rs("ex2")), 0, obj.trc.getDistReal(rs("ex2") * impObj("userDist") / impObj("dist"))), _
     IIf(IsNull(rs("ey1")), 0, rs("ey1")), _
     IIf(IsNull(rs("ey2")), 0, rs("ey2")), _
     IIf(IsNull(rs("ix1")), 0, rs("ix1")), _
     IIf(IsNull(rs("ix2")), 0, rs("ix2")), _
     IIf(IsNull(rs("iy1")), 0, rs("iy1")), _
     IIf(IsNull(rs("iy2")), 0, rs("iy2"))
    cObj.objDefectSet obj.objDist, oDfkt, True
    
   Case "thick"
    'Debug.Print obj.objTyp.tbl & " " & obj.objDist & " thick " & rs("thick") & " name " & obj.comment
    oThick.Init obj, 0, rs("thick"), 0, rs("pressure")
    cObj.objThickSet obj.objDist, oThick, True
    
   Case "weld"
    'Debug.Print obj.objTyp.tbl & " " & obj.objDist & " weld1 " & rs("weld1") & " name " & obj.comment
    oWeld.Init _
     obj, _
     IIf(IsNull(rs("weld1")), -1, rs("weld1")), _
     IIf(IsNull(rs("weld2")), -1, rs("weld2")), _
     IIf(IsNull(rs("curve")), 0, rs("curve")), _
     IIf(IsNull(rs("angle")), 0, rs("angle")), _
     rs("isComplexCurve"), _
     IIf(IsNull(rs("tube_number")), "", rs("tube_number"))
    cObj.objWeldSet obj.objDist, oWeld, True
    
   Case "turn"
    'Debug.Print obj.objTyp.tbl & " " & obj.objDist & " vert " & rs("vert") & " name " & obj.comment
    oTurn.Init _
     obj, _
     rs("vert"), _
     rs("horz"), _
     IIf(IsNull(rs("typ")), T_TURN_TYPE.NonTech, rs("typ")), _
     rs("startTune"), _
     rs("endTune"), _
     IIf(IsNull(rs("calctyp")), 0, rs("calctyp")), _
     IIf(IsNull(rs("radxy")), 0, rs("radxy")), _
     IIf(IsNull(rs("anglxy")), 0, rs("anglxy")), _
     IIf(IsNull(rs("radz")), 0, rs("radz")), _
     IIf(IsNull(rs("anglz")), 0, rs("anglz")), _
     IIf(IsNull(rs("xmark")), 0, rs("xmark")), _
     IIf(IsNull(rs("ymark")), 0, rs("ymark")), _
     IIf(IsNull(rs("zmark")), 0, rs("zmark"))
    cObj.objTurnSet obj.objDist, oTurn, True
    
   Case Else
    'Debug.Print "common" & obj.objDist & " type " & obj.objTyp.tbl & " name " & obj.comment
    cObj.objCommonSet obj.objDist, obj, False
    
  End Select
 
 Else
 
  errcount = errcount + 1
  If errcount < 11 Then
   cObj.objCommon impObj("dist"), obj
   importMdb = importMdb & obj.usrDist & " " & obj.objTyp.name & vbNewLine
  End If
  
 End If
 
 impObj.MoveNext
Wend

If errcount > 0 Then
 importMdb = _
  "Некоторые обьекты (" & errcount & ") не были импортированы." & _
  vbNewLine & _
  "На этих дистанциях уже есть следующие обьекты:" & _
  vbNewLine & vbNewLine & importMdb
End If

db.Close
setWait "Пересчет отметок и длин..."
cObj.calcKoefData
setWait "Пересчет длин труб..."
cObj.TubLengthRecalc
setWait "Обновление данных..."
RaiseEvent updateData
refreshData
Exit Function

noIid:
ogdWin.Alert _
 "База обьектов повреждена: " & vbNewLine & FileName & _
 vbNewLine & "Не найден индекс iid"
Exit Function
End Function

Private Sub mnuSingleObj_Click(Index As Integer)
Dim p As Long, cnt As Long, i As Long, bkm As Variant, msg As String, cur_color As Long
Dim arrDist() As Long

Static delInProgress As Boolean

If popupMenuFlag Then
 popupMenuItem = Index
 Exit Sub
End If

If data.Recordset Is Nothing Then Exit Sub
If data.Recordset.EOF Then Exit Sub
If delInProgress Then Exit Sub

delInProgress = True
On Error GoTo errHandl
p = data.Recordset("dist")

Select Case Index

 Case 0 'перейти
  RaiseEvent showObj(p)

 Case 1, 4 'изменить
  waitDfktChange = True
  dfktEditDist = p
  RaiseEvent edtObj(p, IIf(Index = 4, True, False))

 Case 2 'удалить
  ' сохранить позицию, куда перейти после удаления (с учетом сортировки обьектов)
  data.Recordset.FindFirst "common.dist = " & p
  data.Recordset.MoveNext
  If data.Recordset.EOF Then
    data.Recordset.MoveLast
    data.Recordset.MovePrevious
  End If
  If data.Recordset.BOF <> True Then
    nextAfterDelete = data.Recordset("dist")
  End If
  data.Recordset.FindFirst "common.dist = " & p
  
  setWait "Удаление ..."
  RaiseEvent delObj(p, True)
  setReady

 Case 3 'изменение группы
  If grid.SelBookmarks.count > 0 Then
    If frmCommentEdit.Edit(edtCmnt) Then updateComments edtCmnt
  Else
    ogdWin.Alert "Не выбрано ни одной строки таблицы."
  End If

 Case 13 'удаление группы

  cnt = grid.SelBookmarks.count
  If cnt > 0 Then

   If ogdWin.AskAction("Удалить выделенные обьекты (" & cnt & ") ?", True) Then
    setWait "Удаление группы..."
    ReDim arrDist(cnt) As Long
    i = 0
    For Each bkm In grid.SelBookmarks
     grid.Bookmark = bkm
     arrDist(i) = data.Recordset("dist")
     i = i + 1
    Next
    msg = "Удаление группы " & cnt & "/"
    For i = 0 To cnt - 1
     setWait msg & i
     cObj.objDel arrDist(i), True
    Next
    setReady
   End If

   Else

   If ogdWin.AskAction("Удалить все отображаемые в таблице обьекты?", True) Then
    setWait "Удаление группы..."
    RaiseEvent delObjRange
    setReady
   End If

  End If
  RaiseEvent updateData
  refreshData
  
 Case 7 'задать цвет
 
  cur_color = userColor
  If cur_color = 0 Then
   cur_color = data.Recordset("color")
  End If
  
  cur_color = ogdWin.selColor(cur_color)
  If cur_color >= 0 Then
    userColor = cur_color
    If grid.SelBookmarks.count > 0 Then
      For Each bkm In grid.SelBookmarks
        grid.Bookmark = bkm
        data.Recordset.Edit
        data.Recordset("color") = userColor
        data.Recordset.Update
      Next
    Else
      data.Recordset.Edit
      data.Recordset("color") = userColor
      data.Recordset.Update
    End If
    grid.Refresh
  End If
  
 Case 8 'сбросить цвет
  
  If grid.SelBookmarks.count > 0 Then
    msg = "Сбросить цвет выбранных строк?"
  Else
    msg = "Сбросить цвет выбранной строки?"
  End If
  
  If ogdWin.AskAction(msg) Then
   If grid.SelBookmarks.count > 0 Then
     For Each bkm In grid.SelBookmarks
        grid.Bookmark = bkm
        data.Recordset.Edit
        data.Recordset("color") = 0
        data.Recordset.Update
     Next
   Else
     data.Recordset.Edit
     data.Recordset("color") = 0
     data.Recordset.Update
   End If
   grid.Refresh
  End If
  
 Case 5 'пересчитать класс размера
  fTrace.trc.db.featSizeRecalc
  refreshData
    
 Case 10 'привязать к ближайшему стыку
  
  If ogdWin.AskAction("Привязать выбранные обьекты к ближайшим швам?") = False Then
    Exit Sub
  End If
  
  Dim rsWeld As Recordset
  
  Set rsWeld = cObj.db.OpenRecordset( _
  "SELECT weld.dist FROM weld LEFT JOIN common ON weld.dist=common.dist ORDER BY common.dist", _
  dbOpenSnapshot)
  
  nextAfterDelete = data.Recordset("dist")
  If grid.SelBookmarks.count > 0 Then
    cnt = grid.SelBookmarks.count
    setWait "Привязка..."
    i = 0
    For Each bkm In grid.SelBookmarks
      setWait "Привязка " & i & "/" & cnt
      grid.Bookmark = bkm
      cObj.objStick2Weld data.Recordset, rsWeld
      i = i + 1
    Next
    setReady
  Else
    cObj.objStick2Weld data.Recordset, rsWeld
  End If
  
  RaiseEvent updateData
  refreshData

 Case 11 'отвязать от стыка

  If ogdWin.AskAction("Отвязать выбранные обьекты от швов?") = False Then
    Exit Sub
  End If

  nextAfterDelete = data.Recordset("dist")
  If grid.SelBookmarks.count > 0 Then
    cnt = grid.SelBookmarks.count
    setWait "Привязка..."
    i = 0
    For Each bkm In grid.SelBookmarks
      setWait "Привязка " & i & "/" & cnt
      grid.Bookmark = bkm
      cObj.objUnStick2Weld data.Recordset
      i = i + 1
    Next
    setReady
  Else
    cObj.objUnStick2Weld data.Recordset
  End If
  
  RaiseEvent updateData
  refreshData

End Select

errHandl:
delInProgress = False
On Error GoTo 0
End Sub

Private Sub updateComments(cmntObj As clsCommentEdit)
Dim b As Variant, dst As Long, firstDist As Long

setWait "Обновление таблицы..."
Me.Refresh
firstDist = -1
For Each b In grid.SelBookmarks
 
 data.Recordset.FindFirst "userDist = " & grid.Columns(C_DIST).CellValue(b)
  If data.Recordset.NoMatch Then
  ogdWin.Alert "Can't find userDist = " & grid.Columns(C_DIST).CellValue(b)
  setReady
  Exit Sub
 End If
 
 dst = data.Recordset("dist")
 If firstDist = -1 Then firstDist = dst
 ignoreDataChange = True
 
 If cmntObj.is_comment Then
   RaiseEvent edtCmnt(dst, cmntObj.comment)
 End If
 If cmntObj.is_inside_type Then
   RaiseEvent edtDfkt(dst, cmntObj.inside_type)
 End If
 
Next

If cmntObj.is_comment Then
  RaiseEvent edtCmnt(dst, cmntObj.comment)
End If
If cmntObj.is_inside_type Then
  RaiseEvent edtDfkt(dst, cmntObj.inside_type)
End If

setReady
refreshData
End Sub

Public Sub refreshData()
data.Refresh
grid.Refresh
cObj_dataChange fltrObj, curDist
End Sub
