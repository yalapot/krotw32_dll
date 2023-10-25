Attribute VB_Name = "FloatNumber"
Option Explicit

Private Declare Function GetLocaleInfo Lib "kernel32" _
    Alias "GetLocaleInfoA" (ByVal lLocale As Long, _
        ByVal lLocaleType As Long, ByVal sLCData As String, _
        ByVal lBufferLength As Long) As Long


Public Function dblStr(ByVal numVal As Double, Optional ByVal decNum As Integer = -1) As String
Dim s As String, i As Long

If decNum >= 0 Then numVal = Int(numVal * (10# ^ decNum)) / (10 ^ decNum)

s = Trim$(str$(numVal))
If Asc(s) = Asc(".") Then s = "0" & s
If Mid(s, 1, 2) = "-." Then s = "-0." & Mid(s, 3)

i = InStrRev(s, ".")
If i = 0 Then
 If decNum > 0 Then s = s & "." & String(decNum, "0")
 Else
 i = decNum - Len(s) + i
 If i > 0 Then s = s & String(i, "0")
End If

dblStr = s
End Function

Public Function intDblStr(ByVal numVal As Long, Optional ByVal pointShift As Integer = 0, Optional ByVal decNum As Integer = 0) As String
Dim s As String, signCh As String, lstr As String, rstr As String, i As Long

s = Trim$(str$(numVal))

If Asc(s) = Asc("-") Then
 s = Mid(s, 2)
 signCh = "-"
 Else
 signCh = ""
End If

If pointShift < Len(s) Then
 lstr = Left(s, Len(s) - pointShift)
 rstr = Right(s, pointShift)
 Else
 lstr = "0"
 rstr = String(pointShift - Len(s), "0") & s
End If

If Len(rstr) > decNum Then
 rstr = Left(rstr, decNum)
 Else
 rstr = rstr & String(decNum - Len(rstr), "0")
End If

intDblStr = signCh & lstr & IIf(Len(rstr) > 0, "." & rstr, "")
End Function

Private Function GetLocaleString(ByVal lLocaleNum As Long) As String
'
' Generic routine to get the locale string from the Operating system.
'
    Dim lBuffSize As String
    Dim sBuffer As String
    Dim lRet As Long

    Const LOCALE_USER_DEFAULT As Long = &H400
'
' Create a string buffer large enough to hold the returned value, 256 should
' be more than enough
'
    lBuffSize = 256
    sBuffer = String$(lBuffSize, vbNullChar)
'
' Get the information from the registry
'
    lRet = GetLocaleInfo(LOCALE_USER_DEFAULT, lLocaleNum, sBuffer, lBuffSize)
'
' If lRet > 0 then success - lret is the size of the string returned
'
    If lRet > 0 Then
        GetLocaleString = Left$(sBuffer, lRet - 1)
    End If

End Function

Public Function DecimalDelim() As String
Const LOCALE_SDECIMAL As Long = &HE
DecimalDelim = GetLocaleString(LOCALE_SDECIMAL)
End Function

Public Function fix_delim(s As String) As String
If DecimalDelim() = "." Then
    fix_delim = Replace$(s, ",", ".")
Else
    fix_delim = Replace$(s, ".", ",")
End If

End Function

Public Function readDoubleFromString(ByVal txt As String) As Double
readDoubleFromString = CDbl(fix_delim(txt))
End Function
