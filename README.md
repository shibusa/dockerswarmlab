# Django project Docker deploy
This is just playing around with [Docker](https://docs.docker.com/manuals/) and implementing microservices.  Similar to the [webcluster](https://github.com/shibusa/webcluster) deploy of the Django based [ghquery](https://github.com/shibusa/ghquery) project, I'll be breaking off the nginx and django portions into their own containers.  All my VMs are using CentOS 7 running Debian 8 containers.

Table of Contents |
--- |
[Requirements](#requirements) |
[Vagrant Infrastructure](#vagrant-infrastructure-setup) |
[Docker Swarm](#docker-swarm-setup) |
[Docker Machine](#docker-machine-setup) |
[Deployment **WIP**](#project-deployment-setup-wip) |

## Requirements
- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/)

<sup>[Back to Top](#django-project-docker-deploy)</sup>

## Vagrant infrastructure Setup
1. Change to the `vagrantbuild` directory
2. Change [network settings](https://www.vagrantup.com/docs/networking/public_network.html) to desired settings.  When I built this lab, the Vagrant/Virtualbox hypervisor is the running on the same system as my Macbook. I'm using the WiFi interface and the same network range for my Macbook as my VMs (192.168.1.0/24).  The VMs will specifically be using the range of 192.168.1.10-29.
3. Start Vagrant VMs.  The Vagrantfile will be in charge of installing the Community version of Docker-Engine and building an insecure docker registry
```
vagrant up
```

### Brief [Docker Registry](https://docs.docker.com/registry/) Overview **WIP**
Docker registry will help distribute images across your swarm.  Images will be covered in a later section.  A non-production level registry node will be built as part of vagrant up.  Registry node setup has already been automated as well as inclusion of the insecure registry in `/etc/docker/daemon.json`.

Pushing to the repository:
```
docker push <registryip>:5000/<reponame>
```

Pulling from the repository:
```
docker pull <registryip>:5000/<reponame>
```

<sup>[Back to Top](#django-project-docker-deploy)</sup>

## [Docker Swarm](https://docs.docker.com/engine/swarm/key-concepts/#what-is-a-swarm) Setup
We're going to start with getting all of our VMs communicating with each other in the same cluster aka Docker Swarm.  As per [Docker](https://docs.docker.com/engine/swarm/key-concepts/#what-is-a-node), Docker Swarms consist of at least one manager node whose role is to deploy tasks to the worker nodes.  With Docker's decentralized design, the manager node will take on the same responsibilities of as a worker node as well.  As a single manager node in a swarm is a single point of failure for dispatching tasks, [high availability](https://docs.docker.com/datacenter/ucp/2.1/guides/admin/configure/set-up-high-availability/) will be implemented with additional manager nodes.  In this lab setup, I'll be using the 192.168.1.10-19 for manager nodes and 192.168.1.20-29 for my worker nodes.

1. Change to the `dockerbuild` directory
2.  Log on to a node you wish to use as a manager and [create swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)
```
docker swarm init --advertise-addr <node ip>
```
3. **Two options for additional manager nodes:**
- Get a manager join token by running `docker swarm join-token manager` on the first manager node.  Use the manager join token on each node you want as a manger.
- Use worker join token on all nodes.  On the first manager node, issue a promote `docker node promote <nodename>` for each worker node you want converted to a manger node.

4. Join remaining nodes to swarm
```
docker swarm join --token <token> <manager node ip>
```
5. Verify swarm by issuing `docker node ls` on any of the manager nodes

### [Docker Swarm Networking](https://docs.docker.com/engine/userguide/networking/#overlay-networks-in-swarm-mode)  **WIP**

<sup>[Back to Top](#django-project-docker-deploy)</sup>

## [Docker Machine](https://docs.docker.com/machine/overview/#why-should-i-use-it) Setup
Docker Machine will be running on your daily use system and allow you to remotely issue docker commands on those system short of actually having to ssh to each of the hosts.  This will enable you to have a prepared Dockerfile or docker-compose.yml on your local system and issue it on the remote machines without having to copy it over.

1. Add the nodes you want to manage onto your local system's Docker Machine.  I'm specifically using the generic driver as I'm approaching this lab as a baremetal system.
```
docker-machine create -d generic --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-port "22" --generic-ssh-user "vagrant" --generic-ip-address=<host ip> <hostname>
```
2. Verify nodes are added
```
vagrantlab/Docker [master●] » docker-machine ls
NAME            ACTIVE   DRIVER    STATE     URL                       SWARM   DOCKER        ERRORS
managernode-0   -        generic   Running   tcp://192.168.1.10:2376           v17.06.0-ce   
managernode-1   -        generic   Running   tcp://192.168.1.11:2376           v17.06.0-ce   
managernode-2   -        generic   Running   tcp://192.168.1.12:2376           v17.06.0-ce   
workernode-0    -        generic   Running   tcp://192.168.1.20:2376           v17.06.0-ce   
workernode-1    -        generic   Running   tcp://192.168.1.21:2376           v17.06.0-ce   
workernode-2    -        generic   Running   tcp://192.168.1.22:2376           v17.06.0-ce   
```
3.  You can ssh to the machine as you would normally, `docker-machine ssh <node name>`, or the following:
    1. Swap to the node of your choosing
    ```
    vagrantlab/Docker [master●] » eval $(docker-machine env managernode-0)
    ```
    2. Verify it is active
    ```
    vagrantlab/Docker [master●] » docker-machine active                   
    managernode-0
    ```
    3. Issue _docker commands_ in your local system as you would on the docker node.

<sup>[Back to Top](#django-project-docker-deploy)</sup>

## Project Deployment Setup **WIP**
### Container Image
1. Create a [dockerfile](https://docs.docker.com/engine/reference/builder/) that [defines your container](https://docs.docker.com/get-started/part2/#dockerfile).
2. Build an image from your aggregated files, including dockerfile
```
docker build -t <imagename> <directory with file contents>
```
Try `docker build -t testimage <pathto>/test/` for a quick demo on dockerfile syntax

**[Other useful commands](https://docs.docker.com/engine/reference/run/)**
- `docker run --name <name you wish to give to container> <imagename>` - Running instance of the container
- `docker ps -a` - List all containers
- `docker rm <container id>` - Remove unnecessary containers
- `docker images` - List images on node
- `docker rmi <image id>` - Remove image on node
- `docker attach  <container id>` - Attach local standard input, output, and error streams to a running container
- `docker exec <container id>` - Run a command in a running container

#### Service - cluster of containers


#### Stack - cluster of services

<sup>[Back to Top](#django-project-docker-deploy)</sup>
