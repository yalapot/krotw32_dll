VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensorGraph"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements clsSensor

'размер прицела для захвата линии для D&D в пикселах
Private Const DRAG_APERTURE = 2

Private Const GRPH_MIN = "Min"
Private Const GRPH_MAX = "Max"
Private Const GRPH_SIZE = "Size"
Private Const GRPH_AUTO = "AutoBorders"
Private Const GRPH_DISKRET = "DiskretGraph"
Private Const GRPH_RVRS = "Reverse"
Private Const GRPH_RUL1VAL = "Ruler1Value"
Private Const GRPH_RUL1CLR = "Ruler1Color"
Private Const GRPH_RUL1ENB = "Ruler1Enable"
Private Const GRPH_RUL2VAL = "Ruler2Value"
Private Const GRPH_RUL2CLR = "Ruler2Color"
Private Const GRPH_RUL2ENB = "Ruler2Enable"

Private trc As clsTrace
Private iniKey As String

Private d_autoBrd As Boolean
Private sens As clsSensor
Private notCalcAutoBordersFlag As Boolean

Public rul1val As Double
Public rul1clr As Long
Public rul2val As Double
Public rul2clr As Long
Public rul1enb As Boolean
Public rul2enb As Boolean

Public brdMin As Double
Public brdMax As Double
Public hKoef As Integer
Public diskret As Boolean
Public reverse As Boolean
Public cycledLevel As Long
Public isVOG As Boolean

Public Sub ClearData()
clsSensor_ClearData
End Sub

Private Sub Class_Initialize()
Set sens = New clsSensor
End Sub

Public Sub Init( _
trace As clsTrace, _
ByVal typ As KRT_SENS, _
ByVal iniKeyName As String, _
ByVal nam As String, _
ByVal num As Long, _
ByVal vMin As Long, _
ByVal vMax As Long, _
ByVal cycled As Boolean, _
Optional ByVal notCalcAutoBorders As Boolean = False _
)

Set trc = trace
notCalcAutoBordersFlag = notCalcAutoBorders
cycledLevel = IIf(cycled, (vMax - vMin) * 0.9, 0)
iniKey = iniKeyName
sens.Init trace, typ, iniKey, nam, num, vMin, vMax
brdMin = trc.getUser(iniKey & GRPH_MIN, sens.valMin)
brdMax = trc.getUser(iniKey & GRPH_MAX, sens.valMax)
hKoef = trc.getUser(iniKey & GRPH_SIZE, "0")
diskret = trc.getUserBool(iniKey & GRPH_DISKRET, False)
reverse = trc.getUserBool(iniKey & GRPH_RVRS, False)
Me.autoBrd = trc.getUserBool(iniKey & GRPH_AUTO, False)

rul1val = trc.getUser(iniKey & GRPH_RUL1VAL, sens.valMin)
rul1clr = trc.getUser(iniKey & GRPH_RUL1CLR, &H8000000E)
rul2val = trc.getUser(iniKey & GRPH_RUL2VAL, sens.valMin)
rul2clr = trc.getUser(iniKey & GRPH_RUL2CLR, &H80000007)
rul1enb = trc.getUserBool(iniKey & GRPH_RUL1ENB, False)
rul2enb = trc.getUserBool(iniKey & GRPH_RUL2ENB, False)
End Sub

Public Sub setBordersEx( _
pic As PictureBox, _
ByVal valMin As Long, _
ByVal valMax As Long, _
ByVal brdMin As Long, _
ByVal brdMax As Long _
)
Dim brd As Single

If brdMin = valMin Then
 brd = pic.Height / Screen.twipsPerPixelY
 ' 1 - это 1 пиксель отступа чтобы рисовалась линия миним. показаний
 brd = 1 * (brdMax - brdMin) / brd
 Else
 brd = 0
End If
pic.ScaleTop = brdMin - brd

brd = brdMin - brdMax - brd
If brd = 0 Then brd = 1
pic.ScaleHeight = IIf(Me.reverse, -brd, brd)
End Sub

Public Sub setBorders(pic As PictureBox)
If Me.autoBrd Then
 Me.brdMin = sens.minPageVal
 Me.brdMax = sens.maxPageVal
End If
setBordersEx pic, sens.valMin, sens.valMax, Me.brdMin, Me.brdMax
End Sub

Public Sub drawMarks(p As PictureBox)
drawMark p, trc.mark.white, True
drawMark p, trc.mark.black, False

If Me.isVOG Then
  Dim oldwidth As Long
  oldwidth = p.DrawWidth
  p.DrawWidth = cfg.vog.markWidth
  p.Line (trc.mark.white, p.ScaleTop)-(trc.mark.black, p.ScaleTop), cfg.vog.markColor
  p.DrawWidth = oldwidth
End If
End Sub

Private Sub drawMark(p As PictureBox, ByVal dst As Long, ByVal white As Boolean)
If Not (dst < p.ScaleLeft Or dst > (p.ScaleLeft + p.ScaleWidth)) Then
 p.Line (dst, p.ScaleTop)-(dst, p.ScaleTop + p.ScaleHeight), IIf(white, color.markWhite, color.markBlack)
End If
End Sub

Public Sub drawRulers(p As PictureBox)
If rul1enb Then
  drawRuler p, rul1val, rul1clr
End If
If rul2enb Then
  drawRuler p, rul2val, rul2clr
End If
End Sub

Private Sub drawRuler(p As PictureBox, ByVal v As Double, ByVal color As Long)
Dim yShift As Long

yShift = IIf(Me.reverse, 0, p.ScaleHeight)
v = v + yShift
p.Line (p.ScaleLeft, v)-(p.ScaleLeft + p.ScaleWidth, v), color
End Sub

Public Function Draw(pic As PictureBox, Optional forceRead As Boolean = False) As Boolean
setBorders pic
Draw = sens.Draw(pic, Me.diskret, Me.cycledLevel, Me.reverse, forceRead)
Me.drawMarks pic
Me.drawRulers pic
End Function

Public Sub Save()
sens.Save
trc.setUser iniKey & GRPH_MIN, brdMin
trc.setUser iniKey & GRPH_MAX, brdMax
trc.setUser iniKey & GRPH_SIZE, hKoef
trc.setUserBool iniKey & GRPH_AUTO, autoBrd
trc.setUserBool iniKey & GRPH_DISKRET, diskret
trc.setUserBool iniKey & GRPH_RVRS, reverse

trc.setUser iniKey & GRPH_RUL1VAL, rul1val
trc.setUser iniKey & GRPH_RUL1CLR, rul1clr
trc.setUser iniKey & GRPH_RUL2VAL, rul2val
trc.setUser iniKey & GRPH_RUL2CLR, rul2clr
trc.setUserBool iniKey & GRPH_RUL1ENB, rul1enb
trc.setUserBool iniKey & GRPH_RUL2ENB, rul2enb
End Sub

Property Get autoBrd() As Boolean
autoBrd = d_autoBrd
End Property

Property Let autoBrd(a As Boolean)
d_autoBrd = a
If notCalcAutoBordersFlag Then Exit Property
If Me.autoBrd Then
 brdMin = sens.minPageVal
 brdMax = sens.maxPageVal
End If
End Property

Public Function getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
getVal = sens.getVal(x, lineIndex)
End Function

Property Get num() As Long
num = sens.num
End Property

Property Get visible() As Boolean
visible = sens.visible
End Property

Property Get typ() As KRT_SENS
typ = sens.typ
End Property

Property Get valMin() As Long
valMin = sens.valMin
End Property

Property Get valMax() As Long
valMax = sens.valMax
End Property

Public Sub offAll()
sens.offAll
End Sub

Property Get line(ByVal indx As Integer) As clsSensorLine
Set line = sens.line(indx)
End Property

Property Get name() As String
name = sens.name
End Property

Public Function dispVal(ByVal sensValue As Long) As String
dispVal = "" & sensValue
End Function

Public Function sensVal(ByVal dispVal As String) As Long
sensVal = Fix(Val(dispVal))
End Function

Public Function canDraw(pic As PictureBox) As Boolean
canDraw = sens.canDraw(pic)
End Function

Private Function clsSensor_canDraw(pic As PictureBox) As Boolean
clsSensor_canDraw = Me.canDraw(pic)
End Function

Private Sub clsSensor_ClearData()
sens.ClearData
End Sub

Private Function clsSensor_Draw(pic As PictureBox, ByVal diskret As Boolean, ByVal cycledLevel As Long, ByVal reverse As Boolean, Optional forceReadData As Boolean = False) As Boolean
Me.Draw pic, forceReadData
End Function

Private Function clsSensor_getVal(ByVal x As Long, Optional ByVal lineIndex As Integer = 0) As Long
clsSensor_getVal = Me.getVal(x, lineIndex)
End Function

Private Sub clsSensor_Init(trace As clsTrace, ByVal typ As KRT_SENS, ByVal iniKey As String, ByVal nam As String, ByVal num As Long, ByVal vMin As Long, ByVal vMax As Long)
Me.Init trace, typ, iniKey, nam, num, vMin, vMax, (Me.cycledLevel > 0)
End Sub

Private Property Get clsSensor_isCurrMarkWhite() As Boolean
clsSensor_isCurrMarkWhite = sens.isCurrMarkWhite
End Property

Private Property Get clsSensor_line(ByVal indx As Integer) As clsSensorLine
Set clsSensor_line = Me.line(indx)
End Property

Private Property Get clsSensor_markB(ByVal lineIndex As Long) As Long
clsSensor_markB = sens.markB(lineIndex)
End Property

Private Property Get clsSensor_markW(ByVal lineIndex As Long) As Long
clsSensor_markW = sens.markW(lineIndex)
End Property

Private Property Get clsSensor_maxPageVal() As Long
clsSensor_maxPageVal = sens.maxPageVal
End Property

Private Property Get clsSensor_minPageVal() As Long
clsSensor_minPageVal = sens.minPageVal
End Property

Private Property Get clsSensor_name() As String
clsSensor_name = Me.name
End Property

Private Property Get clsSensor_num() As Long
clsSensor_num = Me.num
End Property

Private Sub clsSensor_offAll()
Me.offAll
End Sub

Private Sub clsSensor_Save()
Me.Save
End Sub

Private Property Get clsSensor_typ() As KRT_SENS
clsSensor_typ = Me.typ
End Property

Private Property Get clsSensor_valMax() As Long
clsSensor_valMax = Me.valMax
End Property

Private Property Get clsSensor_valMin() As Long
clsSensor_valMin = Me.valMin
End Property

Private Property Get clsSensor_visible() As Boolean
clsSensor_visible = Me.visible
End Property

Public Function findMarker(pic As PictureBox, ByVal x As Single) As Integer
Dim unitInPix As Single, minVal As Long, maxVal As Long
Dim i As Integer, pos As Long
Dim picWidthInPixels  As Long
Dim tmpW As Single, tmpH As Single, tmpl As Single, tmpT As Single, tmpi As Integer

findMarker = 0

tmpT = pic.ScaleTop
tmpl = pic.ScaleLeft
tmpW = pic.ScaleWidth
tmpH = pic.ScaleHeight
tmpi = pic.ScaleMode

pic.ScaleMode = 3
picWidthInPixels = pic.ScaleWidth

pic.ScaleMode = tmpi
pic.ScaleTop = tmpT
pic.ScaleLeft = tmpl
pic.ScaleWidth = tmpW
pic.ScaleHeight = tmpH

unitInPix = pic.ScaleWidth / picWidthInPixels
minVal = x - unitInPix * DRAG_APERTURE
maxVal = x + unitInPix * DRAG_APERTURE

pos = trc.mark.white
If pos >= minVal And pos <= maxVal Then
 findMarker = 1
 Exit Function
End If

pos = trc.mark.black
If pos >= minVal And pos <= maxVal Then
 findMarker = 2
 Exit Function
End If
End Function

Property Get markB(ByVal lineIndex As Long) As Long
markB = clsSensor_markB(lineIndex)
End Property

Property Get markW(ByVal lineIndex As Long) As Long
markW = clsSensor_markW(lineIndex)
End Property

Property Get isCurrMarkWhite() As Boolean
isCurrMarkWhite = clsSensor_isCurrMarkWhite
End Property

Property Get TurnAngleTitle() As String
TurnAngleTitle = ""
End Property

Property Get TurnAngleValue() As String
TurnAngleValue = ""
End Property
