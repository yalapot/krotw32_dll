VERSION 5.00
Begin VB.Form frmOdoWheel 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Колеса одометра"
   ClientHeight    =   2055
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   5070
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2055
   ScaleWidth      =   5070
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtEnd 
      Height          =   285
      Left            =   3360
      TabIndex        =   9
      Text            =   "Text1"
      Top             =   960
      Width           =   1095
   End
   Begin VB.TextBox txtStart 
      Height          =   285
      Left            =   3360
      TabIndex        =   8
      Text            =   "Text1"
      Top             =   720
      Width           =   1095
   End
   Begin VB.TextBox txtNominal 
      Height          =   285
      Left            =   3360
      TabIndex        =   7
      Text            =   "Text1"
      Top             =   480
      Width           =   1095
   End
   Begin VB.CommandButton btmRun 
      Caption         =   "Сделать файл поправок"
      Height          =   375
      Left            =   600
      TabIndex        =   1
      Top             =   1560
      Width           =   2415
   End
   Begin VB.CommandButton btmCancel 
      Caption         =   "Выход"
      Height          =   375
      Left            =   3360
      TabIndex        =   0
      Top             =   1560
      Width           =   1215
   End
   Begin VB.Label labTraceLength 
      Caption         =   "Label2"
      Height          =   255
      Left            =   3360
      TabIndex        =   6
      Top             =   120
      Width           =   1575
   End
   Begin VB.Label Label1 
      Caption         =   "Диаметр колеса после пуска, мм"
      Height          =   255
      Index           =   3
      Left            =   120
      TabIndex        =   5
      Top             =   960
      Width           =   3015
   End
   Begin VB.Label Label1 
      Caption         =   "Диаметр колеса до пуска, мм"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   4
      Top             =   720
      Width           =   3015
   End
   Begin VB.Label Label1 
      Caption         =   "Расчетный диаметр колеса, мм"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   3
      Top             =   480
      Width           =   3015
   End
   Begin VB.Label Label1 
      Caption         =   "Длина трассы, м"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   3015
   End
End
Attribute VB_Name = "frmOdoWheel"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private trc As clsTrace

Public Sub Edit(prnt As frmMain, trace As clsTrace)
Set trc = trace

labTraceLength.Caption = trc.length / 1000
txtNominal.Text = DFLT_ODO_DIAM / 100#
txtStart.Text = trc.odoDiam1 / 100#
txtEnd.Text = trc.odoDiam2 / 100#

Me.Show 1, prnt
End Sub

Private Sub btmCancel_Click()
Unload Me
End Sub

Private Function GetFileName() As String
Dim dlg As New clsCommonDialog
dlg.CancelError = False
dlg.Flags = cdlOFNExplorer + cdlOFNHideReadOnly + cdlOFNLongNames + cdlOFNOverwritePrompt + cdlOFNPathMustExist
dlg.DefaultExt = ".csv"
dlg.DialogTitle = "Выберите файл для таблицы поправок"
dlg.filter = "excel (*.csv)|*.csv"
dlg.ShowSave
GetFileName = dlg.FileName
Set dlg = Nothing
End Function

Private Sub btmRun_Click()
Dim sFileName As String, lFileHandle As Long, dlt As Integer, i As Integer
Dim node_odo As Long, segment_length As Long, node_koef As Long, prev_dist As Long, segment As Double

trc.odoDiam1 = Int(val(txtStart.Text) * 100)
trc.odoDiam2 = Int(val(txtEnd.Text) * 100)
trc.odoDiam = Int(val(txtNominal.Text) * 100)

dlt = trc.odoDiam1 - trc.odoDiam2
If dlt <= 0 Then
  ogdWin.Alert "Износа колеса не было, таблица поправок не нужна."
  Exit Sub
End If

sFileName = GetFileName()
If sFileName = "" Then Exit Sub

lFileHandle = FreeFile
Open sFileName For Output As lFileHandle

i = 1
prev_dist = 0
segment = trc.length / dlt

setWait "Запись..."
Print #lFileHandle, "Mode " & trc.distMode & "; Start " & trc.odoStart & "; OdoKoef " & trc.odoKoef

While i <= dlt
  node_odo = segment * i
  segment_length = CLng(segment * (trc.odoDiam1 - i) / trc.odoDiam)
  node_koef = prev_dist + segment_length
  Print #lFileHandle, node_odo & " , " & node_koef
  prev_dist = node_koef
  i = i + 1
Wend
Close lFileHandle
setReady

Unload Me
End Sub

