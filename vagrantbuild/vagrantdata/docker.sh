#!/usr/bin/env bash
dockerversion="17.06.0.ce-1.el7.centos"
installedversion=$(sudo docker version --format '{{.Server.Version}}')

if [[ ${installedversion:0:7} != ${dockerversion:0:7} ]]; then
  echo -e "Installing Docker Engine CE $dockerversion"
  # install docker
  sudo yum remove docker docker-common docker-selinux docker-engine -y
  sudo yum install yum-utils device-mapper-persistent-data lvm2 -y
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum makecache fast
  sudo yum install docker-ce-$dockerversion -y
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -a -G docker vagrant

  # install net-tools for netstat so docker-machine create completes
  sudo yum install net-tools -y
fi
