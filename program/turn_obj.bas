Attribute VB_Name = "turn_obj"
Option Explicit

Public Enum T_TURN_TYPE
 NonTech = 0
 Tech = 1
 Defekt = 2
 Holod_gnut = 3
 Krutoizogn = 4
 Segmentny = 5
 Uprugo_plast = 6
End Enum

Public Function translateKrtTurnType2Tr(ByVal typ As T_TURN_TYPE) As EN_TR_POVOROT_TYPE
Select Case typ

 Case T_TURN_TYPE.NonTech
  translateKrtTurnType2Tr = EN_TR_POVOROT_TYPE.PT_NON_TECH
 
 Case T_TURN_TYPE.Tech
  translateKrtTurnType2Tr = EN_TR_POVOROT_TYPE.PT_TECH
 
 Case T_TURN_TYPE.Defekt
  translateKrtTurnType2Tr = EN_TR_POVOROT_TYPE.PT_DEFEKT

 Case T_TURN_TYPE.Holod_gnut
  translateKrtTurnType2Tr = EN_TR_POVOROT_TYPE.PT_HOLOD

 Case T_TURN_TYPE.Krutoizogn
  translateKrtTurnType2Tr = EN_TR_POVOROT_TYPE.PT_KRUTO

 Case T_TURN_TYPE.Segmentny
  translateKrtTurnType2Tr = EN_TR_POVOROT_TYPE.PT_SEGM

 Case T_TURN_TYPE.Uprugo_plast
  translateKrtTurnType2Tr = EN_TR_POVOROT_TYPE.PT_UPRUGO

End Select
End Function

Public Function TurnTypeName(ByVal typ As T_TURN_TYPE) As String
Select Case typ

 Case T_TURN_TYPE.NonTech
  TurnTypeName = "Нетехнологический"
 
 Case T_TURN_TYPE.Tech
  TurnTypeName = "Технологический"
 
 Case T_TURN_TYPE.Defekt
  TurnTypeName = "Дефект геометрии"

 Case T_TURN_TYPE.Holod_gnut
  TurnTypeName = "Отвод холодного гнутья"

 Case T_TURN_TYPE.Krutoizogn
  TurnTypeName = "Отвод крутоизогнутый"

 Case T_TURN_TYPE.Segmentny
  TurnTypeName = "Отвод сегментный"

 Case T_TURN_TYPE.Uprugo_plast
  TurnTypeName = "Упруго-пластический изгиб"

End Select
End Function

Public Function angle_label(ByVal radius As Long, ByVal tube_diam As Long, Optional d_only As Boolean = False) As String
Dim r As Double

r = radius / tube_diam

On Error GoTo ErrLabel
If d_only Then
   If r > 1000 Then
     angle_label = ""
   Else
     angle_label = dblStr(r, 1)
   End If
Else
   angle_label = dblStr((radius / 1000), 2) & " (" & dblStr(r, 2) & " D)"
End If
Exit Function

ErrLabel:
If Err.Number = 6 Then
  angle_label = "n/a"
End If
End Function

Public Function ArcCos(ByVal x As Double) As Double
    Select Case x
        Case -1
            ArcCos = 4 * Atn(1)
             
        Case 0:
            ArcCos = 2 * Atn(1)
             
        Case 1:
            ArcCos = 0
             
        Case Else:
            ArcCos = Atn(-x / Sqr(-x * x + 1)) + 2 * Atn(1)
    End Select
End Function

Public Function calck_angle_common(ByVal angleXY As Double, ByVal angleZ As Double) As Double
'Debug.Print "angleZ: " & angleZ
'Debug.Print "Cos angleZ: " & Cos(angleZ)
'Debug.Print "angleXY: " & angleXY
'Debug.Print "Cos angleXY: " & Cos(angleXY)
'Debug.Print "cos * cos : " & Cos(angleXY) * Cos(angleZ)
'Debug.Print "ArcCos: " & ArcCos(Cos(angleZ) * Cos(angleXY))
calck_angle_common = ArcCos(Cos(angleZ) * Cos(angleXY))
End Function
