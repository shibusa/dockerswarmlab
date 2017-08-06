#!/usr/bin/env bash
echo -e "Creating daemon.json"
sudo systemctl stop docker
sudo cat << 'DAEMON' > /etc/docker/daemon.json
{
    "insecure-registries": ["192.168.1.30:5000"],
    "metrics-addr" : "127.0.0.1:9323",
    "experimental" : true
}
DAEMON
sudo systemctl start docker
