
SHELL=/bin/sh
IMAGENAME=mmm
IMAGEVERSION=test
CONTAINE_RNAME=test-centos

build:
	sudo docker build -t $(IMAGENAME):$(IMAGEVERSION) .

run:
	sudo docker run -p 9000:8080 $(IMAGENAME):$(IMAGEVERSION)

shell:
# sudo docker run -it --name $(CONTAINE_RNAME) -v ${PWD}:/tmp -p 2222:22 --network host --privileged $(IMAGENAME):$(IMAGEVERSION) /bin/bash
	sudo docker run -d -it --name $(CONTAINE_RNAME) -v ${PWD}:/tmp -p 2222:22 $(IMAGENAME):$(IMAGEVERSION) /bin/zsh
	make login

stop:
	sudo docker stop $(CONTAINE_RNAME)
	sudo docker rm $(CONTAINE_RNAME)

login:
	sudo docker start $(CONTAINE_RNAME)
	sudo docker exec -i -t $(CONTAINE_RNAME) /bin/zsh