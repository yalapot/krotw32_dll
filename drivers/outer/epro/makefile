.PHONY: all clean

include $(BuildKrotXML)\defaults.mk
include $(BuildKrotXML)\drivers\outer\outer.mk 


TARGET = outer.dll
DRV_DEF = outer.def
DRV_LIST = heapinsp.obj krotepro.obj libdafil.obj reciever.obj thick.obj iniTool.obj fileTool.obj outer.obj


all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

outer.obj: $(KROT_API)

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

	