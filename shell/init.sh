#!/bin/bash

function isgreen() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32m$1==========>succeed\e[0m"
    else
        echo -e "\e[31m$1==========>failed\e[0m"
    fi
}

function network() {
    #超时时间
    local timeout=1

    #目标网站
    local target=www.baidu.com

    #获取响应状态码
    local ret_code=$(curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1)

    if [ "$ret_code" = "200" ]; then
        #网络畅通
        echo -e "\e[32m网络畅通==========>succeed\e[0m"
        return 0
    else
        #网络不畅通
        echo -e "\e[31m网络不畅通，请检查网络==========>succeed\e[0m"
        return 1
    fi

    return 0
}

#关闭防火墙
echo "关闭防火墙"
systemctl disable firewalld --now >/dev/null 2>&1
isgreen "关闭防火墙"

#关闭selinux
echo "关闭selinux"
setenforce 0
isgreen "临时关闭"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
isgreen "永久关闭"

#配置阿里源
echo "开始配置阿里源"
network
code=$?
if [ $code -eq 0 ]; then
    rm -rf /etc/yum.repos.d/*
    curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo >/dev/null 2>&1
    isgreen "base源"
    curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo >/dev/null 2>&1
    isgreen "epel源"
fi

#安装常用软件
echo "install vim wget bash-completion net-tools"
yum install -y vim wget bash-completion net-tools >/dev/null 2>&1
isgreen "install pkgs"



#优化ssh连接
echo "优化ssh连接"
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
systemctl restart sshd
isgreen 优化ssh连接


echo -e "\e[32minitial option complete==========>succeed\e[0m"