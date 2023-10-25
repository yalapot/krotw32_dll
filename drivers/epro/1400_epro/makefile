.PHONY: all clean

include $(BuildKrotXML)\defaults.mk
include $(BuildKrotXML)\drivers\epro\epro.mk 


TARGET = 1400_drv.dll
DRV_DEF = 1400_drv.def
DRV_LIST = heapinsp.obj krotepro.obj libdafil.obj navigate.obj 1400_drv.obj


all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

1400_drv.obj: $(KROT_API)

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

