VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsTimer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private WithEvents d_timer As Timer
Attribute d_timer.VB_VarHelpID = -1
Private timeFlag As Boolean

Public Sub sleep(tm As Timer, ByVal miliseconds As Integer)
Set d_timer = tm
timeFlag = True
d_timer.Interval = miliseconds
d_timer.enabled = True
While timeFlag
 DoEvents
Wend
End Sub

Private Sub d_timer_Timer()
timeFlag = False
End Sub
