.PHONY: all clean

include $(BuildKrotXML)\defaults.mk


TARGET = bps_porshen.dll
DRV_DEF = bps_porshen.def
DRV_LIST = bps_porshen.obj

all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $< 

bps_porshen.obj: $(KROT_API)

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

