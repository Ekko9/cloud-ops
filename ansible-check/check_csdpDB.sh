#!/bin/bash

cd $(dirname $0)

INTERACTIVE_MODE=off

if [ ${INTERACTIVE_MODE} = off ]; then
	LOG_DEFAULT_COLOR=""
	LOG_INFO_COLOR=""
	LOG_SUCCESS_COLOR=""
	LOG_WARN_COLOR=""
	LOG_ERROR_COLOR=""
else
	LOG_DEFAULT_COLOR=$(tput sgr 0)
	LOG_INFO_COLOR=$(tput sgr 0)
	LOG_SUCCESS_COLOR=$(tput setaf 2)
	LOG_WARN_COLOR=$(tput setaf 3)
	LOG_ERROR_COLOR=$(tput setaf 1)
fi

color_log() {
	
	local log_text=$1
	local log_level=$2
	local log_color=$3
	
	printf "${log_color} [$(date +"%Y-%m-%d %H:%M:%S %Z")] [${log_level}] ${log_text} ${LOG_DEFAULT_COLOR}\n"
}

log_info() {  
	
	color_log "$1" "INFO" "${LOG_INFO_COLOR}";

}

log_success() {

	color_log "$1" "SUCCESS" "${LOG_SUCCESS_COLOR}";

}

log_warning() {
	
	color_log "$1" "WARNING" "${LOG_WARN_COLOR}";
	
}

log_error() {

	color_log "$1" "ERROR" "${LOG_ERROR_COLOR}"; 

}


start_time=$(date +'%Y-%m-%d %H:%M:%S')

log_info " 检查数据库状态，开始时间：${start_time} "
log_info "******************** DB1 ********************"
ansible -i csdp.bak mysql1 -m shell -a "date&&mysql  -N -e "status" -uroot -pAKR80YB0u0@ctsi"

log_info "******************** DB2 ********************"
ansible -i csdp.bak mysql2 -m shell -a "date&&mysql  -N -e "status" -uroot -pAKR80YB0u0@ctsi"

log_info "******************** 从节点状态 ********************"
ansible -i csdp.bak mysql2 -m shell -a "date && mysql -e 'show slave status \G' -uroot -pAKR80YB0u0@ctsi |grep Running"

end_time=$(date +'%Y-%m-%d %H:%M:%S')
start_seconds=$(date --date="$start_time" +%s)
end_seconds=$(date --date="$end_time" +%s)

log_info " 数据库巡检结束，结束时间：${end_time} "
log_info " 巡检耗时："$((end_seconds-start_seconds))"s "


sh check_csdpPort.sh
