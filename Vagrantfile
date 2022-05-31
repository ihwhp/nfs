# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'open3'
require 'fileutils'

Vagrant.configure("2") do |config|

config.vm.define "srvnfs" do |server|
  config.vm.boot_timeout = 420
  config.vm.box = 'centos/8.4'
  config.vm.box_url = 'http://cloud.centos.org/centos/8/vagrant/x86_64/images/CentOS-8-Vagrant-8.4.2105-20210603.0.x86_64.vagrant-virtualbox.box'
  server.vm.host_name = 'srvnfs'
  server.vm.network :private_network, ip: "192.168.56.40"
  server.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
	vb.cpus = "2"
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end


  server.vm.provision "shell",
    name: "Bootstrap configuration",
    path: "bootstrap.sh"
  end


  config.vm.define "clnfs" do |client|
    config.vm.boot_timeout = 420
    client.vm.box = 'centos/8.4'
    config.vm.box_url = 'http://cloud.centos.org/centos/8/vagrant/x86_64/images/CentOS-8-Vagrant-8.4.2105-20210603.0.x86_64.vagrant-virtualbox.box'
    client.vm.host_name = 'nfsclient'
    client.vm.network :private_network, ip: "192.168.56.41"
    client.vm.provider :virtualbox do |vb|
      vb.memory = "1024"
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end


    client.vm.provision "shell", inline: <<-SHELL
	      mkdir -p ~root/.ssh
              cp ~vagrant/.ssh/auth* ~root/.ssh
	      cd /etc/yum.repos.d/; sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*; sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
	      dnf install -y nano nfs-utils

	SHELL
  end
end
 # config.vm.define "serverv3" do |servernfs|
 #   servernfs.vm.box = 'centos/7.8'
 #   servernfs.vm.box_url = 'http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-2004_01.VirtualBox.box'
 #   servernfs.vm.host_name = 'nfsv3'
 #   servernfs.vm.network :private_network, ip: "192.168.56.42"
 #   servernfs.vm.provider :virtualbox do |vb|
 #     vb.memory = "1024"
 #	  ccc
 #     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
 #   end
 # end
