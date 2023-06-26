build:
	docker build -t gui-in-docker .

XORG=-v ${HOME}/.Xauthority:/root/.Xauthority:rw -e DISPLAY --net=host

RUN=docker run ${XORG} --rm -it gui-in-docker

# Can pose security risk!
access-x:
	xhost + local:docker

bash: build access-x
	${RUN} bash

run: build access-x
	${RUN} xclock
