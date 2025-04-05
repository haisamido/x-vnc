#!/bin/bash

export DISPLAY=:1

xterm &
xeyes &

tail -f /dev/null
