
IMAGE_PATH = $(NDR_PATH)/sec-ops/doc/qinfluxdbkapacitor-image
SCRIPT_PATH = $(NDR_PATH)/sec-ops/scripts
LOG_PATH = $(NDR_PATH)/log/sec-ops/
NDR_PATH = $(DESTDIR)/.data/ndr-management
INFLUXDB_PATH = $(NDR_PATH)/log/sec-ops/lib
INFLUXDB_INIT_PATH = $(NDR_PATH)/sec-ops/docker-entrypoint-initdb.d
TARGET_IMG_NAME = qinfluxdbkapacitor_base
TARGET1 = $(TARGET_IMG_NAME).tar
TARGET2 = control.sh
QSECOPS_ON_AIR = qsecops_on_air
TARGET4 = docker-compose.yml
INFLUXDB_CONF_PATH = $(NDR_PATH)/sec-ops/conf/influxdb/
KAPACITOR_CONF_PATH = $(NDR_PATH)/sec-ops/conf/kapacitor/
LOGROTATE_CONF_PATH= $(NDR_PATH)/sec-ops/conf/logrotate/
ENV_CONF_PATH = $(NDR_PATH)/sec-ops/
INFLUXDB_CONF = influxdb/influxdb.conf
KAPACITOR_CONF = kapacitor/kapacitor.conf
LOGROTATE_CONF = logrotate
INFLUXDB_INIT = influxdb/init.sh
ENV_CONF= .env


all:
	./pre_build.sh

install:
	mkdir -p $(IMAGE_PATH)
	mkdir -p $(SCRIPT_PATH)
	mkdir -p $(LOG_PATH)
	mkdir -p ${INFLUXDB_CONF_PATH}
	mkdir -p ${KAPACITOR_CONF_PATH}
	mkdir -p ${LOGROTATE_CONF_PATH}
	mkdir -p ${INFLUXDB_PATH}
	mkdir -p ${INFLUXDB_INIT_PATH}
	install -m 0755 $(TARGET1) $(IMAGE_PATH)
	install -m 0755 $(TARGET2) $(SCRIPT_PATH)
	install -m 0755 $(QSECOPS_ON_AIR) $(IMAGE_PATH)
	install -m 0755 $(TARGET4) $(SCRIPT_PATH)
	install -m 0755 $(INFLUXDB_CONF) $(INFLUXDB_CONF_PATH)
	install -m 0755 $(KAPACITOR_CONF) $(KAPACITOR_CONF_PATH)
	install -m 0755 $(LOGROTATE_CONF)/influx $(LOGROTATE_CONF_PATH)
	install -m 0755 $(LOGROTATE_CONF)/kapacitor $(LOGROTATE_CONF_PATH)
	install -m 0755 $(ENV_CONF) $(ENV_CONF_PATH)
	install -m 0755 $(INFLUXDB_INIT) $(INFLUXDB_INIT_PATH)

clean:
	rm -f ./*.deb
	rm -f $(TARGET1)
	rm -f ./debian/upload_profiles.log
	rm -f ./debian/code_signing.log
	rm -f ./debian/code_signing_md5sums.log
