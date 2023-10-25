VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsTimeMark"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_cp As Boolean
Private d_indx As Long
Private d_dist As Long
Private d_extTime As Long
Private d_intTime As Long
Private d_intTimeLeft As Long
Private d_intTimeRight As Long
Private d_intDistLeft As Long
Private d_intDistRight As Long
Private d_TimeDiff As Long
Private d_koeff As Double
Private d_last As Boolean

Public Function Init( _
ByVal tHandle As Long, _
ByVal mTime As Long, _
Optional ByVal mDist As Long = -1 _
) As Boolean

d_cp = IIf(mDist < 0, False, True)
d_extTime = mTime
d_dist = mDist

'установить первоначальные значения поправочных коеф-тов
d_TimeDiff = 0
d_koeff = 1
d_last = False

If d_cp Then
 If findIntTime(tHandle, d_dist) Then
  Init = True
 End If
Else
 Init = True
End If
End Function

Property Get cp() As Boolean
cp = d_cp
End Property

Property Get timeExt() As Long
timeExt = d_extTime
End Property

Property Get timeInt() As Long
timeInt = d_intTime
End Property

Property Get dist() As Long
dist = d_dist
End Property

Property Get timeLeft() As Long
timeLeft = d_intTime - d_intTimeLeft
End Property

Property Get timeRight() As Long
timeRight = d_intTimeRight - d_intTime
End Property

Property Get timeDiff() As Long
timeDiff = d_TimeDiff
End Property

Property Get koeff() As Double
koeff = d_koeff
End Property

'ищет бортовое время на отметке dst и возвращает True
'если не находит, возвращает False
Private Function findIntTime(ByVal tHandle As Long, ByVal dst As Long) As Boolean
Dim dat As T_NODEDATA
Dim d1 As Double, d2 As Double, d3 As Double, d4 As Double

findIntTime = False

If krotGetFirstNode(tHandle, dat, dst, SENS_TIMER, -1, 0, 0) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If

'если попали точно на узел, время точное и экстрополяция не нужна
If dat.prevPos = dst Then
 d_intTime = dat.sensVal
 d_intTimeLeft = d_intTime
 d_intTimeRight = d_intTime
 d_intDistLeft = 0
 d_intDistRight = 0
 findIntTime = True
 Exit Function
End If

'проверить, что возвращена дистанция ДО запрошенной
If dst < dat.prevPos Then
 ogdWin.Alert "Возвращена дистанция " & dat.prevPos & " > " & dst & " (запрошенная)"
 Exit Function
End If

'иначе найти левую и правую привязки времени

d_intTimeLeft = dat.sensVal
d_intDistLeft = dat.prevPos

If krotGetNextNode(tHandle, dat) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If

d_intTimeRight = dat.sensVal
d_intDistRight = dat.prevPos

'найти время на запрошенной дистанции экстраполяцией
d1 = d_intTimeRight - d_intTimeLeft
d2 = dst - d_intDistLeft
d3 = d_intDistRight - d_intDistLeft
d4 = d1 * d2 / d3
d_intTime = d4 + d_intTimeLeft

findIntTime = True
End Function

Property Get last() As Boolean
last = d_last
End Property

Property Let last(l As Boolean)
d_last = l
End Property

Public Function Link(nextTm As clsTimeMark) As Boolean
Dim extDiff As Double, intDiff As Double

extDiff = nextTm.timeExt - Me.timeExt
intDiff = nextTm.timeInt - Me.timeInt
d_TimeDiff = extDiff - intDiff
d_koeff = intDiff / extDiff
End Function

Public Function calcDist(ByVal trc As clsTrace, ByVal kf As Double, cp As clsTimeMark) As Boolean
Dim askDist As Long, askDistPrev As Long
Dim lDat As T_NODEDATA, rDat As T_NODEDATA, cDat As T_NODEDATA
Dim d1 As Double, d2 As Double, d3 As Double, d4 As Double

calcDist = False
If d_cp Then
 calcDist = True
 Exit Function
End If

If cp Is Nothing Then
 d_dist = 0
 calcDist = True
 Exit Function
End If

d_koeff = kf
d_intTime = (Me.timeExt - cp.timeExt) * d_koeff + cp.timeInt

'начальные узлы в начале и конце трассы
If krotGetFirstNode(trc.handle, lDat, 0, SENS_TIMER, -1, 0, 0) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If
If krotGetFirstNode(trc.handle, rDat, trc.length, SENS_TIMER, -1, 0, 0) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If
cDat = rDat

askDist = 0
askDistPrev = -1
'найти ближайший узел слева
While (lDat.prevPos < cDat.prevPos) And (askDistPrev <> askDist)

 askDistPrev = askDist
 
 If cDat.sensVal < d_intTime Then
  lDat = cDat
  Else
  rDat = cDat
 End If

 'дистанция, на которой спрашивать
 askDist = (rDat.prevPos - lDat.prevPos) / 2 + lDat.prevPos
 If krotGetFirstNode(trc.handle, cDat, askDist, SENS_TIMER, -1, 0, 0) = KRT_ERR Then
  ogdWin.Alert lastError()
  Exit Function
 End If

Wend

rDat = lDat
'узел справа
If krotGetNextNode(trc.handle, rDat) = KRT_ERR Then
 ogdWin.Alert lastError()
 Exit Function
End If

d_intTimeLeft = lDat.sensVal
d_intTimeRight = rDat.sensVal

'определяем положение между двумя узлами пропорцией
d1 = rDat.prevPos - lDat.prevPos
d2 = d_intTime - lDat.sensVal
d3 = rDat.sensVal - lDat.sensVal

If d3 = 0 Then
 d4 = 0
 'ogdWin.Alert "Неверное время маркера: " & Me.timeExt & vbNewLine & _
 ' "Время контрольной точки: " & cp.timeExt
 'Exit Function
 Else
 d4 = d1 * d2 / d3
End If

d_dist = d4 + lDat.prevPos
calcDist = True
End Function

Property Get indx() As Long
indx = d_indx
End Property

Property Let indx(i As Long)
d_indx = i
End Property

