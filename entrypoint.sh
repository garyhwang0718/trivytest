#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- influxd "$@"
fi

if [ "$1" = 'influxd' ]; then
	/init-influxdb.sh "${@:2}"
fi

if [ ! -f /var/log/influxdb/influxd.log ]; then
    mkdir -p /var/log/influxdb/
    touch /var/log/influxdb/influxd.log
fi

exec "$@" 2>/var/log/influxdb/influxd.log &
if [ -f /docker-entrypoint-initdb.d/initcq.sh ]; then
    /docker-entrypoint-initdb.d/initcq.sh
fi
exec /usr/sbin/crond -f &
KAPACITOR_HOSTNAME=${KAPACITOR_HOSTNAME:-$HOSTNAME}
export KAPACITOR_HOSTNAME
exec kapacitord

