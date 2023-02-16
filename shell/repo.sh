# 配置阿里镜像源   base源&epel源
rm -rf /etc/yum.repos.d/*
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

# nginx安装源
cat > /etc/yum.repos.d/nginx.repo << "EOF"
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

#docker源
yum install -y yum-utils device-mapper-persistent-data lvm2 vim wget bash-completion net-tools yum-utils tree
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 阿里云容器镜像加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://t37y9kai.mirror.aliyuncs.com"],
"exec-opts": ["native.cgroupdriver=systemd"]		    
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
