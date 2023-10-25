Attribute VB_Name = "Export"
Option Explicit

Public Enum OBJ_TYPE
OBJ_gofra = 4
OBJ_anomal = 5
OBJ_crack = 6
OBJ_crzgroup = 7
OBJ_kanavHor = 8
OBJ_kanavVer = 9
OBJ_defekt = 10
OBJ_privarka = 11
OBJ_mehan = 12
OBJ_stress = 13
OBJ_cracks = 14
OBJ_vmyat = 15
OBJ_oval = 16
OBJ_bad_styk = 17
OBJ_zavarka = 18
OBJ_prileganie = 19
OBJ_tehokno = 20
OBJ_runplace = 30
OBJ_getplace = 40
OBJ_kran = 70
OBJ_marker = 80
OBJ_marktime = 81
OBJ_otvod = 120
OBJ_patron_in = 130
OBJ_patron_out = 131
OBJ_troynik = 132
OBJ_looping_in = 133
OBJ_looping_out = 134
OBJ_thick = 140
OBJ_category = 141
OBJ_startprgrz = 110
OBJ_endprgrz = 60
OBJ_prigruz = 170
OBJ_povorot = 160
OBJ_waterin = 161
OBJ_waterout = 162
OBJ_defect_prokata = 163
OBJ_mufta_nach = 164
OBJ_mufta_kon = 165
OBJ_met_mufta_nach = 166
OBJ_met_mufta_kon = 167

OBJ_vog = 180
OBJ_shov_p = 190
OBJ_shov_s = 191
OBJ_shov_b = 192
OBJ_neopr_sektsiya = 193
OBJ_odoshovn = 194
OBJ_dvuhshovn = 195
OBJ_tubekran = 196
OBJ_tubetroynik = 197

OBJ_diststart = 300
OBJ_distend = 301

OBJ_IZOL_STYK = 21
OBJ_PATRON_MALOY_DLINY = 22
OBJ_HOMUT = 23
OBJ_ZADVIZHKA = 24
OBJ_MARKERN_KOLTSO = 25
OBJ_MARKER_MAGN = 26
OBJ_ZAVARKA_BOBYSHKI = 27
OBJ_REM_NAKLADKA = 28
OBJ_OTREM_UCH = 29
OBJ_NERASPOZN_OBJ = 31
OBJ_TRUBN_ARMATURA = 32
OBJ_ELEM_OBUSTROISTVA = 33
OBJ_NEDOPUSTIM_KONSTR_ELEM = 34
OBJ_FLANGE = 35

OBJ_ANOM_OBLICOVKI_SHVA = 200
OBJ_KORR_NA_KOLTSEV_SHVE = 201
OBJ_NEPROVAR_UTYAZHINA = 202
OBJ_PODREZ = 203
OBJ_SMEWENIE_KROMOK = 204
OBJ_PRAVKA_KROMOK = 205
OBJ_PODKLADN_KOLTSO = 206
OBJ_ANOM_PROD_SHVA = 207
OBJ_ANOM_SPIR_SHVA = 208
OBJ_VMYAT_S_DEF_POTERI_MET = 209
OBJ_VNUTRISTENN_RASSOENIE = 210
OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_KON = 211
OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_NACH = 212
OBJ_NESVAREN_STYK_PATRONA = 213
OBJ_EKSTSENTRICHNIY_PATRON = 214
OBJ_POTERYA_KONT_S_TRUBOY = 215
OBJ_ZASHLIFOVKA = 216
OBJ_POTERYA_MET = 217
OBJ_TOCHECHN_KORR = 218
OBJ_PODZHIG = 219
OBJ_RASSLOEN_S_VYHODOM_NA_POVERHN = 220
OBJ_ZAVARKA_OTVERSTIYA = 221
OBJ_TRESCHINA_NA_KOLTSEV_SHVE = 222
OBJ_NESPLOSHNOST_PLOSKOSTN_TIPA = 223
OBJ_POPERECHN_TRESCHINA = 224
OBJ_ZASHLOFOVKA_PRODOLN_SHVA = 225
OBJ_PROVIS_KORNYA_SHVA = 226
OBJ_VISHLIV_PRODOLN_SHVA = 227
OBJ_FORM_PRODOLN_SHVA = 228
OBJ_VISHLIV_SPIRAL_SHVA = 229
OBJ_FORM_SPIRAL_SHVA = 230
OBJ_TEHNDEFEKT = 231
OBJ_CRACK_PRODOLN_SHVA = 232
OBJ_CRACK_SPIRAL_SHVA = 233
OBJ_ZAVARKA_PROD_SHVA = 234
OBJ_KOROZ = 235
OBJ_ZONE_VERT_CRACK = 236
OBJ_REM_NAKLADKA_DFKT = 237

OBJ_startspr_ = 100
OBJ_endsprl_ = 50

End Enum

Public Enum EN_INT_TYPE
    IT_EXT = 0 'внешняя аномалия
    IT_INT = 1 'внутренняя аномалия
    IT_MID = 2 'внитристенная аномалия
    IT_NA = 3 'положение не определено
End Enum

Public Enum EN_EXP_TYPE
    ET_WELD = 0
    ET_LINEOBJ = 1
    ET_DEFECT = 2
    ET_PRIGRUZ = 3
    ET_SPEED = 4
    ET_THICK = 5
    ET_VOG_POVOROT = 6
    ET_CRCT_TABLE = 7
    ET_VOG_CSV = 8
    ET_WELD_EXTENDED = 9
    ET_CATEGORY = 10
    ET_MAGNETS = 11
End Enum

Public Enum EN_TR_WELD_TYPE
    WT_NORMAL = 0
    WT_SPIRAL = 1
    WT_NOSLIT = 2
    WT_NEOPR_SEKTSIYA = 3
    WT_ODNOSHOVN = 4
    WT_DVUHSHOVN = 5
    WT_KRAN = 6
    WT_TROYNIK = 7
End Enum

Public Enum EN_TR_POVOROT_TYPE
    PT_TECH = 0
    PT_NON_TECH = 1
    PT_DEFEKT = 2
    PT_HOLOD = 3
    PT_KRUTO = 4
    PT_SEGM = 5
    PT_UPRUGO = 6
End Enum

Public Enum EN_TR_LINEOBJ_TYPE
    LT_OPERATOR = 0
    LT_KRAN = 1
    LT_MARKER = 2
    LT_OTVOD = 3
    LT_TEHOKNO = 5
    LT_PATRON_VHOD = 6
    LT_PATRON_VIHOD = 7
    LT_TROYNIK = 10
    LT_LUPING_VHOD = 12
    LT_LUPING_VIHOD = 13
    LT_SEGM_POVOROT_START = 14
    LT_SEGM_POVOROT_END = 15
    LT_KZ = 16
    LT_KP = 17
    LT_STARTDIST = 18
    LT_ENDTDIST = 19
    LT_WATERIN = 21
    LT_WATEROUT = 22
    LT_FLANGE = 23
    LT_MUFTA_NACH = 24
    LT_MUFTA_KON = 25
    LT_IZOL_STYK = 26
    LT_PATRON_MALOY_DLINY = 27
    LT_HOMUT = 28
    LT_ZADVIZHKA = 29
    LT_MARKERN_KOLTSO = 30
    LT_MARKER_MAGN = 31
    LT_ZAVARKA_BOBYSHKI = 32
    LT_REM_NAKLADKA = 33
    LT_OTREM_UCH = 34
    LT_NERASPOZN_OBJ = 35
    LT_TRUBN_ARMATURA = 36
    LT_ELEM_OBUSTROISTVA = 37
    LT_NEDOPUSTIM_KONSTR_ELEM = 38
    LT_MET_MUFTA_NACH = 39
    LT_MET_MUFTA_KON = 40
End Enum

Public Enum EN_TR_DEFECT_TYPE
    DT_ANOMAL = 0
    DT_VMYAT = 1
    DT_IZGIB = 2
    DT_OVAL = 3
    DT_PRILEG = 4
    DT_GOFRA = 5
    DT_CORROZ = 6
    DT_CORROZ_GROUP = 7
    DT_SHOV = 8
    DT_ZAVARKA = 10
    DT_SEGM_POVOROT = 11
    DT_TEHNDEFEKT = 12
    DT_STRESS_CORROZ = 13
    DT_CRACK = 14
    DT_MECH = 15
    DT_PRODOL_KANAV = 16
    DT_POPERECH_KANAV = 17
    DT_CRACKS = 18
    DT_PROKAT = 19
    DT_ANOM_OBLICOVKI_SHVA = 20
    DT_KORR_NA_KOLTSEV_SHVE = 21
    DT_NEPROVAR_UTYAZHINA = 22
    DT_PODREZ = 23
    DT_SMEWENIE_KROMOK = 24
    DT_PRAVKA_KROMOK = 25
    DT_PODKLADN_KOLTSO = 26
    DT_ANOM_PROD_SHVA = 27
    DT_ANOM_SPIR_SHVA = 28
    DT_VMYAT_S_DEF_POTERI_MET = 29
    DT_VNUTRISTENN_RASSOENIE = 30
    DT_NARUSHEN_ADGEZII_IZOL_TRUBY_KON = 31
    DT_NARUSHEN_ADGEZII_IZOL_TRUBY_NACH = 32
    DT_NESVAREN_STYK_PATRONA = 33
    DT_EKSTSENTRICHNIY_PATRON = 34
    DT_POTERYA_KONT_S_TRUBOY = 35
    DT_ZASHLIFOVKA = 36
    DT_POTERYA_MET = 37
    DT_TOCHECHN_KORR = 38
    DT_PODZHIG = 39
    DT_RASSLOEN_S_VYHODOM_NA_POVERHN = 40
    DT_ZAVARKA_OTVERSTIYA = 41
    DT_TRESCHINA_NA_KOLTSEV_SHVE = 43
    DT_NESPLOSHNOST_PLOSKOSTN_TIPA = 44
    DT_POPERECHN_TRESCHINA = 45
    DT_ZASHLOFOVKA_PRODOLN_SHVA = 46
    DT_PROVIS_KORNYA_SHVA = 47
    DT_VISHLIV_PRODOLN_SHVA = 48
    DT_FORM_PRODOLN_SHVA = 49
    DT_VISHLIV_SPIRAL_SHVA = 50
    DT_FORM_SPIRAL_SHVA = 51
    DT_PRIVARKA = 52
    DT_CRACK_PRODOLN_SHVA = 53
    DT_CRACK_SPIRAL_SHVA = 54
    DT_KOROZ = 56
    DT_ZONE_VERT_CRACK = 57
    DT_REM_NAKLADKA = 58
End Enum

Public Enum EN_TR_PRIGRUZ_TYPE
    PT_SINGLE = 0
    PT_START = 1
    PT_END = 2
End Enum

Public Function trDefektType(krType As OBJ_TYPE) As EN_TR_DEFECT_TYPE
Dim eType As EN_TR_DEFECT_TYPE

Select Case krType
    
    Case OBJ_anomal
        eType = DT_ANOMAL
    Case OBJ_defekt
        eType = DT_CORROZ
    Case OBJ_vmyat
        eType = DT_VMYAT
    Case OBJ_gofra
        eType = DT_GOFRA
    Case OBJ_oval
        eType = DT_OVAL
    Case OBJ_KOROZ
        eType = DT_KOROZ
    Case OBJ_ZONE_VERT_CRACK
        eType = DT_ZONE_VERT_CRACK
    Case OBJ_REM_NAKLADKA_DFKT
        eType = DT_REM_NAKLADKA
    Case OBJ_bad_styk
        eType = DT_SHOV
    Case OBJ_prileganie
        eType = DT_PRILEG
    Case OBJ_zavarka
        eType = DT_ZAVARKA
    Case OBJ_privarka
        eType = DT_PRIVARKA
    Case OBJ_mehan
        eType = DT_MECH
    Case OBJ_stress
        eType = DT_STRESS_CORROZ
    Case OBJ_crzgroup
        eType = DT_CORROZ_GROUP
    Case OBJ_kanavHor
        eType = DT_PRODOL_KANAV
    Case OBJ_kanavVer
        eType = DT_POPERECH_KANAV
    Case OBJ_crack
        eType = DT_CRACK
    Case OBJ_cracks
        eType = DT_CRACKS
    Case OBJ_defect_prokata
        eType = DT_PROKAT
    Case OBJ_ANOM_OBLICOVKI_SHVA
        eType = DT_ANOM_OBLICOVKI_SHVA
    Case OBJ_KORR_NA_KOLTSEV_SHVE
        eType = DT_KORR_NA_KOLTSEV_SHVE
    Case OBJ_NEPROVAR_UTYAZHINA
        eType = DT_NEPROVAR_UTYAZHINA
    Case OBJ_PODREZ
        eType = DT_PODREZ
    Case OBJ_SMEWENIE_KROMOK
        eType = DT_SMEWENIE_KROMOK
    Case OBJ_PRAVKA_KROMOK
        eType = DT_PRAVKA_KROMOK
    Case OBJ_PODKLADN_KOLTSO
        eType = DT_PODKLADN_KOLTSO
    Case OBJ_VISHLIV_PRODOLN_SHVA
        eType = DT_VISHLIV_PRODOLN_SHVA
    Case OBJ_ZASHLOFOVKA_PRODOLN_SHVA
        eType = DT_ZASHLOFOVKA_PRODOLN_SHVA
    Case OBJ_FORM_PRODOLN_SHVA
        eType = DT_FORM_PRODOLN_SHVA
    Case OBJ_ANOM_PROD_SHVA
        eType = DT_ANOM_PROD_SHVA
    Case OBJ_ZAVARKA_PROD_SHVA
        eType = DT_ZAVARKA
    Case OBJ_ANOM_SPIR_SHVA
        eType = DT_ANOM_SPIR_SHVA
    Case OBJ_VMYAT_S_DEF_POTERI_MET
        eType = DT_VMYAT_S_DEF_POTERI_MET
    Case OBJ_VNUTRISTENN_RASSOENIE
        eType = DT_VNUTRISTENN_RASSOENIE
    Case OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_KON
        eType = DT_NARUSHEN_ADGEZII_IZOL_TRUBY_KON
    Case OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_NACH
        eType = DT_NARUSHEN_ADGEZII_IZOL_TRUBY_NACH
    Case OBJ_NESVAREN_STYK_PATRONA
        eType = DT_NESVAREN_STYK_PATRONA
    Case OBJ_EKSTSENTRICHNIY_PATRON
        eType = DT_EKSTSENTRICHNIY_PATRON
    Case OBJ_POTERYA_KONT_S_TRUBOY
        eType = DT_POTERYA_KONT_S_TRUBOY
    Case OBJ_ZASHLIFOVKA
        eType = DT_ZASHLIFOVKA
    Case OBJ_POTERYA_MET
        eType = DT_POTERYA_MET
    Case OBJ_TOCHECHN_KORR
        eType = DT_TOCHECHN_KORR
    Case OBJ_PODZHIG
        eType = DT_PODZHIG
    Case OBJ_RASSLOEN_S_VYHODOM_NA_POVERHN
        eType = DT_RASSLOEN_S_VYHODOM_NA_POVERHN
    Case OBJ_ZAVARKA_OTVERSTIYA
        eType = DT_ZAVARKA_OTVERSTIYA
    Case OBJ_TRESCHINA_NA_KOLTSEV_SHVE
        eType = DT_TRESCHINA_NA_KOLTSEV_SHVE
    Case OBJ_NESPLOSHNOST_PLOSKOSTN_TIPA
        eType = DT_NESPLOSHNOST_PLOSKOSTN_TIPA
    Case OBJ_POPERECHN_TRESCHINA
        eType = DT_POPERECHN_TRESCHINA
    Case OBJ_ZASHLOFOVKA_PRODOLN_SHVA
        eType = DT_ZASHLOFOVKA_PRODOLN_SHVA
    Case OBJ_PROVIS_KORNYA_SHVA
        eType = DT_PROVIS_KORNYA_SHVA
    Case OBJ_VISHLIV_SPIRAL_SHVA
        eType = DT_VISHLIV_SPIRAL_SHVA
    Case OBJ_FORM_SPIRAL_SHVA
        eType = DT_FORM_SPIRAL_SHVA
    Case OBJ_TEHNDEFEKT
        eType = DT_TEHNDEFEKT
    Case OBJ_CRACK_PRODOLN_SHVA
        eType = DT_CRACK_PRODOLN_SHVA
    Case OBJ_CRACK_SPIRAL_SHVA
        eType = DT_CRACK_SPIRAL_SHVA
    
    Case Else
        eType = DT_ANOMAL

End Select

trDefektType = eType
End Function

Public Function krotObjType( _
ByVal expType As EN_EXP_TYPE, _
ByVal trType As EN_TR_DEFECT_TYPE _
) As OBJ_TYPE

Select Case expType

 Case ET_DEFECT
  Select Case trType
   Case DT_OVAL
   krotObjType = OBJ_oval
   Case DT_CORROZ_GROUP
   krotObjType = OBJ_crzgroup
   Case DT_PRODOL_KANAV
   krotObjType = OBJ_kanavHor
   Case DT_POPERECH_KANAV
   krotObjType = OBJ_kanavVer
   Case DT_ANOMAL
   krotObjType = OBJ_anomal
   Case DT_CORROZ
   krotObjType = OBJ_defekt
   Case DT_ZONE_VERT_CRACK
   krotObjType = OBJ_ZONE_VERT_CRACK
   Case DT_REM_NAKLADKA
   krotObjType = OBJ_REM_NAKLADKA_DFKT
   Case DT_KOROZ
   krotObjType = OBJ_KOROZ
   Case DT_VMYAT
   krotObjType = OBJ_vmyat
   Case DT_GOFRA
   krotObjType = OBJ_gofra
   Case DT_SHOV
   krotObjType = OBJ_bad_styk
   Case DT_PRILEG
   krotObjType = OBJ_prileganie
   Case DT_ZAVARKA
   krotObjType = OBJ_zavarka
   Case DT_PRIVARKA
   krotObjType = OBJ_privarka
   Case DT_MECH
   krotObjType = OBJ_mehan
   Case DT_STRESS_CORROZ
   krotObjType = OBJ_stress
   Case DT_CRACK
   krotObjType = OBJ_crack
   Case DT_CRACKS
   krotObjType = OBJ_cracks
   Case DT_PROKAT
   krotObjType = OBJ_defect_prokata
   Case DT_ANOM_OBLICOVKI_SHVA
   krotObjType = OBJ_ANOM_OBLICOVKI_SHVA
   Case DT_KORR_NA_KOLTSEV_SHVE
   krotObjType = OBJ_KORR_NA_KOLTSEV_SHVE
   Case DT_NEPROVAR_UTYAZHINA
   krotObjType = OBJ_NEPROVAR_UTYAZHINA
   Case DT_PODREZ
   krotObjType = OBJ_PODREZ
   Case DT_SMEWENIE_KROMOK
   krotObjType = OBJ_SMEWENIE_KROMOK
   Case DT_PRAVKA_KROMOK
   krotObjType = OBJ_PRAVKA_KROMOK
   Case DT_PODKLADN_KOLTSO
   krotObjType = OBJ_PODKLADN_KOLTSO
   Case DT_ANOM_PROD_SHVA
   krotObjType = OBJ_ANOM_PROD_SHVA
   Case DT_ANOM_SPIR_SHVA
   krotObjType = OBJ_ANOM_SPIR_SHVA
   Case DT_VMYAT_S_DEF_POTERI_MET
   krotObjType = OBJ_VMYAT_S_DEF_POTERI_MET
   Case DT_VNUTRISTENN_RASSOENIE
   krotObjType = OBJ_VNUTRISTENN_RASSOENIE
   Case DT_NARUSHEN_ADGEZII_IZOL_TRUBY_KON
   krotObjType = OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_KON
   Case DT_NARUSHEN_ADGEZII_IZOL_TRUBY_NACH
   krotObjType = OBJ_NARUSHEN_ADGEZII_IZOL_TRUBY_NACH
   Case DT_NESVAREN_STYK_PATRONA
   krotObjType = OBJ_NESVAREN_STYK_PATRONA
   Case DT_EKSTSENTRICHNIY_PATRON
   krotObjType = OBJ_EKSTSENTRICHNIY_PATRON
   Case DT_POTERYA_KONT_S_TRUBOY
   krotObjType = OBJ_POTERYA_KONT_S_TRUBOY
   Case DT_ZASHLIFOVKA
   krotObjType = OBJ_ZASHLIFOVKA
   Case DT_POTERYA_MET
   krotObjType = OBJ_POTERYA_MET
   Case DT_TOCHECHN_KORR
   krotObjType = OBJ_TOCHECHN_KORR
   Case DT_PODZHIG
   krotObjType = OBJ_PODZHIG
   Case DT_RASSLOEN_S_VYHODOM_NA_POVERHN
   krotObjType = OBJ_RASSLOEN_S_VYHODOM_NA_POVERHN
   Case DT_ZAVARKA_OTVERSTIYA
   krotObjType = OBJ_ZAVARKA_OTVERSTIYA
   Case DT_TRESCHINA_NA_KOLTSEV_SHVE
   krotObjType = OBJ_TRESCHINA_NA_KOLTSEV_SHVE
   Case DT_NESPLOSHNOST_PLOSKOSTN_TIPA
   krotObjType = OBJ_NESPLOSHNOST_PLOSKOSTN_TIPA
   Case DT_POPERECHN_TRESCHINA
   krotObjType = OBJ_POPERECHN_TRESCHINA
   Case DT_ZASHLOFOVKA_PRODOLN_SHVA
   krotObjType = OBJ_ZASHLOFOVKA_PRODOLN_SHVA
   
   
   Case DT_PROVIS_KORNYA_SHVA
   krotObjType = OBJ_PROVIS_KORNYA_SHVA
   Case DT_VISHLIV_PRODOLN_SHVA
   krotObjType = OBJ_VISHLIV_PRODOLN_SHVA
   Case DT_FORM_PRODOLN_SHVA
   krotObjType = OBJ_FORM_PRODOLN_SHVA
   Case DT_VISHLIV_SPIRAL_SHVA
   krotObjType = OBJ_VISHLIV_SPIRAL_SHVA
   Case DT_FORM_SPIRAL_SHVA
   krotObjType = OBJ_FORM_SPIRAL_SHVA
   Case DT_TEHNDEFEKT
   krotObjType = OBJ_TEHNDEFEKT
   Case DT_CRACK_PRODOLN_SHVA
   krotObjType = OBJ_CRACK_PRODOLN_SHVA
   Case DT_CRACK_SPIRAL_SHVA
   krotObjType = OBJ_CRACK_SPIRAL_SHVA
   
   Case Else
   krotObjType = OBJ_anomal
  End Select

 Case ET_WELD
  Select Case trType
   Case WT_NORMAL
   krotObjType = OBJ_shov_p
   Case WT_SPIRAL
   krotObjType = OBJ_shov_s
   Case WT_NOSLIT
   krotObjType = OBJ_shov_b
   Case WT_NEOPR_SEKTSIYA
   krotObjType = OBJ_neopr_sektsiya
   Case WT_ODNOSHOVN
   krotObjType = OBJ_odoshovn
   Case WT_DVUHSHOVN
   krotObjType = OBJ_dvuhshovn
   Case WT_KRAN
   krotObjType = OBJ_tubekran
   Case WT_TROYNIK
   krotObjType = OBJ_tubetroynik
  End Select

 Case ET_LINEOBJ
  Select Case trType
   Case LT_WATERIN
   krotObjType = OBJ_waterin
   Case LT_WATEROUT
   krotObjType = OBJ_waterout
   Case LT_KRAN
   krotObjType = OBJ_kran
   Case LT_MARKER
   krotObjType = OBJ_marker
   Case LT_OTVOD
   krotObjType = OBJ_otvod
   Case LT_PATRON_VHOD
   krotObjType = OBJ_patron_in
   Case LT_PATRON_VIHOD
   krotObjType = OBJ_patron_out
   Case LT_TROYNIK
   krotObjType = OBJ_troynik
   Case LT_SEGM_POVOROT_START
   krotObjType = OBJ_povorot
   Case LT_KZ
   krotObjType = OBJ_runplace
   Case LT_KP
   krotObjType = OBJ_getplace
   Case LT_TEHOKNO
   krotObjType = OBJ_tehokno
   Case LT_MUFTA_NACH
   krotObjType = OBJ_mufta_nach
   Case LT_MUFTA_KON
   krotObjType = OBJ_mufta_kon
   Case LT_FLANGE
   krotObjType = OBJ_FLANGE
   Case LT_IZOL_STYK
   krotObjType = OBJ_IZOL_STYK
   Case LT_PATRON_MALOY_DLINY
   krotObjType = OBJ_PATRON_MALOY_DLINY
   Case LT_HOMUT
   krotObjType = OBJ_HOMUT
   Case LT_ZADVIZHKA
   krotObjType = OBJ_ZADVIZHKA
   Case LT_MARKERN_KOLTSO
   krotObjType = OBJ_MARKERN_KOLTSO
   Case LT_MARKER_MAGN
   krotObjType = OBJ_MARKER_MAGN
   Case LT_ZAVARKA_BOBYSHKI
   krotObjType = OBJ_ZAVARKA_BOBYSHKI
   Case LT_REM_NAKLADKA
   krotObjType = OBJ_REM_NAKLADKA
   Case LT_OTREM_UCH
   krotObjType = OBJ_OTREM_UCH
   Case LT_NERASPOZN_OBJ
   krotObjType = OBJ_NERASPOZN_OBJ
   Case LT_TRUBN_ARMATURA
   krotObjType = OBJ_TRUBN_ARMATURA
   Case LT_ELEM_OBUSTROISTVA
   krotObjType = OBJ_ELEM_OBUSTROISTVA
   Case LT_NEDOPUSTIM_KONSTR_ELEM
   krotObjType = OBJ_NEDOPUSTIM_KONSTR_ELEM
   Case LT_MET_MUFTA_NACH
   krotObjType = OBJ_met_mufta_nach
   Case LT_MET_MUFTA_KON
   krotObjType = OBJ_met_mufta_kon
   Case LT_STARTDIST
   krotObjType = OBJ_diststart
   Case LT_ENDTDIST
   krotObjType = OBJ_distend
   
   Case Else
   krotObjType = OBJ_marker
  End Select

 Case ET_PRIGRUZ
  Select Case trType
   Case PT_SINGLE
   krotObjType = OBJ_prigruz
   Case PT_START
   krotObjType = OBJ_startprgrz
   Case PT_END
   krotObjType = OBJ_endprgrz
  End Select
  
 Case ET_THICK
  krotObjType = OBJ_thick

 Case ET_CATEGORY
  krotObjType = OBJ_category

 Case ET_VOG_POVOROT
  krotObjType = OBJ_povorot

End Select
End Function


