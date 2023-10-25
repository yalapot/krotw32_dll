VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsCommonDialog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Description = "Class wrapper for Common Dialog use without an .OCX file"
Attribute VB_Ext_KEY = "SavedWithClassBuilder" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'*************
'Common Dialog Control Class - Visual Basic 5 Only
'Copyright Aimbie Software Concepts - 1997
'By Robert W. Rainwater
'*************

Option Explicit

'API function called by ChooseColor method
Private Declare Function ChooseColor Lib "Comdlg32.dll" _
  Alias "ChooseColorA" (pChoosecolor As ChooseColor) As Long

'API funtion called by ChooseFont mehtod
Private Declare Function CHOOSEFONT Lib "Comdlg32.dll" _
  Alias "ChooseFontA" (PChoosefont As CHOOSEFONT) As Long

'API funtion inside ShowHelp method
Private Declare Function WinHelp Lib "USER32" Alias "WinHelpA" _
  (ByVal hWnd As Long, ByVal lpHelpFile As String, _
  ByVal wCommand As Long, ByVal dwData As Long) As Long
  
Private Declare Function WinHelpStr Lib "USER32" Alias "WinHelpA" _
  (ByVal hWnd As Long, ByVal lpHelpFile As String, _
  ByVal wCommand As Long, ByVal dwData As String) As Long
  
'API function called by ShowOpen method
Private Declare Function GetOpenFileName Lib "Comdlg32.dll" _
  Alias "GetOpenFileNameA" (pOpenFilename As OpenFilename) _
  As Long
  
'API function called by ShowSave method
Private Declare Function GetSaveFileName Lib "Comdlg32.dll" _
  Alias "GetSaveFileNameA" (pOpenFilename As OpenFilename) _
  As Long

'API function called by ShowPrint Method
Private Declare Function PrintDlg Lib "Comdlg32.dll" _
  Alias "PrintDlgA" (pPrintdlg As PrintDlg) As Long

Private Declare Function GlobalLock Lib "kernel32" _
  (ByVal hMem As Long) As Long
Private Declare Function GlobalUnlock Lib "kernel32" _
  (ByVal hMem As Long) As Long
  
'API function to retrieve extended error information
Private Declare Function CommDlgExtendedError Lib "Comdlg32.dll" _
  () As Long
  
'API function to retrieve extended error information for WinHelp
Private Declare Function GetLastError Lib "kernel32" () As Long

Private Declare Sub CopyMemoryStr Lib "kernel32" Alias "RtlMoveMemory" ( _
  lpvDest As Any, ByVal lpvSource As String, ByVal cbCopy As Long)

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" ( _
  ByVal lpvDest As Any, ByVal lpvSource As Any, ByVal cbCopy As Long)
 
'Internal constants
Private Const cMaxFileSize = 256
Private Const cCancelDescription = "Cancel Pressed"
Private Const cUserCanceled = 0
Private Const cUserSelected = 1
Private Const cShowOpen = 1
Private Const cShowSave = 2
Private Const cShowColor = 3
Private Const cShowFont = 4
Private Const cShowPrinter = 5
Private Const cShowHelp = 6

'constants for LOGFONT
Private Const FW_BOLD = 700
 
'UDT for the ChooseColor function
Private Type ChooseColor
  lStructSize As Long
  hwndOwner As Long
  hInstance As Long
  rgbResult As Long
  lpCustColors As Long
  Flags As Long
  lCustData As Long
  lpfnHook As Long
  lpTemplateName As String
End Type

'UDT for the ChooseFont function
Private Type LOGFONT
        lfHeight As Long
        lfWidth As Long
        lfEscapement As Long
        lfOrientation As Long
        lfWeight As Long
        lfItalic As Byte
        lfUnderline As Byte
        lfStrikeOut As Byte
        lfCharSet As Byte
        lfOutPrecision As Byte
        lfClipPrecision As Byte
        lfQuality As Byte
        lfPitchAndFamily As Byte
        lfFaceName(0 To 31) As Byte
End Type

'UDT for the ChooseFont function
Private Type CHOOSEFONT
  lStructSize As Long
  hwndOwner As Long
  hDC As Long
  lpLogFont As Long
  iPointSize As Long
  Flags As Long
  rgbColors As Long
  lCustData As Long
  lpfnHook As Long
  lpTemplateName As String
  hInstance As Long
  lpszStyle As String
  nFontType As Integer
  MISSING_ALIGNMENT As Integer
  nSizeMin As Long
  nSizeMax As Long
End Type

'UDT for the GetOpenFileName and GetSaveFileName functions
Private Type OpenFilename
  lStructSize As Long
  hwndOwner As Long
  hInstance As Long
  lpstrFilter As String
  lpstrCustomFilter As String
  nMaxCustFilter As Long
  iFilterIndex As Long
  lpstrFile As String
  nMaxFile As Long
  lpstrFileTitle As String
  nMaxFileTitle As Long
  lpstrInitialDir As String
  lpstrTitle As String
  Flags As Long
  nFileOffset As Integer
  nFileExtension As Integer
  lpstrDefExt As String
  lCustData As Long
  lpfnHook As Long
  lpTemplateName As String
End Type

'UDT for the PrintDlg function
Private Type PrintDlg
  lStructSize As Long
  hwndOwner As Long
  hDevMode As Long
  hDevNames As Long
  hDC As Long
  Flags As Long
  nFromPage As Integer
  nToPage As Integer
  nMinPage As Integer
  nMaxPage As Integer
  nCopies As Integer
  hInstance As Long
  lCustData As Long
  lpfnPrintHook As Long
  lpfnSetupHook As Long
  lpPrintTemplateName As String
  lpSetupTemplateName As String
  hPrintTemplate As Long
  hSetupTemplate As Long
End Type

'DEVMODE collation selections
Private Const DMCOLLATE_FALSE = 0
Private Const DMCOLLATE_TRUE = 1

Private Type DEVNAMES
  wDriverOffset As Integer
  wDeviceOffset As Integer
  wOutputOffset As Integer
  wDefault As Integer
End Type

Private Type DEVMODE
  dmDeviceName(0 To 31) As Byte
  dmSpecVersion As Integer
  dmDriverVersion As Integer
  dmSize As Integer
  dmDriverExtra As Integer
  dmFields As Long
  dmOrientation As Integer
  dmPaperSize As Integer
  dmPaperLength As Integer
  dmPaperWidth As Integer
  dmScale As Integer
  dmCopies As Integer
  dmDefaultSource As Integer
  dmPrintQuality As Integer
  dmColor As Integer
  dmDuplex As Integer
  dmYResolution As Integer
  dmTTOption As Integer
  dmCollate As Integer
  dmFormName(0 To 31) As Byte
  dmUnusedPadding As Integer
  dmBitsPerPel As Integer
  dmPelsWidth As Long
  dmPelsHeight As Long
  dmDisplayFlags As Long
  dmDisplayFrequency As Long
  dmICMMethod As Long
  dmICMIntent As Long
  dmMediaType As Long
  dmDitherType As Long
  dmReserved1 As Long
  dmReserved2 As Long
End Type

'local variable(s) to hold property value(s)
Private mintAction As Integer 'local copy
Private mstrFilter As String 'local copy
Private mstrFileName As String 'local copy
Private mintFilterIndex As Integer 'local copy
Private mblnCancelError As Boolean 'local copy
Private mlngColor As Long 'local copy
Private mlngCopies As Long 'local copy
Private mstrDefaultExt As String 'local copy
Private mstrDialogTitle As String 'local copy
Private mlngFlags As Long 'local copy
Private mblnFontBold As Boolean 'local copy
Private mblnFontItalic As Boolean 'local copy
Private mstrFontName As String 'local copy
Private mlngFontSize As Long 'local copy
Private mblnFontStrikethru As Boolean 'local copy
Private mblnFontUnderline As Boolean 'local copy
Private mlngFromPage As Long 'local copy
Private mlnghWnd As Long 'local copy
Private mlnghDC As Long 'local copy
Private mlngHelpCommand As Long 'local copy
Private mstrHelpFile As String 'local copy
Private mstrHelpKey_Context As String 'local copy
Private mstrInitDir As String 'local copy
Private mlngMax As Long 'local copy
Private mlngMaxFileSize As Long 'local copy
Private mlngMin As Long 'local copy
Private mblnPrinterDefault As Boolean 'local copy
Private mlngToPage As Long 'local copy
Private mstrFileTitle As String 'local copy
Private mlngAPIReturn As Long 'local copy
Private mlngExtendedError As Long 'local copy

Public Enum ccdControlContants
  'File Open/Save Dialog Box Flags
  cdlOFNAllowMultiselect = &H200
  cdlOFNCreatePrompt = &H2000
  cdlOFNExplorer = &H80000
  cdlOFNExtensionDifferent = &H400
  cdlOFNFileMustExist = &H1000
  cdlOFNHelpButton = &H10
  cdlOFNHideReadOnly = &H4
  cdlOFNLongNames = &H200000
  cdlOFNNoChangeDir = &H8
  cdlOFNNoDereferenceLinks = &H100000
  cdlOFNNoReadOnlyReturn = &H8000
  cdlOFNNoValidate = &H100
  cdlOFNOverwritePrompt = &H2
  cdlOFNPathMustExist = &H800
  cdlOFNReadOnly = &H1
  cdlOFNShareAware = &H4000
  'Color Dialog Box Flags
  cdlCCFullOpen = &H2
  cdlCCShowHelp = &H8
  cdlCCPreventFullOpen = &H4
  cdlCCRGBInit = &H1
  'Fonts Dialog Box Flags
  cdlCFANSIOnly = &H400
  cdlCFapply = &H200 'Enables the Apply button on the dialog box.
  cdlcfboth = &H3
  cdlCFeffects = &H100 'Specifies that the dialog box enables
  'strikethrough, underline, and color effects.
  cdlCFFixedPitchOnly = &H4000
  cdlCFForceFontExist = &H10000
  cdlCFHelpButton = &H4
  cdlCFLimitSize = &H2000
  cdlCFNoFaceSel = &H80000
  cdlCFNoSimulations = &H1000
  cdlCFNoSizeSel = &H200000
  cdlCFNoStyleSel = &H100000
  cdlCFNoVictorFonts = &H800
  cdlCFPrinterFonts = &H2
  cdlCFScalableOnly = &H20000
  cdlCFSreenFonts = &H1
  cdlCFTTOnly = &H40000
  cdlCFWYSIWYG = &H8000
  'Printer Dialog Box Flags
  cdlPDAllPages = &H0
  cdlPDCollate = &H10
  cdlPDDisablePrintToFile = &H80000
  cdlPDHelpButton = &H800
  cdlPDHidePrintToFile = &H100000
  cdlPDNoPageNums = &H8
  cdlPDNoSelection = &H4
  cdlPDNoWarning = &H80
  cdlPDPageNums = &H2
  cdlPDPrintSetup = &H40
  cdlPDPrintToFile = &H20
  cdlPDReturnDC = &H100
  cdlPDReturnDefault = &H400
  cdlPDReturnIC = &H200
  cdlPDSelection = &H1
  cdlPDUseDevModeCopies = &H40000
End Enum

Public Enum cCancel
  'Cancel Constant
  cdlCancel = vbObjectError + 2001
End Enum

Public Enum cHelp
  'Help Constants
  cdlHelpCommand = &H102
  cdlHelpContents = &H3
  cdlHelpFinder = &HB
  cdlHelpContext = &H1
  cdlHelpContextPopup = &H8
  cdlHelpForceFile = &H9
  cdlHelpHelpOnHelp = &H4
  cdlHelpIndex = &H3
  cdlHelpKey = &H101
  cdlHelpPartialKey = &H105
  cdlHelpQuit = &H2
  cdlHelpSetContents = &H5
  cdlHelpSetIndex = &H5
End Enum

Public Property Get ExtendedError() As Long
  'Read Only - Get the last error message
  ExtendedError = mlngExtendedError
End Property

Public Property Get APIReturn() As Long
  'Read Only - Get the action performed by the class
  APIReturn = mlngAPIReturn
End Property

Public Property Let FileTitle(ByVal strData As String)
  mstrFileTitle = strData
End Property

Public Property Get FileTitle() As String
  FileTitle = mstrFileTitle
End Property

Public Property Let ToPage(ByVal lngData As Long)
  mlngToPage = lngData
End Property

Public Property Get ToPage() As Long
  ToPage = mlngToPage
End Property

Public Property Let PrinterDefault(ByVal intData As Boolean)
  mblnPrinterDefault = intData
End Property

Public Property Get PrinterDefault() As Boolean
  PrinterDefault = mblnPrinterDefault
End Property

Public Property Let Min(ByVal lngData As Long)
  mlngMin = lngData
End Property

Public Property Get Min() As Long
  Min = mlngMin
End Property

Public Property Let MaxFileSize(ByVal lngData As Long)
  mlngMaxFileSize = lngData
End Property

Public Property Get MaxFileSize() As Long
  MaxFileSize = mlngMaxFileSize
End Property

Public Property Let Max(ByVal lngData As Long)
  mlngMax = lngData
End Property

Public Property Get Max() As Long
  Max = mlngMax
End Property

Public Property Let InitDir(ByVal strData As String)
  mstrInitDir = strData
End Property

Public Property Get InitDir() As String
  InitDir = mstrInitDir
End Property

Public Property Let HelpKey(ByVal strData As String)
  mstrHelpKey_Context = strData
End Property

Public Property Get HelpKey() As String
  HelpKey = mstrHelpKey_Context
End Property

Public Property Let HelpFile(ByVal strData As String)
  mstrHelpFile = strData
End Property

Public Property Get HelpFile() As String
  HelpFile = mstrHelpFile
End Property

Public Property Let HelpContext(ByVal strData As String)
  mstrHelpKey_Context = strData
End Property

Public Property Get HelpContext() As String
  HelpContext = mstrHelpKey_Context
End Property

Public Property Let HelpCommand(ByVal lngData As cHelp)
  mlngHelpCommand = lngData
End Property

Public Property Get HelpCommand() As cHelp
  HelpCommand = mlngHelpCommand
End Property

Public Property Let hDC(ByVal lngData As Long)
  mlnghDC = lngData
End Property

Public Property Get hDC() As Long
  hDC = mlnghDC
End Property

Public Property Let FromPage(ByVal lngData As Long)
  mlngFromPage = lngData
End Property

Public Property Get FromPage() As Long
  FromPage = mlngFromPage
End Property

Public Property Let FontUnderline(ByVal blnData As Boolean)
  mblnFontUnderline = blnData
End Property

Public Property Get FontUnderline() As Boolean
  FontUnderline = mblnFontUnderline
End Property

Public Property Let FontStrikethru(ByVal blnData As Boolean)
  mblnFontStrikethru = blnData
End Property

Public Property Get FontStrikethru() As Boolean
  FontStrikethru = mblnFontStrikethru
End Property

Public Property Let FontSize(ByVal lngData As Long)
  mlngFontSize = lngData
End Property

Public Property Get FontSize() As Long
  FontSize = mlngFontSize
End Property

Public Property Let FontName(ByVal strData As String)
  mstrFontName = strData
End Property

Public Property Get FontName() As String
  FontName = mstrFontName
End Property

Public Property Let FontItalic(ByVal blnData As Boolean)
  mblnFontItalic = blnData
End Property

Public Property Get FontItalic() As Boolean
  FontItalic = mblnFontItalic
End Property

Public Property Let FontBold(ByVal blnData As Boolean)
  mblnFontBold = blnData
End Property

Public Property Get FontBold() As Boolean
  FontBold = mblnFontBold
End Property

Public Property Let Flags(ByVal lngData As ccdControlContants)
  mlngFlags = lngData
End Property

Public Property Get Flags() As ccdControlContants
  Flags = mlngFlags
End Property

Public Property Let DialogTitle(ByVal strData As String)
  mstrDialogTitle = strData
End Property

Public Property Get DialogTitle() As String
  DialogTitle = mstrDialogTitle
End Property

Public Property Let DefaultExt(ByVal strData As String)
  mstrDefaultExt = strData
End Property

Public Property Get DefaultExt() As String
  DefaultExt = mstrDefaultExt
End Property

Public Property Let Copies(ByVal lngData As Long)
  mlngCopies = lngData
End Property

Public Property Get Copies() As Long
  Copies = mlngCopies
End Property

Public Property Let Color(ByVal lngData As Long)
  mlngColor = lngData
End Property

Public Property Get Color() As Long
  Color = mlngColor
End Property

Public Property Let CancelError(ByVal blnData As Boolean)
  mblnCancelError = blnData
End Property

Public Property Get CancelError() As Boolean
  CancelError = mblnCancelError
End Property

Public Property Let FilterIndex(ByVal intData As Integer)
  mintFilterIndex = intData
End Property

Public Property Get FilterIndex() As Integer
  FilterIndex = mintFilterIndex
End Property

Public Property Let FileName(ByVal strData As String)
  mstrFileName = strData
End Property

Public Property Get FileName() As String
  FileName = mstrFileName
End Property

Public Sub ShowSave()
  
  ShowFileDialog (cShowSave)
  
End Sub

Public Sub ShowPrinter()

  Dim udtPrintDlg As PrintDlg
  Dim dvmode As DEVMODE
  Dim pDevMode As Long
  
  On Error GoTo ShowPrinterError
  
  mintAction = cShowPrinter
  mlngAPIReturn = 0
  mlngExtendedError = 0
  
  'Prepare udtPrintDlg for data
  udtPrintDlg.lStructSize = Len(udtPrintDlg)
  udtPrintDlg.hwndOwner = mlnghWnd
  'hDevMode set to 0 - default
  'hDevNames set to 0 - default
  udtPrintDlg.hDC = mlnghDC
  udtPrintDlg.Flags = mlngFlags
  udtPrintDlg.nFromPage = mlngFromPage
  udtPrintDlg.nToPage = mlngToPage
  udtPrintDlg.nMinPage = mlngMin
  udtPrintDlg.nMaxPage = mlngMax
  udtPrintDlg.nCopies = mlngCopies
  'hInstance set to 0 - default
  'lCustData  set to 0 - default
  'lpfnPrintHook set to 0 - default
  'lpfnSetupHook set to 0 - default
  'lpPrintTemplateName set to 0 - default
  'lpSetupTemplateName set to 0 - default
  'hPrintTemplate set to 0 - default
  'hSetupTemplate set to 0 - default
  
  mlngAPIReturn = PrintDlg(udtPrintDlg)
  
  Select Case mlngAPIReturn
    Case cUserCanceled
      If mblnCancelError = True Then
        'generate an error
        'On Error GoTo 0
        Err.Raise Number:=cdlCancel, Description:=cCancelDescription
        Exit Sub
      End If
    Case cUserSelected
      mlngFromPage = udtPrintDlg.nFromPage
      mlngToPage = udtPrintDlg.nToPage
      mlngMin = udtPrintDlg.nMinPage
      mlngMax = udtPrintDlg.nMaxPage
      mlnghDC = udtPrintDlg.hDC
      'Get DEVMODE structure from udtPrintDlg
      pDevMode = GlobalLock(udtPrintDlg.hDevMode)
      CopyMemory VarPtr(dvmode), pDevMode, Len(dvmode)
      Call GlobalUnlock(udtPrintDlg.hDevMode)
      If mlngFlags And cdlPDUseDevModeCopies Then
        mlngCopies = dvmode.dmCopies
      Else
        mlngCopies = udtPrintDlg.nCopies
      End If
      On Error Resume Next
      If mblnPrinterDefault Then
        Printer.Copies = mlngCopies
        Printer.Orientation = dvmode.dmOrientation
        Printer.PaperSize = dvmode.dmPaperSize
        Printer.PrintQuality = dvmode.dmPrintQuality
      End If
    Case Else
      'Call CommDlgExtendedError
      mlngExtendedError = CommDlgExtendedError
  End Select
  
  Exit Sub
ShowPrinterError:
  Exit Sub
  
End Sub

Public Sub ShowOpen()
  
  ShowFileDialog (cShowOpen)
  
End Sub

Public Sub ShowHelp()
  
  Dim lngData As Long
  Dim strData As String
  Dim lngReturn As Long
  
  On Error GoTo ShowHelpError
  
  mintAction = cShowHelp
  mlngAPIReturn = 0
  mlngExtendedError = 0
  
  'Prepare data for API funtion call
  Select Case mlngHelpCommand
    Case cdlHelpContext, cdlHelpContextPopup, cdlHelpSetContents
      lngData = CLng(mstrHelpKey_Context)
      mlngAPIReturn = WinHelp(mlnghDC, mstrHelpFile, mlngHelpCommand, _
        lngData)
    Case cdlHelpKey, cdlHelpPartialKey, cdlHelpCommand
      mlngAPIReturn = WinHelpStr(mlnghDC, mstrHelpFile, _
        mlngHelpCommand, mstrHelpKey_Context & vbNullChar)
    Case Else
      lngData = 0&
      mlngAPIReturn = WinHelp(mlnghDC, mstrHelpFile, mlngHelpCommand, _
        lngData)
  End Select
  
  'Check for error
  If mlngAPIReturn = 0 Then mlngExtendedError = GetLastError
  
  Exit Sub
  
ShowHelpError:

  Exit Sub
      
End Sub

Public Sub ShowFont()
  
  Dim udtLogFont As LOGFONT
  Dim udtChooseFont As CHOOSEFONT
  Dim lngReturn As Long
  Const PointsPerTwip = 1440 / 72
  Const CF_InitToLogFontStruct = &H40
  
  On Error GoTo ShowFontError
  
  mintAction = cShowFont
  mlngAPIReturn = 0
  mlngExtendedError = 0
  
  'Prepare the udtLogFont with data
  'lfHeight set to 0 - default
  udtLogFont.lfHeight = -(mlngFontSize * (PointsPerTwip / _
    Screen.twipsPerPixelY))
  'lfWidth set to 0 - default
  'lfEscapement set to 0 - default
  'lfOrientation set to 0 - default
  If mblnFontBold = True Then
    udtLogFont.lfWeight = FW_BOLD
  End If
  If mblnFontItalic = True Then
    udtLogFont.lfItalic = 1
  End If
  If mblnFontUnderline = True Then
    udtLogFont.lfUnderline = 1
  End If
  If mblnFontStrikethru = True Then
    udtLogFont.lfStrikeOut = 1
  End If
  'lfCharSet set to 0 - default
  'lfOutPrecision set to 0 - default
  'lfClipPrecision set to 0 - default
  'lfQuality set to 0 - default
  'lfPitchAndFamily set to 0 - default
  StrToBytes udtLogFont.lfFaceName, mstrFontName
  
  'Prepare mudtChooseFont with data
  udtChooseFont.lStructSize = Len(udtChooseFont)
  udtChooseFont.hwndOwner = mlnghWnd
  udtChooseFont.hDC = hDC
  
  'Get address of LogFont Structure
  udtChooseFont.lpLogFont = VarPtr(udtLogFont)
  udtChooseFont.iPointSize = mlngFontSize * 10
  mlngFlags = (mlngFlags Or CF_InitToLogFontStruct)
  udtChooseFont.Flags = mlngFlags
  udtChooseFont.rgbColors = mlngColor
  'lCustData set to 0 - default
  'lpfnHook set to 0 - default
  'lpTemplateName set to 0 - default
  'hInstance set to 0 - default
  'lpszStyle set to 0 - default
  'nFontType set to 0 - default
  'MISSING_ALIGNMENT set to 0 - default
  udtChooseFont.nSizeMin = mlngMin
  udtChooseFont.nSizeMax = mlngMax
  
  'Call the API ChooseFont function
  mlngAPIReturn = CHOOSEFONT(udtChooseFont)
  
  Select Case mlngAPIReturn
    Case cUserCanceled    'Cancel button pressed
      If mblnCancelError = True Then
        'generate an error
        'On Error GoTo 0
        Err.Raise Number:=cdlCancel, _
          Description:=cCancelDescription
        Exit Sub
      End If
    Case cUserSelected    'User selected a font
      mlngFlags = udtChooseFont.Flags
      mlngColor = udtChooseFont.rgbColors
      If udtLogFont.lfWeight >= FW_BOLD Then
        mblnFontBold = True
      Else
        mblnFontBold = False
      End If
      If udtLogFont.lfItalic > 1 Then
        mblnFontItalic = True
      Else
        mblnFontItalic = False
      End If
      If udtLogFont.lfUnderline = 1 Then
        mblnFontUnderline = True
      Else
        mblnFontUnderline = False
      End If
      If udtLogFont.lfStrikeOut = 1 Then
        mblnFontStrikethru = True
      Else
        mblnFontStrikethru = False
      End If
      mstrFontName = strByteArrayToString(udtLogFont.lfFaceName())
      mlngFontSize = CLng(udtChooseFont.iPointSize / 10)
    Case Else
      mlngExtendedError = CommDlgExtendedError
  End Select
  
  Exit Sub
  
ShowFontError:

  Exit Sub

End Sub

Public Sub ShowColor()

  Dim udtChooseColor As ChooseColor
  Dim alngCustomColors(15) As Long
  Dim intn As Integer
  Dim lngReturn As Long
  
  On Error GoTo ShowColorError
  
  mintAction = cShowColor   'Set the Action property to ShowColor
  mlngAPIReturn = 0         'Reset APIRetur property
  mlngExtendedError = 0     'Reset the Extended Error property
  
  'Prepare the udtChooseColor with data
  udtChooseColor.lStructSize = Len(udtChooseColor)
  udtChooseColor.hwndOwner = mlnghWnd
  'hInstance set to 0 - default
  udtChooseColor.rgbResult = mlngColor
  'Set custom color array with white
  For intn = 0 To UBound(alngCustomColors)
    alngCustomColors(intn) = &HFFFFFF
  Next
  'Get address of Custom Color Array
  udtChooseColor.lpCustColors = VarPtr(alngCustomColors(0))
  udtChooseColor.Flags = mlngFlags
  'CustData set to 0 - default
  'lpfnHook set to 0 - default
  'lpTemplateName set to 0 - default
  
  'Call the ChooseColor API function
  mlngAPIReturn = ChooseColor(udtChooseColor)
  
  'Process return
  Select Case mlngAPIReturn
    Case cUserCanceled    'Dialog cancel button pressed
      If mblnCancelError = True Then
        'On Error GoTo 0
        Err.Raise Number:=cdlCancel, Description:=cCancelDescription
        Exit Sub
      End If
    Case cUserSelected  'Color selected
      mlngColor = udtChooseColor.rgbResult
    Case Else             'Error
      mlngExtendedError = CommDlgExtendedError
  End Select
    
Exit Sub

ShowColorError:

  Exit Sub
  
End Sub

Public Property Let Filter(ByVal strData As String)
  mstrFilter = strData
End Property

Public Property Get Filter() As String
  Filter = mstrFilter
End Property

Public Property Let Action(ByVal intData As Integer)
  mintAction = intData
End Property

Public Property Get Action() As Integer
  Action = mintAction
End Property

Private Function strByteArrayToString(abBytes() As Byte) As String
      
  strByteArrayToString = StrConv(abBytes, vbUnicode)
        
'  'return a string from a byte array
'  Dim lngBytePoint As Long
'  Dim lngByteVal As Long
'  Dim strOut As String
'
'  'init array pointer
'  lngBytePoint = LBound(abBytes)
'
'  'fill sOut with characters in array
'  While lngBytePoint <= UBound(abBytes)
'    lngByteVal = abBytes(lngBytePoint)
'
'    'return sOut and stop if Chr$(0) is encountered
'    If lngByteVal = 0 Then
'      strByteArrayToString = strOut
'      Exit Function
'    Else
'      strOut = strOut & Chr$(lngByteVal)
'    End If
'
'    lngBytePoint = lngBytePoint + 1
'
'  Wend
'
'  'return sOut if Chr$(0) wasn't encountered
'  strByteArrayToString = strOut
    
End Function

Private Function strLeftOfNull(ByVal strIn As String)
  
  If InStr(strIn, vbNullChar) Then
    strLeftOfNull = Left$(strIn, InStr(strIn, vbNullChar) - 1)
  Else
    strLeftOfNull = strIn
  End If
    
End Function

Private Function strAPIFilter(strIn)

  'prepares sIn for use as a filter string in API common dialog functions
  Dim lngChrNdx As Long
  Dim strOneChr As String
  Dim strOutStr As String
  
  'convert any | characters to nulls
  For lngChrNdx = 1 To Len(strIn)
    strOneChr = Mid$(strIn, lngChrNdx, 1)
    If strOneChr = "|" Then
      strOutStr = strOutStr & vbNullChar
    Else
      strOutStr = strOutStr & strOneChr
    End If
  Next
  
  'add a null to the end
  strOutStr = strOutStr & vbNullChar
  
  'return sOutStr
  strAPIFilter = strOutStr
    
End Function

Private Sub ShowFileDialog(ByVal mintAction As Integer)
    
  'display the file dialog for ShowOpen or ShowSave
  Dim udtOpenFile As OpenFilename
  Dim lngMaxSize As Long
    
  On Error GoTo ShowFileDialogError
    
  '***    init property buffers
  mintAction = mintAction  'Action property
  mlngAPIReturn = 0  'APIReturn property
  mlngExtendedError = 0  'ExtendedError property
        
  'Prepare mudtOpenFile for data
  udtOpenFile.lStructSize = Len(udtOpenFile)
  udtOpenFile.hwndOwner = mlnghWnd
  'hInstance set to 0 - default
  udtOpenFile.lpstrFilter = strAPIFilter(mstrFilter)
  'lpstrCustomFilter set to 0 - default
  'nMaxCustFilter set to 0 - default
  udtOpenFile.iFilterIndex = CLng(mintFilterIndex)
  If mlngMaxFileSize > 0 Then
    lngMaxSize = mlngMaxFileSize
  Else
    lngMaxSize = cMaxFileSize
  End If
  udtOpenFile.lpstrFile = String(lngMaxSize + 1, 0)
  udtOpenFile.nMaxFile = Len(udtOpenFile.lpstrFile) - 1
  udtOpenFile.lpstrFileTitle = udtOpenFile.lpstrFile
  udtOpenFile.nMaxFileTitle = udtOpenFile.nMaxFile
  udtOpenFile.lpstrInitialDir = mstrInitDir
  udtOpenFile.lpstrTitle = mstrDialogTitle
  udtOpenFile.Flags = mlngFlags
  udtOpenFile.lpstrDefExt = mstrDefaultExt
    
  'Call the GetOpenFileName API function
  Select Case mintAction
    Case cShowOpen
      mlngAPIReturn = GetOpenFileName(udtOpenFile)
    Case cShowSave
      mlngAPIReturn = GetSaveFileName(udtOpenFile)
    Case Else   'unknown action
      Exit Sub
  End Select
      
  '***    handle return from GetOpenFileName API function
  Select Case mlngAPIReturn
    Case cUserCanceled
      If mblnCancelError = True Then
        'generate an error
        'On Error GoTo 0
        Err.Raise Number:=cdlCancel, _
          Description:=cCancelDescription
        Exit Sub
      End If
    Case cUserSelected
      mstrFileName = strLeftOfNull(udtOpenFile.lpstrFile)
      mstrFileTitle = strLeftOfNull(udtOpenFile.lpstrFileTitle)
    Case Else   'an error occured
      'call CommDlgExtendedError
      mlngExtendedError = CommDlgExtendedError
  End Select
    
Exit Sub

ShowFileDialogError:
    
  Exit Sub

End Sub

Sub StrToBytes(ab() As Byte, s As String)

  Dim cab As Long
  'Copy to existing array, padding or truncating if necessary
  cab = UBound(ab) - LBound(ab) + 1
  If Len(s) < cab Then s = s & String$(cab - Len(s), 0)
  CopyMemoryStr ab(LBound(ab)), s, LenB(s)
  
End Sub

Public Property Get hWnd() As Long
  hWnd = mlnghWnd
End Property

Public Property Let hWnd(ByVal lnghWnd As Long)
  mlnghWnd = lnghWnd
End Property
