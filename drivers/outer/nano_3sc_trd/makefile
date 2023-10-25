.PHONY: all clean

include $(BuildKrotXML)\defaults.mk
include $(BuildKrotXML)\drivers\outer\outer.mk 


TARGET = nano_outer_3sc.dll
DRV_DEF = nano_outer_3sc.def
DRV_LIST = krotnano.obj reciever.obj iniTool.obj fileTool.obj nano_outer_3sc.obj


all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

krotnano.obj: krotnano.h $(BuildKrotXML)\drivers\int_unit.h $(KROT_API)

reciever.obj: reciever.h krotnano.h $(BuildKrotXML)\drivers\int_unit.h $(KROT_API)

nano_outer_3sc.obj: $(KROT_API) 

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

