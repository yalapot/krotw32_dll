all: bb128_3d.dll

COMPILE_FLAGS = /c /I../../inc /DWIN32 /G5 /O2 /Ot

krotdrv.obj: krtblack.h krotdrv.c
    cl $(COMPILE_FLAGS) krotdrv.c

krtblack.obj: krtblack.h krtblack.c
    cl $(COMPILE_FLAGS) krtblack.c

blackdrv.obj: blackdrv.c krtblack.h
    cl $(COMPILE_FLAGS) blackdrv.c

bb128_3d.dll: krtblack.obj blackdrv.obj krotdrv.obj blackdrv.def
  link /DLL /DEF:blackdrv.def /OUT:bb128_3d.dll blackdrv.obj krtblack.obj krotdrv.obj kernel32.lib gdi32.lib user32.lib

