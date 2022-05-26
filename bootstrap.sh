#!/bin/bash

#Disable selinux or permissive 

selinuxenabled && setenforce 0

cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF

#Install nfs-utils
sudo dnf install nfs-utils -y

#Install utils
yum install -y epel-release
yum install -y nano ncdu tree