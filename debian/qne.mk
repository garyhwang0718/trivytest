include /usr/share/dpkg/pkg-info.mk
export DEB_SOURCE
export DEB_VERSION
export DEB_BUILD_DATE := $(shell date +%Y/%m/%d)

SUBSTVARS := \
	-Vqne:BuildDate="$(DEB_BUILD_DATE)"

override_dh_gencontrol:
	dh_gencontrol -- $(SUBSTVARS)

override_dh_installdeb:
	dh_installdeb
	-for pkg in $$(dh_listpackages); do \
		sed -i -e 's/__DEB_VERSION__/$(DEB_VERSION)/' debian/$$pkg/DEBIAN/* 2>/dev/null || true; \
		done
