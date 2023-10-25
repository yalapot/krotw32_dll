VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsObjType"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private d_id As OBJ_TYPE
Private d_off As Boolean
Private d_name As String
Private d_tbl As String
Private d_enbl As Boolean

Public Sub Init( _
ByVal id As OBJ_TYPE, _
ByVal name As String, _
ByVal off As Boolean, _
ByVal tbl As String _
)
d_id = id
d_off = off
d_name = name
d_tbl = tbl
d_enbl = True
End Sub

Property Get isLength() As Boolean
Select Case Me.tbl
 Case OBJ_TBL_DFKT, OBJ_TBL_WELD, OBJ_TBL_TURN, OBJ_TBL_NONE
  isLength = True
 Case Else
  isLength = False
End Select
End Property

Property Get isDepth() As Boolean
isDepth = False

If Me.tbl = OBJ_TBL_DFKT Then
 isDepth = True
 Select Case Me.id
  Case OBJ_privarka, OBJ_bad_styk, OBJ_zavarka, OBJ_prileganie
   isDepth = False
 End Select
End If
End Property

Property Get isLengthEditable() As Boolean
Select Case Me.tbl
 Case OBJ_TBL_WELD
  isLengthEditable = False
 Case Else
  isLengthEditable = Me.isLength
End Select
End Property

Property Get off() As Boolean
off = d_off
End Property

Property Get id() As OBJ_TYPE
id = d_id
End Property

Property Get name() As String
name = d_name
End Property

Property Get tbl() As String
tbl = d_tbl
End Property

Private Function getPicture(ByVal t As OBJ_TYPE) As Integer
Select Case t
 
 Case OBJ_anomal
  getPicture = BMP_anomal
 Case OBJ_crack
  getPicture = BMP_crack
 Case OBJ_cracks
  getPicture = BMP_cracks
 Case OBJ_privarka
  getPicture = BMP_privarka
 Case OBJ_mehan
  getPicture = BMP_mehan
 Case OBJ_stress
  getPicture = BMP_stress
 Case OBJ_defekt
  getPicture = BMP_defekt
 Case OBJ_vmyat
  getPicture = BMP_vmyat
 Case OBJ_oval
  getPicture = BMP_oval
 Case OBJ_bad_styk
  getPicture = BMP_bad_styk
 Case OBJ_zavarka
  getPicture = BMP_zavarka
 Case OBJ_prileganie
  getPicture = BMP_prileganie
 Case OBJ_tehokno
  getPicture = BMP_tehokno
 Case OBJ_gofra
  getPicture = BMP_gofra
 Case OBJ_FLANGE
  getPicture = BMP_flange
 Case OBJ_IZOL_STYK
  getPicture = BMP_izostyk
 Case OBJ_runplace
  getPicture = BMP_runplace
 Case OBJ_getplace
  getPicture = BMP_getplace
 Case OBJ_kran
  getPicture = BMP_kran
 Case OBJ_marktime
  getPicture = BMP_marktime
 Case OBJ_otvod
  getPicture = BMP_otvod
 Case OBJ_patron_in
  getPicture = BMP_patron_in
 Case OBJ_patron_out
  getPicture = BMP_patron_out
 Case OBJ_troynik
  getPicture = BMP_troynik
 Case OBJ_looping_in
  getPicture = BMP_looping_in
 Case OBJ_looping_out
  getPicture = BMP_looping_out
 Case OBJ_thick
  getPicture = BMP_thick
 Case OBJ_category
  getPicture = BMP_category
 Case OBJ_startprgrz
  getPicture = BMP_startprgrz
 Case OBJ_endprgrz
  getPicture = BMP_endprgrz
 Case OBJ_prigruz
  getPicture = BMP_prigruz
 Case OBJ_povorot
  getPicture = BMP_povorot
 Case OBJ_waterin
  getPicture = BMP_waterIn
 Case OBJ_waterout
  getPicture = BMP_waterOut
 Case OBJ_vog
  getPicture = BMP_vog
 Case OBJ_shov_p
  getPicture = BMP_shov_p
 Case OBJ_shov_s
  getPicture = BMP_shov_s
 Case OBJ_shov_b
  getPicture = BMP_shov_b
 Case OBJ_neopr_sektsiya
  getPicture = BMP_shov_n
 Case OBJ_tubekran
  getPicture = BMP_shov_kran
 Case OBJ_tubetroynik
  getPicture = BMP_shov_troynik
 Case OBJ_crzgroup
  getPicture = BMP_crzgroup
 Case OBJ_kanavHor
  getPicture = BMP_kanavHor
 Case OBJ_kanavVer
  getPicture = BMP_kanavVer
 Case OBJ_defect_prokata
  getPicture = BMP_defect_prokata
 Case OBJ_FLANGE
  getPicture = BMP_flange
 Case OBJ_IZOL_STYK
  getPicture = BMP_izostyk
 Case OBJ_HOMUT
  getPicture = BMP_homut
 Case OBJ_REM_NAKLADKA
  getPicture = BMP_zaplat1
 Case OBJ_REM_NAKLADKA_DFKT
  getPicture = BMP_zaplat1
 Case OBJ_MARKER_MAGN
  getPicture = BMP_marker
 Case OBJ_VMYAT_S_DEF_POTERI_MET
  getPicture = BMP_vmyat_m
 Case OBJ_POTERYA_MET
  getPicture = BMP_defekt
 Case OBJ_MARKERN_KOLTSO
  getPicture = BMP_025
 Case OBJ_ANOM_OBLICOVKI_SHVA
  getPicture = BMP_200
 Case OBJ_ANOM_PROD_SHVA
  getPicture = BMP_207
 Case OBJ_ANOM_SPIR_SHVA
  getPicture = BMP_208
 Case OBJ_VNUTRISTENN_RASSOENIE
  getPicture = BMP_210
 Case OBJ_dvuhshovn
  getPicture = BMP_195
 Case OBJ_ZAVARKA_BOBYSHKI
  getPicture = BMP_027
 Case OBJ_ZAVARKA_OTVERSTIYA
  getPicture = BMP_221
 Case OBJ_ZAVARKA_PROD_SHVA
  getPicture = BMP_234
 Case OBJ_ZASHLIFOVKA
  getPicture = BMP_216
 Case OBJ_ZASHLOFOVKA_PRODOLN_SHVA
  getPicture = BMP_225
 Case OBJ_ZONE_VERT_CRACK
  getPicture = BMP_236
 Case OBJ_KORR_NA_KOLTSEV_SHVE
  getPicture = BMP_201
 Case OBJ_mufta_nach
  getPicture = BMP_164
 Case OBJ_mufta_kon
  getPicture = BMP_165
 Case OBJ_VISHLIV_PRODOLN_SHVA
  getPicture = BMP_227
 Case OBJ_VISHLIV_SPIRAL_SHVA
  getPicture = BMP_229
 Case OBJ_met_mufta_nach
  getPicture = BMP_166
 Case OBJ_met_mufta_kon
  getPicture = BMP_167
 Case OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_KON
  getPicture = BMP_211
 Case OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_NACH
  getPicture = BMP_212
 Case OBJ_FORM_PRODOLN_SHVA
  getPicture = BMP_228
 Case OBJ_FORM_SPIRAL_SHVA
  getPicture = BMP_230
 Case OBJ_NEDOPUSTIM_KONSTR_ELEM
  getPicture = BMP_034
 Case OBJ_NEPROVAR_UTYAZHINA
  getPicture = BMP_202
 Case OBJ_NERASPOZN_OBJ
  getPicture = BMP_031
 Case OBJ_NESVAREN_STYK_PATRONA
  getPicture = BMP_213
 Case OBJ_NESPLOSHNOST_PLOSKOSTN_TIPA
  getPicture = BMP_223
 Case OBJ_odoshovn
  getPicture = BMP_194
 Case OBJ_OTREM_UCH
  getPicture = BMP_029
 Case OBJ_PODZHIG
  getPicture = BMP_219
 Case OBJ_PODKLADN_KOLTSO
  getPicture = BMP_206
 Case OBJ_PODREZ
  getPicture = BMP_203
 Case OBJ_POPERECHN_TRESCHINA
  getPicture = BMP_224
 Case OBJ_POTERYA_KONT_S_TRUBOY
  getPicture = BMP_215
 Case OBJ_PRAVKA_KROMOK
  getPicture = BMP_205
 Case OBJ_PROVIS_KORNYA_SHVA
  getPicture = BMP_226
 Case OBJ_RASSLOEN_S_VYHODOM_NA_POVERHN
  getPicture = BMP_220
 Case OBJ_SMEWENIE_KROMOK
  getPicture = BMP_204
 Case OBJ_TEHNDEFEKT
  getPicture = BMP_231
 Case OBJ_TOCHECHN_KORR
  getPicture = BMP_218
 Case OBJ_TRESCHINA_NA_KOLTSEV_SHVE
  getPicture = BMP_222
 Case OBJ_CRACK_PRODOLN_SHVA
  getPicture = BMP_232
 Case OBJ_CRACK_SPIRAL_SHVA
  getPicture = BMP_233
 Case OBJ_TRUBN_ARMATURA
  getPicture = BMP_032
 Case OBJ_ELEM_OBUSTROISTVA
  getPicture = BMP_033
 Case OBJ_EKSTSENTRICHNIY_PATRON
  getPicture = BMP_214
 Case OBJ_PATRON_MALOY_DLINY
  getPicture = BMP_022
 Case OBJ_ZADVIZHKA
  getPicture = BMP_zadvijka
 Case OBJ_marker
  getPicture = BMP_marker1
 Case OBJ_diststart
  getPicture = BMP_ND_start
 Case OBJ_distend
  getPicture = BMP_ND_end
  
 Case Else
  getPicture = BMP_defekt
End Select

End Function

Public Function ObjPicture(ByVal t As OBJ_TYPE) As Integer
ObjPicture = getPicture(t)
End Function

Property Get Picture() As Integer
Picture = getPicture(d_id)
End Property

Property Get enabled() As Boolean
enabled = d_enbl
End Property

Property Let enabled(e As Boolean)
d_enbl = e
End Property

Public Function isTubeBorder(ByVal code As OBJ_TYPE) As Boolean
Select Case code
 Case OBJ_shov_p, OBJ_shov_s, OBJ_shov_b
 isTubeBorder = True
 Case Else
 isTubeBorder = False
End Select
End Function
