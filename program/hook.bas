Attribute VB_Name = "Hook"
Option Explicit

Public Declare Function CallWindowProc Lib "USER32" Alias "CallWindowProcA" ( _
ByVal lpPrevWndFunc As Long, _
ByVal hwnd As Long, _
ByVal msg As Long, _
ByVal wParam As Long, _
ByVal lParam As Long _
) As Long

Public Declare Function SetWindowLong Lib "USER32" Alias "SetWindowLongA" ( _
ByVal hwnd As Long, _
ByVal nIndex As Long, _
ByVal dwNewLong As Long _
) As Long

Public Declare Function SendMessage Lib "USER32" Alias "SendMessageA" ( _
ByVal hwnd As Long, _
ByVal wMsg As Long, _
ByVal wParam As Long, _
lParam As Any _
) As Long

Public Declare Function GetWindow Lib "USER32" ( _
ByVal hwnd As Long, _
ByVal wCmd As Long _
) As Long

Public Declare Function GetScrollRange Lib "USER32" ( _
ByVal hwnd As Long, _
ByVal nBar As Long, _
ByRef lpMinPos As Long, _
ByRef lpMaxPos As Long _
) As Long

' Enumerates all windows active on the
' the system until the last window has
' been reached.
Public Declare Function EnumWindows _
    Lib "USER32" ( _
        ByVal lpEnumFunc As Long, _
        ByVal lParam As Long) _
        As Long

' Retrieves the window text (caption)
' from the specified window.
Public Declare Function GetWindowText _
    Lib "USER32" _
    Alias "GetWindowTextA" ( _
        ByVal hwnd As Long, _
        ByVal lpString As String, _
        ByVal cch As Long) _
        As Long

' Determines if a window is visible on
' the system.
Public Declare Function IsWindowVisible _
    Lib "USER32" ( _
        ByVal hwnd As Long) _
        As Long

' Posts a specified windows message into
' a window procedures message queue to be
' processed
Public Declare Function PostMessage _
    Lib "USER32" _
    Alias "PostMessageA" ( _
        ByVal hwnd As Long, _
        ByVal wMsg As Long, _
        ByVal wParam As Long, _
        ByVal lParam As Long) _
        As Long

Public Const SB_HORZ = 0
Public Const SB_VERT = 1
Public Const SB_CTL = 2
Public Const SB_BOTH = 3

Public Const SB_BOTTOM = 7
Public Const SB_LEFT = 6
Public Const SB_LINEDOWN = 1
Public Const SB_LINELEFT = 0
Public Const SB_LINERIGHT = 1
Public Const SB_LINEUP = 0
Public Const SB_PAGEDOWN = 3
Public Const SB_PAGELEFT = 2
Public Const SB_PAGERIGHT = 3
Public Const SB_PAGEUP = 2
Public Const SB_RIGHT = 7
Public Const SB_THUMBPOSITION = 4
Public Const SB_THUMBTRACK = 5
Public Const SB_TOP = 6
Public Const SB_ENDSCROLL = 8

Public Const GW_CHILD = 5

Public Const GWL_WNDPROC = -4

Public Const WM_NULL = &H0
Public Const WM_CREATE = &H1
Public Const WM_DESTROY = &H2
Public Const WM_MOVE = &H3
Public Const WM_SIZE = &H5
Public Const WM_ACTIVATE = &H6
Public Const WM_SETFOCUS = &H7
Public Const WM_KILLFOCUS = &H8
Public Const WM_ENABLE = &HA
Public Const WM_SETREDRAW = &HB
Public Const WM_SETTEXT = &HC
Public Const WM_GETTEXT = &HD
Public Const WM_GETTEXTLENGTH = &HE
Public Const WM_PAINT = &HF
Public Const WM_CLOSE = &H10
Public Const WM_QUERYENDSESSION = &H11
Public Const WM_QUIT = &H12
Public Const WM_QUERYOPEN = &H13
Public Const WM_ERASEBKGND = &H14
Public Const WM_SYSCOLORCHANGE = &H15
Public Const WM_ENDSESSION = &H16
Public Const WM_SHOWWINDOW = &H18
Public Const WM_WININICHANGE = &H1A
Public Const WM_DEVMODECHANGE = &H1B
Public Const WM_ACTIVATEAPP = &H1C
Public Const WM_FONTCHANGE = &H1D
Public Const WM_TIMECHANGE = &H1E
Public Const WM_CANCELMODE = &H1F
Public Const WM_SETCURSOR = &H20
Public Const WM_MOUSEACTIVATE = &H21
Public Const WM_CHILDACTIVATE = &H22
Public Const WM_QUEUESYNC = &H23
Public Const WM_GETMINMAXINFO = &H24
Public Const WM_PAINTICON = &H26
Public Const WM_ICONERASEBKGND = &H27
Public Const WM_NEXTDLGCTL = &H28
Public Const WM_SPOOLERSTATUS = &H2A
Public Const WM_DRAWITEM = &H2B
Public Const WM_MEASUREITEM = &H2C
Public Const WM_DELETEITEM = &H2D
Public Const WM_VKEYTOITEM = &H2E
Public Const WM_CHARTOITEM = &H2F
Public Const WM_SETFONT = &H30
Public Const WM_GETFONT = &H31
Public Const WM_SETHOTKEY = &H32
Public Const WM_GETHOTKEY = &H33
Public Const WM_QUERYDRAGICON = &H37
Public Const WM_COMPAREITEM = &H39
Public Const WM_GETOBJECT = &H3D
Public Const WM_COMPACTING = &H41
Public Const WM_COMMNOTIFY = &H44
Public Const WM_WINDOWPOSCHANGING = &H46
Public Const WM_WINDOWPOSCHANGED = &H47
Public Const WM_POWER = &H48
Public Const WM_COPYDATA = &H4A
Public Const WM_CANCELJOURNAL = &H4B
Public Const WM_NOTIFY = &H4E
Public Const WM_INPUTLANGCHANGEREQUEST = &H50
Public Const WM_INPUTLANGCHANGE = &H51
Public Const WM_TCARD = &H52
Public Const WM_HELP = &H53
Public Const WM_USERCHANGED = &H54
Public Const WM_NOTIFYFORMAT = &H55
Public Const WM_CONTEXTMENU = &H7B
Public Const WM_STYLECHANGING = &H7C
Public Const WM_STYLECHANGED = &H7D
Public Const WM_DISPLAYCHANGE = &H7E
Public Const WM_GETICON = &H7F
Public Const WM_SETICON = &H80
Public Const WM_NCCREATE = &H81
Public Const WM_NCDESTROY = &H82
Public Const WM_NCCALCSIZE = &H83
Public Const WM_NCHITTEST = &H84
Public Const WM_NCPAINT = &H85
Public Const WM_NCACTIVATE = &H86
Public Const WM_GETDLGCODE = &H87
Public Const WM_SYNCPAINT = &H88
Public Const WM_NCMOUSEMOVE = &HA0
Public Const WM_NCLBUTTONDOWN = &HA1
Public Const WM_NCLBUTTONUP = &HA2
Public Const WM_NCLBUTTONDBLCLK = &HA3
Public Const WM_NCRBUTTONDOWN = &HA4
Public Const WM_NCRBUTTONUP = &HA5
Public Const WM_NCRBUTTONDBLCLK = &HA6
Public Const WM_NCMBUTTONDOWN = &HA7
Public Const WM_NCMBUTTONUP = &HA8
Public Const WM_NCMBUTTONDBLCLK = &HA9
Public Const WM_KEYFIRST = &H100
Public Const WM_KEYDOWN = &H100
Public Const WM_KEYUP = &H101
Public Const WM_CHAR = &H102
Public Const WM_DEADCHAR = &H103
Public Const WM_SYSKEYDOWN = &H104
Public Const WM_SYSKEYUP = &H105
Public Const WM_SYSCHAR = &H106
Public Const WM_SYSDEADCHAR = &H107
Public Const WM_KEYLAST = &H108
Public Const WM_IME_STARTCOMPOSITION = &H10D
Public Const WM_IME_ENDCOMPOSITION = &H10E
Public Const WM_IME_COMPOSITION = &H10F
Public Const WM_INITDIALOG = &H110
Public Const WM_COMMAND = &H111
Public Const WM_SYSCOMMAND = &H112
Public Const WM_TIMER = &H113
Public Const WM_HSCROLL = &H114
Public Const WM_VSCROLL = &H115
Public Const WM_INITMENU = &H116
Public Const WM_INITMENUPOPUP = &H117
Public Const WM_MENUSELECT = &H11F
Public Const WM_MENUCHAR = &H120
Public Const WM_ENTERIDLE = &H121
Public Const WM_MENURBUTTONUP = &H122
Public Const WM_MENUDRAG = &H123
Public Const WM_MENUGETOBJECT = &H124
Public Const WM_UNINITMENUPOPUP = &H125
Public Const WM_MENUCOMMAND = &H126
Public Const WM_CTLCOLORMSGBOX = &H132
Public Const WM_CTLCOLOREDIT = &H133
Public Const WM_CTLCOLORLISTBOX = &H134
Public Const WM_CTLCOLORBTN = &H135
Public Const WM_CTLCOLORDLG = &H136
Public Const WM_CTLCOLORSCROLLBAR = &H137
Public Const WM_CTLCOLORSTATIC = &H138
Public Const WM_MOUSEMOVE = &H200
Public Const WM_LBUTTONDOWN = &H201
Public Const WM_LBUTTONUP = &H202
Public Const WM_LBUTTONDBLCLK = &H203
Public Const WM_RBUTTONDOWN = &H204
Public Const WM_RBUTTONUP = &H205
Public Const WM_RBUTTONDBLCLK = &H206
Public Const WM_MBUTTONDOWN = &H207
Public Const WM_MBUTTONUP = &H208
Public Const WM_MBUTTONDBLCLK = &H209
Public Const WM_MOUSELAST = &H20A
Public Const WM_PARENTNOTIFY = &H210
Public Const WM_ENTERMENULOOP = &H211
Public Const WM_EXITMENULOOP = &H212
Public Const WM_NEXTMENU = &H213
Public Const WM_SIZING = &H214
Public Const WM_CAPTURECHANGED = &H215
Public Const WM_MOVING = &H216
Public Const WM_POWERBROADCAST = &H218
Public Const WM_DEVICECHANGE = &H219
Public Const WM_MDICREATE = &H220
Public Const WM_MDIDESTROY = &H221
Public Const WM_MDIACTIVATE = &H222
Public Const WM_MDIRESTORE = &H223
Public Const WM_MDINEXT = &H224
Public Const WM_MDIMAXIMIZE = &H225
Public Const WM_MDITILE = &H226
Public Const WM_MDICASCADE = &H227
Public Const WM_MDIICONARRANGE = &H228
Public Const WM_MDIGETACTIVE = &H229
Public Const WM_MDISETMENU = &H230
Public Const WM_ENTERSIZEMOVE = &H231
Public Const WM_EXITSIZEMOVE = &H232
Public Const WM_DROPFILES = &H233
Public Const WM_MDIREFRESHMENU = &H234
Public Const WM_IME_SETCONTEXT = &H281
Public Const WM_IME_NOTIFY = &H282
Public Const WM_IME_CONTROL = &H283
Public Const WM_IME_COMPOSITIONFULL = &H284
Public Const WM_IME_SELECT = &H285
Public Const WM_IME_CHAR = &H286
Public Const WM_IME_REQUEST = &H288
Public Const WM_IME_KEYDOWN = &H290
Public Const WM_IME_KEYUP = &H291
Public Const WM_MOUSEHOVER = &H2A1
Public Const WM_MOUSELEAVE = &H2A3
Public Const WM_CUT = &H300
Public Const WM_COPY = &H301
Public Const WM_PASTE = &H302
Public Const WM_CLEAR = &H303
Public Const WM_UNDO = &H304
Public Const WM_RENDERFORMAT = &H305
Public Const WM_RENDERALLFORMATS = &H306
Public Const WM_DESTROYCLIPBOARD = &H307
Public Const WM_DRAWCLIPBOARD = &H308
Public Const WM_PAINTCLIPBOARD = &H309
Public Const WM_VSCROLLCLIPBOARD = &H30A
Public Const WM_SIZECLIPBOARD = &H30B
Public Const WM_ASKCBFORMATNAME = &H30C
Public Const WM_CHANGECBCHAIN = &H30D
Public Const WM_HSCROLLCLIPBOARD = &H30E
Public Const WM_QUERYNEWPALETTE = &H30F
Public Const WM_PALETTEISCHANGING = &H310
Public Const WM_PALETTECHANGED = &H311
Public Const WM_HOTKEY = &H312
Public Const WM_PRINT = &H317
Public Const WM_PRINTCLIENT = &H318
Public Const WM_HANDHELDFIRST = &H358
Public Const WM_HANDHELDLAST = &H35F
Public Const WM_AFXFIRST = &H360
Public Const WM_AFXLAST = &H37F
Public Const WM_PENWINFIRST = &H380
Public Const WM_PENWINLAST = &H38F
Public Const WM_USER = &H400
Public Const WM_APP = &H8000
Public Const WM_MOUSEWHEEL = &H20A

Public Const WM_KRT_EXTZOOM = WM_USER + 10

Private mWeel As New Collection
Private prevMainWndProc As Long

Global lpPrevWndProc As Long
Global gHW As Long

Private Const hookLogFile As String = "D:\data\krt.log"
Public Const krotMessageZoomDelimeter As String = "!"

Private Function getMessageName(ByVal msgVal As Long) As String

Select Case msgVal
Case WM_NULL
 getMessageName = "WM_NULL"
Case WM_CREATE
 getMessageName = "WM_CREATE"
Case WM_DESTROY
 getMessageName = "WM_DESTROY"
Case WM_MOVE
 getMessageName = "WM_MOVE"
Case WM_SIZE
 getMessageName = "WM_SIZE"
Case WM_ACTIVATE
 getMessageName = "WM_ACTIVATE"
Case WM_SETFOCUS
 getMessageName = "WM_SETFOCUS"
Case WM_KILLFOCUS
 getMessageName = "WM_KILLFOCUS"
Case WM_ENABLE
 getMessageName = "WM_ENABLE"
Case WM_SETREDRAW
 getMessageName = "WM_SETREDRAW"
Case WM_SETTEXT
 getMessageName = "WM_SETTEXT"
Case WM_GETTEXT
 getMessageName = "WM_GETTEXT"
Case WM_GETTEXTLENGTH
 getMessageName = "WM_GETTEXTLENGTH"
Case WM_PAINT
 getMessageName = "WM_PAINT"
Case WM_CLOSE
 getMessageName = "WM_CLOSE"
Case WM_QUERYENDSESSION
 getMessageName = "WM_QUERYENDSESSION"
Case WM_QUIT
 getMessageName = "WM_QUIT"
Case WM_QUERYOPEN
 getMessageName = "WM_QUERYOPEN"
Case WM_ERASEBKGND
 getMessageName = "WM_ERASEBKGND"
Case WM_SYSCOLORCHANGE
 getMessageName = "WM_SYSCOLORCHANGE"
Case WM_ENDSESSION
 getMessageName = "WM_ENDSESSION"
Case WM_SHOWWINDOW
 getMessageName = "WM_SHOWWINDOW"
Case WM_WININICHANGE
 getMessageName = "WM_WININICHANGE"
Case WM_DEVMODECHANGE
 getMessageName = "WM_DEVMODECHANGE"
Case WM_ACTIVATEAPP
 getMessageName = "WM_ACTIVATEAPP"
Case WM_FONTCHANGE
 getMessageName = "WM_FONTCHANGE"
Case WM_TIMECHANGE
 getMessageName = "WM_TIMECHANGE"
Case WM_CANCELMODE
 getMessageName = "WM_CANCELMODE"
Case WM_SETCURSOR
 getMessageName = "WM_SETCURSOR"
Case WM_MOUSEACTIVATE
 getMessageName = "WM_MOUSEACTIVATE"
Case WM_CHILDACTIVATE
 getMessageName = "WM_CHILDACTIVATE"
Case WM_QUEUESYNC
 getMessageName = "WM_QUEUESYNC"
Case WM_GETMINMAXINFO
 getMessageName = "WM_GETMINMAXINFO"
Case WM_PAINTICON
 getMessageName = "WM_PAINTICON"
Case WM_ICONERASEBKGND
 getMessageName = "WM_ICONERASEBKGND"
Case WM_NEXTDLGCTL
 getMessageName = "WM_NEXTDLGCTL"
Case WM_SPOOLERSTATUS
 getMessageName = "WM_SPOOLERSTATUS"
Case WM_DRAWITEM
 getMessageName = "WM_DRAWITEM"
Case WM_MEASUREITEM
 getMessageName = "WM_MEASUREITEM"
Case WM_DELETEITEM
 getMessageName = "WM_DELETEITEM"
Case WM_VKEYTOITEM
 getMessageName = "WM_VKEYTOITEM"
Case WM_CHARTOITEM
 getMessageName = "WM_CHARTOITEM"
Case WM_SETFONT
 getMessageName = "WM_SETFONT"
Case WM_GETFONT
 getMessageName = "WM_GETFONT"
Case WM_SETHOTKEY
 getMessageName = "WM_SETHOTKEY"
Case WM_GETHOTKEY
 getMessageName = "WM_GETHOTKEY"
Case WM_QUERYDRAGICON
 getMessageName = "WM_QUERYDRAGICON"
Case WM_COMPAREITEM
 getMessageName = "WM_COMPAREITEM"
Case WM_GETOBJECT
 getMessageName = "WM_GETOBJECT"
Case WM_COMPACTING
 getMessageName = "WM_COMPACTING"
Case WM_COMMNOTIFY
 getMessageName = "WM_COMMNOTIFY"
Case WM_WINDOWPOSCHANGING
 getMessageName = "WM_WINDOWPOSCHANGING"
Case WM_WINDOWPOSCHANGED
 getMessageName = "WM_WINDOWPOSCHANGED"
Case WM_POWER
 getMessageName = "WM_POWER"
Case WM_COPYDATA
 getMessageName = "WM_COPYDATA"
Case WM_CANCELJOURNAL
 getMessageName = "WM_CANCELJOURNAL"
Case WM_NOTIFY
 getMessageName = "WM_NOTIFY"
Case WM_INPUTLANGCHANGEREQUEST
 getMessageName = "WM_INPUTLANGCHANGEREQUEST"
Case WM_INPUTLANGCHANGE
 getMessageName = "WM_INPUTLANGCHANGE"
Case WM_TCARD
 getMessageName = "WM_TCARD"
Case WM_HELP
 getMessageName = "WM_HELP"
Case WM_USERCHANGED
 getMessageName = "WM_USERCHANGED"
Case WM_NOTIFYFORMAT
 getMessageName = "WM_NOTIFYFORMAT"
Case WM_CONTEXTMENU
 getMessageName = "WM_CONTEXTMENU"
Case WM_STYLECHANGING
 getMessageName = "WM_STYLECHANGING"
Case WM_STYLECHANGED
 getMessageName = "WM_STYLECHANGED"
Case WM_DISPLAYCHANGE
 getMessageName = "WM_DISPLAYCHANGE"
Case WM_GETICON
 getMessageName = "WM_GETICON"
Case WM_SETICON
 getMessageName = "WM_SETICON"
Case WM_NCCREATE
 getMessageName = "WM_NCCREATE"
Case WM_NCDESTROY
 getMessageName = "WM_NCDESTROY"
Case WM_NCCALCSIZE
 getMessageName = "WM_NCCALCSIZE"
Case WM_NCHITTEST
 getMessageName = "WM_NCHITTEST"
Case WM_NCPAINT
 getMessageName = "WM_NCPAINT"
Case WM_NCACTIVATE
 getMessageName = "WM_NCACTIVATE"
Case WM_GETDLGCODE
 getMessageName = "WM_GETDLGCODE"
Case WM_SYNCPAINT
 getMessageName = "WM_SYNCPAINT"
Case WM_NCMOUSEMOVE
 getMessageName = "WM_NCMOUSEMOVE"
Case WM_NCLBUTTONDOWN
 getMessageName = "WM_NCLBUTTONDOWN"
Case WM_NCLBUTTONUP
 getMessageName = "WM_NCLBUTTONUP"
Case WM_NCLBUTTONDBLCLK
 getMessageName = "WM_NCLBUTTONDBLCLK"
Case WM_NCRBUTTONDOWN
 getMessageName = "WM_NCRBUTTONDOWN"
Case WM_NCRBUTTONUP
 getMessageName = "WM_NCRBUTTONUP"
Case WM_NCRBUTTONDBLCLK
 getMessageName = "WM_NCRBUTTONDBLCLK"
Case WM_NCMBUTTONDOWN
 getMessageName = "WM_NCMBUTTONDOWN"
Case WM_NCMBUTTONUP
 getMessageName = "WM_NCMBUTTONUP"
Case WM_NCMBUTTONDBLCLK
 getMessageName = "WM_NCMBUTTONDBLCLK"
Case WM_KEYFIRST
 getMessageName = "WM_KEYFIRST"
Case WM_KEYDOWN
 getMessageName = "WM_KEYDOWN"
Case WM_KEYUP
 getMessageName = "WM_KEYUP"
Case WM_CHAR
 getMessageName = "WM_CHAR"
Case WM_DEADCHAR
 getMessageName = "WM_DEADCHAR"
Case WM_SYSKEYDOWN
 getMessageName = "WM_SYSKEYDOWN"
Case WM_SYSKEYUP
 getMessageName = "WM_SYSKEYUP"
Case WM_SYSCHAR
 getMessageName = "WM_SYSCHAR"
Case WM_SYSDEADCHAR
 getMessageName = "WM_SYSDEADCHAR"
Case WM_KEYLAST
 getMessageName = "WM_KEYLAST"
Case WM_IME_STARTCOMPOSITION
 getMessageName = "WM_IME_STARTCOMPOSITION"
Case WM_IME_ENDCOMPOSITION
 getMessageName = "WM_IME_ENDCOMPOSITION"
Case WM_IME_COMPOSITION
 getMessageName = "WM_IME_COMPOSITION"
Case WM_INITDIALOG
 getMessageName = "WM_INITDIALOG"
Case WM_COMMAND
 getMessageName = "WM_COMMAND"
Case WM_SYSCOMMAND
 getMessageName = "WM_SYSCOMMAND"
Case WM_TIMER
 getMessageName = "WM_TIMER"
Case WM_HSCROLL
 getMessageName = "WM_HSCROLL"
Case WM_VSCROLL
 getMessageName = "WM_VSCROLL"
Case WM_INITMENU
 getMessageName = "WM_INITMENU"
Case WM_INITMENUPOPUP
 getMessageName = "WM_INITMENUPOPUP"
Case WM_MENUSELECT
 getMessageName = "WM_MENUSELECT"
Case WM_MENUCHAR
 getMessageName = "WM_MENUCHAR"
Case WM_ENTERIDLE
 getMessageName = "WM_ENTERIDLE"
Case WM_MENURBUTTONUP
 getMessageName = "WM_MENURBUTTONUP"
Case WM_MENUDRAG
 getMessageName = "WM_MENUDRAG"
Case WM_MENUGETOBJECT
 getMessageName = "WM_MENUGETOBJECT"
Case WM_UNINITMENUPOPUP
 getMessageName = "WM_UNINITMENUPOPUP"
Case WM_MENUCOMMAND
 getMessageName = "WM_MENUCOMMAND"
Case WM_CTLCOLORMSGBOX
 getMessageName = "WM_CTLCOLORMSGBOX"
Case WM_CTLCOLOREDIT
 getMessageName = "WM_CTLCOLOREDIT"
Case WM_CTLCOLORLISTBOX
 getMessageName = "WM_CTLCOLORLISTBOX"
Case WM_CTLCOLORBTN
 getMessageName = "WM_CTLCOLORBTN"
Case WM_CTLCOLORDLG
 getMessageName = "WM_CTLCOLORDLG"
Case WM_CTLCOLORSCROLLBAR
 getMessageName = "WM_CTLCOLORSCROLLBAR"
Case WM_CTLCOLORSTATIC
 getMessageName = "WM_CTLCOLORSTATIC"
Case WM_MOUSEMOVE
 getMessageName = "WM_MOUSEMOVE"
Case WM_LBUTTONDOWN
 getMessageName = "WM_LBUTTONDOWN"
Case WM_LBUTTONUP
 getMessageName = "WM_LBUTTONUP"
Case WM_LBUTTONDBLCLK
 getMessageName = "WM_LBUTTONDBLCLK"
Case WM_RBUTTONDOWN
 getMessageName = "WM_RBUTTONDOWN"
Case WM_RBUTTONUP
 getMessageName = "WM_RBUTTONUP"
Case WM_RBUTTONDBLCLK
 getMessageName = "WM_RBUTTONDBLCLK"
Case WM_MBUTTONDOWN
 getMessageName = "WM_MBUTTONDOWN"
Case WM_MBUTTONUP
 getMessageName = "WM_MBUTTONUP"
Case WM_MBUTTONDBLCLK
 getMessageName = "WM_MBUTTONDBLCLK"
Case WM_MOUSELAST
 getMessageName = "WM_MOUSELAST"
Case WM_PARENTNOTIFY
 getMessageName = "WM_PARENTNOTIFY"
Case WM_ENTERMENULOOP
 getMessageName = "WM_ENTERMENULOOP"
Case WM_EXITMENULOOP
 getMessageName = "WM_EXITMENULOOP"
Case WM_NEXTMENU
 getMessageName = "WM_NEXTMENU"
Case WM_SIZING
 getMessageName = "WM_SIZING"
Case WM_CAPTURECHANGED
 getMessageName = "WM_CAPTURECHANGED"
Case WM_MOVING
 getMessageName = "WM_MOVING"
Case WM_POWERBROADCAST
 getMessageName = "WM_POWERBROADCAST"
Case WM_DEVICECHANGE
 getMessageName = "WM_DEVICECHANGE"
Case WM_MDICREATE
 getMessageName = "WM_MDICREATE"
Case WM_MDIDESTROY
 getMessageName = "WM_MDIDESTROY"
Case WM_MDIACTIVATE
 getMessageName = "WM_MDIACTIVATE"
Case WM_MDIRESTORE
 getMessageName = "WM_MDIRESTORE"
Case WM_MDINEXT
 getMessageName = "WM_MDINEXT"
Case WM_MDIMAXIMIZE
 getMessageName = "WM_MDIMAXIMIZE"
Case WM_MDITILE
 getMessageName = "WM_MDITILE"
Case WM_MDICASCADE
 getMessageName = "WM_MDICASCADE"
Case WM_MDIICONARRANGE
 getMessageName = "WM_MDIICONARRANGE"
Case WM_MDIGETACTIVE
 getMessageName = "WM_MDIGETACTIVE"
Case WM_MDISETMENU
 getMessageName = "WM_MDISETMENU"
Case WM_ENTERSIZEMOVE
 getMessageName = "WM_ENTERSIZEMOVE"
Case WM_EXITSIZEMOVE
 getMessageName = "WM_EXITSIZEMOVE"
Case WM_DROPFILES
 getMessageName = "WM_DROPFILES"
Case WM_MDIREFRESHMENU
 getMessageName = "WM_MDIREFRESHMENU"
Case WM_IME_SETCONTEXT
 getMessageName = "WM_IME_SETCONTEXT"
Case WM_IME_NOTIFY
 getMessageName = "WM_IME_NOTIFY"
Case WM_IME_CONTROL
 getMessageName = "WM_IME_CONTROL"
Case WM_IME_COMPOSITIONFULL
 getMessageName = "WM_IME_COMPOSITIONFULL"
Case WM_IME_SELECT
 getMessageName = "WM_IME_SELECT"
Case WM_IME_CHAR
 getMessageName = "WM_IME_CHAR"
Case WM_IME_REQUEST
 getMessageName = "WM_IME_REQUEST"
Case WM_IME_KEYDOWN
 getMessageName = "WM_IME_KEYDOWN"
Case WM_IME_KEYUP
 getMessageName = "WM_IME_KEYUP"
Case WM_MOUSEHOVER
 getMessageName = "WM_MOUSEHOVER"
Case WM_MOUSELEAVE
 getMessageName = "WM_MOUSELEAVE"
Case WM_CUT
 getMessageName = "WM_CUT"
Case WM_COPY
 getMessageName = "WM_COPY"
Case WM_PASTE
 getMessageName = "WM_PASTE"
Case WM_CLEAR
 getMessageName = "WM_CLEAR"
Case WM_UNDO
 getMessageName = "WM_UNDO"
Case WM_RENDERFORMAT
 getMessageName = "WM_RENDERFORMAT"
Case WM_RENDERALLFORMATS
 getMessageName = "WM_RENDERALLFORMATS"
Case WM_DESTROYCLIPBOARD
 getMessageName = "WM_DESTROYCLIPBOARD"
Case WM_DRAWCLIPBOARD
 getMessageName = "WM_DRAWCLIPBOARD"
Case WM_PAINTCLIPBOARD
 getMessageName = "WM_PAINTCLIPBOARD"
Case WM_VSCROLLCLIPBOARD
 getMessageName = "WM_VSCROLLCLIPBOARD"
Case WM_SIZECLIPBOARD
 getMessageName = "WM_SIZECLIPBOARD"
Case WM_ASKCBFORMATNAME
 getMessageName = "WM_ASKCBFORMATNAME"
Case WM_CHANGECBCHAIN
 getMessageName = "WM_CHANGECBCHAIN"
Case WM_HSCROLLCLIPBOARD
 getMessageName = "WM_HSCROLLCLIPBOARD"
Case WM_QUERYNEWPALETTE
 getMessageName = "WM_QUERYNEWPALETTE"
Case WM_PALETTEISCHANGING
 getMessageName = "WM_PALETTEISCHANGING"
Case WM_PALETTECHANGED
 getMessageName = "WM_PALETTECHANGED"
Case WM_HOTKEY
 getMessageName = "WM_HOTKEY"
Case WM_PRINT
 getMessageName = "WM_PRINT"
Case WM_PRINTCLIENT
 getMessageName = "WM_PRINTCLIENT"
Case WM_HANDHELDFIRST
 getMessageName = "WM_HANDHELDFIRST"
Case WM_HANDHELDLAST
 getMessageName = "WM_HANDHELDLAST"
Case WM_AFXFIRST
 getMessageName = "WM_AFXFIRST"
Case WM_AFXLAST
 getMessageName = "WM_AFXLAST"
Case WM_PENWINFIRST
 getMessageName = "WM_PENWINFIRST"
Case WM_PENWINLAST
 getMessageName = "WM_PENWINLAST"
Case WM_APP
 getMessageName = "WM_APP"

Case Else
 getMessageName = toHex(msgVal)
End Select
End Function

Public Sub setHook(ByVal hwnd As Long)
gHW = hwnd
lpPrevWndProc = SetWindowLong(gHW, GWL_WNDPROC, AddressOf WindowProc)
End Sub

Public Sub UnHook()
Dim lngReturnValue As Long

lngReturnValue = SetWindowLong(gHW, GWL_WNDPROC, lpPrevWndProc)
End Sub

Function WindowProc( _
ByVal hw As Long, _
ByVal uMsg As Long, _
ByVal wParam As Long, _
ByVal lParam As Long _
) As Long
Static cnt As Long

'Select Case uMsg
 'Case WM_ERASEBKGND
 ' Debug.Print "WM_ERASEBKGND " & cnt
 ' cnt = cnt + 1
 'Case Else
 ' WindowProc = CallWindowProc(lpPrevWndProc, hw, uMsg, wParam, lParam)
'End Select

Debug.Print cnt & " - "; getMessageName(uMsg)
cnt = cnt + 1
WindowProc = CallWindowProc(lpPrevWndProc, hw, uMsg, wParam, lParam)
End Function

Public Function toHex(ByVal v As Long) As String
Dim s As String, i As Integer

s = Hex(v)
i = 4 - Len(s)
While i > 0
 s = "0" & s
 i = i - 1
Wend

toHex = "0x" & s
End Function

Function mouseWeelProc( _
ByVal hw As Long, _
ByVal uMsg As Long, _
ByVal wParam As Long, _
ByVal lParam As Long _
) As Long
'Static cnt As Long
Dim rot As Long
Dim frm As clsMouseWeel

On Error GoTo errHandler
Set frm = mWeel.Item(str(hw))

Select Case uMsg
 Case WM_MOUSEWHEEL
  rot = wParam / 65536
  'Debug.Print "WM_MOUSEWHEEL " & cnt & " rot " & rot
  'cnt = cnt + 1
  frm.MouseWeel rot / 120
End Select

mouseWeelProc = CallWindowProc(frm.prevWndProc, frm.hwnd, uMsg, wParam, lParam)
Exit Function

errHandler:
On Error GoTo 0
End Function

Public Sub mouseWeelHook(frm As clsMouseWeel)
frm.prevWndProc = SetWindowLong(frm.hwnd, GWL_WNDPROC, AddressOf mouseWeelProc)
mWeel.Add frm, str(frm.hwnd)
End Sub

Public Sub mouseWeelUnHook(frm As clsMouseWeel)
SetWindowLong frm.hwnd, GWL_WNDPROC, frm.prevWndProc
mWeel.Remove str(frm.hwnd)
End Sub

Private Function EnumKrotWindows(ByVal hwnd As Long, ByVal lParam As Long) As Long
    'Dim lngReturn           As Long                     ' Return Value variable
    'Dim strWindowName       As String * 256             ' Holds the window caption (256 Characters max)
    Dim blnIsVisible        As Boolean                  ' [Flag] Determines if a window is visible or not
    'Dim winTitle As String
    
    blnIsVisible = IsWindowVisible(hwnd)
    If blnIsVisible = True Then PostMessage hwnd, WM_KRT_EXTZOOM, 0, 0
    
    ' Check if the window is visible
    'blnIsVisible = IsWindowVisible(hwnd)
    ' If it is then get the other information needed
    ' (Class Name & Window Caption)
    'If blnIsVisible = True Then
        'lngReturn = GetWindowText(hwnd, strWindowName, 256)
        'If lngReturn Then
        '    winTitle = Left$(strWindowName, lngReturn)
        '    'Log hookLogFile, winTitle
        '    If frmMain.Caption = winTitle Then
        '      'Log hookLogFile, "KrotWindow " & hwnd
        '      PostMessage hwnd, WM_KRT_EXTZOOM, 0, 0
        '    End If
        'End If
    'End If
    ' Continue the Enumeration
    EnumKrotWindows = True
End Function

Public Sub krotMessage(msg As String)
'Log hookLogFile, "send krotMessage: " & msg & " from frmMain.hWnd: " & frmMain.hwnd
Clipboard.SetText msg
Call EnumWindows(AddressOf EnumKrotWindows, ByVal 0&)
'Log hookLogFile, "send krotMessage done"
End Sub

Function mainFormProc( _
ByVal hw As Long, _
ByVal uMsg As Long, _
ByVal wParam As Long, _
ByVal lParam As Long _
) As Long

On Error GoTo errHandler

Select Case uMsg
 Case WM_KRT_EXTZOOM
   'Log hookLogFile, "recieve krotMessage frmMain.hwnd: " & frmMain.hwnd
   frmMain.krotZoomMessage = Clipboard.GetText
   frmMain.Timer1.Interval = 10
End Select

mainFormProc = CallWindowProc(prevMainWndProc, frmMain.hwnd, uMsg, wParam, lParam)
Exit Function

errHandler:
On Error GoTo 0
End Function

Public Sub mainFormHook()
'Log hookLogFile, "Hook frmMain.hwnd: " & frmMain.hwnd
prevMainWndProc = SetWindowLong(frmMain.hwnd, GWL_WNDPROC, AddressOf mainFormProc)
End Sub

Public Sub mainFormUnHook()
'Log hookLogFile, "UnHook frmMain.hwnd: " & frmMain.hwnd
SetWindowLong frmMain.hwnd, GWL_WNDPROC, prevMainWndProc
End Sub

