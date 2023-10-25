Attribute VB_Name = "krtVersions"
Option Explicit

#If AppVerRestricted Then
Global Const appVersionRestricted = True
#Else
Global Const appVersionRestricted = False
#End If

#If AppVerIran Then
Global Const appVersionIran = True
#Else
Global Const appVersionIran = False
#End If

#If AppVerViewer Then
Global Const appVersionViewer = True
#Else
Global Const appVersionViewer = False
#End If


