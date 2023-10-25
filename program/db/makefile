.PHONY: all clean

include $(BuildKrotW32)\defaults.mk

DBUTIL_FOLDER = dbutil
DBUTIL = $(DBUTIL_FOLDER)\dbutil.exe

TARGET = _trcobj.mdb
SRC = trcobj.def make.sql

all: $(TARGET)

$(DBUTIL):
	$(MAKE) -C $(DBUTIL_FOLDER)

$(TARGET): $(DBUTIL) $(SRC)
	cmd /C start /wait $(DBUTIL) make.sql

clean:
	-$(DEL) _trcobj.mdb >nul
	-$(DEL) _trcobj.log >nul
	$(MAKE) -C $(DBUTIL_FOLDER) clean
