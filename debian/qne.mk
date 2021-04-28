include /usr/share/dpkg/pkg-info.mk
export DEB_SOURCE
export DEB_VERSION
export DEB_BUILD_DATE := $(shell date +%Y/%m/%d)

SUBSTVARS := \
	-Vqne:BuildDate="$(DEB_BUILD_DATE)"

override_dh_gencontrol:
	dh_gencontrol -- $(SUBSTVARS)

