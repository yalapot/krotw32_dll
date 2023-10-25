VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsObjCommon"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_comment As String
Private d_dist As Long
Private d_len As Long
Private d_userDist As Long
Private d_userLen As Long
Private d_linkedDist As Variant
Private d_objTyp As New clsObjType

Public isAttention As Boolean
Public trc As clsTrace

Public Sub Init( _
trace As clsTrace, _
ByVal dst As Long, _
l As Long, _
cmnt As String, _
attention As Boolean, _
objTyp As clsObjType _
)
Set trc = trace
Me.comment = cmnt
Me.objDist = dst
Me.objLen = l
Me.isAttention = attention
d_linkedDist = Null
d_objTyp.Init objTyp.id, objTyp.name, objTyp.off, objTyp.tbl
End Sub

Public Function moveTo(ByVal dst As Long) As Boolean
Dim cmd() As String, olddist As Long

moveTo = False
olddist = Me.objDist

If trc.db.checkDist(dst) Then Exit Function 'уже есть обьект

trc.db.rsObj.Seek "=", olddist
If trc.db.rsObj.NoMatch Then Exit Function 'нет текущего обьекта в базе

Me.objDist = dst

With trc.db.rEdit
.Edit
.Change "dist", Me.objDist
.Change "userDist", Me.usrDist
.Change "editBy", trc.db.userName
.Change "editDate", Now()
.Update
End With

If Len(Me.objTyp.tbl) > 0 Then
 ReDim cmd(5) As String
 cmd(0) = "UPDATE " & Me.objTyp.tbl & " SET dist=" & Me.objDist & " WHERE dist=" & olddist
 trc.db.sqlUpdateTubLengthAtPoint Me.objDist, cmd, 1, 2
 trc.db.sqlUpdateTubLengthAtPoint olddist, cmd, 3, 4
 If SQLexe(trc.db.db, cmd) = False Then Exit Function
End If

moveTo = True
End Function

Property Get comment() As String
comment = d_comment
End Property

Property Let comment(c As String)
If Len(c) > CMNT_LENGTH Then c = Left(c, CMNT_LENGTH)
d_comment = c
End Property

Property Get objDist() As Long
objDist = d_dist
End Property

Property Let objDist(d As Long)
d_dist = d
d_userDist = trc.getDistKoef(d_dist)
End Property

Property Get usrDist() As Long
usrDist = d_userDist
End Property

Property Let usrDist(d As Long)
d_userDist = d
d_dist = trc.getDistReal(d_userDist)
End Property

Property Get linkedDist() As Variant
linkedDist = d_linkedDist
End Property

Public Sub link2dist(ByVal lnk_dist As Variant, usr_dist As Long, Optional ByVal set_editor As Boolean = True)
If IsNull(lnk_dist) Then
  d_userDist = trc.getDistKoef(d_dist)
Else
  d_userDist = usr_dist
End If

d_linkedDist = lnk_dist

trc.db.rsObj.Seek "=", d_dist
If trc.db.rsObj.NoMatch Then Exit Sub 'нет текущего обьекта в базе

With trc.db.rEdit
.Edit
.Change "linkedDist", Me.linkedDist
.Change "userDist", Me.usrDist
If set_editor = True Then
  .Change "editBy", trc.db.userName
  .Change "editDate", Now()
End If
.Update
End With

End Sub

Property Get objLen() As Long
objLen = d_len
End Property

Property Let objLen(d As Long)
d_len = d

Select Case Me.objTyp.id
 Case OBJ_TYPE.OBJ_prigruz
  d_userLen = d_len
 Case Else
  d_userLen = trc.getLenKoef(Me.objDist, d_len)
End Select
End Property

Property Get usrLen() As Long
usrLen = d_userLen
End Property

Property Let usrLen(d As Long)
d_userLen = d

Select Case Me.objTyp.id
 Case OBJ_TYPE.OBJ_prigruz
  d_len = d_userLen
 Case Else
  d_len = trc.getLenReal(Me.objDist, d_userLen)
End Select
End Property

Property Get objTyp() As clsObjType
Set objTyp = d_objTyp
End Property
