#!/bin/bash
INFLUXDB_INIT_PORT="8086"
INFLUX_CMD="influx -host 127.0.0.1 -port $INFLUXDB_INIT_PORT -execute "
INIT_QUERY="SHOW DATABASES"
for i in {30..0}; do
    if $INFLUX_CMD "$INIT_QUERY" &> /dev/null; then
        break
    fi
    echo "[$(date)] [initcq] influxdb init process in progress..."
    sleep 60
done
if [ "$i" = 0 ]; then
        echo >&2 "[$(date)] [initcq] influxdb init process failed."
        exit 1
fi

jsonResult=( $(curl -s --unix-socket /var/run/influxdb/influxdb.sock  -G 'http://localhost/query' --data-urlencode "q=SHOW CONTINUOUS QUERIES" | jq -r '[.results[].series[] | select(.name == "ndr_management").values[][0]]?') )
if [ $? -eq 0 ]; then
    echo "[initcq] drop current continuous query: ndr_management"
    for element in "${jsonResult[@]}"
    do
        if [ x"$element" != x"[" ] && [ x"$element" != x"]" ]; then
            newElement=$(echo $element | sed 's/,//g')
            influx -execute="DROP CONTINUOUS QUERY "${newElement}" ON "ndr_management"" -database=ndr_management
        fi
    done
fi
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_10m" ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_10m" FROM threat_secops_event GROUP BY time(10m),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_1h" ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_1h" FROM threat_secops_event GROUP BY time(1h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_2h" ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_2h" FROM threat_secops_event GROUP BY time(2h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_12h" ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_12h" FROM threat_secops_event GROUP BY time(12h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_2d" ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_2d" FROM threat_secops_event GROUP BY time(2d),* END" -database=ndr_management

influx -execute="CREATE CONTINUOUS QUERY cq_dta_pkts_10m ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT MEAN(pkt_cnt) INTO ndr_management.autogen.dta_pkts_10m FROM ndr_management.autogen.dta_pkts GROUP BY time(10m), * END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY cq_dta_pkts_1h ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT MEAN(pkt_cnt) INTO ndr_management.autogen.dta_pkts_1h FROM ndr_management.autogen.dta_pkts GROUP BY time(1h), * END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY cq_dta_pkts_2h ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT MEAN(pkt_cnt) INTO ndr_management.autogen.dta_pkts_2h FROM ndr_management.autogen.dta_pkts GROUP BY time(2h), * END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY cq_dta_pkts_12h ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT MEAN(pkt_cnt) INTO ndr_management.autogen.dta_pkts_12h FROM ndr_management.autogen.dta_pkts GROUP BY time(12h), * END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY cq_dta_pkts_2d ON ndr_management RESAMPLE EVERY 5m BEGIN SELECT MEAN(pkt_cnt) INTO ndr_management.autogen.dta_pkts_2d FROM ndr_management.autogen.dta_pkts GROUP BY time(2d), * END" -database=ndr_management

