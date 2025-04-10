.DEFAULT_GOAL := help

.PHONY: clean delete

SHELL=bash
export DIFF_PROGRAM:=vimdiff

# Containerization Parameters (in future podman will useable)
export CONTAINER_BIN=podman
export CONTAINER_COMPOSE=${CONTAINER_BIN} compose
export DEFAULT_IMAGE_REGISTRY=docker.io/library/
export DOCKERFILE=./Dockerfile

# git parameters
GIT_URL := $(shell git remote get-url origin)
GIT_REPO := $(shell basename $(GIT_URL) .git)
GIT_BRANCH:=$(shell git branch --show-current)

# vnc configurations
EXTERNAL_VNC_PORT=15901
INTERNAL_PORT=80

# Docker/podman config
IMAGE_SUFFIX=

REGISTRY_HOST=localhost
IMAGE_USERNAME=library
IMAGE_NAME=${GIT_REPO}
IMAGE_TAG=${GIT_BRANCH}
IMAGE_NAME_TAG=${IMAGE_NAME}:${IMAGE_TAG}

CONTAINER_NAME=${GIT_REPO}-${EXTERNAL_VNC_PORT}

# Publicly warehoused pre-built (PB) image
IMAGE_URI_PREBUILT=ghcr.io/haisamido/x-vnc:latest
EXTERNAL_VNC_PORT_PB=15902
CONTAINER_NAME_PB=$(GIT_REPO)${IMAGE_SUFFIX}-${EXTERNAL_VNC_PORT_PB}

pull-prebuilt: ## Pull pre-built x-vnc image
	${CONTAINER_BIN} pull ${IMAGE_URI_PREBUILT}

up-prebuilt: pull-prebuilt ## Bring up x-vnc from a pre-built image from a remote registry
	$(MAKE) down CONTAINER_NAME=${CONTAINER_NAME_PB}
	${CONTAINER_BIN} run -d --rm \
		--name ${CONTAINER_NAME_PB} \
		--hostname ${CONTAINER_NAME_PB} \
		--volume ${HOME}/.ssh:/root/.ssh \
		--volume ${HOME}/.gitconfig:/root/.gitconfig \
		--volume ${PWD}/entrypoint.sh:/entrypoint.sh \
		--volume ${PWD}/startapp.sh:/startapp.sh \
		-p ${EXTERNAL_VNC_PORT_PB}:${INTERNAL_PORT} \
		${IMAGE_URI_PREBUILT} && \
		$(MAKE) info EXTERNAL_VNC_PORT=${EXTERNAL_VNC_PORT_PB}

build: ## Build 42 docker image
	${CONTAINER_BIN} build \
		--file ${DOCKERFILE} \
		-t ${IMAGE_NAME_TAG} .

up: | down build ## bring up X app in x/vnc system
	@${CONTAINER_BIN} run -d --rm \
		--name ${CONTAINER_NAME} \
		--hostname ${CONTAINER_NAME} \
		--volume ${HOME}/.ssh:/root/.ssh \
		--volume ${HOME}/.gitconfig:/root/.gitconfig \
		--volume ${PWD}/entrypoint.sh:/entrypoint.sh \
		--volume ${PWD}/startapp.sh:/startapp.sh \
		-p ${EXTERNAL_VNC_PORT}:${INTERNAL_PORT} ${IMAGE_NAME_TAG} && \
		$(MAKE) info

down: ## Bring down x-vnc
	${CONTAINER_BIN} stop ${CONTAINER_NAME} || true
	${CONTAINER_BIN} rm ${CONTAINER_NAME} || true

clean: ## clean up: stop, and remove container and delete 42's image
	${CONTAINER_BIN} stop ${CONTAINER_NAME} || true && \
	${CONTAINER_BIN} rm ${CONTAINER_NAME} || true && \
	${CONTAINER_BIN} rmi ${IMAGE_NAME_TAG} || true

delete: ## locally delete x-vnc's image
	${CONTAINER_BIN} rmi ${IMAGE_NAME_TAG} -f

info: ## show info
	@echo
	@echo "open browser to http://localhost:${EXTERNAL_VNC_PORT}/vnc.html and click on 'Connect'"
	@echo

#---
RESET  = \033[0m
PURPLE = \033[0;35m
GREEN  = \033[0;32m
LINE   = $(PURPLE)----------------------------------------------------------------------------------------$(RESET)

help:
	@echo
	@printf "\033[37m%-30s\033[0m %s\n" "#----------------------------------------------------------------------------------------"
	@printf "\033[37m%-30s\033[0m %s\n" "# This Makefile can be used to run build, bring up, and bring down, in vnc "
	@printf "\033[37m%-30s\033[0m %s\n" "#   open: http://localhost:${VNC_PORT}/vnc.html "
	@printf "\033[37m%-30s\033[0m %s\n" "#----------------------------------------------------------------------------------------"
	@echo 
	@printf "\033[37m%-30s\033[0m %s\n" "#-target-----------------------description-----------------------------------------------"
	@grep -E '^[a-zA-Z_-].+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo 

print-%  : ; @echo $* = $($*)
