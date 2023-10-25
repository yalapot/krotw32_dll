
NANO_512_CORE = ..\nano_512_drv.c ..\krotnano_512.c ..\krotnano_512.h ..\..\tracetool.h ..\..\tracetool.c $(BuildKrotXML)\lib\navigate.c ..\..\..\int_unit.h $(BuildKrotXML)\lib\quicklz.c $(BuildKrotXML)\lib\quicklz.h

INCLUDES = /I..  /I..\.. /I..\..\.. /I..\..\..\.. /I$(BuildKrotXML)\lib
               
SKIP_WARNINGS = /wd4996 /wd4127

# /wd4996 This function or variable may be unsafe.
# /wd4127 conditional expression is constant
#

TARGET_VERSION = $(TARGET)_v2.dll


all: $(TARGET_VERSION)

$(DRV_LIST): $(NANO_512_CORE) $(KROT_API)

$(DRV_LIST): %.obj: %.c
	$(MAKE) -C $(BuildKrotXML)\lib
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

include $(BuildKrotXML)\lib\use_lib_quicklz.mk

include $(BuildKrotXML)\lib\use_lib_navigate.mk

include $(BuildKrotXML)\lib\use_lib_file_buffering.mk

include $(BuildKrotXML)\lib\use_lib_height_arrow.mk

include $(BuildKrotXML)\lib\use_lib_BPdata.mk

include $(BuildKrotXML)\lib\use_lib_bending_plane.mk


$(TARGET_VERSION): $(DRV_DEF) $(DRV_LIST) $(QUICKLZ_LIB) $(NAVIGATE_LIB) $(FILE_BUFEERING_LIB)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET_VERSION) $(DRV_LIST) $(WIN_LIB) $(QUICKLZ_LIB) $(NAVIGATE_LIB) $(FILE_BUFEERING_LIB) $(HEIGHT_ARROW) $(BPDATA_LIB) $(BENDING_PLANE)

clean:
	$(RM) $(TARGET_VERSION) *.obj *.lib *.exp

