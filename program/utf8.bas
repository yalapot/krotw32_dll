Attribute VB_Name = "utf8"
Option Explicit

' http://stackoverflow.com/questions/29980993/how-to-decode-utf8-in-vb6
Private Const CP_UTF8 As Long = 65001 ' UTF-8 Code Page

'Sys call to convert multiple byte chars to a char
Private Declare Function MultiByteToWideChar Lib "kernel32" ( _
    ByVal CodePage As Long, _
    ByVal dwFlags As Long, _
    ByVal lpMultiByteStr As Long, _
    ByVal cchMultiByte As Long, _
    ByVal lpWideCharStr As Long, _
    ByVal cchWideChar As Long) As Long

'------------------------------------------------------------------
' NAME:         DecodeURI (PUBLIC)
' DESCRIPTION:  Decodes a UTF8 encoded string
' CALLED BY:    HandleNavigate
' PARAMETERS:
'  EncodedURL (I,REQ) - the UTF-8 encoded string to decode
' RETURNS:      the the decoded UTF-8 string
'------------------------------------------------------------------
Public Function DecodeUTF8(ByVal EncodedURI As String) As String
    Dim bANSI() As Byte
    Dim bUTF8() As Byte
    Dim lIndex As Long
    Dim lUTFIndex As Long

    If Len(EncodedURI) = 0 Then
        Exit Function
    End If

    EncodedURI = Replace$(EncodedURI, "+", " ")         ' In case encoding isn't used.
    bANSI = StrConv(EncodedURI, vbFromUnicode)          ' Convert from unicode text to ANSI values
    ReDim bUTF8(UBound(bANSI))                          ' Declare dynamic array, get length
    For lIndex = 0 To UBound(bANSI)                     ' from 0 to length of ANSI
        If bANSI(lIndex) = &H25 Then                    ' If we have ASCII 37, %, then
            bUTF8(lUTFIndex) = val("&H" & Mid$(EncodedURI, lIndex + 2, 2)) ' convert hex to ANSI
            lIndex = lIndex + 2                         ' this character was encoded into two bytes
        Else
            bUTF8(lUTFIndex) = bANSI(lIndex)            ' otherwise don't need to do anything special
        End If
        lUTFIndex = lUTFIndex + 1                       ' advance utf index
    Next
    DecodeUTF8 = FromUTF8(bUTF8, lUTFIndex)              ' convert to string
End Function

'------------------------------------------------------------------
' NAME:         FromUTF8 (Private)
' DESCRIPTION:  Use the system call MultiByteToWideChar to
'               get chars using more than one byte and return
'               return the whole string
' CALLED BY:    DecodeURI
' PARAMETERS:
'  UTF8 (I,REQ)   - the ID of the element to return
'  Length (I,REQ) - length of the string
' RETURNS:      the full raw data of this field
'------------------------------------------------------------------
Private Function FromUTF8(ByRef UTF8() As Byte, ByVal length As Long) As String
Dim lDataLength As Long

lDataLength = MultiByteToWideChar(CP_UTF8, 0, VarPtr(UTF8(0)), length, 0, 0) ' Get the length of the data.
FromUTF8 = String$(lDataLength, 0) ' Create array big enough
MultiByteToWideChar CP_UTF8, 0, VarPtr(UTF8(0)), length, StrPtr(FromUTF8), lDataLength
End Function
