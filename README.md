# X application in Docker/Podman within a Turbovnc web session

Refer to https://github.com/haisamido/x-vnc/pkgs/container/x-vnc if you just want to use a pre-built image

## Run the following commands 

```bash
CONTAINER_BIN=podman # or docker
CONTAINER_NAME=42-x-vnc
IMAGE_URI=ghcr.io/haisamido/x-vnc:main # <--- pre-built image

EXTERNAL_VNC_PORT=5801

${CONTAINER_BIN} stop ${CONTAINER_NAME} || true
${CONTAINER_BIN} rm ${CONTAINER_NAME} || true

${CONTAINER_BIN} run -d --rm \
		--name ${CONTAINER_NAME} \
		--volume ${PWD}/entrypoint.sh:/entrypoint.sh \
		--volume ${PWD}/startapp.sh:/startapp.sh \
		-p ${EXTERNAL_VNC_PORT}:80 \
		${IMAGE_URI}
```

Then open http://localhost:5801/vnc.html

## Or use the provided make file

### In `docker`

#### To build an X application inside of a `docker` image do the following:

`make build`

#### To bring up an X application inside of `docker` container do the following:

`make up`

then in a browser connect to http://localhost:5801/vnc.html and click on 'Connect'

#### To bring down `docker`'s an X application do the following:

`make down`

### In `podman`

#### To build an X application inside of a `podman` image do the following:

`make build CONTAINER_BIN=podman`

#### To bring up an X application inside of a `podman` container do the following:

`make up CONTAINER_BIN=podman`

then in a browser connect to http://localhost:5801/vnc.html and click on 'Connect'

#### To bring down `podman`'s an X application do the following:

`make down CONTAINER_BIN=podman`
