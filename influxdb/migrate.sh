#!/bin/bash
echo "y" | influx_inspect buildtsi -datadir /var/lib/influxdb/data/ -waldir /var/lib/influxdb/wal/
