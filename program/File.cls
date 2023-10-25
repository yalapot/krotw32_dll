VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const GENERIC_READ = &H80000000
Private Const GENERIC_WRITE = &H40000000
Private Const CREATE_ALWAYS = 2
Private Const FILE_ATTRIBUTE_NORMAL = &H80
Private Const INVALID_HANDLE_VALUE = -1

Private Declare Function CreateFile Lib "kernel32" Alias "CreateFileA" ( _
 ByVal lpFileName As String, _
 ByVal dwDesiredAccess As Long, _
 ByVal dwShareMode As Long, _
 ByVal lpSecurityAttributes As Long, _
 ByVal dwCreationDisposition As Long, _
 ByVal dwFlagsAndAttributes As Long, _
 ByVal hTemplateFile As Long _
) As Long

Private Declare Function GetLastError Lib "kernel32" () As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long

Private Enum T_ErrCode
 ALL_OK
 CREATE_FILE
End Enum

Private errCode As T_ErrCode
Private errCodeText As String
Private d_drive As String

Public path As String
Public name As String
Public ext As String

Property Get drive() As String
drive = d_drive
End Property

Property Let drive(d As String)
d_drive = d
End Property

Property Get basePath() As String
Dim f As String

If Me.isUNC Then
 f = "\\" & d_drive & "\"
 Else
 If Len(d_drive) > 0 Then
  f = d_drive & ":\"
  Else
  f = ""
 End If
End If

f = f & path
If Len(path) > 0 Then
 f = f & "\"
End If
basePath = f
End Property

Property Get dropExt() As String
dropExt = Me.basePath & name
End Property

Property Get lastFolder() As String
Dim i As Long

i = InStrRev(path, "\")
If i > 0 Then
 lastFolder = Right(path, Len(path) - i)
 Else
 lastFolder = path
End If
End Property

Property Get fullName() As String
fullName = Me.dropExt & IIf(Len(ext) > 0, "." & ext, "")
End Property

Property Get nameExt() As String
nameExt = name & IIf(Len(ext) > 0, "." & ext, "")
End Property

Property Let fullName(ByVal f As String)
Dim i As Long

i = InStrRev(f, ".")
If i > 0 Then
 ext = Right(f, Len(f) - i)
 f = Left(f, i - 1)
 Else
 ext = ""
End If

i = InStrRev(f, "\")
If i > 0 Then
 name = Right(f, Len(f) - i)
 f = Left(f, i - 1)
 Else
 name = f
 f = ""
End If

If Left(f, 2) = "\\" Then

 f = Right(f, Len(f) - 2)
 i = InStr(f, "\")
 i = InStr(i + 1, f, "\")
 If i > 0 Then
  d_drive = Left(f, i - 1)
  f = Right(f, Len(f) - i)
  Else
  d_drive = f
  f = ""
 End If
 
 Else
 
 If Mid(f, 2, 1) = ":" Then
  d_drive = Left(f, 1)
  f = Right(f, Len(f) - 2)
  Else
  d_drive = ""
 End If
 
End If

If Left(f, 1) = "\" Then
 f = Right(f, Len(f) - 1)
End If

path = f

End Property

Property Get isUNC() As Boolean
isUNC = Len(d_drive) > 1
End Property

Property Get errText() As String
Select Case errCode
 Case ALL_OK
  errText = "Все в порядке"
 Case CREATE_FILE
  errText = "CreateFile error code: " & errCodeText

 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property

Public Function CopyTo(dst As String) As Boolean
Dim hnd As Long

CopyTo = False
errCode = ALL_OK

hnd = CreateFile(dst, GENERIC_READ And GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
If hnd = INVALID_HANDLE_VALUE Then
 errCode = CREATE_FILE
 errCodeText = "" & GetLastError()
 Exit Function
End If
CloseHandle hnd

CopyTo = True
End Function

Property Get isPathContainLeadingSpace() As Boolean
isPathContainLeadingSpace = (InStr(1, Me.fullName, "\ ") > 0)
End Property
