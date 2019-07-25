#!/usr/bin/env bash

yum remove \
    docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine

yum update -y
yum install -y amazon-linux-extras yum-utils device-mapper-persistent-data lvm2
amazon-linux-extras install -y docker
amazon-linux-extras install -y nginx1.12
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user


#Add K8s repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install kubelet and kubectl
yum install -y kubelet-${kubernetes_version}-0.x86_64 kubectl-${kubernetes_version}-0.x86_64 --disableexcludes=kubernetes

# Install go
wget -q https://dl.google.com/go/go${go_version}.linux-amd64.tar.gz
tar -C /usr/local -xzf go${go_version}.linux-amd64.tar.gz

cat <<EOF > /etc/profile.d/gopath.sh
PATH=$PATH:/usr/local/go/bin
EOF

# Install cfssl
wget -q https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget -q https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssl_linux-amd64
chmod +x cfssljson_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
