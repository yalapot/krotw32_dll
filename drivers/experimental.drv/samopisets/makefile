all: epro_drv.dll epro_reg.exe

include $(BuildKrotXML)\defaults.mk

COMPILE_FLAGS = /nologo /c /DWIN32 /GA /O2 /Ot 
OBJ_LIST = heapinsp.obj krotepro.obj libdafil.obj epro_drv.obj navigate.obj
DEL = del /F /Q

heapinsp.obj: heapinsp.h heapinsp.c
	$(cc) $(COMPILE_FLAGS) heapinsp.c

krotepro.obj: krotepro.h krotepro.c libdafil.h heapinsp.h
	$(cc) $(COMPILE_FLAGS) krotepro.c

libdafil.obj: libdafil.h libdafil.c krotepro.h heapinsp.h
	$(cc) $(COMPILE_FLAGS) libdafil.c

navigate.obj: navigate.h navigate.c
	$(cc) $(COMPILE_FLAGS) navigate.c

epro_drv.obj: epro_drv.c krotepro.h libdafil.h heapinsp.h navigate.h
	$(cc) $(COMPILE_FLAGS) epro_drv.c

epro_drv.dll: $(OBJ_LIST) epro_drv.def
	$(LINK) /NOLOGO /DLL /DEF:epro_drv.def /OUT:drv_samopis_dif.dll $(OBJ_LIST) user32.lib

epro_reg.obj: epro_reg.c krotepro.h libdafil.h
	$(cc) $(COMPILE_FLAGS) epro_reg.c

epro_reg.exe: $(OBJ_LIST) epro_reg.obj
	$(LINK) /NOLOGO epro_reg.obj $(OBJ_LIST) user32.lib

clean:
	$(DEL) epro_reg.exe
	$(DEL) epro_drv.dll
	$(DEL) *.exp
	$(DEL) *.lib
	$(DEL) *.obj
