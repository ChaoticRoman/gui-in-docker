IMAGE=gui-in-docker

build:
	# Building without context
	docker build -t ${IMAGE} - < Dockerfile

XORG=-v ${HOME}/.Xauthority:/root/.Xauthority:rw -e DISPLAY --net=host

RUN=docker run ${XORG} --rm -it ${IMAGE}

# Can pose security risk!
ENABLE=xhost + local:docker
DISABLE=xhost - local:docker

bash: build
	${ENABLE}
	${RUN} bash
	${DISABLE}

run: build
	${ENABLE}
	${RUN} xclock
	${DISABLE}
