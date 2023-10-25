.PHONY: all clean

include $(BuildKrotW32)\defaults.mk


INCLUDES = /I..  /I..\.. /I..\..\.. /I..\..\..\..
               
SKIP_WARNINGS = /wd4996 /wd4127


TARGET = VogMath.dll
DRV_DEF = VogMath.def
DRV_LIST = GetCurveData.obj


all: $(TARGET)

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

epro_drv.obj: $(KROT_API)

$(TARGET): $(DRV_DEF) $(DRV_LIST)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

