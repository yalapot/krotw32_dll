.PHONY: all clean

include $(BuildKrotXML)\defaults.mk
#include $(BuildKrotXML)\drivers\nano\nano_512\nano_512_core.mk 

INCLUDES = /I..


TARGET = krot_trc.obj navigate.obj quicklz.obj file_buffering.obj height_arrow.obj baypass.obj bending_plane.obj
DRV_LIST = krot_trc.obj  navigate.obj quicklz.obj file_buffering.obj height_arrow.obj baypass.obj bending_plane.obj


all: $(TARGET)

$(DRV_LIST): krot_trc.c navigate.c navigate.h quicklz.c quicklz.h file_buffering.c file_buffering.h height_arrow.c height_arrow.h baypass.c baypass.h bending_plane.c bending_plane.h

$(DRV_LIST): %.obj: %.c
	$(cc) /c /DWIN32 /DDLL /GA /O2 /Ot /W4 $(SKIP_WARNINGS) $(INCLUDES) $< 

$(TARGET):

krot_trc.obj: $(KROT_API) krot_trc.c

navigate.obj: $(KROT_API) navigate.c navigate.h

quicklz.obj: $(KROT_API) quicklz.c quicklz.h

file_buffering.obj: $(KROT_API) file_buffering.c file_buffering.h

height_arrow.obj: $(KROT_API) height_arrow.c height_arrow.h

baypass.obj: $(KROT_API) baypass.c baypass.h

clean:
	$(RM) $(TARGET) *.obj *.lib *.exp

