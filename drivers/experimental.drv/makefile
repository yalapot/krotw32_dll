.PHONY: all clean

include $(BuildKrotXML)\defaults.mk

all:
	$(MAKE) -C common
	$(MAKE) -C bps_drv    
	$(MAKE) -C bps_porshen
	$(MAKE) -C samopisets 
	$(MAKE) -C text_drv   

clean:
	$(MAKE) -C common clean
	$(MAKE) -C bps_drv clean   
	$(MAKE) -C bps_porshen  clean
	$(MAKE) -C samopisets clean
	$(MAKE) -C text_drv clean  
