VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsRegion"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const HKEY_CLASSES_ROOT = &H80000000
Private Const HKEY_CURRENT_CONFIG = &H80000005
Private Const HKEY_CURRENT_USER = &H80000001
Private Const HKEY_DYN_DATA = &H80000006
Private Const HKEY_LOCAL_MACHINE = &H80000002
Private Const HKEY_PERFORMANCE_DATA = &H80000004
Private Const HKEY_USERS = &H80000003

Private Const READ_CONTROL = &H20000
Private Const STANDARD_RIGHTS_ALL = &H1F0000
Private Const STANDARD_RIGHTS_READ = (READ_CONTROL)
Private Const STANDARD_RIGHTS_EXECUTE = (READ_CONTROL)
Private Const STANDARD_RIGHTS_REQUIRED = &HF0000
Private Const STANDARD_RIGHTS_WRITE = (READ_CONTROL)

Private Const KEY_QUERY_VALUE = &H1
Private Const KEY_CREATE_LINK = &H20
Private Const KEY_CREATE_SUB_KEY = &H4
Private Const KEY_ENUMERATE_SUB_KEYS = &H8
Private Const KEY_EVENT = &H1     '  Event contains key event record
Private Const KEY_NOTIFY = &H10
Private Const KEY_SET_VALUE = &H2
Private Const SYNCHRONIZE = &H100000

Private Const KEY_ALL_ACCESS = ((STANDARD_RIGHTS_ALL Or KEY_QUERY_VALUE Or KEY_SET_VALUE Or KEY_CREATE_SUB_KEY Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY Or KEY_CREATE_LINK) And (Not SYNCHRONIZE))
Private Const KEY_READ = ((STANDARD_RIGHTS_READ Or KEY_QUERY_VALUE Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY) And (Not SYNCHRONIZE))
Private Const KEY_EXECUTE = ((KEY_READ) And (Not SYNCHRONIZE))
Private Const KEY_WRITE = ((STANDARD_RIGHTS_WRITE Or KEY_SET_VALUE Or KEY_CREATE_SUB_KEY) And (Not SYNCHRONIZE))

Private Const REG_SZ = 1
Private Const ERROR_SUCCESS = 0&

Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" ( _
ByVal hKey As Long, _
ByVal lpSubKey As String, _
ByVal ulOptions As Long, _
ByVal samDesired As Long, _
phkResult As Long _
) As Long

' Note that if you declare the lpData parameter as String,
' you must pass it By Value.
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" ( _
ByVal hKey As Long, _
ByVal lpValueName As String, _
ByVal lpReserved As Long, _
lpType As Long, _
ByVal lpData As String, _
lpcbData As Long _
) As Long

Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias "RegSetValueExA" ( _
ByVal hKey As Long, _
ByVal lpValueName As String, _
ByVal Reserved As Long, _
ByVal dwType As Long, _
ByVal lpData As String, _
ByVal cbData As Long _
) As Long

Private Declare Function RegCloseKey Lib "advapi32.dll" ( _
ByVal hKey As Long _
) As Long

Private Declare Function RegFlushKey Lib "advapi32.dll" ( _
ByVal hKey As Long _
) As Long

Private keyCode As Long
Private initFlag As Boolean
Private errCode As Long

Private Function getStringValue(key As String) As String
Dim buf As String, ret As Long, typ As Long

ret = 255
buf = String(ret, Asc(" "))
errCode = RegQueryValueEx(keyCode, key, 0, typ, buf, ret)
If errCode = ERROR_SUCCESS Then
 getStringValue = Left$(buf, InStr(buf, Chr(0)) - 1)
 Else
 getStringValue = ""
End If
End Function

Private Sub setStringValue(key As String, s As String)
RegSetValueEx keyCode, key, 0, REG_SZ, s, Len(s) + 1
RegFlushKey keyCode
End Sub

Property Get sDecimal() As String
sDecimal = getStringValue("sDecimal")
End Property

Property Let sDecimal(s As String)
setStringValue "sDecimal", s
End Property

Property Get sCurrency() As String
sCurrency = getStringValue("sMonDecimalSep")
End Property

Property Let sCurrency(s As String)
setStringValue "sMonDecimalSep", s
End Property

Private Sub Class_Initialize()

errCode = RegOpenKeyEx( _
HKEY_CURRENT_USER, _
"Control Panel\International", _
0, _
KEY_ALL_ACCESS, _
keyCode)

If errCode = ERROR_SUCCESS Then
 initFlag = True
 Else
 initFlag = False
End If
End Sub

Private Sub Class_Terminate()
If initFlag = True Then
 RegCloseKey keyCode
End If
End Sub
