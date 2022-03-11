
SHELL=/bin/sh
IMAGENAME=mmm
IMAGEVERSION=test

build:
	sudo docker build -t $(IMAGENAME):$(IMAGEVERSION) .

run:
	sudo docker run -p 9000:8080 $(IMAGENAME):$(IMAGEVERSION)

shell:
# sudo docker run -it --name test-centos -v ${PWD}:/tmp -p 2222:22 --network host --privileged $(IMAGENAME):$(IMAGEVERSION) /bin/bash
	sudo docker run -d -it --name test-centos -v ${PWD}:/tmp -p 2222:22 $(IMAGENAME):$(IMAGEVERSION) /bin/zsh
	make login

stop:
	sudo docker stop test-centos
	sudo docker rm test-centos

login:
	sudo docker start test-centos
	sudo docker exec -i -t test-centos /bin/zsh