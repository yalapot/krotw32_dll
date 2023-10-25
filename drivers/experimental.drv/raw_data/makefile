.PHONY: all clean

include $(BuildKrotXML)\defaults.mk

INCLUDES = /I /I..  /I..\.. /I..\..\.. /I..\..\..\..


TARGET = raw_data_reg.exe
DRV_LIST = raw_data_reg.obj


all: $(TARGET)
#	cp $(TARGET) $(SETUP_BIN_FOLDER)

$(DRV_LIST): xml_tools.c

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

$(TARGET): $(DRV_LIST)
	$(LINK) /OUT:$(TARGET) $(DRV_LIST) $(WIN_LIB)

clean:
	$(RM) $(TARGET) *.exe *.obj

