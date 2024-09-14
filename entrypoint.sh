#!/usr/bin/env bash

set -e


script_dir=$(cd $(dirname ${BASH_SOURCE[@]}) && pwd)
container_name="swarm-device-manager"


# All printed log lines from this script should be formatted with this function
print_log() {
  local timestamp="$(date +'%Y-%m-%d %H:%M:%S %z')"
  local pid="$$"
  local level="$1"
  local message="${@:2}"
  echo "[${timestamp}] [${pid}] [${level^^}] ${message}"
}


# Ensure docker socket is available
if [ ! -S /var/run/docker.sock ]; then
    print_log "error" "Missing Docker socket. Ensure you run this container mounting '/var/run/docker.sock'. Exit!"
    exit 1
fi


# Re-run this as a docker container with elevated privileges
if [ ! -d /host/sys ]; then
    # Ensure image version is available
    if [ "X${DOCKER_IAMGE}" = "X" ]; then
        print_log "error" "Missing required 'DOCKER_IAMGE' variable. Exit!"
        exit 1
    fi

    # Check if container is already running. Stop it
    if docker ps --filter "name=^${container_name}$" | grep -q "${container_name}"; then
        docker stop "${container_name}" &> /dev/null || true
    fi

    # Run docker container
    print_log "info" "Running privileged container '${container_name}'..."
    exec docker run \
        --rm \
        -i \
        --name "${container_name}" \
        --privileged \
        --cgroupns=host \
        --pid=host \
        --userns=host \
        -v /sys:/host/sys \
        -v /var/run/docker.sock:/var/run/docker.sock \
        "${DOCKER_IAMGE:?}"
fi


# Run service
print_log "info" "Running main service..."
exec /dvd
