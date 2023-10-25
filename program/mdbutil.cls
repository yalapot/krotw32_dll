VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMdbUtil"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const S_ATTACH = "ATTACH"
Private Const S_TABLE = "TABLE"
Private Const S_FIELD = "FIELD"
Private Const S_INDEX = "INDEX"
Private Const S_ENDTABLE = "ENDTABLE"
Private Const S_QUERY = "QUERY"
Private Const S_ENDQUERY = "ENDQUERY"

Private Const S_DFLTDELIM = ";"
Private Const S_INDXDELIM = "#"

Private Const CMD_LOG = "DB_LOG"
Private Const CMD_FLAG = "DB_FLAG"
Private Const CMD_MAKE = "DB_MAKE"
Private Const CMD_MAKEUNQ = "DB_MAKEUNIQ"
Private Const CMD_OPEN = "DB_OPEN"
Private Const CMD_PACK = "DB_PACK"
Private Const CMD_LIST = "DB_LIST"
Private Const CMD_EXPORT = "DB_EXPORT"

Private logFile As String
Private scrFile As Integer
Private scrFileName As String
Private lineNumber As Integer
Private scriptLine As String
Private db As Database
Private dbFlag As Boolean

Public Function Proccess(scr As String) As Boolean
logFile = ""
scrFile = -1
scrFileName = ""
lineNumber = 0
scriptLine = ""
Set db = Nothing
dbFlag = False

scrFileName = scr
scrFile = FreeFile
On Error GoTo notOpen
Open scrFileName For Input As scrFile
On Error GoTo 0

While Not EOF(scrFile)
 readLine
 If scriptLine = "" Then GoTo skip
 If Asc(scriptLine) = Asc(";") Then GoTo skip
 If UCase(Left$(scriptLine, 3)) = "DB_" Then
  procCommand
  Else
  procSql
 End If

skip:
Wend

Close scrFile
If dbFlag Then db.Close
If logFile <> "" Then Log logFile, "Finish " & scrFileName

notOpen:
End Function

Private Sub readLine()
Line Input #scrFile, scriptLine
scriptLine = Trim$(scriptLine)
lineNumber = lineNumber + 1
End Sub

Private Sub cmdLog(msg As String)
If logFile = "" Then Exit Sub
msg = " Error line " & lineNumber & ": " & msg
Log logFile, msg
End Sub

Private Sub procSql()
Dim cmd As String

Select Case UCase(scriptLine)
 Case UCase("BeginTrans")
  BeginTrans
 Case UCase("CommitTrans")
  CommitTrans
 Case Else
  cmd = readFullSentence(scriptLine)
  If cmd = "" Then
   GoTo unexpectedEOF
   Else
   On Error GoTo sqlError
   db.Execute cmd, dbFailOnError
   On Error GoTo 0
  End If
End Select

GoTo endError

sqlError:
cmdLog "SQL: " & cmd & vbNewLine & "Err: " & Err.Description
GoTo endError

unexpectedEOF:
cmdLog "Unexpected EOF."
GoTo endError

endError:
End Sub

Private Sub procCommand()
Dim cmd As String, cline As New clsCommandLine
Dim msg As String

cline.Delim = " "
cline.TestString = " " & scriptLine
cline.Parse

cmd = cline.Item(1)

Select Case UCase(cmd)

Case CMD_LOG
 logFile = cline.Item(2)
 Log logFile, "Start " & scrFileName

Case CMD_FLAG
 If Me.makeFlag(cline.Item(2)) = False Then
  msg = "Can't create flag " & cline.Item(2)
  cmdLog msg
 End If
 
Case CMD_MAKE
 makeBase cline.Item(2), cline.Item(3)
 
Case CMD_MAKEUNQ
 makeBase (cline.Item(4) & Right(getID(cline.Item(2)), 8) & ".mdb"), cline.Item(3)
 
Case CMD_OPEN
 openBase cline.Item(2)
 
Case CMD_PACK
 packBase
 
Case CMD_LIST
 listBase cline.Item(2)
 
Case CMD_EXPORT
 exportBase cline.Item(2)
 
Case Else
 cmdLog "Unknown command: " & scriptLine
 
End Select

End Sub

Public Function makeFlag(fname As String) As Boolean
Dim fl As Integer

fl = FreeFile
On Error GoTo fail
Open fname For Output As fl
On Error GoTo 0

Close fl
makeFlag = True
Exit Function

fail:
makeFlag = False
End Function

Private Function readFullSentence(s As String) As String
Dim cmd As String

cmd = ""
While (Right(s, 1) = "_")
 cmd = cmd & Left(s, Len(s) - 1)
 If EOF(scrFile) Then
  readFullSentence = ""
  Exit Function
  Else
  readLine
  s = scriptLine
 End If
Wend

readFullSentence = cmd & s
End Function

Private Sub exportBase(iniFile As String)
Dim fl As Integer, i As Integer
Dim cl As New clsCommandLine
Dim s As String

fl = FreeFile
i = 0
cl.Delim = S_DFLTDELIM

Open iniFile For Input As fl

While Not EOF(fl)
 Line Input #fl, s
 s = Trim$(s)
 If Not s = "" Then
  If Not Asc(s) = Asc(";") Then
   If exportTable(db, s, cl) Then
    i = i + 1
   End If
  End If
 End If
Wend

Close fl
End Sub

Private Function exportTable(db As Database, cmd As String, cl As clsCommandLine) As Boolean
Dim cmds() As String

ReDim cmds(1) As String
cl.TestString = S_DFLTDELIM & cmd
cl.Parse
cmds(1) = "SELECT * INTO " & _
"[Text;database=" & cl.Item(2) & "]." & cl.Item(3) & _
" FROM " & cl.Item(1) & " " & cl.Item(4)

If SQLexe(db, cmds) = 0 Then
 exportTable = True
 Else
 exportTable = False
End If
End Function

Private Sub procLeksem(db As Database, fl As Integer)
Dim s As String, procFlag As Boolean, cl As New clsCommandLine
Dim i As Integer

procFlag = True
cl.Delim = S_DFLTDELIM
While procFlag
 Line Input #fl, s
 If EOF(fl) Then procFlag = False
 s = Trim$(s)
 If Len(s) > 0 Then
 If Not Asc(s) = Asc(";") Then
  cl.TestString = S_DFLTDELIM & s
  cl.Parse
  Select Case cl.Item(1)
   Case S_ATTACH
   attachTable db, cl.Item(2), cl.Item(3), cl.Item(4), cl.Item(5)
   procFlag = False
   Case S_TABLE
   makeTable db, fl, cl.Item(2)
   procFlag = False
   Case S_QUERY
   s = ""
   For i = 3 To cl.Count
    s = s & cl.Item(i)
   Next
   makeQuery db, fl, cl.Item(2), s
   procFlag = False
   Case Else
  End Select
 End If
 End If
Wend

End Sub

Public Function makeField(tbl As TableDef, _
name As String, _
typ As Long, _
size As Integer, _
azl As Boolean, _
dflt As String _
) As Boolean
Dim fld As Field

Set fld = tbl.CreateField(name, typ, size)
If (typ = dbText) Or (typ = dbMemo) Then
 fld.AllowZeroLength = azl
End If
fld.DefaultValue = dflt

On Error GoTo badLink
tbl.Fields.Append fld
On Error GoTo 0

Set fld = Nothing
makeField = True
Exit Function

badLink:
On Error GoTo 0
Set fld = Nothing

cmdLog _
"Can't create field" & vbNewLine & _
"Name : " & name & vbNewLine & _
"Type : " & typ & vbNewLine & _
"Size : " & size & vbNewLine & _
"AllowZeroLength : " & azl
makeField = False
Exit Function

End Function

Public Function makeIndex(tbl As TableDef, _
name As String, _
indxFields As String, _
Primary As Boolean, _
Unique As Boolean, _
IgnoreNulls As Boolean _
) As Boolean
Dim indx  As Index

Set indx = tbl.CreateIndex(name)
indx.Fields = indxFields
indx.Primary = Primary
indx.Unique = Unique
indx.IgnoreNulls = IgnoreNulls

On Error GoTo badLink
tbl.Indexes.Append indx
On Error GoTo 0

Set indx = Nothing
makeIndex = True
Exit Function

badLink:
On Error GoTo 0
Set indx = Nothing

cmdLog _
"Can't create index" & vbNewLine & _
"Fields : " & name & vbNewLine & _
"Primary : " & Primary & vbNewLine & _
"Unique : " & Unique & vbNewLine & _
"IgnoreNulls : " & IgnoreNulls
makeIndex = False
Exit Function

End Function

Private Function makeTable(db As Database, fl As Integer, name As String) As Boolean
Dim s As String, procFlag As Boolean
Dim cl As New clsCommandLine, indx As New clsCommandLine
Dim tbl As TableDef
Dim sErr As String

procFlag = True
cl.Delim = S_DFLTDELIM
indx.Delim = S_INDXDELIM
Set tbl = db.CreateTableDef(name)

While procFlag
 Line Input #fl, s
 If EOF(fl) Then procFlag = False
 s = Trim$(s)
 If Len(s) > 0 Then
 If Not Asc(s) = Asc(";") Then
 
  If Left(s, Len(S_INDEX)) = S_INDEX Then
   
   indx.TestString = S_INDXDELIM & s
   indx.Parse
   makeIndex tbl, indx.Item(2), indx.Item(3), indx.Item(4), indx.Item(5), indx.Item(6)
   
  Else
  
   cl.TestString = S_DFLTDELIM & s
   cl.Parse
   Select Case cl.Item(1)
    Case S_FIELD
    makeField tbl, cl.Item(2), cl.Item(3), cl.Item(4), cl.Item(5), cl.Item(6)
    Case S_ENDTABLE
    procFlag = False
    Case Else
   End Select
   
  End If
 End If
 End If
Wend

On Error GoTo badLink
db.TableDefs.Append tbl
On Error GoTo 0

Set tbl = Nothing
makeTable = True
Exit Function

badLink:
sErr = Err.Description
On Error GoTo 0
Set tbl = Nothing

cmdLog _
"Can't create table" & vbNewLine & _
"Name : " & name + vbNewLine & _
"Error : " + sErr
makeTable = False
Exit Function

End Function

Private Function makeQuery(db As Database, fl As Integer, name As String, cnct As String) As Boolean
Dim s As String, procFlag As Boolean, sqltxt As String
Dim tbl As QueryDef

procFlag = True
Set tbl = db.CreateQueryDef(name)

While procFlag
 Line Input #fl, s
 If EOF(fl) Then procFlag = False
 s = Trim$(s)
 If s = S_ENDQUERY Then
  procFlag = False
  Else
  sqltxt = sqltxt & s & vbNewLine
 End If
Wend

On Error GoTo badLink
tbl.sql = sqltxt
tbl.Connect = cnct
On Error GoTo 0

Set tbl = Nothing
makeQuery = True
Exit Function

badLink:
On Error GoTo 0
Set tbl = Nothing

cmdLog _
"Can't create query" & vbNewLine & _
"Name : " & name & vbNewLine & _
"Connect : " & cnct & vbNewLine & _
"SqlText : " & vbNewLine & sqltxt
makeQuery = False
Exit Function

End Function

Private Function makeDataBase(dbName As String) As Boolean

If dbFlag Then
 db.Close
 dbFlag = False
End If

If fExist(dbName) Then Kill dbName

On Error GoTo openError
Set db = CreateDatabase(dbName, dbLangCyrillic)
On Error GoTo 0
dbFlag = True
makeDataBase = True
Exit Function

openError:
cmdLog "Can't create " & dbName
makeDataBase = False
End Function

Private Sub makeBase(dbName As String, iniFile As String)
Dim fl As Integer, i As Integer
Dim cl As New clsCommandLine

If makeDataBase(dbName) = False Then Exit Sub
fl = FreeFile
i = 0
cl.Delim = S_DFLTDELIM
Open iniFile For Input As fl
While Not EOF(fl)
 procLeksem db, fl
 i = i + 1
Wend
Close fl
End Sub

Private Function attachTable(db As Database, _
name As String, _
typ As String, _
dbName As String, _
tblname As String _
) As Boolean

Dim tbl As TableDef

Set tbl = db.CreateTableDef(name)
tbl.Connect = typ & ";" & dbName
tbl.SourceTableName = tblname

On Error GoTo badLink
db.TableDefs.Append tbl
On Error GoTo 0

Set tbl = Nothing
attachTable = True
Exit Function

badLink:
On Error GoTo 0
Set tbl = Nothing

cmdLog _
"Can't create attachment" & vbNewLine & _
"Name : " & name & vbNewLine & _
"Type : " & typ & vbNewLine & _
"Base : " & dbName & vbNewLine & _
"Table: " & tblname

attachTable = False
Exit Function

End Function

Private Sub attachList(db As Database, fl As Integer)
Dim tbl As TableDef

Print #fl, ""
Print #fl, "; Attachment list"
Print #fl, "; " & S_ATTACH & S_DFLTDELIM & _
"name" & S_DFLTDELIM & _
"database type" & S_DFLTDELIM & _
"database" & S_DFLTDELIM & _
"table"
Print #fl, ""

For Each tbl In db.TableDefs
 If tbl.Connect <> "" Then
  Print #fl, S_ATTACH & S_DFLTDELIM;
  Print #fl, tbl.name;
  Print #fl, S_DFLTDELIM;
  Print #fl, tbl.Connect;
  Print #fl, S_DFLTDELIM;
  Print #fl, tbl.SourceTableName
 End If
Next

End Sub

Private Sub tablesList(db As Database, fl As Integer)
Dim tbl As TableDef, fld As Field, indx As Index

Print #fl, ""
Print #fl, "; Tables list"
Print #fl, "; " & S_TABLE & S_DFLTDELIM & "name"
Print #fl, "; " & S_FIELD & S_DFLTDELIM & _
"name" & S_DFLTDELIM & _
"Type" & S_DFLTDELIM & _
"Size" & S_DFLTDELIM & _
"AllowZeroLength" & S_DFLTDELIM & _
"DefaultValue"
Print #fl, "; ..."
Print #fl, "; " & S_INDEX & S_INDXDELIM & _
"name" & S_INDXDELIM & _
"Fields" & S_INDXDELIM & _
"Primary" & S_INDXDELIM & _
"Unique" & S_INDXDELIM & _
"IgnoreNulls"
Print #fl, "; ..."
Print #fl, "; " & S_ENDTABLE
Print #fl, ""

Print #fl, "; Type is:"
Print #fl, "; " & dbBigInt & " - Big Int"
Print #fl, "; " & dbBinary & " - Binary"
Print #fl, "; " & dbBoolean & " - Boolean"
Print #fl, "; " & dbByte & " - Byte"
Print #fl, "; " & dbChar & " - Char"
Print #fl, "; " & dbCurrency & " - Currency"
Print #fl, "; " & dbDate & " - Date / Time"
Print #fl, "; " & dbDecimal & " - Decimal"
Print #fl, "; " & dbDouble & " - Double"
Print #fl, "; " & dbFloat & " - Float"
Print #fl, "; " & dbGUID & " - Guid"
Print #fl, "; " & dbInteger & " - Integer"
Print #fl, "; " & dbLong & " - Long"
Print #fl, "; " & dbLongBinary & " - Long Binary (OLE Object)"
Print #fl, "; " & dbMemo & " - Memo"
Print #fl, "; " & dbNumeric & " - Numeric"
Print #fl, "; " & dbSingle & " - Single"
Print #fl, "; " & dbText & " - Text"
Print #fl, "; " & dbTime & " - Time"
Print #fl, "; " & dbTimeStamp & " - Time Stamp"
Print #fl, "; " & dbVarBinary & " - VarBinary"
Print #fl, ""

For Each tbl In db.TableDefs
 If tbl.Connect = "" And ((tbl.Attributes And dbSystemObject) = 0) Then
 
  Print #fl, S_TABLE & S_DFLTDELIM;
  Print #fl, tbl.name
  
  For Each fld In tbl.Fields
   Print #fl, S_FIELD & S_DFLTDELIM;
   Print #fl, fld.name & S_DFLTDELIM;
   Print #fl, fld.Type & S_DFLTDELIM;
   Print #fl, fld.size & S_DFLTDELIM;
   Print #fl, fld.AllowZeroLength & S_DFLTDELIM;
   'Print #fl, fld.Required & S_DFLTDELIM;
   Print #fl, fld.DefaultValue
  Next
  
  For Each indx In tbl.Indexes
   Print #fl, S_INDEX & S_INDXDELIM;
   Print #fl, indx.name & S_INDXDELIM;
   Print #fl, indx.Fields & S_INDXDELIM;
   Print #fl, indx.Primary & S_INDXDELIM;
   Print #fl, indx.Unique & S_INDXDELIM;
   Print #fl, indx.IgnoreNulls
  Next
  
  Print #fl, S_ENDTABLE
  Print #fl, ""
 End If
Next

End Sub

Private Sub queryList(db As Database, fl As Integer)
Dim tbl As QueryDef

Print #fl, ""
Print #fl, "; Query list"
Print #fl, "; " & S_QUERY & S_DFLTDELIM & _
"name" & S_DFLTDELIM & _
"connect"
Print #fl, "; Query sql"
Print #fl, "; ..."
Print #fl, "; " & S_ENDQUERY
Print #fl, ""

For Each tbl In db.QueryDefs
 Print #fl, S_QUERY & S_DFLTDELIM;
 Print #fl, tbl.name;
 Print #fl, S_DFLTDELIM;
 Print #fl, tbl.Connect
 
 Print #fl, tbl.sql;
 Print #fl, S_ENDQUERY
 Print #fl, ""
Next

End Sub

Private Sub listBase(lstFile As String)
Dim fl As Integer

fl = FreeFile
Open lstFile For Output As fl

Print #fl, "; Structure of " & db.name
Print #fl, "; Created " & Format$(Now, "dd.mm.yyyy hh:nn")

tablesList db, fl
attachList db, fl
queryList db, fl

Close fl
End Sub

Private Function getID(ByVal compID As String) As String
Static oldId As String
Dim id As String, d As String, dt As Date

 id = oldId
 While oldId = id
  dt = Now
  d = Format$(dt, "yymmddhhmmss")
  id = Mid(d, 1, 4) & _
       compID & _
       to32(Day(dt)) & _
       to32(Hour(dt)) & _
       Mid(d, 9)
 Wend
 oldId = id
 getID = id
End Function

Private Sub packBase()
Dim dbName As String, tmp As String

If dbFlag = False Then Exit Sub
tmp = "dbtemp.mdb"
dbName = db.name
db.Close
dbFlag = False

If fExist(tmp) Then Kill tmp

DBEngine.CompactDatabase dbName, tmp, dbLangCyrillic, dbVersion30
Kill dbName
FileCopy tmp, dbName
Kill tmp
openBase dbName
End Sub

Private Function openBase(dbName As String) As Boolean

If dbFlag Then
 db.Close
 dbFlag = False
End If

On Error GoTo openError
Set db = OpenDatabase(dbName)
On Error GoTo 0
dbFlag = True
openBase = True
Exit Function

openError:
cmdLog "Can't open " & dbName
openBase = False
End Function

Property Get logName() As String
logName = logFile
End Property

Property Let logName(l As String)
logFile = l
End Property

Public Function fExist(f As String) As Integer
If f = "" Or Dir$(f, 16) = "" Then
 fExist = False
 Else
 fExist = True
End If
End Function

Public Function to32(ByVal i As Integer) As String
If i < 10 Then
 i = i + Asc("0")
 Else
 i = i - 10 + Asc("A")
End If
to32 = Chr(i)
End Function
