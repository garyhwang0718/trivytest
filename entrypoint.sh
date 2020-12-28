#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- influxd "$@"
fi

if [ "$1" = 'influxd' ]; then
	/init-influxdb.sh "${@:2}"
fi

exec "$@" 2>/var/log/influxdb/influxd.log &
exec /usr/sbin/crond -f &
KAPACITOR_HOSTNAME=${KAPACITOR_HOSTNAME:-$HOSTNAME}
export KAPACITOR_HOSTNAME
exec kapacitord

