#!/bin/bash
# OpenStack平台自动化巡检脚本

log_dir_root=`pwd`/logs
today=`date +%Y-%m-%d`
today_log_dir=${log_dir_root}/$today

function dir_exists()
{
    if [ ! -d $1 ];then
        mkdir -p $1
    else
        :
    fi
}

dir_exists ${today_log_dir}

cd /etc/ansible/roles/ansible-playbooks-ctsi-openstack-autoops/inventories/dev/

ansible-playbook ../../playbooks/check-openstack-controller.yml > ${today_log_dir}/openstack_controller_check_${today}.log
ansible-playbook ../../playbooks/check-openstack-compute.yml > ${today_log_dir}/openstack_compute_check_${today}.log
ansible-playbook ../../playbooks/check_roller.yml > ${today_log_dir}/roller_check_${today}.log
ansible-playbook ../../playbooks/check_nfs.yml > ${today_log_dir}/nfs_check_${today}.log

# 汇总报告
echo "===============================巡检报告汇总-${today}===============================" > ${today_log_dir}/openstack_check_${today}.log
echo

echo "===============================controller===============================" >> ${today_log_dir}/openstack_check_${today}.log
echo
cat ${today_log_dir}/openstack_controller_check_${today}.log >> ${today_log_dir}/openstack_check_${today}.log

echo "===============================compute===============================" >> ${today_log_dir}/openstack_check_${today}.log
echo
cat ${today_log_dir}/openstack_compute_check_${today}.log >> ${today_log_dir}/openstack_check_${today}.log

echo "===============================roller===============================" >> ${today_log_dir}/openstack_check_${today}.log
echo
cat ${today_log_dir}/roller_check_${today}.log >> ${today_log_dir}/openstack_check_${today}.log

echo "===============================nfs===============================" >> ${today_log_dir}/openstack_check_${today}.log
echo
cat ${today_log_dir}/nfs_check_${today}.log >> ${today_log_dir}/openstack_check_${today}.log

echo
echo "===============================巡检报告结束-${today}===============================" >> ${today_log_dir}/openstack_check_${today}.log


find ${log_dir_root} -name '*' -mtime +15 -exec rm -f {} \;


