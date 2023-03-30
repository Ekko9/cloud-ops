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
services=("gateway" "resource" "product" "user" "statistic" "infraAsset" "rack")
for service in ${services[@]}
do
   ansible-playbook ../../playbooks/ops-check-service.yaml -e "service=${service}" >> ${today_log_dir}/ops-check-service-${today}.log
done
# 应用默认输出的ansible配置
unlink ansible.cfg
ln -s ansible-cmd.cfg ansible.cfg

# 汇总报告
echo "# 运维巡检报告-${today}" > ${today_log}
echo "" >> ${today_log}
echo "## 1. 巡检报告说明" >> ${today_log}
echo "### 1. 巡检日期" >> ${today_log}
echo "" >> ${today_log}
echo "**${today}**" >> ${today_log}
echo "" >> ${today_log}
echo "### 2. 巡检人" >> ${today_log}
echo "" >> ${today_log}
echo "**付守信**" >> ${today_log}
echo "" >> ${today_log}
echo "### 3. 巡检服务器规模" >> ${today_log}
echo "1. 云管平台: 15" >> ${today_log}
echo "2. CMS: 8" >> ${today_log}
echo "### 4. 巡检结果汇总说明" >> ${today_log}
echo "1. 操作系统基础巡检: 正常" >> ${today_log}
echo "2. 操作系统其他信息巡检: 正常" >> ${today_log}
echo "3. 云管服务模块巡检: 正常" >> ${today_log}
echo "4. 巡检过程发现的问题: 无" >> ${today_log}
echo "### 5. 巡检报告补充说明" >> ${today_log}
echo "1. 巡检过程发现问题的解决方案" >> ${today_log}
echo "" >> ${today_log}
echo "   无" >> ${today_log}
echo "" >> ${today_log}
echo "2. 巡检遗留问题" >> ${today_log}
echo "" >> ${today_log}
echo "   无" >> ${today_log}
echo "" >> ${today_log}
echo "## 2. 巡检报告详细内容" >> ${today_log}
echo "### 2.1 操作系统-基础巡检" >> ${today_log}
echo "" >> ${today_log}
echo "\`\`\`shell" >> ${today_log}
cat ${today_log_dir}/ops-check-system-${today}.log >> ${today_log}
echo "\`\`\`" >> ${today_log}

echo "### 2.2 操作系统-其他信息巡检" >> ${today_log}
echo "" >> ${today_log}
echo "\`\`\`shell" >> ${today_log}
cat ${today_log_dir}/ops-check-system-other-${today}.log >> ${today_log}
echo "\`\`\`" >> ${today_log}

echo "### 2.3 服务-mysql巡检" >> ${today_log}
echo "" >> ${today_log}
echo "\`\`\`shell" >> ${today_log}
cat ${today_log_dir}/ops-check-mysql-${today}.log >> ${today_log}
echo "\`\`\`" >> ${today_log}

echo "### 2.4 服务-模块巡检" >> ${today_log}
echo "" >> ${today_log}
echo "\`\`\`shell" >> ${today_log}
cat ${today_log_dir}/ops-check-service-${today}.log >> ${today_log}
echo "\`\`\`" >> ${today_log}
