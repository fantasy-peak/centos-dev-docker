# centos-dev-docker

## Overview
The centos7 docker image contains the latest version of boost, g++, hiredis, It can be used as our daily c++ development environment

## How to use it?
```shell
git clone https://github.com/fantasy-peak/centos-dev-docker.git
cd centos-dev-docker
// create docker images
make build
// create a container
make shell
// Login to container
make login
// stop and remove the container
make stop
```

