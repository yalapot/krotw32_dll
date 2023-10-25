
RAW_DATA_CORE = ..\raw_data_core.c ..\raw_data_tools.c ..\tracetool.h ..\tracetool.c ..\..\..\int_unit.h

INCLUDES = /I..  /I..\.. /I..\..\.. /I..\..\..\..
               
SKIP_WARNINGS = /wd4996 /wd4127

# /wd4996 This function or variable may be unsafe.
# /wd4127 conditional expression is constant
#

TARGET_VERSION = $(TARGET).dll


all: $(TARGET_VERSION)

$(DRV_LIST): $(RAW_DATA_CORE) $(KROT_API)

$(DRV_LIST): %.obj: %.c
	$(MAKE) -C $(BuildKrotXML)\lib
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 


$(TARGET_VERSION): $(DRV_DEF) $(DRV_LIST) 
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET_VERSION) $(DRV_LIST) $(WIN_LIB) 
clean:
	$(RM) $(TARGET_VERSION) *.obj *.lib *.exp

