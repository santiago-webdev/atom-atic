#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG="${XDG_CONFIG_HOME}/atom-atic"

# Get script name without extension for log file
SCRIPT_NAME=$(basename "$0" .sh)
LOG_FILE="$HOME/${SCRIPT_NAME}.log"

# Redirect all output (stdout and stderr) to both console and log file
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE")

# ensure local registry is created and running
if ! podman start registry; then
    notify-send "atom-atic" "Failed to start registry container. Re-creating it..."
    podman stop -f registry 2>/dev/null
    podman rm registry 2>/dev/null
    podman run -d -p 5000:5000 --restart=always --name registry registry:latest
fi

cd $CONFIG
notify-send "atom-atic" "About to build your image"
podman build -t atom-atic -f ./Containerfile
if [[ $? -eq 125 ]]; then
	notify-send "atom-atic" "Failed build, exiting: ~/atom-atic.log"
	exit
fi

podman push localhost/atom-atic:latest localhost:5000/atom-atic:latest
notify-send "atom-atic" "Image pushed to local registry"
