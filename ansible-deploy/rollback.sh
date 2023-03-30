#!/bin/bash


cd $(dirname $0)

version=$1
service=(${2//,/ })

for i in ${service[@]}
do
	ansible-playbook -i csdp rollback.yml -e "version=${version} service=${i}"
done
