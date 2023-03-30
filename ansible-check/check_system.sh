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

log_info " 开始检查CMS系统指标，开始时间：${start_time} "

log_info "******************** CPU负载&使用情况 ********************"
ansible -i cms all -m shell -a "vmstat 3  5"

if [ $? -eq 0 ]; then
	log_info "******************** 检查CPU核心数 ********************"
	ansible -i cms all -m shell -a "cat  /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c"
else
	log_error "******************** 检测失败，请排查原因 ********************"
	exit 1
fi

if [ $? -eq 0 ]; then	
	log_info "******************** 检查CPU占用TOP10 ********************"
	ansible -i cms all -m shell -a "ps -aux | sort  -k3nr | head -10"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查内存使用情况 ********************"
	ansible -i cms all -m shell -a "free -m"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查内存占用TOP10 ********************"
	ansible -i cms all -m shell -a "ps -aux | sort  -k4nr | head -10"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查磁盘容量使用情况 ********************"
	ansible -i cms all -m shell -a "df -h"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查Inode使用情况 ********************"
	ansible -i cms all -m shell -a "df -i"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查IP、MAC地址 ********************"
	ansible -i cms all -m shell -a "ip a | grep  inet | awk -F/ '{print $1}' | awk '{print $2}' | grep -v 127.0.0.1 | sed 1d"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 网卡流量 ********************"
	ansible -i cms all -m shell -a "netstat -i"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 端口监听状态 ********************"
	ansible -i cms all -m shell -a "netstat -ntulp"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查系统类型 ********************"
	ansible -i cms all -m shell -a "cat  /etc/redhat-release"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查内核版本 ********************"
	ansible -i cms all -m shell -a "uname -r"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检测最后启动时间 ********************"
	ansible -i cms all -m shell -a "who -b"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检测uptime ********************"
	ansible -i cms all -m shell -a "uptime"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查是否启用SElinux ********************"
	ansible -i cms all -m shell -a "getenforce"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

end_time=$(date +'%Y-%m-%d %H:%M:%S')
start_seconds=$(date --date="$start_time" +%s)
end_seconds=$(date --date="$end_time" +%s)

if [ $? -eq 0 ]; then
	log_info " CMS系统指标检查结束，结束时间：${end_time} "
	log_info " 检查耗时："$((end_seconds-start_seconds))"s "
else
	log_error "******************** 检测失败，请排查原因 ********************"
	exit 1
fi


if [ ! -f "./check_service.sh" ]; then
	log_error "******************** check_service.sh 文件不存在 ********************"
	exit 1
else
	sh check_service.sh
fi
