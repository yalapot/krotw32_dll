VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensColors"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public markWhite As Long
Public markBlack As Long

Private Const MAX_COLORS = 9
Private colors(MAX_COLORS) As Long

Private Sub Class_Initialize()
colors(1) = &H0&
colors(2) = &HFF&
colors(3) = &H80FF&
colors(4) = &HFFFF&
colors(5) = &HFF00&
colors(6) = &HFFFF00
colors(7) = &HFF0000
colors(8) = &HFF00FF
colors(9) = &HFFFFFF

markWhite = &H8000000E
markBlack = &H80000007
End Sub

Public Function clrIndx(ByVal indx As Integer) As Long
indx = indx + 1
If (indx > 0) And (indx <= MAX_COLORS) Then
 clrIndx = colors(indx)
 Else
 clrIndx = colors(1)
End If
End Function

Property Get markWhiteText() As Long
markWhiteText = &H0&
End Property

Property Get markBlackText() As Long
markBlackText = &HFFFFFF
End Property

Property Get markWhiteBackColor() As Long
markWhiteBackColor = &HFFFFFF
End Property

Property Get markBlackBackColor() As Long
markBlackBackColor = &H0&
End Property

Property Get noData() As Long
noData = &H8000000F
End Property

Property Get noDataX() As Long
noDataX = &H808000
End Property

Property Get normalColor() As Long
normalColor = RGB(212, 208, 200) '&H8000000F
End Property
