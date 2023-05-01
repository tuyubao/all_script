#!/bin/bash

function isgreen() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32m$1==========>succeed\e[0m"
    else
        echo -e "\e[31m$1==========>failed\e[0m"
    fi
}

# 添加到hosts解析
new_vm=$1
vm_ip=$(virsh domifaddr "$new_vm" | grep ipv4 | awk -F " " '{print $NF}' | awk -F "/" '{print $1}')
if [ "$vm_ip" = "" ]; then
    ip not found > /dev/null 2>&1
    isgreen 解析"$new_vm"
else
    echo "$vm_ip"
    echo "$vm_ip  $new_vm" >>/etc/hosts
    isgreen 解析"$new_vm"
fi

# 配置免密登录
# 1、判断sshpass软件是否安装
pkg=tree
if ! rpm -q "$pkg" &>/dev/null 2>&1; then
    echo "install $pkg ..."
    yum install -y "$pkg" >/dev/null 2>&1
fi
# 2、配置免密登录
pwd=000000
sshpass -p "$pwd" ssh-copy-id -o StrictHostKeyChecking=no -f "$vm_ip" >/dev/null 2>&1
isgreen 免密登录
