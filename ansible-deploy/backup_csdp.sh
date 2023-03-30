#!/bin/bash

# 执行脚本方式

# version：代表现网运行版本
# service：代表备份的后端服务

# service可以写多个
# sh backup_csdp.sh csdp3.31 "file,rack" 
# service可以写一个
# sh backup_csdp.sh csdp3.31 "rack"

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


version=$1
service=(${2//,/ })

log_info "获取模块配置文件"

for i in ${service[@]}
do
        log_info "获取${i}配置文件"
	ansible-playbook -i csdp csdpfetch.yml -e "version=${version} service=${i}"
done

if [ $? -eq 0 ]; then
    log_info "配置文件获取成功"
else
    log_error "配置文件获取失败，请排查原因"
    exit 1
fi

configdir=/opt/script/csdp/csdpbackup
log_info "打包配置文件"
cd ${configdir}
tar -czf ${version}.tar.gz *
result=$(ls ${configdir})
if [ $? -eq 0 ]; then
    log_info "${result}"
else
    log_error "打包失败"
    exit 1
fi

log_info "拷贝配置文件至备份机器"
cd $(dirname $0)
ansible-playbook -i csdp csdpcopy.yml -e "version=${version}"

