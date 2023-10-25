Attribute VB_Name = "onLine"
Option Explicit

Public onLineCurrentDist As Long
Public onLineTraceHwnd As Long
Public onLineData As T_ARRIVED_DATA

Public Function newDataCallBack(newData As T_ARRIVED_DATA) As Long
newDataCallBack = 0
If onLineTraceHwnd = -1 Then Exit Function

If onLineData.d_start = -1 Then
 onLineData.d_start = newData.d_start * 10
 onLineData.d_length = newData.d_length * 10
 Else
 onLineData.d_length = onLineData.d_length + newData.d_length
End If
SendMessage onLineTraceHwnd, WM_LBUTTONDBLCLK, 0, 0
newDataCallBack = 1
End Function
