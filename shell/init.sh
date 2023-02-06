# /bin/bash

# 关闭防火墙和selinux
systemctl disable firewalld --now
setenforce 0		# 临时关闭
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config  # 永久关闭

# 关闭交换分区
swapoff -a 		# 临时关闭
sed -i 's/^[^#].*swap*/#&/g'  /etc/fstab

# 修改内核参数
modprobe br_netfilter
echo "modprobe br_netfilter" >> /etc/profile
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf

# 配置阿里镜像源
rm -rf /etc/yum.repos.d/*
#base源：
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
#epel源：
wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo
#docker源：
yum install -y yum-utils device-mapper-persistent-data lvm2 vim wget bash-completion net-tools yum-utils tree 
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
#kubernetes源：
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF
yum repolist

# 配置时间同步
yum install -y  ntpdate
ntpdate cn.pool.ntp.org
echo "* */1 * * * /usr/sbin/ntpdate   cn.pool.ntp.org" >> /var/spool/cron/root
systemctl restart crond 

# 开启ipvs
if [ !-f "ipvs.modules" ]
then
echo "Missing files in the current directory: ipvs.modules"
else
mv ipvs.modules  /etc/sysconfig/modules/
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep ip_vs
fi

# 安装docker
yum install -y docker-ce
systemctl enabled docker --now

# 配置docker镜像加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://t37y9kai.mirror.aliyuncs.com"],
"exec-opts": ["native.cgroupdriver=systemd"]				
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
docker --version





