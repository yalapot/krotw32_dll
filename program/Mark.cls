VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMark"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const MRK_WHITE = "mrkWhite"
Private Const MRK_BLACK = "mrkBlack"

Private trc As clsTrace

Public white As Long
Public black As Long
Public isCurrWhite As Boolean

Public Sub setPos(ByVal whiteMark As Long, ByVal blackMark As Long)
If whiteMark < 0 Then whiteMark = 0
If whiteMark > trc.length Then whiteMark = trc.length
If blackMark < 0 Then blackMark = 0
If blackMark > trc.length Then blackMark = trc.length

If blackMark > whiteMark Then
 white = whiteMark
 black = blackMark
 Else
 white = blackMark
 black = whiteMark
End If
End Sub

Public Sub Init(trace As clsTrace)
Set trc = trace
white = trc.getUser(MRK_WHITE, 0)
black = trc.getUser(MRK_BLACK, 0)
isCurrWhite = True
End Sub

Public Sub Save()
trc.setUser MRK_WHITE, white
trc.setUser MRK_BLACK, black
End Sub
