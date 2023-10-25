VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsAnglUnit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private angl As Double
Private d_minute As Integer
Private d_hour As Integer

Property Get fullHour() As Double
fullHour = 6 * angl / PI
End Property

Property Let fullHour(h As Double)
angl = PI * h / 6
d_hour = Int(Me.fullHour)
d_minute = (Me.fullHour - Int(Me.fullHour)) * 60

If d_minute >= 60 Then
  d_minute = d_minute - 60
  d_hour = d_hour + 1
End If

If d_hour >= 12 Then
  d_hour = d_hour - 12
End If
End Property

Property Get degreeInt() As Integer
degreeInt = Fix(angl / PI * 180)
End Property

Property Let degreeInt(d As Integer)
Me.degree = Me.degree - Me.degreeInt + d
End Property

Property Get degreeMinute() As Integer
degreeMinute = Fix((Me.degree - Me.degreeInt) * 60)
End Property

Property Let degreeMinute(d As Integer)
Dim dd As Double
dd = d
Me.degree = Me.degreeInt + d / 60#
End Property

Property Get degree() As Double
degree = angl / PI * 180
End Property

Property Let degree(d As Double)
angl = d / 180# * PI
End Property

Property Get radian() As Double
radian = angl
End Property

Property Let radian(r As Double)
angl = r
End Property

Property Get dHour() As Integer
dHour = d_hour
End Property

Property Let dHour(h As Integer)
Dim m As Double

m = Me.fullHour - Int(Me.fullHour)
Me.fullHour = h + m
End Property

Property Get dMinute() As Integer
dMinute = d_minute
End Property

Property Let dMinute(m As Integer)
Dim md As Double

md = m
Me.fullHour = Int(Me.fullHour) + md / 60
End Property

Property Let fullMinute(m As Integer)
Dim md As Double

If m < 0 Then
  m = 12 * 60 + m
End If

If m > 12 * 60 Then
  m = m - 12 * 60
End If

md = m
Me.fullHour = md / 60
End Property
Property Get fullMinute() As Integer
fullMinute = Me.dHour * 60 + Me.dMinute
End Property


Property Get dStr() As String
Dim h As Integer, m As Integer

h = Me.dHour
m = Me.dMinute

If h = -1 Then
    dStr = ""
Else
    If m = 60 Then
      h = h + 1
      m = 0
    End If
    If h >= 12 Then h = h - 12
    dStr = "" & h & ":" & Format$(m, "00")
End If
End Property

Property Let dStr(s As String)
On Error Resume Next
Dim l As Long
If s = "" Then
    Me.fullMinute = -60
Else
    l = InStr(s, ":")
    If l > 0 Then
        Me.dHour = CInt(Left(s, l - 1)) Mod 12
        Me.dMinute = CInt(Right(s, Len(s) - l))
    Else
        Me.dHour = CInt(s) Mod 12
    End If
End If
End Property

