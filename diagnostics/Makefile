BASE_DIR    := $(realpath $(realpath .)/..)
DIAG_VERSION = 1.1

clean:
	echo "In Script Notihing to do ..."

install:
	@sed -i "/DIAG_VERSION=/c\\DIAG_VERSION=$(DIAG_VERSION)" epos_peripheral_test/scripts/epos_diag.sh
	@mkdir -p  $(DESTDIR)/opt/; \
		cp -r epos_peripheral_test $(DESTDIR)/opt/epos_peripheral_test_$(DIAG_VERSION); \
		cd $(DESTDIR)/opt/; \
		ln -sf epos_peripheral_test_$(DIAG_VERSION) epos_peripheral_test;
	@cp diag $(DESTDIR)/usr/bin;
	@chmod 777 $(DESTDIR)/usr/bin/diag \
		$(DESTDIR)/opt/epos_peripheral_test_$(DIAG_VERSION)/scripts/SetDateTime.sh
	@cp epos_peripheral_test/configs/81-usb.rules $(DESTDIR)/etc/udev/rules.d/
	@mkdir -p $(DESTDIR)/etc/ppp/peers; \
		cp epos_peripheral_test/configs/chat-airtel $(DESTDIR)/etc/ppp/; \
		cp epos_peripheral_test/configs/hangup-airtel $(DESTDIR)/etc/ppp/; \
		cp epos_peripheral_test/configs/chat-vodafone $(DESTDIR)/etc/ppp/; \
		cp epos_peripheral_test/configs/hangup-vodafone $(DESTDIR)/etc/ppp/; \
		cp epos_peripheral_test/configs/provider.airtel $(DESTDIR)/etc/ppp/peers/airtel; \
		cp epos_peripheral_test/configs/provider.vodafone $(DESTDIR)/etc/ppp/peers/vodafone;


include $(BASE_DIR)/etc/local.mk
include $(BASE_DIR)/etc/rules.mk


