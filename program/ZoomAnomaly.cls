VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsZoomAnomaly"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public draw_x1 As Single
Public draw_x2 As Single
Public draw_y1 As Single
Public draw_y2 As Single

Public x1 As Integer
Public x2 As Integer
Public y1 As Integer
Public y2 As Integer
Public depth As Integer
Public dflt_type As Integer

Public Function isNear(rectangles As Collection) As Boolean
Dim rect As clsZoomAnomaly

isNear = False
If rectangles.count = 0 Then Exit Function

For Each rect In rectangles
  If Me.isIntercept(rect) Then
    isNear = True
    Exit Function
  End If
Next
End Function

Public Function isIntercept(r As clsZoomAnomaly) As Boolean
isIntercept = False

If Me.y1 > r.y2 Or Me.y2 < r.y1 Then Exit Function
If Me.x1 > r.x2 Or Me.x2 < r.x1 Then Exit Function
isIntercept = True
End Function

Public Function isIside(x As Single, y As Single) As Boolean
isIside = x > Me.draw_x1 And x < Me.draw_x2 And y > Me.draw_y1 And y < Me.draw_y2
End Function

