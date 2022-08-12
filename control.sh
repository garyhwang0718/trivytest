#!/bin/bash

NDR_PATH_DYNAMIC="/var/lib/qne-qundr"
NDR_PATH_STATIC="/usr/share/qne-qundr"
NDR_PATH="/.data/qne-qundr"
IMAGE_TAR="qinfluxdbkapacitor_base.tar"
INSTALL_PATH=${NDR_PATH_STATIC}/sec-ops/doc/qinfluxdbkapacitor-image
SCRIPT_PATH=${NDR_PATH_DYNAMIC}/sec-ops/scripts
CMD_ECHO="/bin/echo"
CMD_AWK="/usr/bin/awk"
CMD_RM="/bin/rm"
CMD_CUT="/usr/bin/cut"

LOG_FILE="/tmp/control_qinfluxdbkapacitor.log"

exit_with_error_and_clean()
{
	exit 1
}

stop_sec_ops()
{
   env $(cat ${NDR_PATH_DYNAMIC}/sec-ops/.env) docker-compose -f ${NDR_PATH_DYNAMIC}/sec-ops/scripts/docker-compose.yml down
   if [ "x0" != "x$?" ] ; then
       echo "[$(date)] docker stop and rm qundr-sec-ops failure" >> ${LOG_FILE}
       exit 1
   fi

}

load_image()
{
	local ret="$(docker load --input ${INSTALL_PATH}/${IMAGE_TAR})"
	if [ "x0" != "x$?" ] ; then
		echo "[$(date)] docker load --input ${INSTALL_PATH}/${IMAGE_TAR} failure" >> ${LOG_FILE}
		exit 1
	else
		LOADED_IMAGE_NAME="$(echo ${ret} | grep "Loaded image" | cut -d ':' -f 2-3 | xargs)"
		`qsetcfg --app=qundr "Secops" "Docker_Image" ${LOADED_IMAGE_NAME}`
	fi
}

rm_image()
{
	IMAGE_TAG=`qgetcfg --app=qundr "Secops" "Docker_Image"`
	if [ "x" != "x${IMAGE_TAG}" ]; then
		ret="$(docker rmi -f ${IMAGE_TAG} 2>&1)"
		if [ "x0" != "x$?" ]; then
			echo "docker rmi -f ${IMAGE_TAG} failure"
			echo "${ret}"
		fi
	fi
}


init_debug_settings()
{
    APP_NAME="qundr"
    SECTION_NAME="ndr_manager"
    DEBUG_MODE="debug_mode"
    SEC_OPS_ENV=${NDR_PATH_DYNAMIC}"/sec-ops/.env"
    SUPERVISOR_CONF=${NDR_PATH_DYNAMIC}"/sec-ops/conf/supervisor/supervisord.conf"
    KAPACITOR_CONF=${NDR_PATH_DYNAMIC}"/sec-ops/conf/kapacitor/kapacitor.conf"

    result=$(/usr/bin/qgetcfg --app=$APP_NAME $SECTION_NAME $DEBUG_MODE)
    sed -i "/$DEBUG_MODE/d" $SEC_OPS_ENV
    if [ x"$result" = x"0" ] || [ x"$result" = x"" ]; then
        echo "$DEBUG_MODE=0" >> $SEC_OPS_ENV
        sed -i -e "s/logfile=.*/logfile=\/dev\/null/g" $SUPERVISOR_CONF
        sed -i -e "s/stderr_logfile = .*/redirect_stderr=true/g" $SUPERVISOR_CONF
        sed -i -e "s/stdout_logfile = .*/redirect_stdout=true/g" $SUPERVISOR_CONF
        sed -i -e 's/  level = .*/  level = \"ERROR\"/g' $KAPACITOR_CONF
    else
        echo "$DEBUG_MODE=1" >> $SEC_OPS_ENV
        sed -i -e "s/logfile=.*/logfile=\/var\/log\/supervisor\/supervisord.log/g" $SUPERVISOR_CONF
        sed -i -e "s/redirect_stdout=.*/stdout_logfile = \/var\/log\/supervisor\/%(program_name)s.log/g" $SUPERVISOR_CONF
        sed -i -e "s/redirect_stderr=.*/stderr_logfile = \/var\/log\/influxdb\/%(program_name)s.log/g" $SUPERVISOR_CONF
        sed -i -e 's/  level = .*/  level = \"INFO\"/g' $KAPACITOR_CONF
    fi
}

start_sec_ops()
{
    init_debug_settings
    docker images | grep 'qinfluxdbkapacitor_base'
    if ! [ $? -eq 0 ]; then
        echo "[$(date)] no sec-ops image. Load image again." >> ${LOG_FILE}
        load_image
    fi
    env $(cat ${NDR_PATH_DYNAMIC}/sec-ops/.env) docker-compose -f ${NDR_PATH_DYNAMIC}/sec-ops/scripts/docker-compose.yml up 2>&1 >/dev/null
    if [ "x0" != "x$?" ] ; then
        echo "[$(date)] docker run sec-ops failure" >> ${LOG_FILE}
        exit 1
    fi
}

retention_policy()
{
    RETENTION_POLICY=`qgetcfg --app=qundr "retention_policy" "default"`
    count=0
    while true
        do
        curl  --unix-socket /var/run/influxdb/influxdb.sock -G "127.0.0.1/ping"
        if [ $? -eq 0 ]; then
            break
        elif [ $count -gt 60 ] ; then
            echo "[$(date)] InfluxDB is not ready after retrying for 60 times." >> ${LOG_FILE}
            exit 1
        else
            echo "[$(date)] InfluxDB is not ready, sleep 60 seconds " >> ${LOG_FILE}
            (( count++ ))
            sleep 60
        fi
    done 
    if [ "x" = "x${RETENTION_POLICY}" ]; then
        echo "[$(date)] retention_policy: No default policy. Set to 180 days" >> ${LOG_FILE}
        curl -s --unix-socket /var/run/influxdb/influxdb.sock -X POST -G "127.0.0.1/query?db=ndr_management" --data-urlencode 'q=ALTER RETENTION POLICY "autogen" on ndr_management DURATION 180d DEFAULT'
        if [ $? -eq 0 ] ;then
            `qsetcfg --app=qundr "retention_policy" "default" "180d"`
        fi
    else
        result=$(curl -s --unix-socket /var/run/influxdb/influxdb.sock -G "127.0.0.1/query?db=ndr_management" --data-urlencode "q=SHOW RETENTION POLICIES" | jq -r '.results[].series[].values[][1]')
        echo "[$(date)] retention_policy: current default policy is $result " >> ${LOG_FILE}
    fi

}

version_compare()
{
    OLD_VERSION="$1"
    VERSION=`dpkg-query --show --showformat '${Version}' qundr-sec-ops`
    if [ x"${OLD_VERSION}" != x"" ];then
        dpkg --compare-versions "${OLD_VERSION}" le "1.0.0.q24"
        if [ $? -eq 0 ];then
            echo "Migrate to tsi1"
            source ${NDR_PATH}/sec-ops/.env
            docker run -d --rm --name qundr-sec-ops-migrate -v ${NDR_PATH_DYNAMIC}/${SEC_OPS_PATH}/conf/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro -v ${NDR_PATH}/${SEC_OPS_PATH}/lib/:/var/lib/influxdb/ ${IMAGE_TAG} bash
            docker exec qundr-sec-ops-migrate migrate.sh
            if [ $? -eq 0 ]; then
                echo "Migrate to tsi1 successfully."
            fi
            docker stop qundr-sec-ops-migrate
        fi
    fi
}

case "$1" in
	load_image)
		load_image
		;;
	rm_image)
		rm_image
		;;
        stop)
		stop_sec_ops
		;;
	start)
		start_sec_ops
		;;
        configure)
                retention_policy
                ;;
        ver_cmp)
                version_compare $2
                ;;
	*)
		echo "Usage: $0 {load_image|rm_image}"
		exit 1
esac

exit 0
