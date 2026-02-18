.git
.gitignore
LICENSE
README.md
Makefile
.dockerignore

.PHONY: build run clean stop logs

IMAGE_NAME ?= jumper
IMAGE_TAG ?= latest
PORT ?= 2222

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

run:
	docker run -d -p $(PORT):22 $(IMAGE_NAME):$(IMAGE_TAG)

run-interactive:
	docker run -it -p $(PORT):22 $(IMAGE_NAME):$(IMAGE_TAG) /bin/bash

stop:
	docker stop $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true

clean: stop
	docker rm $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true

logs:
	docker logs $(IMAGE_NAME):$(IMAGE_TAG)

pull:
	docker pull $(IMAGE_NAME):$(IMAGE_TAG)
