VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsCommandLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Type typStringParseTokens
  Key As String
  Value As String
End Type

Private m_strTestString As String
Private m_strDelim As String
Private m_intCount As Integer

Private maTokens() As typStringParseTokens

Public Property Get Count() As Integer
  ' Returns: Count of the number of key/value pairs found
  ' Source: Total VB SourceBook 6

  Count = m_intCount

End Property

Public Property Get Delim() As String
  ' Returns: current value of the Delim property
  ' Source: Total VB SourceBook 6
  Delim = m_strDelim

End Property

Public Property Let Delim(ByVal strValue As String)
  ' strValue: the character to use to delimit keys from values
  ' Source: Total VB SourceBook 6

  m_strDelim = strValue

End Property

Public Property Get Item(varIndex As Variant) As String
  ' Returns: if varIndex is numeric, use the index value.
  '          If it is a string, use the key value
  ' Source: Total VB SourceBook 6

  Dim intCounter As Integer

  On Error GoTo PROC_ERR

  ' If the user specifies a number, use it as an index to
  ' find the corresponding item
  If IsNumeric(varIndex) Then
    If varIndex > 0 And varIndex <= m_intCount Then
      Item = maTokens(varIndex).Value
    End If
  Else

    ' If the user specifies a non-numeric value, search the
    ' collection serially to find a match
    For intCounter = 1 To m_intCount
      If StrComp(maTokens(intCounter).Key, varIndex, vbTextCompare) = 0 Then
        Item = maTokens(intCounter).Value
        Exit For
      End If
    Next intCounter

  End If

PROC_EXIT:
  Exit Property

PROC_ERR:
  MsgBox "Error: " & Err.Number & ". " & Err.Description, , _
    "Item"
  Resume PROC_EXIT

End Property

Public Property Get Key(intIndex As Integer) As String
  ' Returns: the value of the key at the specified index
  '          value. For example if the value of intIndex
  '          is 0, the value of the first key is returned
  ' Source: Total VB SourceBook 6
  '
  Key = maTokens(intIndex).Key

End Property

Public Property Get TestString() As String
  ' Returns: current value of the TestString property
  ' Source: Total VB SourceBook 6

  TestString = m_strTestString

End Property

Public Property Let TestString(ByVal strValue As String)
  ' strValue: The command line or other string to test
  ' Source: Total VB SourceBook 6

  m_strTestString = strValue

End Property

Public Property Get Value(intIndex As Integer) As String
  ' Returns: the value at the specified index
  '          location. For example if intIndex
  '          is 0, the first value is returned
  ' Source: Total VB SourceBook 6

  Value = maTokens(intIndex).Value

End Property

Public Sub Parse()
  ' Comments  : Parses the current value of the TestString property
  ' Parameters: none
  ' Returns   : nothing
  ' Source    : Total VB SourceBook 6
  '
  Dim intCurPos As Integer
  Dim intPosFound As Integer
  Dim intNextPos As Integer
  Dim strItem As String
  Dim strTest As String
  Dim intDelimLen As Integer
  Dim fDone As Boolean

  On Error GoTo PROC_ERR

  ' if either the Delim property or the TestString property
  ' has not been set, do not continue
  If m_strDelim = "" Then
    GoTo PROC_EXIT
  End If

  If m_strTestString = "" Then
    GoTo PROC_EXIT
  End If

  ' prepare the token array
  Erase maTokens

  m_intCount = 0
  intCurPos = 1
  fDone = False

  ' iterate across the test string, breaking it out into key/value
  ' pairs based on the occurrence of the Delim character
  Do Until fDone

    strItem = ""

    ' find occurrence of delimiter in remaining portion of string
    intPosFound = _
      InStr(intCurPos, m_strTestString, m_strDelim, vbTextCompare)

    If intPosFound Then
      intCurPos = intPosFound
      intNextPos = _
        InStr(intCurPos + 1, m_strTestString, m_strDelim, vbTextCompare)

      ' test for another occurence of the delim
      If intNextPos Then
        strItem = Mid$(m_strTestString, intCurPos, intNextPos - intCurPos)
        intCurPos = intNextPos
      Else
        strItem = Mid$(m_strTestString, intCurPos)
        fDone = True
      End If

    Else
      ' no delimiter found in remainder of string
      fDone = True
    End If

    ' break the key/value string into parts and store in array
    If strItem <> "" Then
      m_intCount = m_intCount + 1

      ReDim Preserve maTokens(m_intCount)

      intDelimLen = Len(m_strDelim)
      intPosFound = InStr(intDelimLen + 1, strItem & m_strDelim, m_strDelim)
'      intPosFound = InStr(intDelimLen + 1, strItem & " ", " ")

      'get key portion
      strTest = _
        Trim$(Mid$(strItem, intDelimLen + 1, intPosFound - intDelimLen))
      maTokens(m_intCount).Key = strTest

      'get value portion. If missing repeat the key portion
      strTest = Trim$(Mid$(strItem, intPosFound + 1))
      If strTest = "" Then
        strTest = maTokens(m_intCount).Key
      End If

      maTokens(m_intCount).Value = strTest

    End If

  Loop

PROC_EXIT:
  Exit Sub

PROC_ERR:
  MsgBox "Error: " & Err.Number & ". " & Err.Description, , _
    "Parse"
  Resume PROC_EXIT

End Sub
