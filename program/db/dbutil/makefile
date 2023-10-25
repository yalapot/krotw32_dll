.PHONY: all clean

include $(BuildKrotW32)\defaults.mk

TARGET = dbutil.exe
SRC = dbutil.vbp utilmain.bas CMDLINE.CLS mdbutil.cls

all: $(TARGET)

$(TARGET): $(SRC)
	$(PRG_VB6) /d /m dbutil.vbp

clean:
	-$(DEL) dbutil.vbw >nul
	-$(DEL) dbutil.exe >nul
