#!/bin/bash

INTERACTIVE_MODE=off

if [ ${INTERACTIVE_MODE} = off ];then
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

log_info " 开始检查CMS服务指标，开始时间：${start_time} "

log_info "******************** 检查服务 cms-zg-ct-1 ********************"
ansible -i cms cmszg -m shell -a "ps -ef | grep  cms-zg-ct-1 | grep -v grep"

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cms-zg-ct-2 ********************"
	ansible -i cms cmszg -m shell -a "ps -ef | grep  cms-zg-ct-2 | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cms-zg-it-1 ********************"
	ansible -i cms cmszg -m shell -a "ps -ef | grep  cms-zg-it-1 | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cms-zg-it-2 ********************"
	ansible -i cms cmszg -m shell -a "ps -ef | grep  cms-zg-it-2 | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
	log_info "******************** 检查服务 cms-data-ct-1 ********************"
	ansible -i cms cmsdata -m shell -a "ps  -ef | grep cms-data-ct-1 | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cms-data-ct-2 ********************"
        ansible -i cms cmsdata -m shell -a "ps  -ef | grep cms-data-ct-2 | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cms-data-it-1 ********************"
        ansible -i cms cmsdata -m shell -a "ps  -ef | grep cms-data-it-1 | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cms-data-it-2 ********************"
        ansible -i cms cmsdata -m shell -a "ps  -ef | grep cms-data-it-2 | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cms-pond ********************"
        ansible -i cms software -m shell -a "ps -ef | grep cms-pond | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

#if [ $? -eq 0 ]; then
#        log_info "******************** 检查服务 kairosdb ********************"
#        ansible -i cms software -m shell -a "ps -ef | grep kairosdb | grep -v grep"
#else
#        log_error "******************** 检测失败，请排查原因 ********************"
#        exit 1
#fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 redis ********************"
        ansible -i cms software -m shell -a "ps -ef | grep redis | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 cassandra ********************"
        ansible -i cms software -m shell -a "ps -ef | grep cassandra | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 蓝鲸 ********************"
        ansible -i csdp.bak lanj -m shell -a "ps -ef | grep cmdb | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

if [ $? -eq 0 ]; then
        log_info "******************** 检查服务 zookeeper ********************"
        ansible -i csdp.bak zk -m shell -a "ps -ef | grep zookeeper | grep -v grep"
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi


end_time=$(date +'%Y-%m-%d %H:%M:%S')
start_seconds=$(date --date="$start_time" +%s)
end_seconds=$(date --date="$end_time" +%s)

if [ $? -eq 0 ]; then
        log_info " CMS服务指标检查结束，结束时间：${end_time} "
        log_info " 检查耗时："$((end_seconds-start_seconds))"s "
else
        log_error "******************** 检测失败，请排查原因 ********************"
        exit 1
fi

