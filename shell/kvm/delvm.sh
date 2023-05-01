#!/bin/bash

vm=$1

function isgreen() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32m$1==========>succeed\e[0m"
    else
        echo -e "\e[31m$1==========>failed\e[0m"
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

function isrunning() {
    state=$(virsh dominfo "$1" | grep State | awk '{print $2}')
    if [[ "$state" == "running" ]]; then
        return 0
    else
        return 1
    fi
}

function delvm() {
    virsh undefine "$1" >/dev/null 2>&1
    rm -rf /etc/libvirt/qemu/"$1".xml
    rm -rf /opt/vm/"$1".qcow2
}

# main
echo "delete vm"
isexist "$vm"
isrunning "$vm"
code=$?
if [ $code -eq 0 ]; then
    virsh destroy "$vm" >/dev/null 2>&1
    isgreen 关闭"$vm"
fi
delvm "$vm"
isgreen 删除"$vm"

echo "clear hosts"
sed -i '/'"$vm"'/d' /etc/hosts
isgreen "clear hosts"

echo "clear known_hosts"
sed -i '/'"$vm"'/d' /root/.ssh/known_hosts
isgreen "clear known_hosts"
