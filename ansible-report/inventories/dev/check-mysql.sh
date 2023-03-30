#!/bin/bash
# OpenStack平台自动化巡检脚本

log_dir_root=`pwd`/logs
today=`date +%Y-%m-%d`
today_log_dir=${log_dir_root}/$today
today_log=${today_log_dir}/ops_check_${today}.md

function dir_exists()
{
    if [ ! -d $1 ];then
        mkdir -p $1
    else
        :
    fi
}

# 创建log目录
dir_exists ${today_log_dir}

# 应用带callbak模块的ansible输出
unlink ansible.cfg
ln -s ansible-callbak.cfg ansible.cfg

# 执行ansible-playbook任务
ansible-playbook ../../playbooks/ops-check-system.yaml > ${today_log_dir}/ops-check-system-${today}.log
ansible-playbook ../../playbooks/ops-check-system-other.yaml > ${today_log_dir}/ops-check-system-other-${today}.log
ansible-playbook ../../playbooks/ops-check-mysql.yaml > ${today_log_dir}/ops-check-mysql-${today}.log
# 应用默认输出的ansible配置
unlink ansible.cfg
ln -s ansible-cmd.cfg ansible.cfg

# 汇总报告
echo "# 运维巡检报告-${today}" > ${today_log}
echo "" >> ${today_log}

echo "## 1. 操作系统-基础巡检" >> ${today_log}
echo "" >> ${today_log}
echo "\`\`\`shell" >> ${today_log}
cat ${today_log_dir}/ops-check-system-${today}.log >> ${today_log}
echo "\`\`\`" >> ${today_log}

echo "## 2. 操作系统-其他信息巡检" >> ${today_log}
echo "" >> ${today_log}
echo "\`\`\`shell" >> ${today_log}
cat ${today_log_dir}/ops-check-system-other-${today}.log >> ${today_log}
echo "\`\`\`" >> ${today_log}

echo "## 3. 服务-mysql巡检" >> ${today_log}
echo "" >> ${today_log}
echo "\`\`\`shell" >> ${today_log}
cat ${today_log_dir}/ops-check-mysql-${today}.log >> ${today_log}
echo "\`\`\`" >> ${today_log}
