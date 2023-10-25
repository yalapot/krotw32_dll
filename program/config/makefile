.PHONY: all clean

include $(BuildKrotW32)\defaults.mk

TARGET = ../krotw32.exe

RESOURCE_FOLDER = ../res
RESOURCE = $(RESOURCE_FOLDER)/krotw32.RES

MDB_FOLDER = ../db
MDB = $(MDB_FOLDER)/_trcobj.mdb

all:
	-$(DEL) $(TARGET) >nul
	-$(DEL) $(RESOURCE) >nul
	-$(DEL) $(MDB) >nul
	cp $(CFG)/company.ico $(RESOURCE_FOLDER)/company.ico
	cp $(CFG)/logo.bmp $(RESOURCE_FOLDER)/logo.bmp
	cp $(CFG)/company.rc $(RESOURCE_FOLDER)/company.rc
	cp $(CFG)/make.sql $(MDB_FOLDER)/make.sql
	cp $(CFG)/build.cmd ../build.cmd

clean:
	$(MAKE) -C arkaline clean
	$(MAKE) -C gpas clean
	$(MAKE) -C viewer clean
