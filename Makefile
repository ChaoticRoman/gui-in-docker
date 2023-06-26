build:
	docker build -t gui-in-docker .

run: build
	docker run --rm -it gui-in-docker
