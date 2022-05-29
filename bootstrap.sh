#!/bin/bash

#Disable selinux or permissive 

selinuxenabled && setenforce 0

cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF

#Install nfs-utils
sudo dnf install -y nfs-utils 

#Install utils
dnf install -y epel-release
dnf install -y nano ncdu tree
