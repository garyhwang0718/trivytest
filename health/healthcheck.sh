#!/bin/bash
kapacitor=1
influxdb=1
curl -s 127.0.0.1:9092/kapacitor/v1/ping
if [ $? -eq 0 ] ;then
    kapacitor=0
fi
curl -s --unix-socket /var/run/influxdb/influxdb.sock -G 'http://localhost/ping?verbose=true' >/dev/null
if [ $? -eq 0 ] ;then
    influxdb=0
fi

if [ $kapacitor -eq 0 ] && [ $influxdb -eq 0 ];then
    echo "{\"error_code\":0,\"status\":{\"influxdb\":$influxdb,\"kapacitor\":$kapacitor}}"
else
    echo "{\"error_code\":1,\"status\":{\"influxdb\":$influxdb,\"kapacitor\":$kapacitor}}"
fi
