#!/bin/bash
# author tyb

function isgreen() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32m$1==========>succeed\e[0m"
    else
        echo -e "\e[31m$1==========>failed\e[0m"
    fi
}

# 判断模板虚拟机是否开机
function isrunning() {
    state=$(virsh dominfo "$1" | grep State | awk '{print $2}')
    if [[ "$state" == "running" ]]; then
        return 0
    else
        return 1
    fi
}

# 克隆
new=$1
# 默认克隆centos7.9-template
old=$2

echo "start clone"
isrunning "${old:-"centos7.9-template"}"
code=$?
if [ $code -eq 0 ]; then
    virsh destroy "${old:-"centos7.9-template"}" > /dev/null 2>&1
fi
virt-clone --auto-clone -o "${old:-"centos7.9-template"}" -n "$new"
isgreen "$old"clone"$new"
