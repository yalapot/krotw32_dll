.PHONY: all clean

include $(BuildKrotXML)\defaults.mk

all:
	$(MAKE) -C 1400_epro
	$(MAKE) -C epro_drv
	$(MAKE) -C epro_drv_460
	$(MAKE) -C epro_drv_508

clean:
	$(MAKE) -C 1400_epro clean
	$(MAKE) -C epro_drv  clean
	$(MAKE) -C epro_drv_460  clean
	$(MAKE) -C epro_drv_508  clean
