.PHONY: all clean

include $(BuildKrotXML)\defaults.mk


TARGET = csv_drv.dll
DRV_DEF = csv_drv.def
DRV_LIST = csv_drv.obj

all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $< 

csv_drv.obj: $(KROT_API)

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

