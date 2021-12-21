#!/bin/bash
task_name="aggregation_reporting"
udf_path="/var/lib/udf"
name="udf"
count=0
while true
do
    kapacitor list tasks
    if [ $? -eq 0 ]; then
        break
    elif [ $count -gt 30 ] ; then
        echo "[$(date)] failed to list tasks due to something wrong"
        exit 1
    else
        echo "[$(date)] kapacitor is not ready, sleep 5 "
        (( count++ ))
        sleep 5
    fi
done

kapacitor define ${task_name} -tick ${udf_path}/${name}.tick

result=$(echo '{"api":"/aggregation_rule","method":"get"}' | nc -N -U /var/run/qundr-aggregation-reporting.sock)
for k in $(jq '.result[].schedule_type' -r <<< "$result");do
    if [ x"$k" = x"i" ];then
        echo "[$(date)] rule match"
        kapacitor enable ${task_name}
        break
    fi
done
