
IMAGE_PATH = $(DESTDIR)/usr/share/doc/qinfluxdbkapacitor-image
SCRIPT_PATH = $(DESTDIR)/var/lib/qinfluxdbkapacitor-image/script
NDR_PATH = $(DESTDIR)/.data/ndr-management
TARGET_IMG_NAME = qinfluxdbkapacitor_base
TARGET1 = $(TARGET_IMG_NAME).tar
TARGET2 = control.sh
QSECOPS_ON_AIR = qsecops_on_air
TARGET4 = docker-compose.yml

all:
	./pre_build.sh

install:
	mkdir -p $(IMAGE_PATH)
	mkdir -p $(SCRIPT_PATH)
	mkdir -p $(NDR_PATH)/scripts
	install -m 0755 $(TARGET1) $(IMAGE_PATH)
	install -m 0755 $(TARGET2) $(SCRIPT_PATH)
	install -m 0755 $(QSECOPS_ON_AIR) $(IMAGE_PATH)
	install -m 0755 $(TARGET4) $(SCRIPT_PATH)

clean:
	rm -f ./*.deb
	rm -f $(TARGET1)
	rm -f ./debian/upload_profiles.log
	rm -f ./debian/code_signing.log
	rm -f ./debian/code_signing_md5sums.log
