VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Enum T_ErrCode
 ALL_OK
 ERR_FIRST
 ERR_NEXT
End Enum

Private errCode As T_ErrCode
Private errCodeText As String

Private d_type As KRT_SENS
Private trc As clsTrace

Private dataStart As Long
Private dataLength As Long
Private dataLengthMax As Long
Private dataArray() As T_NODEDATA
Private dataNodes As Long
Private dataMin As Long
Private dataMax As Long

Private d_markW As Long
Private d_markB As Long
Private d_markWpos As Long
Private d_markBpos As Long

Public Index As Integer
Public visible As Boolean

Property Get errText() As String
Select Case errCode
 Case ALL_OK
  errText = "Все в порядке"
 Case ERR_FIRST
  errText = "Ошибка при вызове krotGetFirstNode:" & vbNewLine & errCodeText
 Case ERR_NEXT
  errText = "Ошибка при вызове krotGetNextNode:" & vbNewLine & errCodeText

 Case Else
  errText = "Ошибка с кодом " & errCode
End Select
End Property

Public Sub Init( _
trace As clsTrace, _
ByVal typ As KRT_SENS, _
ByVal indx As Integer _
)
Set trc = trace
Index = indx
d_type = typ
dataStart = -1
dataLengthMax = -1
dataNodes = 0
d_markWpos = -1
d_markBpos = -1
End Sub

Property Get typ() As KRT_SENS
typ = d_type
End Property

Property Get Caption() As String
Caption = "" & IIf(Me.Index < 1, "Базовый", "" & Me.Index)
End Property

Property Get minPageVal() As Long
If updateDataIfNeed() Then
 minPageVal = dataMin
 Else
 minPageVal = -1
End If
End Property

Property Get maxPageVal() As Long
If updateDataIfNeed() Then
 maxPageVal = dataMax
 Else
 maxPageVal = -1
End If
End Property

Public Function getVal(ByVal x As Long) As Long
Dim dat As T_NODEDATA

getVal = -1

If krotGetFirstNode( _
 trc.handle, _
 dat, _
 x, _
 Me.typ, _
 Me.Index - 1, _
 0, _
 0 _
 ) = KRT_ERR Then
 errCodeText = lastError()
 errCode = ERR_FIRST
 Exit Function
End If

getVal = dat.sensVal
End Function

Private Function fillArray() As Boolean
Dim dat As T_NODEDATA, dataEnd As Long, lastPos As Long

fillArray = False

If krotGetFirstNode( _
 trc.handle, _
 dat, _
 dataStart, _
 Me.typ, _
 Me.Index - 1, _
 dataLength, _
 dataLength _
 ) = KRT_ERR Then
 errCodeText = lastError()
 errCode = ERR_FIRST
 Exit Function
End If

dataMin = dat.sensVal
dataMax = dat.sensVal
dataEnd = dataStart + dataLength
dataNodes = 0

Do While dat.prevPos < dataEnd

 dataArray(dataNodes) = dat
 lastPos = dat.prevPos
 If dat.sensVal < dataMin Then dataMin = dat.sensVal
 If dat.sensVal > dataMax Then dataMax = dat.sensVal

 If krotGetNextNode(trc.handle, dat) = KRT_ERR Then
  errCodeText = lastError()
  errCode = ERR_NEXT
  Exit Function
 End If

 If lastPos = dat.prevPos Then
  Exit Do
  Else
  dataNodes = dataNodes + 1
 End If

Loop
fillArray = True
End Function

Public Sub ClearData()
dataStart = -1
End Sub

Private Function updateDataIfNeed(Optional forceRead As Boolean = False) As Boolean
updateDataIfNeed = True

If dataLength <> trc.pageLength Then
 dataLength = trc.pageLength
 ClearData
End If

If dataLengthMax < dataLength Then
 dataLengthMax = dataLength
 'предполагается, что шага показаний меньше миллиметра нету и буфер для данных выделяется с избытком
 ReDim dataArray(dataLengthMax) As T_NODEDATA
 ClearData
End If

If forceRead Or (dataStart <> trc.pageStart) Then
 dataStart = trc.pageStart
 updateDataIfNeed = fillArray()
End If

End Function

Public Sub drawNode( _
pic As PictureBox, _
ByVal x1 As Long, _
ByVal y1 As Long, _
ByVal x2 As Long, _
ByVal y2 As Long, _
ByVal reverse As Boolean, _
ByVal diskret As Boolean, _
ByVal cycledLevel As Long, _
ByVal lineColor As Long _
)
Dim yShift As Long

yShift = IIf(reverse, 0, pic.ScaleHeight)

If cycledLevel > 0 Then
 If Abs(y2 - y1) > cycledLevel Then
   Exit Sub
 End If
End If

'Dim lFileHandle As Long
'lFileHandle = FreeFile
'Open "E:\Temp\krot.txt" For Append As lFileHandle
'Print #lFileHandle, CStr(x1), "; ", CStr(y1), "; ", CStr(x2), "; ", CStr(y2), "; ", CStr(yShift)
'Close lFileHandle

If diskret Then
 pic.Line (x1, y1 + yShift)-(x2, y1 + yShift), lineColor
 pic.Line (x2, y1 + yShift)-(x2, y2 + yShift), lineColor
 Else
 pic.Line (x1, y1 + yShift)-(x2, y2 + yShift), lineColor
End If
End Sub

Public Function Draw( _
pic As PictureBox, _
ByVal lineColor As Long, _
ByVal diskret As Boolean, _
ByVal cycledLevel As Long, _
ByVal reverse As Boolean, _
Optional forceRead As Boolean = False _
) As Boolean

Dim i As Long, x1 As Long, y1 As Long, x2 As Long, y2 As Long
Dim dat As T_NODEDATA

If updateDataIfNeed(forceRead) = False Then Exit Function

' переключаем дистанции области отрисовки на относительные,
' чтобы исключить искажения в последних знаках значения с плавающей точкой
' при больших дистанциях отрисовываемых значений
Dim saveScaleLeft As Double
saveScaleLeft = pic.ScaleLeft
pic.ScaleLeft = 0

dat = dataArray(0)
x1 = dat.prevPos - saveScaleLeft
y1 = dat.sensVal

For i = 1 To dataNodes - 1
 dat = dataArray(i)
 x2 = dat.prevPos - saveScaleLeft
 y2 = dat.sensVal
 drawNode pic, x1, y1, x2, y2, reverse, diskret, cycledLevel, lineColor
 x1 = x2
 y1 = y2
Next

' восстанавливаем координаты области отрисовки
pic.ScaleLeft = saveScaleLeft
End Function

Property Get markW() As Long
If d_markWpos <> trc.mark.white Then
 d_markW = Me.getVal(trc.mark.white)
 d_markWpos = trc.mark.white
End If
markW = d_markW
End Property

Property Get markB() As Long
If d_markBpos <> trc.mark.black Then
 d_markB = Me.getVal(trc.mark.black)
 d_markBpos = trc.mark.black
End If
markB = d_markB
End Property
