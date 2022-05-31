#!/bin/bash

#Disable selinux or permissive 

selinuxenabled && setenforce 0

cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF

#Repos
cd /etc/yum.repos.d/; sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*; sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

#Install repo
dnf install -y epel-release

#Install nfs-utils
sudo dnf install -y nfs-utils 

#Install utils
dnf install -y nano ncdu tree

#Update nfs.conf
cd /etc/; sed -i '/tcp=y/a\udp=y' nfs.conf
