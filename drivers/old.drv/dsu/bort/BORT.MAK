!if $d(DEBUG)
BCCDEBUG=-v
!else
BCCDEBUG=
!endif

TLINK = tlink

PRJPATH = d:\user\krot
OBJPATH = $(PRJPATH)\obj
EXEPATH = $(PRJPATH)\exe
INCPATH = $(PRJPATH)\sourse\inc
CFLAGS = @bort128.cfg $(BCCDEBUG)
AFLAGS = /m2 /ml /t /q /zn /w2 /i$(INCPATH)
TLFLAGS = /x

H_N2WORD = $(INCPATH)\num2word.h
H_KROT128 = $(INCPATH)\krot128.h
INC_BORT = $(INCPATH)\bort.inc

# check.exe
TARcheck = $(EXEPATH)\check.exe
SRCcheck = check.c
OBJcheck = $(OBJPATH)\$(SRCcheck:.c=.obj)

# scan128.exe
TARscan = $(EXEPATH)\scan128.exe
SRCscan = scan128.c
OBJscan = $(OBJPATH)\$(SRCscan:.c=.obj)

# bort.exe
TARbort = $(EXEPATH)\bort.exe
SRCbort = bort.asm
OBJbort = $(OBJPATH)\$(SRCbort:.asm=.obj)

# bortini.exe
TARbini = $(EXEPATH)\bortini.exe
SRCbini1 = sensor.asm
SRCbini2 = num2word.c
SRCbini3 = vreport.c
SRCbini4 = bortini.c
OBJbini1 = $(OBJPATH)\$(SRCbini1:.asm=.obj)
OBJbini2 = $(OBJPATH)\$(SRCbini2:.c=.obj)
OBJbini3 = $(OBJPATH)\$(SRCbini3:.c=.obj)
OBJbini4 = $(OBJPATH)\$(SRCbini4:.c=.obj)
OBJbini = $(OBJbini1) $(OBJbini2) $(OBJbini3) $(OBJbini4)

# report.exe
TARrprt = $(EXEPATH)\report.exe
SRCrprt = report.c
OBJrprt = $(OBJPATH)\$(SRCrprt:.c=.obj)

allFiles: $(TARcheck) $(TARscan) $(TARbort) $(TARbini) $(TARrprt)

# report.exe
$(TARrprt): $(OBJrprt) $(OBJbini2) $(OBJbini3)
	@echo $(OBJrprt) >tmp
	@echo $(OBJbini2) >>tmp
	@echo $(OBJbini3) >>tmp
	$(CC) -e$(TARrprt) $(CFLAGS) @tmp
	@del tmp

$(OBJrprt): $(SRCrprt) $(H_KROT128)
	@$(CC) $(CFLAGS) -n$(OBJPATH) /c $(SRCrprt)

# bortini.exe
$(TARbini): $(OBJbini)
	@echo $(OBJbini1) >tmp
	@echo $(OBJbini2) >>tmp
	@echo $(OBJbini3) >>tmp
	@echo $(OBJbini4) >>tmp
	$(CC) -e$(TARbini) $(CFLAGS) @tmp
	@del tmp

$(OBJbini1): $(SRCbini1) $(INC_BORT)
	@$(AS) $(AFLAGS) $(SRCbini1), $(OBJbini1)
$(OBJbini2): $(SRCbini2) $(H_N2WORD)
	@$(CC) $(CFLAGS) -n$(OBJPATH) /c $(SRCbini2)
$(OBJbini3): $(SRCbini3) $(H_N2WORD) $(H_KROT128)
	@$(CC) $(CFLAGS) -n$(OBJPATH) /c $(SRCbini3)
$(OBJbini4): $(SRCbini4) $(H_N2WORD) $(H_KROT128)
	@$(CC) $(CFLAGS) -n$(OBJPATH) /c $(SRCbini4)

# check.exe
$(TARcheck): $(OBJcheck)
	@$(CC) -e$(TARcheck) $(CFLAGS) $(OBJcheck)

$(OBJcheck): $(SRCcheck) $(H_KROT128)
	@$(CC) $(CFLAGS) -n$(OBJPATH) /c $(SRCcheck)

# scan128.exe
$(TARscan): $(OBJscan)
	@$(CC) -e$(TARscan) $(CFLAGS) $(OBJscan)

$(OBJscan): $(SRCscan) $(H_KROT128)
	@$(CC) $(CFLAGS) -n$(OBJPATH) /c $(SRCscan)

# bort.exe
$(TARbort): $(OBJbort)
	@$(TLINK) $(TLFLAGS) $(OBJbort), $(TARbort)

$(OBJbort): $(SRCbort) $(INC_BORT)
	@$(AS) $(AFLAGS) $(SRCbort), $(OBJbort)