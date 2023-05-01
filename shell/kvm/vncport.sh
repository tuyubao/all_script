#!/bin/bash

function isgreen() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32m$1==========>succeed\e[0m"
    else
        echo -e "\e[31m$1==========>failed\e[0m"
    fi
}

function isRightVncport() {
    if [ "$port" -ge 5900 ] && [ "$port" -le 5999 ]; then
        # echo "$port"
        return 0
    else
        return 1
    fi
}

function isUsed() {
    pid=$(/usr/sbin/lsof -i :$1 | grep -v "PID" | awk '{print $2}')
    #echo $pid
    if [ "$pid" != "" ]; then
        # 如果pid不为null，则说明有端口号存在，表示此端口号已被占用，返回1
        return 1
    else
        return 0
    fi
}

function isexist() {
    virsh dominfo "$1" >/dev/null 2>&1
    code=$?
    if [ $code -ne 0 ]; then
        echo -e "\e[31mnot found $1\e[0m"
        exit
    fi
}

hostname=$1
isexist "$hostname"
path="/etc/libvirt/qemu/$hostname.xml"
# echo "$path"
port=$2

isRightVncport "$port"
code=$?
if [ $code -eq 0 ]; then
    #判断端口号是否被占用
    isUsed "$port"
    code=$?
    if [ $code -eq 0 ]; then
        line=$(grep -n autoport "$path" | awk -F':' '{print $1}')
        sed -i "$line"d "$path"
        content="\ \ \ \ <graphics type='vnc' port='"$port"' autoport='no' listen='0.0.0.0'>"
        sed -i "$line i$content" "$path"
        isgreen "modifity vncport"
        virsh define "$path" >/dev/null 2>&1
        virsh destroy "$hostname" >/dev/null 2>&1
        virsh start "$hostname" >/dev/null 2>&1
        isgreen "$hostname restart"
    else
        echo "the ""$port"" in use!!!"
    fi
else
    echo "The vncport number should be: [5900 ~ 5999]"
fi
