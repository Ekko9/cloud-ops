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

log_info " 开始巡检CSDP，开始时间：${start_time} "

log_info "******************** CPU负载&使用情况 ********************"
ansible -i csdp.bak all -m shell -a "vmstat 3  5"

if [ $? -eq 0 ]; then
	log_info "******************** 检查内存使用情况 ********************"
	ansible -i csdp.bak all -m shell -a "free -m"
else
	log_error "******************** 检测失败，请排查原因 ********************"
	exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查uptime ********************"
	ansible -i csdp.bak all -m shell -a "uptime"
else
	log_error "******************** 检测失败，请排查原因 ********************"
	exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 采集cpu使用率 ********************"
	ansible -i csdp.bak all -m shell -a "sar -u 1 5"
else
	log_error "******************** 检测失败，请排查原因 ********************"
	exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查磁盘使用情况 ********************"
	ansible -i csdp.bak all -m shell -a "df -h"
else
	log_error "******************** 检测失败，请排查原因 ********************"
	exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查Inode使用情况 ********************"
	ansible -i csdp.bak all -m shell -a "df -i"
else
	log_error "******************** 检测失败，请排查原因 ********************"
	exit 1
fi

end_time=$(date +'%Y-%m-%d %H:%M:%S')
start_seconds=$(date --date="$start_time" +%s)
end_seconds=$(date --date="$end_time" +%s)

log_info " CSDP巡检结束，结束时间：${end_time} "
log_info " 巡检耗时："$((end_seconds-start_seconds))"s "

#sh check_csdpDB.sh
