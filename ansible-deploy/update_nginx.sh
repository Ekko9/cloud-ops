#!/bin/bash

# 更新nginx
cd $(dirname $0)

version=$1
service=nginx
tag=$2

ansible-playbook -i csdp --tags=${tag} update_nginx.yml -e "version=${version} service=${service}"
