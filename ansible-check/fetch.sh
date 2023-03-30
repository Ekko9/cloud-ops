#!/bin/bash

cd /opt/script/ansible
iplist=$(cat ip)

for i in ${iplist}
do
	echo "=================${i}================"
	ansible-playbook -i csdp.bk fetch.yml -e "host=${i}"
done


