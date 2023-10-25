.PHONY: all clean arkaline gpas clear_cfg

include $(BuildKrotW32)\defaults.mk
include $(BuildKrotW32)\ver.mk

TARGET = krotw32.exe

RESOURCE_FOLDER = res
RESOURCE = $(RESOURCE_FOLDER)\krotw32.RES

MDB_FOLDER = db
MDB = $(MDB_FOLDER)\_trcobj.mdb

VOG_FOLDER = vogMath
VOG_MATH =  $(VOG_FOLDER)\VogMath.dll

SRC = \
AnglUnit.cls CMDLINE.CLS CmntEdit.cls COMMNDLG.CLS Config.cls Coroz.cls CorozMark.cls CorozSettings.cls CorozZones.cls Cursor.cls Db.cls \
DebugLog.cls Depth.cls DepthRow.cls DepthSpiral.cls DfctRpt.cls Dirs.cls DragMark.cls Driver.cls DrvSet.cls Export.cls ExtTime.cls File.cls \
FileHistory.cls FormProps.cls Help.cls History.cls IniSection.cls KrtCmd.cls LangExp.cls longJob.cls MagnCurve.cls MagnCurveSet.cls \
Magnit.cls Mark.cls mdbutil.cls MouseWeel.cls ObjCommn.cls ObjDfkt.cls ObjFilt.cls ObjLine.cls ObjSettings.cls ObjThick.cls ObjTurn.cls \
ObjType.cls ObjWeld.cls Palette.cls PointLnk.cls PrnGraph.cls Regional.cls RsetEdit.cls SensCircle.cls SensClrs.cls SensGrph.cls Sensor.cls \
SensorGraphCoroz.cls SensorGraphCurve.cls SensorGraphExt.cls SensorGraphOrient.cls SensorGraphSpeed.cls SensorLine.cls SensorLineCurve.cls \
TimeMark.cls Timer.cls Trace.cls TubeFiltr.cls TubeScan.cls Vog.cls VogMatch.cls VogSettings.cls VogSlave.cls VogSlideSetting.cls Window.cls Zoom.cls \
SensorGraphVog.cls \
\
about.frm about.frx AutoScan.frm CmntEdit.frm CrzTool.frm CrzTool.frx Defekt.frm Defekt.frx DistKoef.frm DistKoef.frx driver.frm driver.frx \
interval.frm interval.frx MagnExplain.frm MagnExplain.frx Magnit.frm Main.frm Main.frx ObjCommn.frm ObjCommn.frx ObjDfkt.frm ObjDfkt.frx \
ObjFiltr.frm ObjFiltr.frx ObjLine.frm ObjLine.frx ObjThick.frm ObjThick.frx ObjTurn.frm ObjTurn.frx ObjWeld.frm ObjWeld.frx Palette.frm Palette.frx \
PalItem.frm PrgSet.frm PrgSet.frx Register.frm Register.frx ScaleNew.frm ScaleNew.frx ScanTube.frm SensInterval.frm Setting.frm Setting.frx \
Speed.frm Speed.frx Table.frm Table.frx TableColumns.frm TableColumns.frx TimeMark.frm TimeMark.frx Trace.frm Trace.frx TubeProfile.frm TubeProfile.frx \
TubFiltr.frm TubFiltr.frx TurnInfo.frm TurnInfo.frx uMinute.frm VogMSel.frm VogMSel.frx Zoom.frm Zoom.frx \
\
AnglUnit.ctl aScroll.ctl aScroll.ctx Coroz.ctl Coroz.ctx CrzCircl.ctl CrzCircl.ctx CrzGraph.ctl CrzGraph.ctx CrzZones.ctl CrzZonesSettings.ctl \
GrfDigit.ctl GrfDigit.ctx GrfSimpl.ctl GrfSimpl.ctx GrfSpec.ctl GrfSpec.ctx lNumBox.ctl lScroll.ctl lScroll.ctx lSlit.ctl MagnCurves.ctl \
MagnCurves.ctx multyNum.ctl multyNum.ctx ObjComn.ctl ObjComn.ctx Orient.ctl Orient.ctx Pallete.ctl rotAngle.ctl rotAngle.ctx scaleList.ctl \
traceObj.ctl traceObj.ctx trcCtrl.ctl trcCtrl.ctx VOG.ctl VOG.ctx \
\
dai.bas Glob.bas Help.bas hook.bas krtapi.bas onLine.bas util.bas Vbapi.bas Versions.bas RESOURCE.BAS vogMath.bas \
\
krotw32.vbp

all: $(TARGET)
	$(MAKE) -C $(MDB_FOLDER)
#	$(MAKE) -C $(VOG_FOLDER)

$(RESOURCE): 
	$(MAKE) -C $(RESOURCE_FOLDER)

$(MDB):
	$(MAKE) -C $(MDB_FOLDER)

$(VOG_MATH):
	$(MAKE) -C $(VOG_FOLDER)

$(TARGET): $(SRC) $(RESOURCE) $(MDB)
	@$(GNU_FOLDER)\sed.exe -e s/MajorVer=1/MajorVer=$(KROT_MAJOR_VER)/g;s/MinorVer=0/MinorVer=$(KROT_MINOR_VER)/g;s/RevisionVer=0/RevisionVer=$(KROT_REVISION_VER)/g krotw32.vbp > temp.vbp
	@build.cmd
	-$(DEL) temp.vbp >nul
	"C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe" -addoverwrite $(TARGET),$(TARGET),res\company.ico,ICONGROUP,MAINICON,0

	@EDITBIN.EXE /LARGEADDRESSAWARE KrotW32.exe

arkaline: clear_cfg
	$(MAKE) CFG=arkaline -C config

gpas: clear_cfg
	$(MAKE) CFG=gpas -C config

viewer: clear_cfg
	$(MAKE) CFG=viewer -C config

clear_cfg:
	-$(DEL) $(TARGET) $(MDB) $(RESOURCE) build.cmd >nul

clean:
	$(MAKE) -C $(RESOURCE_FOLDER) clean
	$(MAKE) -C $(MDB_FOLDER) clean
	$(MAKE) -C config clean
#	$(MAKE) -C $(VOG_FOLDER) clean
	-$(DEL) krotw32.vbw build.cmd $(TARGET) >nul
