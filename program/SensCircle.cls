VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSensCircle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const C_IS_ON = "On"
Private Const C_MIN = "Min"
Private Const C_MAX = "Max"
Private Const C_AUTO = "AutoBorders"
Private Const C_DISKR = "Diskret"
Private Const C_MARKW = "MarkW"
Private Const C_MARKB = "MarkB"

Private trc As clsTrace
Private crz As clsCoroz
Private iniKey As String

Public visible As Boolean
Public autoBorders As Boolean
Public diskret As Boolean
Public mwEnable As Boolean
Public mbEnable As Boolean
Public brdMin As Long
Public brdMax As Long

Public Sub Init(trace As clsTrace, Coroz As clsCoroz, ByVal iniKeyName As String)
Set trc = trace
Set crz = Coroz
iniKey = iniKeyName
visible = trc.getUserBool(iniKey & C_IS_ON, False)
autoBorders = trc.getUserBool(iniKey & C_AUTO, False)
diskret = trc.getUserBool(iniKey & C_DISKR, False)
mwEnable = trc.getUserBool(iniKey & C_MARKW, False)
mbEnable = trc.getUserBool(iniKey & C_MARKB, False)

brdMin = trc.getUser(iniKey & C_MIN, crz.valMin)
brdMax = trc.getUser(iniKey & C_MAX, crz.valMax)
End Sub

Public Sub Save()
trc.setUserBool iniKey & C_IS_ON, visible
trc.setUserBool iniKey & C_AUTO, autoBorders
trc.setUserBool iniKey & C_DISKR, diskret
trc.setUserBool iniKey & C_MARKW, mwEnable
trc.setUserBool iniKey & C_MARKB, mbEnable

trc.setUser iniKey & C_MIN, brdMin
trc.setUser iniKey & C_MAX, brdMax
End Sub

Public Sub setMinMax(ByVal valMin As Long, ByVal valMax As Long)
brdMin = valMin
brdMax = valMax
End Sub

Property Get valMin() As Long
valMin = IIf(crz.isRow, crz.valMinRow, crz.valMin)
End Property

Property Get valMax() As Long
valMax = IIf(crz.isRow, crz.valMaxRow, crz.valMax)
End Property

Property Get markW(ByVal Index As Long) As Long
markW = crz.markW(Index)
End Property

Property Get markB(ByVal Index As Long) As Long
markB = crz.markB(Index)
End Property

Public Sub Draw(pic As PictureBox)
crz.DrawCircle pic
End Sub

Property Get corozZone() As clsCoroz
Set corozZone = crz
End Property
