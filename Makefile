IMAGE=gui-in-docker

build:
	# Building without context
	docker build -t ${IMAGE} - < Dockerfile

# On some guides found on the internet they added also
#
#     -v ${HOME}/.Xauthority:/root/.Xauthority:rw
#
# but it was not required in my case...
XORG=-e DISPLAY --net=host

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
