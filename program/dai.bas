Attribute VB_Name = "dai"
Option Explicit

Public Const DAI_EXPLAIN_TEXT_MAX_LENGTH = 4096
Public Const DAI_QUEST_ERROR = -1

Public Type DAI_INFO
 internal As Long      ' 0 - наружный дефект или 1 - внутренний
 wallThickness As Long ' толщина стенки трубы в мм
 x1 As Long            ' номер колонки левого верхнего угла области
 y1 As Long            ' номер строки левого верхнего угла области
 x2 As Long            ' номер колонки правого нижнего угла области
 y2 As Long            ' номер строки правого нижнего угла области
End Type

'структура для передачи из VB информации о характеристиках лупы для DAI
Public Type VB_DAI_INFO
 orntStart As Long     'положение первой строки массива данных по окружности трубы в градусах (1-360)
 orntLen As Long       'размер сектора по окружности трубы в градусах (1-360) занимаемый анализируемым фрагментом
 itemX As Long         'протяженность элемента массива данных вдоль трубы в мм. (шаг опроса снаряда)
 itemY As Long         'протяженность элемента массива данных по окружности трубы в мм. (расстояние между датчиками)
End Type

Public Declare Function krotDai Lib "krotw32.dll" ( _
 ByVal handle As Long, _
 ByVal crzIndx As Long, _
 ByRef udai As DAI_INFO, _
 ByRef daiInfo As VB_DAI_INFO, _
 ByVal lpReturnedString As String, _
 ByVal informUser As Long _
) As Integer

Global frmZoomDAI As frmZoom
