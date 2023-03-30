#!/bin/bash

# 更新nginx
cd $(dirname $0)

version=$1
service=nginx

ansible-playbook -i csdp update_nginx.yml -e "version=${version} service=${service}"
