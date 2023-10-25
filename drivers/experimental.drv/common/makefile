.PHONY: all clean

include $(BuildKrotXML)\defaults.mk

TARGET = common.dll
DRV_DEF = common.def
DRV_LIST = common.obj

all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 /wd4996 $<

common.obj: common.h $(KROT_API)

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp
