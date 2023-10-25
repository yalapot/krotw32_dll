
NANO_V3_CORE = ..\krotnano_lc.h ..\..\nano_lc.c ..\..\tracetool.c ..\..\tracetool.h ..\..\directmove.c $(BuildKrotXML)\lib\navigate.c $(BuildKrotXML)\lib\navigate.h $(BuildKrotXML)\lib\height_arrow.c $(BuildKrotXML)\lib\height_arrow.h ..\..\..\int_unit.h

INCLUDES = /I..  /I..\.. /I..\..\.. /I..\..\..\.. /I$(BuildKrotXML)\lib


               
SKIP_WARNINGS = /wd4996 /wd4127

# /wd4996 This function or variable may be unsafe.
# /wd4127 conditional expression is constant
#


all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

$(DRV_LIST): $(NANO_V3_CORE) $(KROT_API)

include $(BuildKrotXML)\lib\use_lib_file_buffering.mk
include $(BuildKrotXML)\lib\use_lib_height_arrow.mk

include $(BuildKrotXML)\lib\use_lib_bending_plane.mk

$(TARGET): $(DRV_DEF) $(DRV_LIST) $(FILE_BUFEERING_LIB)
	$(MAKE) -C $(BuildKrotXML)\lib
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB) $(FILE_BUFEERING_LIB) $(HEIGHT_ARROW) $(BENDING_PLANE)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

