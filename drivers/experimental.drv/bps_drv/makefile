.PHONY: all clean

include $(BuildKrotXML)\defaults.mk


TARGET = bps_drv.dll
DRV_DEF = bps_drv.def
DRV_LIST = bps_drv.obj

all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $< 

bps_drv.obj: $(KROT_API)

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

