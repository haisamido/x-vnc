# Run an X application in Docker/Podman within a vnc (turbovnc) web session

Refer to https://github.com/haisamido/x-vnc/pkgs/container/x-vnc if you just want to use a pre-built image

## In `docker`

### To build an X application inside of a `docker` image do the following:

`make build`

### To bring up an X application inside of `docker` container do the following:

`make up`

then in a browser connect to http://localhost:5801/vnc.html and click on 'Connect'

### To bring down `docker`'s an X application do the following:

`make down`

## In `podman`

### To build an X application inside of a `podman` image do the following:

`make build CONTAINER_BIN=podman`

### To bring up an X application inside of a `podman` container do the following:

`make up CONTAINER_BIN=podman`

then in a browser connect to http://localhost:5801/vnc.html and click on 'Connect'

### To bring down `podman`'s an X application do the following:

`make down CONTAINER_BIN=podman`
