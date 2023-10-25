VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDb"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const OBJ_FILTR = "objFiltr"
Private Const OBJ_DFLT = "objDflt"
Private Const OBJ_SHOW = "Show"
Private Const OBJ_STAT = "Stat"
Private Const FL_ITM_DATABASE = "Database"

'старые ключи trc, перенесенные в trcConfig
Private Const TR_ITM_DISTMODE = "DistMode"
Private Const TR_ITM_ODOKOEF = "OdoKoef"
Private Const TR_ITM_ODOSTART = "OdoStart"

Private d_distMode As Integer
Private d_odoKoef As Double
Private d_odoStart As Long
Private isNeedKoefRecalc As Boolean

Private trc As clsTrace
Private iniKey As String
Private types As New Collection
Private filtrType As String
Private d_isEnable As Boolean
Private d_isVisible As Boolean
Private d_mdb As String
Private d_ro As Boolean
Private dfltThick As Double

Private rsDistOdo As Recordset
Private rsDistRpt As Recordset
Public rEdit As New clsRsetEdit
Private traceExport As New clsExport

Public db As Database
Public rsObj As Recordset
Public rsWeldTable As Recordset
Public rsDefectTable As Recordset
Public rsConfig As Recordset
Public showForever As Boolean
Public dfltObjType As New clsObjType
Public prigruzLength As Long
Public userName As String
Public dfltTurnType As T_TURN_TYPE

Public Event sbMessage(ByVal ready As Boolean, msg As String)
Public Event dataChange(fltStr As String, ByVal dst As Long)
Public Event eraseObjects()
Public Event dfktChange(ByVal dst As Long, dfkt As clsObjDefekt)
Public Event moveObject(ByVal src_dist As Long, ByVal target_dist As Long)

Public Sub Init(trace As clsTrace, ByVal iniKeyName As String)
Set db = Nothing
Set trc = trace
iniKey = iniKeyName

d_isEnable = cfg.obj.dbLine
If Me.enable = False Then Exit Sub

d_mdb = trc.getPathFull(trc.secFiles.getStr(FL_ITM_DATABASE, ""))
d_isVisible = trc.getUserBool(iniKey & OBJ_STAT, True)
showForever = trc.getUserBool(iniKey & OBJ_SHOW, False)

dfltThick = trc.drv.wallThick
prigruzLength = 500

If Not ogdWin.fExist(d_mdb) Then
 ogdWin.Alert "У записи не установлен файл базы обьектов" & _
   vbNewLine & "Полоса расшифровки отключена."
 d_isEnable = False
 Exit Sub
End If
d_isEnable = mdbSet(d_mdb)

If Me.enable = False Then Exit Sub

Me.userName = CurrentUserName()
Me.dfltType = trc.getUser(iniKey & OBJ_DFLT, OBJ_anomal)
Me.Filter = trc.getUser(iniKey & OBJ_FILTR, "")
Me.dfltTurnType = T_TURN_TYPE.Holod_gnut

If d_ro = False Then
 d_ro = trc.isMdbRO
End If
End Sub

Public Sub Save()
trc.secFiles.setStr FL_ITM_DATABASE, trc.getPathPack(Me.Mdb)
trc.setUserBool iniKey & OBJ_STAT, Me.visible
trc.setUserBool iniKey & OBJ_SHOW, showForever
trc.setUser iniKey & OBJ_DFLT, Me.dfltType
trc.setUser iniKey & OBJ_FILTR, Me.Filter
End Sub

Public Sub off()
d_isEnable = False
End Sub

Property Get enable() As Boolean
enable = d_isEnable
End Property

Property Get visible() As Boolean
visible = IIf(Me.enable, d_isVisible, False)
End Property

Property Let visible(v As Boolean)
d_isVisible = v
End Property

Property Get Mdb() As String
Mdb = d_mdb
End Property

Property Let Mdb(m As String)
If Me.Mdb = trc.getPathFull(m) Then Exit Property
If Len(m) > 0 Then
 trc.secFiles.setStr FL_ITM_DATABASE, m
 d_mdb = trc.getPathFull(m)
 mdbSet d_mdb
End If
End Property

Property Get isRO() As Boolean
isRO = d_ro
End Property

Public Function mdbSet(mdbFile As String) As Boolean
Dim cmd() As String, tmp As Variant, dbPatch() As String, tmpRs As Recordset

isNeedKoefRecalc = False
ReDim cmd(2) As String

mdbSet = False
Me.CloseDb

If tryOpenDbRW(mdbFile) = False Then
 d_ro = True
 On Error GoTo dbDamage
 Set db = OpenDatabase(mdbFile, True, True)
 On Error GoTo 0
 ogdWin.Alert "База обьектов доступна только для чтения." & _
  vbNewLine & "Создание, изменение и удаление обьектов невозможно."
 Else
 d_ro = False
End If

If cfg.obj.updt > 0 Then updateObjects

'проверка на версии мдб и реконструкция на ходу.
On Error GoTo dbStructPatch01
tmp = db.TableDefs("defect").Fields("ex1").Type
On Error GoTo dbStructPatch02
tmp = db.TableDefs("distnode").Fields("rpt").Type
On Error GoTo dbStructPatch03
tmp = db.TableDefs("weld").Fields("weld1").Type
On Error GoTo dbStructPatch04
tmp = db.TableDefs("weld").Fields("isComplexCurve").Type
On Error GoTo dbStructPatch05
tmp = db.TableDefs("common").Fields("len").Type
On Error GoTo dbStructPatch06
tmp = db.TableDefs("turn").Fields("typ").Type
On Error GoTo dbStructPatch07
tmp = db.TableDefs("common").Fields("[name]").size + 1
tmp = Fix(tmp / CMNT_LENGTH)
tmp = 1 / tmp

tmp = -1
On Error Resume Next
tmp = db.TableDefs("thick").Fields("steel").size
On Error GoTo dbStructPatch08
If tmp >= 0 Then tmp = tmp / 0

On Error GoTo dbStructPatch09
tmp = db.TableDefs("trcConfig").Fields("distMode").type
Set tmpRs = db.OpenRecordset("select count(*) as cnt from common where userDist is null or userLen is null", dbOpenSnapshot)
If tmpRs("cnt") > 0 Then isNeedKoefRecalc = True
tmpRs.Close

On Error GoTo dbStructPatch10
Set tmpRs = db.OpenRecordset("SELECT count(*) as cnt FROM objtypes WHERE id BETWEEN 163 AND 165", dbOpenSnapshot)
If tmpRs("cnt") <> 3 Then Err.Raise 11

On Error GoTo dbStructPatch11
tmp = db.TableDefs("defect").Fields("feat_size_id").type

On Error GoTo dbStructPatch12
tmp = db.TableDefs("defect").Fields("insidetype").type

On Error GoTo dbStructPatch13
Set tmpRs = db.OpenRecordset("SELECT count(*) as cnt FROM objtypes WHERE id BETWEEN 200 AND 202", dbOpenSnapshot)
If tmpRs("cnt") <> 3 Then Err.Raise 11

On Error GoTo dbStructPatch14
Set tmpRs = db.OpenRecordset("SELECT count(*) as cnt FROM objtypes WHERE id = 4", dbOpenSnapshot)
If tmpRs("cnt") <> 1 Then Err.Raise 11

On Error GoTo dbStructPatch15
tmp = db.TableDefs("common").Fields("isAttention").type

On Error GoTo dbStructPatch16
tmp = db.TableDefs("weld").Fields("tube_number").type

On Error GoTo dbStructPatch17
tmp = db.TableDefs("common").Fields("color").type

On Error GoTo dbStructPatch18
Set tmpRs = db.OpenRecordset("SELECT count(*) as cnt FROM objtypes WHERE id = 141", dbOpenSnapshot)
If tmpRs("cnt") < 1 Then Err.Raise 11

On Error GoTo dbStructPatch19
Set tmpRs = db.OpenRecordset("SELECT count(*) as cnt FROM objtypes WHERE id = 35", dbOpenSnapshot)
If tmpRs("cnt") < 1 Then Err.Raise 11

On Error GoTo dbStructPatch20
Set tmpRs = db.OpenRecordset("SELECT count(*) as cnt FROM objtypes WHERE id = 226", dbOpenSnapshot)
If tmpRs("cnt") < 1 Then Err.Raise 11

On Error GoTo dbStructPatch21
Set tmpRs = db.OpenRecordset("SELECT count(*) as cnt FROM objtypes WHERE id = 234", dbOpenSnapshot)
If tmpRs("cnt") < 1 Then Err.Raise 11

On Error GoTo dbStructPatch22
tmp = db.TableDefs("common").Fields("linkedDist").type

On Error GoTo dbStructPatch23
tmp = db.TableDefs("thick").Fields("pressure").type

On Error GoTo dbStructPatch24
tmp = db.TableDefs("turn").Fields("calctyp").type

On Error GoTo dbStructPatch25
tmp = db.TableDefs("turn").Fields("radcom").type

On Error GoTo 0

'здесь вставить проверку на валидность мдбшника и
'соответствие его текущей записи (расстояния и т.п.)

fillTypes
Set rsObj = db.OpenRecordset("common", dbOpenTable)
Set rsWeldTable = db.OpenRecordset("weld", dbOpenTable)
Set rsDefectTable = db.OpenRecordset("defect", dbOpenTable)
Set rsConfig = db.OpenRecordset("trcConfig", dbOpenTable)

setCfgRS
setDistRS

'обработка отсутствия индекса iid
On Error GoTo noIid
rsObj.Index = "iid"
On Error GoTo 0
rsWeldTable.Index = "iid"
rsDefectTable.Index = "iid"

rEdit.Init rsObj, "dist"

If isNeedKoefRecalc Then calcKoefData

mdbSet = True
Exit Function

dbDamage:

Dim tmpStr As String
tmpStr = "Не могу открыть базу обьектов для чтения:" & _
 vbNewLine & mdbFile & _
 vbNewLine & "Полоса расшифровки и таблица поправок отключена."
If Err.Number = 3045 Then
 tmpStr = tmpStr & _
 vbNewLine & _
 vbNewLine & "База открыта для редактирования другими пользователями."
 Else
 tmpStr = tmpStr & _
 vbNewLine & _
 vbNewLine & "Системное описание ошибки:" & _
 vbNewLine & Err.Description
End If
d_isEnable = False
ogdWin.Alert tmpStr
Exit Function

noIid:
ogdWin.Alert _
 "База обьектов повреждена: " & vbNewLine & mdbFile & _
 vbNewLine & "Не найден индекс iid таблицы common"
Exit Function

'типы: CURRENCY, TEXT, DATETIME, INTEGER, DOUBLE, LOGICAL
''' данные о линзе у дефекта
dbStructPatch01:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(9) As String
dbPatch(1) = "ALTER TABLE defect ADD COLUMN internal LOGICAL"
dbPatch(2) = "ALTER TABLE defect ADD COLUMN ex1 DOUBLE"
dbPatch(3) = "ALTER TABLE defect ADD COLUMN ex2 DOUBLE"
dbPatch(4) = "ALTER TABLE defect ADD COLUMN ey1 DOUBLE"
dbPatch(5) = "ALTER TABLE defect ADD COLUMN ey2 DOUBLE"
dbPatch(6) = "ALTER TABLE defect ADD COLUMN ix1 DOUBLE"
dbPatch(7) = "ALTER TABLE defect ADD COLUMN ix2 DOUBLE"
dbPatch(8) = "ALTER TABLE defect ADD COLUMN iy1 DOUBLE"
dbPatch(9) = "ALTER TABLE defect ADD COLUMN iy2 DOUBLE"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления таблицы defect (dbStructPatch01):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

''' таблица поправок дистанции
dbStructPatch02:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "CREATE TABLE distnode (" & _
"odo INTEGER NOT NULL CONSTRAINT iodo UNIQUE, " & _
"rpt INTEGER NOT NULL CONSTRAINT irpt UNIQUE " & _
")"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка создания таблицы distnode (dbStructPatch02):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

''' продольные швы на трубах
dbStructPatch03:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(3) As String
dbPatch(1) = "ALTER TABLE weld ADD COLUMN weld1 DOUBLE"
dbPatch(2) = "ALTER TABLE weld ADD COLUMN weld2 DOUBLE"
dbPatch(3) = "UPDATE weld SET weld1=-1, weld2=-1"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка изменения таблицы weld:" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

Dim rsSpiral As Recordset
Dim sprFlag As Boolean, s As String, cnt As Long

Set rsSpiral = db.OpenRecordset( _
 "SELECT * FROM common WHERE type IN (" & _
 OBJ_startspr_ & ", " & _
 OBJ_shov_p & ", " & _
 OBJ_endsprl_ & ") ORDER BY dist")

sprFlag = False
rEdit.Init rsSpiral, "dist"
s = "Преобразование базы для поддержки продольных швов... "

If rsSpiral.RecordCount > 0 Then
 rsSpiral.MoveLast
 rsSpiral.MoveFirst
End If
cnt = 0
RaiseEvent sbMessage(False, s)

While Not rsSpiral.EOF
 Select Case rsSpiral("type")

  Case OBJ_startspr_
   rEdit.Edit
   rEdit.Change "type", OBJ_shov_s
   rEdit.Update
   sprFlag = True

  Case OBJ_endsprl_
   rEdit.Edit
   rEdit.Change "type", OBJ_shov_p
   rEdit.Update
   sprFlag = False

  Case OBJ_shov_p
   If sprFlag Then
    rEdit.Edit
    rEdit.Change "type", OBJ_shov_s
    rEdit.Update
   End If

  Case Else
 End Select
 rsSpiral.MoveNext
 cnt = cnt + 1
 RaiseEvent sbMessage(False, s & rsSpiral.RecordCount & " / " & cnt)
Wend

RaiseEvent sbMessage(False, s)
rsSpiral.Close

ReDim dbPatch(4) As String
dbPatch(1) = "DELETE FROM objtypes WHERE id IN (" & OBJ_startspr_ & ", " & OBJ_endsprl_ & ")"
dbPatch(2) = "UPDATE objtypes SET name = 'Прямошовная труба' WHERE id = " & OBJ_shov_p
dbPatch(3) = "INSERT INTO objtypes (id, name, tbl) VALUES (191, 'Спиралешовная труба', 'weld')"
dbPatch(4) = "INSERT INTO objtypes (id, name, tbl) VALUES (192, 'Беcшовная труба', 'weld')"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления таблицы objtypes (dbStructPatch03):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

RaiseEvent sbMessage(False, "Продолжение загрузки...")
Resume Next

''' изгиб трубы и угол стыка
dbStructPatch04:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(4) As String
dbPatch(1) = "ALTER TABLE weld ADD COLUMN isComplexCurve LOGICAL"
dbPatch(2) = "ALTER TABLE weld ADD COLUMN curve DOUBLE"
dbPatch(3) = "ALTER TABLE weld ADD COLUMN angle DOUBLE"
dbPatch(4) = "UPDATE weld SET curve = -1, angle = -1, isComplexCurve = False"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления таблицы weld (dbStructPatch04):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

''' длина пригруза и признак активности типа обьекта
dbStructPatch05:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(5) As String
dbPatch(1) = "ALTER TABLE objtypes ADD COLUMN off LOGICAL"
dbPatch(2) = "ALTER TABLE common ADD COLUMN len INTEGER"
dbPatch(3) = "UPDATE common SET len=0"
dbPatch(4) = "UPDATE objtypes SET off=False"
dbPatch(5) = "UPDATE objtypes SET off=True WHERE id IN (110, 60, 180)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления таблиц objtypes и common (dbStructPatch05):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

''' замена булевого поля tech на целое поле typ в таблице поворотов
dbStructPatch06:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(4) As String
dbPatch(1) = "ALTER TABLE turn ADD COLUMN typ INTEGER"
dbPatch(2) = "UPDATE turn SET typ=0 WHERE tech=False"
dbPatch(3) = "UPDATE turn SET typ=1 WHERE tech=True"
dbPatch(4) = "ALTER TABLE turn DROP COLUMN tech"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления таблицы turn (dbStructPatch06):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

''' расширение длины поля примечания до текущей величины (значения трейс-репорта)
dbStructPatch07:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(6) As String
dbPatch(1) = "ALTER TABLE common ADD COLUMN tmp TEXT(" & CMNT_LENGTH & ")"
dbPatch(2) = "UPDATE common SET tmp=name"
dbPatch(3) = "ALTER TABLE common DROP COLUMN name"
dbPatch(4) = "ALTER TABLE common ADD COLUMN name TEXT(" & CMNT_LENGTH & ")"
dbPatch(5) = "UPDATE common SET name=tmp"
dbPatch(6) = "ALTER TABLE common DROP COLUMN tmp"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка расширения поля common.name (dbStructPatch07):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

''' марки стали для труб
dbStructPatch08:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(4) As String
dbPatch(1) = "ALTER TABLE thick DROP COLUMN steel"
dbPatch(2) = "ALTER TABLE weld DROP COLUMN steel"
dbPatch(3) = "ALTER TABLE weld DROP COLUMN thick"
dbPatch(4) = "DROP TABLE steel"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка удаления таблицы марок сталей (dbStructPatch08):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

''' перенос длин из таблиц weld,turn,defect в таблицу common и поддержка полей userDist, userLength
dbStructPatch09:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(3) As String
dbPatch(1) = "UPDATE common RIGHT JOIN weld ON common.dist=weld.dist SET common.len=weld.tubeLength"
dbPatch(2) = "UPDATE common RIGHT JOIN turn ON common.dist=turn.dist SET common.len=turn.length"
dbPatch(3) = "UPDATE common RIGHT JOIN defect ON common.dist=defect.dist SET common.len=defect.length"

If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка сведения длин в таблицу common (dbStructPatch09 data):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

d_distMode = trc.secTrace.getInt(TR_ITM_DISTMODE, 0)
d_odoKoef = trc.secTrace.getDbl(TR_ITM_ODOKOEF, 1)
d_odoStart = trc.secTrace.getInt(TR_ITM_ODOSTART, 0)

ReDim dbPatch(7) As String
dbPatch(1) = "ALTER TABLE weld DROP COLUMN tubeLength"
dbPatch(2) = "ALTER TABLE turn DROP COLUMN [length]"
dbPatch(3) = "ALTER TABLE defect DROP COLUMN [length]"
dbPatch(4) = "ALTER TABLE common ADD COLUMN userDist INTEGER"
dbPatch(5) = "ALTER TABLE common ADD COLUMN userLen INTEGER"
dbPatch(6) = "CREATE TABLE trcConfig (" & _
"distMode INTEGER, " & _
"odoKoef DOUBLE, " & _
"odoStart INTEGER " & _
")"
dbPatch(7) = "INSERT INTO trcConfig (distMode,odoKoef,odoStart) VALUES (" & _
 d_distMode & "," & dblStr(d_odoKoef) & "," & d_odoStart & _
")"

If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка сведения длин в таблицу common (dbStructPatch09 struct):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

isNeedKoefRecalc = True
Resume Next

'добавление рем. муфты, дефекта проката
dbStructPatch10:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(3) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (163, 'Дефект проката', 'defect', False)"
dbPatch(2) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (164, 'Начало рем. муфты', 'lin_obj', False)"
dbPatch(3) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (165, 'Конец рем. муфты', 'lin_obj', False)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления записей таблицы objtypes (dbStructPatch10):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'добавление класса размера дефекта
dbStructPatch11:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(12) As String
dbPatch(1) = "CREATE TABLE dct_feat_size (id INTEGER, name VARCHAR(32), code_name VARCHAR(8))"
dbPatch(2) = "ALTER TABLE dct_feat_size ADD CONSTRAINT pk_dct_feat_size PRIMARY KEY (id)"
dbPatch(3) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (0, 'NULL', 'NONE')"
dbPatch(4) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (1, 'Продольная канавка', 'AXGR')"
dbPatch(5) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (2, 'Продольная щель', 'AXSL')"
dbPatch(6) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (3, 'Поперечная канавка', 'CIGR')"
dbPatch(7) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (4, 'Поперечная щель', 'CISL')"
dbPatch(8) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (5, 'Обширный', 'GENE')"
dbPatch(9) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (6, 'Язва', 'PINH')"
dbPatch(10) = "INSERT INTO dct_feat_size (id, name, code_name) VALUES (7, 'Каверна', 'PITT')"
dbPatch(11) = "ALTER TABLE defect ADD COLUMN feat_size_id INTEGER"
dbPatch(12) = "ALTER TABLE defect ADD CONSTRAINT fk_feat_size FOREIGN KEY (feat_size_id) REFERENCES dct_feat_size (id)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления таблиц defect и dct_feat_size (dbStructPatch11):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
featSizeRecalc
Resume Next

'добавление способов размещения дефектов на трубе - "внутристенный" и "не определено"
dbStructPatch12:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "ALTER TABLE defect ADD COLUMN insidetype INTEGER"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении атрибута insidetype в таблицу defect (dbStructPatch12):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

insideTypeRecalc

ReDim dbPatch(1) As String
dbPatch(1) = "ALTER TABLE defect DROP COLUMN internal"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при удалении атрибута internal из таблицы defect (dbStructPatch12):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'добавление дополнительных объектов для спецнефтегаза
dbStructPatch13:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "UPDATE objtypes SET name='Каверна' WHERE id=10"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при изменении Коррозии на Каверну в таблице objtypes (dbStructPatch13):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

ReDim dbPatch(26) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (200, 'Аном. облицовки шва', 'defect', False)"
dbPatch(2) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (201, 'Корр. на колцев. шве', 'defect', False)"
dbPatch(3) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (202, 'Непровар / утяжина', 'defect', False)"
dbPatch(4) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (203, 'Подрез', 'defect', False)"
dbPatch(5) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (204, 'Смещение кромок', 'defect', False)"
dbPatch(6) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (205, 'Правка кромок', 'defect', False)"
dbPatch(7) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (206, 'Подкладное кольцо', 'defect', False)"
dbPatch(8) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (207, 'Аном. продольн. шва', 'defect', False)"
dbPatch(9) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (208, 'Аном. спиральн. шва', 'defect', False)"
dbPatch(10) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (209, 'Вмят. с деф. потери мет.', 'defect', False)"
dbPatch(11) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (210, 'Внутристенное расслоение', 'defect', False)"
dbPatch(12) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (211, 'Наруш. адгезии изоляц. трубы кон.', 'defect', False)"
dbPatch(13) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (212, 'Наруш. адгезии изоляц. трубы нач.', 'defect', False)"
dbPatch(14) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (213, 'Несваренный стык патрона', 'defect', False)"
dbPatch(15) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (214, 'Эксцентричный патрон', 'defect', False)"
dbPatch(16) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (215, 'Потеря конт. с трубой', 'defect', False)"
dbPatch(17) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (216, 'Зашлифовка', 'defect', False)"
dbPatch(18) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (217, 'Потеря металла', 'defect', False)"
dbPatch(19) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (218, 'Точечная коррозия', 'defect', False)"
dbPatch(20) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (219, 'Поджиг', 'defect', False)"
dbPatch(21) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (220, 'Расслоение с вых. на пов-ность', 'defect', False)"
dbPatch(22) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (221, 'Заварка отверстия', 'defect', False)"
dbPatch(23) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (222, 'Трещина на кольцевом шве', 'defect', False)"
dbPatch(24) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (223, 'Несплошность плоскостного типа', 'defect', False)"
dbPatch(25) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (224, 'Поперечная трещина', 'defect', False)"
dbPatch(26) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (225, 'Зашлифовка продольного шва', 'defect', False)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении типов дефектов в таблицу objtypes (dbStructPatch13):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

ReDim dbPatch(13) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (21, 'Изоляционный стык', 'lin_obj', False)"
dbPatch(2) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (22, 'Патрон малой длины', 'lin_obj', False)"
dbPatch(3) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (23, 'Хомут', 'lin_obj', False)"
dbPatch(4) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (24, 'Задвижка', 'lin_obj', False)"
dbPatch(5) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (25, 'Маркерное кольцо', 'lin_obj', False)"
dbPatch(6) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (26, 'Маркер магнитный', 'lin_obj', False)"
dbPatch(7) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (27, 'Заварка бобышки', 'lin_obj', False)"
dbPatch(8) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (28, 'Рем. накладка, зашлиф. и т.п.', 'lin_obj', False)"
dbPatch(9) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (29, 'Отрем. участок', 'lin_obj', False)"
dbPatch(10) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (31, 'Нераспозн. объект', 'lin_obj', False)"
dbPatch(11) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (32, 'Трубн. арматура', 'lin_obj', False)"
dbPatch(12) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (33, 'Элемент обустройства', 'lin_obj', False)"
dbPatch(13) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (34, 'Недопуст. конструкт. эл-т', 'lin_obj', False)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении типов линейных объектов в таблицу objtypes (dbStructPatch13):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

ReDim dbPatch(3) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (193, 'Неопределенная секция', 'weld', False)"
dbPatch(2) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (194, 'Одношовная', 'weld', False)"
dbPatch(3) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (195, 'Двухшовная', 'weld', False)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении типов линейных объектов в таблицу objtypes (dbStructPatch13):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If

featSizeRecalc

Resume Next

'добавление гофры
dbStructPatch14:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (4, 'Гофра', 'defect', False)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка обновления записей таблицы objtypes (dbStructPatch14):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'добавление поля isAttention и полей протокола в таблицу common
dbStructPatch15:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(5) As String
dbPatch(1) = "ALTER TABLE common ADD COLUMN isAttention LOGICAL"
dbPatch(2) = "ALTER TABLE common ADD COLUMN createBy TEXT(" & CMNT_LENGTH & ")"
dbPatch(3) = "ALTER TABLE common ADD COLUMN createDate DATETIME"
dbPatch(4) = "ALTER TABLE common ADD COLUMN editBy TEXT(" & CMNT_LENGTH & ")"
dbPatch(5) = "ALTER TABLE common ADD COLUMN editDate DATETIME"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении полей в таблицу defect (dbStructPatch15):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'добавление поля tube_number в таблицу weld
dbStructPatch16:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "ALTER TABLE weld ADD COLUMN tube_number TEXT(" & CMNT_LENGTH & ")"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении полей в таблицу weld (dbStructPatch16):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'добавление поля color в таблицу common
dbStructPatch17:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "ALTER TABLE common ADD COLUMN color INTEGER"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении полей в таблицу defect (dbStructPatch17):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'категории участков
dbStructPatch18:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (141, 'Категория участка', 'thick', False)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении типа <Категория участка> в таблицу objtypes (dbStructPatch18):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'фланцевое соединение
dbStructPatch19:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl, off) VALUES (35, 'Фланцевое соединение', 'lin_obj', False)"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении типа <Фланцевое соединение> в таблицу objtypes (dbStructPatch19):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'добавление обьуктов в 1.22.0
dbStructPatch20:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(10) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl)      VALUES (226, 'Провис корня шва', 'defect')"
dbPatch(2) = "INSERT INTO objtypes (id, name, tbl)      VALUES (227, 'Место вышлифовки продольного шва', 'defect')"
dbPatch(3) = "INSERT INTO objtypes (id, name, tbl)      VALUES (228, 'Нарушение формы продольного шва', 'defect')"
dbPatch(4) = "INSERT INTO objtypes (id, name, tbl)      VALUES (229, 'Место вышлифовки спирального шва', 'defect')"
dbPatch(5) = "INSERT INTO objtypes (id, name, tbl)      VALUES (230, 'Нарушение формы спирального шва', 'defect')"
dbPatch(6) = "INSERT INTO objtypes (id, name, tbl)      VALUES (231, 'Технолог.дефект', 'defect')"
dbPatch(7) = "INSERT INTO objtypes (id, name, tbl)      VALUES (232, 'Трещина на продольном шве', 'defect')"
dbPatch(8) = "INSERT INTO objtypes (id, name, tbl)      VALUES (233, 'Трещина на спиральном шве', 'defect')"
dbPatch(9) = "INSERT INTO objtypes (id, name, tbl)      VALUES (196, 'Кран-секция', 'weld')"
dbPatch(10) = "INSERT INTO objtypes (id, name, tbl)      VALUES (197, 'Тройник-секция', 'weld')"

If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении типов дефектов в таблицу objtypes (dbStructPatch13):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'обькеты, прилепленные к продольному шву
dbStructPatch21:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "INSERT INTO objtypes (id, name, tbl)      VALUES (234, 'Заварка продольн. шва', 'defect')"

If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении типов дефектов в таблицу objtypes (dbStructPatch21):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'поле строки координат для экспорта
dbStructPatch22:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "ALTER TABLE common ADD COLUMN linkedDist INTEGER"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении полей в таблицу defect (dbStructPatch22):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'поле рабочего давления категории участка
dbStructPatch23:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "ALTER TABLE thick ADD COLUMN pressure DOUBLE"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении полей в таблицу defect (dbStructPatch23):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'поле преобразованного поворота
dbStructPatch24:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(1) As String
dbPatch(1) = "ALTER TABLE turn ADD COLUMN calctyp INTEGER"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении поля calctyp в таблицу turn (dbStructPatch24):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

'поле поворота 3d
dbStructPatch25:
If Me.isRO Then
 ogdWin.Alert "База нуждается в обновлении, но доступна только для чтения."
 Exit Function
End If

ReDim dbPatch(2) As String
dbPatch(1) = "ALTER TABLE turn ADD COLUMN radcom DOUBLE"
dbPatch(2) = "ALTER TABLE turn ADD COLUMN anglcom DOUBLE"
If SQLexe(db, dbPatch) = False Then
 ogdWin.Alert "Ошибка при добавлении полей radcom и anglcom в таблицу turn (dbStructPatch25):" & vbNewLine & lastSQLerror
 On Error GoTo 0
 Exit Function
End If
Resume Next

End Function

Public Sub featSizeRecalc()
 Dim sql As String, rs As Recordset
 Dim rLen As Long, rWidth As Long, rDist As Long, rType As Long, rTypeOut As Long, rFeatClass As Long
 Dim cmd() As String
 Dim Zoom As New clsZoom
 
 setWait "Пересчет типов размеров дефектов..."
 sql = "SELECT " & _
       "common.dist AS dist, common.type, len, width " & _
       "FROM objtypes RIGHT JOIN " & _
       "(common LEFT JOIN defect ON defect.dist=common.dist) " & _
       "ON objtypes.id=common.type " & _
       "WHERE objtypes.tbl='" & OBJ_TBL_DFKT & "' " & _
       "AND common.dist>0 ORDER BY common.dist"
 Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
 While Not rs.EOF
  rLen = IIf(IsNull(rs("len")), 0, rs("len"))
  rWidth = IIf(IsNull(rs("width")), 0, rs("width"))
  rDist = IIf(IsNull(rs("dist")), 0, rs("dist"))
  rType = IIf(IsNull(rs("type")), 0, rs("type"))
  rFeatClass = CalcFeatureClass(rLen, rWidth, GetWallThick(rDist))
  
  rTypeOut = DefineDefType(rType, rFeatClass)
  
  ReDim cmd(2) As String
  cmd(1) = "UPDATE " & _
  "defect SET feat_size_id=" & _
  CStr(rFeatClass) & _
  " WHERE dist=" & CStr(rDist)
  
  cmd(2) = "UPDATE " & _
  "common SET type=" & _
  CStr(rTypeOut) & _
  " WHERE dist=" & CStr(rDist)
  
  If SQLexe(db, cmd) = False Then
     ogdWin.Alert "Ошибка обновления таблицы defect"
     Exit Sub
  End If
  rs.MoveNext
 Wend
 rs.Close
 Set rs = Nothing
 
 setWait "Обновление таблицы..."
 setReady
End Sub

Private Sub insideTypeRecalc()
 Dim sql As String, rs As Recordset
 Dim rDist As Long
 Dim cmd() As String
 
 sql = "SELECT dist, internal FROM defect ORDER BY dist ASC"
 Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
 While Not rs.EOF
  ReDim cmd(1) As String
  rDist = IIf(IsNull(rs("dist")), 0, rs("dist"))
  If rs("internal") = False Then
    cmd(1) = "UPDATE defect SET insidetype=0 WHERE dist=" & CStr(rDist)
  Else
    cmd(1) = "UPDATE defect SET insidetype=1 WHERE dist=" & CStr(rDist)
  End If
  
  If SQLexe(db, cmd) = False Then
     ogdWin.Alert "Ошибка обновления таблицы defect с атрибутом insidetype"
     Exit Sub
  End If
  rs.MoveNext
 Wend
 rs.Close
 Set rs = Nothing
End Sub

Public Function GetWallThick(dst As Long) As Double
Dim sql As String, dfltThick As Double, rs As Recordset
 dfltThick = trc.drv.wallThick
 sql = "select top 1 thick from thick where dist <= " & CStr(dst) & " order by dist desc"
 Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
 GetWallThick = IIf(rs.RecordCount = 0, dfltThick, rs("thick"))
 rs.Close
 Set rs = Nothing
End Function

Public Sub calcKoefData()
Dim typ As New clsObjType, l As Long, d As Long, s As String, cnt As Long
Dim cmd() As String

On Error Resume Next
rsObj.Close
On Error GoTo 0

ReDim cmd(1) As String
cmd(1) = "delete from common where type not in (select id as type from objtypes)"
If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка очистки мусора из таблицы common:" & vbNewLine & lastSQLerror
 RaiseEvent sbMessage(True, "")
 Exit Sub
End If

Set rsObj = db.OpenRecordset("common", dbOpenTable)
rsObj.Index = "iid"
rEdit.Init rsObj, "dist"

If rsObj.RecordCount = 0 Then Exit Sub

On Error GoTo errHandle
rsObj.MoveLast
rsObj.MoveFirst
cnt = 0
s = "Применение таблицы поправок... " & rsObj.RecordCount & " / "
 
While Not rsObj.EOF

 cnt = cnt + 1
 RaiseEvent sbMessage(False, s & cnt)
 
 d = getDistFromRs(rsObj, trc.length)
 objUnStick2Weld rsObj, False
 
 Set typ = types(Trim(str(rsObj("type"))))
 If typ.isLength Then
  l = trc.getLenKoef(d, rsObj("len"))
  Else
  l = 0
 End If
 
 rEdit.Edit
 rEdit.Change "userDist", trc.getDistKoef(d)
 rEdit.Change "userLen", l
 rEdit.Update
 
 rsObj.MoveNext
Wend

ReDim cmd(1) As String
cmd(1) = "UPDATE trcConfig SET " & _
 "odoKoef=" & dblStr(d_odoKoef) & ", " & _
 "odoStart=" & d_odoStart & ", " & _
 "distMode=" & d_distMode

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка обновления таблицы trcConfig:" & vbNewLine & lastSQLerror
 RaiseEvent sbMessage(True, "")
 Exit Sub
End If

On Error GoTo 0
RaiseEvent sbMessage(True, "")
isNeedKoefRecalc = False
Exit Sub

errHandle:
RaiseEvent sbMessage(True, "")
ogdWin.Alert "Ошибка при применении таблицы поправок:" & vbNewLine & Err.Description
End Sub

Private Function tryOpenDbRW(mdbFile As String) As Boolean
On Error GoTo tryRO
Set db = OpenDatabase(mdbFile)
tryOpenDbRW = True
Exit Function

tryRO:
tryOpenDbRW = False
End Function

Public Function shiftObjects(ByVal vStart As Long, ByVal vLength As Long) As Boolean
Dim cmd() As String

shiftObjects = False

shiftTable "common", vStart, vLength
shiftTable "lin_obj", vStart, vLength
shiftTable "thick", vStart, vLength
shiftTable "weld", vStart, vLength
shiftTable "turn", vStart, vLength

ReDim cmd(1) As String
cmd(0) = "UPDATE defect SET " & _
 "ex1=ex1+" & vLength & "," & _
 "ex2=ex2+" & vLength & _
 " WHERE ex1>0 AND dist>" & vStart
If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка сдвига обьектов:" & vbNewLine & lastSQLerror
 Exit Function
End If

shiftTable "defect", vStart, vLength

shiftObjects = True
End Function

Private Sub shiftTable(ByVal tblname As String, ByVal shiftStart As Long, ByVal shiftLen As Long)
Dim rs As Recordset, cmd As String

cmd = "SELECT * FROM " & tblname & " WHERE dist>" & shiftStart & " ORDER BY dist " & IIf(shiftLen > 0, "DESC", "ASC")
Set rs = db.OpenRecordset(cmd, dbOpenDynaset)

If rs.RecordCount = 0 Then
 rs.Close
 Exit Sub
End If

rs.MoveFirst
While Not rs.EOF
 rs.Edit
 rs("dist") = rs("dist") + shiftLen
 rs.Update
 rs.MoveNext
Wend
rs.Close
End Sub

Public Sub updateObjects()
Dim cmd() As String

ReDim cmd(2) As String
cmd(1) = "DELETE FROM objtypes"
cmd(2) = "INSERT INTO objtypes SELECT * FROM objtypes IN '" & cfg.dir.dbTemplete & "'"
If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка обновления таблицы objtypes:" & vbNewLine & lastSQLerror
End If
fillTypes
End Sub

Private Function fillTypes() As Boolean
Dim typ As clsObjType, rs As Recordset, s As String

Set rs = db.OpenRecordset("SELECT * FROM objtypes ORDER BY name", dbOpenSnapshot)
clearCollection types
dfltObjType.Init rs("id"), rs("name"), rs("off"), rs("tbl")
While Not rs.EOF
 Set typ = New clsObjType
 typ.Init rs("id"), rs("name"), rs("off"), rs("tbl")
 s = typ.id
 types.Add typ, s
 rs.MoveNext
Wend
rs.Close

fillTypes = True
End Function

Property Get objTypes() As Collection
Set objTypes = types
End Property

Property Get dfltType() As OBJ_TYPE
dfltType = dfltObjType.id
End Property

Property Let dfltType(t As OBJ_TYPE)
Dim rs As Recordset

Set rs = db.OpenRecordset("SELECT * FROM objtypes WHERE id=" & t, dbOpenSnapshot)
If rs.RecordCount = 0 Then Exit Property
dfltObjType.Init rs("id"), rs("name"), rs("off"), rs("tbl")
End Property

Private Sub setCfgRS()
rsConfig.MoveFirst
d_distMode = rsConfig("distMode")
d_odoKoef = rsConfig("odoKoef")
d_odoStart = rsConfig("odoStart")
End Sub

Private Sub setDistRS()
Set rsDistOdo = db.OpenRecordset("distnode", dbOpenTable)
rsDistOdo.Index = "iodo"
If Not isRsEmpty(rsDistOdo) Then rsDistOdo.MoveFirst
Set rsDistRpt = db.OpenRecordset("distnode", dbOpenTable)
rsDistRpt.Index = "irpt"
If Not isRsEmpty(rsDistRpt) Then rsDistRpt.MoveFirst
End Sub

Public Function getDistKoef(ByVal dst As Long) As Long
getDistKoef = getDist(dst, rsDistOdo, "odo", "rpt")
End Function

Public Function getDistReal(ByVal dst As Long) As Long
getDistReal = getDist(dst, rsDistRpt, "rpt", "odo")
End Function

Public Sub dstTblLoad(xarr As XArrayDB)
Dim i As Integer

If Me.enable = False Then Exit Sub

xarr.Clear
If rsDistOdo.RecordCount = 0 Then Exit Sub
xarr.ReDim 0, rsDistOdo.RecordCount - 1, 0, 1
If isRsEmpty(rsDistOdo) Then Exit Sub

rsDistOdo.MoveFirst
i = 0
While Not rsDistOdo.EOF
 xarr.Value(i, 0) = "" & rsDistOdo("odo")
 xarr.Value(i, 1) = "" & rsDistOdo("rpt")
 i = i + 1
 rsDistOdo.MoveNext
Wend
End Sub

Public Sub dstTblSave(xarr As XArrayDB)
Dim rs As Recordset, i As Integer
Dim cmd() As String

If Me.enable = False Then Exit Sub

ReDim cmd(1) As String

'очистить таблицу поправок
cmd(1) = "DELETE FROM distnode"
If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка при очистке таблицы:" & vbNewLine & lastSQLerror
 Exit Sub
End If

Set rs = db.OpenRecordset("distnode", dbOpenTable)
On Error GoTo tblIndxErr
'заполнить значениеми из xarr
For i = xarr.LowerBound(1) To xarr.UpperBound(1)
 If Not (IsEmpty(xarr.Value(i, 0)) Or IsEmpty(xarr.Value(i, 1))) Then
  rs.AddNew
  rs("odo") = xarr.Value(i, 0)
  rs("rpt") = xarr.Value(i, 1)
  rs.Update
 End If
Next
On Error GoTo 0
rs.Close

calcKoefData
rsDistOdo.Close
rsDistRpt.Close
setDistRS
Exit Sub

tblIndxErr:
ogdWin.Alert _
 "Строка таблицы " & i & " содержит дублирующееся значение дистанции." & vbNewLine & _
 "Odo: " & xarr.Value(i, 0) & " Rpt: " & xarr.Value(i, 1) & vbNewLine & _
 "Данная строка не будет записана в базу."
Resume Next
End Sub

Public Function objAdd( _
ByVal objDist As Long, _
ByVal objLen As Long, _
ByVal objTyp As clsObjType, _
Optional ByVal batched As Boolean = False, _
Optional ByVal ignoreFilter As Boolean = False, _
Optional ByVal uName As String = "" _
) As Boolean

Dim cmd() As String, obj As New clsObjCommon, insideType As Integer

ReDim cmd(2) As String

objAdd = False

If ignoreFilter = False Then
 If presentInString(filtrType, Trim$(str$(objTyp.id)), ",") Then
  ogdWin.Alert "Обьект не создан. Заблокирован текущими настройками фильтра"
  Exit Function
 End If
End If

If uName = "" Then uName = Me.userName

obj.Init trc, objDist, objLen, "", False, objTyp
With rEdit
.AddNew
.Change "dist", obj.objDist
.Change "len", obj.objLen
.Change "type", objTyp.id
.Change "userDist", obj.usrDist
.Change "userLen", obj.usrLen
.Change "isAttention", obj.isAttention
.Change "createBy", uName
.Change "createDate", Now()
.Change "editBy", uName
.Change "editDate", Now()
If .Update = False Then
 If Not batched Then ogdWin.Alert "Занято! (отметка " & objDist & ")"
 Exit Function
End If
End With

Select Case objTyp.tbl

 Case ""
  cmd(1) = ""
 
 Case OBJ_TBL_WELD
  cmd(1) = "INSERT INTO " & objTyp.tbl & " (dist, weld1, weld2, curve, angle) VALUES (" & objDist & ", -1, -1, -1, -1)"
 
 Case OBJ_TBL_THICK
 
  Dim thickParam As String
  Select Case objTyp.id
  
    Case OBJ_TYPE.OBJ_category
      thickParam = "1"
      
    'Case OBJ_TYPE.OBJ_thick
    Case Else
      thickParam = dblStr(dfltThick)
    
  End Select
  cmd(1) = "INSERT INTO " & objTyp.tbl & " (dist, thick) VALUES (" & objDist & ", " & thickParam & ")"
  
 Case OBJ_TBL_DFKT
  insideType = GetInsideType(objTyp.id)
  If insideType <> -1 Then
   cmd(1) = "INSERT INTO " & objTyp.tbl & " (dist, insidetype) VALUES (" & objDist & ", " & insideType & ")"
  Else
   cmd(1) = "INSERT INTO " & objTyp.tbl & " (dist) VALUES (" & objDist & ")"
  End If
  
 Case OBJ_TBL_TURN
  cmd(1) = "INSERT INTO " & objTyp.tbl & " (dist, typ) VALUES (" & objDist & ", " & Me.dfltTurnType & ")"
  
 Case Else
  cmd(1) = "INSERT INTO " & objTyp.tbl & " (dist) VALUES (" & objDist & ")"

End Select
cmd(2) = ""

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "SQL: objAdd(1):" & vbNewLine & lastSQLerror
 Exit Function
End If

If (ignoreFilter = False) And (objTyp.tbl = OBJ_TBL_WELD) Then
 If sqlUpdateTubLengthAtPoint(objDist, cmd, 1, 2) Then

  If SQLexe(db, cmd) = False Then
   ogdWin.Alert "SQL: objAdd(2):" & vbNewLine & lastSQLerror & _
    vbNewLine & "Необходимо пересчитать таблицу длин труб."
   Exit Function
  End If

  Else

  If Len(cmd(1)) > 0 Then cmd(1) = "DELETE FROM weld WHERE dist=" & objDist
  cmd(2) = "DELETE FROM common WHERE dist=" & objDist
  If SQLexe(db, cmd) Then
   ogdWin.Alert "Шов слишком близко к другому шву. Отменено."
   Else
   ogdWin.Alert "Ошибка при отмене операции:" & vbNewLine & lastSQLerror & _
    vbNewLine & "Необходимо пересчитать таблицу длин труб."
  End If

 End If
End If

If batched Then
 objAdd = True
 Exit Function
End If

RaiseEvent dataChange(filtrType, objDist)
objAdd = True
End Function

Property Get Filter() As String
Filter = filtrType
End Property

Property Let Filter(f As String)
Dim c As clsObjType

cfg.parser.Delim = ","
cfg.parser.TestString = cfg.parser.Delim & f
cfg.parser.Parse

For Each c In Me.objTypes
 If findInHideObjects(c.id, cfg.parser) Then
  c.enabled = False
  Else
  c.enabled = True
 End If
Next
filtrType = getFilterString()
RaiseEvent dataChange(filtrType, -1)
End Property

Public Function addObj(ByVal objDist As Long) As Boolean
If objDist < 0 Then
 addObj = True
 Exit Function
End If

addObj = objAdd(objDist, IIf(dfltObjType.id = OBJ_prigruz, prigruzLength, 0), dfltObjType)
End Function

Public Function objDelRange() As Boolean
Dim cmd() As String, rs As Recordset, cnt As Long, s As String

objDelRange = False

If Len(Trim(filtrType)) = 0 Then

 RaiseEvent sbMessage(False, "Удаление обьектов...")
 ReDim cmd(7) As String
 cmd(1) = "DELETE * FROM common"
 cmd(2) = "DELETE * FROM lin_obj"
 cmd(3) = "DELETE * FROM defect"
 cmd(4) = "DELETE * FROM thick"
 cmd(5) = "DELETE * FROM weld"
 cmd(6) = "DELETE * FROM turn"
 cmd(7) = "DELETE * FROM distnode"
 If SQLexe(db, cmd) = False Then
  RaiseEvent sbMessage(True, "")
  ogdWin.Alert "SQL: objDelRange(1):" & vbNewLine & lastSQLerror
  Exit Function
 End If

 Else

 Set rs = db.OpenRecordset("SELECT dist FROM common WHERE type NOT IN (" & filtrType & ")", dbOpenSnapshot)
 If rs.RecordCount > 0 Then
  rs.MoveLast
  rs.MoveFirst
 End If
 cnt = 0
 s = "Удаление обьектов... " & rs.RecordCount & " / "
 While Not rs.EOF
  cnt = cnt + 1
  RaiseEvent sbMessage(False, s & cnt)
  objDel rs("dist"), True
  rs.MoveNext
 Wend
 rs.Close

End If

RaiseEvent sbMessage(False, "Удаление обьектов...")
RaiseEvent dataChange(filtrType, 0)
RaiseEvent eraseObjects

'noFirstDistEvent = True
'refreshRs
'drawObj
'noFirstDistEvent = False

RaiseEvent sbMessage(True, "")
objDelRange = True
End Function

Public Function is_tube_border(ByVal code As OBJ_TYPE) As Boolean
Select Case code
 Case OBJ_shov_p, OBJ_shov_s, OBJ_shov_b
 is_tube_border = True
 Case Else
 is_tube_border = False
End Select
End Function

Public Function objStick2Weld(rs As Recordset, rsWeld As Recordset) As Boolean
Dim dst As Long, prv_dist As Long, nxt_dist As Long, lnk_dist As Long
Dim obj As New clsObjCommon, wld As New clsObjCommon

objStick2Weld = False
dst = rs("dist")

If is_tube_border(rs("type")) = True Then
  'Debug.Print "Skip " & dst
  Exit Function
End If

rsWeld.MoveFirst
rsWeld.FindFirst "dist > " & dst

If rsWeld.NoMatch Then
  rsWeld.MoveLast
  
  If rsWeld.NoMatch Then
    ' no welds in rsWeld
    Exit Function
  Else
    lnk_dist = rsWeld("dist")
  End If
  
Else

  nxt_dist = rsWeld("dist")
  rsWeld.MovePrevious
  
  If rsWeld.NoMatch Then
    lnk_dist = nxt_dist
  Else
    prv_dist = rsWeld("dist")
    
    If (nxt_dist - dst) > (dst - prv_dist) Then
      lnk_dist = prv_dist
    Else
      lnk_dist = nxt_dist
    End If
    
  End If
  
End If

'Debug.Print prv_dist & " < " & rs("dist") & " > " & nxt_dist & " link " & lnk_dist
If Me.objCommon(dst, obj) = False Then
  Exit Function
End If

If Me.objCommon(lnk_dist, wld) = False Then
  Exit Function
End If

obj.link2dist lnk_dist, wld.usrDist

objStick2Weld = True
End Function

Public Function objUnStick2Weld(rs As Recordset, Optional ByVal set_editor As Boolean = True) As Boolean
Dim obj As New clsObjCommon
Dim dst As Long

dst = rs("dist")
If Me.objCommon(dst, obj) = False Then
  Exit Function
End If

obj.link2dist Null, 0, set_editor
End Function


Public Function objDel(ByVal objDist As Long, Optional ByVal batched As Boolean = False) As Boolean
Dim cmd() As String, rs As Recordset

On Error GoTo errHandle

ReDim cmd(2) As String

objDel = False

cmd(1) = "SELECT * FROM common LEFT JOIN objtypes ON common.type=objtypes.id WHERE dist=" & objDist
Set rs = db.OpenRecordset(cmd(1), dbOpenSnapshot)
cmd(2) = rs("tbl")
rs.Close

cmd(1) = ""
With rsObj
.Seek "=", objDist
If Not .NoMatch Then rEdit.Delete
End With

If cmd(2) = "" Then
 cmd(2) = ""
 Else
 cmd(2) = "DELETE FROM " & cmd(2) & " WHERE dist=" & objDist
End If

If SQLexe(db, cmd) = False Then
 If Not batched Then ogdWin.Alert "SQL: objDel(1):" & vbNewLine & lastSQLerror
 Exit Function
End If

sqlUpdateTubLengthAtPoint objDist, cmd, 1, 2
If SQLexe(db, cmd) = False Then
 If Not batched Then ogdWin.Alert "SQL: objDel(2):" & vbNewLine & lastSQLerror & _
  vbNewLine & "Необходимо пересчитать таблицу длин труб."
 Exit Function
End If

If batched Then
 objDel = True
 Exit Function
End If

On Error GoTo 0

RaiseEvent dataChange(filtrType, objDist)
RaiseEvent eraseObjects

'noFirstDistEvent = True
'refreshRs
'drawObj
'noFirstDistEvent = False
objDel = True
Exit Function

errHandle:
ogdWin.Alert "objDel err: " & vbNewLine & lastSQLerror
Resume Next

End Function

Public Function objAddEx(ByVal x1 As Long, ByVal x2 As Long) As Boolean
Dim cmd() As String, cmdFlag As Boolean, moveFlag As Boolean

objAddEx = False

'при установке поворотов - если начало совпадает со швом,
'сдвигать вправо на 1 см, пока не встанет
If dfltObjType.tbl = OBJ_TBL_TURN Then
 moveFlag = True
 While moveFlag
  If checkDist(x1) Then
   'здесь бы вставить проверку шов на этом месте или не шов.
   'лень. 11.07.03 ВБ
   x1 = x1 + 1
   Else
   moveFlag = False
  End If
 Wend
End If

If objAdd(x1, x2 - x1, dfltObjType) = False Then Exit Function

cmdFlag = False
Select Case dfltObjType.tbl

 Case OBJ_TBL_TURN
  ReDim cmd(1) As String
  cmd(1) = "UPDATE turn SET " & _
  "startTune=" & cfg.vog.tuneStart & ", endTune=" & cfg.vog.tuneEnd & _
  " WHERE dist=" & x1
  cmdFlag = True

End Select

If cmdFlag Then
 If SQLexe(db, cmd) = False Then
  ogdWin.Alert "SQL: objAddEx(1):" & vbNewLine & lastSQLerror
 End If
End If
objAddEx = True
End Function

Public Function objWeldSet( _
ByVal dst As Long, _
obj As clsObjWeld, _
Optional ByVal isBatched As Boolean = False, _
Optional ByVal uName As String = "" _
) As Boolean

Dim cmd() As String, tlen As Long, ret1 As Boolean, ret2 As Boolean

objWeldSet = False
noTransActionFlag = True
BeginTrans

If Me.objCommonSet(dst, obj.objCommon, False, uName) = False Then
 noTransActionFlag = False
 Rollback
 Exit Function
End If

ReDim cmd(1) As String
cmd(1) = "UPDATE weld SET " & _
 "weld1=" & dblStr(obj.weld1) & ", " & _
 "weld2=" & dblStr(obj.weld2) & ", " & _
 "curve=" & dblStr(obj.curve) & ", " & _
 "angle=" & dblStr(obj.angle) & ", " & _
 "isComplexCurve=" & boolStr(obj.curveComplex) & ", " & _
 "tube_number='" & obj.tube_number & "', " & _
 "dist=" & obj.objCommon.objDist & " " & _
 "WHERE dist=" & dst

If SQLexe(db, cmd) = False Then
 noTransActionFlag = False
 Rollback
 ogdWin.Alert "SQL: objWeldSet(1):" & vbNewLine & lastSQLerror
 Exit Function
End If

ReDim cmd(4) As String
ret1 = sqlUpdateTubLengthAtPoint(dst, cmd, 1, 2)
ret2 = sqlUpdateTubLengthAtPoint(obj.objCommon.objDist, cmd, 3, 4)

If Not (ret1 And ret2) Then
 noTransActionFlag = False
 Rollback
 ogdWin.Alert "Шов слишком близко к другому шву. Отменено."
 Exit Function
End If

CommitTrans
noTransActionFlag = False

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "SQL: objWeldSet(2):" & vbNewLine & lastSQLerror & _
  vbNewLine & "Необходимо пересчитать таблицу длин труб."
 Exit Function
End If

If isBatched = False Then RaiseEvent dataChange(filtrType, obj.objCommon.objDist)
objWeldSet = True
End Function

Public Function objCommonSet( _
ByVal dst As Long, _
obj As clsObjCommon, _
ByVal refreshFlag As Boolean, _
Optional ByVal uName As String = "" _
) As Boolean
Dim cmd() As String

ReDim cmd(1) As String
objCommonSet = False

If dst <> obj.objDist Then
 If checkDist(obj.objDist) Then
  ogdWin.Alert "Не могу переместить обьект на отметку " & _
  mm2txt(obj.objDist) & _
  vbNewLine & "Там есть другой обьект."
  Exit Function
 End If
End If

rsObj.Seek "=", dst
If rsObj.NoMatch Then
 ogdWin.Alert "Не могу найти обьект на отметке " & dst
 Exit Function
End If

If uName = "" Then uName = Me.userName

With rEdit
.Edit
.Change "name", obj.comment
.Change "len", obj.objLen
.Change "type", obj.objTyp.id
.Change "dist", obj.objDist
.Change "userDist", obj.usrDist
.Change "userLen", obj.usrLen
.Change "isAttention", obj.isAttention
.Change "editBy", uName
.Change "editDate", Now()
.Update
End With

If refreshFlag Then
 RaiseEvent dataChange(filtrType, obj.objDist)
End If

objCommonSet = True
End Function

Public Function objLineSet(ByVal dst As Long, obj As clsObjLine, Optional ByVal batched As Boolean = False) As Boolean
Dim cmd() As String

objLineSet = False

If Me.objCommonSet(dst, obj.objCommon, Not batched) = False Then Exit Function

ReDim cmd(1) As String
cmd(1) = "UPDATE lin_obj SET " & _
 "marker=" & boolStr(obj.dMarker) & ", " & _
 "marker_text='" & obj.dMarkerText & "', " & _
 "trace_dist='" & obj.dTraceDist & "', " & _
 "dist=" & obj.objCommon.objDist & " " & _
 "WHERE dist=" & dst

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "SQL: objLineSet(1):" & vbNewLine & lastSQLerror
 Exit Function
End If

If Not batched Then
 RaiseEvent dataChange(filtrType, obj.objCommon.objDist)
End If

objLineSet = True
End Function

Public Function objThickSet(ByVal dst As Long, obj As clsObjThick, Optional ByVal batched As Boolean = False) As Boolean
Dim cmd() As String

objThickSet = False

If Me.objCommonSet(dst, obj.objCommon, Not batched) = False Then Exit Function

ReDim cmd(1) As String
cmd(1) = "UPDATE thick SET " & _
 "thick=" & dblStr(obj.dThick) & ", " & _
 "pressure=" & dblStr(obj.dPress) & ", " & _
 "dist=" & obj.objCommon.objDist & " " & _
 "WHERE dist=" & dst

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "SQL: objThickSet(1):" & vbNewLine & lastSQLerror
 Exit Function
End If
dfltThick = obj.dThick

If Not batched Then
 RaiseEvent dataChange(filtrType, obj.objCommon.objDist)
End If
objThickSet = True
End Function

Public Function objTurnSet(ByVal dst As Long, obj As clsobjTurn, Optional ByVal batched As Boolean = False) As Boolean
Dim cmd() As String

objTurnSet = False

If Me.objCommonSet(dst, obj.objCommon, False) = False Then Exit Function

ReDim cmd(1) As String
cmd(1) = "UPDATE turn SET " & _
 "vert=" & boolStr(obj.dVert) & ", " & _
 "horz=" & boolStr(obj.dHorz) & ", " & _
 "typ=" & obj.dTyp & ", " & _
 "startTune=" & boolStr(obj.dTuneStart) & ", " & _
 "endTune=" & boolStr(obj.dTuneEnd) & ", " & _
 "calctyp=" & obj.dCalctyp & ", " & _
 "radxy=" & dblStr(obj.dRadXY) & ", " & _
 "anglxy=" & dblStr(obj.dAnglXY) & ", " & _
 "radz=" & dblStr(obj.dRadZ) & ", " & _
 "anglz=" & dblStr(obj.dAnglZ) & ", " & _
 "radcom=" & dblStr(obj.dRad3D) & ", " & _
 "anglcom=" & dblStr(obj.dAngl3D) & ", " & _
 "xmark=" & obj.dMarkX & ", " & _
 "ymark=" & obj.dMarkY & ", " & _
 "zmark=" & obj.dMarkZ & ", " & _
 "dist=" & obj.objCommon.objDist & " " & _
 "WHERE dist=" & dst

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "SQL: objTurnSet(1):" & vbNewLine & lastSQLerror
 Exit Function
End If

If Not batched Then
 RaiseEvent dataChange(filtrType, obj.objCommon.objDist)
End If
objTurnSet = True
End Function

Public Function objDefectSet( _
ByVal dst As Long, _
obj As clsObjDefekt, _
Optional ByVal batched As Boolean = False _
) As Boolean

Dim cmd() As String

objDefectSet = False
If Me.objCommonSet(dst, obj.objCommon, False) = False Then Exit Function

ReDim cmd(1) As String
cmd(1) = "UPDATE defect SET " & _
 "width=" & dblStr(obj.dWidth) & ", " & _
 "orient_s=" & dblStr(obj.dOrients) & ", " & _
 "orient_e=" & dblStr(obj.dOriente) & ", " & _
 "value_min=" & dblStr(obj.dValMin) & ", " & _
 "value_max=" & dblStr(obj.dValMax) & ", " & _
 "insidetype=" & dblStr(obj.dInsideType) & ", " & _
 "feat_size_id=" & dblStr(obj.dFeatClass) & ", " & _
 "ex1=" & dblStr(obj.dEx1) & ", " & _
 "ex2=" & dblStr(obj.dEx2) & ", " & _
 "ey1=" & dblStr(obj.dEy1) & ", " & _
 "ey2=" & dblStr(obj.dEy2) & ", " & _
 "ix1=" & dblStr(obj.dIx1) & ", " & _
 "ix2=" & dblStr(obj.dIx2) & ", " & _
 "iy1=" & dblStr(obj.dIy1) & ", " & _
 "iy2=" & dblStr(obj.dIy2) & ", " & _
 "dist=" & obj.objCommon.objDist & " " & _
 "WHERE dist=" & dst

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "SQL: objDefectSet(1):" & vbNewLine & lastSQLerror
 Exit Function
End If

If batched Then
 objDefectSet = True
 Exit Function
End If

RaiseEvent dfktChange(dst, obj)
RaiseEvent dataChange(filtrType, obj.objCommon.objDist)
objDefectSet = True
End Function

Public Sub ExportData(ByVal et As EN_EXP_TYPE)
traceExport.Export et, trc
End Sub

Public Function deleteTubes(ByVal fromDist As Long, ByVal toDist As Long) As Boolean
Dim cmd() As String

deleteTubes = False
ReDim cmd(2) As String
cmd(1) = "DELETE FROM common WHERE type IN (" & krotObjTypeStr(ET_WELD) & ") AND dist Between " & fromDist & " AND " & toDist
cmd(2) = "DELETE FROM weld WHERE dist Between " & fromDist & " AND " & toDist

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка очистки швов :" & vbNewLine & lastSQLerror
 Exit Function
End If
deleteTubes = True
End Function

Public Function addTube( _
ByVal tubeDist As Long, _
ByVal tubeLen As Long, _
ByVal tubeTyp As T_TUBE_TYPE, _
ByVal wld1 As Double, _
ByVal wld2 As Double, _
Optional ByVal uName As String = "" _
) As Boolean
Dim cmn As New clsObjCommon, wld As New clsObjWeld
Dim saveType As OBJ_TYPE

addTube = False

saveType = dfltType

Select Case tubeTyp
 Case TUBE_DIRECT
  dfltType = OBJ_shov_p
 Case TUBE_SPIRAL
  dfltType = OBJ_shov_s
 Case TUBE_WITHOUT
  dfltType = OBJ_shov_b
End Select

While checkDist(tubeDist)
 tubeDist = tubeDist + 1
Wend

If uName = "" Then uName = Me.userName

If objAdd(tubeDist, 0, dfltObjType, True, False, uName) = False Then
 ogdWin.Alert "Ошибка создания обьекта на отметке " & mm2txt(tubeDist)
End If

Me.objCommon tubeDist, cmn
Me.objWeld cmn, wld
  
wld.weld1 = wld1
wld.weld2 = wld2 'rStart.fullHour

Me.objWeldSet tubeDist, wld, True, uName

dfltType = saveType
addTube = True
End Function

Public Sub ImportData(exp_type As EN_EXP_TYPE, vog As ctrlVOG)
Dim fName As String, logName As String, fl As Long, lg As Long, s As String, msg As String, tmpLong As Long
Dim cmn As New clsObjCommon
Dim wld As New clsObjWeld, dfk As New clsObjDefekt, lin As New clsObjLine
Dim thk As New clsObjThick, trn As New clsobjTurn
Dim oldtyp As OBJ_TYPE
Dim dst As Long, cnt As Long, firstDist As Long, conflictCount As Long, userDist As Long
Dim rStart As New clsAnglUnit, rEnd As New clsAnglUnit
Dim cmd() As String

ReDim cmd(2) As String
msg = krotObjTypeStr(exp_type)

Select Case exp_type
 Case ET_WELD
  s = "Раскладка труб (*.wld)|*.wld"
  cmd(1) = msg
  cmd(2) = "DELETE FROM weld"
 Case ET_LINEOBJ
  s = "Линейные обьекты (*.lbj)|*.lbj"
  cmd(1) = msg
  cmd(2) = "DELETE FROM lin_obj"
 Case ET_DEFECT
  s = "Дефекты (*.dfc)|*.dfc"
  cmd(1) = msg
  cmd(2) = "DELETE FROM defect"
 Case ET_PRIGRUZ
  s = "Пригрузы (*.grv)|*.grv"
  cmd(1) = OBJ_prigruz & "," & OBJ_startprgrz & "," & OBJ_endprgrz
  cmd(2) = ""
 Case ET_THICK
  s = "Толщина стенки (*.tck)|*.tck"
  cmd(1) = OBJ_thick
  cmd(2) = "DELETE thick.* FROM thick LEFT JOIN common ON thick.dist=common.dist WHERE type = " & OBJ_TYPE.OBJ_thick
 Case ET_CATEGORY
  s = "Категории участков (*.ctg)|*.ctg"
  cmd(1) = OBJ_category
  cmd(2) = "DELETE thick.* FROM thick LEFT JOIN common ON thick.dist=common.dist WHERE type = " & OBJ_TYPE.OBJ_category
 Case ET_VOG_POVOROT
  s = "Повороты (*.str)|*.str"
  cmd(1) = msg
  cmd(2) = "DELETE FROM turn"
 Case Else
  ogdWin.Alert "Неизвестный тип импорта: " & exp_type
  Exit Sub
End Select

fName = ogdWin.fileOpen( _
 "Выберите файл внешних обьектов", _
 "", _
 "", _
 s, _
 frmMain.hWnd)

If fName = "" Then Exit Sub
If ogdWin.AskAction( _
 "Все имеющиеся в базе обьекты данного типа будут удалены " & vbNewLine & _
 "и заменены обьектами из файла " & vbNewLine & _
 fName & vbNewLine & _
 "Продолжить?", True) = False Then Exit Sub

Dim param As String

param = cmd(1)
cmd(1) = cmd(2)
cmd(2) = "DELETE FROM common WHERE type IN (" & param & ")"

If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка очистки таблицы :" & vbNewLine & lastSQLerror
 Exit Sub
End If

If (exp_type = ET_VOG_POVOROT) And (Not trc.vog.enable) Then
 ogdWin.Alert "Навигационные данные отсутствуют в этой записи." & _
  vbNewLine & "Для поворотов будут загружены дистанция, длина, тип и примечание." & _
  vbNewLine & "Данные об изгибах и углах сгенерированы не будут."
End If

cFile.fullName = fName
logName = cFile.dropExt & ".err"
fl = FreeFile
Open fName For Input As fl
lg = FreeFile
Open logName For Output As lg
conflictCount = 0
cnt = 0
setWait "Чтение из '" & fName & "' ..."

cfg.parser.Delim = ","
oldtyp = dfltObjType.id
cnt = 0
conflictCount = 0
msg = frmMain.sbar.Panels(1).Text

'считать первую строку с VERSION2
Line Input #1, s

Do
next_loop:
 Line Input #1, s
 cnt = cnt + 1
 setWait msg & " " & cnt & "..."
 cfg.parser.TestString = cfg.parser.Delim & s
 cfg.parser.Parse
 
 On Error GoTo next_loop
 userDist = cfg.parser.Item(1)
 dst = trc.getDistReal(userDist)
 On Error GoTo 0
 
 dfltType = krotObjType(exp_type, cfg.parser.Item(2))
 firstDist = -1

 While checkDist(dst)
  If firstDist < 0 Then firstDist = dst
  dst = dst + 1
 Wend

 If firstDist >= 0 Then
  conflictCount = conflictCount + 1
  Print #lg, firstDist & " => " & dst
 End If

 If objAdd(dst, 0, dfltObjType, True) = False Then
  ogdWin.Alert "Ошибка создания обьекта на отметке " & mm2txt(userDist)
 End If

 Me.objCommon dst, cmn

 Select Case exp_type

  Case ET_DEFECT
   Me.objDefect cmn, dfk
   dfk.objCommon.comment = getTileFrom(cfg.parser, 14)
   dfk.dLength = trc.getLenReal(dst, cfg.parser.Item(3))
   dfk.dWidth = cfg.parser.Item(4)
   dfk.dValMin = Abs(cfg.parser.Item(7))
   dfk.dValMax = cfg.parser.Item(8)
   dfk.dInsideType = cfg.parser.Item(5)
   dfk.dFeatClass = cfg.parser.Item(6)
   rStart.dStr = cfg.parser.Item(9)
   dfk.dOrients = rStart.fullHour
   rEnd.dStr = cfg.parser.Item(10)
   dfk.dOriente = rEnd.fullHour
   Me.objDefectSet dst, dfk, True

  Case ET_WELD
   Dim w1 As String, w2 As String
   Me.objWeld cmn, wld
   
   w1 = Trim(cfg.parser.Item(3))
   If Len(w1) > 0 Then
     rStart.dStr = w1
     wld.weld1 = rStart.fullHour
   End If
   
   w2 = Trim(cfg.parser.Item(4))
   If Len(w2) > 0 Then
     rStart.dStr = w2
     wld.weld2 = rStart.fullHour
   End If
   
   tmpLong = val(cfg.parser.Item(5))
   If tmpLong >= 0 Then
    rStart.degree = tmpLong / 100#
    wld.curve = rStart.fullHour
   End If
   
   tmpLong = Val(cfg.parser.Item(6))
   If tmpLong >= 0 Then
    rStart.degree = tmpLong / 100#
    wld.angle = rStart.fullHour
   End If
   
   wld.curveComplex = (Val(cfg.parser.Item(10)) > 0)
   wld.tube_number = cfg.parser.Item(12)
   wld.objCommon.comment = getTileFrom(cfg.parser, 13)
   
   Me.objWeldSet dst, wld, True
   ' здесь добавлять обьект переход толщины, если изменилась толщина трубы
   ' Me.objThick cmn, thk
   ' thk.dThick = cfg.parser.Item(3) / 10#
   ' Me.objThickSet dst, thk

  Case ET_LINEOBJ
   Me.objLine cmn, lin
   lin.dMarker = IIf(cfg.parser.Item(3) = 0, False, True)
   lin.dMarkerText = cfg.parser.Item(4)
   lin.dTraceDist = cfg.parser.Item(5)
   lin.objCommon.comment = getTileFrom(cfg.parser, 9)
   Me.objLineSet dst, lin, True

  Case ET_PRIGRUZ
   cmn.objLen = cfg.parser.Item(3)
   Dim i As Integer, s1 As String
   i = 7
   s1 = ""
   While i <= cfg.parser.count
     If Len(s1) > 0 Then
       s1 = s1 & cfg.parser.Delim & " "
     End If
     s1 = s1 & cfg.parser.Item(i)
     i = i + 1
   Wend
   cmn.comment = s1
   Me.objCommonSet dst, cmn, False
   
  Case ET_THICK
   Me.objThick cmn, thk
   thk.dThick = cfg.parser.Item(2) / 100#
   Me.objThickSet dst, thk, True
   
  Case ET_CATEGORY
   Me.objThick cmn, thk
   thk.dThick = cfg.parser.Item(2)
   thk.dPress = cfg.parser.Item(3)
   Me.objThickSet dst, thk, True
   
  Case ET_VOG_POVOROT
   Me.objTurn cmn, trn
   Select Case cfg.parser.Item(2)
    Case EN_TR_POVOROT_TYPE.PT_TECH
     trn.dTyp = T_TURN_TYPE.Tech
    Case EN_TR_POVOROT_TYPE.PT_NON_TECH
     trn.dTyp = T_TURN_TYPE.NonTech
    Case EN_TR_POVOROT_TYPE.PT_DEFEKT
     trn.dTyp = T_TURN_TYPE.Defekt
    Case EN_TR_POVOROT_TYPE.PT_HOLOD
     trn.dTyp = T_TURN_TYPE.Holod_gnut
    Case EN_TR_POVOROT_TYPE.PT_KRUTO
     trn.dTyp = T_TURN_TYPE.Krutoizogn
    Case EN_TR_POVOROT_TYPE.PT_SEGM
     trn.dTyp = T_TURN_TYPE.Segmentny
    Case EN_TR_POVOROT_TYPE.PT_UPRUGO
     trn.dTyp = T_TURN_TYPE.Uprugo_plast
   End Select
   trn.dLength = trc.getLenReal(dst, cfg.parser.Item(3))
   If trc.vog.enable Then trn.reCalc vog, cfg.vog.turnHor, cfg.vog.turnVer
   trn.objCommon.comment = getTileFrom(cfg.parser, 10)
   Me.objTurnSet dst, trn, True

 End Select

Loop While Not EOF(fl)

dfltType = oldtyp
RaiseEvent dataChange(filtrType, dst)
Close fl
Close lg
setReady

If conflictCount > 0 Then
 ogdWin.Alert _
  "При импорте данных из файла " & fName & _
  vbNewLine & "загружено обьектов: " & cnt & _
  vbNewLine & "обнаружено конфликтов по дистанции: " & conflictCount & _
  vbNewLine & "Протокол разрешения конфликтов смотри в файле " & _
  vbNewLine & logName
 Else
 Kill logName
 ogdWin.Info _
  "Из файла " & fName & _
  vbNewLine & "загружено обьектов: " & cnt
End If

End Sub

Private Function getTileFrom(pars As clsCommandLine, ByVal startIndex As String) As String
Dim i As Integer, s As String

s = ""
For i = startIndex To pars.count
 If Len(s) > 0 Then
  s = s & pars.Delim & " "
 End If
 s = s & pars.Item(i)
Next
getTileFrom = s
End Function

Public Sub move_Object(ByVal src_dist As Long, ByVal target_dist As Long)
RaiseEvent moveObject(src_dist, target_dist)
Me.Refresh target_dist
End Sub

Public Function Refresh(Optional ByVal dst As Long = -1) As Boolean
filtrType = getFilterString()
RaiseEvent dataChange(filtrType, dst)
End Function

Public Sub debug_Fill_50K_weld()
Dim cmd As String, i As Long

db.Execute "DELETE FROM weld", dbFailOnError
db.Execute "DELETE FROM common WHERE type=190", dbFailOnError

Debug.Print "Proccessing..."
For i = 1 To 50000
 db.Execute _
  "INSERT INTO common (dist, type) VALUES (" & i * 1000 & ", 190)", _
  dbFailOnError
 Debug.Print i
Next

Debug.Print "Recalc..."
Me.TubLengthRecalc
Debug.Print "Refresh..."
Me.Refresh
Debug.Print "Done"
End Sub

Public Function newDefekt( _
ByVal id As Long, _
ByVal X As Long, _
ByVal dx As Long, _
ByVal dy As Long, _
ByVal or1 As Double, _
ByVal or2 As Double, _
ByVal minVal As Integer, _
ByVal maxVal As Integer, _
ByVal cmnt As String, _
ByVal dInsideType As Long, _
ByVal dFeatClass As EN_FEAT_CLASS, _
ByVal dEx1 As Long, _
ByVal dEx2 As Long, _
ByVal dEy1 As Long, _
ByVal dEy2 As Long, _
ByVal dIx1 As Long, _
ByVal dIx2 As Long, _
ByVal dIy1 As Long, _
ByVal dIy2 As Long, _
ByVal attention As Boolean _
) As clsObjDefekt

Dim t As New clsObjType, d As New clsObjDefekt, c As New clsObjCommon
Dim s As String, tDflt As clsObjType

Set newDefekt = Nothing
s = id
Set tDflt = objTypes(s)

t.Init id, tDflt.name, tDflt.off, OBJ_TBL_DFKT
c.Init trc, x, dx, cmnt, attention, t
d.Init _
 c, dy, or1, or2, minVal, maxVal, _
 dInsideType, dFeatClass, dEx1, dEx2, dEy1, dEy2, dIx1, dIx2, dIy1, dIy2

If objAdd(X, dx, t) = False Then Exit Function
If objDefectSet(X, d) = False Then Exit Function

Set newDefekt = d
End Function

Private Function isRsEmpty(r As Recordset) As Boolean
isRsEmpty = r.EOF And r.BOF
End Function

Private Function getDist(ByVal dst As Long, rs As Recordset, odoFld As String, rptFld As String) As Long
Dim o1 As Long, o2 As Long, r1 As Long, r2 As Long, dbl As Double

With rs
.Seek "<=", dst
If .NoMatch Then

 o1 = 0
 r1 = 0
 .Seek ">", dst
 If .NoMatch Then
  o2 = trc.length
  r2 = trc.length
  Else
  o2 = rs(odoFld)
  r2 = rs(rptFld)
 End If

 Else

 o1 = rs(odoFld)
 r1 = rs(rptFld)
 .MoveNext
 If .EOF Then
  o2 = trc.length
  If o1 = o2 Then
   getDist = r1
   Exit Function
   Else
   'r2 = r1 + tCtl.traceEnd - o2
   getDist = dst + r1 - o1
   Exit Function
  End If
  Else
  o2 = rs(odoFld)
  r2 = rs(rptFld)
 End If

End If
End With

dbl = (dst - o1)
dbl = dbl * (r2 - r1)
getDist = r1 + dbl / (o2 - o1)
End Function

Public Function currObjVisible() As Boolean
If presentInString(filtrType, Trim$(str$(rsObj("type"))), ",") Then
 currObjVisible = False
 Else
 currObjVisible = True
End If
End Function

Public Function sqlUpdateTubLengthAtPoint(ByVal dst As Long, cmd() As String, ByVal indx1 As Long, ByVal indx2 As Long) As Boolean
Dim x1 As Long, x2 As Long, d1 As Long, d2 As Long, l As Long
Dim findFlag As Boolean

With rsObj

.Seek ">=", dst
If Not .NoMatch Then
 If dfltObjType.isTubeBorder(![Type]) = False Then moveNextWeld
  If .EOF Then
   findFlag = False
   Else
   findFlag = True
  End If
 Else
 findFlag = False
End If

If Not findFlag Then
 If moveLastWeld() Then 'последний шов
  'поправить длину последней трубы
  x1 = 0
  d2 = ![dist]
  x2 = calcTubLength()
  Else
  'нет швов вообще
  x1 = 0
  x2 = 0
 End If
 Else
 'не последний шов
 If ![dist] = dst Then
  'шов остался на том же месте
  d1 = ![dist]
  x1 = calcTubLength()
  movePrevWeld
  If .BOF Then
   'перед найденным швом швов больше нет
   x2 = 0
   Else
   'есть шов перед найденным
   d2 = ![dist]
   x2 = calcTubLength()
  End If
  Else
  'на старом месте шва уже нет
  movePrevWeld
  x1 = 0
  If .BOF Then
   x2 = 0 'удален первый шов
   Else
   d2 = ![dist]
   x2 = calcTubLength()
  End If
 End If
End If
End With

If _
  ((x1 > 0) And (x1 < cfg.obj.weldDist * 10)) Or _
  ((x2 > 0) And (x2 < cfg.obj.weldDist * 10)) Then
 sqlUpdateTubLengthAtPoint = False
 Exit Function
End If

If x1 = 0 Then
 cmd(indx1) = ""
 Else
 l = trc.getLenKoef(d1, x1)
 cmd(indx1) = "UPDATE common SET len=" & x1 & ", userLen=" & l & " WHERE dist=" & d1
End If

If x2 = 0 Then
 cmd(indx2) = ""
 Else
 l = trc.getLenKoef(d2, x2)
 cmd(indx2) = "UPDATE common SET len=" & x2 & ", userLen=" & l & " WHERE dist=" & d2
End If

sqlUpdateTubLengthAtPoint = True
End Function

Private Function getFilterString() As String
Dim c As clsObjType, s As String, off_obj As String

s = ""
off_obj = ""

For Each c In objTypes
 
 If c.off = True Then
 
   If off_obj = "" Then
     off_obj = off_obj & c.id
     Else
     off_obj = off_obj & "," & c.id
   End If
 
 Else
 
   If c.enabled = False Then
     If s = "" Then
       s = s & c.id
     Else
       s = s & "," & c.id
     End If
   End If
 
 End If

Next

If Len(s) > 0 Then
  s = s & "," & off_obj
End If

getFilterString = s
End Function

Private Function findInHideObjects(ByVal id As Integer, parser As clsCommandLine) As Boolean
Dim i As Integer

For i = 1 To parser.count
 If Val(parser.Item(i)) = id Then
  findInHideObjects = True
  Exit Function
 End If
Next
findInHideObjects = False
End Function

Public Function checkDist(ByVal dst As Long) As Boolean
rsObj.Seek "=", dst
checkDist = Not rsObj.NoMatch
End Function

Private Function krotObjTypeStr(ByVal expType As EN_EXP_TYPE) As String
Dim tbl As String, rs As Recordset

krotObjTypeStr = ""
Select Case expType
 Case ET_DEFECT
  tbl = "defect"
 Case ET_WELD
  tbl = "weld"
 Case ET_LINEOBJ
  tbl = "lin_obj"
 Case ET_THICK, ET_CATEGORY
  tbl = "thick"
 Case ET_VOG_POVOROT
  tbl = "turn"
 Case Else
  tbl = ""
End Select

If tbl = "" Then Exit Function
Set rs = db.OpenRecordset("SELECT id FROM objtypes WHERE tbl='" & tbl & "'", dbOpenSnapshot)
tbl = ""
While Not rs.EOF
 If Len(tbl) > 0 Then tbl = tbl & ","
 tbl = tbl & rs("id")
 rs.MoveNext
Wend
rs.Close
krotObjTypeStr = tbl
End Function

Public Function objCommon(ByVal dst As Long, obj As clsObjCommon) As Boolean
Dim cmd As String, rs As Recordset, objTyp As New clsObjType

objCommon = False
cmd = "SELECT * FROM common LEFT JOIN objtypes ON common.type=objtypes.id " & _
"WHERE dist=" & dst
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 ogdWin.Alert "На отметке " & mm2txt(dst) & " обьектов не найдено"
 rs.Close
 Exit Function
End If
objTyp.Init rs("id"), rs("objtypes.name"), rs("off"), rs("tbl")
obj.Init trc, dst, rs("len"), IIf(IsNull(rs("common.name")), "", rs("common.name")), rs("isAttention"), objTyp
rs.Close
objCommon = True
End Function

Public Function objLine(obj As clsObjCommon, objLin As clsObjLine) As Boolean
Dim cmd As String, rs As Recordset

objLine = False
cmd = "SELECT * FROM lin_obj WHERE dist=" & obj.objDist
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 ogdWin.Alert "На отметке " & mm2txt(obj.objDist) & " линейных обьектов не найдено"
 rs.Close
 Exit Function
End If

objLin.Init obj, _
 rs("marker"), _
 IIf(IsNull(rs("marker_text")), "", rs("marker_text")), _
 IIf(IsNull(rs("trace_dist")), "", rs("trace_dist"))

rs.Close
objLine = True
End Function

Public Function objThick(obj As clsObjCommon, objThck As clsObjThick) As Boolean
Dim cmd As String, cmdBase As String, rs As Recordset
Dim dPrev As Double, dNext As Double, dVal As Double, dPress As Double

objThick = False

cmd = "SELECT * FROM thick WHERE dist=" & obj.objDist
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 ogdWin.Alert "На отметке " & mm2txt(obj.objDist) & " обьектов участка трассы не найдено"
 rs.Close
 Exit Function
End If

dVal = IIf(IsNull(rs("thick")), 0, rs("thick"))
dPress = IIf(IsNull(rs("pressure")), 0, rs("pressure"))
rs.Close

cmdBase = "SELECT thick FROM thick LEFT JOIN common ON thick.dist=common.dist WHERE common.type = " & obj.objTyp.id

cmd = cmdBase & " AND thick.dist<" & obj.objDist & " ORDER BY thick.dist DESC"
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 dPrev = 0
 Else
 dPrev = IIf(IsNull(rs("thick")), 0, rs("thick"))
End If
rs.Close

cmd = cmdBase & " AND thick.dist>" & obj.objDist & " ORDER BY thick.dist"
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 dNext = 0
 Else
 dNext = IIf(IsNull(rs("thick")), 0, rs("thick"))
End If
rs.Close

objThck.Init obj, dPrev, dVal, dNext, dPress

objThick = True
End Function

Public Function objTurn(obj As clsObjCommon, objTrn As clsobjTurn) As Boolean
Dim cmd As String, rs As Recordset
Dim drxy As Long, daxy As Single
Dim drz As Long, daz As Single, dmz As Long, dmx As Long, dmy As Long
Dim ddh As Boolean, ddv As Boolean, ddt As Integer
Dim dts As Boolean, dte As Boolean, drc As Integer

objTurn = False

cmd = "SELECT * FROM turn WHERE dist=" & obj.objDist
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 ogdWin.Alert "На отметке " & mm2txt(obj.objDist) & " поворотов не найдено"
 rs.Close
 Exit Function
End If

drxy = IIf(IsNull(rs("radxy")), 0, rs("radxy"))
daxy = IIf(IsNull(rs("anglxy")), 0, rs("anglxy"))
drz = IIf(IsNull(rs("radz")), 0, rs("radz"))
daz = IIf(IsNull(rs("anglz")), 0, rs("anglz"))
dmx = IIf(IsNull(rs("xmark")), 0, rs("xmark"))
dmy = IIf(IsNull(rs("ymark")), 0, rs("ymark"))
dmz = IIf(IsNull(rs("zmark")), 0, rs("zmark"))
ddh = rs("horz")
ddv = rs("vert")
ddt = IIf(IsNull(rs("typ")), T_TURN_TYPE.NonTech, rs("typ"))
dts = rs("startTune")
dte = rs("endTune")
drc = IIf(IsNull(rs("calctyp")), 0, rs("calctyp"))

rs.Close
objTrn.Init obj, ddv, ddh, ddt, dts, dte, drc, drxy, daxy, drz, daz, dmx, dmy, dmz
objTurn = True
End Function

Public Function objWeld(obj As clsObjCommon, objWld As clsObjWeld) As Boolean
Dim cmd As String, rs As Recordset

objWeld = False
cmd = "SELECT * FROM weld WHERE dist=" & obj.objDist
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 ogdWin.Alert "На отметке " & mm2txt(obj.objDist) & " шов не найден"
 rs.Close
 Exit Function
End If

objWld.Init _
 obj, _
 IIf(IsNull(rs("weld1")), -1, rs("weld1")), _
 IIf(IsNull(rs("weld2")), -1, rs("weld2")), _
 IIf(IsNull(rs("curve")), 0, rs("curve")), _
 IIf(IsNull(rs("angle")), 0, rs("angle")), _
 rs("isComplexCurve"), _
 IIf(IsNull(rs("tube_number")), "", rs("tube_number"))

rs.Close
objWeld = True
End Function

Public Function objDefect(obj As clsObjCommon, objDfkt As clsObjDefekt, Optional ByVal noMsg As Boolean = False) As Boolean
Dim cmd As String, rs As Recordset

objDefect = False
cmd = "SELECT * FROM defect WHERE dist=" & obj.objDist
Set rs = db.OpenRecordset(cmd, dbOpenSnapshot)
If rs.RecordCount = 0 Then
 If noMsg = False Then
  ogdWin.Alert "На отметке " & mm2txt(obj.objDist) & " дефектов не найдено"
  Me.rsObj.Seek "=", obj.objDist
  If Not Me.rsObj.NoMatch Then Me.rEdit.Delete
 End If
 rs.Close
 Exit Function
End If

objDfkt.Init obj, _
 IIf(IsNull(rs("width")), 0, rs("width")), _
 IIf(IsNull(rs("orient_s")), 0, rs("orient_s")), _
 IIf(IsNull(rs("orient_e")), 0, rs("orient_e")), _
 IIf(IsNull(rs("value_min")), 0, rs("value_min")), _
 IIf(IsNull(rs("value_max")), 0, rs("value_max")), _
 IIf(IsNull(rs("insidetype")), 0, rs("insidetype")), _
 IIf(IsNull(rs("feat_size_id")), 0, rs("feat_size_id")), _
 IIf(IsNull(rs("ex1")), 0, rs("ex1")), _
 IIf(IsNull(rs("ex2")), 0, rs("ex2")), _
 IIf(IsNull(rs("ey1")), 0, rs("ey1")), _
 IIf(IsNull(rs("ey2")), 0, rs("ey2")), _
 IIf(IsNull(rs("ix1")), 0, rs("ix1")), _
 IIf(IsNull(rs("ix2")), 0, rs("ix2")), _
 IIf(IsNull(rs("iy1")), 0, rs("iy1")), _
 IIf(IsNull(rs("iy2")), 0, rs("iy2"))

rs.Close
objDefect = True
End Function

Private Function fldDbl2str(ByRef rs As Recordset, ByVal fld As String, ByVal dflt As String) As String
If IsNull(rs(fld)) Then
 fldDbl2str = dflt
 Else
 fldDbl2str = dblStr(rs(fld))
End If
End Function

Public Function TurnsRecalc(vogControl As ctrlVOG) As Boolean
Dim objTurn As New clsobjTurn, objCommon As New clsObjCommon
Dim r As Recordset
Dim sql As String

sql = "SELECT common.dist AS dist,typ,len,anglxy,anglz,xmark,ymark,zmark,name " & _
"FROM common INNER JOIN turn ON common.dist=turn.dist WHERE " & _
"type=" & CStr(OBJ_povorot) & _
" AND common.dist>0 " & _
" AND len>0 " & _
"ORDER BY common.dist"

Set r = db.OpenRecordset(sql, dbOpenSnapshot)

While Not r.EOF
 If Me.objCommon(r("dist"), objCommon) Then
   If Me.objTurn(objCommon, objTurn) Then
     objTurn.reCalc vogControl, cfg.vog.turnHor, cfg.vog.turnVer, objTurn.dCalctyp
     Me.objTurnSet objCommon.objDist, objTurn, True
   End If
 End If
 setWait "Выполнено: " + CStr(CInt(r.PercentPosition)) + "%"
 r.MoveNext
Wend
r.Close
End Function

Public Function TubLengthRecalc() As Boolean
Dim tbl As TableDef, cmd() As String
Dim rs As Recordset, s As String
Dim dst As Long, cnt As Long, tlen As Long, msg As String
Dim weld1 As String, weld2 As String, curve As String, angle As String, isComlex As String

TubLengthRecalc = True
On Error GoTo noTable
If IsNull(db.TableDefs("weld")) Then DoEvents
On Error GoTo 0

ReDim cmd(2)
cmd(1) = "DELETE FROM weld"
cmd(2) = ""

s = "SELECT * FROM weld RIGHT JOIN (common LEFT JOIN objtypes ON common.type=objtypes.id) ON weld.dist=common.dist " & _
"WHERE objtypes.tbl='" & OBJ_TBL_WELD & "' " & _
"ORDER BY common.dist"
Set rs = db.OpenRecordset(s, dbOpenSnapshot)

If Not (SQLexe(db, cmd)) Then
 ogdWin.Alert "SQL: TubLengthRecalc(1):" & vbNewLine & lastSQLerror
 TubLengthRecalc = False
End If

cnt = 0
msg = "Пересчет длин труб... " & rs.RecordCount & " / "

dst = rs("common.dist")
weld1 = fldDbl2str(rs, "weld1", "-1")
weld2 = fldDbl2str(rs, "weld2", "-1")
curve = fldDbl2str(rs, "curve", "0")
angle = fldDbl2str(rs, "angle", "0")
isComlex = IIf(rs("isComplexCurve"), "1", "0")

rs.MoveNext
While Not rs.EOF
 cnt = cnt + 1
 setWait msg & cnt
 tlen = rs("common.dist") - dst
 cmd(1) = _
  "INSERT INTO weld (dist,weld1,weld2,curve,angle,isComplexCurve) " & _
  "VALUES (" & _
  dst & "," & weld1 & "," & weld2 & "," & curve & "," & angle & "," & isComlex & _
  ")"
 cmd(2) = "UPDATE common SET len=" & tlen & " WHERE dist=" & dst
 
 If Not (SQLexe(db, cmd)) Then
  ogdWin.Alert "SQL: TubLengthRecalc(2):" & vbNewLine & lastSQLerror
  TubLengthRecalc = False
 End If

 dst = rs("common.dist")
 weld1 = fldDbl2str(rs, "weld1", "-1")
 weld2 = fldDbl2str(rs, "weld2", "-1")
 curve = fldDbl2str(rs, "curve", "0")
 angle = fldDbl2str(rs, "angle", "0")
 isComlex = IIf(rs("isComplexCurve"), "1", "0")
 
 rs.MoveNext
Wend

cnt = cnt + 1
tlen = trc.length - dst
cmd(1) = _
 "INSERT INTO weld (dist,weld1,weld2,curve,angle,isComplexCurve) " & _
 "VALUES (" & _
 dst & "," & weld1 & "," & weld2 & "," & curve & "," & angle & "," & isComlex & _
 ")"
cmd(2) = "UPDATE common SET len=" & tlen & " WHERE dist=" & dst

rs.Close

If Not (SQLexe(db, cmd)) Then
 ogdWin.Alert "SQL: TubLengthRecalc(3):" & vbNewLine & lastSQLerror
 TubLengthRecalc = False
End If
ReDim cmd(0)

Exit Function

noTable:
Set tbl = db.CreateTableDef("weld")
bildWeldTable tbl
db.TableDefs.Append tbl
Resume Next

End Function

Private Sub moveNextWeld()
With rsObj
.MoveNext
While Not .EOF
 If dfltObjType.isTubeBorder(![Type]) Then Exit Sub
 .MoveNext
Wend
End With
End Sub

Private Sub movePrevWeld()
With rsObj
.MovePrevious
While Not .BOF
 If dfltObjType.isTubeBorder(![Type]) Then Exit Sub
 .MovePrevious
Wend
End With
End Sub

Private Function moveLastWeld() As Boolean
moveLastWeld = False
With rsObj
.Seek "<", 1000000000 '1000 км -> таких дистанций не бывает -> найдет последнюю
If .NoMatch Then Exit Function ' нет обьектов вообще

moveLastWeld = True
If dfltObjType.isTubeBorder(![Type]) Then Exit Function
.MovePrevious
While Not .BOF
 If dfltObjType.isTubeBorder(![Type]) Then Exit Function
 .MovePrevious
Wend
End With
moveLastWeld = False
End Function

'функция считает расстояние между текущим швом в рекодсете и следующим
'рекордсет содержит только швы
Private Function calcTubLength() As Long
Dim s As Long

With rsObj
s = ![dist]
moveNextWeld
If .EOF Then
 calcTubLength = trc.length - s
 Else
 calcTubLength = ![dist] - s
End If
movePrevWeld
End With
End Function

Private Sub bildWeldTable(tbl As TableDef)
Dim mUtil As New clsMdbUtil

With mUtil
.logName = ""
.makeField tbl, "dist", 4, 4, False, 0
.makeIndex tbl, "iid", "+dist", True, True, False
End With

End Sub

Public Function getTubeAtDist(ByVal dst As Long) As clsObjWeld
Dim wdist As Long, oc As clsObjCommon, ow As clsObjWeld, rs As Recordset


Set rs = db.OpenRecordset("SELECT dist FROM weld WHERE dist >= " & dst & " ORDER BY dist", dbOpenSnapshot)
If rs.RecordCount = 0 Then
  rsWeldTable.MoveLast
Else
  rs.MoveFirst
  rsWeldTable.Seek "=", rs("dist")
  If rsWeldTable.NoMatch Then
    Err.Raise 11
  End If
  rsWeldTable.MovePrevious
  If rsWeldTable.NoMatch Then
    rsWeldTable.MoveFirst
  End If
End If

wdist = rsWeldTable("dist")

Set oc = New clsObjCommon
If Me.objCommon(wdist, oc) = False Then
  Err.Raise 11
End If

Set ow = New clsObjWeld
If Me.objWeld(oc, ow) = False Then
  Err.Raise 11
End If

Set getTubeAtDist = ow
End Function

Public Function nearTubLength(ByVal dst As Long, ByVal isPrev As Boolean) As Long
Dim outTube As Boolean

nearTubLength = 0
rsWeldTable.Seek "=", dst

If rsWeldTable.NoMatch Then
 ogdWin.Alert "Но отметке " & mm2txt(trc.getDistKoef(dst)) & " шов не найден!"
 Exit Function
End If

If isPrev Then
 rsWeldTable.MovePrevious
 outTube = rsWeldTable.BOF
 Else
 rsWeldTable.MoveNext
 outTube = rsWeldTable.EOF
End If

If outTube Then
 nearTubLength = 0
 Else
 rsObj.Seek "=", rsWeldTable("dist")
 nearTubLength = rsObj("len")
 rsObj.Seek "=", dst
End If
End Function

Public Sub dropSlits()
Dim cmd() As String

ReDim cmd(1) As String
cmd(1) = "UPDATE weld SET weld1 = -1, weld2 = -1 WHERE weld1=0 AND weld2=0"
If SQLexe(db, cmd) = False Then
 ogdWin.Alert "Ошибка обновления таблицы weld:" & vbNewLine & lastSQLerror
End If
End Sub

Public Function getPointLinks(pl As clsPointLink) As Boolean
Dim rsMark As Recordset, rsWeld As Recordset
Dim wr As Long, wl As Long, i As Integer
Dim cmd As String
Dim objWld As New clsObjWeld, objCmn As New clsObjCommon, objTyp As New clsObjType

cmd = _
"SELECT * FROM lin_obj LEFT JOIN common ON lin_obj.dist=common.dist " & _
"WHERE lin_obj.marker=True " & _
"ORDER BY common.dist"
Set rsMark = db.OpenRecordset(cmd, dbOpenSnapshot)

cmd = _
"SELECT * FROM objtypes RIGHT JOIN (weld LEFT JOIN common ON weld.dist=common.dist) ON objtypes.id=common.type " & _
"ORDER BY common.dist"
Set rsWeld = db.OpenRecordset(cmd, dbOpenSnapshot)

getPointLinks = True

With rsMark
If .RecordCount > 0 Then
 .FindFirst "common.dist > " & pl.pointDist
 If Not .NoMatch Then
  pl.mrk2Dist = rsMark("common.dist")
  pl.mrk2Name = IIf(IsNull(rsMark("marker_text")), "", rsMark("marker_text"))
 End If
 .FindLast "common.dist < " & pl.pointDist
 If Not .NoMatch Then
  pl.mrk1Dist = rsMark("common.dist")
  pl.mrk1Name = IIf(IsNull(rsMark("marker_text")), "", rsMark("marker_text"))
 End If
End If
End With

wl = -1
wr = -1
With rsWeld
If .RecordCount > 0 Then

 .FindFirst "common.dist > " & pl.pointDist
 If Not .NoMatch Then

  wr = rsWeld("common.dist")
  For i = 0 To pl.tubesNum - 1
   cmd = IIf(IsNull(rsWeld("common.name")), "", rsWeld("common.name"))
   objTyp.Init rsWeld("type"), rsWeld("objtypes.name"), rsWeld("off"), rsWeld("tbl")
   objCmn.Init trc, rsWeld("common.dist"), rsWeld("len"), cmd, rsWeld("isAttention"), objTyp

   objWld.Init _
    objCmn, _
    dbDbl(rsWeld, "weld1"), _
    dbDbl(rsWeld, "weld2"), _
    dbDbl(rsWeld, "curve"), _
    dbDbl(rsWeld, "angle"), _
    rsWeld("isComplexCurve"), _
    IIf(IsNull(rsWeld("tube_number")), "", rsWeld("tube_number"))

   pl.setTube i, False, objWld
   .MoveNext
   If .EOF Then Exit For
  Next

 End If

 .FindLast "common.dist <= " & pl.pointDist
 If Not .NoMatch Then

  wl = rsWeld("common.dist")
  cmd = IIf(IsNull(rsWeld("common.name")), "", rsWeld("common.name"))
  objTyp.Init rsWeld("type"), rsWeld("objtypes.name"), rsWeld("off"), rsWeld("tbl")
  objCmn.Init trc, rsWeld("common.dist"), rsWeld("len"), cmd, rsWeld("isAttention"), objTyp

  objWld.Init _
   objCmn, _
   dbDbl(rsWeld, "weld1"), _
   dbDbl(rsWeld, "weld2"), _
   dbDbl(rsWeld, "curve"), _
   dbDbl(rsWeld, "angle"), _
   rsWeld("isComplexCurve"), _
   IIf(IsNull(rsWeld("tube_number")), "", rsWeld("tube_number"))

  pl.setTubeDfkt objWld

  For i = 0 To pl.tubesNum - 1
   .MovePrevious
   If .BOF Then Exit For
   cmd = IIf(IsNull(rsWeld("common.name")), "", rsWeld("common.name"))
   objTyp.Init rsWeld("type"), rsWeld("objtypes.name"), rsWeld("off"), rsWeld("tbl")
   objCmn.Init trc, rsWeld("common.dist"), rsWeld("len"), cmd, rsWeld("isAttention"), objTyp

   objWld.Init _
    objCmn, _
    rsWeld("weld1"), _
    rsWeld("weld2"), _
    rsWeld("curve"), _
    rsWeld("angle"), _
    rsWeld("isComplexCurve"), _
    IIf(IsNull(rsWeld("tube_number")), "", rsWeld("tube_number"))

   pl.setTube i, True, objWld
  Next

 End If

End If
End With

If (wl < 0) Or (wr < 0) Then Exit Function
pl.tubeDfktLeft = pl.pointDist - wl
pl.tubeDfktRight = wr - pl.pointDist
End Function

Public Function TubLengthCheck() As Long
Dim rs As Recordset, cmd As String
Dim dst As Long, tlen As Long, cnt As Long

TubLengthCheck = 0
On Error GoTo noTable
If IsNull(Me.db.TableDefs("weld")) Then DoEvents
On Error GoTo 0

cmd = "SELECT * FROM " & _
"objtypes RIGHT JOIN common ON objtypes.id=common.type " & _
"WHERE objtypes.tbl='" & OBJ_TBL_WELD & "' " & _
"ORDER BY dist"
Set rs = Me.db.OpenRecordset(cmd, dbOpenSnapshot)

If rs.EOF Then
 rs.Close
 Exit Function
End If
cnt = 0

dst = rs("dist")
tlen = IIf(IsNull(rs("len")), 0, rs("len"))
rs.MoveNext
While Not rs.EOF
 If tlen <> (rs("dist") - dst) Then cnt = cnt + 1
 dst = rs("dist")
 tlen = IIf(IsNull(rs("len")), 0, rs("len"))
 rs.MoveNext
Wend

If tlen <> (trc.length - dst) Then cnt = cnt + 1

rs.Close
If cnt > 0 Then TubLengthCheck = cnt
Exit Function

noTable:
TubLengthCheck = -1
Exit Function
End Function

Property Get isNeedRecalc() As Boolean
isNeedRecalc = isNeedKoefRecalc
End Property

Property Get odoKoef() As Double
odoKoef = d_odoKoef
End Property
Property Let odoKoef(d As Double)
If d_odoKoef = d Then Exit Property
d_odoKoef = d
isNeedKoefRecalc = True
End Property

Property Get distMode() As Integer
distMode = d_distMode
End Property
Property Let distMode(d As Integer)
If d_distMode = d Then Exit Property
d_distMode = d
isNeedKoefRecalc = True
End Property

Property Get odoStart() As Long
odoStart = d_odoStart
End Property
Property Let odoStart(d As Long)
If d_odoStart = d Then Exit Property
d_odoStart = d
isNeedKoefRecalc = True
End Property

Private Sub Class_Initialize()
isNeedKoefRecalc = False
End Sub

Public Sub CloseDb()
If Not (db Is Nothing) Then
 db.Close
 Set db = Nothing
End If
End Sub