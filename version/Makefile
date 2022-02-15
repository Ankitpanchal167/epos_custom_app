BASE_DIR    := $(realpath $(realpath .)/..)

BSP_VERSION = bsp_version.txt

clean:
	echo "In Script Notihing to do ..."

install:
	@mkdir -p  $(DESTDIR)/etc/; \
	   cp $(BSP_VERSION) $(DESTDIR)/etc/bsp_version.txt; \
	   cp version.sh $(DESTDIR)/usr/bin/version; \
	   chmod 777 $(DESTDIR)/usr/bin/version

include $(BASE_DIR)/etc/local.mk
include $(BASE_DIR)/etc/rules.mk


