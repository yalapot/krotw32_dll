VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDepthSpiral"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements clsDepth

Private d_depth As clsDepth
Private d_arr() As Long
Private d_x As Long
Private d_y As Long

Private Sub Class_Initialize()
Set d_depth = New clsDepth
End Sub

Private Property Get clsDepth_Amplitude() As Long
clsDepth_Amplitude = d_depth.Amplitude
End Property

Private Property Get clsDepth_dfktLen() As Long
clsDepth_dfktLen = d_depth.dfktLen
End Property

Private Property Set clsDepth_dfktSize(ByVal RHS As clsDefectSize)
Set d_depth.dfktSize = RHS
End Property

Private Property Get clsDepth_dfktSize() As clsDefectSize
Set clsDepth_dfktSize = d_depth.dfktSize
End Property

Private Property Let clsDepth_dltX(RHS As Long)
d_depth.dltY = RHS
End Property

Private Property Get clsDepth_dltX() As Long
clsDepth_dltX = d_depth.dltY
End Property

Private Property Let clsDepth_dltY(RHS As Single)
d_depth.dltX = RHS
End Property

Private Property Get clsDepth_dltY() As Single
clsDepth_dltY = d_depth.dltX
End Property

Private Property Get clsDepth_explain() As String
clsDepth_explain = d_depth.explain
End Property

Private Property Get clsDepth_h0() As Long
clsDepth_h0 = d_depth.h0
End Property

Private Property Let clsDepth_lastPrcntSlit(ByVal RHS As Long)
d_depth.lastPrcntSlit = RHS
End Property

Private Property Get clsDepth_lastPrcntSlit() As Long
clsDepth_lastPrcntSlit = d_depth.lastPrcntSlit
End Property

Private Property Get clsDepth_lineNumber() As Integer
clsDepth_lineNumber = d_depth.lineNumber
End Property

Private Property Set clsDepth_magnit(RHS As clsMagnit)
Set d_depth.magnit = RHS
End Property

Private Property Get clsDepth_magnit() As clsMagnit
Set clsDepth_magnit = d_depth.magnit
End Property

Private Property Get clsDepth_maxPos() As Long
clsDepth_maxPos = d_depth.maxPos
End Property

Private Property Let clsDepth_wallThick(RHS As Long)
d_depth.wallThick = RHS
End Property

Private Property Get clsDepth_wallThick() As Long
clsDepth_wallThick = d_depth.wallThick
End Property

Private Property Let clsDepth_sensMax(RHS As Long)
d_depth.sensMax = RHS
End Property

Private Property Get clsDepth_sensMax() As Long
clsDepth_sensMax = d_depth.sensMax
End Property

Private Property Let clsDepth_sensMin(RHS As Long)
d_depth.sensMin = RHS
End Property

Private Property Get clsDepth_sensMin() As Long
clsDepth_sensMin = d_depth.sensMin
End Property

Private Property Get clsDepth_minPos1() As Long
clsDepth_minPos1 = d_depth.widthTop * clsDepth_dltX
End Property

Private Property Get clsDepth_minPos2() As Long
clsDepth_minPos2 = d_depth.widthBottom * clsDepth_dltX
End Property

Private Property Get clsDepth_widthBottom() As Long
clsDepth_widthBottom = d_x - d_depth.minPos1 / d_depth.dltX
End Property

Private Property Get clsDepth_widthTop() As Long
clsDepth_widthTop = d_x - d_depth.minPos2 / d_depth.dltX
End Property

Private Function clsDepth_CalcDent(sensArray() As Long, ByVal xSize As Long, ByVal ysize As Long, ByVal h0 As Long, ByVal dfktLen As Long, ByVal yStart As Long, ByVal yEnd As Long, ByVal noWarn As Boolean) As Integer
ReDim d_arr(xSize * ysize) As Long
d_x = ysize
d_y = xSize
rotateMatrixClock xSize, ysize, sensArray, d_arr
clsDepth_CalcDent = d_depth.CalcDent(d_arr, ysize, xSize, h0, -1, 0, xSize - 1, noWarn)
End Function

Private Function clsDepth_Calculate( _
sensArray() As Long, _
ByVal xSize As Long, _
ByVal ysize As Long, _
ByVal h0 As Long, _
ByVal inside As Boolean, _
ByVal dfktLen As Long, _
ByVal yStart As Long, _
ByVal yEnd As Long, _
ByVal noWarn As Boolean, _
ByVal isTFI As Boolean, _
Optional sensType As KRT_SENS_TYPE = 0 _
) As Integer

ReDim d_arr(xSize * ysize) As Long
d_x = ysize
d_y = xSize
rotateMatrixClock xSize, ysize, sensArray, d_arr
clsDepth_Calculate = d_depth.Calculate(d_arr, ysize, xSize, h0, inside, -1, 0, xSize - 1, noWarn, isTFI)
End Function
