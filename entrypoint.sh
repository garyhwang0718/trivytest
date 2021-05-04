#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- influxd "$@"
fi

if [ "$1" = 'influxd' ]; then
	/init-influxdb.sh "${@:2}"
fi

mkdir -p /var/log/supervisor/
mkdir -p /var/log/influxdb/

exec /usr/sbin/crond -f &
exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
