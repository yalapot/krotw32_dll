.PHONY: all clean

include $(BuildKrotXML)\defaults.mk

TARGET = dsu.dll
DRV_DEF = dsu.def
#COMPILE_FLAGS = /c /I../../inc /DWIN32 /DDLL /G5 /O2 /Ot

all: $(TARGET)

dsu.obj: dsu.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) dsu.c

$(TARGET): dsu.obj $(DRV_DEF)
	$(LINK) /DLL /DEF:$(DRV_DEF) /OUT:$(TARGET) dsu.obj $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp
