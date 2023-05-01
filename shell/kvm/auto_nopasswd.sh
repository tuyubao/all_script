#!/bin/bash

# 检查软件是否安装
if ! which expect >/dev/null 2>&1; then
    echo "开始安装 expect"
    yum install -y expect
else
    echo "expect installed"
fi

#判断是否存在公钥,不存在就创建
[ ! -f /root/.ssh/id_rsa.pub ] && ssh-keygen -P '' -f /root/.ssh/id_rsa &>/dev/null

#发送公钥
host=$1
user=root
passwd=$2

expect <<EOF
  set timeout 10
  spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user@$host
  expect {
    "*yes/no" {send "yes\n";exp_continue}
    "*password" {send "$passwd\n"}
  }
  expect eof
EOF

#spawn ssh root@mc-ecs-clone hostname
#expect "*password"
#send "Admin@123...\n"
#expect eof
