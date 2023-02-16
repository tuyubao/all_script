# ssh连接优化
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
systemctl restart sshd

# 安全优化
systemctl disable firewalld --now
setenforce 0		
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config  