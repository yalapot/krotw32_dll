.PHONY: all clean

include $(BuildKrotXML)\defaults.mk

all:
	$(MAKE) -C experimental.drv
	$(MAKE) -C old.drv
	$(MAKE) -C nano
	$(MAKE) -C epro
	$(MAKE) -C outer

clean:
	$(MAKE) -C experimental.drv clean
	$(MAKE) -C old.drv clean
	$(MAKE) -C nano clean
	$(MAKE) -C epro clean
	$(MAKE) -C outer clean
