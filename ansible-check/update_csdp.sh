#!/bin/bash

# 执行脚本方式
#sh update_csdp.sh version service tag
# version：代表备份上个版本
# service：代表执行的后端服务
# tag："stopapp" "backup" "scp" "updateapp" "startapp" "check"

# service可以写多个，执行单个tag
#sh update_csdp.sh csdp3.29 "file,rack" check
# service可以写一个，执行所有tag
#sh update_csdp.sh csdp3.29 "rack" tagged

cd $(dirname $0)

version=$1
service=(${2//,/ })

tag=$3

for i in ${service[@]}
do
	ansible-playbook -i csdp --tags=${tag} update.yml -e "version=${version} service=${i}"
done

