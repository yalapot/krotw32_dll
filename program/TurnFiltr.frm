Attribute VB_Name = "frmTurnFiltr"
Option Explicit
Private ret As Boolean
Private objLst As Collection
Private tFlt As clsTurnFiltr
Private frm As frmTrace
Private curMode As T_TURNFILTR
Private hlp As New clsHelp

Public Function Edit(prnt As frmTrace, tFilter As clsTurnFiltr) As Boolean
Dim c As clsObjType
Dim i As T_TURN_TYPE
Load Me
hlp.BindHelp Me, KRT_ObjTubeLength

ret = False
Set frm = prnt
Set tFlt = tFilter

    For i = 0 To 6
        lstObj.addItem TurnTypeName(i)
        lstObj.ItemData(lstObj.NewIndex) = i
        lstObj.Selected(lstObj.NewIndex) = tFlt.selectType(i)
    Next

centerForm frmMain, Me
setControls
Me.Show 1, frmMain
Edit = ret
End Function

Private Function getIndex(s As String) As Integer
Dim i As Integer

For i = 0 To lstOper.ListCount
 If lstOper.List(i) = s Then
  getIndex = i
  Exit Function
 End If
Next
'ogdWin.Alert "Unknoun operation " & s
getIndex = 0
End Function
Private Sub setControls()
    lstOper.ListIndex = getIndex(tFlt.turnCompare)
    optMode(tFlt.mode).Value = True
End Sub

Private Sub getControls()
    tFlt.turnLen = val(txtLen.Text) * 1000
    tFlt.turnAngle3D = val(txtLen.Text)
    tFlt.tubeRad3D = val(txtLen.Text)
    tFlt.turnCompare = lstOper.List(lstOper.ListIndex)
    tFlt.mode = curMode
End Sub

Private Sub btmAct_Click(index As Integer)
Select Case index
 Case 0 'да
  getControls
  ret = True
    readList    'список объектов
End Select
Unload Me
End Sub

Private Sub btmSet_Click(index As Integer)
Dim i As Integer

Select Case index
 
 Case 0
 setList True
 
 Case 1
 setList False
 
End Select
End Sub

Private Sub readList()
Dim i As Integer, s As String
    For i = 0 To lstObj.ListCount - 1
        If lstObj.Selected(i) Then
            tFlt.onSelectType = i
            'If s <> "" Then s = s & ","
            's = s & CStr(i)
        Else
            If s <> "" Then s = s & ","
            s = s & CStr(i)
            tFlt.offSelectType = i
        End If
    Next i
tFlt.turnLstType = s
End Sub


Private Sub setList(ByVal selStat As Boolean)
Dim i As Integer

For i = 0 To lstObj.ListCount - 1
 lstObj.Selected(i) = selStat
Next
End Sub

Private Sub optMode_Click(index As Integer)
curMode = index
frameLength.visible = False
Select Case curMode
    Case TURNF_CURVE
        frameLength.Caption = "Показывать отводы c радиусом"
        labEdIzm.Caption = "D"
        txtLen.Text = tFlt.turnRad3D
        frameLength.visible = True
    Case TURNF_ANGLE
        frameLength.Caption = "Показывать отводы с уголом"
        labEdIzm.Caption = Chr(176) '"град."
        txtLen.Text = tFlt.turnAngle3D
        frameLength.visible = True
    Case TURNF_LENGTH
        frameLength.Caption = "Показывать отводы с длинной"
        labEdIzm.Caption = "м."
        txtLen.Text = mm2txt(tFlt.turnLen)
        frameLength.visible = True
    Case TURNF_OFF
        frameLength.visible = False
End Select
End Sub
