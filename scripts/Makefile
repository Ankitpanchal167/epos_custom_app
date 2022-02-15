BASE_DIR    := $(realpath $(realpath .)/..)


clean:
	echo "In Script Notihing to do ..."

install:
	@cp epos.init  $(DESTDIR)/etc/init.d/epos
	@cd $(DESTDIR)/etc/rc5.d/ && ln -sf ../init.d/epos S39epos
	@cd $(DESTDIR)/etc/rc0.d/ && ln -sf ../init.d/epos K39epos
	@cd $(DESTDIR)/etc/rc6.d/ && ln -sf ../init.d/epos K39epos
	@cp Command.txt  $(DESTDIR)/home/root/
	@cp am335x-pm-firmware.elf  $(DESTDIR)/lib/firmware/
	@cp wl18xx-fw-4.bin $(DESTDIR)/lib/firmware/ti-connectivity/
	@rm -f $(DESTDIR)/usr/bin/psplash
	@cp hello.png $(DESTDIR)/opt/


include $(BASE_DIR)/etc/local.mk
include $(BASE_DIR)/etc/rules.mk



