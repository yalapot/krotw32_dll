.PHONY: all clean

include $(BuildKrotXML)\defaults.mk

all:
	$(MAKE) -C 1000_encoder_1022
	$(MAKE) -C 1000_encoder_1023
	$(MAKE) -C 1000_profil_32
	$(MAKE) -C 1200_profil
	$(MAKE) -C 1200_profil_1000_block
	$(MAKE) -C 1200_profil_1221
	$(MAKE) -C 1400_profil
	$(MAKE) -C 426_profil
	$(MAKE) -C 500_profil
	$(MAKE) -C 700_profil
	$(MAKE) -C 500_profil_id5320
	$(MAKE) -C samopisets_nano_v1

clean:
	$(MAKE) -C 1000_encoder_1022 clean
	$(MAKE) -C 1000_encoder_1023 clean
	$(MAKE) -C 1000_profil_32    clean
	$(MAKE) -C 1200_profil       clean
	$(MAKE) -C 1200_profil_1000_block clean
	$(MAKE) -C 1200_profil_1221       clean
	$(MAKE) -C 1400_profil    clean
	$(MAKE) -C 426_profil     clean
	$(MAKE) -C 500_profil     clean
	$(MAKE) -C 700_profil     clean
	$(MAKE) -C 500_profil_id5320  clean
	$(MAKE) -C samopisets_nano_v1 clean

