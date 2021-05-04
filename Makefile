
IMAGE_PATH = $(NDR_PATH_STATIC)/sec-ops/doc/qinfluxdbkapacitor-image
SCRIPT_PATH = $(NDR_PATH_DYNAMIC)/sec-ops/scripts
NDR_PATH_STATIC = $(DESTDIR)/usr/share/qne-qundr
NDR_PATH_DYNAMIC = $(DESTDIR)/var/lib/qne-qundr
INFLUXDB_INIT_PATH = $(NDR_PATH_DYNAMIC)/sec-ops/docker-entrypoint-initdb.d
TARGET_IMG_NAME = qinfluxdbkapacitor_base
TARGET1 = $(TARGET_IMG_NAME).tar
TARGET2 = control.sh
QSECOPS_ON_AIR = qsecops_on_air
TARGET4 = docker-compose.yml
INFLUXDB_CONF_PATH = $(NDR_PATH_DYNAMIC)/sec-ops/conf/influxdb/
KAPACITOR_CONF_PATH = $(NDR_PATH_DYNAMIC)/sec-ops/conf/kapacitor/
LOGROTATE_CONF_PATH= $(NDR_PATH_DYNAMIC)/sec-ops/conf/logrotate/
SUPERVISOR_CONF_PATH= $(NDR_PATH_DYNAMIC)/sec-ops/conf/supervisor/
ENV_CONF_PATH = $(NDR_PATH_DYNAMIC)/sec-ops/
SUPERVISOR_CONF = supervisor/supervisord.conf
INFLUXDB_CONF = influxdb/influxdb.conf
KAPACITOR_CONF = kapacitor/kapacitor.conf
LOGROTATE_CONF = logrotate
INFLUXDB_INIT = influxdb/init.sh
INFLUXDB_CQ_INIT = influxdb/initcq.sh
RULE_PATH= $(NDR_PATH_DYNAMIC)/sec-ops/rules
RULE_HANDLER_PATH= $(NDR_PATH_DYNAMIC)/sec-ops/rule_handler
DOCKER_CONF_PATH = $(DESTDIR)/etc/docker/
DOCKER_CONF = docker/daemon.json
ENV_CONF= .env


all:
	./pre_build.sh

install:
	mkdir -p $(IMAGE_PATH)
	mkdir -p $(SCRIPT_PATH)
	mkdir -p ${INFLUXDB_CONF_PATH}
	mkdir -p ${KAPACITOR_CONF_PATH}
	mkdir -p ${LOGROTATE_CONF_PATH}
	mkdir -p ${SUPERVISOR_CONF_PATH}
	mkdir -p ${INFLUXDB_INIT_PATH}
	mkdir -p ${DOCKER_CONF_PATH}
	mkdir -p ${RULE_PATH}
	mkdir -p ${RULE_HANDLER_PATH}
	install -m 0755 $(TARGET1) $(IMAGE_PATH)
	install -m 0755 $(TARGET2) $(SCRIPT_PATH)
	install -m 0755 $(QSECOPS_ON_AIR) $(IMAGE_PATH)
	install -m 0755 $(TARGET4) $(SCRIPT_PATH)
	install -m 0755 $(INFLUXDB_CONF) $(INFLUXDB_CONF_PATH)
	install -m 0755 $(KAPACITOR_CONF) $(KAPACITOR_CONF_PATH)
	install -m 0644 $(SUPERVISOR_CONF) $(SUPERVISOR_CONF_PATH)
	install -m 0755 $(LOGROTATE_CONF)/influx $(LOGROTATE_CONF_PATH)
	install -m 0755 $(LOGROTATE_CONF)/kapacitor $(LOGROTATE_CONF_PATH)
	install -m 0755 $(ENV_CONF) $(ENV_CONF_PATH)
	install -m 0755 $(INFLUXDB_INIT) $(INFLUXDB_INIT_PATH)
	install -m 0755 $(INFLUXDB_CQ_INIT) $(INFLUXDB_INIT_PATH)
	install -m 0755 $(DOCKER_CONF) $(DOCKER_CONF_PATH)

clean:
	rm -f ./*.deb
	rm -f $(TARGET1)
	rm -f ./debian/upload_profiles.log
	rm -f ./debian/code_signing.log
	rm -f ./debian/code_signing_md5sums.log
