#!/bin/bash

NDR_PATH="/.data/qne-qundr"
IMAGE_TAR="qinfluxdbkapacitor_base.tar"
INSTALL_PATH=${NDR_PATH}/sec-ops/doc/qinfluxdbkapacitor-image
SCRIPT_PATH=${NDR_PATH}/sec-ops/scripts
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
   env $(cat ${NDR_PATH}/sec-ops/.env) docker-compose -f ${NDR_PATH}/sec-ops/scripts/docker-compose.yml down
   if [ "x0" != "x$?" ] ; then
       echo "docker stop and rm qundr-sec-ops failure" >> ${LOG_FILE}
       exit 1
   fi

}

load_image()
{
	local ret="$(docker load --input ${INSTALL_PATH}/${IMAGE_TAR})"
	if [ "x0" != "x$?" ] ; then
		echo "docker load --input ${INSTALL_PATH}/${IMAGE_TAR} failure" >> ${LOG_FILE}
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

start_sec_ops()
{
   env $(cat ${NDR_PATH}/sec-ops/.env) docker-compose -f ${NDR_PATH}/sec-ops/scripts/docker-compose.yml up -d
   if [ "x0" != "x$?" ] ; then
       echo "docker run sec-ops failure" >> ${LOG_FILE}
       exit 1
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
	*)
		echo "Usage: $0 {load_image|rm_image}"
		exit 1
esac

exit 0
